//
//  ProfileViewController.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class ActionCell: UITableViewCell {
    
    @IBOutlet private weak var associatedTitleLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!
    
    var action: ProfileAction? {
        didSet {
            guard let action = action else { return }
            associatedTitleLabel.text = action.localizedTitle
            associatedTitleLabel.textColor = action.associatedColor
            imageView?.image = action.associatedImage
            imageView?.tintColor = action.associatedColor
            chevronImageView.isHidden = action == .deleteAccount
        }
    }
    
    class var cellReuseIdentifier: String {
        "ActionCell"
    }
}

final class ProfileViewController: BaseViewController {
    
    private var viewModel: ProfileViewModel?
    
    @IBOutlet private weak var logoutButton: UIBarButtonItem!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userEmailLabel: UILabel!
    @IBOutlet private weak var actionsTableView: UITableView!
    
    override func configure() {
        super.configure()
        
        viewModel = ProfileViewModel(factory: DefaultManagerFactory.shared)
        viewModel?.fetch()
    }
    
    override func bind() {
        super.bind()
        
        viewModel?.actionsRelay.asDriver().drive(actionsTableView.rx.items(cellIdentifier: ActionCell.cellReuseIdentifier, cellType: ActionCell.self)) { row, item, cell in
            cell.action = item
        }.disposed(by: disposeBag)
        
        viewModel?.userNameRelay.asDriver().drive(userNameLabel.rx.text).disposed(by: disposeBag)
        viewModel?.userEmailRelay.asDriver().drive(userEmailLabel.rx.text).disposed(by: disposeBag)
        
        viewModel?.userImageRelay.asDriver().drive(onNext: { [weak self] image in
            guard let image = image else { return }
            self?.userImageView.image = image
            self?.userImageView.contentMode = .scaleAspectFill
        }).disposed(by: disposeBag)
        
        viewModel?.loadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.endLoadingRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] _ in
            self?.displayEndLoading()
        }).disposed(by: disposeBag)
        
        viewModel?.alertMessageRelay.asDriver(onErrorDriveWith: .never()).drive(onNext: { [weak self] text in
            self?.infoAlert(text)
        }).disposed(by: disposeBag)
        
        actionsTableView.rx.modelSelected(ProfileAction.self).asDriver().drive(onNext: { [weak self] action in
            switch action {
            case .changePhoto:
                self?.changePhotoFlow()
            case .changeEmail:
                self?.changeEmailFlow()
            case .changePassword:
                self?.changePasswordFlow()
            case .changeCodePassword:
                self?.changeCodePasswordFlow()
            case .deleteAccount:
                self?.deleteAccountFlow()
            }
        }).disposed(by: disposeBag)
        
        logoutButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel?.logout()
            self?.coordinator?.coordinateToRoot()
        }).disposed(by: disposeBag)
    }
}

private extension ProfileViewController {
    
    private func changePhotoFlow() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func changeEmailFlow() {
        alertWithTextField(header: "Change email", text: "", textFieldPlaceholder: "Enter new email") { [weak self] email in
            guard let email = email else { return }
            self?.viewModel?.changeEmail(email)
        }
    }
    
    private func changeCodePasswordFlow() {
        alertWithTextField(header: "Change code-password", text: "Code-password must be 4-digit code", textFieldPlaceholder: "Enter new Code-Password") { [weak self] codePassword in
            guard let codePassword = codePassword else { return }
            self?.viewModel?.changeCodePassword(codePassword)
        }
    }
    
    private func changePasswordFlow() {
        alertWithTextField(header: "Change password", text: "Password must be 6 characters length, contain at least one capital character and one number", textFieldPlaceholder: "Enter new Password") { [weak self] password in
            guard let password = password else { return }
            self?.viewModel?.changePassword(password)
        }
    }
    
    private func deleteAccountFlow() {
        viewModel?.deleteAccount({ [weak self] deleted in
            guard deleted else { return }
            self?.coordinator?.coordinateToRoot()
        })
    }
    
    private func alertWithTextField(header: String, text: String, textFieldPlaceholder: String, _ action: @escaping StringClosure) {
        let ac = UIAlertController(title: header, message: text, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = textFieldPlaceholder
            textField.textAlignment = .center
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let text = ac.textFields?.first?.text
            action(text)
        }))
        present(ac, animated: true)
    }
    
    private func infoAlert(_ text: String) {
        let ac = UIAlertController(title: "Alert", message: text, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage, let jpegData = image.jpegData(compressionQuality: 1), let jpegImage = UIImage(data: jpegData) else { return }
        viewModel?.setImage(jpegImage)
        picker.dismiss(animated: true)
    }
}
