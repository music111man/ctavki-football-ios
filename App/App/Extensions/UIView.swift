//
//  CALayer.swift
//  App
//
//  Created by Denis Shkultetskyy on 23.02.2024.
//

import UIKit

extension UIView {
    func roundCorners(radius: CGFloat? = nil) {
        layer.cornerRadius = radius ?? frame.width / 2
    }
}

