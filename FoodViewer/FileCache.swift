//
//  FileCache.swift
//  cacheTest
//
//  Created by Maksim Kita on 12/28/17.
//  Copyright © 2017 Maksim Kita. All rights reserved.
//

import Foundation


internal class FileCache<Key:Hashable,Value:ItemCacheProtocol> {
    
    let destination:URL
    let journalDestinition:URL
    
    private let fileCacheQueue = OperationQueue()
    
    init(cacheDestination:FileCacheDestination) {
        switch cacheDestination {
        case .temporary:
            self.destination = URL(fileURLWithPath: NSTemporaryDirectory())
        case .folder(let folderName):
            let documentFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            self.destination = URL(fileURLWithPath: documentFolder).appendingPathComponent(folderName, isDirectory: true)
        }
        do {
            try FileManager.default.createDirectory(at: self.destination, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        journalDestinition = self.destination.appendingPathComponent(FileCacheConstants.CACHE_JOURNAL_NAME)
    }
    
    func saveInFileCache(key:Key,value:Value, completionHandler:@escaping () -> ()) {
        let operation = BlockOperation {
            do {
                try self.persist(data: value.toData()!, at: self.destination.appendingPathComponent(String(key.hashValue)))
            } catch {
                print(error.localizedDescription)
            }
        }
        operation.completionBlock = {
            completionHandler()
        }
        fileCacheQueue.addOperation(operation)
    }
    
    func removeFromFileCache(key:Key, completionHandler:@escaping () -> ()) {
        let operation = BlockOperation {
            do {
                try FileManager.default.removeItem(at: self.destination.appendingPathComponent(String(key.hashValue)))
            } catch {
                print(error.localizedDescription)
            }
        }
        operation.completionBlock = {
            completionHandler()
        }
        fileCacheQueue.addOperation(operation)
    }
    
    func loadFromFileCache(key:Key, completionHandler:@escaping (Value?) -> ()) {
        let operation = BlockOperation {
            do {
                let data = try Data(contentsOf: self.destination.appendingPathComponent(String(key.hashValue)))
                completionHandler(Value(data:data))
            } catch {
                print(error)
                completionHandler(nil)
            }
        }
        fileCacheQueue.addOperation(operation)
    }
    
    private func persist(data: Data, at url: URL) throws {
        do {
            print(url.absoluteString)
            try data.write(to: url, options: [.atomicWrite])
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}

