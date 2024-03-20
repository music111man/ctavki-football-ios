//
//  SKProduct+Extension.swift
//  IAPManager
//
//  Created by Sergey Zhuravel on 1/12/22.
//

import UIKit
import StoreKit

extension SKProduct: Comparable {
    public static func < (lhs: SKProduct, rhs: SKProduct) -> Bool {
        lhs.price.doubleValue < rhs.price.doubleValue
    }
    
    var localizedCurrencyPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        
        return formatter.string(from: price)!
    }
}
