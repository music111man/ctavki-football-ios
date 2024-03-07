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
    
    var betId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            activityView.style = .large
        } else {
            activityView.style = .whiteLarge
        }
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.layer.opacity = 0
        containerView.isUserInteractionEnabled = false
        closeView.isUserInteractionEnabled = true
        closeView.roundCorners()
        containerView.roundCorners(radius: 10)
        castLabel.text = R.string.localizable.prediction()
        betSumLabel.text = R.string.localizable.bet_amount_100()
        factorLabel.text = R.string.localizable.odds_col()
        resultLabel.text = R.string.localizable.result()
        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        containerView.isHidden = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        loadInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.view.layer.opacity = 1
        }
    }
    
    @objc
    func close() {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.containerView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
            
        } completion: {[weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.view.layer.opacity = 0
            } completion: { _ in
                self?.dismiss(animated: false)
            }
        }

    }
    
    func loadInfo() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self,
                  let bet: Bet = Repository.scalarData(Bet.table.where(Bet.idField == self.betId)),
                  let typeId = bet.typeId,
                  let factor = bet.factor,
                  let outcome = bet.outcome,
                  let betType: BetType = Repository.scalarData(BetType.table.where(BetType.idField == typeId)) else { return }
            let teams: [Team] = Repository.selectData(Team.table.where([bet.team1Id, bet.team2Id].contains(Team.idField)))
            guard teams.count == 2, let team1 = teams.first, let team2 = teams.last else { return }
            
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.eventDateLabel.text = R.string.localizable.year_at_end(bet.eventDate.format("d MMMM yyyy"))
                self.teamsLabel.text = "\(team1.title) - \(team2.title)"
                self.betTypeLabel.text = betType.shortTitle
                self.factorResultLabel.text = factor.formattedString
                self.betTypeDetailsLabel.text = betType.description
                if let typeArg = bet.typeArg {
                    self.betTypeLabel.text?.replace("%x%", with: "\(typeArg)")
                    self.betTypeDetailsLabel.text?.replace("%x%", with: "\(typeArg)")
                }
                switch outcome {
                case .active:
                    break
                case .won:
                    self.resultValLabel.text = R.string.localizable.winnings("\(factor.winCalcValue)")
                    self.resultValLabel.textColor = R.color.won()
                case .lost:
                    self.resultValLabel.text = R.string.localizable.loss()
                    self.resultValLabel.textColor = R.color.lost()
                case .return:
                    self.resultValLabel.text = R.string.localizable.return()
                    self.resultValLabel.textColor = R.color.text()
                }
                self.activityView.animateOpacity(0.4, 0) {[weak self] in
                    self?.activityView.isHidden = true
                    self?.containerView.isHidden = false
                    UIView.animate(withDuration: 0.4) {[weak self] in
                        self?.containerView.transform = CGAffineTransform.identity
                    }
                }
            }
                                                      
        }
        
    }
}
