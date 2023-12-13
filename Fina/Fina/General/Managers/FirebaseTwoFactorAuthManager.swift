//
//  TwoFactorAuthManager.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import LocalAuthentication
import SwiftKeychainWrapper

typealias BoolClosure = (Bool) -> Void

protocol TwoFactorAuthManager: AnyObject {
    var isBiometricEnabled: Bool { get }
    var enabledBiometricType: LAContext.BiometricType { get }
    
    func isBiometricFastVerificationEnabled(for userId: String) -> Bool
    func setupBiometricEnabled(for userId: String, _ enabled: Bool)
    func resetBiometricAccess()
    func authorizeBiometric(for userId: String, _ completion: @escaping BoolClosure)
    func authorizeWithCodePassword(required codePassword: Data, entered password: String, _ completion: @escaping BoolClosure)
}

final class FirebaseTwoFactorAuthManager: TwoFactorAuthManager {
    
    private var context: LAContext = LAContext()
    private let keychain = KeychainWrapper.standard
    
    var isBiometricEnabled: Bool {
        return context.biometricType != .none
    }
    
    var enabledBiometricType: LAContext.BiometricType {
        return context.biometricType
    }
    
    func isBiometricFastVerificationEnabled(for userId: String) -> Bool {
        return keychain.bool(forKey: userId) ?? false
    }
    
    func setupBiometricEnabled(for userId: String, _ enabled: Bool) {
        keychain.set(enabled, forKey: userId)
    }
    
    func resetBiometricAccess() {
        keychain.removeAllKeys()
    }
    
    func authorizeBiometric(for userId: String, _ completion: @escaping BoolClosure) {
        guard isBiometricEnabled, isBiometricFastVerificationEnabled(for: userId) else { completion(false); return }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "\(context.biometricType.rawValue) for code-password") { [weak self] granted, error in
            completion(granted && error == nil)
            self?.context = LAContext()
        }
    }
    
    func authorizeWithCodePassword(required codePassword: Data, entered password: String, _ completion: @escaping BoolClosure) {
        let unsealed = Ciper.unseal(codePassword)
        completion(unsealed == password)
    }
}
