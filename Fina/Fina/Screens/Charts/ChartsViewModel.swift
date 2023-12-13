//
//  ChartsViewModel.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import Foundation
import RxSwift
import RxRelay
import Charts

final class ChartsViewModel: BaseLoadingViewModel {
    
    let chartsRelay = BehaviorRelay<[ChartModel]>(value: [])
    
    let bankAccountsManager: BankAccountsManager
    let disposeBag = DisposeBag()
    
    init(factory: ManagerFactory) {
        self.bankAccountsManager = factory.bankAccountsManager
    }
    
    private var chartModels: [ChartModel] = [] {
        didSet {
            chartsRelay.accept(chartModels)
        }
    }

    func fetch() {
        loadingRelay.accept(())
        bankAccountsManager.userBankAccounts.subscribe(onNext: { [weak self] bankAccounts in
            for bankAccount in bankAccounts {
                let transactionManager = FirebaseTransactionsManager()
                transactionManager.fetchTransactions(for: bankAccount.uid) { transactions in
                    let chartModel = ChartModel(bankAccountId: bankAccount.uid, bankAccount: Ciper.unseal(bankAccount.number), currency: bankAccount.currency, transactions: transactions)
                    self?.endLoadingRelay.accept(())
                    self?.chartModels.append(chartModel)
                }
            }
        }).disposed(by: disposeBag)
    }
}
