//
//  ImageCellViewModel.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 04/10/2024.
//

import UIKit

final class RecipeCellViewModel {
    private let imageLoader: ImageDownloader
    private var downloadTask: Task<UIImage?, Never>?
    
    init(imageLoader: ImageDownloader) {
        self.imageLoader = imageLoader
    }
    
    func loadImage(for url: URL) async throws -> UIImage? {
        downloadTask = Task { [weak self] in
            guard let self = self else { return nil }
            do {
                return try await imageLoader.loadImage(from: url)
            } catch {
                return nil
            }
        }
        return await downloadTask?.value
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
    }
}
