//
//  Card.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import UIKit

struct Card {
    var uid: String
    var ownerId: String
    var bankAccountId: String
    var cardType: CardType
    var title: String
    var number: Data
    var expiresDate: Date
    var cvv: Data
    var pin: Data
}

extension Card {
    
    enum CardType: Int, CaseIterable {
        case debit = 0
        case loyalty
        case credit
        
        var associatedColor: UIColor {
            switch self {
            case .credit:
                return .systemGray
            case .debit:
                return .black
            case .loyalty:
                return .systemPurple
            }
        }
        
        var associatedAccountType: BankAccount.BankAccountType {
            switch self {
            case .loyalty:
                return .currentAccount
            case .credit:
                return .creditAccount
            case .debit:
                return .currentAccount
            }
        }
        
        var localizedTitle: String {
            switch self {
            case .loyalty:
                return "Loyalty card"
            case .credit:
                return "Credit card"
            case .debit:
                return "Debit card"
            }
        }
        
        var localizedDescription: String {
            switch self {
            case .loyalty:
                return "Receive cashback up to 2% on purchases in online stores and online marketplaces"
            case .credit:
                return "Receive cashback up to 1% on all purchases"
            case .debit:
                return "Receive cashback up to 1% on money transfers"
            }
        }
    }
}

extension Card: FirebaseEntity {
    
    static func collection() -> String {
        return "cards"
    }
    
    init?(_ from: [String : Any]) {
        guard let uid = from["uid"] as? String else { return nil }
        guard let ownerId = from["ownerId"] as? String else { return nil }
        guard let bankAccountId = from["bankAccountId"] as? String else { return nil }
        guard let rawCardType = from["cardType"] as? Int, let cardType = CardType(rawValue: rawCardType) else { return nil }
        guard let title = from["title"] as? String else { return nil }
        guard let number = from["number"] as? Data else { return nil }
        guard let cvv = from["cvv"] as? Data else { return nil }
        guard let pin = from["pin"] as? Data else { return nil }
        guard let expiresTimestamp = from["expiresDate"] as? TimeInterval else { return nil }
        let expiresDate = Date(timeIntervalSince1970: expiresTimestamp)
        self.uid = uid
        self.ownerId = ownerId
        self.bankAccountId = bankAccountId
        self.cardType = cardType
        self.title = title
        self.number = number
        self.cvv = cvv
        self.pin = pin
        self.expiresDate = expiresDate
    }
    
    func toEntity() -> [String : Any] {
        return [
            "uid": uid,
            "ownerId": ownerId,
            "bankAccountId": bankAccountId,
            "cardType": cardType.rawValue,
            "title": title,
            "number": number,
            "cvv": cvv,
            "pin": pin,
            "expiresDate": expiresDate.timeIntervalSince1970
        ]
    }
    
}
