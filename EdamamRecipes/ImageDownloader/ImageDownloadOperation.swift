//
//  ImageDownloadOperation.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 05/10/2024.
//

import UIKit

class ImageDownloadOperation: Operation {
    private let urlString: String
    var image: UIImage?
    let cache: ImageCache
    
    init(urlString: String, cache: ImageCache) {
        self.urlString = urlString
        self.cache = cache
    }
    
    override func main() {
        // Ensure the operation is not cancelled before starting
        if isCancelled { return }
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            if !isCancelled, let downloadedImage = UIImage(data: data) {
                self.image = downloadedImage
                cache.cacheImage(downloadedImage, forKey: urlString)
            }
        } catch {
            print("Image download failed: \(error)")
        }
    }
}
