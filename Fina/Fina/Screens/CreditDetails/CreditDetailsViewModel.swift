//
//  CreditDetailsViewModel.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import Foundation
import RxRelay

final class CreditDetailsViewModel: BaseLoadingViewModel {
    
    let creditRelay: BehaviorRelay<Credit>
    let scheduleRelay = BehaviorRelay<[CreditSchedule]>(value: [])
    let bankAccountRelay = BehaviorRelay<String>(value: "")
    
    let creditsManager: CreditsManager
    let scheduleManager: CreditScheduleManager
    let transactionEngine: TransactionEngine
    let bankAccountManager: BankAccountsManager
    
    private var credit: Credit
    
    init(credit: Credit, factory: ManagerFactory) {
        self.creditRelay = BehaviorRelay(value: credit)
        self.credit = credit
        self.creditsManager = factory.creditsManager
        self.scheduleManager = factory.creditScheduleManager
        self.transactionEngine = factory.transactionEngine
        self.bankAccountManager = factory.bankAccountsManager
    }
    
    func fetch() {
        let credit = creditRelay.value
        loadingRelay.accept(())
        creditsManager.observeCredit(credit.uid) { [weak self] credit in
            guard let credit = credit else { return }
            self?.creditRelay.accept(credit)
            self?.credit = credit
        }
        
        scheduleManager.observeSchedule(for: credit) { [weak self] schedule in
            self?.endLoadingRelay.accept(())
            self?.scheduleRelay.accept(schedule)
        }
        
        bankAccountManager.fetchBankAccount(credit.bankAccountId) { [weak self] bankAccount in
            guard let bankAccount = bankAccount else { return }
            self?.bankAccountRelay.accept(Ciper.unseal(bankAccount.number))
        }
    }
    
    func payForSchedule(schedule: CreditSchedule) {
        loadingRelay.accept(())
        transactionEngine.payForCreditSchedule(credit: credit, schedule: schedule) { [weak self] payed in
            self?.endLoadingRelay.accept(())
            guard payed else { print("Payment failed"); return }
        }
    }
    
}
