//
//  CreditDetailsViewController.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import UIKit
import RxSwift
import RxCocoa

final class PaymentCell: UITableViewCell {
    
    var schedule: CreditSchedule? {
        didSet {
            guard let schedule = schedule else { return }
            date.text = schedule.date.baseFormatted()
            rate.text = "\(schedule.percentPayment.toRounded())"
            month.text = "\(schedule.loanPayment.toRounded())"
            total.text = "\(schedule.totalSum.toRounded())"
            payButton.isEnabled = !schedule.isPayed
            payButton.tintColor = schedule.isPayed ? .green : .blue
        }
    }
    
    var paymentListener: ((CreditSchedule) -> Void)?
    
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var rate: UILabel!
    @IBOutlet private weak var month: UILabel!
    @IBOutlet private weak var total: UILabel!
    @IBOutlet private weak var payButton: UIButton!
    
    @IBAction func payClicked(_ sender: Any) {
        guard let schedule = schedule else { return }
        paymentListener?(schedule)
    }
    
    class var cellReuseIdentifier: String {
        return "PaymentCell"
    }
}


final class CreditDetailsViewController: BaseViewController {
    
    var viewModel: CreditDetailsViewModel?
    
    @IBOutlet private weak var creditStatus: UIButton!
    @IBOutlet private weak var loanSum: UILabel!
    @IBOutlet private weak var totalSum: UILabel!
    @IBOutlet private weak var period: UILabel!
    @IBOutlet private weak var percentage: UILabel!
    @IBOutlet private weak var paymentType: UILabel!
    @IBOutlet private weak var bankAccount: UILabel!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.fetch()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.creditRelay.asDriver().drive(onNext: { [weak self] credit in
            let attributedStatus = NSAttributedString(string: credit.isPayed ? "Payed" : "Active", attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: UIColor.white
            ])
            self?.creditStatus.setAttributedTitle(attributedStatus, for: .normal)
            self?.creditStatus.tintColor = credit.isPayed ? .green : .blue
            self?.loanSum.text = credit.currency.stringAmount(credit.sum)
            self?.totalSum.text = credit.currency.stringAmount(credit.totalSum)
            self?.period.text = "\(credit.durationMonths) months"
            self?.percentage.text = "\(credit.percentYear.toRounded())%"
            self?.paymentType.text = credit.paymentType.rawValue
        }).disposed(by: disposeBag)
        
        viewModel?.bankAccountRelay.asDriver().drive(onNext: { [weak self] bankAccount in
            self?.bankAccount.text = bankAccount
        }).disposed(by: disposeBag)
        
        viewModel?.scheduleRelay.asDriver().drive(tableView.rx.items(cellIdentifier: PaymentCell.cellReuseIdentifier, cellType: PaymentCell.self)) { [weak self] row, item, cell in
            cell.schedule = item
            cell.paymentListener = { scheduleToPay in
                self?.payForCreditSchedule(scheduleToPay)
            }
        }.disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
}


private extension CreditDetailsViewController {
    
    private func payForCreditSchedule(_ schedule: CreditSchedule) {
        guard let vc: TwoFactorConfirmViewController = UIStoryboard.instantiateViewController(identifier: "TwoFactorConfirmViewController", storyboard: .auth) else { return }
        vc.authEvent = { [weak self] authorized in
            guard authorized else { return }
            self?.viewModel?.payForSchedule(schedule: schedule)
        }
        present(vc, animated: true)
    }
    
}
