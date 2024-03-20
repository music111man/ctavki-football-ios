//
//  IAPService.swift
//  Ctavki
//
//  Created by Denis Shkultetskyy on 20.03.2024.
//

import Foundation
import StoreKit

typealias RequestProductsResult = Result<[SKProduct], Error>
typealias PurchaseProductResult = Result<Bool, Error>

protocol IAPServiceDelegate: AnyObject {
    func fetchAvailable(result: RequestProductsResult) -> Void
    func processPurchase(result: PurchaseProductResult) -> Void
}

enum PurchasesError: Error {
    case purchaseInProgress
    case productNotFound
    case unknown
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
    
    private var products: [String: SKProduct]?
    private let productIdentifiers = Set<String>(["donate_5", "donate_10", "donate_25", "donate_100"])
    private var productRequest: SKProductsRequest?
    weak var delegate: IAPServiceDelegate?
    var purchesProductId: String?
    
    var canMakePurchases: Bool { SKPaymentQueue.canMakePayments() }
    
    func requestProducts() {
        productRequest?.cancel()
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
        self.productRequest = productRequest
    }
    
    func purcheProduct(_ productId: String) {
        if purchesProductId != nil {
            delegate?.processPurchase(result: .failure(PurchasesError.purchaseInProgress))
            return
        }

        guard let product = products?[productId] else {
            delegate?.processPurchase(result: .failure(PurchasesError.productNotFound))
            return
        }
        
        purchesProductId = productId
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = [String: SKProduct]()
        response.products.forEach {products?[$0.productIdentifier] = $0 }
        
        delegate?.fetchAvailable(result: .success(response.products))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        delegate?.fetchAvailable(result: .failure(error))
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {
            guard let purchesProductId = self.purchesProductId else {
                SKPaymentQueue.default().finishTransaction(transaction)
                continue
            }
            printAppEvent("transactionState: \(transaction.transactionState)")
            switch transaction.transactionState {
            case .purchased, .restored:
                if transaction.payment.productIdentifier == purchesProductId {
                    delegate?.processPurchase(result: .success(true))
                } else {
                    delegate?.processPurchase(result: .success(false))
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                self.purchesProductId = nil
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                self.purchesProductId = nil
            default:
                break
            }
        }
    }
    
    
}
