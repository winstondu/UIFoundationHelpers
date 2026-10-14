//
//  UIColor+.swift
//  Winston
//
//

import SwiftUI
import UIKit

public extension UIColor {

    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// Initialize with a hex string like "#E0115F" or "E0115F".
    /// Supports 3‑, 6‑ or 8‑digit hex (the 8‑digit form includes the leading alpha channel).
    /// Returns nil if the string can't be parsed.
    convenience init?(hex: String) {
        // Strip leading “#” and whitespace, convert to upper‑case
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }

        // Expand shorthand 3‑digit form to 6 digits (e.g. "ABC" → "AABBCC")
        if cleaned.count == 3 {
            let chars = cleaned.map { "\($0)" }
            cleaned = chars.map { $0 + $0 }.joined()
        }

        // Accept 6‑digit RGB or 8‑digit ARGB
        guard cleaned.count == 6 || cleaned.count == 8,
              let int = UInt32(cleaned, radix: 16) else { return nil }

        let a, r, g, b: UInt32
        if cleaned.count == 6 {
            (a, r, g, b) = (255,
                            (int >> 16) & 0xFF,
                            (int >> 8) & 0xFF,
                            int & 0xFF)
        } else { // 8‑digit ARGB
            (a, r, g, b) = ((int >> 24) & 0xFF,
                            (int >> 16) & 0xFF,
                            (int >> 8) & 0xFF,
                            int & 0xFF)
        }

        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: CGFloat(a) / 255.0)
    }

    func lerpHSB(to: UIColor, t: CGFloat) -> UIColor {
        var h1: CGFloat = 0, s1: CGFloat = 0, l1: CGFloat = 0, a1: CGFloat = 0
        var h2: CGFloat = 0, s2: CGFloat = 0, l2: CGFloat = 0, a2: CGFloat = 0

        self.getHue(&h1, saturation: &s1, brightness: &l1, alpha: &a1)
        to.getHue(&h2, saturation: &s2, brightness: &l2, alpha: &a2)

        let hueDiff = h2 - h1
        if hueDiff > 0.5 {
            h1 += 1.0
        } else if hueDiff < -0.5 {
            h2 += 1.0
        }

        return UIColor(hue: Double.lerp(h1, h2, t).truncatingRemainder(dividingBy: 1.0),
                       saturation: Double.lerp(s1, s2, t),
                       brightness: Double.lerp(l1, l2, t),
                       alpha: Double.lerp(a1, a2, t))
    }

}
