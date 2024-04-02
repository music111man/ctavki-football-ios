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

    @IBOutlet weak var signOutLabel: UILabel!
    @IBOutlet weak var signOutView: UIView!
    @IBOutlet weak var signOutContainerView: UIView!
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
//    var gradient: CAGradientLayer!
    var appleBtnView: UIView?
    var singInMethodName: String?
    var disposed: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.setStyle()
        AccountService.share.delegate = self
        view.backgroundColor = .black.withAlphaComponent(0.6)
        AppSettings.authorizeEvent.asObservable().observe(on: MainScheduler.instance).bind {[weak self] isSignIn in
            self?.activityView.isHidden = true
            self?.titleLabel.text = isSignIn ? AppSettings.userName : R.string.localizable.you_are_not_logged_in()
            self?.subTitleLabel.text = !isSignIn ? R.string.localizable.we_gift_free_bets_to_new_users() : R.string.localizable.you_are_logged()
            self?.goToView.superview?.isHidden = !isSignIn
            self?.googleBtnView.isHidden = isSignIn
            self?.telegramBtnView.isHidden = isSignIn
            self?.appleBtnView?.isHidden = isSignIn
            self?.signOutContainerView.isHidden = !AppSettings.enableSignOut
            if #available(iOS 13.0, *) {
                self?.stackView.arrangedSubviews.first?.isHidden = isSignIn
            }
            
        }.disposed(by: disposeBag)
        
        googleLabel.text = R.string.localizable.log_in_with_google()
        telegramLabel.text = R.string.localizable.log_in_with_telegram()
        goToLabel.text = R.string.localizable.get_more_bets().uppercased()
        goToView.setGradient(start: .greenBlueStart, end: .greenBlueEnd, isLine: true, index: 0).frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 90, height: 50)
        view.tap(animateTapGesture: false) {
           UIView.animate(withDuration: 0.3) {[weak self] in
               self?.view.layer.opacity = 0
           } completion: {[weak self] _ in
               self?.dismiss(animated: false)
           }
        }.disposed(by: disposeBag)
        containerView.tap(animateTapGesture: false) { }.disposed(by: disposeBag)
        closeView.tap {[weak self] in
            self?.close()
        }.disposed(by: disposeBag)
        goToView.superview?.tap {[weak self] in
            self?.dismiss(animated: false) { [weak self] in
                                self?.disposed?()
                            }
        }.disposed(by: disposeBag)
        
        googleBtnView.tap {[weak self] in
            self?.singInMethodName = SignInMethod.google(idToken: "").toString
            self?.accountService.signInByGoogle(presenting: self!)
        }.disposed(by: disposeBag)
        
        telegramBtnView.tap {[weak self] in
            self?.singInMethodName = SignInMethod.telegram(uuid: "").toString
            self?.accountService.signInByTelegram()
        }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
            self?.activityView.isHidden = !(self?.accountService.signIn() ?? false)
         }.disposed(by: disposeBag)
        
        if #available(iOS 13.0, *), !AppSettings.isAuthorized {
            let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
            authorizationButton.shadowed = true
            authorizationButton.cornerRadius = 8
            authorizationButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            stackView.insertArrangedSubview(authorizationButton, at: 0)
            authorizationButton.tap {[weak self] in
                self?.singInMethodName = SignInMethod.apple(idToken: "", jwt: "", userName: "", userEmail: "").toString
                self?.accountService.signInByApple(presenting: self!)
            }.disposed(by: disposeBag)
            appleBtnView = authorizationButton
        }
        
        NotificationCenter.default.rx.notification(Notification.Name.internalServerError).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
            self?.activityView.isHidden = true
            if let metnodName = self?.singInMethodName {
                self?.showOkAlert(title: R.string.localizable.error(), message: R.string.localizable.log_in_unable(metnodName))
            }
         }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.badServerResponse).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
            self?.activityView.isHidden = true
            if let metnodName = self?.singInMethodName {
                self?.showOkAlert(title: R.string.localizable.error(), message: R.string.localizable.log_in_unable(metnodName))
            }
         }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.deserializeError).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
            self?.activityView.isHidden = true
            if self?.singInMethodName != nil {
                self?.showOkAlert(title: R.string.localizable.error(), message: R.string.localizable.server_data_error())
            }
         }.disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.badNetRequest).observe(on: MainScheduler.instance).subscribe {[weak self] _ in
            self?.activityView.isHidden = true
            if self?.singInMethodName != nil {
                self?.showOkAlert(title: R.string.localizable.error(), message: R.string.localizable.net_error())
            }
         }.disposed(by: disposeBag)
        
        activityView.isHidden = !accountService.signIn()
        signOutLabel.text = R.string.localizable.sign_out()
        signOutContainerView.isHidden = !AppSettings.enableSignOut
        signOutView.tap {[weak self] in
            self?.showOkCancelAlert(title: R.string.localizable.sign_out(), message: R.string.localizable.sing_out_desc()) {[weak self] in
                AppSettings.signInMethod = .singOut
                self?.accountService.signIn()
                self?.close()
            }
        }.disposed(by: disposeBag)
    }
    
    func close() {
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.view.layer.opacity = 0
        } completion: {[weak self] _ in
            self?.dismiss(animated: false)
        }
    }
}

@available(iOS 13.0, *)
extension SignInVController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension SignInVController: AccountServiceDelegate {
    func showSettingsWarning() {
        showOkCancelAlert(title: R.string.localizable.log_in_with_apple(),
                  message: R.string.localizable.log_in_with_apple_desc(),
                  okText: R.string.localizable.settings(),
                  cancelText: R.string.localizable.cancel_Ok()) {
            let urlString = "App-Prefs:root=APPLE_ID"
            UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
        }
    }
}
