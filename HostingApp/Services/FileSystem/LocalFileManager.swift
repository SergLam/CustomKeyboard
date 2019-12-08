//
//  FileManager.swift
//  HostingApp
//
//  Created by Serg Liamthev on 08.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class LocalFileManager {
    
    private static let appCacheDirectoryName = Bundle.main.bundleIdentifier ?? "CustomKeyboard"
    
    private let manager = FileManager.default
    
    var cacheDirectoryURL: URL? {
        
        guard let cacheDirectory = manager.urls(for: .cachesDirectory,
                                                in: .userDomainMask).first else {
                                                    assertionFailure("Unable to get cache directory")
                                                    return nil
        }
        let folderURL = cacheDirectory.appendingPathComponent(LocalFileManager.appCacheDirectoryName)
        return manager.fileExists(atPath: folderURL.path) ? folderURL : nil
    }
    
    func saveFileToCache(fileName: String, data: Data, fileType: CacheFileType) -> String? {
        
        guard let cacheDirectory = createSubFolderInCacheDirectory(folderName: LocalFileManager.appCacheDirectoryName) else {
            assertionFailure("Unable to get cache directory")
            return nil
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(fileName+".\(fileType.rawValue)")
        
        if manager.fileExists(atPath: fileURL.path) {
            do {
                try manager.removeItem(atPath: fileURL.path)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        
        do {
            try data.write(to: fileURL)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return fileURL.lastPathComponent
    }
    
    func loadDataFromCache(fileName: String) -> Data? {
        
        guard let cacheDirectory = cacheDirectoryURL else {
            assertionFailure("Unable to get cache directory")
            return nil
        }
        
        let imageUrl = cacheDirectory.appendingPathComponent(fileName)
        do {
            return try Data(contentsOf: imageUrl)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return nil
    }
    
    func removeFile(filePath: String) {
        
        do {
            try manager.removeItem(atPath: filePath)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    func createSubFolderInCacheDirectory(folderName: String) -> URL? {
        
        guard let cacheDirectory = manager.urls(for: .cachesDirectory,
                                                in: .userDomainMask).first else {
                                                    assertionFailure("Unable to get cache directory")
                                                    return nil
        }
        
        let folderURL = cacheDirectory.appendingPathComponent(folderName)
        // If folder URL does not exist, create it
        if !manager.fileExists(atPath: folderURL.path) {
            do {
                // Attempt to create folder
                try manager.createDirectory(atPath: folderURL.path,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            } catch {
                // Creation failed.
                assertionFailure(error.localizedDescription)
                return nil
            }
        }
        // Folder either exists, or was created. Return URL
        return folderURL
    }
    
}

