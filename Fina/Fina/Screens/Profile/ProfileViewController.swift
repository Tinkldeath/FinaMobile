//
//  ProfileViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa

final class ActionCell: UITableViewCell {
    
    @IBOutlet private weak var associatedTitleLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!
    
    var action: ProfileAction? {
        didSet {
            guard let action = action else { return }
            associatedTitleLabel.text = action.localizedTitle
            associatedTitleLabel.textColor = action.associatedColor
            imageView?.image = action.associatedImage
            imageView?.tintColor = action.associatedColor
            chevronImageView.isHidden = action == .deleteAccount
        }
    }
    
    class var cellReuseIdentifier: String {
        "ActionCell"
    }
}

final class ProfileViewController: BaseViewController {
    
    private var viewModel: ProfileViewModel?
    
    @IBOutlet private weak var settingsButton: UIBarButtonItem!
    @IBOutlet private weak var logoutButton: UIBarButtonItem!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userEmailLabel: UILabel!
    @IBOutlet private weak var actionsTableView: UITableView!
    
    override func configure() {
        super.configure()
        
        viewModel = ProfileViewModel()
        viewModel?.fetch()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.actionsRelay.asDriver().drive(actionsTableView.rx.items(cellIdentifier: ActionCell.cellReuseIdentifier, cellType: ActionCell.self)) { row, item, cell in
            cell.action = item
        }.disposed(by: disposeBag)
        
        viewModel?.userNameRelay.asDriver().drive(userNameLabel.rx.text).disposed(by: disposeBag)
        viewModel?.userEmailRelay.asDriver().drive(userEmailLabel.rx.text).disposed(by: disposeBag)
    }
}
