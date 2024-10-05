//
//  Recipe.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

struct Recipe: Decodable {
    let uri: String
    let recipeName: String
    let imageURL: URL
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uri = try container.decode(String.self, forKey: .uri)
        self.recipeName = try container.decode(String.self, forKey: .recipeName)
        
        let urlString = try container.decode(String.self, forKey: .imageURL)
        guard let validURL = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: .imageURL, in: container, debugDescription: "Invalid URL string")
        }
        self.imageURL = validURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case uri
        case recipeName = "label"
        case imageURL = "image"
    }
}
