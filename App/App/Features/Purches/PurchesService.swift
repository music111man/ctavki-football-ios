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
    
    var products: [SKProduct]?
    let disposeBag = DisposeBag()
    let donates = BehaviorRelay<[Donate]>(value: [])
    let endLoad = BehaviorRelay<Bool>(value: true)
    let endPurche = PublishRelay<String?>()

    init() {
        IAPService.default.productsResult.bind {[weak self] result in
            self?.fetchAvailable(result: result)
        }.disposed(by: disposeBag)
        
        IAPService.default.purchaseProductResult.bind {[weak self] result in
            self?.processPurchase(result: result)
        }.disposed(by: disposeBag)
    }
    
    func loadDonates() {
        IAPService.default.requestProducts()
    }
    
    func makeDotane(donateId: String) -> Bool {
        guard IAPService.default.canMakePurchases,
              let product = products?.first(where: {$0.productIdentifier == donateId} )  else { return false }
        IAPService.default.purcheProduct(product)
        
        return true
    }

    func fetchAvailable(result: RequestProductsResult) {
        var hasProducts = false
        defer { endLoad.accept(hasProducts) }
        
        switch result {
        case let .success(products):
            self.products = products
            hasProducts = !products.isEmpty
            donates.accept(
                products.sorted(by: { $0.price.doubleValue < $1.price.doubleValue } )
                    .map { p in
                        guard let id = ProductIdentifiers.init(rawValue: p.productIdentifier) else { return nil }
                        
                        return Donate(productId: p.productIdentifier,
                                  priceWithCurrency: p.localizedCurrencyPrice,
                                  name: id.toTitle,
                                      description: id.toDesc) }
                    .compactMap({$0}))
        case let .failure(error):
            printAppEvent(error.localizedDescription)
            donates.accept([])
        }
    }
    
    func processPurchase(result: PurchaseProductResult) {
        switch result {
        case let .success(ok):
            if let ok = ok {
                let msg = ok ? R.string.localizable.thankful_speech() : nil
                endPurche.accept(msg)
            }
        case .failure:
            printAppEvent(R.string.localizable.buy_failed())
            endPurche.accept(R.string.localizable.buy_failed())
        }
    }
}

extension ProductIdentifiers {
    var toTitle: String {
        switch self {
        case .donate5:
            R.string.localizable.donate_5_title()
        case .donate10:
            R.string.localizable.donate_10_title()
        case .donate25:
            R.string.localizable.donate_25_title()
        case .donate100:
            R.string.localizable.donate_100_title()
        }
    }
    var toDesc: String {
        switch self {
        case .donate5:
            R.string.localizable.donate_5_desc()
        case .donate10:
            R.string.localizable.donate_10_desc()
        case .donate25:
            R.string.localizable.donate_25_desc()
        case .donate100:
            R.string.localizable.donate_100_desc()
        }
    }
}
