//
//  IAPService.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 20.03.2024.
//

import Foundation
import RxSwift
import RxCocoa
import StoreKit

typealias RequestProductsResult = Result<[SKProduct], Error>
typealias PurchaseProductResult = Result<Bool?, Error>

enum PurchasesError: Error {
    case purchaseInProgress
    case productNotFound
    case unknown
}
enum ProductIdentifiers: String, CaseIterable {
    case donate5 = "donate_5"
    case donate10 = "donate_10"
    case donate25 = "donate_25"
    case donate100 = "donate_100"
}

enum IAPPurchesResult {
    case disabled
    case restored
    case purchased
    case failed
    
    var message: String {
        switch self {
        case .disabled: return R.string.localizable.buy_disabled()
        case .restored: return R.string.localizable.buy_restored()
        case .purchased: return R.string.localizable.thankful_speech()
        case .failed: return R.string.localizable.buy_failed()
        }
    }
}

final class IAPService: NSObject {
    
    static let `default` = IAPService()
    let productsResult = BehaviorRelay<RequestProductsResult>(value: .success([]))
    let purchaseProductResult = PublishRelay<PurchaseProductResult>()
    private var products: [SKProduct]?
    private var productRequest: SKProductsRequest?

    var purchesProductId: String?
    
    var canMakePurchases: Bool { SKPaymentQueue.canMakePayments() && purchesProductId == nil }
    
    func requestProducts() {
        productRequest?.cancel()
        productRequest = SKProductsRequest(productIdentifiers: Set(ProductIdentifiers.allCases.map { $0.rawValue }))
        productRequest?.delegate = self
        productRequest?.start()
    }
    
    func purcheProduct(_ product: SKProduct) {
        if purchesProductId != nil {
            purchaseProductResult.accept(.failure(PurchasesError.purchaseInProgress))
            return
        }
        
        purchesProductId = product.productIdentifier
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsResult.accept(.success(response.products))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        productsResult.accept(.failure(error))
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var result: Bool?
        for transaction in transactions {
           
            guard let purchesProductId = self.purchesProductId else {
                SKPaymentQueue.default().finishTransaction(transaction)
                continue
            }
            switch transaction.transactionState {
            case .purchased, .restored:
                if transaction.payment.productIdentifier == purchesProductId {
                    result = true
                    self.purchesProductId = nil
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if transaction.payment.productIdentifier == purchesProductId {
                    result = false
                    self.purchesProductId = nil
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                continue
            }
        }

        purchaseProductResult.accept(.success(result))
    }
    
    
}
