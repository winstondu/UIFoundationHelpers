import SwiftUI

public extension View {
    @ViewBuilder
    func applyGlassEffect<S: Shape>(_ interactive: Bool = true, in shape: S) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular.interactive(interactive), in: shape)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyScrollEdgeEffectStyle(for edges: Edge.Set) -> some View {
        if #available(iOS 26, *) {
            self.scrollEdgeEffectStyle(.automatic, for: edges)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyOnlyLegacy<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            transform(self)
        }
    }
}
