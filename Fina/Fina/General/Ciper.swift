//
//  Security.swift
//  FinaMobile
//
//  Created by Dima on 4.12.23.
//

import Foundation
import CryptoKit


struct Ciper {
    
    private static let masterKey: SymmetricKey = SymmetricKey(data: Data([136, 56, 137, 227, 168, 88, 48, 75, 53, 36, 61, 23, 229, 219, 108, 88, 15, 160, 13, 98, 170, 183, 23, 41, 189, 3, 82, 68, 181, 210, 48, 203]))
    
    static func seal(_ data: String) -> Data {
        guard let dataToSeal = data.data(using: .utf8) else { return Data() }
        let sealedBox = try? AES.GCM.seal(dataToSeal, using: masterKey)
        return sealedBox?.combined ?? Data()
    }
    
    static func unseal(_ data: Data) -> String {
        guard let sealedBox = try? AES.GCM.SealedBox(combined: data) else { return "" }
        let decryptedData = try? AES.GCM.open(sealedBox, using: masterKey)
        return String(data: decryptedData ?? Data(), encoding: .utf8) ?? ""
    }
    
}
