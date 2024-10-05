//
//  APIError.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    
    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.decodingError, .decodingError):
            return false
        default:
            return false
        }
    }
}
