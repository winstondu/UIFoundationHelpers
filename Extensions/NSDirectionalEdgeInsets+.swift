//
//  UIEdgeInsets.swift
//  Winston
//
//

import Foundation
import UIKit

public extension NSDirectionalEdgeInsets {
    init(topBottom: CGFloat, leadingTrailing: CGFloat) {
        self.init(top: topBottom, leading: leadingTrailing, bottom: topBottom, trailing: leadingTrailing)
    }

    init(all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }
}
