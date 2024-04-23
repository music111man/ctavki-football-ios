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
    var teamsModels = [TeamsViewModel]()

    @discardableResult
    func initTeamsFeatures() -> UIViewController {
        activityView.startAnimating()
        NotificationCenter.default.rx.notification(Notification.Name.needUpdateApp).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
            self?.refresher.endRefreshing()
            self?.activityView.stopAnimating()
        }.disposed(by: disposeBag)
        SyncService.shared.refresh {[weak self] _ in
            guard let self = self else { return }
            self.updateTeams()
            NotificationCenter.default.rx.notification(Notification.Name.needUpdateBetsScreen).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
                self?.activityView.startAnimating()
                self?.updateTeams()
            }.disposed(by: self.disposeBag)
        }
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher.rx.controlEvent(UIControl.Event.valueChanged).bind {
            SyncService.shared.refresh {[weak self] _ in
                self?.updateTeams()
            }
        }.disposed(by: disposeBag)
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
    
    private func updateTeams() {
        teamsService.load().filter {[weak self] models in
            guard let self else { return false }
            if self.teamsModels.count != models.count { return true }
            for i in 0..<models.count {
                if models[i] != self.teamsModels[i] { return true }
            }
            DispatchQueue.main.async {[weak self] in
                self?.activityView.stopAnimating()
                self?.refresher.endRefreshing()
            }
            return false
        }.observe(on: MainScheduler.instance).subscribe {[weak self] models in
            guard let self = self else {
                self?.activityView.stopAnimating()
                self?.refresher.endRefreshing()
                return
            }
            self.teamsModels = models
            self.stackView.replaceArrangedSubviews({
                let views = models.map { model in
                    let view = TeamsView().configure(title: model.title, teams: model.teams)
                    view.delegate = self
                    
                    return view
                }
                return views
            }) {[weak self] in
                    self?.activityView.stopAnimating()
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
