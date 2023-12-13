//
//  TransactionEngine.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxSwift

final class TransactionEngine {
    
    // MARK: - Managers
    private let bankAccountManager: BankAccountsManager
    private let transactionManager: TransactionsManager
    private let creditsManager: CreditsManager
    private let userManager: UserManager
    private let creditScheduleManager: CreditScheduleManager
    private let notificationsManager: NotificationsManager
    
    // MARK: - Revert properties
    private var firstPreviousBankAccountState: BankAccount?
    private var secondPreviousBankAccountState: BankAccount?
    private var transactionId: String?
    
    private let disposeBag = DisposeBag()
    
    init(bankAccountManager: BankAccountsManager, transactionManager: TransactionsManager, creditsManager: CreditsManager, userManager: UserManager, creditScheduleManager: CreditScheduleManager, notificationsManager: NotificationsManager) {
        self.bankAccountManager = bankAccountManager
        self.transactionManager = transactionManager
        self.creditsManager = creditsManager
        self.userManager = userManager
        self.creditScheduleManager = creditScheduleManager
        self.notificationsManager = notificationsManager
    }
    
    func addCredit(credit: Credit, schedule: [CreditSchedule], to bankAccount: BankAccount, _ completion: BoolClosure? = nil) {
        guard credit.sum > 0 else { completion?(false); return }
        creditsManager.createCredit(credit) { [weak self] creditId in
            guard let creditId = creditId, var user = self?.userManager.currentUser.value else { completion?(false); return }
            self?.creditScheduleManager.createSchedule(creditId: creditId, scheduleItems: schedule, { scheduleIds in
                guard !scheduleIds.isEmpty else { self?.revertCredit(creditId); completion?(false); return }
                var creditToUpdate = credit
                creditToUpdate.uid = creditId
                creditToUpdate.schedule = scheduleIds
                self?.creditsManager.updateCredit(creditToUpdate, { updated in
                    guard updated else { self?.revertCredit(creditId); completion?(false); return }
                    user.credits.append(creditId)
                    self?.userManager.updateUser(user, { updated in
                        guard updated else { self?.revertCredit(creditId); completion?(false); return }
                        let bynSum = Currency.exchange(amount: credit.sum, from: credit.currency, to: .byn)
                        guard bynSum > 0 else { self?.revertCredit(creditId); completion?(false); return }
                        let recieveSum = Currency.exchange(amount: bynSum, from: .byn, to: bankAccount.currency)
                        guard bankAccount.balance + recieveSum < Double.greatestFiniteMagnitude else { self?.revertCredit(creditId); completion?(false); return }
                        var bankAccountToUpdate = bankAccount
                        bankAccountToUpdate.balance += recieveSum
                        var transaction = Transaction(uid: "", transactionType: .obtainingCredit, recieverBankAccount: bankAccountToUpdate.uid, sum: credit.sum, currency: credit.currency, date: Date.now, isCompleted: false)
                        self?.transactionManager.createTransaction(transaction, { transactionId in
                            guard let transactionId = transactionId else { self?.revertCredit(creditId); completion?(false); return }
                            transaction.uid = transactionId
                            self?.transactionId = transactionId
                            self?.firstPreviousBankAccountState = bankAccount
                            self?.bankAccountManager.updateBankAccount(bankAccountToUpdate, { completed in
                                guard completed else { self?.revert(); self?.revertCredit(creditId); completion?(false); return }
                                transaction.isCompleted = true
                                self?.transactionManager.updateTransaction(transaction, { completed in
                                    guard completed else { self?.revert(); self?.revertCredit(creditId); completion?(false); return }
                                    self?.firstPreviousBankAccountState = nil
                                    self?.secondPreviousBankAccountState = nil
                                    self?.transactionId = nil
                                    self?.notifyUser(bankAccount.ownerId, "New credit added", "You've added new credit with sum \(credit.currency.stringAmount(credit.sum)) and duration \(credit.durationMonths) months to \(Ciper.unseal(bankAccount.number))")
                                })
                            })
                        })
                    })
                })
            })
        }
    }
    
    func autoCreditPayment(for creditId: String) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            let dateNowComponents = Date.now.baseComponents()
            self?.creditsManager.fetchCredit(creditId) { credit in
                guard let credit = credit else { return }
                for scheduleId in credit.schedule {
                    self?.creditScheduleManager.fetchSchedule(scheduleId, { schedule in
                        guard let schedule = schedule, !schedule.isPayed else { return }
                        let scheduleComponents = schedule.date.baseComponents()
                        guard dateNowComponents.day < scheduleComponents.day, dateNowComponents.month == scheduleComponents.month,  dateNowComponents.year == scheduleComponents.year else { return }
                        if dateNowComponents.day == scheduleComponents.day {
                            self?.autoPaymentForCreditScheduleAttempt(credit, schedule)
                        } else {
                            self?.setOverbayForCreditSchedule(credit, schedule, dateNowComponents) { schedule in
                                guard let schedule = schedule else { return }
                                self?.autoPaymentForCreditScheduleAttempt(credit, schedule)
                            }
                        }
                    })
                }
                self?.creditScheduleManager.observeSchedule(for: credit, { schedule in
                    for scheduleItem in schedule {
                        guard scheduleItem.isPayed else { return }
                    }
                    var copy = credit
                    copy.isPayed = true
                    self?.creditsManager.updateCredit(copy, { completed in
                        guard completed else { print("WARNING: Must set credit \(credit.uid) to payed but did not set"); return }
                    })
                })
            }
        }
    }
    
    func addAutoPaymentCreditsObserver() {
        creditsManager.userCreditsRelay.subscribe(onNext: { [weak self] credits in
            credits.forEach({ self?.autoCreditPayment(for: $0.uid) })
        }).disposed(by: disposeBag)
    }
    
    func payForCreditSchedule(credit: Credit, schedule: CreditSchedule, _ completion: BoolClosure? = nil) {
        bankAccountManager.fetchBankAccount(credit.bankAccountId) { [weak self] bankAccount in
            guard var bankAccount = bankAccount else { completion?(false); return }
            let paymentSum = Currency.exchange(amount: schedule.totalSum, from: credit.currency, to: bankAccount.currency)
            guard bankAccount.balance - paymentSum >= 0 else { completion?(false); return }
            bankAccount.balance -= paymentSum
            self?.bankAccountManager.updateBankAccount(bankAccount, { completed in
                guard completed else { completion?(false); return }
                var scheduleToUpdate = schedule
                scheduleToUpdate.isPayed = true
                self?.creditScheduleManager.updateSchedule(scheduleToUpdate) { updated in
                    guard updated else { completion?(false); return }
                    let transaction = Transaction(uid: "", transactionType: .creditPayment, senderBankAccount: credit.bankAccountId, recieverBankAccount: nil, sum: paymentSum, currency: bankAccount.currency, date: Date.now, isCompleted: true)
                    self?.transactionManager.createTransaction(transaction, { transactionId in
                        guard let _ = transactionId else { completion?(false); return }
                        self?.notifyUser(credit.ownerId, "Credit payment succeed", "Credit payment in the amount of \(credit.currency.stringAmount(scheduleToUpdate.totalSum)) for payment date \(scheduleToUpdate.date.formatted()) is successfully payed")
                        completion?(true)
                    })
                }
            })
        }
    }
    
    func transfer(from fromBankAccountId: String, to toBankAccountId: String, sum: Double, currency: Currency, _ completion: BoolClosure? = nil) {
        let bynSum = Currency.exchange(amount: sum, from: currency, to: .byn)
        let limitedSum = Currency.exchange(amount: bynSum, from: .byn, to: .usd)
        guard limitedSum < 10000, bynSum >= 5.0 else { completion?(false); return } // Перевод не превышает сумму в 10000$ и не менее 5 BYN
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
                            self?.completeTransaction(transaction)
                            self?.firstPreviousBankAccountState = nil
                            self?.secondPreviousBankAccountState = nil
                            self?.transactionId = nil
                            self?.checkLimit(fromBankAccountId)
                            completion?(true)
                        })
                    }
                })
            }
        }
    }
    
    func pay(from fromBankAccountId: String, sum: Double, currency: Currency, _ completion: BoolClosure? = nil) {
        let bynSum = Currency.exchange(amount: sum, from: currency, to: .byn)
        let limitedSum = Currency.exchange(amount: bynSum, from: .byn, to: .usd)
        guard limitedSum < 10000, bynSum >= 5.0 else { completion?(false); return } // Перевод не превышает сумму в 10000$ и не менее 5 BYN
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
                    self?.completeTransaction(transaction)
                    self?.firstPreviousBankAccountState = nil
                    self?.secondPreviousBankAccountState = nil
                    self?.transactionId = nil
                    self?.checkLimit(fromBankAccountId)
                    completion?(true)
                })
            })
        }
    }
    
    func topUp(to bankAccountId: String, sum: Double, currency: Currency, _ completion: BoolClosure? = nil) {
        let bynSum = Currency.exchange(amount: sum, from: currency, to: .byn)
        let limitedSum = Currency.exchange(amount: bynSum, from: .byn, to: .usd)
        guard limitedSum < 10000, bynSum >= 5.0 else { completion?(false); return } // Перевод не превышает сумму в 10000$ и не менее 5 BYN
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
                    self?.completeTransaction(transaction)
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
    
    private func revertCredit(_ uid: String) {
        creditsManager.deleteCredit(uid) { completed in
            guard completed else { fatalError("Failed to revert credit \(uid)") }
        }
        guard var user = userManager.currentUser.value, let creditIndex = user.credits.firstIndex(of: uid) else { return }
        user.credits.remove(at: creditIndex)
        userManager.updateUser(user) { completed in
            guard completed else { fatalError("Failed to revert credit \(uid)") }
        }
    }
    
    private func autoPaymentForCreditScheduleAttempt(_ credit: Credit, _ schedule: CreditSchedule) {
        bankAccountManager.fetchBankAccount(credit.bankAccountId) { [weak self] bankAccount in
            guard var bankAccount = bankAccount else { return }
            let paymentSum = Currency.exchange(amount: schedule.totalSum, from: credit.currency, to: bankAccount.currency)
            guard bankAccount.balance - paymentSum >= 0 else { return }
            bankAccount.balance -= paymentSum
            self?.bankAccountManager.updateBankAccount(bankAccount, { completed in
                guard completed else { print("WARNING: Failed to reduce bank account \(bankAccount.uid) by \(paymentSum)"); return }
                var scheduleToUpdate = schedule
                scheduleToUpdate.isPayed = true
                self?.creditScheduleManager.updateSchedule(scheduleToUpdate) { updated in
                    guard updated else { print("WARNING: Failed to update schedule \(schedule.uid) with autoPaymemnt completion"); return }
                    let transaction = Transaction(uid: "", transactionType: .creditPayment, senderBankAccount: credit.bankAccountId, recieverBankAccount: nil, sum: paymentSum, currency: bankAccount.currency, date: Date.now, isCompleted: true)
                    self?.transactionManager.createTransaction(transaction, { transactionId in
                        guard let _ = transactionId else { print("WARNING: Failed to log transaction on credit payment for schedule: \(schedule.uid)"); return }
                        self?.notifyUser(credit.ownerId, "Credit auto payment succeed", "Credit auto-payment in the amount of \(credit.currency.stringAmount(scheduleToUpdate.totalSum)) for payment date \(scheduleToUpdate.date.formatted()) is successfully payed")
                    })
                }
            })
        }
    }
    
    private func setOverbayForCreditSchedule(_ credit: Credit, _ schedule: CreditSchedule, _ nowComponents: (day: Int, month: Int, year: Int), _ completion: @escaping CreditScheduleCompletionHandler) {
        var creditToUpdate = credit
        var scheduleToUpdate = schedule
        let debtDayCounted = credit.debtDays.first { date in
            let components = date.baseComponents()
            return components.year == nowComponents.year && components.day == nowComponents.day && components.month == nowComponents.month
        }
        guard debtDayCounted == nil else { completion(schedule); return }
        creditToUpdate.debtDays.append(Date.now)
        scheduleToUpdate.overbay += (0.01 * schedule.monthPayment).toRounded()
        creditsManager.updateCredit(creditToUpdate) { [weak self] _ in
            self?.creditScheduleManager.updateSchedule(scheduleToUpdate) { updated in
                self?.notifyUser(credit.ownerId, "WARNING: Credit payment date is over", "You did not pay the loan amount for the month and received a penalty in the amount of \(credit.currency.stringAmount(scheduleToUpdate.overbay)). Please pay manually or top up your credit account balance to avoid a penalty grow later")
                completion(scheduleToUpdate)
            }
        }
    }
    
    private func completeTransaction(_ transaction: Transaction) {
        var copy = transaction
        copy.isCompleted = true
        transactionManager.updateTransaction(copy) { completed in
            guard completed else { print("WARNING: Failed to complete transaction \(transaction.uid) wich must be completed"); return }
        }
    }
    
    private func notifyUser(_ uid: String, _ title: String, _ content: String) {
        let notification = Notification(uid: "", recieverId: uid, title: title, content: content, isRead: false)
        notificationsManager.createNotification(notification) { notificationId in
            guard let notificationId = notificationId else { return }
            print("Notified user \(uid) with \(notificationId)")
        }
    }
    
    private func checkLimit(_ bankAccountId: String) {
        let (_, month, year) = Date.now.baseComponents()
        bankAccountManager.fetchBankAccount(bankAccountId) { [weak self] bankAccount in
            guard let bankAccount = bankAccount, let limit = bankAccount.monthLimit else { return }
            self?.transactionManager.fetchTransactions(for: bankAccountId, month, year) { monthTransactions in
                var sumByn = 0.0
                for transaction in monthTransactions {
                    sumByn += Currency.exchange(amount: transaction.sum, from: transaction.currency, to: .byn)
                }
                let bankAccountCurrencySum = Currency.exchange(amount: sumByn, from: .byn, to: bankAccount.currency)
                guard bankAccountCurrencySum >= limit else { return }
                self?.notifyUser(bankAccount.ownerId, "Limits warning", "It seems you've reached your limit with \(bankAccount.currency.rate)\(Ciper.unseal(bankAccount.number)) bank account. If you didn't reach the limit, please, change it in card page")
            }
        }
    }
}
