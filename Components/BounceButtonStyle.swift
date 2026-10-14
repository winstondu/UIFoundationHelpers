//
//  BounceButtonStyle.swift
//  Winston
//
//  SwiftUI version of BounceButton
//

import SwiftUI

public struct BounceButtonStyle: ButtonStyle {
    public var scale: CGFloat

    public init(scale: CGFloat = 0.9) {
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeOut(duration: configuration.isPressed ? 0.1 : 0.3), value: configuration.isPressed)
    }
}

public extension View {
    func bounceEffect(scale: CGFloat = 0.9) -> some View {
        modifier(BounceModifier(scale: scale))
    }
}

fileprivate struct BounceModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.easeOut(duration: isPressed ? 0.1 : 0.3), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}
