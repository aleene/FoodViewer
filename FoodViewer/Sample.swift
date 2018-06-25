//
//  Sample.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
//  This class ets up the sample product for the current product type

import Foundation
import UIKit

class Sample {
    
    internal struct Notification {
        static let BarcodeKey = "Sample.Notification.Barcode.Key"
    }

    fileprivate struct Sample {
        fileprivate struct Barcode {
            static let Food = "40111490"
            static let Beauty = "4005900122063"
            static let PetFood = "7613034182067"
        }
        fileprivate struct Image {
            fileprivate struct Main {
                static let Food = "SampleFoodMain"
                static let Beauty = "SampleBeautyMain"
                static let PetFood = "SamplePetFoodMain"
            }
            fileprivate struct Ingredients {
                static let Food = "SampleFoodIngredients"
                static let Beauty = "SampleBeautyIngredients"
                static let PetFood = "SamplePetFoodIngredients"
            }
            fileprivate struct Nutrition {
                static let Food = "SampleFoodNutrition"
                static let Beauty = "SampleBeautyNutrition"
                static let PetFood = "SamplePetFoodNutrition"
            }
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    private var sampleProductFetchStatus: ProductFetchStatus = .productNotLoaded( "Barcode not set")

    var product: FoodProduct? = nil
    
    private var currentBarcodeString: String {
        switch currentProductType {
        case .food:
            return Sample.Barcode.Food
        case .petFood:
            return Sample.Barcode.PetFood
        case .beauty:
            return Sample.Barcode.Beauty
        }
    }
    
    private var mainImage: String {
        switch currentProductType {
        case .food:
            return Sample.Image.Main.Food
        case .petFood:
            return Sample.Image.Main.PetFood
        case .beauty:
            return Sample.Image.Main.Beauty
        }
    }

    private var ingredientsImage: String {
        switch currentProductType {
        case .food:
            return Sample.Image.Ingredients.Food
        case .petFood:
            return Sample.Image.Ingredients.PetFood
        case .beauty:
            return Sample.Image.Ingredients.Beauty
        }
    }

    private var nutritionImage: String {
        switch currentProductType {
        case .food:
            return Sample.Image.Nutrition.Food
        case .petFood:
            return Sample.Image.Nutrition.PetFood
        case .beauty:
            return Sample.Image.Nutrition.Beauty
        }
    }

    func load(completionHandler: @escaping (FoodProduct?) -> ()) {
        // If the user runs for the first time, then there is no history available
        // Then a sample product will be shown, which is stored within the app
        switch sampleProductFetchStatus {
        case .productNotLoaded:
            self.sampleProductFetchStatus = .loading(currentBarcodeString)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = self.fetch()
                self.sampleProductFetchStatus = fetchResult
                DispatchQueue.main.async(execute: { () -> Void in
                    switch fetchResult {
                    case .success(let product):
                        completionHandler(product)
                        self.loadSampleImages()
                        return
                    default:
                        break
                    }
                })
            })
        default:
            break
        }
    }

    private func fetch() -> ProductFetchStatus {
        let filePath  = Bundle.main.path(forResource: currentBarcodeString, ofType:OFF.URL.JSONExtension)
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        if let validData = data {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let productJson = try decoder.decode(OFFProductJson.self, from:validData)
                if let offDetailedProductJson = productJson.product {
                    let newProduct = FoodProduct.init(json: offDetailedProductJson)
                    newProduct.barcode = BarcodeType.sample(newProduct.barcode.asString, newProduct.type)
                    return .success(newProduct)
                } else {
                    print("OpenFoodFactsRequest: No valid product json in sample data")
                }
            } catch let error {
                print (error)
                return .loadingFailed("sample product")
            }
        }
        return ProductFetchStatus.loadingFailed(currentBarcodeString)
    }

    private func loadSampleImages() {
        
        // The images are read from the assets catalog as UIImage
        // this ensure that the right resolution will be read
        // and then they are internally stored as PNG data
         // I need to find where the demo product is.
        switch sampleProductFetchStatus {
        case .success(let sampleProduct):
            let languageCode = sampleProduct.primaryLanguageCode ?? "en"
            if sampleProduct.frontImages[languageCode] == nil {
                sampleProduct.frontImages[languageCode] = ProductImageSize()
            }
            if let validImage = UIImage(named: mainImage) {
                    sampleProduct.frontImages[languageCode]?.small?.fetchResult = .success(validImage)
                    sampleProduct.frontImages[languageCode]?.display?.fetchResult = .success(validImage)
            } else {
                sampleProduct.frontImages[languageCode]?.small?.fetchResult = .noData
                sampleProduct.frontImages[languageCode]?.display?.fetchResult = .noData
            }
            
            if sampleProduct.ingredientsImages[languageCode] == nil {
                sampleProduct.ingredientsImages[languageCode] = ProductImageSize()
            }
            if let validImage = UIImage(named: ingredientsImage) {
                    sampleProduct.ingredientsImages[languageCode]?.small?.fetchResult = .success(validImage)
            } else {
                sampleProduct.ingredientsImages[languageCode]?.small?.fetchResult = .noData
            }
         
            if sampleProduct.nutritionImages[languageCode] == nil {
                sampleProduct.nutritionImages[languageCode] = ProductImageSize()
            }
            if let validImage = UIImage(named: nutritionImage) {
                sampleProduct.nutritionImages[languageCode]?.small?.fetchResult = .success(validImage)
            } else {
                sampleProduct.nutritionImages[languageCode]?.small?.fetchResult = .noData
            }
         
            sampleProduct.nameLanguage[languageCode] = TranslatableStrings.SampleProductName
            sampleProduct.genericNameLanguage[languageCode] = TranslatableStrings.SampleGenericProductName
         
            default: break
         }
    }

}

// Notification definitions

extension Notification.Name {
    static let SampleLoaded = Notification.Name("Sample.Notification.SampleLoaded")
    static let SampleLoadFailed = Notification.Name("Sample.Notification.SampleLoadFailed")
}



