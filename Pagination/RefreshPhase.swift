//
//  RefreshPhase.swift
//  WinstonUIFoundation
//

import Foundation

/// Describes the current phase of a pull-to-refresh gesture.
/// Custom `RefreshIndicator` views use this to drive their animations.
public enum RefreshPhase: Sendable, Equatable {
    /// User is not pulling, or pull distance is zero.
    case idle
    /// User is pulling down. `progress` ranges from 0 to 1, mapped to the pull threshold.
    case pulling(progress: Double)
    /// Threshold exceeded and refresh started. Indicator should show a looping animation.
    case refreshing
    /// Refresh completed. Indicator should play a brief completion animation before hiding.
    case completing
}
