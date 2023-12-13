//
//  CreditSchedule.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

struct CreditSchedule {
    
    var uid: String
    var creditId: String
    var date: Date
    var isPayed: Bool
    var percentPayment: Double
    var loanPayment: Double
    var monthPayment: Double
    var overbay: Double
    
    var totalSum: Double {
        return monthPayment + overbay
    }
}

extension CreditSchedule: FirebaseEntity {
    
    static func collection() -> String {
        return "creditSchedule"
    }
    
    init?(_ from: [String : Any]) {
        guard let uid = from["uid"] as? String, let creditId = from["creditId"] as? String, let dateRaw = from["date"] as? TimeInterval, let isPayed = from["isPayed"] as? Bool, let percentPayment = from["percentPayment"] as? Double, let loanPayment = from["loanPayment"] as? Double, let monthPayment = from["monthPayment"] as? Double, let overbay = from["overbay"] as? Double else { return nil }
        let date = Date(timeIntervalSince1970: dateRaw)
        self.uid = uid
        self.creditId = creditId
        self.date = date
        self.isPayed = isPayed
        self.percentPayment = percentPayment
        self.loanPayment = loanPayment
        self.monthPayment = monthPayment
        self.overbay = overbay
    }
    
    func toEntity() -> [String : Any] {
        return [
            "uid": uid,
            "creditId": creditId,
            "date": date.timeIntervalSince1970,
            "isPayed": isPayed,
            "percentPayment": percentPayment,
            "loanPayment": loanPayment,
            "monthPayment": monthPayment,
            "overbay": overbay
        ]
    }
}

extension CreditSchedule {
    
    static func fromCalculatorResults(_ results: CreditCountResults) -> [CreditSchedule] {
        var items = [CreditSchedule]()
        var date = Date.now
        for i in 0..<results.monthPayments.count {
            date = date.appendMonth()
            let scheduleItem = CreditSchedule(uid: "", creditId: "", date: date, isPayed: false, percentPayment: results.percentPayments[i], loanPayment: results.loanPayments[i], monthPayment: results.monthPayments[i], overbay: 0)
            items.append(scheduleItem)
        }
        return items
    }
}
