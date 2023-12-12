//
//  CreditCalculator.swift
//  Fina
//
//  Created by Dima on 11.12.23.
//

import Foundation

typealias CreditCountResults = (totalSum: Double, percentPayments: [Double], loanPayments: [Double], monthPayments: [Double])

// Потребительский кредит (калькулятор)
struct CreditCalculator {
    
    func count(loanSum: Double, loanPercent: Double, durationMonths: Int, paymentType: Credit.PaymentType) -> CreditCountResults {
        var current = loanSum
        var generalPaymentSum = 0.0
        var percentPayments = [Double]()
        var loanPayments = [Double]()
        var monthPayments = [Double]()
        for _ in 0..<durationMonths {
            let (percentPayment, loanPayment, monthPayment) = paymentType.monthPayment(loanBalance: current, loanSum: loanSum, durationMonths: durationMonths, loanPercent: loanPercent)
            current -= monthPayment
            generalPaymentSum += monthPayment
            percentPayments.append(percentPayment)
            loanPayments.append(loanPayment)
            monthPayments.append(monthPayment)
        }
        switch paymentType {
        case .ann:
            return (round(generalPaymentSum * 100) / 100, percentPayments.sorted(by: >), loanPayments.sorted(), monthPayments)
        case .diff:
            return (round(generalPaymentSum * 100) / 100, percentPayments.sorted(by: >), loanPayments, monthPayments.sorted(by: >))
        }
    }
    
}
