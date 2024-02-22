//
//  MenuButton.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit
import Rswift

final class MenuButton: UIView {
    typealias Action = () -> ()
    
    let action: Action
    let label = UILabel()
    let animationView = UIView()
    let imageView: UIImageView!
    init(title: String, icon: UIImage?, _ action: @escaping Action) {
        self.action = action
        imageView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .black
        super.init(frame: CGRect())
        imageView.contentMode = .scaleToFill
        label.text = title
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(label)
        addSubview(animationView)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        self.isSelected = false
//        animationView.isHidden = true
        animationView.backgroundColor = .lightGray
        animationView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var isSelected: Bool! {
        didSet {
            label.textColor = isSelected ? .blue : .black
            label.font = isSelected ? UIFont.boldSystemFont(ofSize: 12.0) : UIFont.systemFont(ofSize: 12.0)
            imageView.tintColor = isSelected ? .blue : .black
            if isSelected {
//                animationView.isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
                        self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
//                    self.animationView.transform = .identity
//                    self.animationView.layer.opacity = 0.1
                        }, completion: { (finish) in
//                            self.animationView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
//                            self.animationView.layer.opacity = 1
//                            self.animationView.isHidden = true
                            UIView.animate(withDuration: 0.1, animations: {
                                self.transform = CGAffineTransform.identity
                            })
                    })
            }
        }
    }
    
    func initUI() {
//        self.isSelected = isSelected
        imageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        animationView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
//        animationView.layer.cornerRadius = 29
        animationView.heightAnchor.constraint(equalToConstant: 58).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 58).isActive = true
    }
                             
    @objc
    private func tap() {
        action()
    }
}
