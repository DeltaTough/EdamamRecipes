//
//  ImageCache.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 05/10/2024.
//

import UIKit

final class ImageCache {
    private let cacheDirectory: URL
    private let maxDiskSize: UInt64 = 100 * 1024 * 1024
    
    init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        let hashedFileName = key.sha256() + ".jpg"
        let fileURL = cacheDirectory.appendingPathComponent(hashedFileName)
        if let data = image.jpegData(compressionQuality: 1.0) {
            try? data.write(to: fileURL)
        }
        clearCacheIfNeeded()
    }
    
    func getImage(forKey key: String) -> UIImage? {
        let hashedFileName = key.sha256() + ".jpg"
        let fileURL = cacheDirectory.appendingPathComponent(hashedFileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
    
    func clearCacheIfNeeded() {
        let totalSize = calculateTotalDiskSize()
        
        if totalSize > maxDiskSize {
            removeOldestFilesUntilBelowLimit()
        }
    }
    
    func calculateTotalDiskSize() -> UInt64 {
        var totalSize: UInt64 = 0
        
        let contents = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
        
        contents?.forEach { fileURL in
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += UInt64(fileSize)
            }
        }
        
        return totalSize
    }
    
    func removeOldestFilesUntilBelowLimit() {
        var totalSize = calculateTotalDiskSize()
        
        let contents = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)
        
        let sortedContents = contents?.sorted {
            let firstDate = try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
            let secondDate = try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
            return firstDate ?? Date.distantPast < secondDate ?? Date.distantPast
        }
        
        sortedContents?.forEach { fileURL in
            try? FileManager.default.removeItem(at: fileURL)
            totalSize = calculateTotalDiskSize()
            
            if totalSize <= maxDiskSize {
                return
            }
        }
    }
}
