//
//  UIView+extensions.swift
//  Granular
//
//  Created by tom on 2019-06-15.
//

import Foundation
import UIKit

public extension UIView {

    func constraints(fillingHorizontally: UIView) -> [NSLayoutConstraint] {
        return [
            leadingAnchor.constraint(equalTo: fillingHorizontally.leadingAnchor),
            trailingAnchor.constraint(equalTo: fillingHorizontally.trailingAnchor),
        ]
    }
    func constraints(fillingVertically: UIView) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: fillingVertically.topAnchor),
            bottomAnchor.constraint(equalTo: fillingVertically.bottomAnchor)
        ]
    }
    
    func constraints(filling: UIView) -> [NSLayoutConstraint] {
        return constraints(fillingVertically: filling) + constraints(fillingHorizontally: filling)
    }
    
    func constraints(safelyFilling filling: UIView) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: filling.safeAreaLayoutGuide.topAnchor),
            leadingAnchor.constraint(equalTo: filling.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: filling.safeAreaLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: filling.safeAreaLayoutGuide.bottomAnchor)
        ]
    }
    
    func constraints(insideWithSystemSpacing parent: UIView, multiplier: CGFloat) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalToSystemSpacingBelow: parent.topAnchor, multiplier: multiplier),
            leadingAnchor.constraint(equalToSystemSpacingAfter: parent.leadingAnchor, multiplier: multiplier),
            parent.trailingAnchor.constraint(equalToSystemSpacingAfter: trailingAnchor, multiplier: multiplier),
            parent.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomAnchor, multiplier: multiplier)
        ]
    }
}
