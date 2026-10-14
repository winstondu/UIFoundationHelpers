//
//  LoadMoreModifier.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A ViewModifier that detects when the user scrolls near the bottom
/// and triggers a load-more action.
///
/// Uses `onScrollGeometryChange` to compare the remaining scrollable distance
/// against a threshold. A `hasTriggered` flag prevents duplicate triggers;
/// it resets when `contentSize.height` changes (i.e., new items are appended).
///
/// Usage:
/// ```swift
/// ScrollView {
///     LazyVStack { ... }
/// }
/// .loadMore { viewModel.loadMore() }
/// ```
@available(iOS 18, *)
struct LoadMoreModifier: ViewModifier {
    let distanceThreshold: CGFloat
    let isEnabled: Bool
    let onLoadMore: @MainActor () -> Void

    @State private var hasTriggered = false

    func body(content: Content) -> some View {
        content
            // Detect when near bottom
            .onScrollGeometryChange(for: Bool.self) { geometry in
                let remaining =
                    geometry.contentSize.height
                    - geometry.contentOffset.y
                    - geometry.visibleRect.size.height
                return remaining < distanceThreshold
            } action: { _, isNearBottom in
                if isNearBottom, isEnabled, !hasTriggered {
                    hasTriggered = true
                    onLoadMore()
                }
            }
            // Reset trigger when content size changes (new items loaded)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentSize.height
            } action: { oldHeight, newHeight in
                if newHeight != oldHeight {
                    hasTriggered = false
                }
            }
    }
}

// MARK: - View extension

extension View {

    /// Triggers an action when the user scrolls near the bottom of the content.
    ///
    /// Apply this modifier to a `ScrollView`. The action fires once per scroll
    /// to the threshold zone and resets when new content is appended.
    ///
    /// - Parameters:
    ///   - distanceFromBottom: Distance from the bottom (in points) at which to trigger. Defaults to 300.
    ///   - isEnabled: Whether load-more detection is active. Defaults to `true`.
    ///   - action: A closure called when the scroll position enters the threshold zone.
    @available(iOS 18, *)
    public func loadMore(
        distanceFromBottom: CGFloat = 300,
        isEnabled: Bool = true,
        action: @escaping @MainActor () -> Void
    ) -> some View {
        modifier(LoadMoreModifier(
            distanceThreshold: distanceFromBottom,
            isEnabled: isEnabled,
            onLoadMore: action
        ))
    }
}
