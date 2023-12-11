//
//  ProfileAction.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation
import UIKit

enum ProfileAction: Int, CaseIterable {
    case changePhoto = 0
    case changeEmail
    case changePassword
    case changeCodePassword
    case deleteAccount
    
    var localizedTitle: String {
        switch self {
        case .changePhoto:
            return "Change profile picture"
        case .changeEmail:
            return "Change E-Mail"
        case .changePassword:
            return "Change password"
        case .changeCodePassword:
            return "Change code-password"
        case .deleteAccount:
            return "Delete account"
        }
    }
    
    var associatedColor: UIColor {
        switch self {
        case .changePhoto:
            return .label
        case .changeEmail:
            return .label
        case .changePassword:
            return .label
        case .changeCodePassword:
            return .label
        case .deleteAccount:
            return .red
        }
    }
    
    var associatedImage: UIImage? {
        switch self {
        case .changePhoto:
            return UIImage(systemName: "photo.circle")
        case .changeEmail:
            return UIImage(systemName: "person.circle")
        case .changePassword:
            return UIImage(systemName: "lock.circle")
        case .changeCodePassword:
            return UIImage(systemName: "lock.shield")
        case .deleteAccount:
            return UIImage(systemName: "trash.circle")
        }
    }
}
