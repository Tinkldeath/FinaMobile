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
        guard let vc: SignInViewController = UIStoryboard.instantiateViewController(identifier: "SignInViewController", storyboard: .auth) else { return }
        navigationController.pushViewController(vc, animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func coordinateSignIn() {
        
    }
    
    func coordinateSignUp() {
        
    }
    
    func back() {
        
    }
}
