//
//  FaqVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class FaqVController: UIViewController {
    
    let activityView = UIActivityIndicatorView()
    let navigationBar = NavigationTopBarView()
    let stackView = UIStackView()
    let faqService = FaqService()
    let disposeBage = DisposeBag()
    let refresher = UIRefreshControl()
    let imageView = UIImageView()
    var isFirstShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        faqService.faqs.observe(on: MainScheduler.instance).bind {[weak self] models in
            self?.stackView.replaceArrangedSubviews({
                models.map { model in
                    let view: FaqView = FaqView.fromNib()
                    view.model = model
                    view.delegate = self
                    return view
                }
            }) {[weak self] in
                self?.activityView.animateOpacity(0.3, 0.2) {[weak self] in
                    self?.activityView.isHidden = true
                    self?.refresher.endRefreshing()
                }
            }
        }.disposed(by: disposeBage)
        
        faqService.isLoading.observe(on: MainScheduler.instance).bind { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading && !self.refresher.isRefreshing {
                self.activityView.isHidden = false
                self.activityView.animateOpacity(0.3, 1)
            }
        }.disposed(by: disposeBage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstShow {
            isFirstShow.toggle()
            faqService.loadData()
        }
        
    }
    
    func initUI() {
        navigationBar.initUI(parent: view, title: R.string.localizable.screen_faq_title(), icon: R.image.faq())
        navigationBar.hideAuthBtn()
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: stackView.spacing),
            stackView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: stackView.spacing),
            stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -stackView.spacing),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -stackView.spacing)
        ])
        activityView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            activityView.style = .large
        } else {
            activityView.style = .whiteLarge
        }
        activityView.color = R.color.shadow()
        view.addSubview(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityView.startAnimating()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(callNeedRefresh), for: .valueChanged)
        scrollView.addSubview(refresher)
        
        imageView.image = R.image.up_small_arrow()?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .title
        imageView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -10),
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -stackView.spacing * 2)
        ])
        imageView.tap(animateTapGesture: false) { [weak self] in
            self?.stackView.arrangedSubviews.forEach { view in
                (view as? FaqView)?.collapse()
            }
            UIView.animate(withDuration: 0.4, animations: {[weak self] in
                self?.imageView.transform = .identity
            }) {[weak self] _ in
                self?.imageView.animateOpacity(0.3, 0) { [weak self] in
                    self?.imageView.isHidden = true
                }
            }
        }.disposed(by: disposeBage)
        imageView.layer.opacity = 0
    }

    @objc func callNeedRefresh() {
        faqService.loadData()
    }
}

extension FaqVController: FaqViewDeelegate {
    func changeVisibality() {
        let allCollapsed = stackView.arrangedSubviews.filter({ !($0 as! FaqView).isCollapsed}).isEmpty
        if allCollapsed, imageView.isHidden { return }
        if !allCollapsed {
            imageView.isHidden = false
            imageView.animateOpacity(0.2, 1) {
                UIView.animate(withDuration: 0.4) {[weak self] in
                    self?.imageView.transform = .init(rotationAngle: FaqView.rotateAngel)
                }
            }
        } else {
            UIView.animate(withDuration: 0.4, animations: {[weak self] in
                self?.imageView.transform = .init(rotationAngle: FaqView.rotateAngel)
            }) {[weak self] _ in
                self?.imageView.animateOpacity(0.2, 0)
            }
        }
    }
}
