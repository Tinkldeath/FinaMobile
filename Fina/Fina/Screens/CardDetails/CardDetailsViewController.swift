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
    
    override func bind() {
        super.bind()
        
        viewModel?.balanceRelay.asDriver().drive(cardBalanceLabel.rx.text).disposed(by: disposeBag)
        viewModel?.ownerRelay.asDriver().drive(cardOwnerLabel.rx.text).disposed(by: disposeBag)
        
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
            cell.detailTextLabel?.text = item.currency.stringAmount(item.sum)
            cell.detailTextLabel?.textColor = item.transactionType.associatedColor
        }.disposed(by: disposeBag)
    
        topUpButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.topUpAlert()
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
}
