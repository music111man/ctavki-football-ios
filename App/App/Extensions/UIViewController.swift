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
    
    func showOkAlert(title: String, message: String? = nil, delay: TimeInterval = 0, okText: String = "OK",
                   _ okAction: (() -> ())? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default) {_ in
                okAction?()
            })
            self?.present(alert, animated: true)
        }

    }
    
    func showOkCancelAlert(title: String, message: String? = nil, delay: TimeInterval = 0, okText: String = "OK", cancelText: String? = nil,
                   _ okAction: @escaping(() -> ()),
                   _ cancelAction: (() -> ())? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: okText, style: UIAlertAction.Style.default) {_ in
                okAction()
            })
            alert.addAction(UIAlertAction(title: cancelText ?? R.string.localizable.cancel_Ok(), style: UIAlertAction.Style.cancel) {_ in
                cancelAction?()
            })
            self?.present(alert, animated: true)
        }

    }
}
