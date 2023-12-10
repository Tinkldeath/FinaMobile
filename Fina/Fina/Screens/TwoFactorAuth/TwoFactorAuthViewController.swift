//
//  TwoFactorAuthViewController.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class TwoFactorAuthViewController: BaseInputViewController {

    private var viewModel: TwoFactorAuthViewModel?
    
    @IBOutlet private weak var codePasswordTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBOutlet private weak var biometricButton: UIButton!
    
    override func configure() {
        super.configure()
        
        viewModel = TwoFactorAuthViewModel()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.isValidInput.asDriver().drive(submitButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel?.prepareEvent.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.coordinator?.coordinatePrepare()
        }).disposed(by: disposeBag)
        
        viewModel?.biometricType.asDriver().drive(onNext: { [weak self] biometricType in
            self?.biometricButton.isHidden = biometricType == .none
            self?.biometricButton.setImage(biometricType.associatedImage, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel?.logoutEvent.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.coordinator?.coordinateSignIn()
        }).disposed(by: disposeBag)
        
        viewModel?.enableBiometricEvent.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.showBiometricAlert()
        }).disposed(by: disposeBag)
        
        codePasswordTextField.rx.text.asDriver().drive(onNext: { [weak self] codePassword in
            guard let password = codePassword else { return }
            self?.viewModel?.enterInput(password)
        }).disposed(by: disposeBag)
        
        submitButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.authorize()
        }).disposed(by: disposeBag)
        
        biometricButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.authorizeBiometric()
        }).disposed(by: disposeBag)
        
        logoutButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.logout()
        }).disposed(by: disposeBag)
    }
}

extension TwoFactorAuthViewController {
    
    private func showBiometricAlert() {
        let ac = UIAlertController(title: "Enable biometric", message: "Do you want to enable biometric authentication?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Enable", style: .default, handler: { [weak self] _ in
            self?.viewModel?.setEnableBiometric(true)
        }))
        ac.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: { [weak self] _ in
            self?.viewModel?.setEnableBiometric(false)
        }))
        present(ac, animated: true)
    }
}
