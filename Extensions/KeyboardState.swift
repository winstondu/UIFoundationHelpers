//
//  KeyboardState.swift
//  WinstonUICore
//

import SwiftUI
import UIKit

@MainActor
@Observable
public final class KeyboardState {

    public static let shared = KeyboardState()

    public private(set) var isVisible: Bool = false
    public private(set) var height: CGFloat = 0

    private init() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard
                let self,
                let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
            self.height = frame.height
            self.isVisible = true
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.height = 0
            self?.isVisible = false
        }
    }
}
