//
//  NotificationsManager.swift
//  Fina
//
//  Created by Dima on 12.12.23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import RxRelay

typealias NotificationCompletionHandler = (Notification?) -> Void

final class NotificationsManager: BaseManager {

    let userNotifiactionsRelay = BehaviorRelay<[Notification]>(value: [])
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    
    func initialize() async {
        guard let uid = auth.currentUser?.uid else { return }
        let notifications = await fetchUserNotificationsAsync(uid)
        userNotifiactionsRelay.accept(notifications)
        observeUserNotifications(uid)
    }
    
    func createNotification(_ newNotification: Notification, _ completion: @escaping StringClosure) {
        let reference = firestore.collection(Notification.collection()).document()
        var copy = newNotification
        copy.uid = reference.documentID
        reference.setData(copy.toEntity()) { error in
            guard error == nil else { completion(nil); return }
            completion(copy.uid)
        }
    }
    
    func fetchNotification(_ uid: String, _ completion: @escaping NotificationCompletionHandler) {
        firestore.collection(Credit.collection()).document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), let notification = Notification(data), error == nil else { completion(nil); return }
            completion(notification)
        }
    }
    
    func updateNotification(_ updateNotification: Notification, _ completion: BoolClosure? = nil) {
        firestore.collection(Notification.collection()).document(updateNotification.uid).updateData(updateNotification.toEntity()) { error in
            completion?(error == nil)
        }
    }
    
    func deleteNotification(_ uid: String, _ completion: BoolClosure? = nil) {
        firestore.collection(Notification.collection()).document(uid).delete { error in
            completion?(error == nil)
        }
    }
    
}

private extension NotificationsManager {
    
    private func fetchUserNotificationsAsync(_ uid: String) async -> [Notification] {
        guard let snapshot = try? await firestore.collection(Notification.collection()).whereField("recieverId", isEqualTo: uid).getDocuments() else { return [] }
        let notifications = snapshot.documents.compactMap({ Notification($0.data()) })
        return notifications
    }
    
    private func observeUserNotifications(_ uid: String) {
        firestore.collection(Notification.collection()).whereField("recieverId", isEqualTo: uid).addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            let notifications = documents.compactMap({ Notification($0.data()) })
            self?.userNotifiactionsRelay.accept(notifications)
        }
    }
    
}
