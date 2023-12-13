//
//  BaseTabBarController.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    var coordinator: AppCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navigationControllers = viewControllers?.compactMap({ $0 as? UINavigationController }) else { return }
        let baseControllers = navigationControllers.compactMap({ $0.viewControllers.first as? BaseViewController })
        baseControllers.forEach({ $0.coordinator = self.coordinator })
    }
}
