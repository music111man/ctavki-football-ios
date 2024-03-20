//
//  PurchesService.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 19.03.2024.
//

import Foundation
import StoreKit
import RxSwift
import RxCocoa

struct Donate {
    let productId: String
    let priceWithCurrency: String
    let name: String
    let description: String
}

final class PurchesService {
    
    
    let disposeBag = DisposeBag()
    let donates = BehaviorRelay<[Donate]>(value: [])
    let endLoad = PublishRelay<Bool>()
    let endPurche = PublishRelay<String>()

    init() {
        IAPService.default.delegate = self
    }
    
    func loadDonates() {
        IAPService.default.requestProducts()
    }
    
    func makeDotane(donateId: String) -> Bool {
        if !IAPService.default.canMakePurchases  { return false }
        IAPService.default.purcheProduct(donateId)
        
        return true
    }
}

extension PurchesService: IAPServiceDelegate {
    func fetchAvailable(result: RequestProductsResult) {
        var hasProducts = false
        defer { endLoad.accept(hasProducts) }
        
        switch result {
        case let .success(products):
            hasProducts = !products.isEmpty
            printAppEvent("was load \(products.count) donates")
            donates.accept(
                products.sorted(by: { $0.price.doubleValue < $1.price.doubleValue } ).map { Donate(productId: $0.productIdentifier,
                                                                                                   priceWithCurrency: $0.localizedCurrencyPrice,
                                                                                                   name: $0.localizedTitle,
                                                                                                   description: $0.localizedDescription) })
        case let .failure(error):
            printAppEvent(error.localizedDescription)
            donates.accept([])
        }
    }
    
    func processPurchase(result: PurchaseProductResult) {
        switch result {
        case let .success(ok):
            let msg = ok ? R.string.localizable.thankful_speech() : R.string.localizable.buy_failed()
            printAppEvent(msg)
            endPurche.accept(msg)
        case .failure:
            printAppEvent(R.string.localizable.buy_failed())
            endPurche.accept(R.string.localizable.buy_failed())
        }
    }
}
