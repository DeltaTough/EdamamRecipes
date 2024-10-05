//
//  ImageCellViewModel.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import UIKit

final class ImageCellViewModel {
    private let imageLoader: ImageDownloader
    
    init(imageLoader: ImageDownloader) {
        self.imageLoader = imageLoader
    }
    
    func loadImage(for url: URL) async throws -> UIImage? {
        return try await imageLoader.loadImage(from: url)
    }
}
