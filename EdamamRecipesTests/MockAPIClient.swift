//
//  MockAPIClient.swift
//  EdamamRecipesTests
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

class MockAPIClient: APIClientProtocol {
    var mockResult: Any?
    var mockError: Error?
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let error = mockError {
            throw error
        }
        guard let result = mockResult as? T else {
            throw APIError.decodingError(NSError(domain: "MockError", code: 0, userInfo: nil))
        }
        return result
    }
}
