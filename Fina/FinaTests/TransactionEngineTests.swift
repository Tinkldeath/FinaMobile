//
//  TransactionEngineTests.swift
//  FinaTests
//
//  Created by Dima on 13.12.23.
//

import Foundation
import XCTest
@testable import Fina

class TransactionEngineTests: XCTestCase {
    
    var managerFactory: MockupManagerFactory!
    var transactionsEngine: TransactionEngine!
    var mockupCredit: Credit!
    var mockcupSchedule: [CreditSchedule] = []
    var mockupBankAccount: BankAccount!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let factory = MockupManagerFactory()
        managerFactory = factory
        transactionsEngine = factory.transactionEngine
        mockupCredit = Credit(uid: "1", ownerId: "1", bankAccountId: "1", durationMonths: 3, totalSum: 12000, sum: 10000, currency: .byn, paymentType: .diff, percentYear: 19, hasDebt: false, isPayed: false, dateAdded: Date.now, debtDays: [], schedule: [], guarantor: Ciper.seal("BY1234567"))
        mockupBankAccount = BankAccount(uid: "1", ownerId: "1", accountType: .creditAccount, currency: .byn, balance: 1000, dateCreated: Date.now, isBlocked: false, number: Ciper.seal("123124523512313"), contractNumber: Ciper.seal("1231245235"), iban: Ciper.seal("BY1231245235123131231231213123123123123123123123"), monthLimit: 50000)
        mockcupSchedule = [
            CreditSchedule(uid: "1", creditId: "1", date: Date.now.appendMonth(), isPayed: false, percentPayment: 200, loanPayment: 300, monthPayment: 500, overbay: 0)
        ]
    }
    
    override func tearDownWithError() throws  {
        try super.tearDownWithError()
        managerFactory = nil
        transactionsEngine = nil
        mockupCredit = nil
        mockupBankAccount = nil
    }
    
    func testValidTransaction() {
        transactionsEngine.topUp(to: "1", sum: 1000, currency: .byn) { completed in
            XCTAssertEqual(completed, true)
        }
        
        transactionsEngine.pay(from: "1", sum: 10, currency: .byn) { completed in
            XCTAssertEqual(completed, true)
        }
        
        transactionsEngine.topUp(to: "1", sum: 10000, currency: .byn) { completed in
            XCTAssertEqual(completed, true)
        }
        
        transactionsEngine.transfer(from: "1", to: "2", sum: 6, currency: .byn) { completed in
            XCTAssertEqual(completed, true)
        }
    
        transactionsEngine.autoCreditPayment(for: "1")
    
        transactionsEngine.payForCreditSchedule(credit: mockupCredit, schedule: mockcupSchedule.first!) { completed in
            XCTAssertEqual(completed, true)
        }
        
        transactionsEngine.checkLimit("1")
        
        transactionsEngine.setOverbayForCreditSchedule(mockupCredit, mockcupSchedule.first!, Date.now.baseComponents()) { schedule in
            XCTAssertNotNil(schedule)
        }
        
        transactionsEngine.completeTransaction(Transaction(uid: "1", transactionType: .transfer, senderBankAccount: nil, recieverBankAccount: nil, sum: 200, currency: .byn, date: Date.now, isCompleted: false))
        
        transactionsEngine.revert()
        
        transactionsEngine.revertCredit("1")
        
        transactionsEngine.notifyUser("1", "test", "test")
        
        transactionsEngine.checkLimit("1")
        
        transactionsEngine.autoPaymentForCreditScheduleAttempt(mockupCredit, mockcupSchedule.first!)
        
        transactionsEngine.addCredit(credit: mockupCredit, schedule: mockcupSchedule, to: mockupBankAccount) { completed in
            XCTAssertEqual(completed, true)
        }
    }
    
    func testFailingTransactions() {
        transactionsEngine.topUp(to: "1", sum: -1000, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.pay(from: "1", sum: -1000, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.transfer(from: "1", to: "2", sum: -1000, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.topUp(to: "1", sum: Double.greatestFiniteMagnitude, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.pay(from: "1", sum: Double.greatestFiniteMagnitude, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }

        transactionsEngine.transfer(from: "1", to: "2", sum: Double.greatestFiniteMagnitude, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.topUp(to: "1", sum: Double.leastNonzeroMagnitude, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.pay(from: "1", sum: Double.leastNonzeroMagnitude, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.transfer(from: "1", to: "2", sum: Double.leastNonzeroMagnitude, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.topUp(to: "1", sum: 0, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.pay(from: "1", sum: 0, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
        
        transactionsEngine.transfer(from: "1", to: "2", sum: 0, currency: .byn) { completed in
            XCTAssertEqual(completed, false)
        }
    
    }
}
