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
    
    @discardableResult
    func setGradient(start: UIColor?, end: UIColor?, isLine: Bool, index: UInt32? = nil) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [(start ?? .clear).cgColor, (end ?? .clear).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = isLine ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: 1.0, y: 1.0)
        if let index = index {
            layer.insertSublayer(gradient, at: index)
        } else {
            layer.addSublayer(gradient)
        }
        gradient.frame = bounds
        return gradient
    }
    
    @discardableResult
    func setGradient(colors: [UIColor?], isLine: Bool) -> CALayer{
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { ($0 ?? .clear).cgColor }
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = isLine ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(gradient)
        gradient.frame = bounds
        return gradient
    }
    
    func setshadow(size: CGSize? = nil) {
        layer.shadowColor = R.color.shadow()!.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = size ?? CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
    }
    
    static var safeAreaHeight: CGFloat {
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        return window.frame.maxY - safeFrame.maxY
    }
    
    func animateOpacity(_ withDuration: TimeInterval, _ value: Float, _ onComplite: (() -> ())? = nil) {
        UIView.animate(withDuration: withDuration) {[weak self] in
            self?.layer.opacity = value
        } completion: { _ in
            onComplite?()
        }

    }
    func animateTpSimulation(withDuration: TimeInterval = 0.2, value: CGFloat, _ onComplite: (() -> ())? = nil) {
        UIView.animate(withDuration: withDuration, animations: {[weak self] in
            self?.transform = CGAffineTransform.init(scaleX: value, y: value)
        }) { [weak self] _ in
            
            onComplite?()
            UIView.animate(withDuration: withDuration, animations: {[weak self] in
                self?.transform = CGAffineTransform.identity
            }) { _ in

            }
        }
    }
    

    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

