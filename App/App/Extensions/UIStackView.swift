//
//  UIStackView.swift
//  App
//
//  Created by Denis Shkultetskyy on 09.03.2024.
//

import UIKit

extension UIStackView {

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
