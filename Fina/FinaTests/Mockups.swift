//
//  Mockups.swift
//  FinaTests
//
//  Created by Dima on 13.12.23.
//

import Foundation
import LocalAuthentication
@testable import Fina
@testable import RxRelay

// MARK: - Mockup Auth
class MockupAuthManager: AuthManager {
    
    var currentUser: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    var isPreviouslySigned: Bool {
        return false
    }
    
    var currentUserEmail: String? {
        return nil
    }
    
    private var mockupUsers: [User] = [
        User(uid: "1", name: "Test user 1", passportIdentifier: Ciper.seal("BY1234567"), accounts: [], cards: [], credits: [], receipts: []),
        User(uid: "2", name: "Test user 2", passportIdentifier: Ciper.seal("BY7654321"), accounts: [], cards: [], credits: [], receipts: [])
    ]
    
    func signUp(_ input: Fina.AuthManagerUserInput, _ completion: @escaping Fina.AuthCompletionHandler) {
        guard input.email.isValidEmail(), input.password.isValidPassword(), let user = mockupUsers.randomElement() else { completion(false, nil); return }
        completion(true, user.uid)
    }
    
    func signIn(_ input: Fina.AuthManagerUserInput, _ completion: @escaping Fina.AuthCompletionHandler) {
        guard input.email.isValidEmail(), input.password.isValidPassword(), let user = mockupUsers.randomElement() else { completion(false, nil); return }
        completion(true, user.uid)
    }
    
    func deleteUser(_ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func changeEmail(_ newEmail: String, _ completion: Fina.StringClosure?) {
        completion?(newEmail)
    }
    
    func changePassword(_ newPassword: String, _ completion: Fina.BoolClosure?) {
        completion?(true)
    }
    
    func logout(_ completion: Fina.BoolClosure?) {
        completion?(true)
    }
}

class MockupUserManager: UserManager {
    var currentUser: RxRelay.BehaviorRelay<Fina.User?> = BehaviorRelay(value: User(uid: "1", name: "Test user 1", passportIdentifier: Ciper.seal("BY1234567"), accounts: [], cards: [], credits: [], receipts: []))
    
    private var mockupUsers: [User] = [
        User(uid: "1", name: "Test user 1", passportIdentifier: Ciper.seal("BY1234567"), accounts: [], cards: [], credits: [], receipts: []),
        User(uid: "2", name: "Test user 2", passportIdentifier: Ciper.seal("BY7654321"), accounts: [], cards: [], credits: [], receipts: [])
    ]
    
    func getUser(uid: String, _ completion: @escaping Fina.UserCompletionHandler) {
        let user = mockupUsers.randomElement()
        completion(user)
    }
    
    func getCurrentUser(_ uid: String) {
        
    }
    
    func createUser(_ newUser: Fina.User, _ completion: @escaping Fina.BoolClosure) {
        var copy = newUser
        copy.uid = "\(mockupUsers.count + 1)"
        mockupUsers.append(copy)
        completion(true)
    }
    
    func updateUser(_ updatedUser: Fina.User, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func deleteUser(_ uid: String, _ completion: @escaping Fina.BoolClosure) {
        if let index = mockupUsers.firstIndex(where: { $0.uid == uid }) {
            mockupUsers.remove(at: index)
            completion(true)
        } else {
            completion(false)
        }
        
    }
    
    func signOut() {
        
    }
}

class MockupCardsManager: CardsManager {
    
    var userCards: RxRelay.BehaviorRelay<[Fina.Card]> = BehaviorRelay(value: [])
    
    func fechCard(_ cardNumber: String, _ completion: @escaping Fina.CardClosure) {
        let card = Card(uid: "1", ownerId: "1", bankAccountId: "1", cardType: .credit, title: "Credit card", number: Ciper.seal(cardNumber), expiresDate: Date.now.appendMonth(), cvv: Ciper.seal("123"), pin: Ciper.seal("1234"))
        completion(card)
    }
    
    func createCard(_ newCard: Fina.Card, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func updateCard(_ updatedCard: Fina.Card, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func deleteCard(_ uid: String, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
}

class MockupBankAccountsManager: BankAccountsManager {
    
    var userBankAccounts: RxRelay.BehaviorRelay<[Fina.BankAccount]> = BehaviorRelay(value: [])
    
    var bankAccounts: [BankAccount] = []
    
    func fetchBalance(for uid: String, _ completion: @escaping Fina.BalanceClosure) {
        completion(Double.random(in: 1000...100000), .byn)
    }
    
    func observeBalance(for uid: String, _ completion: @escaping Fina.BalanceClosure) {
        completion(Double.random(in: 1000...100000), .byn)
    }
    
    func fetchBankAccount(by cardNumber: String, _ completion: @escaping Fina.BankAccountClosure) {
        let bankAccount = BankAccount(uid: "1", ownerId: "1", accountType: .creditAccount, currency: .byn, balance: Double.random(in: 1000...100000), dateCreated: Date.now, isBlocked: false, number: Ciper.seal(String.generateRandomNumbers(16)), contractNumber: Ciper.seal(String.generateContractNumber()), iban: Ciper.seal(String.generateIBAN(for: "")), monthLimit: nil)
        completion(bankAccount)
    }
    
    func fetchBankAccount(_ uid: String, _ completion: @escaping Fina.BankAccountClosure) {
        let bankAccount = BankAccount(uid: "1", ownerId: "1", accountType: .creditAccount, currency: .byn, balance: Double.random(in: 1000...100000), dateCreated: Date.now, isBlocked: false, number: Ciper.seal(String.generateRandomNumbers(16)), contractNumber: Ciper.seal(String.generateContractNumber()), iban: Ciper.seal(String.generateIBAN(for: "")), monthLimit: nil)
        completion(bankAccount)
    }
    
    func observeBankAccount(_ uid: String, _ completion: @escaping Fina.BankAccountClosure) {
        let bankAccount = BankAccount(uid: "1", ownerId: "1", accountType: .creditAccount, currency: .byn, balance: Double.random(in: 1000...100000), dateCreated: Date.now, isBlocked: false, number: Ciper.seal(String.generateRandomNumbers(16)), contractNumber: Ciper.seal(String.generateContractNumber()), iban: Ciper.seal(String.generateIBAN(for: "")), monthLimit: nil)
        completion(bankAccount)
    }
    
    func createBankAccount(_ newAccount: Fina.BankAccount, _ completion: @escaping Fina.StringClosure) {
        completion("1")
    }
    
    func updateBankAccount(_ updatedAccount: Fina.BankAccount, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func deleteBankAccount(_ uid: String, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
}

class MockupTransactionsManager: TransactionsManager {
    
    var transactionsRelay: RxRelay.BehaviorRelay<[Fina.Transaction]> = BehaviorRelay(value: [])
    
    func fetchTransactions(for bankAccountId: String, _ month: Int, _ year: Int, _ completion: @escaping Fina.TransactionsClosure) {
        let transaction = Transaction(uid: "1", transactionType: .transfer, senderBankAccount: "1", recieverBankAccount: bankAccountId, sum: Double.random(in: 1000...100000), currency: .byn, date: Date.now, isCompleted: true)
        completion([transaction])
    }
    
    func createTransaction(_ newTransaction: Fina.Transaction, _ completion: @escaping Fina.StringClosure) {
        let transaction = Transaction(uid: "1", transactionType: .transfer, senderBankAccount: "1", recieverBankAccount: "2", sum: Double.random(in: 1000...100000), currency: .byn, date: Date.now, isCompleted: true)
        completion(transaction.uid)
    }
    
    func updateTransaction(_ newTransaction: Fina.Transaction, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func deleteTransaction(_ uid: String, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func observeTransactions(for bankAccountId: String) {
        
    }

}

class MockupCreditsManager: CreditsManager {
    
    var currentUserHasCredits: Bool {
        false
    }
    
    var userCreditsRelay: RxRelay.BehaviorRelay<[Fina.Credit]> = BehaviorRelay(value: [])
    
    func createCredit(_ newCredit: Fina.Credit, _ completion: @escaping Fina.StringClosure) {
        completion("1")
    }
    
    func observeCredit(_ uid: String, _ observer: @escaping Fina.CreditCompletionHandler) {
        let credit = Credit(uid: "1", ownerId: "1", bankAccountId: "1", durationMonths: 42, totalSum: Double.random(in: 2000...100000), sum: Double.random(in: 1000...100000), currency: .byn, paymentType: .diff, percentYear: 19, hasDebt: false, isPayed: false, dateAdded: Date.now, debtDays: [], schedule: ["1", "2", "3"], guarantor: Ciper.seal("BY1234567"))
        observer(credit)
    }
    
    func fetchCreditAsync(_ uid: String) async -> Fina.Credit? {
        let credit = Credit(uid: "1", ownerId: "1", bankAccountId: "1", durationMonths: 42, totalSum: Double.random(in: 2000...100000), sum: Double.random(in: 1000...100000), currency: .byn, paymentType: .diff, percentYear: 19, hasDebt: false, isPayed: false, dateAdded: Date.now, debtDays: [], schedule: ["1", "2", "3"], guarantor: Ciper.seal("BY1234567"))
        return credit
    }
    
    func fetchCredit(_ uid: String, _ completion: @escaping Fina.CreditCompletionHandler) {
        let credit = Credit(uid: "1", ownerId: "1", bankAccountId: "1", durationMonths: 42, totalSum: Double.random(in: 2000...100000), sum: Double.random(in: 1000...100000), currency: .byn, paymentType: .diff, percentYear: 19, hasDebt: false, isPayed: false, dateAdded: Date.now, debtDays: [], schedule: ["1", "2", "3"], guarantor: Ciper.seal("BY1234567"))
        completion(credit)
    }
    
    func updateCredit(_ updateCredit: Fina.Credit, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func deleteCredit(_ uid: String, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    
}

class MockupCreditScheduleManager: CreditScheduleManager {
    
    func createSchedule(creditId: String, scheduleItems: [Fina.CreditSchedule], _ completion: @escaping Fina.StringArrayClosure) {
        completion(["1", "2", "3"])
    }
    
    func observeSchedule(for credit: Fina.Credit, _ observer: @escaping Fina.CreditSchedulesCompletionHandler) {
        let schedule = CreditSchedule(uid: "1", creditId: "1", date: Date.now, isPayed: false, percentPayment: 19, loanPayment: 100, monthPayment: 120, overbay: 0)
        observer([schedule])
    }
    
    func fetchSchedule(_ uid: String, _ completion: @escaping Fina.CreditScheduleCompletionHandler) {
        let schedule = CreditSchedule(uid: "1", creditId: "1", date: Date.now, isPayed: false, percentPayment: 19, loanPayment: 100, monthPayment: 120, overbay: 0)
        completion(schedule)
    }
    
    func fetchScheduleAsync(_ scheduleIds: [String]) async -> [Fina.CreditSchedule] {
        let schedule = CreditSchedule(uid: "1", creditId: "1", date: Date.now, isPayed: false, percentPayment: 19, loanPayment: 100, monthPayment: 120, overbay: 0)
        return [schedule]
    }
    
    func updateSchedule(_ scheduleToUpdate: Fina.CreditSchedule, _ completion: Fina.BoolClosure?) {
        completion?(true)
    }
    
    func deleteSchedule(_ uid: String, _ completion: Fina.BoolClosure?) {
        completion?(true)
    }
}

class MockupNotificationsManager: NotificationsManager {
    
    var userNotifiactionsRelay: RxRelay.BehaviorRelay<[Fina.Notification]> = BehaviorRelay(value: [])
    
    func createNotification(_ newNotification: Fina.Notification, _ completion: @escaping Fina.StringClosure) {
        let _ = Notification(uid: "1", recieverId: "1", title: "Test", content: "Test", isRead: false)
        completion("1")
    }
    
    func fetchNotification(_ uid: String, _ completion: @escaping Fina.NotificationCompletionHandler) {
        let notification = Notification(uid: "1", recieverId: "1", title: "Test", content: "Test", isRead: false)
        completion(notification)
    }
    
    func updateNotification(_ updateNotification: Fina.Notification, _ completion: Fina.BoolClosure?) {
        completion?(true)
    }
    
    func deleteNotification(_ uid: String, _ completion: Fina.BoolClosure?) {
        completion?(true)
    }
    
    
}

class MockupTwoFactorAuthManager: TwoFactorAuthManager {
    var isBiometricEnabled: Bool {
        false
    }
    
    var enabledBiometricType: LAContext.BiometricType {
        .none
    }
    
    func isBiometricFastVerificationEnabled(for userId: String) -> Bool {
        false
    }
    
    func setupBiometricEnabled(for userId: String, _ enabled: Bool) {
    
    }
    
    func resetBiometricAccess() {
        
    }
    
    func authorizeBiometric(for userId: String, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    func authorizeWithCodePassword(required codePassword: Data, entered password: String, _ completion: @escaping Fina.BoolClosure) {
        completion(true)
    }
    
    
}

class MockupMediaManager: MediaManager {
    
    func fetchImage(for uid: String, _ completion: @escaping Fina.ImageCompletionHandler) {
        completion(nil)
    }
    
    func setImage(for uid: String, _ image: UIImage, _ completion: @escaping Fina.ImageCompletionHandler) {
        completion(nil)
    }
    
}

class MockupManagerFactory: ManagerFactory {
    
    var authManager: Fina.AuthManager = MockupAuthManager()
    
    var twoFactorAuthManager: Fina.TwoFactorAuthManager = MockupTwoFactorAuthManager()
    
    var userManager: Fina.UserManager = MockupUserManager()
    
    var cardsManager: Fina.CardsManager = MockupCardsManager()
    
    var bankAccountsManager: Fina.BankAccountsManager = MockupBankAccountsManager()
    
    var transactionsManager: Fina.TransactionsManager = MockupTransactionsManager()
    
    var creditsManager: Fina.CreditsManager = MockupCreditsManager()
    
    var creditScheduleManager: Fina.CreditScheduleManager = MockupCreditScheduleManager()
    
    var notificationsManager: Fina.NotificationsManager = MockupNotificationsManager()
    
    var mediaManager: Fina.MediaManager = MockupMediaManager()
    
    lazy var transactionEngine: Fina.TransactionEngine = TransactionEngine(bankAccountManager: bankAccountsManager, transactionManager: transactionsManager, creditsManager: creditsManager, userManager: userManager, creditScheduleManager: creditScheduleManager, notificationsManager: notificationsManager)
    
}
