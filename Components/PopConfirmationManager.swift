//
//  PopConfirmationManager.swift
//  Winston
//
//  A UI-agnostic manager for handling pop confirmation dialogs with safe continuation handling.
//

import SwiftUI

/// Manages pop confirmation state for router with guaranteed single-resumption.
///
/// Usage: `await requestConfirmation()` suspends in before you plan to pop, until
/// the UI (in a separate location) calls `confirm()` or `cancel()`.
/// Always call `cancelIfNeeded()` in `.onDisappear` for views.
@MainActor
@Observable
public final class PopConfirmationManager {

    // MARK: - Observable State

    /// Whether a confirmation request is currently active.
    public private(set) var isRequesting = false

    // MARK: - Private

    private var continuation: CheckedContinuation<Bool, Never>?
    private var currentRequestId: UUID?
    private var confirmTask: Task<Void, Never>?

    #if DEBUG
    private let creationFile: StaticString
    private let creationLine: UInt
    #endif

    // MARK: - Initialization

    public init(file: StaticString = #file, line: UInt = #line) {
        #if DEBUG
        self.creationFile = file
        self.creationLine = line
        #endif
    }

    @MainActor deinit {
        #if DEBUG
        if continuation != nil {
            fatalError("PopConfirmationManager deallocated with pending continuation. Call cancelIfNeeded() in onDisappear. Created at \(creationFile):\(creationLine)")
        }
        #else
        cancelIfNeeded()
        #endif
    }

    // MARK: - Public API

    /// Request confirmation from the user. Returns `true` if confirmed, `false` if cancelled.
    public func requestConfirmation() async -> Bool {
        confirmTask?.cancel()
        confirmTask = nil
        cancelIfNeeded()

        let requestId = UUID()
        currentRequestId = requestId
        isRequesting = true

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    /// User confirmed - proceed with pop.
    public func confirm() {
        respond(true)
    }

    /// User cancelled - abort pop.
    public func cancel() {
        respond(false)
    }

    /// Run async work, then confirm. Task is cancelled if a new request starts or if cancelled.
    public func confirmAsync(_ work: @escaping @MainActor @Sendable () async -> Void) {
        let requestId = currentRequestId
        confirmTask = Task {
            await work()
            guard !Task.isCancelled else { return }
            guard currentRequestId == requestId else { return }
            confirm()
        }
    }

    /// Cancel if needed. Call in `.onDisappear` for UI to ensure the continuation is always resumed.
    public func cancelIfNeeded() {
        confirmTask?.cancel()
        confirmTask = nil
        if continuation != nil {
            cancel()
        }
    }

    /// Binding for SwiftUI modifiers like `.alert(isPresented:)`.
    public var binding: Binding<Bool> {
        Binding(
            get: { self.isRequesting },
            set: { newValue in
                if !newValue {
                    if self.confirmTask == nil {
                        self.cancel()
                    } else {
                        self.isRequesting = false
                    }
                }
            }
        )
    }

    // MARK: - Private

    /// Atomically respond to the confirmation request.
    private func respond(_ shouldPop: Bool) {
        guard let cont = continuation else { return }
        continuation = nil
        currentRequestId = nil
        confirmTask?.cancel()
        confirmTask = nil
        isRequesting = false
        cont.resume(returning: shouldPop)
    }
}
