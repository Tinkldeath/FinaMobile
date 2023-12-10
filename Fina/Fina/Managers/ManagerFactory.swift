//
//  ManagerFactory.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation


final class ManagerFactory {
    
    let authManager = AuthManager()
    let twoFactorAuthManager = TwoFactorAuthManager()
    let userManager = UserManager()
    
    static let shared = ManagerFactory()
    
    private init() {}
    
}
