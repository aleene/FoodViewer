//
//  ViewController.swift
//  TaxonomyParser
//
//  Created by arnaud on 11/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

/*
    Understanding the OFF taxonomy mark up.
- Definition section are delimited by empty lines (\n). Each definition section defines a Vertex().
- A definition section can start with a "<" (smaller then sign), then this section defines a child.
- The ordering of the definition section is random. This implies that processing them in order might produce children Vertexes without a father Vertex.
- There are sections that do not define a Vertex. Lines in these blocks start with words like "synonyms", "stopwords"

*/
import Foundation

class OFFTaxonomies {

    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let instance = OFFTaxonomies()
    
    private struct Constants {
        static let OpenFoodFactsExtension = "off"
        static let PlistExtension = "plist"
        static let AllergensFileName = "Allergens"
        static let AdditivesFileName = "Additives"
        static let StatesFileName = "States"
        static let CountriesFileName = "Countries"
        static let GlobalLabelsFileName = "GlobalLabels"
        static let BrandsFileName = "Brands"
        static let CategoriesFileName = "Categories"
        static let TaxonomyKey = "Taxonomy"
        static let Language = "en"
        static let LanguageDivider = ":"
    }
    
    lazy var OFFstates: Set <VertexNew>? = nil
    lazy var OFFadditives: Set <VertexNew>? = nil
    
    init() {
        // read all necessary plists in the  background
        OFFstates = readPlist(Constants.StatesFileName)
        OFFadditives = readPlist(Constants.AdditivesFileName)
    }
    
    // MARK: Outlets and Actions

    
    func translateStates(key: String, language:String) -> String {
        if OFFstates != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)

            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = OFFstates!.indexOf(vertex)
            if  index != nil {
                
                let currentVertex = OFFstates![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0] : "No translation available"
            }
        }
        return "No translation file available"
    }
    
    func translateAdditives(key: String, language:String) -> String {
        if OFFadditives != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)
            
            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = OFFstates!.indexOf(vertex)
            if  index != nil {
                
                let currentVertex = OFFadditives![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0] : "No translation available"
            }
        }
        return "No translation file available"
    }

    private func readPlist(fileName: String) -> Set <VertexNew>? {
        // Copy the file from the Bundle and write it to the Device:
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: Constants.PlistExtension) {

            //let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            //let documentsDirectory = paths.objectAtIndex(0) as! NSString
            //let path = documentsDirectory.stringByAppendingPathComponent(fileName + "." + Constants.PlistExtension)
            let resultDictionary = NSDictionary(contentsOfFile: path)
            // print("Saved plist file is --> \(resultDictionary?.description)")
            var verteces = Set <VertexNew>()
        
            if let result = resultDictionary {
                var vertex = VertexNew()
                for (key, value) in result {
                    let newKey = key as! String
                    let dict = Dictionary(dictionaryLiteral: (newKey, value))
                    vertex = vertex.decodeDict(dict)
                    verteces.insert(vertex)
                }
                return verteces
            }
        }
        return nil
    }
}

