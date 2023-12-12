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
    
    func appendMonth() -> Date {
        guard let date = Calendar.current.date(byAdding: .month, value: 1, to: self) else { fatalError("Cannot add month to date \(Date.now)") }
        return date
    }
    
    func baseComponents() -> (day: Int, month: Int, year: Int) {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        guard let day = components.day, let month = components.month, let year = components.year else { fatalError("Cannot fetch date components from \(self)") }
        return (day, month, year)
    }
    
    func baseFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
}
