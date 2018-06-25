//
//  LRUFileCache.swift
//  cacheTest
//
//  Created by Maksim Kita on 12/28/17.
//  Copyright © 2017 Maksim Kita. All rights reserved.
//

import Foundation

public class LRUFileCache<Key:Hashable,Value:ItemCacheProtocol>{
    
    private var fileCacheJournal:FileJournal<Key,Value> = FileJournal<Key,Value>(fileDictionary:[:], keysQueue:Queue<Key>())
    
    private let fileCache:FileCache<Key, Value>
    
    public typealias SizeOfValueFunction = (Value) -> (Double)
    
    private var sizeOfValueFunction:SizeOfValueFunction
    
    private(set) var maxSize:Double
    
    private(set) var capacity:Int
    
    private(set) var size:Double = 0
    
    private(set) var evictionCount:Int = 0
    
    private(set) var hitCount:Int = 0
    
    private(set) var missCount:Int = 0
    
    private(set) var putCount:Int = 0
    
    public init(maxSize:Double, capacity:Int, cacheDestination:FileCacheDestination, sizeOf:@escaping SizeOfValueFunction)  {
        self.maxSize = maxSize
        self.capacity = capacity
        self.sizeOfValueFunction = sizeOf
        self.fileCache = FileCache<Key, Value>(cacheDestination: cacheDestination)
        self.fileCacheJournal = loadFileJournal()
        self.size = self.fileCacheJournal.sizeOfJournalFiles()
        
    }

    public func keysSetSnapshot() -> [Key]{
        return fileCacheJournal.keysQueue.keySnapshot()
    }
    public func cacheDictionarySnapshot() -> Dictionary<Key,Double> {
        return fileCacheJournal.fileDictionary
    }
    
    public  func resize(maxSize:Double) {
        if (maxSize>0) {
            self.maxSize = maxSize
        }
        trimToSize(maxSize: maxSize)
    }
    
    public func get(key:Key, comletionHandler:@escaping (Value?) -> ()) {
        if fileCacheJournal.keysQueue.checkExistInQueue(key: key) == true {
            hitCount += 1
            fileCache.loadFromFileCache(key: key) { value in
                comletionHandler(value)
            }
        } else {
            missCount += 1
            comletionHandler(nil)
        }
    }
    
    public func put(key:Key, value:Value) {
        if (fileCacheJournal.keysQueue.checkExistInQueue(key: key) == true) {
            return
        }
        fileCache.saveInFileCache(key: key, value: value) {[weak self] in
            self?.afterPutUpdate(key: key, value: value)
        }
    }
    
    private func afterPutUpdate(key:Key, value:Value) {
        self.fileCacheJournal.keysQueue.put(key: key)
        self.fileCacheJournal.fileDictionary.updateValue((safeSizeOf(value: value)), forKey: key)
        self.size += (self.safeSizeOf(value: value))
        self.putCount += 1
        self.saveFileJournal()
        self.trimToSize(maxSize: self.maxSize)
    }
    
    public func trimToSize(maxSize:Double) {
        while(true) {
            if (size<0 || (fileCacheJournal.fileDictionary.isEmpty && size != 0) || capacity<0) {
                return
            }
            if (size <= maxSize && fileCacheJournal.fileDictionary.count <= capacity) {
                break
            }
            guard let eldestKey = fileCacheJournal.keysQueue.getEldest(), let value = fileCacheJournal.fileDictionary[eldestKey] else {
                return
            }
            fileCache.removeFromFileCache(key: eldestKey) { [weak self] in
                self?.afterTrimToSizeUpdate(key: eldestKey, value: value)
            }
            
        }
    }
    
    private func afterTrimToSizeUpdate(key:Key, value:Double) {
        self.fileCacheJournal.fileDictionary.removeValue(forKey: key)
        self.size -= value
        self.evictionCount += 1
        self.saveFileJournal()
    }
    
    public func remove(key:Key) {
        guard fileCacheJournal.keysQueue.checkExistInQueue(key: key) == true, let value = fileCacheJournal.fileDictionary[key] else {
            return
        }
        fileCache.removeFromFileCache(key: key) { [weak self] in
            self?.afterRemoveUpdate(key: key, value: value)
        }
    }
    
    private func afterRemoveUpdate(key:Key,value:Double) {
        self.size -= value
        self.evictionCount += 1
        self.fileCacheJournal.fileDictionary.removeValue(forKey: key)
        self.saveFileJournal()
    }
    
    public func evictAll() {
        trimToSize(maxSize: 0)
    }
    
    private func saveFileJournal(){
        NSKeyedArchiver.archiveRootObject(fileCacheJournal, toFile: fileCache.journalDestinition.path)
    }
    
    private func loadFileJournal() -> FileJournal<Key,Value> {
        guard let fileJournal = NSKeyedUnarchiver.unarchiveObject(withFile: fileCache.journalDestinition.path) as? FileJournal<Key,Value> else {
            return FileJournal<Key,Value>(fileDictionary:[:], keysQueue:Queue<Key>())
        }
        return fileJournal
    }
    
    public func checkInCache(key:Key) -> Bool {
        return fileCacheJournal.keysQueue.checkExistInQueue(key: key)
    }
    
    public func safeSizeOf(value:Value) -> Double {
        return sizeOf(value: value)
    }
    
    public func sizeOf(value:Value) -> Double {
        return sizeOfValueFunction(value)
    }
    
    public func toString() -> String {
        let accesses = hitCount + missCount
        let hitPercent = accesses != 0 ? (100 * hitCount / accesses) : 0
        return "LRU CACHE SIZE: \(size) MAXSIZE:\(maxSize) HITS:\(hitCount) MISSES:\(missCount) HITPERSENT:\(hitPercent) ELEMENTS:\(fileCacheJournal.fileDictionary.count)"
    }
}

