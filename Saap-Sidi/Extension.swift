//
//  Extension.swift
//  Saap-Sidi
//
//  Created by home on 24/03/22.
//

import SwiftUI

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

infix operator ± : AdditionPrecedence
extension CGRect {
    static func ±(lhs: CGRect, rhs: CGRect) -> (CGPoint, CGPoint) {
        (lhs.origin+rhs.origin, lhs.origin-rhs.origin)
    }
}
