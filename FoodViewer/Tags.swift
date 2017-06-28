//
//  Tags.swift
//  FoodViewer
//
//  Created by arnaud on 18/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public enum Tags {
    
    case undefined
    case empty
    case available([String])
    
    func description() -> String {
        switch self {
        case .undefined: return NSLocalizedString("unknown", comment: "Text in a TagListView, when the field in the json was empty.")
        case .empty: return NSLocalizedString("none", comment: "Text in a TagListView, when the json provided an empty string.")
        case .available:
            return NSLocalizedString("available", comment: "Text in a TagListView, when tags are available the product data.")        }
    }
    
    public init() {
        self = .undefined
    }
    
    public init(_ list: [String]?) {
        self.init()
        decode(list)
    }
    
    // initialise with a comma delimited string
    public init(_ string: String?) {
        self.init()
        if let validString = string {
            decode(validString.characters.split{ $0 == "," }.map(String.init))
        }
    }
    
    public init(withList list: [String]?, and languageCode: String) {
        self.init()
        guard list != nil else { return }
        decode(addPrefix(list!, prefix: languageCode))
    }
    
    public init(_ string: String?, with languageCode: String) {
        self.init()
        guard string != nil else { return }
        let list = string!.characters.split{ $0 == "," }.map(String.init)
        decode(addPrefix(list, prefix: languageCode))
    }

    
    public func tag(_ index: Int) -> String? {
        switch self {
        case .undefined, .empty:
            return self.description()
        case let .available(list):
            if index >= 0 && index < list.count {
                return list[index]
            } else {
                assert(true, "Tags array - index out of bounds")
            }
        }
        return nil
    }
    
    public func tagWithoutPrefix(_ index: Int, locale:String) -> String? {
        if let currentTag = self.tag(index) {
            let interfaceLanguage = locale.characters.split{ $0 == "-" }.map(String.init)[0]
            if currentTag.hasPrefix(interfaceLanguage + ":") {
                return currentTag.characters.split{ $0 == ":" }.map(String.init)[1]
            } else {
                return currentTag
            }
        } else {
            return nil
        }
    }
    
    public func tagWithoutPrefix(_ index: Int) -> String? {
        if let currentTag = self.tag(index) {
            if currentTag.hasPrefix(":") {
                return currentTag.characters.split{ $0 == ":" }.map(String.init)[1]
            } else {
                return currentTag
            }
        } else {
            return nil
        }
    }

    public mutating func remove(_ index: Int) {
        switch self {
        case .available(var newList):
            guard index >= 0 && index < newList.count else { break }
            newList.remove(at: index)
            self = .available(newList)
        default:
            break
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
    
    // returns the tag-list with a language-prefix
    public func prefixedList(_ language: String) -> [String] {
        switch self {
        case let .available(list):
            if !list.isEmpty {
                return addPrefix(list, prefix: language)
            }
        default:
            break
        }
        return []
    }
    
    private func addPrefix(_ list: [String], prefix: String) -> [String] {
        var prefixedList: [String] = []
        for tag in list {
            if tag.contains(":") {
                // there is already a prefix
                prefixedList.append(tag)
                // is there an language prefex encoded?
            } else if tag[2] == "-" {
                prefixedList.append(tag)
            } else {
                prefixedList.append(prefix + ":" + tag)
            }
        }
        return prefixedList
    }
}
