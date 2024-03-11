//
//  UIViewController.swift
//  App
//
//  Created by Denis Shkultetskyy on 07.03.2024.
//

import UIKit

extension UIViewController {
    static func createFromNib<T: UIViewController>(_ configure: ((_ vc: T) -> ())? = nil) -> T {
        let identificator = String(describing: Self.self)
        let vc = UIStoryboard(name: identificator,
                            bundle: nil)
        .instantiateViewController(withIdentifier: identificator) as! T
        configure?(vc)
        
        return vc
    }
}
