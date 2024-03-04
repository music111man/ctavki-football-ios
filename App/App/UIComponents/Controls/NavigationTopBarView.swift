//
//  NavigationTopBarView.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Notification.Name {
    static let tapAutozire = Notification.Name("tapAutozire")
}

final class NavigationTopBarView: UIView {
    
    private let titleLabel = UILabel()
    private let tapAuthAnimate = UIView()
    private let tapBackAnimate = UIView()
    private let disposeBag = DisposeBag()
    
    var title: String {
        set {
            titleLabel.text = newValue
        }
        get {
            titleLabel.text ?? ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first?.frame = bounds
        tapAuthAnimate.roundCorners()
        tapBackAnimate.roundCorners()
    }
    
    func initUI(parent: UIView, title: String, icon: UIImage?,_ callback: (() -> ())?) {
        translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor),
            leftAnchor.constraint(equalTo: parent.leftAnchor),
            rightAnchor.constraint(equalTo: parent.rightAnchor),
            heightAnchor.constraint(equalToConstant: UIView.safeAreaHeight + 90)
        ])
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.textColor = R.color.title_color()
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
        ])
        
        let iconView = UIImageView(image: icon?.withRenderingMode(.alwaysTemplate) ?? R.image.left_arrow()?.withRenderingMode(.alwaysTemplate))
        iconView.contentMode = .scaleToFill
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        
        let tapBackView = UIView()
        tapBackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapBackView)
        tapBackView.addSubview(iconView)
        let iconHeightAnchor: CGFloat = icon == nil ? 30.0 : 40.0
        let iconWidthAnchor: CGFloat = icon == nil ? 20.0 : 40.0
        NSLayoutConstraint.activate([
            tapBackView.leftAnchor.constraint(equalTo: leftAnchor),
            tapBackView.topAnchor.constraint(equalTo: topAnchor),
            tapBackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tapBackView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: iconHeightAnchor),
            iconView.widthAnchor.constraint(equalToConstant: iconWidthAnchor),
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconView.leftAnchor.constraint(equalTo: tapBackView.leftAnchor, constant: 15)
        ])
        if let callback = callback {
            tapBackAnimate.translatesAutoresizingMaskIntoConstraints = false
            tapBackAnimate.backgroundColor = R.color.title_color()
            tapBackAnimate.layer.opacity = 0
            tapBackView.insertSubview(tapBackAnimate, at: 0)
            NSLayoutConstraint.activate([
                tapBackAnimate.widthAnchor.constraint(equalToConstant: 100),
                tapBackAnimate.heightAnchor.constraint(equalToConstant: 100),
                tapBackAnimate.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                tapBackAnimate.centerXAnchor.constraint(equalTo: iconView.centerXAnchor)
            ])
            let tapGesture = UITapGestureRecognizer()
            tapGesture.rx.event.bind {[weak self] _ in
                self?.tapBackAnimate.layer.opacity = 1
                self?.tapBackAnimate.transform = CGAffineTransform.init(scaleX: 0, y: 0)
                UIView.animate(withDuration: 0.3) {
                    self?.tapBackAnimate.transform = CGAffineTransform.identity
                    self?.tapBackAnimate.layer.opacity = 0
                } completion: { _ in
                    callback()
                }
                
            }.disposed(by: disposeBag)
            tapBackView.addGestureRecognizer(tapGesture)
        }
        
        let rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        rightLabel.textColor = R.color.title_color()
        rightLabel.textAlignment = .right
        rightLabel.numberOfLines = 2
        let tapAutorizeView = UIView()
        tapAutorizeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapAutorizeView)
        tapAuthAnimate.backgroundColor = R.color.title_color()
        tapAuthAnimate.translatesAutoresizingMaskIntoConstraints = false
        tapAutorizeView.addSubview(tapAuthAnimate)
        tapAutorizeView.addSubview(rightLabel)
        
        
        NSLayoutConstraint.activate([
            tapAutorizeView.heightAnchor.constraint(equalToConstant: 80),
            tapAutorizeView.widthAnchor.constraint(equalToConstant: 40),
            tapAutorizeView.rightAnchor.constraint(equalTo: rightAnchor),
            tapAutorizeView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            tapAuthAnimate.centerXAnchor.constraint(equalTo: tapAutorizeView.centerXAnchor),
            tapAuthAnimate.centerYAnchor.constraint(equalTo: tapAutorizeView.centerYAnchor),
            tapAuthAnimate.heightAnchor.constraint(equalToConstant: 100),
            tapAuthAnimate.widthAnchor.constraint(equalToConstant: 100),
            rightLabel.rightAnchor.constraint(equalTo: tapAutorizeView.rightAnchor, constant: -10),
            rightLabel.centerYAnchor.constraint(equalTo: tapAutorizeView.centerYAnchor)
        ])
        tapAuthAnimate.roundCorners()
        let tapGestore = UITapGestureRecognizer()
        tapAuthAnimate.layer.opacity = 0
        tapGestore.rx.event.bind {[weak self] _ in
            self?.tapAuthAnimate.layer.opacity = 1
            self?.tapAuthAnimate.transform = CGAffineTransform.init(scaleX: 0, y: 0)
            UIView.animate(withDuration: 0.3) {
                self?.tapAuthAnimate.transform = CGAffineTransform.identity
                self?.tapAuthAnimate.layer.opacity = 0
            } completion: { _ in
                NotificationCenter.default.post(name: Notification.Name.tapAutozire, object: nil)
            }
        }.disposed(by: disposeBag)
        tapAutorizeView.addGestureRecognizer(tapGestore)
        
        AppSettings.isAutorized.bind { isAutorize in
            rightLabel.text = isAutorize ? R.string.localizable.my_balance() : R.string.localizable.sign_in()
        }.disposed(by: disposeBag)
        
        setGradient(start: R.color.green_blue_start()!, end: R.color.green_blue_end()!, isLine: true)
        layoutIfNeeded()
    }
}
