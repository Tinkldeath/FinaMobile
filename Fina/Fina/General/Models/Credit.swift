//
//   Credit.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

struct Credit {
    
    var uid: String
    var ownerId: String
    var bankAccountId: String // С какого счёта списываем
    var durationMonths: Int // Продолжительность в месяцах
    var totalSum: Double // Сумма с учётом всех процентов
    var sum: Double // Исходная сумма
    var currency: Currency
    var paymentType: PaymentType // Тип выплаты
    var percentYear: Double // Процент годовых
    var hasDebt: Bool // Имеет ли задолженность
    var isPayed: Bool // Уплачен ли
    var dateAdded: Date
    var debtDays: [Date] // Дни начисления пени, если дня нет, а задолженность есть - начисляем
    var schedule: [String] // Расписание кредита
    var guarantor: Data // Поручитель
}

extension Credit {
    
    enum PaymentType: String {
        
        case diff = "Differentiated payments" // Дифференцированые выплаты
        case ann = "Annuity payments" // Аннуитетные выплаты
        
        func monthPayment(loanBalance: Double, loanSum: Double, durationMonths: Int, loanPercent: Double) -> (percentPayment: Double, loanPayment: Double, monthPayment: Double) {
            let monthPercent = loanPercent / 1200
            switch self {
            case .diff:
                let percentPayment = abs(loanBalance) * monthPercent
                let result = loanSum / Double(durationMonths) + percentPayment
                let loanPayment = result - percentPayment
                return (round(percentPayment * 100) / 100, round(loanPayment * 100) / 100, round(result * 100) / 100)
            case .ann:
                let percentPayment = abs(loanBalance) * monthPercent
                let result = (loanSum * monthPercent * (pow((1 + monthPercent), Double(durationMonths)))) / (pow((1 + monthPercent), Double(durationMonths)) - 1)
                let loanPayment = result - percentPayment
                return (round(percentPayment * 100) / 100, round(loanPayment * 100) / 100, round(result * 100) / 100)
            }
        }
    }
    
}

extension Credit: FirebaseEntity {
    
    static func collection() -> String {
        return "credits"
    }
    
    init?(_ from: [String : Any]) {
        guard let uid = from["uid"] as? String, let ownerId = from["ownerId"] as? String, let bankAccountId = from["bankAccountId"] as? String, let durationMonths = from["durationMonths"] as? Int, let totalSum = from["totalSum"] as? Double, let sum = from["sum"] as? Double, let paymentTypeRaw = from["paymentType"] as? String, let paymentType = PaymentType(rawValue: paymentTypeRaw), let percentYear = from["percentYear"] as? Double, let hasDebt = from["hasDebt"] as? Bool, let isPayed = from["isPayed"] as? Bool, let debtDaysRaw = from["debtDays"] as? [TimeInterval], let schedule = from["schedule"] as? [String], let dateAddedRaw = from["dateAdded"] as? TimeInterval, let currencyRaw = from["currency"] as? String, let currency = Currency(rawValue: currencyRaw), let guarantor = from["guarantor"] as? Data else { return nil }
        let debtDays = debtDaysRaw.map({ Date(timeIntervalSince1970: $0) })
        let dateAdded = Date(timeIntervalSince1970: dateAddedRaw)
        self.uid = uid
        self.ownerId = ownerId
        self.durationMonths = durationMonths
        self.bankAccountId = bankAccountId
        self.sum = sum
        self.totalSum = totalSum
        self.paymentType = paymentType
        self.percentYear = percentYear
        self.debtDays = debtDays
        self.schedule = schedule
        self.hasDebt = hasDebt
        self.isPayed = isPayed
        self.dateAdded = dateAdded
        self.currency = currency
        self.guarantor = guarantor
    }
    
    func toEntity() -> [String : Any] {
        return [
            "uid": self.uid,
            "ownerId": self.ownerId,
            "dateAdded": self.dateAdded.timeIntervalSince1970,
            "durationMonths": self.durationMonths,
            "bankAccountId": self.bankAccountId,
            "currency": self.currency.rawValue,
            "sum": self.sum,
            "totalSum": self.totalSum,
            "paymentType": self.paymentType.rawValue,
            "percentYear": self.percentYear,
            "debtDays": self.debtDays.map({ $0.timeIntervalSince1970 }),
            "schedule": self.schedule,
            "hasDebt": self.hasDebt,
            "isPayed": self.isPayed,
            "guarantor": guarantor
        ]
    }
}

extension Credit: Hashable, Equatable {
    
    static func == (lhs: Credit, rhs: Credit) -> Bool {
        return lhs.uid == rhs.uid
    }
    
}
