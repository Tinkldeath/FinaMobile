//
//  Currency.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

enum Currency: String {
    
    case byn = "BYN"
    case usd = "USD"
    case eur = "EUR"
    case rub = "RUB"
    
    var rate: Double {
        switch self {
        case .usd:
            return 3.1384
        case .eur:
            return 3.4204
        case .rub:
            return 0.0350
        case .byn:
            return 1.0
        }
    }
    
    var title: String {
        switch self {
        case .rub:
            return " 🇷🇺 100 RUB"
        case .usd:
            return " 🇺🇸 1 USD"
        case .eur:
            return " 🇪🇺 1 EUR"
        default:
            return ""
        }
    }
    
    var titleRate: String {
        switch self {
        case .usd:
            return "\(round(rate * 100) / 100) BYN"
        case .eur:
            return "\(round(rate * 100) / 100) BYN"
        case .rub:
            return "3.50 BYN"
        default:
            return ""
        }
    }
    
    func stringAmount(_ amount: Double) -> String {
        return self.rawValue + " \(amount.toRounded())"
    }
    
    static var displayCurrencies: [Currency] {
        return [.usd, .eur, .rub]
    }
    
    static func exchange(amount: Double, from fromCurrency: Currency,to toCurrency: Currency) -> Double {
        let amountInBYN = amount * fromCurrency.rate
        let result = amountInBYN / toCurrency.rate
        return round(result * 100) / 100
    }
    
}
