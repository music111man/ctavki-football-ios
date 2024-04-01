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
    
    func load() -> Single<[FaqViewModel]> {
        let observer: Observable<[Faq]> = Repository.selectObservable(Faq.table)
        return observer.map { faqs -> [FaqViewModel] in
                var models = [FaqViewModel]()
                var index = 0
                for faq in  faqs {
                    index += 1
                    models.append(FaqViewModel(index: index, question: faq.question, answer: faq.answer))
                }
                return models
            }.asSingle()
    }
}
