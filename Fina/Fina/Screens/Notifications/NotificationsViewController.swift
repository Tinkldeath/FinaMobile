//
//  NotificationsViewController.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//
import UIKit
import RxSwift
import RxCocoa

final class NotificationCell: UITableViewCell {
    
    var notification: Notification? {
        didSet {
            guard let notification = notification else { return }
            notificationTitle.text = notification.title
            notificationContent.text = notification.content
        }
    }
    
    @IBOutlet private weak var notificationTitle: UILabel!
    @IBOutlet private weak var notificationContent: UILabel!
    
    class var cellReuseIdentifier: String {
        return "NotificationCell"
    }
}

final class NotificationsViewController: BaseViewController {
    
    var viewModel: NotificationsViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var newNotifications: UILabel!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    
    override func setupView() {
        super.setupView()
        
        let notificationsCount = viewModel?.hasUnreadNotificationsRelay.value ?? 0
        let notificationsTitle = notificationsCount == 0 ? "No" : "+\(notificationsCount)"
        newNotifications.text = "\(notificationsTitle) new"
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.notificationsRelay.asDriver().drive(tableView.rx.items(cellIdentifier: NotificationCell.cellReuseIdentifier, cellType: NotificationCell.self)) { [weak self] row, item, cell in
            cell.notification = item
            self?.viewModel?.read(item)
        }.disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }

}
