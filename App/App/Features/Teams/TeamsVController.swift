//
//  TeamsVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class TeamsVController: FeaureVController {
    
    var teamsService: TeamsService!
    var isUpdating = false
    var needAnimationOnWillAppend = false
    let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamsService = TeamsService {[weak self] refresh in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isUpdating = refresh
                if refresh {
                    if self.refresher.isRefreshing { return }
                    self.activityView.isHidden = false
//                    self.activityView.animateOpacity(0.2, 1)
                    
                    return
                }
//                self.refresher.endRefreshing()
//                self.activityView.animateOpacity(0.2, 0) {[weak self] in
//                    self?.activityView.isHidden = true
//                }
            }
        }
        
        teamsService.teams.observe(on: MainScheduler.instance).bind {[weak self] models in
            self?.stackView.replaceArrangedSubviews({
                models.map { model in
                    let view: TeamsView = .fromNib() { v in
                        v.configure(title: model.title, teams: model.teams)
                    }
                    view.delegate = self
                    return view
                }
            }) {[weak self] in
                self?.activityView.animateOpacity(0.3, 0.2) {[weak self] in
                    self?.activityView.isHidden = true
                    self?.refresher.endRefreshing()
                }
            }
        }.disposed(by: disposeBag)
        
//        teamsService.teams.bind(to: tableView.rx.items(cellIdentifier: TeamsViewCell.reuseIdentifier,
//                                                       cellType: TeamsViewCell.self)) { [weak self] _, item, cell in
//            cell.delegate = self
//            cell.configure(model: item)
//        }.disposed(by: disposeBag)
        
        teamsService.updateData()
    }
    override func initTableView() {
        //        tableView.register(UINib(resource: R.nib.teamsViewCell), forCellReuseIdentifier: TeamsViewCell.reuseIdentifier)
        //        view.addSubview(tableView)
        //        NSLayoutConstraint.activate([
        //            tableView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor),
        //            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        //            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        //            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        //        ])
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(stackView)
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: stackView.spacing),
//            stackView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: stackView.spacing),
//            stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -stackView.spacing),
//            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -stackView.spacing)
//        ])
        scrollView.addSubview(refresher)
    }
    override func initUI() {
        super.initUI()
        navigationBar.hideAuthBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needAnimationOnWillAppend {
            needAnimationOnWillAppend = false
            stackView.superview?.transform = .init(scaleX: 0.01, y: 0.01)
            stackView.superview?.layer.opacity = 0
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.stackView.superview?.transform = .identity
                self?.stackView.superview?.layer.opacity = 1
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func titleName() -> String {
        R.string.localizable.screen_teams_title()
    }
    
    override func icon() -> UIImage? {
        R.image.teams()
    }
    
    override func refreshData() -> Bool {
        
        if isUpdating { return false }
        
        teamsService.updateData()
        
        return true
    }
}

extension TeamsVController: BetViewDelegate {
    func openTeamDetails(team: Team, onLeft: Bool) {
//        let vc: HistoryVController = .createFromNib { vc in
//            vc.configure(team: team)
//        }
//        UIView.transition(with: view,
//                          duration: 0.4,
//                          options: [onLeft ? .transitionFlipFromRight : .transitionFlipFromLeft],
//                          animations: { [weak self] in
//            self?.view.layer.opacity = 0
//        }) {[weak self] _ in
//            self?.view.layer.opacity = 1
//            self?.navigationController?.pushViewController(vc, animated: false)
//        }
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.tableView.transform = .init(scaleX: 0.01, y: 0.01)
//        } completion: { [weak self] _ in
//            self?.navigationController?.pushViewController(vc, animated: true)
//        }
        needAnimationOnWillAppend = true
        NotificationCenter.default.post(name: Notification.Name.needOpenHistory, object: self, userInfo: [BetView.teamKeyUserInfo: team])

    }
}
