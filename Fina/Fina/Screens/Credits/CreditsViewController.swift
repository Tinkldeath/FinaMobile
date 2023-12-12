//
//  CreditsViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa

final class CreditCell: UITableViewCell {
    
    var credit: Credit? {
        didSet {
            guard let credit = credit else { return }
            creditSumLabel.text = "\(credit.currency.stringAmount(credit.sum))"
            creditMonths.text = " \(credit.durationMonths) Months"
            creditStatus.backgroundColor = credit.isPayed ? .green : .blue
            creditStatus.setTitle(credit.isPayed ? "Payed" : "Active", for: .normal)
        }
    }
    
    @IBOutlet private weak var creditSumLabel: UILabel!
    @IBOutlet private weak var creditMonths: UILabel!
    @IBOutlet private weak var creditStatus: UIButton!
    
    class var cellReuseIdentifier: String {
        "CreditCell"
    }
}

final class CreditsViewController: BaseViewController {
    
    private var viewModel: CreditsViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addCreditButton: UIBarButtonItem!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    
    override func configure() {
        super.configure()
        
        viewModel = CreditsViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.fetch()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.creditsRelay.asDriver().drive(tableView.rx.items(cellIdentifier: CreditCell.cellReuseIdentifier, cellType: CreditCell.self)) { row, item, cell in
            cell.credit = item
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Credit.self).asDriver().drive(onNext: { credit in
            
        }).disposed(by: disposeBag)
        
        addCreditButton.rx.tap.asDriver().drive(onNext: { _ in
            
        }).disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
}
