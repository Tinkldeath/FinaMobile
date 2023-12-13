//
//  CreditsManager.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import RxRelay
import RxSwift

typealias CreditCompletionHandler = (Credit?) -> Void

final class CreditsManager: BaseManager {
    
    let userCreditsRelay = BehaviorRelay<[Credit]>(value: [])
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let disposeBag = DisposeBag()
    
    var currentUserHasCredits: Bool {
        return userCreditsRelay.value.first(where: { !$0.isPayed }) == nil
    }
    
    func initialize() async {
        guard let uid = auth.currentUser?.uid else { return }
        let credits = await fetchUserCreditsAsync(uid)
        userCreditsRelay.accept(credits)
        observeUserCredits(uid)
    }
    
    func createCredit(_ newCredit: Credit, _ completion: @escaping StringClosure) {
        let reference = firestore.collection(Credit.collection()).document()
        var copy = newCredit
        copy.uid = reference.documentID
        reference.setData(copy.toEntity()) { error in
            guard error == nil else { completion(nil); return }
            completion(copy.uid)
        }
    }
    
    func observeCredit(_ uid: String, _ observer: @escaping CreditCompletionHandler) {
        firestore.collection(Credit.collection()).document(uid).addSnapshotListener { snapshot, error in
            guard let document = snapshot?.data(), error == nil else { return }
            let credit = Credit(document)
            observer(credit)
        }
    }
    
    func fetchCreditAsync(_ uid: String) async -> Credit? {
        guard let creditData = try? await firestore.collection(Credit.collection()).document(uid).getDocument().data(), let credit = Credit(creditData) else { return nil }
        return credit
    }
    
    func fetchCredit(_ uid: String, _ completion: @escaping CreditCompletionHandler) {
        firestore.collection(Credit.collection()).document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let credit = Credit(data), error == nil else { completion(nil); return }
            completion(credit)
        }
    }
    
    func updateCredit(_ updateCredit: Credit, _ completion: @escaping BoolClosure) {
        firestore.collection(Credit.collection()).document(updateCredit.uid).updateData(updateCredit.toEntity()) { error in
            completion(error == nil)
        }
    }
    
    func deleteCredit(_ uid: String, _ completion: @escaping BoolClosure) {
        firestore.collection(Credit.collection()).document(uid).delete { error in
            completion(error == nil)
        }
    }
    
}

private extension CreditsManager {
    
    private func fetchUserCreditsAsync(_ uid: String) async -> [Credit] {
        guard let snapshot = try? await firestore.collection(Credit.collection()).whereField("ownerId", isEqualTo: uid).getDocuments() else { return [] }
        let credits = snapshot.documents.compactMap({ Credit($0.data()) })
        return credits
    }
    
    private func observeUserCredits(_ uid: String) {
        firestore.collection(Credit.collection()).whereField("ownerId", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            let credits = documents.compactMap({ Credit($0.data()) })
            self?.userCreditsRelay.accept(credits)
        }
    }
}
