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
    
    var teamsService = TeamsService()
    var isUpdating = false
    var needAnimationOnWillAppend = false
    let stackView = UIStackView()
    
    func initTeamsFeatures() -> UIViewController {
        teamsService = TeamsService()
        teamsService.refreshActivity.observe(on: MainScheduler.instance).bind {[weak self] in
            guard let self = self else { return }
            
            self.isUpdating = true
            self.activityView.isHidden = false
        }.disposed(by: disposeBag)
        
        teamsService.teams.observe(on: MainScheduler.instance).bind {[weak self] models in
            self?.stackView.replaceWithHideAnimation({
                printAppEvent("start create views")
                let views = models.map { model in
                    let view: TeamsView = .fromNib() { v in
                        v.configure(title: model.title, teams: model.teams)
                    }
                    view.delegate = self
                    
                    return view
                }
                printAppEvent("and create views")
                return views
            }) {[weak self] in
                    self?.activityView.isHidden = true
                    self?.isUpdating = false
                    self?.refresher.endRefreshing()
            }
        }.disposed(by: disposeBag)
        teamsService.updateData()
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.isHidden = true
    }
    override func initTableView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
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
        scrollView.addSubview(refresher)
    }
    override func initUI() {
        super.initUI()
        navigationBar.hideAuthBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        NotificationCenter.default.post(name: Notification.Name.needOpenHistory, object: self, userInfo: [BetView.teamIdKeyUserInfo: teamId])

    }
}
