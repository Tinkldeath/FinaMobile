//
//  CardsViewController.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import UIKit
import RxRelay
import RxCocoa


class CardCell: UITableViewCell {
    
    var card: Card? {
        didSet {
            guard let card = card else { return }
            cardTitleLabel.text = card.title
            cardBackgroundView.backgroundColor = card.cardType.associatedColor
            cardNumberLabel.text = Ciper.unseal(card.number).asHiddenCardNumber()
            cardExpiresLabel.text = card.expiresDate.monthYear()
        }
    }
    
    @IBOutlet private weak var cardTitleLabel: UILabel!
    @IBOutlet private weak var cardBackgroundView: UIView!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardExpiresLabel: UILabel!
    @IBOutlet private weak var cardOwnerLabel: UILabel!
    @IBOutlet private weak var cardBalanceLabel: UILabel!
    
    func setBalance(_ amount: Double, _ currency: Currency) {
        cardBalanceLabel.text = currency.stringAmount(amount)
    }
    
    func setOwner(_ owner: String) {
        cardOwnerLabel.text = owner
    }
    
    class var cellReuseIdentifier: String {
        "CardCell"
    }
}


final class CardsViewController: BaseViewController {
    
    private var viewModel: CardsViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addCardButton: UIBarButtonItem!
    
    override func configure() {
        super.configure()
        
        viewModel = CardsViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.fetch()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.cardsRelay.asDriver().drive(tableView.rx.items(cellIdentifier: CardCell.cellReuseIdentifier, cellType: CardCell.self)) { [weak self] row, item, cell in
            cell.card = item
            
            self?.viewModel?.observeBalance(for: item.bankAccountId, { amount, currency in
                guard let amount = amount, let currency = currency else { return }
                cell.setBalance(amount, currency)
            })
            
            self?.viewModel?.observeOwner(item.ownerId, { name in
                guard let name = name else { return }
                cell.setOwner(name)
            })
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Card.self).asDriver().drive(onNext: { [weak self] card in
            self?.showCardDetails(card)
        }).disposed(by: disposeBag)
        
        addCardButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let vc: AddCardViewController = UIStoryboard.instantiateViewController(identifier: "AddCardViewController", storyboard: .main) else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }
}

private extension CardsViewController {
    
    private func showCardDetails(_ card: Card) {
        guard let vc: CardDetailsViewController = UIStoryboard.instantiateViewController(identifier: "CardDetailsViewController", storyboard: .main) else { return }
        vc.viewModel = CardDetailsViewModel(card)
        navigationController?.pushViewController(vc, animated: true)
    }
}
