//
//  SignUpViewModel.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import RxRelay


final class SignUpViewModel: BaseLoadingViewModel {
    
    let isValidInput = BehaviorRelay<Bool>(value: false)
    let enableBiometricEvent = PublishRelay<Void>()
    let prepareEvent = PublishRelay<Void>()
    
    let authManager: AuthManager
    let userManager: UserManager
    let twoAuthFactorManager: TwoFactorAuthManager
    private var input: Input?
    
    init(factory: ManagerFactory) {
        self.authManager = factory.authManager
        self.userManager = factory.userManager
        self.twoAuthFactorManager = factory.twoFactorAuthManager
    }

    func enterInput(_ input: Input) {
        self.input = input
        isValidInput.accept(input.isValid())
    }
    
    func signUp() {
        guard let input = input else { return }
        loadingRelay.accept(())
        authManager.signUp(.init(email: input.email, password: input.password)) { [weak self] completed, uid in
            guard completed, let uid = uid else { self?.endLoadingRelay.accept(()); return }
            let sealedPassport = Ciper.seal(input.passportIdentifier)
            let sealedCodePassword = Ciper.seal(input.codePassword)
            let user = User.create(uid, input.fullName, sealedPassport, sealedCodePassword)
            self?.userManager.createUser(user, { created in
                guard created else { self?.authManager.deleteUser({ deleted in
                    self?.endLoadingRelay.accept(());
                }) ;return }
                self?.enableBiometricEvent.accept(())
            })
        }
    }
    
    func setEnableBiometric(_ enable: Bool) {
        guard twoAuthFactorManager.isBiometricEnabled, let uid = authManager.currentUser.value else { return }
        twoAuthFactorManager.setupBiometricEnabled(for: uid, enable)
        guard enable else { prepareEvent.accept(()); return }
        twoAuthFactorManager.authorizeBiometric(for: uid) { [weak self] authorized in
            guard authorized else { return }
            self?.prepareEvent.accept(())
        }
    }
}

extension SignUpViewModel {
    struct Input {
        var passportIdentifier: String
        var fullName: String
        var email: String
        var password: String
        var passwordConfirm: String
        var codePassword: String
        
        func isValid() -> Bool {
            return passportIdentifier.isBelarusPassportNumber() && !fullName.isEmpty && email.isValidEmail() && password.isValidPassword() && password == passwordConfirm && codePassword.isFourDigitPassword()
        }
    }
}
