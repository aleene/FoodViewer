 //
//  OpenFoodFactsRequest.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class OpenFoodFactsRequest {
    
    private var debug = false
    
    fileprivate struct OpenFoodFacts {
        // static let JSONExtension = ".json"
        static let APIURLPrefixForFoodProduct = "http://world.openfoodfacts.org/api/v0/product/"
        static let APIURLPrefixForBeautyProduct = "http://world.openbeautyfacts.org/api/v0/product/"
        //static let FoodSampleProductBarcode = "40111490"
        //static let BeautySampleProductBarcode = "4005900122063"
        //static let PetFoodSampleProductBarcode = "3166780740950"
    }
    
    enum FetchJsonResult {
        case error(String)
        case success(Data)
    }

    var fetched: ProductFetchStatus = .initialized
    
    var currentBarcode: BarcodeType? = nil
    
    func fetchStoredProduct(_ data: Data, completion: @escaping (ProductFetchStatus) -> ()) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            //print(String(data: data, encoding: .utf8)!)

            let productJson = try decoder.decode(OFFProductJson.self, from:data)

            if let offProductDetailed = productJson.product {
                let newProduct = FoodProduct.init(json: offProductDetailed)
                // in case the code was missing in the product json
                if newProduct.barcode.asString == "no code" {
                    newProduct.barcode = BarcodeType(barcodeString: productJson.code, type: newProduct.barcode.productType!)
                }
                completion(.success(newProduct))
            } else {
                completion(.loadingFailed("OpenFoodFactsRequest: No valid stored product json"))
            }
            
        } catch let error {
            print (error)
            completion(.loadingFailed(error.localizedDescription))
        }

        return
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    func url(for barcodeType: BarcodeType) -> URL? {
        var fetchUrlString = OFF.URL.Prefix
        // add the right server
        fetchUrlString += barcodeType.productType != nil ? barcodeType.productType!.rawValue : currentProductType.rawValue
        fetchUrlString += OFF.URL.Postfix
        fetchUrlString += barcodeType.asString + OFF.URL.JSONExtension
        return URL(string: fetchUrlString)

    }

    func fetchProduct(for barcode: BarcodeType, shouldBeReloaded: Bool, completion: @escaping (ProductFetchStatus) -> ()) {
        self.currentBarcode = barcode

        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
        if let validURL = url(for: barcode) {
            let cache = Shared.dataCache
            // the data should be reloaded from off
            if shouldBeReloaded {
                cache.remove(key: validURL.absoluteString)
            }
            cache.fetch(URL: validURL).onSuccess { data in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let productJson = try decoder.decode(OFFProductJson.self, from: data)
                    if let offProduct = productJson.product {
                        let newProduct = FoodProduct.init(json: offProduct)
                        completion(.success(newProduct))
                    } else {
                        if productJson.status_verbose == "product not found" {
                            completion(.productNotAvailable(barcode.asString))
                        } else {
                            completion(.loadingFailed(barcode.asString))
                        }
                    }
                } catch let error {
                    print(error)
                    completion(.loadingFailed(barcode.asString))
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
                return
            }
            cache.fetch(URL: validURL).onFailure { error in
                completion(.loadingFailed(barcode.asString))
            }
        } else {
            completion(.loadingFailed(self.currentBarcode!.asString))
            return
        }
    }

    func fetchJson(for barcode: BarcodeType) -> FetchJsonResult {
        self.currentBarcode = barcode
        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
        let fetchUrl = URL(string: OFF.fetchString(for: barcode, with: currentProductType))
        
        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
        if debug { print("OpenFoodFactsRequest:fetchJsonForBarcode(_:_) - \(String(describing: fetchUrl))") }
        if let url = fetchUrl {
            do {
                let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                
                return FetchJsonResult.success(data)
            } catch let error as NSError {
                print(error);
                return FetchJsonResult.error(error.description)
            }
        } else {
            return FetchJsonResult.error("OpenFoodFactsRequest: URL not matched")
        }
    }


}
