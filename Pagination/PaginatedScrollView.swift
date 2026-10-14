//
//  PaginatedScrollView.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A scroll view with built-in pull-to-refresh, auto-load-more, and state handling.
///
/// Supports both list (LazyVStack) and grid (LazyVGrid) layouts:
/// ```swift
/// // List layout
/// PaginatedScrollView(loader: loader) { item in
///     ItemRow(item: item)
/// }
///
/// // Grid layout
/// PaginatedScrollView(loader: loader, columns: gridColumns) { item in
///     ItemCard(item: item)
/// }
/// ```
///
/// Automatically handles:
/// - Initial loading indicator
/// - Pull-to-refresh with custom animation
/// - Auto-load-more when scrolling near bottom
/// - Empty state
/// - Full-screen error with retry (on initial load failure)
/// - Inline error with retry (on load-more failure)
public struct PaginatedScrollView<
    Source: PaginatedDataSource,
    ItemContent: View,
    Indicator: RefreshIndicator,
    Empty: View
>: View {

    private let loader: PageLoader<Source>
    private let columns: [GridItem]?
    private let spacing: CGFloat
    private let loadMoreDistance: CGFloat
    private let refreshThreshold: CGFloat
    private let tint: Color
    private let contentPadding: EdgeInsets
    @ViewBuilder private let itemContent: (Source.Item) -> ItemContent
    @ViewBuilder private let emptyContent: () -> Empty

    @State private var refreshPhase: RefreshPhase = .idle
    @State private var pullDistance: CGFloat = 0
    @State private var isRefreshActive: Bool = false

    public init(
        loader: PageLoader<Source>,
        spacing: CGFloat = 0,
        loadMoreDistance: CGFloat = 300,
        refreshThreshold: CGFloat = 80,
        indicator: Indicator.Type = DefaultRefreshIndicator.self,
        tint: Color = .white,
        contentPadding: EdgeInsets = EdgeInsets(),
        @ViewBuilder content: @escaping (Source.Item) -> ItemContent,
        @ViewBuilder empty: @escaping () -> Empty
    ) {
        self.loader = loader
        self.columns = nil
        self.spacing = spacing
        self.loadMoreDistance = loadMoreDistance
        self.refreshThreshold = refreshThreshold
        self.tint = tint
        self.contentPadding = contentPadding
        self.itemContent = content
        self.emptyContent = empty
    }

    /// Creates a paginated scroll view with a **grid** layout.
    public init(
        loader: PageLoader<Source>,
        columns: [GridItem],
        spacing: CGFloat = 8,
        loadMoreDistance: CGFloat = 300,
        refreshThreshold: CGFloat = 80,
        indicator: Indicator.Type = DefaultRefreshIndicator.self,
        tint: Color = .white,
        contentPadding: EdgeInsets = EdgeInsets(),
        @ViewBuilder content: @escaping (Source.Item) -> ItemContent,
        @ViewBuilder empty: @escaping () -> Empty
    ) {
        self.loader = loader
        self.columns = columns
        self.spacing = spacing
        self.loadMoreDistance = loadMoreDistance
        self.refreshThreshold = refreshThreshold
        self.tint = tint
        self.contentPadding = contentPadding
        self.itemContent = content
        self.emptyContent = empty
    }

    public var body: some View {
        Group {
            switch loader.state {
            case .loading:
                loadingView
            case .empty:
                emptyContent()
            case .error(let msg) where loader.items.isEmpty:
                PaginatedErrorView(message: msg) { loader.retry() }
            default:
                scrollContent
            }
        }
        .task {
            if loader.items.isEmpty && loader.state == .idle {
                loader.loadInitial()
            }
        }
    }

    @ViewBuilder
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                Indicator(phase: refreshPhase)
                    .clipped()

                if let columns {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(loader.items) { item in
                            itemContent(item)
                        }
                    }
                    .padding(contentPadding)
                } else {
                    LazyVStack(spacing: spacing) {
                        ForEach(loader.items) { item in
                            itemContent(item)
                        }
                    }
                    .padding(contentPadding)
                }

                LoadMoreFooter(state: loader.state, tint: tint) {
                    loader.retry()
                }
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            let overscroll = -(geometry.contentOffset.y + geometry.contentInsets.top)
            return max(overscroll, 0)
        } action: { _, newValue in
            pullDistance = newValue
            guard !isRefreshActive else { return }
            let progress = min(Double(newValue / refreshThreshold), 1.0)
            if progress > 0 {
                refreshPhase = .pulling(progress: progress)
            } else if refreshPhase != .idle {
                refreshPhase = .idle
            }
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            if oldPhase == .interacting, !isRefreshActive, pullDistance >= refreshThreshold {
                triggerRefresh()
            }
            if oldPhase == .interacting, !isRefreshActive, pullDistance < refreshThreshold {
                withAnimation(.easeOut(duration: 0.25)) {
                    refreshPhase = .idle
                }
            }
        }
        .loadMore(
            distanceFromBottom: loadMoreDistance,
            isEnabled: !loader.state.isLoading && loader.hasMore
        ) {
            loader.loadMore()
        }
    }

    private var loadingView: some View {
        ProgressView()
            .tint(tint)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @MainActor
    private func triggerRefresh() {
        isRefreshActive = true
        withAnimation(.easeInOut(duration: 0.3)) {
            refreshPhase = .refreshing
        }
        Task {
            loader.refresh()
            // Wait for refresh to complete
            while loader.state == .refreshing {
                try? await Task.sleep(for: .milliseconds(50))
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                refreshPhase = .completing
            }
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.easeOut(duration: 0.3)) {
                refreshPhase = .idle
                isRefreshActive = false
            }
        }
    }
}

// MARK: - Convenience init without custom empty view

extension PaginatedScrollView where Empty == PaginatedEmptyView {

    /// Creates a paginated scroll view with a **list** layout and default empty state.
    public init(
        loader: PageLoader<Source>,
        spacing: CGFloat = 0,
        loadMoreDistance: CGFloat = 300,
        refreshThreshold: CGFloat = 80,
        indicator: Indicator.Type = DefaultRefreshIndicator.self,
        tint: Color = .white,
        contentPadding: EdgeInsets = EdgeInsets(),
        @ViewBuilder content: @escaping (Source.Item) -> ItemContent
    ) {
        self.init(
            loader: loader,
            spacing: spacing,
            loadMoreDistance: loadMoreDistance,
            refreshThreshold: refreshThreshold,
            indicator: indicator,
            tint: tint,
            contentPadding: contentPadding,
            content: content,
            empty: { PaginatedEmptyView() }
        )
    }

    /// Creates a paginated scroll view with a **grid** layout and default empty state.
    public init(
        loader: PageLoader<Source>,
        columns: [GridItem],
        spacing: CGFloat = 8,
        loadMoreDistance: CGFloat = 300,
        refreshThreshold: CGFloat = 80,
        indicator: Indicator.Type = DefaultRefreshIndicator.self,
        tint: Color = .white,
        contentPadding: EdgeInsets = EdgeInsets(),
        @ViewBuilder content: @escaping (Source.Item) -> ItemContent
    ) {
        self.init(
            loader: loader,
            columns: columns,
            spacing: spacing,
            loadMoreDistance: loadMoreDistance,
            refreshThreshold: refreshThreshold,
            indicator: indicator,
            tint: tint,
            contentPadding: contentPadding,
            content: content,
            empty: { PaginatedEmptyView() }
        )
    }
}
