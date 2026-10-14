//
//  BouncyButton.swift
//  Winston
//
//

import SwiftUI

struct BounceEffect: ViewModifier {
    let action: () -> Void
    @GestureState private var isPressed = false
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.9 : scale)
            .animation(.easeOut(duration: 0.1), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            scale = 1.0
                        }
                        action()
                    }
            )
    }
}

extension View {
    public func bounceButton(action: @escaping () -> Void) -> some View {
        modifier(BounceEffect(action: action))
    }
}
