//
//  NotificationsViewModel.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import Foundation
import RxSwift
import RxRelay

final class NotificationsViewModel {
    
    let notificationsRelay = BehaviorRelay<[Notification]>(value: [])
    let hasUnreadNotificationsRelay = BehaviorRelay<Int>(value: 0)
    
    private let notificationsManager = ManagerFactory.shared.notificationsManager
    private let disposeBag = DisposeBag()
    
    init() {
        notificationsManager.userNotifiactionsRelay.subscribe(onNext: { [weak self] notifications in
            self?.notificationsRelay.accept(notifications)
            self?.hasUnreadNotificationsRelay.accept(notifications.filter({ !$0.isRead }).count)
        }).disposed(by: disposeBag)
    }
    
    func read(_ notification: Notification) {
        guard !notification.isRead else { return }
        var copy = notification
        copy.isRead = true
        notificationsManager.updateNotification(copy)
    }
    
}
