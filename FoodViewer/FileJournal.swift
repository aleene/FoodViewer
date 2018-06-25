//
//  FileJournal.swift
//  cacheTest
//
//  Created by Maksim Kita on 12/28/17.
//  Copyright © 2017 Maksim Kita. All rights reserved.
//

import Foundation

internal class FileJournal<Key:Hashable,Value:ItemCacheProtocol>:NSObject,NSCoding {
    
    var fileDictionary:Dictionary<Key, Double> = [:]
    var keysQueue = Queue<Key>()
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(fileDictionary, forKey: FileCacheConstants.FILE_DICTIONARY_NAME)
        aCoder.encode(keysQueue.keySnapshot(), forKey: FileCacheConstants.KEYS_QUEUE_NAME)
    }
    
    func sizeOfJournalFiles() -> Double {
        var size:Double = 0
        self.fileDictionary.forEach{size += $0.value}
        return size
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let fileDictionary = aDecoder.decodeObject(forKey: FileCacheConstants.FILE_DICTIONARY_NAME) as? [Key:Double],
            let keysQueueArray = aDecoder.decodeObject(forKey:FileCacheConstants.KEYS_QUEUE_NAME) as? [Key] else {
                return nil
        }
        self.init(fileDictionary:fileDictionary, keysQueue:Queue<Key>(array:keysQueueArray))
    }
    
    init(fileDictionary:Dictionary<Key,Double>, keysQueue:Queue<Key>) {
        self.fileDictionary = fileDictionary
        self.keysQueue = keysQueue
    }
    func toString() -> String {
        print("FILE JOURNAL")
        print("KEYS QUEUE")
        keysQueue.keySnapshot().forEach{print($0)}
        print("DICTIONARY")
        fileDictionary.forEach({print("KEY \($0.key) VALUE \($0.value)")})
        print("SIZE OF JOURNAL \(self.sizeOfJournalFiles())")
        return ""
    }
}

