//
//  SignInVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 14.03.2024.
//

import UIKit
import RxSwift
import AuthenticationServices

class SignInVController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var telegramBtnView: UIView!
    @IBOutlet weak var googleBtnView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var telegramLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var goToView: UIView!
    @IBOutlet weak var goToLabel: UILabel!
    let disposeBag = DisposeBag()
    let accountService = AccountService.share
    var gradient: CAGradientLayer!
    var appleBtnView: UIView?
    
    var disposed: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        AppSettings.authorizeEvent.asObservable().observe(on: MainScheduler.instance).bind {[weak self] isSignIn in
            self?.activityView.isHidden = true
            self?.titleLabel.text = isSignIn ? AppSettings.userName : R.string.localizable.you_are_not_logged_in()
            self?.subTitleLabel.text = !isSignIn ? R.string.localizable.we_gift_free_bets_to_new_users() : R.string.localizable.you_are_logged()
            self?.goToView.superview?.isHidden = !isSignIn
            self?.googleBtnView.isHidden = isSignIn
            self?.telegramBtnView.isHidden = isSignIn
            self?.appleBtnView?.isHidden = isSignIn
            if #available(iOS 13.0, *) {
                self?.stackView.arrangedSubviews.first?.isHidden = isSignIn
            }
            
        }.disposed(by: disposeBag)
        
        googleLabel.text = R.string.localizable.log_in_with_google()
        telegramLabel.text = R.string.localizable.log_in_with_telegram()
        goToLabel.text = R.string.localizable.get_more_bets().uppercased()
        gradient = goToView.setGradient(start: .greenBlueStart, end: .greenBlueEnd, isLine: true, index: 0)
        view.tap(animateTapGesture: false) {
           UIView.animate(withDuration: 0.3) {[weak self] in
               self?.view.layer.opacity = 0
           } completion: {[weak self] _ in
               self?.dismiss(animated: false)
           }
        }.disposed(by: disposeBag)
        containerView.tap(animateTapGesture: false) { }.disposed(by: disposeBag)
        closeView.tap {[weak self] in
            guard let self = self else { return }
            UIView.transition(with: self.containerView,
                              duration: 0.5,
                              options: [.transitionFlipFromLeft],
                              animations: { [weak self] in
                self?.containerView.layer.opacity = 0
            }) { _ in
                UIView.animate(withDuration: 0.3) {[weak self] in
                    self?.view.layer.opacity = 0
                } completion: {[weak self] _ in
                    self?.dismiss(animated: false)
                }
            }
        }.disposed(by: disposeBag)
        goToView.superview?.tap {
            UIView.animate(withDuration: 0.3) {[weak self] in
                self?.containerView.transform = .init(scaleX: 0.01, y: 0.01)
                self?.view.layer.opacity = 0
            } completion: {[weak self] _ in
                self?.dismiss(animated: false) { [weak self] in
                    self?.disposed?()
                }
            }
        }.disposed(by: disposeBag)
        
        googleBtnView.tap {[weak self] in
            self?.accountService.signInByGoogle(presenting: self!)
        }.disposed(by: disposeBag)
        
        telegramBtnView.tap {[weak self] in
            self?.accountService.signInByTelegram()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).subscribe {[weak self] _ in
            self?.activityView.isHidden = !(self?.accountService.signIn() ?? false)
         }.disposed(by: disposeBag)
        
        if #available(iOS 13.0, *), !AppSettings.isAuthorized {
            let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
            authorizationButton.shadowed = true
            authorizationButton.cornerRadius = 8
            authorizationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            stackView.insertArrangedSubview(authorizationButton, at: 0)
            authorizationButton.tap {[weak self] in
                self?.accountService.signInByApple(presenting: self!)
            }.disposed(by: disposeBag)
            appleBtnView = authorizationButton
        }
        
        NotificationCenter.default.rx.notification(Notification.Name.deserializeError).subscribe {[weak self] _ in
            self?.activityView.isHidden = true
            self?.showAlert(title: R.string.localizable.error(), message: R.string.localizable.server_data_error())
         }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.badNetRequest).subscribe {[weak self] _ in
            self?.activityView.isHidden = true
            self?.showAlert(title: R.string.localizable.error(), message: R.string.localizable.net_error())
         }.disposed(by: disposeBag)
        
        activityView.isHidden = !accountService.signIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = goToView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerView.transform = .init(scaleX: 0.01, y: 0.01)
        view.layer.opacity = 0
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.view.layer.opacity = 1
            self?.containerView.transform = .identity
        }) {[weak self] _ in
            guard let self = self else { return }
            self.gradient.frame = self.goToView.bounds
        }
    }
}

@available(iOS 13.0, *)
extension SignInVController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
