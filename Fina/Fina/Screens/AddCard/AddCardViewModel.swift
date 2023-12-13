//
//  AddCardViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay

final class AddCardViewModel {
    
    let isValidInput = BehaviorRelay<Bool>(value: false)
    let loadingRelay = PublishRelay<Void>()
    let endLoadingRelay = PublishRelay<Void>()
    let cardTypes = BehaviorRelay<[Card.CardType]>(value: Card.CardType.allCases)
    let createdRelay = PublishRelay<Void>()
    
    let cardsManager: CardsManager
    let bankAccountsManager: BankAccountsManager
    let authManager: AuthManager
    
    private var input: Input?
    private var cardType: Card.CardType?
    
    init(factory: ManagerFactory) {
        self.cardsManager = factory.cardsManager
        self.bankAccountsManager = factory.bankAccountsManager
        self.authManager = factory.authManager
    }
    
    func enterInput(_ input: Input) {
        self.input = input
        isValidInput.accept(input.isValid() && cardType != nil)
    }
    
    func selectCardType(_ cardType: Card.CardType) {
        self.cardType = cardType
        guard let input = input else { return }
        isValidInput.accept(input.isValid())
    }
    
    func addCard() {
        guard let input = input, let uid = authManager.currentUser.value, let cardType = cardType else { return }
        loadingRelay.accept(())
        let sealedCVV = Ciper.seal(input.cvv)
        let sealedPIN = Ciper.seal(input.pin)
        let sealedCardNumber = Ciper.seal(String.generateUniqueCardNumber())
        let accountNumber = String.generateAccountNumber()
        let contractNumber = Ciper.seal(String.generateContractNumber())
        let sealedAccountNumber = Ciper.seal(accountNumber)
        let iban = Ciper.seal(String.generateIBAN(for: accountNumber))
        let account = BankAccount(uid: "", ownerId: uid, accountType: cardType.associatedAccountType, currency: input.currency, balance: 0.0, dateCreated: Date.now, isBlocked: true, number: sealedAccountNumber, contractNumber: contractNumber, iban: iban)
        bankAccountsManager.createBankAccount(account) { [weak self] accountId in
            guard let accountId = accountId else { self?.endLoadingRelay.accept(()); return }
            let card = Card(uid: "", ownerId: uid, bankAccountId: accountId, cardType: cardType, title: cardType.localizedTitle, number: sealedCardNumber, expiresDate: Date.monthSinceFiveYears(), cvv: sealedCVV, pin: sealedPIN)
            self?.cardsManager.createCard(card, { created in
                guard created else { self?.endLoadingRelay.accept(()); return }
                self?.createdRelay.accept(())
            })
        }
    }
    
}

extension AddCardViewModel {
    
    struct Input {
        var currency: Currency
        var cvv: String
        var pin: String
        
        func isValid() -> Bool {
            return cvv.isValidCvv() && pin.isFourDigitPassword()
        }
    }
}
