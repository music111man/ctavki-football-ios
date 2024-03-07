//
//  FeaureVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 04.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

class FeaureVController: UIViewController {
    
    let disposeBag = DisposeBag()
    let activityView = UIActivityIndicatorView()
    let navigationBar = NavigationTopBarView()
    let tableView = UITableView()
    let refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.color.background_main()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(callNeedRefresh), for: .valueChanged)
        tableView.addSubview(refresher)
        NotificationCenter.default.rx.notification(Notification.Name.badNetRequest).subscribe {[weak self] _ in
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.deserializeError).subscribe {[weak self] _ in
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if view.subviews.last != activityView {
            view.bringSubviewToFront(activityView)
        }
    }
   
    func initUI() {
        navigationBar.initUI(parent: view, title: titleName(), icon: icon(), nil)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityView.startAnimating()
    }
    
    func titleName() -> String {
        fatalError("-> Not implemented titleName()!!!")
    }
    
    func icon() -> UIImage? {
        nil
    }
    
    @objc
    private func callNeedRefresh() {
        if !refreshData() {
            refresher.endRefreshing()
        }
    }
    
    func refreshData() -> Bool {
        fatalError("-> Not implemented refreshData()!!!")
    }
}
