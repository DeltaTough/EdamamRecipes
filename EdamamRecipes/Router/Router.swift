//
//  Router.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 02/10/2024.
//

import UIKit

protocol RouterProtocol {
    func navigate(to route: Route)
}

enum Route {
    case recipeList
}

final class AppRouter: RouterProtocol {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func navigate(to route: Route) {
        switch route {
        case .recipeList:
            let viewModel = RecipeListViewModel(
                apiClient: APIClient(baseURL: URL(string: "https://api.edamam.com/api/recipes/v2")!)
            )
            let vc = RecipeListCollectionViewController(viewModel: viewModel)
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
