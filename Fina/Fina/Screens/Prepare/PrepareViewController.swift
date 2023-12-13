//
//  PrepareViewController.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import UIKit

class PrepareViewController: BaseViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await DefaultManagerFactory.shared.initialize()
            await MainActor.run(body: { [weak self] in
                self?.coordinator?.coordinateMain()
            })
        }
    }
}
