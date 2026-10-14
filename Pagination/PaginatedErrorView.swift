//
//  PaginatedErrorView.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A default error state view with a retry button for paginated content.
public struct PaginatedErrorView: View {
    private let message: String
    private let onRetry: () -> Void

    public init(message: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
                .tint(.white)
        }
        .foregroundStyle(.white.opacity(0.7))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
