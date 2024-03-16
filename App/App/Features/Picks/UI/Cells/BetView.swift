//
//  BetView.swift
//  App
//
//  Created by Denis Shkultetskyy on 05.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

extension Notification.Name {
    static let needOpenBetDetails = Notification.Name("needOpenBetDetails")
    static let needOpenActiveBetDetails = Notification.Name("needOpenActiveBetDetails")
    static let needOpenHistory = Notification.Name("needOpenHistory")
    
}

protocol BetViewDelegate: AnyObject {
    func openTeamDetails(team: Team, onLeft: Bool)
}

class BetView: UIView {

    static let betIdKeyForUserInfo = "betId"
    static let teamKeyUserInfo = "team"
    static let tapLeftUserInfo = "tapLeft"
    
    let homeTeamNameLabel = UILabel()
    let goustTeamNameLabel = UILabel()
    let resultLabel = UILabel()
    let resultView = UIView()
    let teamsView = UIView()
    var gradients = [BetOutcome: CALayer]()
    let disposeBag = DisposeBag()
    var betId: Int!
    var homeTeam: Team!
    var goustTeam: Team!
    var betOutCome: BetOutcome!
    weak var delegate: BetViewDelegate?
    
    static let cellHeigth: CGFloat = 70.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        teamsView.subviews.forEach { $0.roundCorners(radius: 10) }
        resultView.roundCorners()
        gradients.forEach { $0.value.frame = resultView.bounds }
    }
    
    func configure(_ model: BetViewModel) {
        betId = model.id
        homeTeam = model.homeTeam
        goustTeam = model.goustTeam
        homeTeamNameLabel.text = model.homeTeam?.title
        goustTeamNameLabel.text = model.goustTeam?.title
        resultLabel.text = model.resultText
        gradients.forEach {$0.value.opacity = 0}
        resultLabel.layer.opacity = 1
        betOutCome = model.betOutCome ?? .active
        gradients[betOutCome]?.opacity = 1
    }
    
    func initUI() {
        translatesAutoresizingMaskIntoConstraints = false
        teamsView.translatesAutoresizingMaskIntoConstraints = false
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(teamsView)
        homeTeamNameLabel.isUserInteractionEnabled = true
        goustTeamNameLabel.isUserInteractionEnabled = true
        let homeView = teamView(label: homeTeamNameLabel)
        let goustView = teamView(label: goustTeamNameLabel)
        teamsView.addSubview(homeView)
        teamsView.addSubview(goustView)
        NSLayoutConstraint.activate([
            homeView.leftAnchor.constraint(equalTo: teamsView.leftAnchor, constant: 5),
            homeView.topAnchor.constraint(equalTo: teamsView.topAnchor, constant: 5),
            homeView.bottomAnchor.constraint(equalTo: teamsView.bottomAnchor, constant: -5),
            goustView.rightAnchor.constraint(equalTo: teamsView.rightAnchor, constant: -5),
            goustView.topAnchor.constraint(equalTo: teamsView.topAnchor, constant: 5),
            goustView.bottomAnchor.constraint(equalTo: teamsView.bottomAnchor, constant: -5),
            homeView.rightAnchor.constraint(equalTo: goustView.leftAnchor, constant: -30),
            homeView.widthAnchor.constraint(equalTo: goustView.widthAnchor, multiplier: 1.0)
        ])
        addSubview(teamsView)
        NSLayoutConstraint.activate([
            teamsView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            teamsView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            teamsView.heightAnchor.constraint(equalToConstant: 56)
        ])
        resultLabel.textAlignment = .center
        resultLabel.textColor = R.color.title_color()
        resultLabel.font = UIFont.systemFont(ofSize: 16)
        resultLabel.lineBreakMode = .byTruncatingTail
        resultLabel.numberOfLines = 2
        
        gradients[.active] = resultView.setGradient(start: R.color.viotet_start(), end: R.color.violet_end(), isLine: false)
        gradients[.won] = resultView.setGradient(start: R.color.won_light(), end: R.color.won(), isLine: false)
        gradients[.lost] = resultView.setGradient(start: R.color.red_start(), end: R.color.lost(), isLine: false)
        gradients[.return] = resultView.setGradient(start: R.color.blue_gray_400(), end: R.color.return(), isLine: false)
        gradients[.unknow] = resultView.setGradient(start: R.color.blue_gray_400(), end: R.color.return(), isLine: false)
        resultView.clipsToBounds = true
        resultView.addSubview(resultLabel)
        NSLayoutConstraint.activate([
            resultLabel.centerYAnchor.constraint(equalTo: resultView.centerYAnchor),
            resultLabel.leftAnchor.constraint(equalTo: resultView.leftAnchor, constant: 2),
            resultLabel.rightAnchor.constraint(equalTo: resultView.rightAnchor, constant: -2)
            
        ])
        addSubview(resultView)
        NSLayoutConstraint.activate([
            resultView.centerYAnchor.constraint(equalTo: centerYAnchor),
            resultView.centerXAnchor.constraint(equalTo: centerXAnchor),
            resultView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            resultView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            resultView.heightAnchor.constraint(equalToConstant: 58),
            resultView.widthAnchor.constraint(equalToConstant: 58),
            teamsView.centerYAnchor.constraint(equalTo: resultLabel.centerYAnchor)
        ])
        initTapGesture()
        
        
    }
    
    private func initTapGesture() {
        resultView.tap {[weak self] in
            guard let self = self, let betId = self.betId else { return }
            resultView.animateTapGesture(value: 0.8) {
                if self.betOutCome == .active || self.betOutCome == .unknow {
                    NotificationCenter.default.post(name: Notification.Name.needOpenActiveBetDetails, object: self, userInfo: [Self.betIdKeyForUserInfo: betId])
                } else {
                    NotificationCenter.default.post(name: Notification.Name.needOpenBetDetails,
                                                    object: self,
                                                    userInfo: [Self.betIdKeyForUserInfo: betId])
                }
            }
        }.disposed(by: disposeBag)
        
        homeTeamNameLabel.superview?.tap {[weak self] in
            guard let self = self else { return }
            
            if self.betOutCome == .active, let betId = self.betId {
                NotificationCenter.default.post(name: Notification.Name.needOpenActiveBetDetails, object: self, userInfo: [Self.betIdKeyForUserInfo: betId])
                return
            }
            
            self.delegate?.openTeamDetails(team: self.homeTeam, onLeft: true)
        }.disposed(by: disposeBag)
        
        goustTeamNameLabel.superview?.tap {[weak self] in
            guard let self = self else { return }
            
            if self.betOutCome == .active, let betId = self.betId {
                NotificationCenter.default.post(name: Notification.Name.needOpenActiveBetDetails, object: self, userInfo: [Self.betIdKeyForUserInfo: betId])
                return
            }
            self.delegate?.openTeamDetails(team: self.goustTeam, onLeft: false)
        }.disposed(by: disposeBag)
    }

    private func teamView(label: UILabel) -> UIView {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = R.color.text_black()
        label.font = UIFont.systemFont(ofSize: 16)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        let parentView = UIView()
        parentView.backgroundColor = R.color.background_light()
        parentView.translatesAutoresizingMaskIntoConstraints = false
        parentView.setshadow()
        parentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])
        
        return parentView
    }
}
