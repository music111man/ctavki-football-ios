//
//  FaqView.swift
//  App
//
//  Created by Denis Shkultetskyy on 09.03.2024.
//

import UIKit

class FaqView: UIView {

    @IBOutlet weak var collapseAnswerImageView: UIImageView!
    @IBOutlet weak var tapCollapseView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    var gradient: CAGradientLayer!
    let rotateAngel: CGFloat = 3.14
    var isCollapsed = true
    
    var model: FaqViewModel! {
        didSet {
            indexLabel.text = model.index.asString
            questionLabel.text = model.question.trimHTMLTags()
            answerLabel.text = model.answer.trimHTMLTags()?.replace("\n", with: "\n\n")
            backgroundColor = model.index % 2 > 0 ? R.color.background_main() : R.color.background_main_light()
            printAppEvent(answerLabel.text!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerLabel.isHidden = isCollapsed
        gradient = circleView.setGradient(start: R.color.green_blue_end(), end: R.color.green_blue_start(), isLine: false, index: 0)
        tapCollapseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(collapseAnswer)))
        questionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(collapseAnswer)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = circleView.bounds
        circleView.roundCorners()
    }
    
    @objc
    private func collapseAnswer() {
        isCollapsed.toggle()
        model?.isCollapsed = isCollapsed
        UIView.animate(withDuration: 0.4) {[weak self] in
            guard let self = self else { return }
            self.answerLabel.isHidden = self.isCollapsed
            self.collapseAnswerImageView.transform =  self.isCollapsed ? .identity : .init(rotationAngle: rotateAngel)
        }
    }

}
