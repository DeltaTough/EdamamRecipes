//
//  APIFetcher.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 02/10/2024.
//

import UIKit

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol APIClientProtocol {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// MARK: - API Client

final actor APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSessionProtocol
    
    init(baseURL: URL, session: URLSessionProtocol = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard var components = URLComponents(
            url: baseURL,
            resolvingAgainstBaseURL: true
        ) else {
            throw APIError.invalidURL
        }
        
        if let queries = endpoint.queryItems {
            for query in queries {
                if queries.first == query {
                    components.queryItems = [query]
                }
                else {
                    components.queryItems?.append(query)
                }
            }
        }
        if let port = components.port, !(0...65535).contains(port) {
            throw APIError.invalidURL
        }
        guard let urlString = components.url?.absoluteString.removingPercentEncoding,
                let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
