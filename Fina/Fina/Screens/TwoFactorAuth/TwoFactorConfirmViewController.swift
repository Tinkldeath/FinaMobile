//
//  TwoFactorConfirmViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa

class TwoFactorConfirmViewController: BaseInputViewController {
    
    var authEvent: BoolClosure?
    
    private var viewModel: TwoFactorConfirmViewModel?
    
    @IBOutlet private weak var codePasswordTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var biometricButton: UIButton!
    
    override func configure() {
        super.configure()
        
        viewModel = TwoFactorConfirmViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel?.fastBiometric()
    }

    override func bind() {
        super.bind()
        
        viewModel?.authorizedRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] authorized in
            guard authorized else { return }
            self?.authEvent?(authorized)
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)
        
        viewModel?.biometricTypeRelay.asDriver().drive(onNext: { [weak self] biometricType in
            guard let biometricType = biometricType else { return }
            self?.biometricButton.isHidden = biometricType == .none
            self?.biometricButton.setImage(biometricType.associatedImage, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel?.isValidInput.asDriver().drive(submitButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        submitButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.authorize()
        }).disposed(by: disposeBag)
        
        biometricButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.authorizeBiometric()
        }).disposed(by: disposeBag)
        
        codePasswordTextField.rx.text.asDriver().drive(onNext: { [weak self] codePassword in
            guard let codePassword = codePassword else { return }
            self?.viewModel?.enterInput(codePassword)
        }).disposed(by: disposeBag)
    }

}
