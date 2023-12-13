//
//  CardInfoViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa

final class CardInfoCell: UITableViewCell {
    
    var cardInfo: CardInfo? {
        didSet {
            guard let info = cardInfo else { return }
            infoTitleLabel.text = info.title
            infoContentLabel.text = info.infoContent
        }
    }
    
    var clipboardAction: (() -> Void)?
    
    @IBOutlet private weak var infoTitleLabel: UILabel!
    @IBOutlet private weak var infoContentLabel: UILabel!
    @IBOutlet private weak var copyToClipboardButton: UIButton!
    
    @IBAction func copyClicked(_ sender: Any) {
        UIPasteboard.general.string = infoContentLabel.text
        clipboardAction?()
    }

    class var cellReuseIdentifier: String {
        return "CardInfoCell"
    }
}

final class CardInfoViewController: BaseViewController {
    
    var viewModel: CardInfoViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var closeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.infoRelay.asDriver().drive(tableView.rx.items(cellIdentifier: CardInfoCell.cellReuseIdentifier, cellType: CardInfoCell.self)) { [weak self] row, item, cell in
            cell.cardInfo = item
            cell.clipboardAction = {
                self?.clipboardAlert()
            }
        }.disposed(by: disposeBag)
        
        closeButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
    }

}

private extension CardInfoViewController {
    
    func clipboardAlert() {
        let ac = UIAlertController(title: "Copied to clipboard", message: nil, preferredStyle: .actionSheet)
        present(ac, animated: true)
        ac.dismiss(animated: true)
    }
}
