//
//  URLExtension.swift
//  FoodViewer
//
//  Created by arnaud on 05/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

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
}
