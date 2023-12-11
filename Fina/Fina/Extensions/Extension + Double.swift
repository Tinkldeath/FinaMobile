//
//  Extension + Double.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

extension Double {
    
    func toRounded() -> Double {
        return Foundation.round(self * 100) / 100
    }
    
}
