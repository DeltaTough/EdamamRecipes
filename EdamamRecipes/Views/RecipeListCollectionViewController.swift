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
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: RecipeListViewModel
    private let downloadQueue = OperationQueue()
    private var downloadOperations: [IndexPath: ImageDownloadOperation] = [:]
    private var isRotating = false
    private lazy var imageCache: ImageCache = {
        let cache = ImageCache()
        return cache
    }()
    
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
        downloadQueue.maxConcurrentOperationCount = 5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isRotating {
            isRotating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.isRotating = false
            }
        }
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
        
        if let cachedImage = imageCache.getImage(forKey: imageUrl.absoluteString) {
            cell.configure(image: cachedImage, recipeName: title)
        } else {
            cell.configure(image: nil, recipeName: title) // Clear the image view while loading
            
            // Cancel any existing operation for this indexPath
            if let existingOperation = downloadOperations[indexPath] {
                existingOperation.cancel()
                downloadOperations.removeValue(forKey: indexPath)
            }
            
            // Create a new image download operation
            let operation = ImageDownloadOperation(urlString: imageUrl.absoluteString, cache: imageCache)
            
            Task {
                // Start the operation asynchronously using async/await
                await operation.asyncStart(on: downloadQueue)
                
                // Once the operation is complete, update the cell if it's still visible
                if let visibleIndexPath = collectionView.indexPath(for: cell), visibleIndexPath == indexPath {
                    cell.configure(image: operation.image, recipeName: title)
                }
                
                downloadOperations.removeValue(forKey: indexPath)
            }
            
            downloadOperations[indexPath] = operation
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let operation = downloadOperations[indexPath] {
            operation.cancel()
            downloadOperations.removeValue(forKey: indexPath)
        }
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
            collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
}
