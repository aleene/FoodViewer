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
        static let NutritionImage = "nutrition_"
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
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(product.asOFFProductJson)
            let fileURL =  directoryURL.appendingPathComponent(product.barcode.asString + Constant.JsonExtension)
            do {
                try encodedData.write(to: fileURL)
            }
            catch let error {
                print("ProductStorage: Failed to write JSON data: \(error.localizedDescription)")
            }
        } catch let error {
            print("ProductStorage: Failed to encode: \(error.localizedDescription)")
        }

        // convert the data to a json file and store that
        // store the new images
        for imageDict in product.images {
            if let fetchResult = imageDict.value.original?.fetch() {
                switch fetchResult {
                case .success(let image):
                    do {
                        let fileURL =  directoryURL.appendingPathComponent("\(imageDict.key)" + Constant.ImageExtension)
                        try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                    } catch {
                        assert(true, "ProductStorage: Not able to create and write image")
                    }
                default:
                    break
                }
            }
        }
        // store the front images
        for imageDict in product.frontImages {
            if let fetchResult = imageDict.value.original?.fetch() {
                switch fetchResult {
                case .success(let image):
                    do {
                        let fileURL =  directoryURL.appendingPathComponent(Constant.FrontImage + "\(imageDict.key)" + Constant.ImageExtension)
                        try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                    } catch {
                        assert(true, "ProductStorage: Not able to create and write image")
                    }
                default:
                    break
                }
            }
        }
        // store the selected ingredients images
        for imageDict in product.ingredientsImages {
            if let fetchResult = imageDict.value.original?.fetch() {
                switch fetchResult {
                case .success(let image):
                    do {
                        let fileURL =  directoryURL.appendingPathComponent(Constant.IngredientsImage + "\(imageDict.key)" + Constant.ImageExtension)
                        try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                    } catch {
                        assert(true, "ProductStorage: Not able to create and write image")
                    }
                default:
                    break
                }
            }
        }
        // store the selected nutrition images
        for imageDict in product.nutritionImages {
            if let fetchResult = imageDict.value.original?.fetch() {
                switch fetchResult {
                case .success(let image):
                    do {
                        let fileURL =  directoryURL.appendingPathComponent(Constant.IngredientsImage + "\(imageDict.key)" + Constant.ImageExtension)
                        try UIImageJPEGRepresentation(image, 1.0)?.write(to: fileURL, options: .atomic)
                    } catch {
                        assert(true, "ProductStorage: Not able to create and write image")
                    }
                default:
                    break
                }
            }
        }

    }
    
    // read all products locally stored
    func readAll() -> [FoodProduct] {
        return []
    }
    
    // read all products locally stored
    func read(_ barcode: String) -> FoodProduct? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(barcode)?.appendingPathComponent(barcode).appendingPathExtension(Constant.JsonExtension) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                do {
                    let data = try Data.init(contentsOf: pathComponent)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    do {
                        let productJson = try decoder.decode(OFFProductJson.self, from: data)
                        if let offProduct = productJson.product {
                            return FoodProduct.init(json: offProduct)
                        } else {
                            print("ProductStorage: no valid offProduct")
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    print("ProductStorage: FILE AVAILABLE")
                } catch let error {
                    print(error.localizedDescription)
                }
            } else {
                print("ProductStorage FILE NOT AVAILABLE")
            }
        } else {
            print("ProductStorage FILE PATH NOT AVAILABLE")
        }
        return nil
    }

    // delete a specif locally stored product
    func delete(_ barcode: String) {
        // does the directory with this barcode exist?
        // delete all files in the directory
        
    }
    
    //private var documentsURL: FileManager {
    //    return FileManager.defaults.urls(for: .documentDirectory, in: .userDomainMask).first!
    //}
    
    
    private func json(for _product: FoodProduct) {
        
    }
    
}
