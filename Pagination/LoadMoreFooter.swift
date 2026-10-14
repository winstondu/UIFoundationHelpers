//
//  LoadMoreFooter.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A footer view placed at the bottom of paginated content.
///
/// Shows a spinner during `.loadingMore`, a retry button on `.error`,
/// or nothing otherwise. Place this after your `ForEach` inside the scroll content.
///
/// ```swift
/// ScrollView {
///     LazyVStack {
///         ForEach(items) { ... }
///         LoadMoreFooter(state: loader.state) { loader.retry() }
///     }
/// }
/// ```
public struct LoadMoreFooter: View {
    private let state: PageState
    private let tint: Color
    private let onRetry: () -> Void

    public init(
        state: PageState,
        tint: Color = .white,
        onRetry: @escaping () -> Void
    ) {
        self.state = state
        self.tint = tint
        self.onRetry = onRetry
    }

    public var body: some View {
        Group {
            switch state {
            case .loadingMore:
                ProgressView()
                    .tint(tint)
                    .padding(.vertical, 20)
            case .error(let message):
                VStack(spacing: 8) {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(tint.opacity(0.6))
                        .multilineTextAlignment(.center)
                    Button("Retry", action: onRetry)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(tint)
                }
                .padding(.vertical, 16)
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
    }
}
