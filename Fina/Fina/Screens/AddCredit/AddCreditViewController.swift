//
//  AddCreditViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa

final class CreditScheduleCell: UITableViewCell {
    
    var schedule: CreditSchedule? {
        didSet {
            guard let schedule = schedule else { return }
            dateLabel.text = schedule.date.baseFormatted()
            rateLabel.text = Currency.byn.stringAmount(schedule.percentPayment)
            totalLabel.text = Currency.byn.stringAmount(schedule.totalSum)
        }
    }
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var rateLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    
    class var cellReuseIdentifier: String {
        "CreditScheduleCell"
    }
}

final class AddCreditViewController: BaseInputViewController {
    
    var viewModel: AddCreditViewModel?
    
    @IBOutlet private weak var creditSumTextField: UITextField!
    @IBOutlet private weak var creditDurationTextField: UITextField!
    @IBOutlet private weak var paymentTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var guarantorTextField: UITextField!
    @IBOutlet private weak var totalSumLabel: UILabel!
    @IBOutlet private weak var creditAgreementButton: UIButton!
    @IBOutlet private weak var addCreditButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    
    override func bind() {
        super.bind()
        
        viewModel?.isValidInput.asDriver().drive(creditAgreementButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel?.isValidInput.asDriver().drive(addCreditButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.scheduleRelay.asDriver().drive(tableView.rx.items(cellIdentifier: CreditScheduleCell.cellReuseIdentifier, cellType: CreditScheduleCell.self)) { row, item, cell in
            cell.schedule = item
        }.disposed(by: disposeBag)
        
        viewModel?.totalSumRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] totalSum in
            self?.totalSumLabel.text = Currency.byn.stringAmount(totalSum)
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(creditSumTextField.rx.text, creditDurationTextField.rx.text, paymentTypeSegmentedControl.rx.value, guarantorTextField.rx.text).asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] sumText, durationText, paymentTypeIndex, guarantorText in
            guard let sumString = sumText, let sum = Double(sumString), let durationString = durationText, let duration = Int(durationString), let paymentTypeString = self?.paymentTypeSegmentedControl.titleForSegment(at: paymentTypeIndex), let paymentType = Credit.PaymentType(rawValue: paymentTypeString), let guarantorPassportId = guarantorText else { return }
            self?.viewModel?.didEnterInput(.init(sum: sum, durationMonths: duration, paymentType: paymentType, guarantorPassportId: guarantorPassportId))
        }).disposed(by: disposeBag)
        
        creditAgreementButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let vc: TextViewController = UIStoryboard.instantiateViewController(identifier: "TextViewController", storyboard: .main), let agreements = self?.viewModel?.generateAgreements()else { return }
            vc.viewModel = TextViewModel("Credit agreements", agreements)
            self?.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        addCreditButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            guard let vc: TwoFactorConfirmViewController = UIStoryboard.instantiateViewController(identifier: "TwoFactorConfirmViewController", storyboard: .auth) else { return }
            vc.authEvent = { authorized in
                guard authorized else { return }
                self?.viewModel?.addCredit({ completed in
                    guard completed else { self?.somethingWentWrongAlert(); return }
                    self?.navigationController?.popViewController(animated: true)
                })
            }
            self?.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
}

extension AddCreditViewController {
    
    private func somethingWentWrongAlert() {
        let ac = UIAlertController(title: "Oops...", message: "Perhaps, something went wrong. Please, try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}
