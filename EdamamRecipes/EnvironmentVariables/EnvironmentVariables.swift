//
//  EnvironmentVariables.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 23/01/2025.
//

import Foundation

struct EnvironmentVariables {
    
    static var apiId: String {
        "API_ID".infoPlist ?? ""
    }
    
    static var apiKey: String {
        "API_KEY".infoPlist ?? ""
    }
    
}

private extension String {

    var infoPlist: String? {
        guard let value = Bundle.main.infoDictionary?[self] as? String else {
            return nil
        }
        guard !value.isEmpty else {
            return nil
        }
        return value
    }
    
}
