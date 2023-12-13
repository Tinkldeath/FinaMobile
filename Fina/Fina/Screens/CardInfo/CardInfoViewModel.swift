//
//  CardInfoViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay


final class CardInfoViewModel {
    
    let infoRelay = BehaviorRelay<[CardInfo]>(value: [])
    
    init(card: Card, account: BankAccount) {
        let info: [CardInfo] = [
            CardInfo(title: "Card number", infoContent: Ciper.unseal(card.number)),
            CardInfo(title: "Contract number", infoContent: Ciper.unseal(account.contractNumber)),
            CardInfo(title: "Contract date", infoContent: account.dateCreated.formatted()),
            CardInfo(title: "IBAN", infoContent: Ciper.unseal(account.iban)),
            CardInfo(title: "Bank account number", infoContent: Ciper.unseal(account.number)),
            CardInfo(title: "Bank account type", infoContent: account.accountType.localizedTitle),
            CardInfo(title: "Bank account currency", infoContent: account.currency.rawValue),
            CardInfo(title: "PIN", infoContent: Ciper.unseal(card.pin)),
            CardInfo(title: "CVV", infoContent: Ciper.unseal(card.cvv))
        ]
        infoRelay.accept(info)
    }
    
}
