//
//  FaqService.swift
//  App
//
//  Created by Denis Shkultetskyy on 09.03.2024.
//

import Foundation
import RxSwift
import RxCocoa

final class FaqService {
    
    let disposeBag = DisposeBag()
    var faqs = BehaviorRelay<[FaqViewModel]>(value: [])
    var isLoading = BehaviorRelay<Bool>(value: false)
    
    init() {
        NotificationCenter.default.rx.notification(Notification.Name.needUpdatFaqsScreen).subscribe {[weak self] _ in
            self?.loadData()
        }.disposed(by: disposeBag)
    }
    
    func loadData() {
        isLoading.accept(true)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            var models = [FaqViewModel]()
            let faqs: [Faq] = Repository.select(Faq.table)
            var index = 0
            for faq in  faqs {
                index += 1
                models.append(FaqViewModel(index: index, question: faq.question, answer: faq.answer))
            }
            self.faqs.accept(models)
            self.isLoading.accept(false)
        }
    }
    
}
