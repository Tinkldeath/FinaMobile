//
//  Extension + Date.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

extension Date {

    static func monthSinceFiveYears() -> Date {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .year, value: 5, to: Date.now) else { fatalError("Cannot add five years to date \(Date.now)") }
        return date
    }
    
    func monthYear() -> String {
        let components = Calendar.current.dateComponents([.month, .year], from: self)
        guard let month = components.month, let year = components.year else { return "" }
        return "\(month)/\(year)"
    }
}
