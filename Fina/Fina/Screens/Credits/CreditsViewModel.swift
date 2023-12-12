//
//  CreditsViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import RxSwift

final class CreditsViewModel {
    
    let creditsRelay = BehaviorRelay<[Credit]>(value: [])
    
    private let creditsManager = ManagerFactory.shared.creditsManager
    private let transactionEngine = ManagerFactory.shared.transactionEngine
    private let disposeBag = DisposeBag()
    
    func fetch() {
        creditsManager.userCreditsRelay.asDriver().drive(onNext: { [weak self] credits in
            self?.creditsRelay.accept(credits)
        }).disposed(by: disposeBag)
    }
    
}
