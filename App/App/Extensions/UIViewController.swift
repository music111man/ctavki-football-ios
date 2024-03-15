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
    
    func showAlert(title: String, message: String? = nil, complite: (() -> ())? = nil) {
        if Thread.isMainThread {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {_ in 
                complite?()
            })
            present(alert, animated: true)
        } else {
            DispatchQueue.main.async { [weak self] in
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {_ in
                    complite?()
                })
                self?.present(alert, animated: true)
            }
        }
    }
}
