//
//  PageLoader.swift
//  WinstonUIFoundation
//

import SwiftUI

/// An observable state controller for cursor-based paginated data.
///
/// `PageLoader` owns all mutable state (items, pagination cursor, loading state)
/// and provides four actions: `loadInitial`, `refresh`, `loadMore`, and `retry`.
/// It is generic over any `PaginatedDataSource`, keeping data-fetching logic separate.
///
/// Usage:
/// ```swift
/// @State private var loader = PageLoader(source: MyDataSource())
/// ```
@MainActor
@Observable
public final class PageLoader<Source: PaginatedDataSource> {

    // MARK: - Public state

    /// The currently loaded items. SwiftUI views read this directly.
    public private(set) var items: [Source.Item] = []

    /// Current state of the loader.
    public private(set) var state: PageState = .idle

    /// Whether more pages are available.
    public var hasMore: Bool { _hasMore }

    // MARK: - Private

    private let source: Source
    private var cursor: String?
    private var _hasMore: Bool = true
    private var activeTask: Task<Void, Never>?

    // MARK: - Init

    public init(source: Source) {
        self.source = source
    }

    // MARK: - Public actions

    /// Perform the initial load. No-op if a load is already in flight.
    public func loadInitial() {
        guard activeTask == nil else { return }
        state = items.isEmpty ? .loading : .idle
        _hasMore = true
        cursor = nil
        activeTask = Task {
            defer { activeTask = nil }
            do {
                let page = try await source.loadInitialPage()
                items = page.items
                cursor = page.nextCursor
                _hasMore = page.hasMore
                state = page.items.isEmpty ? .empty : .idle
            } catch is CancellationError {
                if items.isEmpty { state = .idle }
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    /// Pull-to-refresh: reload from scratch. Cancels any in-flight task.
    /// Existing items remain visible during the refresh.
    public func refresh() {
        activeTask?.cancel()
        activeTask = nil
        state = .refreshing
        cursor = nil
        activeTask = Task {
            defer { activeTask = nil }
            do {
                let page = try await source.loadInitialPage()
                items = page.items
                cursor = page.nextCursor
                _hasMore = page.hasMore
                state = page.items.isEmpty ? .empty : .idle
            } catch is CancellationError {
                state = items.isEmpty ? .idle : .idle
            } catch {
                // On refresh failure, keep existing items and revert to idle
                state = items.isEmpty ? .error(error.localizedDescription) : .idle
            }
        }
    }

    /// Load the next page. No-op if already loading or no more pages exist.
    public func loadMore() {
        guard activeTask == nil,
              _hasMore,
              let cursor
        else { return }

        state = .loadingMore
        activeTask = Task {
            defer { activeTask = nil }
            do {
                let page = try await source.loadPage(after: cursor)
                items.append(contentsOf: page.items)
                self.cursor = page.nextCursor
                _hasMore = page.hasMore
                state = .idle
            } catch is CancellationError {
                state = .idle
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    /// Retry the last failed operation.
    /// If items exist, retries `loadMore`; otherwise retries `loadInitial`.
    public func retry() {
        if items.isEmpty {
            state = .idle
            loadInitial()
        } else {
            state = .idle
            loadMore()
        }
    }
}
