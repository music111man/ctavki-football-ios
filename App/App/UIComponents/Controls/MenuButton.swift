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
    init(title: String, icon: UIImage?,_ isSelected: Bool, _ action: @escaping Action) {
        self.isSelected = isSelected
        self.action = action
        imageView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .black
        super.init(frame: CGRect())
        imageView.contentMode = .scaleToFill
        label.text = title
        label.textAlignment = .center
        label.textColor = isSelected ? R.color.selected_toolbar_item() : R.color.toolbarItem()
        label.font = isSelected ? UIFont.boldSystemFont(ofSize: 12.0) : UIFont.systemFont(ofSize: 12.0)
        imageView.tintColor = isSelected ? R.color.selected_toolbar_item() : R.color.toolbarItem()
        addSubview(animationView)
        addSubview(imageView)
        addSubview(label)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        animationView.isHidden = true
        animationView.backgroundColor = R.color.selected_toolbar_item()
        animationView.layer.cornerRadius = 60
        initConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var isSelected: Bool {
        didSet {
            
            if isSelected {
                animationView.isHidden = false
                animationView.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)
                animationView.layer.opacity = 1
                UIView.animate(withDuration: 0.2, animations: {
                        self.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
                        self.animationView.transform = .identity
                    self.animationView.layer.opacity = 0.5
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.1, animations: {
                                self.transform = CGAffineTransform.identity
                                self.animationView.layer.opacity = 0
                                self.label.textColor =  R.color.selected_toolbar_item()
                                self.label.font = UIFont.boldSystemFont(ofSize: 12.0)
                                self.imageView.tintColor =  R.color.selected_toolbar_item()
                            }, completion: { _ in
                                self.animationView.isHidden = true
                            })
                    })
            } else {
                label.textColor = R.color.toolbarItem()
                label.font = UIFont.systemFont(ofSize: 12.0)
                imageView.tintColor = R.color.toolbarItem()
            }
        }
    }
    
    private func initConstrains() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 30.0),
            imageView.widthAnchor.constraint(equalToConstant: 30.0),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 120),
            animationView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
                             
    @objc
    private func tap() {
        if isSelected { return }
        action()
    }
}
