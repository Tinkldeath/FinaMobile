//
//  ProfileViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import RxSwift


final class ProfileViewModel {
    
    let userImageRelay = BehaviorRelay<UIImage?>(value: nil)
    let userNameRelay = BehaviorRelay<String>(value: "")
    let userEmailRelay = BehaviorRelay<String>(value: "")
    let actionsRelay = BehaviorRelay<[ProfileAction]>(value: ProfileAction.allCases)
    
    private let userManager = ManagerFactory.shared.userManager
    private let authManager = ManagerFactory.shared.authManager
    private let disposeBag = DisposeBag()
    
    func fetch() {
        userManager.currentUser.asDriver().drive(onNext: { [weak self] user in
            guard let user = user, let uid = self?.authManager.currentUser.value, let userEmail = self?.authManager.currentUserEmail, user.uid == uid else { return }
            self?.userEmailRelay.accept(userEmail)
            self?.userNameRelay.accept(user.name)
        }).disposed(by: disposeBag)
    }
    
    func didSelectAction(_ action: ProfileAction) {
        
    }
    
}
