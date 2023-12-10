//
//  Extension + UIStoryboard.swift
//  FinaMobile
//
//  Created by Dima on 9.12.23.
//

import Foundation
import UIKit


extension UIStoryboard {
    
    enum Storyboard: String {
        case main = "Main"
        case auth = "Auth"
    }
    
    static func instantiateViewController<T>(identifier: String, storyboard: Storyboard) -> T? {
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier) as? T
        return vc
    }
    
}
