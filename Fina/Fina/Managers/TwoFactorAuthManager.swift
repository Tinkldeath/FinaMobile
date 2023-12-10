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

final class TwoFactorAuthManager {
    
    private var context: LAContext = LAContext()
    private let keychain = KeychainWrapper.standard
    
    var isBiometricEnabled: Bool {
        return context.biometricType != .none
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
    
    func requestBiometric(for userId: String, _ completion: @escaping BoolClosure) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "\(context.biometricType.rawValue) for code-password") { [weak self] granted, error in
            completion(granted && error == nil)
            self?.context = LAContext()
        }
    }
}
