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
        static let APIURLPrefixForFoodProduct = "https://world.openfoodfacts.org/api/v0/product/"
        static let APIURLPrefixForBeautyProduct = "https://world.openbeautyfacts.org/api/v0/product/"
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

        //DispatchQueue.main.async(execute: { () -> Void in
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //})
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
                        newProduct.json = JSON.convertFromData(data)
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
                //DispatchQueue.main.async(execute: { () -> Void in
                //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //})
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
        //DispatchQueue.main.async(execute: { () -> Void in
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //})
        let fetchUrl = URL(string: OFF.fetchString(for: barcode, with: currentProductType))
        
        //DispatchQueue.main.async(execute: { () -> Void in
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
        //})
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

    func fetchAttributesJson(for barcode: BarcodeType, in languageCode: String, completion: @escaping (ProductFetchStatus) -> ()) {
        self.currentBarcode = barcode
        //DispatchQueue.main.async(execute: { () -> Void in
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //})
        let fetchUrl = URL(string: OFF.fetchAttributesString(for: barcode, with: currentProductType, languageCode: languageCode) )
        if debug { print("OpenFoodFactsRequest:fetchAttributesForBarcodeInLanguageCode(_:_) - \(String(describing: fetchUrl))") }
        if let validURL = fetchUrl {
            let cache = Shared.dataCache
            cache.fetch(URL: validURL).onSuccess { data in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let productJson = try decoder.decode(OFFProductJson.self, from: data)
                    if let offProduct = productJson.product {
                        let newProduct = FoodProduct.init(attributesJson: offProduct)
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
                //DispatchQueue.main.async(execute: { () -> Void in
                //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //})
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
    
    /// gets a single random robotoff question
    func fetchRandomRobotoffQuestionsJson(in interfaceLanguageCode: String, count: Int?, completion: @escaping (OFFRobotoffQuestionFetchStatus) -> ()) {
        fetchRobotoffQuestionsJson(for: nil, in: interfaceLanguageCode, count: count, completion: completion)
    }
    
    func fetchRobotoffQuestionsJson(for barcode: BarcodeType?, in interfaceLanguageCode: String, count: Int?, completion: @escaping (OFFRobotoffQuestionFetchStatus) -> ()) {
        self.currentBarcode = barcode
        //DispatchQueue.main.async(execute: { () -> Void in
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //})
        let fetchUrl = URL(string: OFF.fetchQuestionsString(for: barcode, with: currentProductType, languageCode: interfaceLanguageCode, count: nil) )
        if debug { print("OpenFoodFactsRequest:fetchRobotoffQuestionsJson(_:_) - \(String(describing: fetchUrl))") }
        if let validURL = fetchUrl {
            let cache = Shared.dataCache
            cache.fetch(URL: validURL).onSuccess { data in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let questionsJson = try decoder.decode(OFFRobotoffQuestionJson.self, from: data)
                    if let questions = questionsJson.questions {
                        var newQuestions: [RobotoffQuestion] = []
                        for question in questions {
                            newQuestions.append(RobotoffQuestion.init(jsonQuestion: question))
                        }
                        completion(.success(newQuestions))
                    } else {
                        if questionsJson.status == "not found" {
                            completion(.questionNotAvailable(barcode?.asString ?? ""))
                        }
                    }
                } catch let error {
                    print(error)
                    completion(.failed(barcode?.asString ?? ""))
                }
                //DispatchQueue.main.async(execute: { () -> Void in
                //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                //})
                return
            }
            cache.fetch(URL: validURL).onFailure { error in
                completion(.failed(barcode?.asString ?? ""))
            }
        } else {
            completion(.failed(self.currentBarcode!.asString))
            return
        }
    }

}
