//
//  ProfileViewModel.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import RxRelay
import RxSwift


final class ProfileViewModel: BaseLoadingViewModel {
    
    let alertMessageRelay = PublishRelay<String>()
    let userImageRelay = BehaviorRelay<UIImage?>(value: nil)
    let userNameRelay = BehaviorRelay<String>(value: "")
    let userEmailRelay = BehaviorRelay<String>(value: "")
    let actionsRelay = BehaviorRelay<[ProfileAction]>(value: ProfileAction.allCases)
    
    private let userManager = ManagerFactory.shared.userManager
    private let authManager = ManagerFactory.shared.authManager
    private let creditsManager = ManagerFactory.shared.creditsManager
    private let mediaManager = ManagerFactory.shared.mediaManager
    private let disposeBag = DisposeBag()
    
    func fetch() {
        guard let user = userManager.currentUser.value else { return }
        mediaManager.fetchImage(for: user.uid) { [weak self] image in
            self?.userImageRelay.accept(image)
        }
        userManager.currentUser.asDriver().drive(onNext: { [weak self] user in
            guard let user = user, let uid = self?.authManager.currentUser.value, let userEmail = self?.authManager.currentUserEmail, user.uid == uid else { return }
            self?.userEmailRelay.accept(userEmail)
            self?.userNameRelay.accept(user.name)
        }).disposed(by: disposeBag)
    }
        
    func setImage(_ image: UIImage) {
        guard let user = userManager.currentUser.value else { return }
        loadingRelay.accept(())
        mediaManager.setImage(for: user.uid, image) { [weak self] image in
            self?.endLoadingRelay.accept(())
            guard let image = image else { return }
            self?.userImageRelay.accept(image)
        }
    }
    
    func changeEmail(_ newEmail: String) {
        guard newEmail.isValidEmail() else { return }
        loadingRelay.accept(())
        authManager.changeEmail(newEmail) { [weak self] email in
            self?.endLoadingRelay.accept(())
            guard let email = email else { self?.alertMessageRelay.accept("Something went wrong"); return }
            self?.userEmailRelay.accept(email)
            self?.alertMessageRelay.accept("Email changed")
        }
    }
    
    func changePassword(_ newPassword: String) {
        guard newPassword.isValidPassword() else { return }
        loadingRelay.accept(())
        authManager.changePassword(newPassword) { [weak self] changed in
            self?.endLoadingRelay.accept(())
            guard changed else { self?.alertMessageRelay.accept("Something went wrong"); return }
            self?.alertMessageRelay.accept("Password changed")
        }
    }
    
    func changeCodePassword(_ newCodePassword: String) {
        guard newCodePassword.isFourDigitPassword(), var user = userManager.currentUser.value else { return }
        loadingRelay.accept(())
        user.codePassword = Ciper.seal(newCodePassword)
        userManager.updateUser(user) { [weak self] changed in
            self?.endLoadingRelay.accept(())
            guard changed else { self?.alertMessageRelay.accept("Something went wrong"); return }
            self?.alertMessageRelay.accept("Code-password changed")
        }
    }
    
    func deleteAccount(_ completion: @escaping BoolClosure) {
        guard !creditsManager.currentUserHasCredits, let userId = userManager.currentUser.value?.uid else { alertMessageRelay.accept("We can not delete your account yet. Perhaps, you have and active credits"); completion(false); return }
        authManager.deleteUser { [weak self] deleted in
            guard deleted else { self?.alertMessageRelay.accept("Something went wrong"); completion(false); return  }
            self?.userManager.deleteUser(userId, { deleted in
                guard deleted else { self?.alertMessageRelay.accept("Something went wrong"); completion(false); return }
                completion(deleted)
            })
        }
    }
    
    func logout() {
        authManager.logout()
        userManager.signOut()
    }
}
