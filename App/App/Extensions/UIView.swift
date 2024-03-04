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
    
    func setGradient(start: UIColor, end: UIColor, isLine: Bool) {
        let gradient = CAGradientLayer()
        gradient.colors = [start.cgColor, end.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = isLine ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: 1.0, y: 1.0)
        layer.insertSublayer(gradient, at: 0)
        gradient.frame = bounds
        clipsToBounds = true
    }
    
    func setshadow(size: CGSize? = nil) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = size ?? CGSize(width: 0, height: 2)
        layer.shadowRadius = 0.5
    }
    
    static var safeAreaHeight: CGFloat {
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        return window.frame.maxY - safeFrame.maxY
    }
}

