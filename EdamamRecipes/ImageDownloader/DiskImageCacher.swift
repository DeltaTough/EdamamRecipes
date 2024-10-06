//
//  DiskImageCacher.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 06/10/2024.
//

import UIKit

class DiskImageCacher {
    private let maxCacheSize: Int
    private let cacheDirectory: URL
    
    init(maxCacheSize: Int = 100 * 1024 * 1024) {
        self.maxCacheSize = maxCacheSize
        
        let fileManager = FileManager.default
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("ImageCache", isDirectory: true)
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        let imagePath = pathForKey(key)
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        try? data.write(to: imagePath)
        clearCacheIfNeeded()
    }
    
    func loadImage(forKey key: String) -> UIImage? {
        let imagePath = pathForKey(key)
        guard FileManager.default.fileExists(atPath: imagePath.path) else { return nil }
        return UIImage(contentsOfFile: imagePath.path)
    }
    
    private func clearCacheIfNeeded() {
        let cacheSize = getCacheSize()
        if cacheSize > maxCacheSize {
            clearOldCache()
        }
    }
    
    private func getCacheSize() -> Int {
        var totalSize = 0
        let fileManager = FileManager.default
        
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey], options: []) {
            for file in files {
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += fileSize
                }
            }
        }
        
        return totalSize
    }
    
    private func clearOldCache() {
        let fileManager = FileManager.default
        
        if let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: []) {
            let sortedFiles = files.sorted { (file1, file2) -> Bool in
                let date1 = (try? file1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                let date2 = (try? file2.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
                return date1 < date2
            }
            
            var totalSize = getCacheSize()
            for file in sortedFiles {
                if totalSize <= maxCacheSize {
                    break
                }
                
                if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize -= fileSize
                    try? fileManager.removeItem(at: file)
                }
            }
        }
    }
    
    private func pathForKey(_ key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }
}
