//
//  Taxonomy.swift
//  TaxonomyParser
//
//  Created by arnaud on 18/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class Taxonomy {
    
    var sections: [Section] = []
    
    func createNodes() -> Set <Node> {
        var nodes = Set <Node>()
        // loop over all off entries
        for index in 0 ..< sections.count {
            let node = Node(key: sections[index].key)
            node.leaves = sections[index].leaves
            nodes.insert(node)
        }
        return nodes
    }
    
    // This function creates for each off entry a vertex.
    // A vertex consists of the basic information in an off entry
    // i.e. the key, the language translations with synonyms
    // and ONLY the links to the parentVerteces
    // Thus a vertex is a copy of the off entries, but then as a set
    
    func createVerteces() -> Set <VertexNew> {
        
        var verteces = Set<VertexNew>()

        // first read all off entries to have a set of nodes
        // this step MUST be done before vinding any relations
        let nodes = createNodes()
        
        // convert each node to a vertex with a parent link
        for node in nodes {
            let baseVertex = VertexNew(node: node)
            // find the off entry for this node
            let correspondingOFFentry = locateSection(baseVertex.key)
            //
            if let baseVertexParents = correspondingOFFentry?.parentKeys {
                // add the parents of this off entry to the vertex
                // for all parents defined
                for parentKey in baseVertexParents {
                    // locate the node equivalent of the parent off entry
                    if let parentNode = locateNode(parentKey, inSet: nodes) {
                        let parentVertex = VertexNew.init(node: parentNode)
                        baseVertex.parents.insert(parentVertex)
                    }
                }
            }
            verteces.insert(baseVertex)
        }
        return verteces
    }

    
    func locateNode(searchKey: String, inSet: Set<Node>) -> Node? {
        // return inSet.contains(Node(key: searchKey))
        for node in inSet {
            if node.key == searchKey {
                return node
            }
        }
        return nil
    }
    
    func locateSection(testKey: String) -> Section? {
        // loop over all branches
        // change to repeat while?
        for section in sections {
            if section.key == testKey {
                // key is at the toplevel
                return section
            }
        }
        return nil
    }

}