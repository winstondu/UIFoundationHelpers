//
//  VariableBlur.swift
//  TestSwipe
//
//
//https://github.com/nikstar/VariableBlur

import Foundation
import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins
import QuartzCore


public enum VariableBlurDirection {
    case blurredTopClearBottom
    case blurredBottomClearTop
    case blurredLeftClearRight
    case blurredRightClearLeft
}


public struct VariableBlurView: UIViewRepresentable {

    public var maxBlurRadius: CGFloat = 20
    public var gradientMinHeight: CGFloat = 100.0
    public var direction: VariableBlurDirection = .blurredTopClearBottom

    /// By default, variable blur starts from 0 blur radius and linearly increases to `maxBlurRadius`. Setting `startOffset` to a small negative coefficient (e.g. -0.1) will start blur from larger radius value which might look better in some cases.
    public var startOffset: CGFloat = 0

    public init(maxBlurRadius: CGFloat = 20,
                gradientMinHeight: CGFloat = 100.0,
                direction: VariableBlurDirection = .blurredTopClearBottom,
                startOffset: CGFloat = 0) {
        self.maxBlurRadius = maxBlurRadius
        self.gradientMinHeight = gradientMinHeight
        self.direction = direction
        self.startOffset = startOffset
    }

    public func makeUIView(context: Context) -> VariableBlurUIView {
        VariableBlurUIView(maxBlurRadius: maxBlurRadius,
                           gradientMinHeight: gradientMinHeight,
                           direction: direction,
                           startOffset: startOffset)
    }

    public func updateUIView(_ uiView: VariableBlurUIView, context: Context) {
        uiView.setFilter(maxBlurRadius: maxBlurRadius,
                         gradientMinHeight: gradientMinHeight,
                         direction: direction,
                         startOffset: startOffset)
    }
}


/// credit https://github.com/jtrivedi/VariableBlurView
open class VariableBlurUIView: UIVisualEffectView {

    public init(maxBlurRadius: CGFloat = 20,
                gradientMinHeight: CGFloat,
                direction: VariableBlurDirection = .blurredTopClearBottom, startOffset: CGFloat = 0) {
        super.init(effect: UIBlurEffect(style: .regular))
        setFilter(maxBlurRadius: maxBlurRadius,
                  gradientMinHeight: gradientMinHeight,
                  direction: direction,
                  startOffset: startOffset)

    }

    fileprivate func setFilter(maxBlurRadius: CGFloat = 20,
                               gradientMinHeight: CGFloat,
                               direction: VariableBlurDirection = .blurredTopClearBottom, startOffset: CGFloat = 0) {
        let clsName = String("retliFAC".reversed())
        guard let Cls = NSClassFromString(clsName)! as? NSObject.Type else {
            print("[VariableBlur] Error: Can't find filter class")
            return
        }
        let selName = String(":epyThtiWretlif".reversed())
        guard let variableBlur = Cls.self.perform(NSSelectorFromString(selName), with: "variableBlur").takeUnretainedValue() as? NSObject else {
            print("[VariableBlur] Error: Can't create variableBlur filter")
            return
        }

        // The blur radius at each pixel depends on the alpha value of the corresponding pixel in the gradient mask.
        // An alpha of 1 results in the max blur radius, while an alpha of 0 is completely unblurred.
        let gradientImage = makeGradientImage(height: gradientMinHeight, startOffset: startOffset, direction: direction)

        variableBlur.setValue(maxBlurRadius, forKey: "inputRadius")
        variableBlur.setValue(gradientImage, forKey: "inputMaskImage")
        variableBlur.setValue(true, forKey: "inputNormalizeEdges")
        // We use a `UIVisualEffectView` here purely to get access to its `CABackdropLayer`,
        // which is able to apply various, real-time CAFilters onto the views underneath.
        let backdropLayer = subviews.first?.layer

        // Replace the standard filters (i.e. `gaussianBlur`, `colorSaturate`, etc.) with only the variableBlur.
        backdropLayer?.filters = [variableBlur]

        // Get rid of the visual effect view's dimming/tint view, so we don't see a hard line.
        for subview in subviews.dropFirst() {
            subview.alpha = 0
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func didMoveToWindow() {
        // fixes visible pixelization at unblurred edge (https://github.com/nikstar/VariableBlur/issues/1)
        guard let window, let backdropLayer = subviews.first?.layer else { return }
        backdropLayer.setValue(window.traitCollection.displayScale, forKey: "scale")
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // `super.traitCollectionDidChange(previousTraitCollection)` crashes the app
    }

    private func makeGradientImage(width: CGFloat = 100, height: CGFloat = 100, startOffset: CGFloat, direction: VariableBlurDirection) -> CGImage {
        let ciGradientFilter =  CIFilter.linearGradient()
        ciGradientFilter.color0 = CIColor.black
        ciGradientFilter.color1 = CIColor.clear
        ciGradientFilter.point0 = CGPoint(x: 0, y: height)
        ciGradientFilter.point1 = CGPoint(x: 0, y: startOffset * height) // small negative value looks better with vertical lines

        switch direction {
        case .blurredTopClearBottom:
            break
        case .blurredBottomClearTop:
            ciGradientFilter.point0.y = 0
            ciGradientFilter.point1.y = height - ciGradientFilter.point1.y
        case .blurredLeftClearRight:
            // black (alpha 1) on the left, clear (alpha 0) on the right
            ciGradientFilter.point0 = CGPoint(x: 0, y: 0)
            ciGradientFilter.point1 = CGPoint(x: width - (startOffset * width), y: 0)
        case .blurredRightClearLeft:
            // black (alpha 1) on the right, clear (alpha 0) on the left
            ciGradientFilter.point0 = CGPoint(x: width, y: 0)
            ciGradientFilter.point1 = CGPoint(x: startOffset * width, y: 0)
        }
        return CIContext().createCGImage(ciGradientFilter.outputImage!, from: CGRect(x: 0, y: 0, width: width, height: height))!
    }
}
