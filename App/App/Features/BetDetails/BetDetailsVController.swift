//
//  BetDetailsVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 07.03.2024.
//

import UIKit
import SQLite
import RxSwift
import RxCocoa

class BetDetailsVController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var resultValLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var factorResultLabel: UILabel!
    @IBOutlet weak var factorLabel: UILabel!
    @IBOutlet weak var betSumLabel: UILabel!
    @IBOutlet weak var betTypeDetailsLabel: UILabel!
    @IBOutlet weak var betTypeLabel: UILabel!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var teamsLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    private var betId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.setStyle()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.layer.opacity = 0
        closeView.roundCorners()
        containerView.roundCorners(radius: 10)
        castLabel.text = R.string.localizable.prediction()
        betSumLabel.text = R.string.localizable.bet_amount_100()
        factorLabel.text = R.string.localizable.odds_col()
        resultLabel.text = R.string.localizable.result()
        closeView.tap(animateTapGesture: false) {[weak self] in

            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.view.layer.opacity = 0
            } completion: {[weak self] _ in
                self?.dismiss(animated: false)
            }
        }.disposed(by: disposeBag)
        containerView.tap(animateTapGesture: false) {}.disposed(by: disposeBag)
        view.tap(animateTapGesture: false) {
           UIView.animate(withDuration: 0.3) {[weak self] in
               self?.view.layer.opacity = 0
           } completion: {[weak self] _ in
               self?.dismiss(animated: false)
           }
        }.disposed(by: disposeBag)
        loadInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.layer.opacity = 1
        }
    }
    
    func configure(betId: Int) {
        self.betId = betId
    }
    
    func loadInfo() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let bet: Bet = Repository.selectTop(Bet.table.where(Bet.idField == self.betId)),
                  let typeId = bet.typeId,
                  let factor = bet.factor,
                  let betType: BetType = Repository.selectTop(BetType.table.where(BetType.idField == typeId)) else {
                self?.showOkAlert(title: R.string.localizable.error()) {[weak self] in
                    self?.dismiss(animated: true)
                }
                return
            }
            let outcome = bet.outcome ?? .unknow
            let teams: [Team] = Repository.select(Team.table.where([bet.team1Id, bet.team2Id].contains(Team.idField)))
            guard teams.count == 2,
                    let team1 = teams.first(where: { $0.id == bet.team1Id }),
                    let team2 = teams.first(where: { $0.id == bet.team2Id }) else { return }
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.eventDateLabel.text = R.string.localizable.year_at_end(bet.eventDate.format("d MMMM yyyy"))
                self.teamsLabel.text = "\(team1.title) - \(team2.title)"
                self.factorResultLabel.text = factor.formattedString
                let description = betType.description.regReplace(pattern: "(?i)\\хозяев\\w*", replaceWith: team1.title)
                                                    .regReplace(pattern: "(?i)\\гост\\w*", replaceWith: team2.title)
                                                    .regReplace(pattern: "(?i)home\\s+team", replaceWith: team1.title)
                                                    .regReplace(pattern: "(?i)away\\s+team", replaceWith: team2.title)
                if var typeArg = bet.typeArg {
                    if [34, 38].contains(betType.id) {
                        typeArg += 0.5
                    } else {
                        typeArg -= 0.5
                    }
                    self.betTypeLabel.text =  betType.shortTitle.replace("%x%", with: "\(typeArg)")
                    self.betTypeDetailsLabel.text = description.replace("%x%", with: "\(typeArg)")
                } else {
                    self.betTypeLabel.text = betType.shortTitle
                    self.betTypeDetailsLabel.text = description
                }
                switch outcome {
                case .active:
                    break
                case .won:
                    self.resultValLabel.text = R.string.localizable.winnings(Int(factor.winCalcValue))
                    self.resultValLabel.textColor = R.color.won()
                case .lost:
                    self.resultValLabel.text = R.string.localizable.loss()
                    self.resultValLabel.textColor = R.color.lost()
                case .return:
                    self.resultValLabel.text = R.string.localizable.return()
                    self.resultValLabel.textColor = R.color.text_black()
                case .unknow:
                    self.resultValLabel.text = R.string.localizable.expecting()
                    self.resultValLabel.textColor = R.color.text_black()
                }
                self.activityView.animateOpacity(0.4, 0) {[weak self] in
                    self?.activityView.isHidden = true
                }
            }
                                                      
        }
        
    }
}
