//
//  UIStackView.swift
//  App
//
//  Created by Denis Shkultetskyy on 09.03.2024.
//

import UIKit

extension UIStackView {
    
    func replaceArrangedSubviews(_ getViews:@escaping (() -> [UIView]), _ endAction: (() -> ())? = nil) {
        animateOpacity(0.3, 0) {[weak self] in
            guard let self = self else { return }
            while let v = self.arrangedSubviews.first {
                self.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
            getViews().forEach { self.addArrangedSubview($0)}
            self.animateOpacity(0.3, 1) {
                endAction?()
            }
        }
    }
}
