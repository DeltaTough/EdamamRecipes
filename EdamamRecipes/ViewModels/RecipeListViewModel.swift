//
//  RecipeListViewModel.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

final class RecipeListViewModel {
    @Published var recipes: [Recipe] = []
    @Published var error: Error?
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchRecipes(query: String) async {
        do {
            let endpoint = Endpoint(
                queryItems: [
                    URLQueryItem(name: "app_id", value: EnvironmentVariables.apiId),
                    URLQueryItem(name: "app_key", value: EnvironmentVariables.apiKey),
                    URLQueryItem(name: "q", value: query),
                    URLQueryItem(name: "type", value: "public")
                ]
            )
            let results: WebResponse = try await apiClient.fetch(endpoint)
            self.recipes = results.hits.map { $0.recipe }
        } catch {
            self.error = error
        }
    }
}
