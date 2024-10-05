//
//  Endpoint.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

struct Endpoint {
    let queryItems: [URLQueryItem]?
    
    init(queryItems: [URLQueryItem]? = nil) {
        self.queryItems = queryItems
    }
}
