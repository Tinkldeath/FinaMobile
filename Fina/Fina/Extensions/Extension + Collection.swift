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
    
    func asSet<T: Hashable>() -> Set<T> {
        guard let self = self as? [T] else { return Set() }
        var set = Set<T>()
        for item in self {
            set.insert(item)
        }
        return set
    }
}
