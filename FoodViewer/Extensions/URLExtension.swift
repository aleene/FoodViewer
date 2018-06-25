//
//  URLExtension.swift
//  FoodViewer
//
//  Created by arnaud on 05/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    
    static func createDirectory(with name: String) -> URL? {
        let fileManager = FileManager.default
        if let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = directory.appendingPathComponent(name)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    assert(true, "URLExtension: Not possible to create a directory")
                }
            } else {
                assert(true, "URLExtension: Not possible to create a directory")
            }
        }
        return nil
    }
    
    typealias ImageCacheCompletion = (UIImage) -> Void
    
    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
        let image = ImageCache.shared.object(forKey: absoluteString as NSString)
        print("cached image", absoluteString, image != nil ? "available" : "NOT available")
        return image
    }
    
    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(completion: @escaping ImageCacheCompletion) {
        let task = URLSession.shared.dataTask(with: self) {
            data, response, error in
            if error == nil {
                if let data = data,
                    let image = UIImage(data: data) {
                    ImageCache.shared.setObject(
                        image,
                        forKey: self.absoluteString as NSString,
                        cost: data.count)
                    DispatchQueue.main.async() {
                        completion(image)
                    }
                }
            }
        }
        task.resume()
    }

}
