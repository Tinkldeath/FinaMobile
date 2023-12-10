//
//  User.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation

struct User: Codable {
    var uid: String
    var name: String
    var imageUrl: String?
    var passportIdentifier: Data
    var codePassword: Data?
    var accounts: [String]
    var cards: [String]
    var credits: [String]
    var receipts: [String]
}


extension User: FirebaseEntity {
    
    static func collection() -> String {
        return "users"
    }
    
    init?(_ from: [String : Any]) {
        guard let uid = from["uid"] as? String else { return nil }
        guard let name = from["name"] as? String else { return nil }
        guard let passportIdentifier = from["passportIdentifier"] as? Data else { return nil }
        let imageUrl = from["imageUrl"] as? String
        let codePassword = from["codePassword"] as? Data
        guard let accounts = from["accounts"] as? [String] else { return nil }
        guard let cards = from["cards"] as? [String] else { return nil }
        guard let credits = from["credits"] as? [String] else { return nil }
        guard let receipts = from["receipts"] as? [String] else { return nil }
        self.uid = uid
        self.name = name
        self.passportIdentifier = passportIdentifier
        self.imageUrl = imageUrl
        self.codePassword = codePassword
        self.accounts = accounts
        self.cards = cards
        self.credits = credits
        self.receipts = receipts
    }

    func toEntity() -> [String : Any] {
        var entity = [String: Any]()
        entity["uid"] = self.uid
        entity["name"] = self.name
        entity["passportIdentifier"] = self.passportIdentifier
        entity["codePassword"] = self.codePassword
        entity["accounts"] = self.accounts
        entity["cards"] = self.cards
        entity["credits"] = self.credits
        entity["receipts"] = self.receipts
        entity["imageUrl"] = self.imageUrl
        return entity
    }
}
