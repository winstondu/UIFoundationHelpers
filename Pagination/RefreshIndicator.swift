//
//  RefreshIndicator.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A view that acts as a pull-to-refresh indicator.
///
/// The system injects the current `RefreshPhase` and the indicator
/// drives its own animations in response.
///
/// Conform to this protocol to provide a custom refresh animation:
/// ```swift
/// struct MyIndicator: RefreshIndicator {
///     let phase: RefreshPhase
///     var body: some View { ... }
/// }
/// ```
public protocol RefreshIndicator: View {
    init(phase: RefreshPhase)
}
