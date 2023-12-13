//
//  Constants.swift
//  Fina
//
//  Created by Dima on 10.12.23.
//

import Foundation


enum Constants {
    
    enum Auth {
        static let kAuthPrefersBiometric = "com.finaMobile.Auth.prefersBiometric"
    }
    
    enum Credit {
        static func generateCreditAgreement(_ borrowerName: String, _ amountString: String, _ duration: Int, _ guarantorPassportId: String) -> String {
            let conent = """
CONSUMER LOAN AGREEMENT

This Consumer Loan Agreement (the "Agreement") is made and entered into on \(Date.now.formatted()) (the "Effective Date") by \(borrowerName) and between FinaMobile Inc., having its principal place of business at Minsk City (the "Lender"), and \(borrowerName), having its principal place of business at Minsk City (the "Borrower").

Loan Amount and Interest Rate

The Lender agrees to loan the Borrower the amount of \(amountString) (the "Loan Amount") at a fixed annual interest rate of 19% (the "Interest Rate").

Loan Term and Payment Options

The Borrower shall repay the Loan Amount in \(duration) (the "Loan Term") with the option to choose between a differentiated or annuity payment plan (the "Payment Plan").

Late Payment

If the Borrower fails to make a payment on or before the due date, the Borrower shall pay a penalty fee of 1% of the monthly payment amount per day of delay (the "Penalty Fee") until the late payment is made.

Default and Collections

If the Borrower fails to repay the Loan Amount within one month of the due date, the Borrower's account will be considered in default and will be blocked. The Lender will notify both the Borrower and the Guarantor of the default and seek legal remedies to recover the Loan Amount. The Lender will hold the Guarantor responsible for payment of the outstanding balance if the Borrower fails to repay the Loan Amount.

Guarantor

An individual who is an adult and solvent citizen of the Republic of Belarus (the "Guarantor") agrees to be responsible for the repayment of the consumer loan in the event that the borrower is unable to fulfill their obligations.
Guarantor passport number: \(guarantorPassportId)

Governing Law

This Agreement shall be governed by and construed in accordance with the laws of the Republic of Belarus. Any disputes arising under or in connection with this Agreement shall be resolved in the courts of Minsk.

IN WITNESS WHEREOF, the parties have executed this Agreement as of the date first above written.

Fina Mobile Inc. and \(borrowerName)
"""
            return conent
        }
    }
}
