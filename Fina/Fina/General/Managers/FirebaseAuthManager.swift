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

protocol AuthManager: AnyObject {
    var currentUser: BehaviorRelay<String?> { get }
    var isPreviouslySigned: Bool { get }
    var currentUserEmail: String? { get }
    
    func signUp(_ input: AuthManagerUserInput, _ completion: @escaping AuthCompletionHandler)
    func signIn(_ input: AuthManagerUserInput, _ completion: @escaping AuthCompletionHandler)
    func deleteUser(_ completion: @escaping BoolClosure)
    func changeEmail(_ newEmail: String, _ completion: StringClosure?)
    func changePassword(_ newPassword: String, _ completion: BoolClosure?)
    func logout(_ completion: BoolClosure?)
}

struct AuthManagerUserInput {
    var email: String
    var password: String
}

final class FirebaseAuthManager: AuthManager {
    
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
    
    func signUp(_ input: AuthManagerUserInput, _ completion: @escaping AuthCompletionHandler) {
        auth.createUser(withEmail: input.email, password: input.password) { [weak self] result, error in
            guard error == nil else { completion(false, error?.localizedDescription); return }
            guard let uid = result?.user.uid else { completion(false, "Unknown user"); return }
            completion(true, uid)
            self?.currentUser.accept(uid)
        }
    }
    
    func signIn(_ input: AuthManagerUserInput, _ completion: @escaping AuthCompletionHandler) {
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
    
    func changeEmail(_ newEmail: String, _ completion: StringClosure? = nil) {
        auth.currentUser?.updateEmail(to: newEmail, completion: { error in
            guard error == nil else { completion?(nil); print(String(describing: error)); return }
            completion?(newEmail)
        })
    }
    
    func changePassword(_ newPassword: String, _ completion: BoolClosure? = nil) {
        auth.currentUser?.updatePassword(to: newPassword, completion: { error in
            completion?(error == nil)
        })
    }
    
    func logout(_ completion: BoolClosure? = nil) {
        do {
            try auth.signOut()
            completion?(true)
        } catch {
            print(String(describing: error))
            completion?(false)
        }
    }
}
