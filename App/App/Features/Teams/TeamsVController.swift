//
//  TeamsVController.swift
//  App
//
//  Created by Denis Shkultetskyy on 22.02.2024.
//

import Foundation
import UIKit

final class TeamsVController: FeaureVController {
    
    let flowOutView = UICollectionViewFlowLayout()
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        navigationBar.hideAuthBtn()
        
        activityView.animateOpacity(0.5, 0)
        let viewText = UIView()
        viewText.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.textColor = .darkText
        label.font = UIFont.systemFont(ofSize: 20)
        viewText.addSubview(label)
        viewText.backgroundColor = .backgroundLight
        view.addSubview(viewText)
        NSLayoutConstraint.activate([
            viewText.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            viewText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: viewText.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: viewText.bottomAnchor, constant: -10),
            label.leftAnchor.constraint(equalTo: viewText.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: viewText.rightAnchor, constant: -20)
        ])
        viewText.roundCorners(radius: (label.intrinsicContentSize.height + 20.0) / 2 )
        viewText.setshadow()
        viewText.tap {
            printAppEvent("tap by \(self.label.text ?? "")")
        }.disposed(by: disposeBag)
        let widht = label.intrinsicContentSize.width + 40.0
        printAppEvent("size with text calculated=\(widht)")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        printAppEvent("size with textView=\(label.superview?.bounds.width ?? 0 + 40.0)")
    }
    
    override func titleName() -> String {
        R.string.localizable.screen_teams_title()
    }
    
    override func icon() -> UIImage? {
        R.image.teams()
    }
}
