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
        
//        if arrangedSubviews.isEmpty {
//            replaceWithTrAnimation(getViews, endAction)
//        } else {
//            var k = true
//            UIView.animate(withDuration: 0.3, animations: { [weak self] in
//                self?.arrangedSubviews.forEach { v in
//                    k.toggle()
//                    v.transform = .init(translationX: UIScreen.main.bounds.width * (k ? 1 : -1), y: 0)
//                }
//            }) { [weak self] _ in
//                self?.replaceWithTrAnimation(getViews, endAction)
//            }
//        }
        replaceWithTrAnimation(getViews, endAction)
    }
    
    private func  replaceWithTrAnimation(_ getViews:@escaping (() -> [UIView]), _ endAction: (() -> ())? = nil) {
        while let v = arrangedSubviews.first {
            removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        addArrangedSubview(UILabel())
        getViews().forEach { v in
            addArrangedSubview(v)
//            let translationX = (arrangedSubviews.count % 2 > 0 ? 1 : -1) * UIScreen.main.bounds.width
//            v.transform = .init(translationX: translationX, y: 0)
        }
//        UIView.animate(withDuration: 0.3) {[weak self] in
//            self?.arrangedSubviews.forEach { $0.transform = .identity }
//        } completion: { _ in
//            endAction?()
//        }
        endAction?()
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
