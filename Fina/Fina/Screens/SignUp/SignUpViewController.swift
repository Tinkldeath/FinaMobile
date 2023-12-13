//
//  SignUpViewController.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import UIKit
import RxCocoa
import RxSwift

class SignUpViewController: BaseInputViewController {
    
    private var viewModel: SignUpViewModel?
    
    @IBOutlet private weak var passportIdentifierTextField: UITextField!
    @IBOutlet private weak var fullNameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var codePasswordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var goBackButton: UIButton!
    
    override func configure() {
        super.configure()
        
        viewModel = SignUpViewModel(factory: DefaultManagerFactory.shared)
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.isValidInput.asDriver().drive(signUpButton.rx.isEnabled).disposed(by: disposeBag)
        
        Observable.combineLatest(passportIdentifierTextField.rx.text, fullNameTextField.rx.text, emailTextField.rx.text, passwordTextField.rx.text, confirmPasswordTextField.rx.text, codePasswordTextField.rx.text).asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] passportId, name, email, password, confrimPassword, codePassword in
            guard let passportId = passportId, let name = name, let email = email, let password = password, let confrimPassword = confrimPassword, let codePassword = codePassword else { return }
            self?.viewModel?.enterInput(.init(passportIdentifier: passportId, fullName: name, email: email, password: password, passwordConfirm: confrimPassword, codePassword: codePassword))
        }).disposed(by: disposeBag)
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.enableBiometricEvent.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.showBiometricAlert()
        }).disposed(by: disposeBag)
        
        viewModel?.prepareEvent.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.coordinator?.coordinatePrepare()
        }).disposed(by: disposeBag)
        
        signUpButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.signUp()
        }).disposed(by: disposeBag)
        
        goBackButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.coordinator?.back()
        }).disposed(by: disposeBag)
    }
}

extension SignUpViewController {
    
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
