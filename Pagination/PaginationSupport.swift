//
//  PaginationSupport.swift
//  WinstonUIFoundation
//

import Foundation

/// A page returned by a ``PaginatedDataSource``.
public struct Page<Item> {
    public let items: [Item]
    public let nextCursor: String?
    public let hasMore: Bool

    public init(items: [Item], nextCursor: String? = nil, hasMore: Bool) {
        self.items = items
        self.nextCursor = nextCursor
        self.hasMore = hasMore
    }
}

/// A source of cursor-paginated, identifiable values.
@MainActor
public protocol PaginatedDataSource {
    associatedtype Item: Identifiable

    func loadInitialPage() async throws -> Page<Item>
    func loadPage(after cursor: String) async throws -> Page<Item>
}

/// The state of a ``PageLoader``.
public enum PageState: Equatable {
    case idle
    case loading
    case refreshing
    case loadingMore
    case empty
    case error(String)

    public var isLoading: Bool {
        switch self {
        case .loading, .refreshing, .loadingMore:
            true
        case .idle, .empty, .error:
            false
        }
    }
}

public extension Double {
    /// Linearly interpolates between two CGFloat values.
    static func lerp(_ from: CGFloat, _ to: CGFloat, _ progress: CGFloat) -> CGFloat {
        from + (to - from) * progress
    }

    /// Applies a power-based ease-in curve.
    static func easeIn(_ value: Double, power: Double = 2) -> Double {
        pow(value, power)
    }
}
