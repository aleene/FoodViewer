//
//  Section.swift
//  TaxonomyParser
//
//  Created by arnaud on 13/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class Section {
    
    struct Constants {
        static let Language = "en"
        static let Delimiter = ":"
        static let EmptyString = ""
        static let ChildrenKey = "Children"
        static let ParentsKey = "Parents"
        static let LanguagesKey = "Languages"
    }
    
    
    var leaves: [String:[String]] = [:]
    var parentKeys: [String] = []
    
    var key: String = Constants.EmptyString
    
    func normalizeKey() -> String {
        // do we have a non english key?
        if !self.key.hasPrefix(Constants.Language) {
            // change to an english key if possible
            if self.leaves[Constants.Language] != nil {
                self.key = setKey(Constants.Language, values:self.leaves[Constants.Language]!)
            }
        }
        return self.key
    }

    func alternativeKey() -> String {
        let (language, values) = leaves.first!
        return setKey(language, values:values)
    }
    
    func setKey(_ language: String, values: [String]) -> String {
        return language + Constants.Delimiter + values[0]
    }
}
