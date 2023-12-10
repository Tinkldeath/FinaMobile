//
//  AuthManager.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import FirebaseAuth
import RxRelay

typealias AuthCompletionHandler = (Bool, String?) -> Void

final class AuthManager {
    
    let currentUser = BehaviorRelay<User?>(value: nil)
    
    private let auth = Auth.auth()
    
    init() {
        guard let _ = auth.currentUser?.uid else { auth.signInAnonymously(); return }
    }
    
    func signUp(_ input: UserInput, _ completion: @escaping AuthCompletionHandler) {
        auth.createUser(withEmail: input.email, password: input.password) { result, error in
            guard error == nil else { completion(false, error?.localizedDescription); return }
            guard let uid = result?.user.uid else { completion(false, "Unknown user"); return }
            completion(true, uid)
        }
    }
    
    func signIn(_ input: UserInput, _ completion: @escaping AuthCompletionHandler) {
        auth.signIn(withEmail: input.email, password: input.password) { result, error in
            guard error == nil else { completion(false, error?.localizedDescription); return }
            guard let uid = result?.user.uid else { completion(false, "Unknown user"); return }
            completion(true, uid)
        }
    }
}

extension AuthManager {
        
    struct UserInput {
        var email: String
        var password: String
    }
}
