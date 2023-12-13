//
//  CardsManager.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import FirebaseFirestore
import FirebaseAuth

typealias CardClosure = (Card?) -> Void

protocol CardsManager: AnyObject {
    var userCards: BehaviorRelay<[Card]> { get }
    
    func fechCard(_ cardNumber: String, _ completion: @escaping CardClosure)
    func createCard(_ newCard: Card, _ completion: @escaping BoolClosure)
    func updateCard(_ updatedCard: Card, _ completion: @escaping BoolClosure)
    func deleteCard(_ uid: String, _ completion: @escaping BoolClosure)
}

final class FirebaseCardsManager: BaseManager, CardsManager {
    
    let userCards = BehaviorRelay<[Card]>(value: [])
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    func initialize() async {
        guard let uid = auth.currentUser?.uid else { return }
        let cards = await fetchUserCardsAsync(uid)
        userCards.accept(cards)
        observeUserCards(uid)
    }
    
    func fechCard(_ cardNumber: String, _ completion: @escaping CardClosure) {
        firestore.collection(Card.collection()).getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else { completion(nil); return }
            guard let card = docs.compactMap({ Card($0.data()) }).first(where: { Ciper.unseal($0.number) == cardNumber }) else { completion(nil); return }
            completion(card)
        }
    }
    
    func createCard(_ newCard: Card, _ completion: @escaping BoolClosure) {
        var copy = newCard
        let reference = firestore.collection(Card.collection()).document()
        copy.uid = reference.documentID
        reference.setData(copy.toEntity()) { error in
            completion(error == nil)
        }
    }
    
    func updateCard(_ updatedCard: Card, _ completion: @escaping BoolClosure) {
        firestore.collection(Card.collection()).document(updatedCard.uid).updateData(updatedCard.toEntity()) { error in
            completion(error == nil)
        }
    }
    
    func deleteCard(_ uid: String, _ completion: @escaping BoolClosure) {
        firestore.collection(Card.collection()).document(uid).delete { error in
            completion(error == nil)
        }
    }
}

private extension FirebaseCardsManager {
    
    private func fetchUserCardsAsync(_ uid: String) async -> [Card] {
        guard let data = try? await firestore.collection(Card.collection()).whereField("ownerId", isEqualTo: uid).getDocuments() else { return [] }
        let cards = data.documents.compactMap({ Card($0.data()) })
        return cards
    }
    
    private func observeUserCards(_ uid: String) {
        firestore.collection(Card.collection()).whereField("ownerId", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            let cards = documents.compactMap({ Card($0.data()) })
            self?.userCards.accept(cards)
        }
    }
}
