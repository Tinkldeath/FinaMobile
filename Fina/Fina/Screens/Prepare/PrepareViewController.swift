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
            try? await Task.sleep(nanoseconds: 10_000_000_000)
            self.coordinator?.coordinateMain()
        }
    }

}
