//
//  CGFloat+.swift
//  WinstonUICore
//
//

import Foundation
import UIKit

@MainActor
public extension CGFloat {

    static var hairline: CGFloat {
        1.0 / UIScreen.main.scale
    }

    static var doubleHairline: CGFloat {
        2 * hairline
    }
}
