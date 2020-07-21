//
//  VertexNew.swift
//  TaxonomyParser
//
//  Created by arnaud on 21/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class VertexNew: Node {
    
    var parents: Set <VertexNew> = []
    var children: Set <VertexNew> = []
    
    fileprivate struct Constants {
        static let ParentsKey = "Parents"
        static let ChildrenKey = "Children"
        static let KeyKey = "Key"
        static let LanguagesKey = "Languages"
    }
    
    init() {
        super.init(key: "\(arc4random())")
    }
    
    init(node: Node) {
        super.init(key: node.key)
        self.leaves = node.leaves
    }
    
    override init(key: String) {
        super.init(key: key)
    }

    func asParentsDict() -> Dictionary <String, Any> {
        
        var leafDict: [String:Any] = [:]
        var subDict: [String:Any] = [:]
        var nodeDict: [String:Any] = [:]
        
        if !self.leaves.isEmpty {
            // loop over all leaves within a Vertex
            for (language, values) in self.leaves {
                subDict[language] = values as [String]
            }
            leafDict[Constants.LanguagesKey] = subDict as AnyObject?
            subDict.removeAll()
        }
        
        if !self.parents.isEmpty {
            // loop over all leaves within a Vertex
            for node in self.parents {
                subDict[Constants.KeyKey] = node.key as AnyObject?
            }
            leafDict[Constants.ParentsKey] = subDict as AnyObject?
        }

        nodeDict[key] = leafDict as AnyObject?
        
        return nodeDict
    }

    func asChildrenDict() -> Dictionary <String, Any> {
        
        var leafDict: [String:Any] = [:]
        var subDict: [String:Any] = [:]
        var nodeDict: [String:Any] = [:]
        
        if !self.leaves.isEmpty {
            // loop over all leaves within a Vertex
            for (language, values) in self.leaves {
                subDict[language] = values as Array
            }
            leafDict[Constants.LanguagesKey] = subDict as AnyObject?
            subDict.removeAll()
        }
        
        if !self.children.isEmpty {
            // loop over all leaves within a Vertex
            for node in self.children {
                subDict[key] = node.asChildrenDict() as AnyObject?
            }
            leafDict[Constants.ChildrenKey] = subDict as AnyObject?
        }
        
        nodeDict[key] = leafDict as AnyObject?
        
        return nodeDict
    }
    
    func decodeDict(_ dict: Dictionary <String, Any>) -> VertexNew {
        let vertex = VertexNew()
        // a dict defines a single vertex
        if dict.count == 1 {
            for (key, value) in dict {
                vertex.key = key
                if let valueDict = value as? Dictionary <String, AnyObject> {
                    for (key2, value2) in valueDict  {
                        if key2 == Constants.ParentsKey {
                            if let value2Dict = value2 as? Dictionary <String, String> {
                                for (key3, value3) in value2Dict {
                                    if key3 == Constants.KeyKey {
                                        let parentVertex = VertexNew()
                                        parentVertex.key = value3
                                        vertex.parents.insert(parentVertex)
                                    } else {
                                        print("VertexNew: unknown key in Parents dictionary")
                                    }
                                }
                            }
                        } else if key2 == Constants.LanguagesKey {
                            vertex.leaves = super.decodeLeavesDict(value2 as! Dictionary <String, AnyObject>)
                        }
                    }
                } else {
                    print("VertexNew: not a dictionary")
                }

            }
        } else {
            print ("VertexNew: wrong length")
        }

        return vertex
    }

}
