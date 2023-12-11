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
    
    @IBOutlet private weak var currenciesTableView: UITableView!
    @IBOutlet private weak var accountsTableView: UITableView!
        
    override func configure() {
        super.configure()
        
        viewModel = HomeViewModel()
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
    }
    
}
