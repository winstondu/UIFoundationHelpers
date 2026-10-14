//
//  SmoothGradientView.swift
//  Winston
//
//

import Foundation
import SwiftUI

public struct SmoothGradientView: View {
    let color: Color
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    let steps: Int

    public init(color: Color = .black, startPoint: UnitPoint = .bottom, endPoint: UnitPoint = .top, steps: Int = 6) {
        self.color = color
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.steps = steps
    }

    public var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: (0...steps).map { i in
                            let t = Double(i) / Double(steps)
                        return color.opacity(Double.easeIn(t, power: 1.5))
                        },
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .ignoresSafeArea()
    }
}
