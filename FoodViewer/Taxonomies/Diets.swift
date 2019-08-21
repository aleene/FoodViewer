//
//  Diets.swift
//  FoodViewer
//
//  Created by arnaud on 21/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class Diets {
    
    static let manager = Diets()
    
    private struct Constants {
        static let FileName = "Diets"
        static let PlistExtension = "plist"
    }
    
    var count: Int {
        return all?.count ?? 0
    }
    
    private var all: [String:Any]? = nil
    
    fileprivate func read() {
        if let path = Bundle.main.path(forResource: Constants.FileName, ofType: Constants.PlistExtension) {
            if let resultDictionary = NSDictionary(contentsOfFile: path) {
                for key : Any in resultDictionary.allKeys {
                    if let stringKey = key as? String {
                        if let keyValue = resultDictionary.value(forKey: stringKey){
                            all?[stringKey] = keyValue
                        }
                    }
                }
            } else {
                assert(true, "Diets: File can not be read")
            }

        } else {
            assert(true, "Diets: File can not be found")
        }
    }
    
    public func flush() {
        all = nil
    }
    
}
