//
//  View+.swift
//  Winston
//

import SwiftUI

public extension View {
    /// Performs an action only on the first appearance of the view.
    /// Unlike `.onAppear`, this will not fire again when navigating back to the view.
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }
}

private struct FirstAppearModifier: ViewModifier {
    @State private var didAppear = false
    let action: () -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            guard !didAppear else { return }
            didAppear = true
            action()
        }
    }
}
