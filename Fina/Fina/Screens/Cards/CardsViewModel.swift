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
    
    private let cardsManager = ManagerFactory.shared.cardsManager
    private let accountsManager = ManagerFactory.shared.bankAccountsManager
    private let authManager = ManagerFactory.shared.authManager
    private let userManager = ManagerFactory.shared.userManager
    private let disposeBag = DisposeBag()
    
    func fetch() {
        cardsManager.userCards.asDriver().drive(onNext: { [weak self] cards in
            self?.cardsRelay.accept(cards)
        }).disposed(by: disposeBag)
    }
    
    func observeBalance(for accountId: String, _ observer: @escaping BalanceClosure) {
        accountsManager.observeBalance(for: accountId) { balance, currency in
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
