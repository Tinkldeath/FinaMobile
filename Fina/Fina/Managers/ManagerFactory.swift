//
//  ManagerFactory.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation


final class ManagerFactory {
    
    let authManager = AuthManager()
    let twoFactorAuthManager = TwoFactorAuthManager()
    let userManager = UserManager()
    let cardsManager = CardsManager()
    let bankAccountsManager = BankAccountsManager()
    
    static let shared = ManagerFactory()
    
    private init() {}
    
    func initialize() async {
        await userManager.initialize()
        await cardsManager.initialize()
        await bankAccountsManager.initialize()
    }
}
