//
//  TransactionsManager.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import RxSwift
import RxCocoa

typealias TransactionsClosure = ([Transaction]) -> Void

final class TransactionsManager {
    
    let transactionsRelay = BehaviorRelay<[Transaction]>(value: [])
    
    private let firestore = Firestore.firestore()
    
    private let auth = Auth.auth()
    
    private let disposeBag = DisposeBag()
    
    private var transactions = Set<Transaction>() {
        didSet {
            transactionsRelay.accept(transactions.sorted(by: { $0.date > $1.date }))
        }
    }
    
    func fetchTransactions(for bankAccountId: String, _ month: Int, _ year: Int, _ completion: @escaping TransactionsClosure) {
        firestore.collection(Transaction.collection()).whereField("senderBankAccount", isEqualTo: bankAccountId).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { completion([]); return }
            let transactions = documents.compactMap({ Transaction($0.data()) })
            let filtered = transactions.filter({ $0.date.baseComponents().month == month && $0.date.baseComponents().year == year && ($0.transactionType == .payment || $0.transactionType == .transfer) })
            completion(filtered)
        }
    }
    
    func fetchTransactions(for bankAccountId: String, _ completion: @escaping TransactionsClosure) {
        firestore.collection(Transaction.collection()).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { completion([]); return }
            let transactions = documents.compactMap({ Transaction($0.data()) }).filter({ $0.senderBankAccount == bankAccountId || $0.recieverBankAccount == bankAccountId })
            let nowComponents = Date.now.baseComponents()
            var results = Set<Transaction>()
            for i in 1...12 {
                let filtered = transactions.filter({ $0.date.baseComponents().year == nowComponents.year && $0.date.baseComponents().month == i })
                for filter in filtered {
                    results.insert(filter)
                }
            }
            completion(results.map({ $0 }))
        }
    }
            
    func createTransaction(_ newTransaction: Transaction, _ completion: @escaping StringClosure) {
        let reference = firestore.collection(Transaction.collection()).document()
        var copy = newTransaction
        copy.uid = reference.documentID
        reference.setData(copy.toEntity()) { error in
            completion(copy.uid)
        }
    }
    
    func updateTransaction(_ newTransaction: Transaction, _ completion: @escaping BoolClosure) {
        firestore.collection(Transaction.collection()).document(newTransaction.uid).updateData(newTransaction.toEntity()) { error in
            completion(error == nil)
        }
    }
    
    func deleteTransaction(_ uid: String, _ completion: @escaping BoolClosure) {
        firestore.collection(Transaction.collection()).document(uid).delete { error in
            completion(error == nil)
        }
    }
    
    func observeTransactions(for bankAccountId: String) {
        firestore.collection(Transaction.collection()).whereField("senderBankAccount", isEqualTo: bankAccountId).addSnapshotListener { [weak self] snapshot, error in
            guard let snapshot = snapshot else { return }
            let transactions = snapshot.documents.compactMap({ Transaction($0.data()) })
            transactions.forEach({ self?.transactions.insert($0) })
        }
        firestore.collection(Transaction.collection()).whereField("recieverBankAccount", isEqualTo: bankAccountId).addSnapshotListener { [weak self] snapshot, error in
            guard let snapshot = snapshot else { return }
            let transactions = snapshot.documents.compactMap({ Transaction($0.data()) })
            transactions.forEach({ self?.transactions.insert($0) })
        }
    }
}
