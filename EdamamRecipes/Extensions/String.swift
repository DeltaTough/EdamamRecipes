//
//  String.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 12/10/2024.
//

import CryptoKit
import Foundation

extension String {
    // This will return a SHA256 hash for the string
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
