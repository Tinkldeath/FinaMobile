//
//  TransactionEngine.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

final class TransactionEngine {
    
    private let bankAccountManager: BankAccountsManager
    
    private let transactionManager: TransactionsManager
    
    private var firstPreviousBankAccountState: BankAccount?
    
    private var secondPreviousBankAccountState: BankAccount?
    
    private var transactionId: String?
    
    init(bankAccountManager: BankAccountsManager, transactionManager: TransactionsManager) {
        self.bankAccountManager = bankAccountManager
        self.transactionManager = transactionManager
    }
    
    func transfer(from fromBankAccountId: String, to toBankAccountId: String, sum: Double, currency: Currency, _ completion: BoolClosure? = nil) {
        bankAccountManager.fetchBankAccount(fromBankAccountId) { [weak self] fromBankAccount in
            guard var fromBankAccount = fromBankAccount else { completion?(false); return }
            self?.firstPreviousBankAccountState = fromBankAccount
            self?.bankAccountManager.fetchBankAccount(toBankAccountId) { toBankAccount in
                guard var toBankAccount = toBankAccount else { completion?(false); return }
                self?.secondPreviousBankAccountState = toBankAccount
                // Перевести баланс в буны
                let fromBankAccountBalance = Currency.exchange(amount: fromBankAccount.balance, from: fromBankAccount.currency, to: .byn).toRounded()
                // Перевести сумму перевода в буны
                let transferSum = Currency.exchange(amount: sum, from: currency, to: .byn).toRounded()
                // Перевести баланс в буны
                let toBankAccountBalance = Currency.exchange(amount: toBankAccount.balance, from: toBankAccount.currency, to: .byn).toRounded()
                // Проверить лимиты счетов
                guard fromBankAccountBalance - transferSum >= 0, toBankAccountBalance + transferSum < Double.greatestFiniteMagnitude else { self?.revert(); completion?(false); return }
                // Уменьшить баланс
                fromBankAccount.balance -= Currency.exchange(amount: transferSum, from: .byn, to: fromBankAccount.currency).toRounded()
                // Уменьшить пополнить баланс
                toBankAccount.balance += Currency.exchange(amount: transferSum, from: .byn, to: toBankAccount.currency).toRounded()
                // Создать транзакцию
                var transaction = Transaction(uid: "", transactionType: .transfer, senderBankAccount: fromBankAccountId, recieverBankAccount: toBankAccountId, sum: sum, currency: currency, date: Date.now, isCompleted: false)
                self?.transactionManager.createTransaction(transaction, { uid in
                    guard let uid = uid else { self?.revert(); completion?(false); return }
                    transaction.uid = uid
                    self?.transactionId = uid
                    // Обновить данные, при ошибке откатиться на начало
                    self?.bankAccountManager.updateBankAccount(fromBankAccount) { completed in
                        guard completed else { self?.revert(); completion?(false); return }
                        self?.bankAccountManager.updateBankAccount(toBankAccount, { completed in
                            guard completed else { self?.revert(); completion?(false); return }
                            transaction.isCompleted = true
                            self?.transactionManager.updateTransaction(transaction, { completed in
                                guard completed else { self?.revert(); completion?(false); return }
                                self?.firstPreviousBankAccountState = nil
                                self?.secondPreviousBankAccountState = nil
                                self?.transactionId = nil
                                completion?(true)
                            })
                        })
                    }
                })
            }
        }
    }
    
    func pay(from fromBankAccountId: String, sum: Double, currency: Currency, _ completion: BoolClosure? = nil) {
        var transaction = Transaction(uid: "", transactionType: .payment, senderBankAccount: fromBankAccountId, recieverBankAccount: nil, sum: sum, currency: currency, date: Date.now, isCompleted: false)
        transactionManager.createTransaction(transaction) { [weak self] uid in
            guard let uid = uid else { self?.revert(); completion?(false); return }
            transaction.uid = uid
            self?.transactionId = uid
            self?.bankAccountManager.fetchBankAccount(fromBankAccountId, { fromBankAccount in
                guard var fromBankAccount = fromBankAccount else { self?.revert(); completion?(false); return }
                self?.firstPreviousBankAccountState = fromBankAccount
                let fromBankAccountBalance = Currency.exchange(amount: fromBankAccount.balance, from: fromBankAccount.currency, to: .byn).toRounded()
                let sumToByn = Currency.exchange(amount: sum, from: currency, to: .byn).toRounded()
                guard fromBankAccountBalance - sumToByn >= 0 else { self?.revert(); completion?(false); return }
                fromBankAccount.balance -= Currency.exchange(amount: sumToByn, from: .byn, to: fromBankAccount.currency).toRounded()
                self?.bankAccountManager.updateBankAccount(fromBankAccount, { completed in
                    guard completed else { self?.revert(); completion?(false); return }
                    self?.firstPreviousBankAccountState = nil
                    self?.secondPreviousBankAccountState = nil
                    self?.transactionId = nil
                    completion?(true)
                })
            })
        }
    }
    
    func topUp(to bankAccountId: String, sum: Double, currency: Currency, _ completion: BoolClosure? = nil) {
        var transaction = Transaction(uid: "", transactionType: .income, senderBankAccount: nil, recieverBankAccount: bankAccountId, sum: sum, currency: currency, date: Date.now, isCompleted: false)
        transactionManager.createTransaction(transaction) { [weak self] uid in
            guard let uid = uid else { self?.revert(); completion?(false); return }
            transaction.uid = uid
            self?.transactionId = uid
            self?.bankAccountManager.fetchBankAccount(bankAccountId, { bankAccount in
                guard var bankAccount = bankAccount else { self?.revert(); completion?(false); return }
                self?.firstPreviousBankAccountState = bankAccount
                let bankAccountBalance = Currency.exchange(amount: bankAccount.balance, from: bankAccount.currency, to: .byn).toRounded()
                let sumToByn = Currency.exchange(amount: sum, from: currency, to: .byn).toRounded()
                guard bankAccountBalance + sumToByn < Double.greatestFiniteMagnitude else { self?.revert(); completion?(false); return }
                bankAccount.balance += Currency.exchange(amount: sumToByn, from: .byn, to: bankAccount.currency).toRounded()
                self?.bankAccountManager.updateBankAccount(bankAccount, { completed in
                    guard completed else { self?.revert(); completion?(false); return }
                    self?.firstPreviousBankAccountState = nil
                    self?.secondPreviousBankAccountState = nil
                    self?.transactionId = nil
                    completion?(true)
                })
            })
        }
    }
    
}

fileprivate extension TransactionEngine {
    
    private func revert() {
        if let first = firstPreviousBankAccountState {
            bankAccountManager.updateBankAccount(first) { completed in
                guard completed else { fatalError("Failed to revert bank account state \(first)") }
            }
        }
        if let second = secondPreviousBankAccountState {
            bankAccountManager.updateBankAccount(second) { completed in
                guard completed else { fatalError("Failed to revert bank account state \(second)") }
            }
        }
        if let transactionId = transactionId {
            transactionManager.deleteTransaction(transactionId) { completed in
                guard completed else { fatalError("Failed to delete transaction \(transactionId)") }
            }
        }
        firstPreviousBankAccountState = nil
        secondPreviousBankAccountState = nil
        transactionId = nil
    }
}
