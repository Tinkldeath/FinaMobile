//
//  AddCardViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa

final class CardTypeCell: UITableViewCell {
    
    override var isSelected: Bool {
        didSet {
            cardBackgroundView.layer.borderColor = isSelected ? UIColor.label.cgColor : UIColor.clear.cgColor
        }
    }
    
    var cardType: Card.CardType? {
        didSet {
            guard let cardType = cardType else { return }
            cardBackgroundView.backgroundColor = cardType.associatedColor
            cardTypeLabel.text = cardType.localizedTitle
            cardDescriptionLabel.text = cardType.localizedDescription
        }
    }
    
    @IBOutlet private weak var cardBackgroundView: UIView!
    @IBOutlet private weak var cardTypeLabel: UILabel!
    @IBOutlet private weak var cardDescriptionLabel: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardBackgroundView.layer.borderWidth = 1
        cardBackgroundView.layer.borderColor = isSelected ? UIColor.label.cgColor : UIColor.clear.cgColor
    }
    
    class var cellReuseIdentifier: String {
        return "CardTypeCell"
    }
}

final class AddCardViewController: BaseViewController {
    
    private var viewModel: AddCardViewModel?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didEndEditing))
        gesture.delegate = self
        return gesture
    }()

    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var infoButton: UIBarButtonItem!
    @IBOutlet private weak var currencySegmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var pinTextField: UITextField!
    @IBOutlet private weak var cvvTextField: UITextField!
    
    override func configure() {
        super.configure()
        
        viewModel = AddCardViewModel(factory: DefaultManagerFactory.shared)
    }
    
    override func setupView() {
        super.setupView()
        
        view.addGestureRecognizer(tapGesture)
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.cardTypes.asDriver().drive(tableView.rx.items(cellIdentifier: CardTypeCell.cellReuseIdentifier, cellType: CardTypeCell.self)) { row, item, cell in
            cell.cardType = item
        }.disposed(by: disposeBag)
        
        viewModel?.isValidInput.asDriver().drive(createButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.createdRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Card.CardType.self).asDriver().drive(onNext: { [weak self] cardType in
            self?.viewModel?.selectCardType(cardType)
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(currencySegmentedControl.rx.value, pinTextField.rx.text, cvvTextField.rx.text).asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] currencyIndex, pin, cvv in
            guard let currency = Currency(rawValue: self?.currencySegmentedControl.titleForSegment(at: currencyIndex) ?? ""), let pin = pin, let cvv = cvv else { return }
            self?.viewModel?.enterInput(.init(currency: currency, cvv: cvv, pin: pin))
        }).disposed(by: disposeBag)
        
        createButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.addCard()
        }).disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
}

private extension AddCardViewController {
    
    @objc private func didEndEditing() {
        pinTextField.resignFirstResponder()
        cvvTextField.resignFirstResponder()
    }
}

extension AddCardViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return true }
        if view.isDescendant(of: tableView) {
            return false
        }
        return true
    }
}
