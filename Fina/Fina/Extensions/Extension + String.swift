//
//  Extension + String.swift
//  FinaMobile
//
//  Created by Dima on 19.10.23.
//

import Foundation


extension String {

    func masked(matching regexPattern: String, with template: String = "*") throws -> String {
        let regex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }
    
    func asHiddenCardNumber() -> String? {
        guard self.count == 16 else { return nil }
        let start = self.prefix(2)
        let end = self.suffix(2)
        let middle = "**   ****   ****   **"
        return "\(start)\(middle)\(end)"
    }

    func isBelarusPassportNumber() -> Bool {
        // Формат BY1234567
        let passportNumberRegex = #"^[A-Z]{2}\d{7}$"#
        let passportNumberPredicate = NSPredicate(format: "SELF MATCHES %@", passportNumberRegex)
        return passportNumberPredicate.evaluate(with: self)
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        // Пароль должен содержать как минимум 8 символов, включая хотя бы одну цифру и одну заглавную букву
        let passwordRegex = "(?=.*[A-Z])(?=.*[0-9]).{8,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: self)
    }
    
    func isFourDigitPassword() -> Bool {
        let passwordRegex = "^[0-9]{4}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: self)
    }
    
    func isValidCvv() -> Bool {
        let cvvRegex = "^[0-9]{3}$"
        let cvvTest = NSPredicate(format: "SELF MATCHES %@", cvvRegex)
        return cvvTest.evaluate(with: self)
    }
    
    static func generateUniqueCardNumber() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmss"
        let timestamp = dateFormatter.string(from: Date())
        
        let randomNumber = String(format: "%04d", arc4random_uniform(10000))
        
        let cardNumber = timestamp + randomNumber
        return cardNumber
    }
    
    static func generateRandomNumbers(_ count: Int) -> String {
        var result = ""
        for _ in 0..<count {
            result += "\(Int.random(in: 0...9))"
        }
        return result
    }
    
    static func generateIBAN(for accountNumber: String) -> String {
        let countryCode = "BY"
        let checkDigits = "42"
        let bankCode = "4242"
        return "\(countryCode)\(checkDigits)\(bankCode)\(accountNumber)"
    }

    static func generateContractNumber() -> String {
        return String.generateRandomNumbers(13)
    }

    static func generateAccountNumber() -> String {
        return String.generateRandomNumbers(26)
    }
    
}
