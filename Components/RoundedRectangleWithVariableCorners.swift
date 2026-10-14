import SwiftUI

public struct CornerRadii: Sendable {
    public var topLeft: CGFloat
    public var topRight: CGFloat
    public var bottomLeft: CGFloat
    public var bottomRight: CGFloat

    public init(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    public init(all: CGFloat) {
        self.topLeft = all
        self.topRight = all
        self.bottomLeft = all
        self.bottomRight = all
    }
}

public struct RoundedRectangleWithVariableCorners: Shape {
    private let radii: CornerRadii
    public init(radii: CornerRadii) {
        self.radii = radii
    }

    public init(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {
        self.radii = CornerRadii(
            topLeft: topLeft,
            topRight: topRight,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        )
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let tl = min(radii.topLeft, rect.height / 2, rect.width / 2)
        let tr = min(radii.topRight, rect.height / 2, rect.width / 2)
        let bl = min(radii.bottomLeft, rect.height / 2, rect.width / 2)
        let br = min(radii.bottomRight, rect.height / 2, rect.width / 2)

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                radius: tr,
                startAngle: Angle(degrees: -90),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 {
            path.addArc(
                center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                radius: br,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
        }

        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                radius: bl,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
        }

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 {
            path.addArc(
                center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                radius: tl,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 270),
                clockwise: false
            )
        }

        path.closeSubpath()
        return path
    }
}

public extension View {

    func cornerRadius(_ radii: CornerRadii) -> some View {
        clipShape(RoundedRectangleWithVariableCorners(radii: radii))
    }
}
