//
//  AccountsManager.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import FirebaseFirestore
import FirebaseAuth

typealias BankAccountClosure = (BankAccount?) -> Void
typealias BalanceClosure = (Double?, Currency?) -> Void
typealias StringClosure = (String?) -> Void

protocol BankAccountsManager: AnyObject {
    var userBankAccounts: BehaviorRelay<[BankAccount]> { get }
    
    func fetchBalance(for uid: String, _ completion: @escaping BalanceClosure)
    func observeBalance(for uid: String, _ completion: @escaping BalanceClosure)
    func fetchBankAccount(by cardNumber: String, _ completion: @escaping BankAccountClosure)
    func fetchBankAccount(_ uid: String, _ completion: @escaping BankAccountClosure)
    func observeBankAccount(_ uid: String, _ completion: @escaping BankAccountClosure)
    func createBankAccount(_ newAccount: BankAccount, _ completion: @escaping StringClosure)
    func updateBankAccount(_ updatedAccount: BankAccount, _ completion: @escaping BoolClosure)
    func deleteBankAccount(_ uid: String, _ completion: @escaping BoolClosure)
}

final class FirebaseBankAccountsManager: BaseManager, BankAccountsManager {
    
    let userBankAccounts = BehaviorRelay<[BankAccount]>(value: [])
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    func initialize() async {
        guard let uid = auth.currentUser?.uid else { return }
        let accounts = await fetchUserBankAccountsAsync(uid)
        userBankAccounts.accept(accounts)
        observeUserBankAccounts(uid)
    }
    
    func fetchBalance(for uid: String, _ completion: @escaping BalanceClosure) {
        firestore.collection(BankAccount.collection()).document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let bankAccount = BankAccount(data), error == nil else { completion(nil, nil); return }
            completion(bankAccount.balance, bankAccount.currency)
        }
    }
    
    func observeBalance(for uid: String, _ completion: @escaping BalanceClosure) {
        firestore.collection(BankAccount.collection()).document(uid).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(), let bankAccount = BankAccount(data), error == nil else { completion(nil, nil); return }
            completion(bankAccount.balance, bankAccount.currency)
        }
    }
    
    func fetchBankAccount(by cardNumber: String, _ completion: @escaping BankAccountClosure) {
        firestore.collection(Card.collection()).getDocuments { [weak self] snapshot, error in
            guard let docs = snapshot?.documents, error == nil else { completion(nil); return }
            guard let bankAccountId = docs.compactMap({ Card($0.data()) }).first(where: { Ciper.unseal($0.number) == cardNumber })?.bankAccountId else { completion(nil); return }
            self?.fetchBankAccount(bankAccountId, { bankAccount in
                completion(bankAccount)
            })
        }
    }
    
    func fetchBankAccount(_ uid: String, _ completion: @escaping BankAccountClosure) {
        firestore.collection(BankAccount.collection()).document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let bankAccount = BankAccount(data), error == nil else { completion(nil); return }
            completion(bankAccount)
        }
    }
    
    func observeBankAccount(_ uid: String, _ completion: @escaping BankAccountClosure) {
        firestore.collection(BankAccount.collection()).document(uid).addSnapshotListener { snapshot, error in
            guard let data = snapshot?.data(), let bankAccount = BankAccount(data), error == nil else { completion(nil); return }
            completion(bankAccount)
        }
    }
    
    func createBankAccount(_ newAccount: BankAccount, _ completion: @escaping StringClosure) {
        let reference = firestore.collection(BankAccount.collection()).document()
        var copy = newAccount
        copy.uid = reference.documentID
        reference.setData(copy.toEntity()) { error in
            guard error == nil else { completion(nil); return }
            completion(copy.uid)
        }
    }
    
    func updateBankAccount(_ updatedAccount: BankAccount, _ completion: @escaping BoolClosure) {
        firestore.collection(BankAccount.collection()).document(updatedAccount.uid).updateData(updatedAccount.toEntity()) { error in
            completion(error == nil)
        }
    }
    
    func deleteBankAccount(_ uid: String, _ completion: @escaping BoolClosure) {
        firestore.collection(BankAccount.collection()).document(uid).delete { error in
            completion(error == nil)
        }
    }
}

private extension FirebaseBankAccountsManager {
    
    private func observeUserBankAccounts(_ uid: String) {
        firestore.collection(BankAccount.collection()).whereField("ownerId", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            let accounts = documents.compactMap({ BankAccount($0.data()) })
            self?.userBankAccounts.accept(accounts)
        }
    }
    
    private func fetchUserBankAccountsAsync(_ uid: String) async -> [BankAccount] {
        guard let snapshot = try? await firestore.collection(BankAccount.collection()).whereField("ownerId", isEqualTo: uid).getDocuments() else { return [] }
        let accounts = snapshot.documents.compactMap({ BankAccount($0.data()) })
        return accounts
    }

}
