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
    
    override func configure() {
        super.configure()
        
        viewModel = HomeViewModel()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.currenciesRelay.asDriver().drive(currenciesTableView.rx.items(cellIdentifier: "CurrencyCell")) { row, item, cell in
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.titleRate
        }.disposed(by: disposeBag)
    }
    
}
