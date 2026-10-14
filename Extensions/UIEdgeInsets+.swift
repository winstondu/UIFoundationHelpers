//
//  UIEdgeInsets.swift
//  Winston
//
//

import Foundation
import UIKit

public extension UIEdgeInsets {
    init(topBottom: CGFloat, leftRight: CGFloat) {
        self.init(top: topBottom, left: leftRight, bottom: topBottom, right: leftRight)
    }

    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
}
