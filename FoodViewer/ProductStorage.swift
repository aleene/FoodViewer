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
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let manager = ProductStorage()

    private struct Constant {
        static let ImageExtension = "jpg"
        static let JsonExtension = "json"
    }
    // Provide the number of stored products
    var count: Int {
        return 0
    }
    func save(_ product: FoodProduct, completion: @escaping (ResultType<FoodProduct>) -> () ) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            self.write( product ) {( completionHandler: ResultType<FoodProduct> ) in
                DispatchQueue.main.async(execute: {( ) -> Void in
                    switch completionHandler {
                    case .success(let product):
                        return completion (.success(product))
                    case .failure(let error):
                        return completion(.failure(error))
                    }
                })
            }
        })
    }

    private func write(_ product: FoodProduct, completionHandler: @escaping (ResultType<FoodProduct>) -> () ) {
        
        if !fileManager.fileExists(atPath: productUrl(for:product.barcode).path) {
            // create a directory for this product
            do {
                try fileManager.createDirectory(at: productUrl(for:product.barcode), withIntermediateDirectories: false, attributes: nil)
            } catch let error {
                print("FileStorage: Product directory creation failed \(error.localizedDescription)")
                return completionHandler(.failure(error))
            }
        }
        let encoder = JSONEncoder()
        do {
            let encodedData = try encoder.encode(product.asOFFProductJson)
            let fileURL =  productUrl(for:product.barcode).appendingPathComponent(product.barcode.asString).appendingPathExtension(Constant.JsonExtension)
            do {
                try encodedData.write(to: fileURL)
            } catch let error {
                print("ProductStorage: Failed to write JSON data: \(error.localizedDescription)")
                return completionHandler(.failure(error))
            }
        } catch let error {
            print("ProductStorage: Failed to encode: \(error.localizedDescription)")
            return completionHandler(.failure(error))
        }

        if !product.images.isEmpty {
            let type = ImageTypeCategory.general("")
            let newImagesUrl = productUrl(for:product.barcode).appendingPathComponent(type.description)
            if !fileManager.fileExists(atPath: newImagesUrl.path) {
                // create a directory for this product
                do {
                    try fileManager.createDirectory(at: newImagesUrl, withIntermediateDirectories: false, attributes: nil)
                } catch let error {
                    print("FileStorage: Product directory creation failed \(error.localizedDescription)")
                    return completionHandler(.failure(error))
                }
            }

            // convert the data to a json file and store that
            // store the new images
            for imageDict in product.images {
                if let fetchResult = imageDict.value.original?.fetch() {
                    switch fetchResult {
                    case .success(let image):
                        do {
                            let fileURL =  newImagesUrl.appendingPathComponent(imageDict.key).appendingPathExtension(Constant.ImageExtension)
                            try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL, options: .atomic)
                        } catch {
                            assert(true, "ProductStorage: Not able to create and write image")
                            return completionHandler(.failure(error))
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        // store the front images
        
        if !product.frontImages.isEmpty {
            let type = ImageTypeCategory.front("")
            let frontImagesUrl = productUrl(for: product.barcode).appendingPathComponent(type.description)
            if !fileManager.fileExists(atPath: frontImagesUrl.path) {
                // create a directory for this product
                do {
                    try fileManager.createDirectory(at: frontImagesUrl, withIntermediateDirectories: false, attributes: nil)
                } catch let error {
                    print("ProductStorage: Product directory creation failed \(error.localizedDescription)")
                    return completionHandler(.failure(error))
                }
            }

            for imageDict in product.frontImages {
                if let fetchResult = imageDict.value.original?.fetch() {
                    switch fetchResult {
                    case .success(let image):
                        do {
                            let fileURL =  frontImagesUrl.appendingPathComponent(imageDict.key).appendingPathExtension(Constant.ImageExtension)
                            try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL, options: .atomic)
                        } catch {
                            print("ProductStorage: Not able to create and write front image")
                            return completionHandler(.failure(error))
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        // store the selected ingredients images
        
        if !product.ingredientsImages.isEmpty {
            let type = ImageTypeCategory.ingredients("")
            let ingredientsImagesUrl = productUrl(for: product.barcode).appendingPathComponent(type.description)
            if !fileManager.fileExists(atPath: ingredientsImagesUrl.path) {
                // create a directory for this product
                do {
                    try fileManager.createDirectory(at: ingredientsImagesUrl, withIntermediateDirectories: false, attributes: nil)
                } catch let error {
                    print("ProductStorage: Product directory creation failed \(error.localizedDescription)")
                    return completionHandler(.failure(error))
                }
            }

            for imageDict in product.ingredientsImages {
                if let fetchResult = imageDict.value.original?.fetch() {
                    switch fetchResult {
                    case .success(let image):
                        do {
                            let fileURL =  ingredientsImagesUrl.appendingPathComponent(imageDict.key).appendingPathExtension(Constant.ImageExtension)
                            try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL, options: .atomic)
                        } catch {
                            assert(true, "ProductStorage: Not able to create and write image")
                            return completionHandler(.failure(error))
                        }
                    default:
                        break
                    }
                }
            }
        }
        // store the selected nutrition images
        
        if !product.nutritionImages.isEmpty {
            let type = ImageTypeCategory.nutrition("")
            let nutritionImagesUrl = productUrl(for: product.barcode).appendingPathComponent(type.description)
            if !fileManager.fileExists(atPath: nutritionImagesUrl.path) {
                // create a directory for this product
                do {
                    try fileManager.createDirectory(at: nutritionImagesUrl, withIntermediateDirectories: false, attributes: nil)
                } catch let error {
                    print("ProductStorage: Product directory creation failed \(error.localizedDescription)")
                    return completionHandler(.failure(error))
                }
            }

            for imageDict in product.nutritionImages {
                if let fetchResult = imageDict.value.original?.fetch() {
                    switch fetchResult {
                    case .success(let image):
                        do {
                            let fileURL =  nutritionImagesUrl.appendingPathComponent(imageDict.key).appendingPathExtension(Constant.ImageExtension)
                            try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL, options: .atomic)
                        } catch {
                            print("ProductStorage: Not able to create and write image")
                            return completionHandler(.failure(error))
                        }
                    default:
                        break
                    }
                }
            }
        }
        // store the selected packaging images
        
        if !product.packagingImages.isEmpty {
            let type = ImageTypeCategory.packaging("")
            let nutritionImagesUrl = productUrl(for: product.barcode).appendingPathComponent(type.description)
            if !fileManager.fileExists(atPath: nutritionImagesUrl.path) {
                // create a directory for this product
                do {
                    try fileManager.createDirectory(at: nutritionImagesUrl, withIntermediateDirectories: false, attributes: nil)
                } catch let error {
                    print("ProductStorage: Product directory creation failed \(error.localizedDescription)")
                    return completionHandler(.failure(error))
                }
            }

            for imageDict in product.packagingImages {
                if let fetchResult = imageDict.value.original?.fetch() {
                    switch fetchResult {
                    case .success(let image):
                        do {
                            let fileURL =  nutritionImagesUrl.appendingPathComponent(imageDict.key).appendingPathExtension(Constant.ImageExtension)
                            try image.jpegData(compressionQuality: 1.0)?.write(to: fileURL, options: .atomic)
                        } catch {
                            print("ProductStorage: Not able to create and write image")
                            return completionHandler(.failure(error))
                        }
                    default:
                        break
                    }
                }
            }
        }

        return completionHandler(.success(product))
    }
    
    func load(_ barcodeType: BarcodeType, completionHandler: @escaping ( FoodProduct?) -> () ) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            let product = self.read(barcodeType)
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(product)
            })
        })
        completionHandler(nil)
        return
    }

    // read locally stored product
    private func read(_ barcodeType: BarcodeType) -> FoodProduct? {
        let jsonUrl = productUrl(for: barcodeType).appendingPathExtension(Constant.JsonExtension)
        var storedFoodProduct: FoodProduct? = nil
        
        // Read the product data
        if fileManager.fileExists(atPath: jsonUrl.path) {
            do {
                let data = try Data.init(contentsOf: jsonUrl)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let productJson = try decoder.decode(OFFProductJson.self, from: data)
                    if let offProduct = productJson.product {
                        storedFoodProduct = FoodProduct.init(json: offProduct)
                    } else {
                        print("ProductStorage: no valid offProduct")
                    }
                } catch let error {
                       print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        storedFoodProduct?.images.merge(loadImages(for: barcodeType,
                                                   in: .general("")),
                                        uniquingKeysWith: { (first, last) in last })
        
        storedFoodProduct?.frontImages.merge(loadImages(for:barcodeType, in:.front("")), uniquingKeysWith: { (first, last) in last })
        
        storedFoodProduct?.ingredientsImages.merge(loadImages(for:barcodeType, in:.ingredients("")), uniquingKeysWith: { (first, last) in last })

        storedFoodProduct?.nutritionImages.merge(loadImages(for:barcodeType, in:.nutrition("")), uniquingKeysWith: { (first, last) in last })

        storedFoodProduct?.packagingImages.merge(loadImages(for:barcodeType, in:.packaging("")), uniquingKeysWith: { (first, last) in last })

        return storedFoodProduct
    }
    
    func fetchImage(for url: URL, compl: @escaping (ResultType<UIImage>) -> () ) {
        if let validImage = UIImage(contentsOfFile: url.path) {
            compl( .success(validImage) )
            return
        } else {
            compl( .failure(ImageLoadError.noValidImage) )
            return
        }
    }
    
    // delete the locally stored product directory and the files contained within
    func delete(_ barcodeType: BarcodeType) {
        do {
            try fileManager.removeItem(at: productUrl(for: barcodeType))
        } catch let error {
            print("ProductStorage: Not able to delete product: \(error.localizedDescription)")
        }
    }
    
    func fileUrl(with barcodeType:BarcodeType, for languageCode:String, and imageCategory:ImageTypeCategory) -> URL {
        // The url has the structure: /docDirectory/barcode/imageTypeCategory/languageCode.jpg
        return productUrl(for: barcodeType).appendingPathComponent(imageCategory.description).appendingPathComponent(languageCode).appendingPathExtension(Constant.ImageExtension)
        
    }
    
    private func loadImages(for barcodeType:BarcodeType, in imageTypeCategory:ImageTypeCategory) -> [String:ProductImageSize] {
        let imagesUrl = productUrl(for: barcodeType).appendingPathComponent(imageTypeCategory.description)
        var images: [String:ProductImageSize] = [:]
        // is there a new files directory?
        do {
            let fileUrls = try fileManager.contentsOfDirectory(at: imagesUrl,includingPropertiesForKeys: nil, options: [])
            for fileUrl in fileUrls {
                if fileUrl.pathExtension == Constant.ImageExtension {
                    if let validImage = UIImage(contentsOfFile: fileUrl.path) {
                        var productImageSize = ProductImageSize()
                        let key = fileUrl.deletingPathExtension().lastPathComponent
                        productImageSize.original = ProductImageData.init(image: validImage)
                        images[key] = productImageSize
                    }
                }
            }
        } catch let error {
            assert(true, "ProductStorage: Not able to create a file list \(error.localizedDescription)")
        }
        return images
    }
    
    private var fileManager: FileManager {
        return FileManager.default
    }

    private var documentsDirectoryUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    private func productUrl(for barcodeType:BarcodeType) -> URL {
        return documentsDirectoryUrl.appendingPathComponent(barcodeType.asString)

    }
}
