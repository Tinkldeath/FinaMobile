//
//  ManagerFactory.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation

protocol ManagerFactory: AnyObject {
    var authManager: AuthManager { get }
    var twoFactorAuthManager: TwoFactorAuthManager { get }
    var userManager: UserManager { get }
    var cardsManager: CardsManager { get }
    var bankAccountsManager: BankAccountsManager { get }
    var transactionsManager: TransactionsManager { get }
    var creditsManager: CreditsManager { get }
    var creditScheduleManager: CreditScheduleManager { get }
    var notificationsManager: NotificationsManager { get }
    var mediaManager: MediaManager { get }
    var transactionEngine: TransactionEngine { get }
}

final class DefaultManagerFactory: ManagerFactory {
    
    var authManager: AuthManager = FirebaseAuthManager()
    
    var twoFactorAuthManager: TwoFactorAuthManager = FirebaseTwoFactorAuthManager()
    
    var userManager: UserManager = FirebaseUserManager()
    
    var cardsManager: CardsManager = FirebaseCardsManager()
    
    var bankAccountsManager: BankAccountsManager = FirebaseBankAccountsManager()
    
    var transactionsManager: TransactionsManager = FirebaseTransactionsManager()
    
    var creditsManager: CreditsManager = FirebaseCreditsManager()
    
    var creditScheduleManager: CreditScheduleManager = FirebaseCreditScheduleManager()
    
    var notificationsManager: NotificationsManager = FirebaseNotificationsManager()
    
    var mediaManager: MediaManager = FirebaseMediaManager()
    
    lazy var transactionEngine = TransactionEngine(bankAccountManager: bankAccountsManager, transactionManager: transactionsManager, creditsManager: creditsManager, userManager: userManager, creditScheduleManager: creditScheduleManager, notificationsManager: notificationsManager)
    
    static let shared = DefaultManagerFactory()
    
    private init() {}
    
    func initialize() async {
        await (userManager as? FirebaseUserManager)?.initialize()
        await (cardsManager as? FirebaseCardsManager)?.initialize()
        await (bankAccountsManager as? FirebaseBankAccountsManager)?.initialize()
        await (creditsManager as? FirebaseCreditsManager)?.initialize()
        await (notificationsManager as? FirebaseNotificationsManager)?.initialize()
        transactionEngine.addAutoPaymentCreditsObserver()
    }
}
