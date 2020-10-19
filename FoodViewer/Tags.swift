//
//  Tags.swift
//  FoodViewer
//
//  Created by arnaud on 18/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

//  The Tags object maps a tags-field in OFF. As a tags-field is not always available or filled in an OFF-json,
//  it has been setup as an enum.
//
//  If tags are available, the original tags as supplied vy OFF are stored.
//  For actual use the right language must be set. The language is set as a prefix with a :-delimiter.
//  - no language prefix present, then the product primary language is assumed
//  - language prefix present, then the language prefix is used
//
//  Public methods are available that work on a Tags-object, on a list of tags and on individuel tags

import Foundation

public enum Tags : Equatable {

    case undefined
    case empty
    case available([String])
    case notSearchable
    
    func description() -> String {
        switch self {
        case .undefined:
            return TranslatableStrings.Unknown
        case .empty:
            return TranslatableStrings.NotFilled
        case .available:
            return TranslatableStrings.Available
        case .notSearchable:
            return TranslatableStrings.NotSearchable
        }
    }
    
    //
    // MARK: - Initialisers
    //

    public init() {
        self = .undefined
    }
    
    public init(list: [String]?) {
        self.init()
        decode(list)
    }

    // initialise tags with a comma delimited string
    public init(string: String?) {
        self.init(list:string?.split(separator: ",").map(String.init))
    }
    
    public init(text: String) {
        self.init()
        self = .available([text])
    }
    
    public var isAvailable: Bool {
        switch self {
        case .available:
            return true
        default:
            return false
        }
    }
    
//
// MARK: - Clean tag functions
//

    // add a languageCode to tags that have no language and remove languageCode for another language
    public func prefixed(withAdded languageCode: String?, andRemoved otherLanguageCode: String?) -> Tags {
        switch self {
        case let .available(list):
            if !list.isEmpty {
                var newList: [String] = []
                if languageCode != nil {
                    newList = addPrefix(list, prefix: languageCode!) }
                else {
                    newList = list
                }
                if otherLanguageCode != nil {
                    newList = strip(newList, of:otherLanguageCode!)
                }
                return .available(newList)
            }
        default:
            break
        }
        return self
    }
    
    
    // add a languageCode to tags that have no language and remove languageCode for another language
    public func tags(withAdded languageCode: String) -> [String] {
        switch self {
        case let .available(list):
            if !list.isEmpty {
                return addPrefix(list, prefix: languageCode)
            }
        default:
            break
        }
        return []
    }
    
    // add a languageCode to tags that have no language and remove languageCode for another language
    public func tags(withAdded languageCode: String, andRemoved otherLanguageCode: String) -> [String] {
        switch self {
        case let .available(list):
            if !list.isEmpty {
                let newList = addPrefix(list, prefix: languageCode)
                return strip(newList, of:otherLanguageCode)
            }
        default:
            break
        }
        return []
    }

//
// MARK: - Single tag functions
//
    
    // returns the tag string at an index if available
    public func tag(at index: Int) -> String? {
        switch self {
        case .undefined, .empty, .notSearchable:
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
    
    // If the tag has a languageCode, remove it
    public func tag(at index: Int, in languageCode: String) -> String? {
        return self.tag(at: index) != nil ? strip(self.tag(at: index)!, of: languageCode) : nil
    }
    
    // If the tag has a languageCode, remove it. And add
    public func tag(at index: Int, withAdded languageCode: String, andRemoved otherLanguageCode: String) -> String? {
        guard self.tag(at: index) != nil else { return nil }
        let newString = strip(self.tag(at: index)!, of: otherLanguageCode)
        return add(languageCode, to: newString)
    }

    // remove a tag at an index if available
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
//
// MARK: - Multi tag functions
//
    public var list: [String] {
        switch self {
        case .available(let list):
            return list
        default:
            break
        }
        return []
    }
    
    public var hasTags: Bool {
        return !list.isEmpty
    }
    
    public var count: Int? {
        return list.count > 0 ? list.count : nil
    }


//
// MARK: - Private Tags functions
//
    // returns a tag string without a prefix at an index, if available
    private func stripTag(_ index: Int) -> String? {
        if let currentTag = self.tag(at: index) {
            if currentTag.contains(":") {
                return stripAnyPrefix(currentTag)
            } else {
                return currentTag
            }
        } else {
            return nil
        }
    }
   
    // If there are any tag strings, add a language code.
    private func addPrefix(_ prefix: String) -> [String] {
        switch self {
        case let .available(list):
            if !list.isEmpty {
                return addPrefix(list, prefix: prefix)
            }
        default:
            break
        }
        return []
    }
    
//
// MARK: - Private tag-list functions
//

    private func strip(_ list: [String], of prefix: String) -> [String] {
        var newList: [String] = []
        for string in list {
            newList.append(strip(string, of: prefix))
        }
        return newList
    }
    
    private func addPrefix(_ list: [String], prefix: String) -> [String] {
        var prefixedList: [String] = []
        for tag in list {
            if tag.contains(":") {
                // there is already a prefix
                prefixedList.append(tag)
                // is there an language prefix encoded?
            } else {
                prefixedList.append(prefix + ":" + tag)
            }
        }
        return prefixedList
    }


    // remove any empty tag strings from the list
    private func clean(_ list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }
    
    // setup tags with a cleaned list of strings
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

//
// MARK: - Private tag functions
//

    private func strip(_ string: String, of prefix: String) -> String {
        return string.hasPrefix(prefix + ":") ? stripAnyPrefix(string) : string
    }
    
    private func stripAnyPrefix(_ string: String) -> String {
        return string.contains(":") ? string.split(separator:":").map(String.init)[1]
            : string
    }
    
    private func add(_ prefix: String, to string: String) -> String {
        return string.contains(":") ? string : prefix + ":" + string
    }
//
// MARK: - Equatable protocol conformance
//
    public static func ==(leftTag: Tags, rightTag: Tags) -> Bool {
        switch leftTag {
        case .available(let leftList):
            switch rightTag {
            case .available(let rightList):
                for item in leftList {
                    if !rightList.contains(item) {
                        return false
                    }
                }
                return true
            case .empty, .undefined, .notSearchable:
                return false
            }
        case .empty:
            switch rightTag {
            case .empty:
                return true
            case .available, .undefined, .notSearchable:
                return false
            }
        case .undefined:
            switch rightTag {
            case .undefined:
                return true
            case .empty, .available, .notSearchable:
                return false
            }
        case .notSearchable:
            switch rightTag {
            case .notSearchable:
                return true
            case .empty, .available, .undefined:
                return false
            }
        }
    }

    public static func add(right: Tags?, left: Tags?) -> Tags? {
        if right == nil && left == nil {
            return nil
        } else if right == nil && left != nil {
            return left
        } else if right != nil && left == nil {
            return right
        } else {
            return right! + left!
        }
    }
}

extension Tags {
    static func +(left: Tags, right: Tags) -> Tags {
        switch left {
        case available(let leftList):
            switch right {
            case available(let rightList):
                return Tags.init(list:leftList + rightList)
            default:
                return left
            }
        case .undefined:
            switch right {
            case available:
                return right
            default: break
            }

        default: break
        }
        return .undefined
    }
}
