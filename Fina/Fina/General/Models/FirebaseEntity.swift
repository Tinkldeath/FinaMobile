//
//  FirebaseEntity.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation

protocol FirebaseEntity {
    
    static func collection() -> String
    init?(_ from: [String: Any])
    func toEntity() -> [String: Any]
}
