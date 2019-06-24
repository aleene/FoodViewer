//
//  Node.swift
//  TaxonomyParser
//
//  Created by arnaud on 20/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// Mark: Equatable
func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.key.hashValue == rhs.key.hashValue
}


class Node: Hashable, Equatable, CustomStringConvertible {
    
    struct Constants {
        static let LanguagesKey = "Languages"
    }

    // this is the identifier which unique identifies a node
    var key = String()
    // this is a list of languages with one or more titles describing this node
    var leaves: [String:[String]] = [:]

    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    // use the key string to return a hashValue
    //var hashValue: Int {
    //    return key.hashValue
    //}

    var description: String {
        get {
            var nodeAsString = ("Node: \(key)\n")
            for (language, values) in leaves {
                nodeAsString = nodeAsString + "   Language: \(language) ; values: \(values.description)"
            }
            return nodeAsString
        }
    }
    
    init(key: String) {
        self.key = key
    }

    
    func asDict() -> Dictionary <String, AnyObject> {
        var leafDict: [String:AnyObject] = [:]
        var subDict: [String:AnyObject] = [:]
        var nodeDict: [String:AnyObject] = [:]
        
        if !self.leaves.isEmpty {
            // loop over all leaves within a Vertex
            for (language, values) in self.leaves {
                subDict[language] = values as AnyObject
            }
            leafDict[Constants.LanguagesKey] = subDict as AnyObject?
        }
        
        nodeDict[key] = leafDict as AnyObject?
        
        return nodeDict
    }
    
    func decodeLeavesDict(_ dict: Dictionary <String, AnyObject>) -> [String:[String]] {
        var decodedLeaves: [String:[String]] = [:]
        // a dict defines leaves with languages
        for (key, values) in dict {
            // loop over all languages
            if let synonyms = values as? [String] {
                decodedLeaves[key] = synonyms
            } else {
                print("Node.swift: Not a language string array")
            }
        }
        
        return decodedLeaves
    }

}
