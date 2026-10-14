//
//  DefaultRefreshIndicator.swift
//  WinstonUIFoundation
//

import SwiftUI

/// A built-in refresh indicator that draws an animated arc spinner.
/// Designed for dark backgrounds with white tint by default.
public struct DefaultRefreshIndicator: RefreshIndicator {
    public let phase: RefreshPhase

    public init(phase: RefreshPhase) {
        self.phase = phase
    }

    public var body: some View {
        ZStack {
            switch phase {
            case .idle:
                Color.clear
            case .pulling(let progress):
                ArcShape(trimEnd: progress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .opacity(progress)
            case .refreshing:
                SpinningArc()
            case .completing:
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: indicatorHeight)
        .frame(maxWidth: .infinity)
    }

    private var indicatorHeight: CGFloat {
        switch phase {
        case .idle: 0
        case .pulling(let p): 56 * p
        case .refreshing: 56
        case .completing: 56
        }
    }
}

// MARK: - Spinning arc (used during .refreshing)

private struct SpinningArc: View {
    @State private var rotation: Double = 0

    var body: some View {
        ArcShape(trimEnd: 0.75)
            .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Arc shape

private struct ArcShape: Shape {
    var trimEnd: Double

    var animatableData: Double {
        get { trimEnd }
        set { trimEnd = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: min(rect.width, rect.height) / 2,
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + 360 * trimEnd),
                clockwise: false
            )
        }
    }
}
