//
//  ProductStorage.swift
//  FoodViewer
//
//  Created by arnaud on 05/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

public struct ProductStorage {
    
    private struct Constant {
        static let ImageExtension = ".jpg"
        static let JsonExtension = ".json"
        static let FrontImage = "front_"
        static let IngredientsImage = "ingredients_"
        static let NutritionImage = "ntrition_"
    }
    // Provide the number of stored products
    var count: Int {
        return 0
    }
    
    func save(_ product: FoodProduct) {
        // create a directory for this product
        guard let directoryURL = URL.createDirectory(with:product.barcode.asString) else {
            assert(true, "ProductStorage: Not able to create directory")
            return
        }
        /*
        if let encodedData = OFFProductJson().encode(product) {
            let fileURL =  directoryURL.appendingPathComponent(product.barcode.asString + Constant.JsonExtension)
            do {
                try encodedData.write(to: fileURL)
            }
            catch {
                print("Failed to write JSON data: \(error.localizedDescription)")
            }
        }
 */

        // convert the data to a json file and store that
        // store the new images
        for imageDict in product.images {
            if let image = imageDict.value.original?.image {
                do {
                    let fileURL =  directoryURL.appendingPathComponent("\(imageDict.key)" + Constant.ImageExtension)
                    try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                } catch {
                    assert(true, "ProductStorage: Not able to create and write image")
                }
            }
        }
        // store the front images
        for imageDict in product.frontImages {
            if let image = imageDict.value.original?.image {
                do {
                    let fileURL =  directoryURL.appendingPathComponent(Constant.FrontImage + "\(imageDict.key)" + Constant.ImageExtension)
                    try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                } catch {
                    assert(true, "ProductStorage: Not able to create and write front image")
                }
            }
        }
        // store the selected ingredients images
        for imageDict in product.ingredientsImages {
            if let image = imageDict.value.original?.image {
                do {
                    let fileURL =  directoryURL.appendingPathComponent(Constant.IngredientsImage + "\(imageDict.key)" + Constant.ImageExtension)
                    try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                } catch {
                    assert(true, "ProductStorage: Not able to create and write ingredients image")
                }
            }
        }
        // store the selected nutrition images
        for imageDict in product.nutritionImages {
            if let image = imageDict.value.original?.image {
                do {
                    let fileURL =  directoryURL.appendingPathComponent(Constant.NutritionImage + "\(imageDict.key)" + Constant.ImageExtension)
                    try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                } catch {
                    assert(true, "ProductStorage: Not able to create and write nutrition image")
                }
            }
        }

    }
    
    // read all products locally stored
    func read() -> [FoodProduct] {
        return []
    }
    
    // delete a specif locally stored product
    func delete(_ product: FoodProduct) {
        
    }
    
    //private var documentsURL: FileManager {
    //    return FileManager.defaults.urls(for: .documentDirectory, in: .userDomainMask).first!
    //}
    
    
    private func json(for _product: FoodProduct) {
        
    }
    
}
