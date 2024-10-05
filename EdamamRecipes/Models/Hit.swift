//
//  Hit.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

struct Hit: Decodable {
    let recipe: Recipe
    
    enum CodingKeys: String, CodingKey {
        case recipe
    }
}
