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
    
    let currentUser = BehaviorRelay<String?>(value: nil)
    
    private let auth = Auth.auth()
    
    var isPreviouslySigned: Bool {
        return !(auth.currentUser?.isAnonymous ?? true)
    }
    
    var currentUserEmail: String? {
        return auth.currentUser?.email
    }
    
    init() {
        guard let _ = auth.currentUser?.uid else { auth.signInAnonymously(); return }
        currentUser.accept(auth.currentUser?.uid)
    }
    
    func signUp(_ input: UserInput, _ completion: @escaping AuthCompletionHandler) {
        auth.createUser(withEmail: input.email, password: input.password) { [weak self] result, error in
            guard error == nil else { completion(false, error?.localizedDescription); return }
            guard let uid = result?.user.uid else { completion(false, "Unknown user"); return }
            completion(true, uid)
            self?.currentUser.accept(uid)
        }
    }
    
    func signIn(_ input: UserInput, _ completion: @escaping AuthCompletionHandler) {
        auth.signIn(withEmail: input.email, password: input.password) { [weak self] result, error in
            guard error == nil else { completion(false, error?.localizedDescription); return }
            guard let uid = result?.user.uid else { completion(false, "Unknown user"); return }
            completion(true, uid)
            self?.currentUser.accept(uid)
        }
    }
    
    func deleteUser(_ completion: @escaping BoolClosure) {
        auth.currentUser?.delete(completion: { error in
            completion(error == nil)
        })
    }
    
    func logout(_ completion: @escaping BoolClosure) {
        do {
            try auth.signOut()
            completion(true)
        } catch {
            print(String(describing: error))
            completion(false)
        }
    }
}

extension AuthManager {
        
    struct UserInput {
        var email: String
        var password: String
    }
}
