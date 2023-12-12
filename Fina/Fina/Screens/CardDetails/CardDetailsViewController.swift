//
//  CardDetailsViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa

final class CardDetailsViewController: BaseViewController {
    
    var viewModel: CardDetailsViewModel?
    
    @IBOutlet private weak var cardBackgroundView: UIView!
    @IBOutlet private weak var cardTitleLabel: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardExpiresLabel: UILabel!
    @IBOutlet private weak var cardOwnerLabel: UILabel!
    @IBOutlet private weak var cardBalanceLabel: UILabel!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var infoButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var topUpButton: UIButton!
    @IBOutlet private weak var payButton: UIButton!
    @IBOutlet private weak var transferButton: UIButton!
    @IBOutlet private weak var addCreditButton: UIButton!
    
    override func bind() {
        super.bind()
        
        viewModel?.balanceRelay.asDriver().drive(cardBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel?.ownerRelay.asDriver().drive(cardOwnerLabel.rx.text).disposed(by: disposeBag)
        
        viewModel?.canCreateCreditRelay.asDriver().drive(onNext: { [weak self] creditEnabled in
            self?.addCreditButton.isHidden = !creditEnabled
        }).disposed(by: disposeBag)
        
        viewModel?.cardRelay.asDriver().drive(onNext: { [weak self] card in
            self?.cardBackgroundView.backgroundColor = card.cardType.associatedColor
            self?.cardTitleLabel.text = card.title
            self?.cardNumberLabel.text = Ciper.unseal(card.number).asHiddenCardNumber()
            self?.cardExpiresLabel.text = card.expiresDate.monthYear()
        }).disposed(by: disposeBag)
        
        viewModel?.transactionsRelay.asDriver().drive(tableView.rx.items(cellIdentifier: "TransactionCell")) { row, item, cell in
            cell.imageView?.image = item.transactionType.associatedImage
            cell.imageView?.tintColor = item.transactionType.associatedColor
            cell.textLabel?.text = item.transactionType.localizedTitle
            cell.detailTextLabel?.text = item.transactionTotal
            cell.detailTextLabel?.textColor = item.transactionType.associatedColor
        }.disposed(by: disposeBag)
    
        topUpButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.topUpAlert()
        }).disposed(by: disposeBag)
        
        infoButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.infoTransition()
        }).disposed(by: disposeBag)
        
        transferButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.transferAlert()
        }).disposed(by: disposeBag)
        
        payButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.payAlert()
        }).disposed(by: disposeBag)
        
        addCreditButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let vc: AddCreditViewController = UIStoryboard.instantiateViewController(identifier: "AddCreditViewController", storyboard: .main), let bankAccount = self?.viewModel?.bankAccountRelay.value else { return }
            vc.viewModel = AddCreditViewModel(bankAccount: bankAccount)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
}

private extension CardDetailsViewController {
    
    private func topUpAlert() {
        let ac = UIAlertController(title: "Top Up", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.textAlignment = .center
            textField.placeholder = "Enter sum (BYN)"
        }
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let textField = ac.textFields?.first, let text = textField.text, let sum = Double(text), sum > 0 else { return }
            self?.viewModel?.topUp(sum)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func payAlert() {
        guard let bankAccountCurrency = viewModel?.bankAccountRelay.value?.currency.rawValue else { return }
        let ac = UIAlertController(title: "Pay", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.textAlignment = .center
            textField.placeholder = "Enter sum to pay (\(bankAccountCurrency))"
        }
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let textField = ac.textFields?.first, let text = textField.text, let sum = Double(text) else { return }
            self?.twoFactorAuthTransition({ authorized in
                guard authorized else { return }
                self?.viewModel?.pay(sum)
            })
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func transferAlert() {
        guard let bankAccount = viewModel?.bankAccountRelay.value else { return }
        let ac = UIAlertController(title: "Transfer", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.textAlignment = .center
            textField.placeholder = "Enter card number to transfer"
        }
        ac.addTextField { textField in
            textField.textAlignment = .center
            textField.placeholder = "Enter sum to transfer (\(bankAccount.currency.rawValue))"
        }
        ac.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let cardNumber = ac.textFields?.first?.text, let text = ac.textFields?[safe: 1]?.text, let sum = Double(text) else { return }
            self?.twoFactorAuthTransition({ authorized in
                guard authorized else { return }
                self?.viewModel?.transfer(sum, cardNumber)
            })
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func infoTransition() {
        guard let vc: CardInfoViewController = UIStoryboard.instantiateViewController(identifier: "CardInfoViewController", storyboard: .main), let card = viewModel?.cardRelay.value, let account = viewModel?.bankAccountRelay.value else { return }
        vc.viewModel = CardInfoViewModel(card: card, account: account)
        present(vc, animated: true)
    }
    
    private func twoFactorAuthTransition(_ authCompletion: @escaping BoolClosure) {
        guard let vc: TwoFactorConfirmViewController = UIStoryboard.instantiateViewController(identifier: "TwoFactorConfirmViewController", storyboard: .auth) else { return }
        vc.authEvent = { authorized in
            authCompletion(authorized)
        }
        present(vc, animated: true)
    }
}
