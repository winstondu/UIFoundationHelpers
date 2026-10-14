import SwiftUI

public struct DotPatternView: View {
    var dotRadius: Double
    var spacing: Double
    var jitter: Double
    var opacity: Double

    public init(dotRadius: Double = 1.5, spacing: Double = 28, jitter: Double = 10, opacity: Double = 0.25) {
        self.dotRadius = dotRadius
        self.spacing = spacing
        self.jitter = jitter
        self.opacity = opacity
    }

    public var body: some View {
        Canvas { context, size in
            let cols = Int(ceil(size.width / spacing)) + 1
            let rows = Int(ceil(size.height / spacing)) + 1
            let color = GraphicsContext.Shading.color(.white.opacity(opacity))

            for row in 0..<rows {
                for col in 0..<cols {
                    let (dx, dy) = jitterOffset(row: row, col: col)
                    let x = Double(col) * spacing + dx
                    let y = Double(row) * spacing + dy
                    let rect = CGRect(x: x - dotRadius, y: y - dotRadius,
                                      width: dotRadius * 2, height: dotRadius * 2)
                    context.fill(Path(ellipseIn: rect), with: color)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func jitterOffset(row: Int, col: Int) -> (Double, Double) {
        var h = UInt64(bitPattern: Int64(row) &* 2654435761) ^ UInt64(bitPattern: Int64(col) &* 2246822519)
        h ^= h >> 33
        h &*= 0xff51afd7ed558ccd
        h ^= h >> 33
        let dx = (Double(h & 0xFFFF) / 65535.0 - 0.5) * jitter * 2
        let dy = (Double((h >> 16) & 0xFFFF) / 65535.0 - 0.5) * jitter * 2
        return (dx, dy)
    }
}
