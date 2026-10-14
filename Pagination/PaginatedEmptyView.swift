//
//  PaginatedEmptyView.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A default empty state view for paginated content.
public struct PaginatedEmptyView: View {
    private let title: String
    private let subtitle: String?
    private let systemImage: String

    public init(
        title: String = "Nothing here yet",
        subtitle: String? = nil,
        systemImage: String = "tray"
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let subtitle {
                Text(subtitle)
            }
        }
        .foregroundStyle(.white.opacity(0.6))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
