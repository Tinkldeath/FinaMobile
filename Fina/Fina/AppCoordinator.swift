//
//  AppCoordinator.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation
import UIKit

protocol AppCoordinator {
    func start()
    func coordinateSignIn()
    func coordinateSignUp()
    func coordinatePrepare()
    func coordinateTwoFactorAuth()
    func coordinateMain()
    func back()
}

final class DefaultAppCoordinator: AppCoordinator {
    
    private var window: UIWindow?
    
    private let navigationController: UINavigationController = {
        let nc = UINavigationController()
        nc.isNavigationBarHidden = true
        return nc
    }()
    
    init(_ window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let authManager = ManagerFactory.shared.authManager
        if authManager.isPreviouslySigned {
            self.coordinateTwoFactorAuth()
        } else {
            self.coordinateSignIn()
        }
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func coordinateTwoFactorAuth() {
        guard let vc: TwoFactorAuthViewController = UIStoryboard.instantiateViewController(identifier: "TwoFactorAuthViewController", storyboard: .auth) else { return }
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func coordinatePrepare() {
        guard let vc: PrepareViewController = UIStoryboard.instantiateViewController(identifier: "PrepareViewController", storyboard: .auth) else { return }
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func coordinateMain() {
        guard let vc: UIViewController = UIStoryboard.instantiateViewController(identifier: "MainViewController", storyboard: .main) else { return }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func coordinateSignIn() {
        guard let vc: SignInViewController = UIStoryboard.instantiateViewController(identifier: "SignInViewController", storyboard: .auth) else { return }
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func coordinateSignUp() {
        guard let vc: SignUpViewController = UIStoryboard.instantiateViewController(identifier: "SignUpViewController", storyboard: .auth) else { return }
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func back() {
        navigationController.popViewController(animated: true)
    }
}
