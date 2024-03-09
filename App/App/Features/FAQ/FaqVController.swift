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
    let containerView = UIStackView()
    let faqService = FaqService()
    let disposeBage = DisposeBag()
    let refresher = UIRefreshControl()
    var isFirstShow = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        faqService.faqs.observe(on: MainScheduler.instance).bind {[weak self] models in
            self?.containerView.replaceArrangedSubviews({
                models.map { model in
                    let view: FaqView = FaqView.fromNib()
                    view.model = model
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
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        containerView.axis = .vertical
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
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
    }
    
    @objc func callNeedRefresh() {
        faqService.loadData()
    }
}
