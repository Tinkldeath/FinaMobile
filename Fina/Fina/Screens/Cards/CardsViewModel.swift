//
//  CardsViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import RxSwift


final class CardsViewModel {
    
    let cardsRelay = BehaviorRelay<[Card]>(value: [])
    
    let cardsManager: CardsManager
    let accountsManager: BankAccountsManager
    let authManager: AuthManager
    let userManager: UserManager
    let disposeBag = DisposeBag()
    
    init(factory: ManagerFactory) {
        self.cardsManager = factory.cardsManager
        self.accountsManager = factory.bankAccountsManager
        self.authManager = factory.authManager
        self.userManager = factory.userManager
    }
    
    func fetch() {
        cardsManager.userCards.asDriver().drive(onNext: { [weak self] cards in
            self?.cardsRelay.accept(cards)
        }).disposed(by: disposeBag)
    }
    
    func observeBalance(for accountId: String, _ observer: @escaping BalanceClosure) {
        accountsManager.fetchBalance(for: accountId) { balance, currency in
            guard let balance = balance, let currency = currency else { observer(nil, nil); return }
            observer(balance, currency)
        }
    }
    
    func observeOwner(_ uid: String, _ observer: @escaping StringClosure) {
        guard let userId = authManager.currentUser.value else { return }
        userManager.getUser(uid: userId) { user in
            guard let user = user else { return }
            observer(user.name)
        }
    }
}
