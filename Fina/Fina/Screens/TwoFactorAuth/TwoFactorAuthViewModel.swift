//
//  TwoFactorAuthViewModel.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import RxRelay
import LocalAuthentication


final class TwoFactorAuthViewModel: BaseLoadingViewModel {
    
    let prepareEvent = PublishRelay<Void>()
    let isValidInput = BehaviorRelay<Bool>(value: false)
    let biometricType = BehaviorRelay<LAContext.BiometricType>(value: .none)
    let logoutEvent = PublishRelay<Void>()
    let enableBiometricEvent = PublishRelay<Void>()
    let fastBiometricEvent = PublishRelay<Void>()
    
    let userManager: UserManager
    let twoFactorAuthManager: TwoFactorAuthManager
    let authManager: AuthManager
    var codePassword: String?
    
    init(factory: ManagerFactory) {
        self.userManager = factory.userManager
        self.twoFactorAuthManager = factory.twoFactorAuthManager
        self.authManager = factory.authManager
        
        biometricType.accept(twoFactorAuthManager.enabledBiometricType)
    }
    
    func fastBiometric() {
        guard twoFactorAuthManager.isBiometricEnabled, let uid = authManager.currentUser.value, twoFactorAuthManager.isBiometricFastVerificationEnabled(for: uid) else { return }
        twoFactorAuthManager.authorizeBiometric(for: uid) { authorized in
            guard authorized else { return }
            self.prepareEvent.accept(())
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
                guard authorized else { self?.endLoadingRelay.accept(()); return }
                self?.endLoadingRelay.accept(())
                self?.enableBiometricEvent.accept(())
            })
        }
    }
    
    func authorizeBiometric() {
        guard let uid = authManager.currentUser.value, twoFactorAuthManager.isBiometricFastVerificationEnabled(for: uid) else { return }
        twoFactorAuthManager.authorizeBiometric(for: uid) { authorized in
            guard authorized else { return }
            self.prepareEvent.accept(())
        }
    }
    
    func setEnableBiometric(_ enable: Bool) {
        guard twoFactorAuthManager.isBiometricEnabled, let uid = authManager.currentUser.value else { return }
        twoFactorAuthManager.setupBiometricEnabled(for: uid, enable)
        guard enable else { prepareEvent.accept(()); return }
        twoFactorAuthManager.authorizeBiometric(for: uid) { [weak self] authorized in
            guard authorized else { return }
            self?.prepareEvent.accept(())
        }
    }
    
    func logout() {
        authManager.logout { [weak self] loggedOut in
            guard loggedOut else { return }
            self?.twoFactorAuthManager.resetBiometricAccess()
            self?.userManager.currentUser.accept(nil)
            self?.userManager.signOut()
            self?.logoutEvent.accept(())
        }
    }
}
