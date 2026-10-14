//
//  RefreshControlViewType.swift
//  WinstonNetModels
//
//

import Foundation
import Combine

public enum RefreshControlViewState: Equatable {
    case idle
    case pulling(progress: CGFloat)
    case refreshing

    public static func == (lhs: RefreshControlViewState, rhs: RefreshControlViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case let (.pulling(l), .pulling(r)):
            return l == r
        case (.refreshing, .refreshing):
            return true
        default:
            return false
        }
    }
}


@MainActor
public protocol RefreshControlViewType {
    var currentState: CurrentValueSubject<RefreshControlViewState, Never> { get }
    func stateDidChanged(_ state: RefreshControlViewState)
}
