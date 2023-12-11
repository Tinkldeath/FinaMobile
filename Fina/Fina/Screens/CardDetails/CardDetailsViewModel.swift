//
//  CardDetailsViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import RxSwift

final class CardDetailsViewModel {
    
    let balanceRelay = BehaviorRelay<String?>(value: nil)
    let ownerRelay = BehaviorRelay<String?>(value: nil)
    let cardRelay: BehaviorRelay<Card>
    let transactionsRelay = BehaviorRelay<[Transaction]>(value: [])
    let bankAccountRelay = BehaviorRelay<BankAccount?>(value: nil)
    
    private let userManager = ManagerFactory.shared.userManager
    private let bankAccountsManager = ManagerFactory.shared.bankAccountsManager
    private let transactionsManager = TransactionsManager()
    private let transactionsEngine = ManagerFactory.shared.transactionEngine
    
    private let disposeBag = DisposeBag()
    
    init(_ card: Card) {
        self.cardRelay = BehaviorRelay<Card>(value: card)
        
        userManager.currentUser.asDriver().drive(onNext: { [weak self] user in
            guard let user = user else { return }
            self?.ownerRelay.accept(user.name)
        }).disposed(by: disposeBag)
        
        bankAccountsManager.observeBalance(for: card.bankAccountId) { [weak self] balance, currency in
            guard let balance = balance, let currency = currency else { return }
            self?.balanceRelay.accept(currency.stringAmount(balance))
        }
        
        bankAccountsManager.observeBankAccount(card.bankAccountId) { [weak self] account in
            self?.bankAccountRelay.accept(account)
            guard let uid = account?.uid else { return }
            self?.transactionsManager.observeTransactions(for: uid)
        }
        
        transactionsManager.transactionsRelay.asDriver().drive(onNext: { [weak self] transactions in
            self?.transactionsRelay.accept(transactions)
        }).disposed(by: disposeBag)
    }
    
    func topUp(_ amount: Double) {
        transactionsEngine.topUp(to: cardRelay.value.bankAccountId, sum: amount, currency: .byn)
    }
    
    func pay(_ amount: Double) {
        guard let bankAccount = bankAccountRelay.value else { return }
        transactionsEngine.pay(from: cardRelay.value.bankAccountId, sum: amount, currency: bankAccount.currency)
    }
    
}