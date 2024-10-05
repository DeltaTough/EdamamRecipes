//
//  RecipeListCollectionViewController.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 03/10/2024.
//

import Combine
import UIKit

final class RecipeListCollectionViewController: UIViewController {
    
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private let imageLoader = DefaultImageDownloader()
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: RecipeListViewModel
    
    init(viewModel: RecipeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                              NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        collectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: "RecipeCell")
        viewModel.$recipes
            .receive(on: RunLoop.main)
            .sink { [weak self] recipes in
                guard let self = self else { return }
                guard !recipes.isEmpty else {
                    return
                }
                collectionView?.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$error
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                if error != nil {
                    self.showAlertMessage(title: "", message: "No recipes found. Please type another recipe.")
                    viewModel.recipes = []
                    collectionView.reloadData()
                }
                
            }
            .store(in: &cancellables)
    }
}

extension RecipeListCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath) as! RecipeCollectionViewCell
        let imageUrl = viewModel.recipes[indexPath.row].imageURL
        let title = viewModel.recipes[indexPath.row].recipeName
        
        let viewModel = ImageCellViewModel(imageLoader: imageLoader)
        cell.imageView.alpha = 0
        cell.configure(with: viewModel, url: imageUrl, recipeName: title)
        return cell
    }
}

extension RecipeListCollectionViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension RecipeListCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: view.frame.width, height: 160)
    }
}

extension RecipeListCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            Task {
                await viewModel.fetchRecipes(query: text)
            }
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
            collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}
