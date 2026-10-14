//
//  UIImage+Extension.swift
//  Winston
//

import SwiftUI
import UIKit

public extension UIImage {
    func extractDominantColors() -> [Color]? {
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = resizedImage?.cgImage else {
            return nil
        }

        let data = cgImage.dataProvider?.data
        let ptr = CFDataGetBytePtr(data)
        let length = CFDataGetLength(data ?? CFDataCreate(nil, nil, 0))

        if length < 4 {
            return nil
        }

        var colorCounts: [UInt32: Int] = [:]
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                let idx = ((Int(size.width) * y) + x) * 4
                if idx + 3 < length {
                    let r = ptr?[idx] ?? 0
                    let g = ptr?[idx + 1] ?? 0
                    let b = ptr?[idx + 2] ?? 0
                    let a = ptr?[idx + 3] ?? 0
                    let key = UInt32(r) << 24 | UInt32(g) << 16 | UInt32(b) << 8 | UInt32(a)
                    colorCounts[key, default: 0] += 1
                }
            }
        }

        let sorted = colorCounts.sorted { $0.value > $1.value }
        let dominant = sorted.first?.key
        let secondary = sorted.dropFirst().first?.key

        func colorFromKey(_ key: UInt32?) -> Color {
            guard let key = key else { return Color(.systemBackground) }
            let r = Double((key >> 24) & 0xFF) / 255.0
            let g = Double((key >> 16) & 0xFF) / 255.0
            let b = Double((key >> 8) & 0xFF) / 255.0
            return Color(red: r, green: g, blue: b)
        }

        return [colorFromKey(dominant), colorFromKey(secondary)]
    }
}
