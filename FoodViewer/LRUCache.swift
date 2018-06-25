//
//  LRUCache.swift
//  cacheTest
//
//  Created by Maksim Kita on 12/28/17.
//  Copyright © 2017 Maksim Kita. All rights reserved.
//

import Foundation

internal protocol LRUCacheProtocol {
    
    associatedtype Key:Hashable
    
    associatedtype Value
    
    associatedtype SizeOfValueFunction = (Value) -> (Double)
    
    func keysSetSnapshot() -> [Key]
    
    func keyValueSnapshot() -> [String]
    
    func cacheDictionarySnapshot() -> Dictionary<Key,Value>
    
    func resize(maxSize:Double)
    
    func get(key:Key) -> Value?
    
    func put(key:Key, value:Value)
    
    func trimToSize(maxSize:Double)
    
    func remove(key:Key) -> Value?
    
    func evictAll()
    
    func safeSizeOf(value:Value) -> Double
    
    func sizeOf(value:Value) -> Double
    
    func checkInCache(key:Key) -> Bool
}


public class LRUCache<Key:Hashable,Value>:LRUCacheProtocol {

    private var cacheDictionary:Dictionary<Key,Value> = [:]
    
    private var keysQueue = Queue<Key>()
    
    private var sizeOfValueFunction:SizeOfValueFunction
    
    private(set) var maxSize:Double
    
    private(set)var capacity:Int
    
    private(set) var size:Double = 0
    
    private(set) var evictionCount:Int = 0
    
    private(set) var hitCount:Int = 0
    
    private(set) var missCount:Int = 0
    
    private(set) var putCount:Int = 0
    
    public init(maxSize:Double, capacity:Int, sizeOf:@escaping SizeOfValueFunction) {
        self.maxSize = maxSize
        self.capacity = capacity
        self.sizeOfValueFunction = sizeOf
    }
    
    public func resize(maxSize:Double) {
        if (maxSize>0) {
            self.maxSize = maxSize
        }
        trimToSize(maxSize: maxSize)
    }
    
    public func get(key:Key) -> Value? {
        var mapValue:Value? = nil
        mapValue = cacheDictionary[key]
        if (mapValue != nil) {
            hitCount += 1
            keysQueue.upKeyPriority(key: key)
            return mapValue
        }
        missCount += 1
        return mapValue
    }
    
    public func put(key:Key, value:Value) {
        let exists = keysQueue.checkExistInQueue(key: key)
        if (exists == true) {
            return
        }
        size += safeSizeOf(value: value)
        keysQueue.put(key: key)
        cacheDictionary.updateValue(value, forKey: key)
        putCount += 1
        trimToSize(maxSize: maxSize)
    }
    
    public func trimToSize(maxSize:Double) {
        while(true) {
            if (size<0 || (cacheDictionary.isEmpty && size != 0) || capacity<0) {
                return
            }
            if (size <= maxSize && cacheDictionary.count <= capacity) {
                break
            }
            guard let eldestKey = keysQueue.getEldest(), let value = cacheDictionary[eldestKey] else {
                return
            }
            size -= safeSizeOf(value: value)
            cacheDictionary.removeValue(forKey: eldestKey)
            evictionCount += 1
        }
    }
    
    public func remove(key:Key) -> Value? {
        guard let value = cacheDictionary.removeValue(forKey: key) else {
            return nil
        }
        size -= safeSizeOf(value: value)
        return value
    }
    
    public func checkInCache(key: Key) -> Bool {
        return keysQueue.checkExistInQueue(key: key)
    }
    
    public func evictAll() {
        trimToSize(maxSize: 0)
    }
    
    public func safeSizeOf(value:Value) -> Double {
        return sizeOf(value: value)
    }
    
    public func sizeOf(value:Value) -> Double {
        return sizeOfValueFunction(value)
    }
    
    public func keysSetSnapshot() -> [Key]{
        return keysQueue.keySnapshot()
    }
    
    public func keyValueSnapshot() -> [String] {
        var keyValuesSnapshotArray:[String] = []
        let cacheSnapshot = cacheDictionarySnapshot()
        for key in keysSetSnapshot() {
            guard let value = cacheSnapshot[key] else {
                continue
            }
            keyValuesSnapshotArray.append("KEY:\(key) : VALUE:\(String(describing: value)) : SIZE:\(safeSizeOf(value: value))")
        }
        return keyValuesSnapshotArray
    }
    
    public func cacheDictionarySnapshot() -> Dictionary<Key,Value> {
        return cacheDictionary
    }
    public func toString() -> String {
        let accesses = hitCount + missCount
        let hitPercent = accesses != 0 ? (100 * hitCount / accesses) : 0
        return "LRU CACHE SIZE: \(size) MAXSIZE:\(maxSize) HITS:\(hitCount) MISSES:\(missCount) HITPERSENT:\(hitPercent) ELEMENTS:\(cacheDictionary.count)"
    }
}

