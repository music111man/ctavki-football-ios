//
//  UIStackView.swift
//  App
//
//  Created by Denis Shkultetskyy on 09.03.2024.
//

import UIKit

extension UIStackView {
    
    func replaceWithHideAnimation(_ getViews:@escaping (() -> [UIView]), _ endAction: (() -> ())? = nil) {
//        animateOpacity(0.3, 0) {[weak self] in
//            guard let self = self else { return }
        var k = -1.0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.transform = .init(scaleX: 0, y: 0)
        }) { [weak self] _ in
            while let v = self?.arrangedSubviews.first {
                self?.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
            self?.addArrangedSubview(UILabel())
            getViews().forEach { v in
                self?.addArrangedSubview(v)
            }
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.transform = .identity
            } completion: { _ in
                endAction?()
            }

        }
//            while let v = self.arrangedSubviews.first {
//                UIView.animate(withDuration: 0.4) { [weak self] in
//                    v.layer.opacity = 0
//                } completion: {[weak self] _ in
//                    self?.removeArrangedSubview(v)
//                    v.removeFromSuperview()
//                }
//                
//            }
//            addArrangedSubview(UILabel())
//        getViews().forEach { v in
//            self.addArrangedSubview(v)
//            v.layer.opacity = 1
//            UIView.animate(withDuration: 0.4) {
//                v.layer.opacity = 1
//            }
//        }
//        endAction?()
//            self.animateOpacity(0.3, 1) {
//                endAction?()
//            }
//        }
    }
    func replaceArrangedSubviews(_ getViews:@escaping (() -> [UIView]), _ endAction: (() -> ())? = nil) {
       
        while let v = self.arrangedSubviews.first {
            self.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        addArrangedSubview(UILabel())
        getViews().forEach { self.addArrangedSubview($0)}
        endAction?()
    }
}
