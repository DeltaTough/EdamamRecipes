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
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from url: URL) async throws -> UIImage? {
        let urlString = url.absoluteString as NSString
        
        if let cachedImage = cache.object(forKey: urlString) {
            return cachedImage
        }
        
        let data = try await URLSession.shared.data(from: url).0
        
        guard let image = UIImage(data: data) else { return nil }
        
        cache.setObject(image, forKey: urlString)
        
        return image
    }
}
