//
//  UserManager.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import RxRelay
import FirebaseFirestore
import FirebaseAuth

typealias UserCompletionHandler = (User?) -> Void

final class UserManager: BaseManager {
    
    let currentUser = BehaviorRelay<User?>(value: nil)
    
    private let firestore = Firestore.firestore()
    
    private let auth = Auth.auth()
    
    private var listeners = [ListenerRegistration]()
    
    func initialize() async {
        guard let uid = auth.currentUser?.uid, let user = await fetchUserAsync(uid) else { return }
        currentUser.accept(user)
    }
    
    func getUser(uid: String, _ completion: @escaping UserCompletionHandler) {
        firestore.collection(User.collection()).document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil, let user = User(data) else { completion(nil); return }
            completion(user)
        }
    }
    
    func getCurrentUser(_ uid: String) {
        observeCurrentUserChanges(uid)
    }
    
    func createUser(_ newUser: User, _ completion: @escaping BoolClosure) {
        firestore.collection(User.collection()).getDocuments { [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil else { completion(false); return }
            guard snapshot.documents.compactMap({ User($0.data()) }).first(where: { Ciper.unseal($0.passportIdentifier) == Ciper.unseal(newUser.passportIdentifier) }) == nil else {
                completion(false);
                return
            }
            self?.firestore.collection(User.collection()).document(newUser.uid).setData(newUser.toEntity()) { error in
                completion(error == nil)
                self?.observeCurrentUserChanges(newUser.uid)
            }
        }
    }
    
    func updateUser(_ updatedUser: User, _ completion: @escaping BoolClosure) {
        firestore.collection(User.collection()).document(updatedUser.uid).updateData(updatedUser.toEntity()) { error in
            completion(error == nil)
        }
    }
    
    func deleteUser(_ uid: String, _ completion: @escaping BoolClosure) {
        firestore.collection(User.collection()).document(uid).delete { error in
            completion(error == nil)
        }
    }
    
    func signOut() {
        listeners.forEach{ $0.remove() }
        currentUser.accept(nil)
    }
    
}

private extension UserManager {
    
    private func observeCurrentUserChanges(_ uid: String) {
        let reference = firestore.collection(User.collection()).document(uid).addSnapshotListener { [weak self] snapshot, error in
            guard let data = snapshot?.data(), let user = User(data), error == nil else { return }
            self?.currentUser.accept(user)
        }
        listeners.append(reference)
    }
    
    private func fetchUserAsync(_ uid: String) async -> User? {
        guard let user = try? await firestore.collection(User.collection()).document(uid).getDocument() else { return nil }
        guard let data = user.data(), let user = User(data) else { return nil }
        return user
    }
}
