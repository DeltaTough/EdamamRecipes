//
//  MockURLSession.swift
//  EdamamRecipesTests
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        guard let data = mockData, let response = mockResponse else {
            throw APIError.invalidResponse
        }
        return (data, response)
    }
}
