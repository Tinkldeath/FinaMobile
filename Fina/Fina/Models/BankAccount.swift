//
//  BankAccount.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

struct BankAccount {
    
    var uid: String
    var ownerId: String
    var accountType: BankAccountType
    var currency: Currency
    var balance: Double
    var dateCreated: Date
    var isBlocked: Bool
    var number: Data
    var contractNumber: Data
    var iban: Data
    var monthLimit: Double?
}

extension BankAccount {
    
    enum BankAccountType: Int {
        case currentAccount = 0
        case savingsAccount
        case creditAccount
    }
}

extension BankAccount: FirebaseEntity {
    
    static func collection() -> String {
        return "bankAccounts"
    }
    
    init?(_ from: [String : Any]) {
        guard let uid = from["uid"] as? String else { return nil }
        guard let ownerId = from["ownerId"] as? String else { return nil }
        guard let type = from["accountType"] as? Int, let accountType = BankAccountType(rawValue: type) else { return nil }
        guard let cur = from["currency"] as? String, let currency = Currency(rawValue: cur) else { return nil }
        guard let balance = from["balance"] as? Double else { return nil }
        guard let dateCreatedRaw = from["dateCreated"] as? TimeInterval else { return nil }
        guard let isBlocked = from["isBlocked"] as? Bool else { return nil }
        guard let number = from["number"] as? Data else { return nil }
        guard let contractNumber = from["contractNumber"] as? Data else { return nil }
        guard let iban = from["iban"] as? Data else { return nil }
        let monthLimit = from["monthLimit"] as? Double
        let dateCreated = Date(timeIntervalSince1970: dateCreatedRaw)
        self.uid = uid
        self.ownerId = ownerId
        self.accountType = accountType
        self.currency = currency
        self.balance = balance
        self.dateCreated = dateCreated
        self.isBlocked = isBlocked
        self.number = number
        self.contractNumber = contractNumber
        self.iban = iban
        self.monthLimit = monthLimit
    }
    
    func toEntity() -> [String : Any] {
        return [
            "uid": uid,
            "ownerId": ownerId,
            "accountType": accountType.rawValue,
            "currency": currency.rawValue,
            "balance": balance,
            "dateCreated": dateCreated.timeIntervalSince1970,
            "isBlocked": isBlocked,
            "number": number,
            "contractNumber": contractNumber,
            "iban": iban,
            "monthLimit": monthLimit as Any
        ]
    }
}
