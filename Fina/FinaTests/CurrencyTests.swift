//
//  FinaTests.swift
//  FinaTests
//
//  Created by Dima on 13.12.23.
//

import XCTest
import RxTest
import RxRelay
@testable import Fina

final class CurrencyTests: XCTestCase {

    func testExchange() throws {
        let bynToUsdExchange = Currency.exchange(amount: 100, from: .byn, to: .usd)
        let bynToEurExchange = Currency.exchange(amount: 100, from: .byn, to: .eur)
        let bynToRubExchange = Currency.exchange(amount: 100, from: .byn, to: .rub)
        XCTAssertEqual(bynToUsdExchange, 31.86)
        XCTAssertEqual(bynToEurExchange, 29.24)
        XCTAssertEqual(bynToRubExchange, 2857.14)
        let usdToEurExchange = Currency.exchange(amount: 100, from: .usd, to: .eur)
        let usdToRubExchange = Currency.exchange(amount: 100, from: .usd, to: .rub)
        let usdToBynExchange = Currency.exchange(amount: 100, from: .usd, to: .byn)
        XCTAssertEqual(usdToEurExchange, 91.76)
        XCTAssertEqual(usdToRubExchange, 8966.86)
        XCTAssertEqual(usdToBynExchange, 313.84)
        let eurToUsdExchange = Currency.exchange(amount: 100, from: .eur, to: .usd)
        let eurToRubExchange = Currency.exchange(amount: 100, from: .eur, to: .rub)
        let eurToBynExchange = Currency.exchange(amount: 100, from: .eur, to: .byn)
        XCTAssertEqual(eurToUsdExchange, 108.99)
        XCTAssertEqual(eurToRubExchange, 9772.57)
        XCTAssertEqual(eurToBynExchange, 342.04)
        let rubToUsdExchange = Currency.exchange(amount: 100, from: .rub, to: .usd)
        let rubToEurExchange = Currency.exchange(amount: 100, from: .rub, to: .eur)
        let rubToBynExchange = Currency.exchange(amount: 100, from: .rub, to: .usd)
        XCTAssertEqual(rubToUsdExchange, 1.12)
        XCTAssertEqual(rubToEurExchange, 1.02)
        XCTAssertEqual(rubToBynExchange, 1.12)
    }

}
