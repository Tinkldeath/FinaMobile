//
//  HomeViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import RxSwift

final class HomeViewModel {
    
    let currenciesRelay = BehaviorRelay<[Currency]>(value: Currency.displayCurrencies)
    let accountsRelay = BehaviorRelay<[BankAccount]>(value: [])
    
    private let bankAccountsManager = ManagerFactory.shared.bankAccountsManager
    private let disposeBag = DisposeBag()

    func fetch() {
        bankAccountsManager.userBankAccounts.asDriver().drive(onNext: { [weak self] accounts in
            self?.accountsRelay.accept(accounts)
        }).disposed(by: disposeBag)
    }
    
}
