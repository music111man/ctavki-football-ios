//
//  BetView.swift
//  App
//
//  Created by Denis Shkultetskyy on 05.03.2024.
//

import UIKit

class BetView: UIView {

    let homeTeamNameLabel = UILabel()
    let goustTeamNameLabel = UILabel()
    let resultLabel = UILabel()
    let resultView = UIView()
    let teamsView = UIView()
    var gradients = [BetOutcome: CALayer]()
    
    static let cellHeigth: CGFloat = 70.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        teamsView.subviews.forEach { $0.roundCorners(radius: 10) }
        resultView.roundCorners()
        gradients.forEach { $0.value.frame = resultView.bounds }
    }
    
    func configure(_ model: BetViewModel) {
        homeTeamNameLabel.text = model.homeTeam?.title
        goustTeamNameLabel.text = model.goustTeam?.title
        resultLabel.text = model.resultText
        gradients.forEach {$0.value.opacity = 0}
        resultLabel.layer.opacity = 1
        let outcom = model.betOutCome ?? .active
        gradients[outcom]?.opacity = 1
    }
    
    func initUI() {
        translatesAutoresizingMaskIntoConstraints = false
        teamsView.translatesAutoresizingMaskIntoConstraints = false
        resultView.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(teamsView)
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
            teamsView.heightAnchor.constraint(equalToConstant: 60),
            teamsView.centerYAnchor.constraint(equalTo: centerYAnchor)
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
            resultView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            resultView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            resultView.heightAnchor.constraint(equalToConstant: 50),
            resultView.widthAnchor.constraint(equalToConstant: 50)
        ])
        
    }

    private func teamView(label: UILabel) -> UIView {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = R.color.text()
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
