//
//  Tags.swift
//  FoodViewer
//
//  Created by arnaud on 18/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum Tags {
    
    case undefined
    case empty
    case available([String])
    
    func description() -> String {
        switch self {
        case .undefined: return NSLocalizedString("field not received", comment: "Text in a TagListView, when the field in the json was empty.")
        case .empty: return NSLocalizedString("empty", comment: "Text in a TagListView, when the json provided an empty string.")
        case .available:
            return NSLocalizedString("available", comment: "Text in a TagListView, when tags are available the product data.")        }
    }
    
    init() {
        self = .undefined
    }
    
    init(_ list: [String]?) {
        self.init()
        decode(list)
    }
    
    // initialise with a comma delimited string
    init(_ string: String?) {
        self.init()
        if let validString = string {
            decode(validString.characters.split{ $0 == "," }.map(String.init))
        }
    }
    
    // remove any empty items from the list
    private func clean(_ list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.characters.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }
    
    private mutating func decode(_ list: [String]?) {
        if let validList = list {
            let newList = clean(validList)
            if newList.isEmpty {
                self = .empty
            } else {
                self = .available(newList)
            }
        } else {
            self = .undefined
        }
    }

}
