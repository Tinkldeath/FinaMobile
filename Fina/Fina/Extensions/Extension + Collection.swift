//
//  Extension + Collection.swift
//  FinaMobile
//
//  Created by Dima on 5.12.23.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
