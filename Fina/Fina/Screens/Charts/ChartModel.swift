//
//  ChartModel.swift
//  Fina
//
//  Created by Dima on 13.12.23.
//

import Foundation
import Charts

struct ChartModel {
    var bankAccountId: String
    var bankAccount: String
    var currency: Currency
    var transactions: [Transaction]
    
    func incomeChartDataEntries() -> [BarChartDataEntry] {
        let nowComponents = Date.now.baseComponents()
        var entries = [BarChartDataEntry]()
        for i in 1...12 {
            let transactions = transactions.filter({ $0.date.baseComponents().year == nowComponents.year && $0.date.baseComponents().month == i && $0.recieverBankAccount == bankAccountId && ($0.transactionType == .income || $0.transactionType == .transfer) })
            var sum = 0.0
            for transaction in transactions {
                sum += Currency.exchange(amount: transaction.sum, from: transaction.currency, to: currency)
            }
            let entry = BarChartDataEntry(x: Double(i), y: sum)
            entries.append(entry)
        }
        return entries
    }
    
    func outcomeChartDataEntries() -> [BarChartDataEntry] {
        let nowComponents = Date.now.baseComponents()
        var entries = [BarChartDataEntry]()
        for i in 1...12 {
            let transactions = transactions.filter({ $0.date.baseComponents().year == nowComponents.year && $0.date.baseComponents().month == i && $0.senderBankAccount == bankAccountId && ($0.transactionType == .payment || $0.transactionType == .transfer ) })
            var sum = 0.0
            for transaction in transactions {
                sum += Currency.exchange(amount: transaction.sum, from: transaction.currency, to: currency)
            }
            let entry = BarChartDataEntry(x: Double(i), y: sum)
            entries.append(entry)
        }
        return entries
    }
    
    static let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
}
