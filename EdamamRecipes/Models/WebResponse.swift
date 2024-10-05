//
//  WebResponse.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import Foundation

struct WebResponse: Decodable {
    let from: Int
    let to: Int
    let count: Int
    let links: Links
    let hits: [Hit]
    
    enum CodingKeys: String, CodingKey {
        case from
        case to
        case count
        case links = "_links"
        case hits
    }
}
