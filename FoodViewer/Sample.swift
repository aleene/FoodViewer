//
//  Sample.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
//  This class ets up the sample product for the current product type

import Foundation

class Sample {
    
    internal struct Notification {
        static let BarcodeKey = "Sample.Notification.Barcode.Key"
    }

    fileprivate struct Barcode {
        static let FoodSample = "40111490"
        static let BeautySample = "4005900122063"
        static let PetFoodSample = "3166780740950"
    }

    // on init we can start the load process
    init() {
        load()
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    private var sampleProductFetchStatus: ProductFetchStatus = .productNotLoaded( "Barcode not set")

    var product: FoodProduct {
        get {
            switch sampleProductFetchStatus {
            case .success(let product):
                return product
            case .productNotLoaded:
                load() // do we ever get here '
            default:
                break
            }
            // if the product is not loaded yet, return an empty food product.
            return FoodProduct(with: BarcodeType(barcodeString: currentBarcodeString, type: currentProductType))
        }
    }
    
    private var currentBarcodeString: String {
        switch currentProductType {
        case .food:
            return Barcode.FoodSample
        case .petFood:
            return Barcode.PetFoodSample
        case .beauty:
            return Barcode.BeautySample
        }
    }
    
    private func load() {
        // If the user runs for the first time, then there is no history available
        // Then a sample product will be shown, which is stored within the app
        switch sampleProductFetchStatus {
        case .productNotLoaded:
            self.sampleProductFetchStatus = .loading(currentBarcodeString)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = self.fetch()
                DispatchQueue.main.async(execute: { () -> Void in
                    self.sampleProductFetchStatus = fetchResult
                })
            })
        default:
            break
        }
    }

    private func fetch() -> ProductFetchStatus {
        var resource: String = ""
        switch currentProductType {
        case .food:
            resource = Barcode.FoodSample
        case .petFood:
            resource = Barcode.PetFoodSample
        case .beauty:
            resource = Barcode.BeautySample
        }
        let filePath  = Bundle.main.path(forResource: resource, ofType:OFF.URL.JSONExtension)
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        if let validData = data {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let productJson = try decoder.decode(OFFProductJson.self, from:validData)
                if let offDetailedProductJson = productJson.product {
                    let newProduct = FoodProduct.init(json: offDetailedProductJson)
                    return .success(newProduct)
                } else {
                    print("OpenFoodFactsRequest: No valid product json in sample data")
                    return ProductFetchStatus.loadingFailed(resource)
                }
            } catch let error {
                print (error)
                return .loadingFailed("sample product")
            }
        } else {
            return ProductFetchStatus.loadingFailed(resource)
        }
    }

    private func loadSampleImages() {
        
        // The images are read from the assets catalog as UIImage
        // this ensure that the right resolution will be read
        // and then they are internally stored as PNG data
        /*
         // I need to find where the demo product is.
         if let validFetchResult = allProductFetchResultList[0] {
         switch validFetchResult {
         case .success(let sampleProduct):
         let languageCode = sampleProduct.primaryLanguageCode ?? "en"
         
         if let image = UIImage(named: "SampleMain") {
         if let data = UIImagePNGRepresentation(image) {
         sampleProduct.frontImages?.small[languageCode]?.fetchResult = .success(data)
         sampleProduct.frontImages?.display[languageCode]?.fetchResult = .success(data)
         }
         } else {
         sampleProduct.frontImages?.small[languageCode]?.fetchResult = .noData
         sampleProduct.frontImages?.display[languageCode]?.fetchResult = .noData
         }
         
         if let image = UIImage(named: "SampleIngredients") {
         if let data = UIImagePNGRepresentation(image) {
         sampleProduct.ingredientsImages?.small[languageCode]?.fetchResult = .success(data)
         }
         } else {
         sampleProduct.ingredientsImages?.small[languageCode]?.fetchResult = .noData
         }
         
         if let image = UIImage(named: "SampleNutrition") {
         if let data = UIImagePNGRepresentation(image) {
         sampleProduct.nutritionImages?.small[languageCode]?.fetchResult = .success(data)
         }
         } else {
         sampleProduct.nutritionImages?.small[languageCode]?.fetchResult = .noData
         }
         
         sampleProduct.nameLanguage["en"] = NSLocalizedString("Sample Product for Demonstration, the globally known M&M's", comment: "Product name of the product shown at first start")
         sampleProduct.genericNameLanguage["en"] = NSLocalizedString("This sample product shows you how a product is presented. Slide to the following pages, in order to see more product details. Once you start scanning barcodes, you will no longer see this sample product.", comment: "An explanatory text in the common name field.")
         
         default: break
         }
         }
         */
    }

}

// Notification definitions

extension Notification.Name {
    static let SampleLoaded = Notification.Name("Sample.Notification.SampleLoaded")
    static let SampleLoadFailed = Notification.Name("Sample.Notification.SampleLoadFailed")
}



