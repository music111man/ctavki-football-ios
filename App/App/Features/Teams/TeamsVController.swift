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
    var needAnimationOnWillAppend = false
    let stackView = UIStackView()

    func initTeamsFeatures() -> UIViewController {
        activityView.isHidden = false
        SyncService.shared.refresh {[weak self] _ in
            guard let self = self else { return }
            self.updateTeams()
            NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
                self?.activityView.isHidden = false
                self?.updateTeams()
            }.disposed(by: self.disposeBag)
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initTableView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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

    override func titleName() -> String {
        R.string.localizable.screen_teams_title()
    }
    
    override func icon() -> UIImage? {
        R.image.teams()
    }
    
    override func refreshData() -> Bool {

        SyncService.shared.refresh {[weak self] hasNew in
            
            if hasNew {
                self?.updateTeams()
            } else {
                self?.refresher.endRefreshing()
            }
        }

        return true
    }
    
    private func updateTeams() {
        teamsService.load().observe(on: MainScheduler.instance).subscribe {[weak self] models in
            guard let self = self else {
                self?.activityView.isHidden = true
                self?.refresher.endRefreshing()
                return
            }
            
            self.stackView.replaceWithHideAnimation({
                let views = models.map { model in
                    let view = TeamsView().configure(title: model.title, teams: model.teams)
                    view.delegate = self
                    
                    return view
                }
                return views
            }) {[weak self] in
                    self?.activityView.isHidden = true
                    self?.refresher.endRefreshing()
            }
        }.disposed(by: disposeBag)
    }
}

extension TeamsVController: BetViewDelegate {
    func openTeamDetails(teamId: Int, onLeft: Bool) {
        NotificationCenter.default.post(name: Notification.Name.needOpenHistory, object: self, userInfo: [BetView.teamIdKeyUserInfo: teamId])

    }
}
