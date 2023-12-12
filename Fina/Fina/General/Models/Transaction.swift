//
//  Transaction.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import UIKit

struct Transaction {
    var uid: String
    var transactionType: TransactionType
    var senderBankAccount: String?
    var recieverBankAccount: String?
    var sum: Double
    var currency: Currency
    var date: Date
    var isCompleted: Bool
    
    var transactionTotal: String {
        switch self.transactionType {
        case .transfer:
            return "\(currency.stringAmount(sum))"
        case .payment:
            return "- \(currency.stringAmount(sum))"
        case .obtainingCredit:
            return "+ \(currency.stringAmount(sum))"
        case .creditPayment:
            return "- \(currency.stringAmount(sum))"
        case .income:
            return "+ \(currency.stringAmount(sum))"
        }
    }
}

extension Transaction: Hashable, Equatable {
        
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

extension Transaction {
    
    enum TransactionType: Int {
        case transfer = 0
        case payment
        case obtainingCredit
        case creditPayment
        case income
        
        var localizedTitle: String {
            switch self {
            case .transfer:
                return "Money transfer"
            case .payment:
                return "Payment"
            case .obtainingCredit:
                return "Obtaining credit"
            case .creditPayment:
                return "Creidt payment"
            case .income:
                return "Income"
            }
        }
        
        var associatedColor: UIColor {
            switch self {
            case .transfer:
                return .label
            case .payment:
                return .red
            case .obtainingCredit:
                return .green
            case .creditPayment:
                return .red
            case .income:
                return .green
            }
        }
        
        var associatedImage: UIImage? {
            switch self {
            case .transfer:
                return UIImage(systemName: "repeat.circle")
            case .payment:
                return UIImage(systemName: "arrow.down.to.line.circle")
            case .obtainingCredit:
                return UIImage(systemName: "arrow.up.to.line.circle")
            case .creditPayment:
                return UIImage(systemName: "arrow.down.to.line.circle")
            case .income:
                return UIImage(systemName: "arrow.up.to.line.circle")
            }
        }
    }
}

extension Transaction: FirebaseEntity {
    
    static func collection() -> String {
        return "transactions"
    }
    
    init?(_ from: [String : Any]) {
        guard let uid = from["uid"] as? String else { return nil }
        guard let rawType = from["transactionType"] as? Int, let transactionType = TransactionType(rawValue: rawType) else { return nil }
        let senderBankAccount = from["senderBankAccount"] as? String
        let recieverBankAccount = from["recieverBankAccount"] as? String
        guard let sum = from["sum"] as? Double else { return nil }
        guard let rawCurrency = from["currency"] as? String, let currency = Currency(rawValue: rawCurrency) else { return nil }
        guard let rawDate = from["date"] as? TimeInterval else { return nil }
        let date = Date(timeIntervalSince1970: rawDate)
        guard let isCompleted = from["isCompleted"] as? Bool else { return nil }
        self.uid = uid
        self.transactionType = transactionType
        self.senderBankAccount = senderBankAccount
        self.recieverBankAccount = recieverBankAccount
        self.sum = sum
        self.currency = currency
        self.date = date
        self.isCompleted = isCompleted
    }
    
    func toEntity() -> [String : Any] {
        return [
            "uid": uid,
            "transactionType": transactionType.rawValue,
            "senderBankAccount": senderBankAccount as Any,
            "recieverBankAccount": recieverBankAccount as Any,
            "sum": sum,
            "currency": currency.rawValue,
            "date": date.timeIntervalSince1970,
            "isCompleted": isCompleted
        ]
    }
}
