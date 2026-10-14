//
//  PullToRefreshModifier.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A ViewModifier that adds pull-to-refresh behavior to scroll content.
///
/// This modifier wraps the content in a `ScrollView` and injects a custom
/// `RefreshIndicator` above it. It uses iOS 18's `onScrollGeometryChange`
/// and `onScrollPhaseChange` to detect overscroll and finger release.
///
/// Usage:
/// ```swift
/// LazyVStack { ... }
///     .pullToRefresh { await viewModel.refresh() }
/// ```
///
/// - Note: This modifier creates its own `ScrollView`. Pass the scroll *content*,
///   not a `ScrollView` itself.
struct PullToRefreshModifier<Indicator: RefreshIndicator>: ViewModifier {
    let threshold: CGFloat
    let onRefresh: @MainActor () async -> Void

    @State private var phase: RefreshPhase = .idle
    @State private var pullDistance: CGFloat = 0
    @State private var isRefreshActive: Bool = false

    func body(content: Content) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                indicatorView
                content
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            // Overscroll = how far past the top the user has pulled.
            // At rest at top, contentOffset.y == contentInsets.top (negative).
            // Pulling down decreases contentOffset.y further.
            let overscroll = -(geometry.contentOffset.y + geometry.contentInsets.top)
            return max(overscroll, 0)
        } action: { _, newValue in
            pullDistance = newValue
            guard !isRefreshActive else { return }
            let progress = min(Double(newValue / threshold), 1.0)
            if progress > 0 {
                phase = .pulling(progress: progress)
            } else if phase != .idle {
                phase = .idle
            }
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            // Trigger refresh when user lifts finger while past threshold
            if oldPhase == .interacting,
               !isRefreshActive,
               pullDistance >= threshold
            {
                triggerRefresh()
            }
            // If user releases below threshold, reset
            if oldPhase == .interacting,
               !isRefreshActive,
               pullDistance < threshold
            {
                withAnimation(.easeOut(duration: 0.25)) {
                    phase = .idle
                }
            }
        }
    }

    @ViewBuilder
    private var indicatorView: some View {
        Indicator(phase: phase)
            .clipped()
    }

    @MainActor
    private func triggerRefresh() {
        isRefreshActive = true
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .refreshing
        }
        Task {
            await onRefresh()
            withAnimation(.easeInOut(duration: 0.2)) {
                phase = .completing
            }
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.easeOut(duration: 0.3)) {
                phase = .idle
                isRefreshActive = false
            }
        }
    }
}

// MARK: - View extension

extension View {

    /// Adds pull-to-refresh with a custom indicator to this scroll content.
    ///
    /// This modifier wraps the content in a `ScrollView`, so apply it to
    /// the content *inside* the scroll view, not the scroll view itself.
    ///
    /// - Parameters:
    ///   - indicator: The type of `RefreshIndicator` to display. Defaults to `DefaultRefreshIndicator`.
    ///   - threshold: Pull distance (in points) required to trigger a refresh. Defaults to 80.
    ///   - action: An async closure called when the user triggers a refresh.
    public func pullToRefresh<I: RefreshIndicator>(
        indicator: I.Type = DefaultRefreshIndicator.self,
        threshold: CGFloat = 80,
        action: @escaping @MainActor () async -> Void
    ) -> some View {
        modifier(PullToRefreshModifier<I>(
            threshold: threshold,
            onRefresh: action
        ))
    }
}
