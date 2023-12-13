//
//  HomeViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxCocoa
import RxSwift

final class HomeViewController: BaseViewController {
    
    private var viewModel: HomeViewModel?
    private var notificationsViewModel: NotificationsViewModel?
    
    @IBOutlet private weak var currenciesTableView: UITableView!
    @IBOutlet private weak var accountsTableView: UITableView!
    @IBOutlet private weak var creditsButton: UIBarButtonItem!
    @IBOutlet private weak var notificationsButton: UIBarButtonItem!
    
    
    override func configure() {
        super.configure()
        
        viewModel = HomeViewModel()
        notificationsViewModel = NotificationsViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.fetch()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.currenciesRelay.asDriver().drive(currenciesTableView.rx.items(cellIdentifier: "CurrencyCell")) { row, item, cell in
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.titleRate
        }.disposed(by: disposeBag)
        
        viewModel?.accountsRelay.asDriver().drive(accountsTableView.rx.items(cellIdentifier: "AccountCell")) { row, item, cell in
            cell.textLabel?.text = Ciper.unseal(item.contractNumber)
            cell.detailTextLabel?.text = item.currency.rawValue
        }.disposed(by: disposeBag)
        
        viewModel?.bankAccountInfoRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] components in
            guard let vc: CardInfoViewController = UIStoryboard.instantiateViewController(identifier: "CardInfoViewController", storyboard: .main) else { return }
            vc.viewModel = CardInfoViewModel(card: components.card, account: components.bankAccount)
            self?.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        notificationsViewModel?.hasUnreadNotificationsRelay.asDriver().drive(onNext: { [weak self] notificationsCount in
            let badge = notificationsCount == 0 ? UIImage(systemName: "bell") : UIImage(systemName: "bell.badge")
            self?.notificationsButton.image = badge
        }).disposed(by: disposeBag)
        
        accountsTableView.rx.modelSelected(BankAccount.self).asDriver().drive(onNext: { [weak self] bankAccount in
            self?.viewModel?.didSelectBankAccount(bankAccount)
        }).disposed(by: disposeBag)
        
        creditsButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let vc: CreditsViewController = UIStoryboard.instantiateViewController(identifier: "CreditsViewController", storyboard: .main) else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        notificationsButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let vc: NotificationsViewController = UIStoryboard.instantiateViewController(identifier: "NotificationsViewController", storyboard: .main) else { return }
            vc.viewModel = self?.notificationsViewModel
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }
    
}
