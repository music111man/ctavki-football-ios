//
//  FaqView.swift
//  App
//
//  Created by Denis Shkultetskyy on 09.03.2024.
//

import UIKit
import RxSwift

protocol FaqViewDeelegate: AnyObject {
    func changeVisibality()
}

class FaqView: UIView {
    static let rotateAngel: CGFloat = 3.14

    @IBOutlet weak var collapseAnswerImageView: UIImageView!
    @IBOutlet weak var tapCollapseView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    let disposeBag = DisposeBag()
    weak var delegate: FaqViewDeelegate?
    
    var gradient: CAGradientLayer!
    
    var isCollapsed = true
    
    var model: FaqViewModel! {
        didSet {
            indexLabel.text = model.index.asString
            questionLabel.text = model.question.trimHTMLTags()
            answerLabel.text = model.answer.trimHTMLTags()?.replace("\n", with: "\n\n")
            backView.backgroundColor = model.index % 2 > 0 ? .backgroundMain : .backgroundMainLight
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .shadow.withAlphaComponent(0.2)
        answerLabel.isHidden = isCollapsed
        gradient = circleView.setGradient(start: .greenBlueEnd, end: .greenBlueStart, isLine: false, index: 0)
        tapCollapseView.tap(animateTapGesture: false) {[weak self] in
            self?.changeAnswerVisibility()
        }.disposed(by: disposeBag)
        questionLabel.tap(animateTapGesture: false) {[weak self] in
            self?.changeAnswerVisibility()
        }.disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = circleView.bounds
        roundCorners(radius: circleView.bounds.width / 2)
        backView.roundCorners(radius: circleView.bounds.width / 2)
    }
    
    func collapse() {
        if isCollapsed { return }
        
        isCollapsed = true
        model?.isCollapsed = true
        UIView.animate(withDuration: 0.4) {[weak self] in
            guard let self = self else { return }
            self.answerLabel.isHidden = true
            self.collapseAnswerImageView.transform =  .identity
        }
    }
    private func changeAnswerVisibility() {
        isCollapsed.toggle()
        model?.isCollapsed = isCollapsed
        delegate?.changeVisibality()
        UIView.animate(withDuration: 0.4) {[weak self] in
            guard let self = self else { return }
            self.answerLabel.isHidden = self.isCollapsed
            self.collapseAnswerImageView.transform =  self.isCollapsed ? .identity : .init(rotationAngle: Self.rotateAngel)
        }
    }

}
