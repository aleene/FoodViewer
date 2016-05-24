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
    
    private struct Constants {
        static let ParentsKey = "Parents"
        static let ChildrenKey = "Children"
        static let KeyKey = "Key"
    }
    
    init() {
        super.init(key: "\(rand())")
    }
    
    init(node: Node) {
        super.init(key: node.key)
        self.leaves = node.leaves
    }
    
    override init(key: String) {
        super.init(key: key)
    }

    func asParentsDict() -> Dictionary <String, AnyObject> {
        
        var leafDict: [String:AnyObject] = [:]
        var subDict: [String:AnyObject] = [:]
        var nodeDict: [String:AnyObject] = [:]
        
        if !self.leaves.isEmpty {
            // loop over all leaves within a Vertex
            for (language, values) in self.leaves {
                subDict[language] = values as Array
            }
            leafDict[Constants.LanguagesKey] = subDict
            subDict.removeAll()
        }
        
        if !self.parents.isEmpty {
            // loop over all leaves within a Vertex
            for node in self.parents {
                subDict[Constants.KeyKey] = node.key
            }
            leafDict[Constants.ParentsKey] = subDict
        }

        nodeDict[key] = leafDict
        
        return nodeDict
    }

    func asChildrenDict() -> Dictionary <String, AnyObject> {
        
        var leafDict: [String:AnyObject] = [:]
        var subDict: [String:AnyObject] = [:]
        var nodeDict: [String:AnyObject] = [:]
        
        if !self.leaves.isEmpty {
            // loop over all leaves within a Vertex
            for (language, values) in self.leaves {
                subDict[language] = values as Array
            }
            leafDict[Constants.LanguagesKey] = subDict
            subDict.removeAll()
        }
        
        if !self.children.isEmpty {
            // loop over all leaves within a Vertex
            for node in self.children {
                subDict[key] = node.asChildrenDict()
            }
            leafDict[Constants.ChildrenKey] = subDict
        }
        
        nodeDict[key] = leafDict
        
        return nodeDict
    }
    
    func decodeDict(dict: Dictionary <String, AnyObject>) -> VertexNew {
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
                                        print("unknown key in Parents dictionary")
                                    }
                                }
                            }
                        } else if key2 == Constants.LanguagesKey {
                            vertex.leaves = super.decodeLeavesDict(value2 as! Dictionary <String, AnyObject>)
                        }
                    }
                } else {
                    print("not a dictionary")
                }

            }
        } else {
            print ("wrong length")
        }

        return vertex
    }

}