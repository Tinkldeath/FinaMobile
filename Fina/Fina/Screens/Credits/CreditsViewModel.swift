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
    
    let creditsManager: CreditsManager
    private let disposeBag = DisposeBag()
    
    init(factory: ManagerFactory) {
        self.creditsManager = factory.creditsManager
    }
    
    func fetch() {
        creditsManager.userCreditsRelay.asDriver().drive(onNext: { [weak self] credits in
            self?.creditsRelay.accept(credits)
        }).disposed(by: disposeBag)
    }
    
}
