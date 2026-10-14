import Foundation
import SwiftUI

public enum RevealStyle {
    case sequential
    case slowFromCenter
}

public struct OpacityRevealRenderer: TextRenderer, Animatable {
    public var progress: Double
    public var style: RevealStyle

    public var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    public init(progress: Double, style: RevealStyle = .sequential) {
        self.progress = progress
        self.style = style
    }

    public func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        switch style {
        case .sequential:
            drawSequential(layout: layout, in: &context)
        case .slowFromCenter:
            drawSlowFromCenter(layout: layout, in: &context)
        }
    }

    private func drawSequential(layout: Text.Layout, in context: inout GraphicsContext) {
        var glyphIndex = 0
        var totalGlyphs = 0

        for line in layout {
            for run in line {
                totalGlyphs += run.count
            }
        }

        for line in layout {
            for run in line {
                for glyph in run {
                    let glyphProgress = Double(glyphIndex) / Double(max(totalGlyphs - 1, 1))
                    let revealPoint = progress * 1.2
                    let glyphOpacity = min(1.0, max(0.0, (revealPoint - glyphProgress) * 5))

                    var copy = context
                    copy.opacity = glyphOpacity
                    copy.draw(glyph)
                    glyphIndex += 1
                }
            }
        }
    }

    private func drawSlowFromCenter(layout: Text.Layout, in context: inout GraphicsContext) {
        let lineCount = layout.count
        let lineStaggerDelay = 0.5

        for (lineIndex, line) in layout.enumerated() {
            var glyphsInLine = 0
            for run in line {
                glyphsInLine += run.count
            }

            let lineDelay = Double(lineIndex) * lineStaggerDelay
            let lineProgress = max(0.0, progress - lineDelay) / max(1.0 - lineDelay, 0.01)
            let centerIndex = Double(glyphsInLine - 1) / 2.0

            var glyphIndex = 0
            for run in line {
                for glyph in run {
                    let distanceFromCenter = abs(Double(glyphIndex) - centerIndex) / max(centerIndex, 1.0)
                    let glyphOpacity = min(1.0, max(0.0, (lineProgress * 2.0 - distanceFromCenter) * 3.0))

                    var copy = context
                    copy.opacity = glyphOpacity
                    copy.draw(glyph)
                    glyphIndex += 1
                }
            }
        }
    }
}
