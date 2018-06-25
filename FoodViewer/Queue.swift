//
//  Queue.swift
//  cacheTest
//
//  Created by Maksim Kita on 12/28/17.
//  Copyright © 2017 Maksim Kita. All rights reserved.
//

import Foundation

internal struct Queue<Key:Equatable> {
    
    private var array:[Key] = []
    
    private var size:Int {
        return array.count
    }
    
    private(set) var evictionCount:Int = 0
    
    private(set) var hitCount:Int = 0
    
    private(set) var putCount:Int = 0
    
    init(array:[Key]) {
        self.array = array
    }
    
    init () {
        
    }
    mutating func getEldest() -> Key? {
        guard array.count != 0 else {
            return nil
        }
        let eldestKey = array.last
        self.removeLast()
        evictionCount += 1
        return eldestKey
    }
    
    func keySnapshot() -> [Key] {
        return array
    }
    
    mutating func put(key:Key)  {
        let elementIndex = findInQueue(key: key)
        if (elementIndex == -1) {
            array.insert(key, at: 0)
            putCount += 1
        } else {
            upElementPriority(elementIndex: elementIndex)
            hitCount += 1
        }
    }
    
    mutating func remove(key:Key) {
        array.remove(at: findInQueue(key: key))
    }
    
    mutating func removeAt(index:Int) {
        array.remove(at: index)
    }
    
    mutating func removeLast() {
        _ = array.popLast()
    }
    
    mutating func upKeyPriority(key:Key) {
        let indexToUp = findInQueue(key: key)
        guard indexToUp != -1 else {
            return
        }
        upElementPriority(elementIndex: indexToUp)
    }
    
    private mutating func upElementPriority(elementIndex:Int) {
        let element:Key = array[elementIndex]
        array.remove(at: elementIndex)
        put(key: element)
    }
    
    mutating func checkExistInQueue(key:Key) -> Bool {
        let index = findInQueue(key: key)
        if (index == -1){
            return false
        }
        return true
    }
    
    private mutating func findInQueue(key:Key) -> Int {
        var elementIndex:Int = -1
        for (index,item) in array.enumerated() {
            if (item == key) {
                elementIndex = index
                break
            }
        }
        return elementIndex
    }
    public func toString() -> String {
        return "QUEUE SIZE:\(size) PUTCOUNT:\(putCount) EvictionCount\(evictionCount) HitCount\(hitCount)"
    }

}

