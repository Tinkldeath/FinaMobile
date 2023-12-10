//
//  Extension + LocalAuthentication.swift
//  FinaMobile
//
//  Created by Dima on 9.12.23.
//

import Foundation
import LocalAuthentication
import UIKit

extension LAContext {
    enum BiometricType: String {
        case none = "None"
        case touchID = "Touch Id"
        case faceID = "Face Id"
        
        var associatedImage: UIImage? {
            switch self {
            case .faceID:
                return UIImage(systemName: "faceid")
            case .touchID:
                return UIImage(systemName: "touchid")
            default:
                return nil
            }
        }
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                #warning("Handle new Biometric type")
            }
        }
        return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
}
