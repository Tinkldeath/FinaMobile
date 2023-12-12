//
//  TwoFactorConfirmViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import LocalAuthentication

final class TwoFactorConfirmViewModel: BaseLoadingViewModel {
    
    let authorizedRelay = PublishRelay<Bool>()
    let isValidInput = BehaviorRelay<Bool>(value: false)
    let biometricTypeRelay = BehaviorRelay<LAContext.BiometricType?>(value: nil)
    
    private let twoFactorAuthManager = ManagerFactory.shared.twoFactorAuthManager
    private let userManager = ManagerFactory.shared.userManager
    private let authManager = ManagerFactory.shared.authManager
    
    private var codePassword: String?
    
    override init() {
        super.init()
        
        biometricTypeRelay.accept(twoFactorAuthManager.enabledBiometricType)
    }
    
    func fastBiometric() {
        guard twoFactorAuthManager.isBiometricEnabled, let uid = authManager.currentUser.value, twoFactorAuthManager.isBiometricFastVerificationEnabled(for: uid) else { return }
        twoFactorAuthManager.authorizeBiometric(for: uid) { [weak self] authorized in
            self?.authorizedRelay.accept(authorized)
        }
    }
    
    func enterInput(_ input: String) {
        self.codePassword = input
        isValidInput.accept(input.isFourDigitPassword())
    }
    
    func authorize() {
        loadingRelay.accept(())
        guard let codePassword = codePassword, let uid = authManager.currentUser.value else { return }
        userManager.getUser(uid: uid) { [weak self] user in
            guard let user = user, let requiredCodePassword = user.codePassword else { self?.endLoadingRelay.accept(()); return }
            self?.twoFactorAuthManager.authorizeWithCodePassword(required: requiredCodePassword, entered: codePassword, { authorized in
                self?.endLoadingRelay.accept(())
                self?.authorizedRelay.accept(authorized)
            })
        }
    }
    
    func authorizeBiometric() {
        guard let uid = authManager.currentUser.value, twoFactorAuthManager.isBiometricFastVerificationEnabled(for: uid) else { return }
        twoFactorAuthManager.authorizeBiometric(for: uid) { [weak self] authorized in
            self?.authorizedRelay.accept(authorized)
        }
    }
}
