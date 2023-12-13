//
//  DependencyInjectionTests.swift
//  FinaTests
//
//  Created by Dima on 13.12.23.
//

import Foundation
import XCTest
@testable import Fina

final class ViewModelsTests: XCTestCase {
    
    var mockupFactory: MockupManagerFactory!
    var mockupCredit: Credit!
    var mockupBankAccount: BankAccount!
    var mockupCard: Card!
    var mockupNotification: Fina.Notification!
    var mockupSchedule: CreditSchedule!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockupFactory = MockupManagerFactory()
        mockupCredit = Credit(uid: "1", ownerId: "1", bankAccountId: "1", durationMonths: 3, totalSum: 12000, sum: 10000, currency: .byn, paymentType: .diff, percentYear: 19, hasDebt: false, isPayed: false, dateAdded: Date.now, debtDays: [], schedule: [], guarantor: Ciper.seal("BY1234567"))
        mockupBankAccount = BankAccount(uid: "1", ownerId: "1", accountType: .creditAccount, currency: .byn, balance: 1000, dateCreated: Date.now, isBlocked: false, number: Ciper.seal("123124523512313"), contractNumber: Ciper.seal("1231245235"), iban: Ciper.seal("BY1231245235123131231231213123123123123123123123"), monthLimit: 50000)
        mockupCard = Card(uid: "1", ownerId: "1", bankAccountId: "1", cardType: .credit, title: "", number: Data(), expiresDate: Date.now, cvv: Data(), pin: Data())
        mockupNotification = Notification(uid: "", recieverId: "", title: "Test", content: "Test", isRead: false)
        mockupSchedule = CreditSchedule(uid: "1", creditId: "1", date: Date.now.appendMonth(), isPayed: false, percentPayment: 200, loanPayment: 300, monthPayment: 500, overbay: 0)
    }
    
    override func tearDownWithError() throws  {
        try super.tearDownWithError()
        mockupFactory = nil
        mockupCredit = nil
        mockupBankAccount = nil
        mockupCard = nil
        mockupNotification = nil
        mockupSchedule = nil
    }
    
    func testCase() {
        let chartsViewModel = ChartsViewModel(factory: mockupFactory)
        XCTAssertTrue(chartsViewModel.bankAccountsManager === mockupFactory.bankAccountsManager)
        
        chartsViewModel.fetch()
        
        let notificationsViewModel = NotificationsViewModel(factory: mockupFactory)
        XCTAssertTrue(notificationsViewModel.notificationsManager === mockupFactory.notificationsManager)
        
        notificationsViewModel.read(mockupNotification)
        
        let creditDetailsViewModel = CreditDetailsViewModel(credit: mockupCredit, factory: mockupFactory)
        XCTAssertTrue(creditDetailsViewModel.bankAccountManager === mockupFactory.bankAccountsManager)
        XCTAssertTrue(creditDetailsViewModel.creditsManager === mockupFactory.creditsManager)
        XCTAssertTrue(creditDetailsViewModel.scheduleManager === mockupFactory.creditScheduleManager)
        
        creditDetailsViewModel.fetch()
        creditDetailsViewModel.payForSchedule(schedule: mockupSchedule)
        
        let addCreditViewModel = AddCreditViewModel(bankAccount: mockupBankAccount, factory: mockupFactory)
        XCTAssertTrue(addCreditViewModel.userManager === mockupFactory.userManager)
        XCTAssertTrue(addCreditViewModel.creditScheduleManager === mockupFactory.creditScheduleManager)
        XCTAssertTrue(addCreditViewModel.transactionEngine === mockupFactory.transactionEngine)
        
        addCreditViewModel.didEnterInput(.init(sum: 500, durationMonths: 12, paymentType: .diff, guarantorPassportId: "BY1234567"))
        let agreements = addCreditViewModel.generateAgreements()
        addCreditViewModel.addCredit()
        XCTAssertTrue(agreements.isEmpty)
        
        let creditsViewModel = CreditsViewModel(factory: mockupFactory)
        XCTAssertTrue(creditsViewModel.creditsManager === mockupFactory.creditsManager)
        
        creditsViewModel.fetch()
        
        let cardDetailsViewModel = CardDetailsViewModel(mockupCard, factory: mockupFactory)
        XCTAssertTrue(cardDetailsViewModel.userManager === mockupFactory.userManager)
        XCTAssertTrue(cardDetailsViewModel.bankAccountsManager === mockupFactory.bankAccountsManager)
        XCTAssertTrue(cardDetailsViewModel.transactionsEngine === mockupFactory.transactionEngine)
        
        cardDetailsViewModel.topUp(500)
        cardDetailsViewModel.pay(500)
        cardDetailsViewModel.transfer(300, "1")
        
        let addCardViewModel = AddCardViewModel(factory: mockupFactory)
        XCTAssertTrue(addCardViewModel.cardsManager === mockupFactory.cardsManager)
        XCTAssertTrue(addCardViewModel.bankAccountsManager === mockupFactory.bankAccountsManager)
        XCTAssertTrue(addCardViewModel.authManager === mockupFactory.authManager)
        
        addCardViewModel.selectCardType(.credit)
        addCardViewModel.enterInput(.init(currency: .byn, cvv: "123", pin: "1234"))
        addCardViewModel.addCard()
        
        let homeViewModel = HomeViewModel(factory: mockupFactory)
        XCTAssertTrue(homeViewModel.cardsManager === mockupFactory.cardsManager)
        XCTAssertTrue(homeViewModel.bankAccountsManager === mockupFactory.bankAccountsManager)
        
        homeViewModel.fetch()
        homeViewModel.didSelectBankAccount(mockupBankAccount)
        
        let profileViewModel = ProfileViewModel(factory: mockupFactory)
        XCTAssertTrue(profileViewModel.userManager === mockupFactory.userManager)
        XCTAssertTrue(profileViewModel.authManager === mockupFactory.authManager)
        XCTAssertTrue(profileViewModel.creditsManager === mockupFactory.creditsManager)
        XCTAssertTrue(profileViewModel.mediaManager === mockupFactory.mediaManager)
        
        profileViewModel.fetch()
        profileViewModel.changeEmail("mail@mail.ru")
        profileViewModel.changePassword("Password123")
        profileViewModel.changeCodePassword("1234")
        profileViewModel.deleteAccount { deleted in
            XCTAssertEqual(deleted, true)
        }
        profileViewModel.logout()
        
        let cardsViewModel = CardsViewModel(factory: mockupFactory)
        XCTAssertTrue(cardsViewModel.cardsManager === mockupFactory.cardsManager)
        XCTAssertTrue(cardsViewModel.accountsManager === mockupFactory.bankAccountsManager)
        XCTAssertTrue(cardsViewModel.authManager === mockupFactory.authManager)
        XCTAssertTrue(cardsViewModel.userManager === mockupFactory.userManager)
        
        cardsViewModel.fetch()
        cardsViewModel.observeBalance(for: "1") { balance, currency in
            XCTAssertNotNil(balance)
            XCTAssertNotNil(currency)
        }
        
        let twoFactorAuthViewModel = TwoFactorAuthViewModel(factory: mockupFactory)
        XCTAssertTrue(twoFactorAuthViewModel.userManager === mockupFactory.userManager)
        XCTAssertTrue(twoFactorAuthViewModel.twoFactorAuthManager === mockupFactory.twoFactorAuthManager)
        XCTAssertTrue(twoFactorAuthViewModel.authManager === mockupFactory.authManager)
        
        twoFactorAuthViewModel.enterInput("1234")
        twoFactorAuthViewModel.authorize()
        twoFactorAuthViewModel.authorizeBiometric()
        twoFactorAuthViewModel.fastBiometric()
        twoFactorAuthViewModel.setEnableBiometric(true)
        twoFactorAuthViewModel.logout()
        
        let signUpViewModel = SignUpViewModel(factory: mockupFactory)
        XCTAssertTrue(signUpViewModel.authManager === mockupFactory.authManager)
        XCTAssertTrue(signUpViewModel.userManager === mockupFactory.userManager)
        XCTAssertTrue(signUpViewModel.twoAuthFactorManager === mockupFactory.twoFactorAuthManager)
        
        signUpViewModel.enterInput(.init(passportIdentifier: "BY1234567", fullName: "Name", email: "mail@mail.ru", password: "Password123", passwordConfirm: "Password123", codePassword: "1234"))
        signUpViewModel.setEnableBiometric(true)
        signUpViewModel.signUp()
        
        let signInViewModel = SignInViewModel(factory: mockupFactory)
        XCTAssertTrue(signInViewModel.authManager === mockupFactory.authManager)
        
        signInViewModel.enterInput(.init(email: "mail@mail.ru", password: "Password123"))
        signInViewModel.signIn()
    }
    
}
