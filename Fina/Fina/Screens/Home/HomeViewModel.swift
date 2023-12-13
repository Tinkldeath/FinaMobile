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
    
    typealias BankAccountComponents = (bankAccount: BankAccount, card: Card)
    
    let currenciesRelay = BehaviorRelay<[Currency]>(value: Currency.displayCurrencies)
    let accountsRelay = BehaviorRelay<[BankAccount]>(value: [])
    let bankAccountInfoRelay = PublishRelay<BankAccountComponents>()
    
    let bankAccountsManager: BankAccountsManager
    let cardsManager: CardsManager
    private let disposeBag = DisposeBag()
    
    init(factory: ManagerFactory) {
        self.bankAccountsManager = factory.bankAccountsManager
        self.cardsManager = factory.cardsManager
    }

    func fetch() {
        bankAccountsManager.userBankAccounts.asDriver().drive(onNext: { [weak self] accounts in
            self?.accountsRelay.accept(accounts)
        }).disposed(by: disposeBag)
    }
    
    func didSelectBankAccount(_ bankAccount: BankAccount) {
        guard let card = cardsManager.userCards.value.first(where: { $0.bankAccountId == bankAccount.uid }) else { return }
        bankAccountInfoRelay.accept((bankAccount, card))
    }
}
