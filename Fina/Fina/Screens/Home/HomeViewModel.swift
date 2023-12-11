//
//  HomeViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay

final class HomeViewModel {
    
    let currenciesRelay = BehaviorRelay<[Currency]>(value: Currency.displayCurrencies)

}
