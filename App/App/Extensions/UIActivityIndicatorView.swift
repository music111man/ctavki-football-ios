//
//  UIActivityIndicatorView.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 18.03.2024.
//

import UIKit

extension UIActivityIndicatorView {
    func setStyle() {
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
    }
}
