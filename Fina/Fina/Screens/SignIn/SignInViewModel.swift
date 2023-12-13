//
//  SignInViewModel.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import RxRelay

final class SignInViewModel: BaseLoadingViewModel {
    
    let isValidInput = BehaviorRelay<Bool>(value: false)
    let twoFactorRelay = PublishRelay<Void>()
    
    private var input: Input?
    
    let authManager: AuthManager
    
    init(factory: ManagerFactory) {
        self.authManager = factory.authManager
    }
    
    func signIn() {
        guard let input = input else { return }
        loadingRelay.accept(())
        authManager.signIn(.init(email: input.email, password: input.password)) { [weak self] signedIn, uid in
            guard signedIn, let _ = uid else { return }
            self?.endLoadingRelay.accept(())
            self?.twoFactorRelay.accept(())
        }
    }
    
    func enterInput(_ input: Input) {
        self.input = input
        isValidInput.accept(input.isValid())
    }
    
}

extension SignInViewModel {
    
    struct Input {
        var email: String
        var password: String
        
        func isValid() -> Bool {
            return email.isValidEmail() && password.isValidPassword()
        }
    }
}
