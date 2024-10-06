//
//  ImageDownloader.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 02/10/2024.
//

import UIKit

protocol ImageDownloader {
    func loadImage(from url: URL) async throws -> UIImage?
}

final class DefaultImageDownloader: ImageDownloader {
    private let cache: DiskImageCacher
    
    init(cache: DiskImageCacher) {
        self.cache = cache
    }
    
    func loadImage(from url: URL) async throws -> UIImage? {
        let urlString = url.absoluteString
        
        if let cachedImage = cache.loadImage(forKey: urlString) {
            return cachedImage
        }
        
        let data = try await URLSession.shared.data(from: url).0
        
        guard let image = UIImage(data: data) else { return nil }
        
        cache.saveImage(image, forKey: urlString)
        
        return image
    }
}
