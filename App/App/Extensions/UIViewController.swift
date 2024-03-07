//
//  UIViewController.swift
//  App
//
//  Created by Denis Shkultetskyy on 07.03.2024.
//

import UIKit

extension UIViewController {
    static func createFromNib() -> UIViewController {
        let identificator = String(describing: Self.self)
        return UIStoryboard(name: identificator,
                            bundle: nil)
        .instantiateViewController(withIdentifier: identificator)
    }
}
