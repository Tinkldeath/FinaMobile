//
//  AddCreditViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay

final class AddCreditViewModel: BaseLoadingViewModel {
    
    let isValidInput = BehaviorRelay<Bool>(value: false)
    let totalSumRelay = PublishRelay<Double>()
    let scheduleRelay = BehaviorRelay<[CreditSchedule]>(value: [])
    
    private let userManager = ManagerFactory.shared.userManager
    private let creditScheduleManager = ManagerFactory.shared.creditScheduleManager
    private let transactionEngine = ManagerFactory.shared.transactionEngine
    
    private let calculator = CreditCalculator()
    private var input: Input?
    private var results: CreditCountResults?
    
    private var bankAccount: BankAccount
    
    init(bankAccount: BankAccount) {
        self.bankAccount = bankAccount
    }
    
    func didEnterInput(_ input: Input) {
        isValidInput.accept(input.isValid())
        guard input.isValid() else { return }
        let results = calculator.count(loanSum: input.sum, loanPercent: 19, durationMonths: input.durationMonths, paymentType: input.paymentType)
        let schedule = CreditSchedule.fromCalculatorResults(results)
        scheduleRelay.accept(schedule)
        totalSumRelay.accept(results.totalSum)
        self.results = results
        self.input = input
    }
    
    func generateAgreements() -> String {
        guard let borrowerName = userManager.currentUser.value?.name, let input = input else { return "" }
        print(borrowerName)
        return Constants.Credit.generateCreditAgreement(borrowerName, Currency.byn.stringAmount(input.sum), input.durationMonths, input.guarantorPassportId)
    }
    
    func addCredit(_ completion: BoolClosure? = nil) {
        guard let input = input, let results = results else { return }
        let schedule = scheduleRelay.value
        let credit = Credit(uid: "", ownerId: bankAccount.ownerId, bankAccountId: bankAccount.uid, durationMonths: input.durationMonths, totalSum: results.totalSum, sum: input.sum, currency: .byn, paymentType: input.paymentType, percentYear: 19, hasDebt: false, isPayed: false, dateAdded: Date.now, debtDays: [], schedule: [], guarantor: Ciper.seal(input.guarantorPassportId))
        loadingRelay.accept(())
        transactionEngine.addCredit(credit: credit, schedule: schedule, to: bankAccount) { [weak self] completed in
            self?.loadingRelay.accept(())
            completion?(completed)
        }
    }
    
}

extension AddCreditViewModel {
    
    struct Input {
        var sum: Double
        var durationMonths: Int
        var paymentType: Credit.PaymentType
        var guarantorPassportId: String
        
        func isValid() -> Bool {
            guard sum >= 1000, sum <= 100_000, durationMonths >= 2, durationMonths <= 60, guarantorPassportId.isBelarusPassportNumber() else { return false }
            return true
        }
    }
}
