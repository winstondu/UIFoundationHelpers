//
//  CreationLiquidGlass.swift
//  Winston
//
//

import SwiftUI

public extension View {
    @ViewBuilder
    func applyGlassEffectForPanel<S: Shape>(_ interactive: Bool = true, in shape: S) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.clear.interactive(interactive), in: shape)
        } else {
            self.background(.ultraThinMaterial.opacity(0.75))
            .clipShape(shape)
            .overlay {
                shape
                    .stroke(.white.opacity(0.5), lineWidth: 1)
            }
            .shadow(radius: 10)
        }
    }

    @ViewBuilder
    func suppressGlassEffect() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.identity)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyGlassEffectForButton<S: Shape>(shape: S, tint: Color = .clear) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular.interactive(true).tint(tint), in: shape)
        } else {
            self.background{
                shape.fill(tint == .clear ? .white.opacity(0.25) : tint)
            }
        }
    }
}

public extension ToolbarContent {
    @ToolbarContentBuilder
    func suppressSharedBackground() -> some ToolbarContent {
        if #available(iOS 26, *) {
            self.sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}
