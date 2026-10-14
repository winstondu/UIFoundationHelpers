//
//  LoopingVideoView.swift
//  Winston
//
//

import SwiftUI
import AVFoundation
import UIKit

public struct LoopingVideoView: UIViewRepresentable {
    public let videoURL: URL?
    public let isMuted: Bool
    public let videoGravity: AVLayerVideoGravity

    public init(videoURL: URL?, isMuted: Bool, videoGravity: AVLayerVideoGravity) {
        self.videoURL = videoURL
        self.isMuted = isMuted
        self.videoGravity = videoGravity
    }

    public func makeUIView(context: Context) -> LoopingPlayerUIView {
        let view = LoopingPlayerUIView()
        view.configure(
            videoURL: videoURL,
            isMuted: isMuted,
            videoGravity: videoGravity
        )
        return view
    }

    public func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {
        uiView.configure(
            videoURL: videoURL,
            isMuted: isMuted,
            videoGravity: videoGravity
        )
    }

    public static func dismantleUIView(_ uiView: LoopingPlayerUIView, coordinator: ()) {
        uiView.resetPlayer()
    }
}

@MainActor
public final class LoopingPlayerUIView: UIView {
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var currentVideoURL: URL?

    public override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        // Break player references as soon as the view is detached.
        if newWindow == nil {
            resetPlayer()
        }
    }

    public func configure(videoURL: URL?, isMuted: Bool, videoGravity: AVLayerVideoGravity) {
        playerLayer.videoGravity = videoGravity

        guard let videoURL else {
            resetPlayer()
            return
        }

        if currentVideoURL != videoURL || queuePlayer == nil {
            let item = AVPlayerItem(url: videoURL)
            let player = AVQueuePlayer()
            let looper = AVPlayerLooper(player: player, templateItem: item)
            player.preventsDisplaySleepDuringVideoPlayback = false
            queuePlayer = player
            playerLooper = looper
            currentVideoURL = videoURL
            playerLayer.player = player
        }

        queuePlayer?.isMuted = isMuted
        queuePlayer?.play()
    }

    public func resetPlayer() {
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        playerLooper?.disableLooping()
        playerLayer.player = nil
        queuePlayer = nil
        playerLooper = nil
        currentVideoURL = nil
    }
}
