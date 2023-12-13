//
//  SignInViewController.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import UIKit
import RxCocoa
import RxSwift

class SignInViewController: BaseInputViewController {
    
    private var viewModel: SignInViewModel?

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func configure() {
        super.configure()
        
        viewModel = SignInViewModel(factory: DefaultManagerFactory.shared)
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.isValidInput.asDriver().drive(signInButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.twoFactorRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.coordinator?.coordinateTwoFactorAuth()
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(emailTextField.rx.text, passwordTextField.rx.text).asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] email, password in
            guard let email = email, let password = password else { return }
            self?.viewModel?.enterInput(.init(email: email, password: password))
        }).disposed(by: disposeBag)
        
        signInButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.signIn()
        }).disposed(by: disposeBag)
        
        signUpButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.coordinator?.coordinateSignUp()
        }).disposed(by: disposeBag)
    }
}
