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
    var tableView: UITableView!
    let refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.rx.notification(Notification.Name.badNetRequest).subscribe {[weak self] _ in
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.deserializeError).subscribe {[weak self] _ in
            self?.refresher.endRefreshing()
        }.disposed(by: disposeBag)
        initUI()
        activityView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if view.subviews.last != activityView {
            view.bringSubviewToFront(activityView)
        }
    }
   
    func initUI() {
        activityView.setStyle()
        
        view.backgroundColor = .backgroundMainLight
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(callNeedRefresh), for: .valueChanged)
        
        navigationBar.initUI(parent: view, title: titleName(), icon: icon())
        activityView.translatesAutoresizingMaskIntoConstraints = false
        activityView.color = R.color.shadow()
        view.addSubview(activityView)
        NSLayoutConstraint.activate([
            activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        initTableView()
    }
    
    func initTableView() {
        tableView = UITableView()
        tableView.addSubview(refresher)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
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
