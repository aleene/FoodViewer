//
//  CompletionState.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// completion states parameters
struct CompletionState {
    
    struct Keys {
        static let BrandsComplete = "brandsComplete"
        static let CategoriesComplete = "categoriesComplete"
        static let ExpirationDateComplete = "expirationDateComplete"
        static let IngredientsComplete = "ingredientsComplete"
        static let NutritionFactsComplete = "nutritionFactsComplete"
        static let PhotosValidatedComplete = "photosValidatedComplete"
        static let ProductNameComplete = "productNameComplete"
        static let QuantityComplete = "quantityComplete"
        static let PackagingComplete = "packagingComplete"
        static let PhotosUploadedComplete = "photosUploadedComplete"
    }
    var states: [String:CompletionStatus]
   //var photosValidatedComplete: CompletionStatus = nil
    //var productNameComplete: CompletionStatus  = nil
    //var brandsComplete: CompletionStatus = nil
    //var quantityComplete: CompletionStatus = nil
    //var packagingComplete: CompletionStatus = nil
    //var categoriesComplete: CompletionStatus = nil
    //var nutritionFactsComplete: CompletionStatus = nil
    //var photosUploadedComplete: CompletionStatus = nil
    //var ingredientsComplete: CompletionStatus = nil
    //var expirationDateComplete: CompletionStatus = nil
    
    func completionPercentage() -> Int {
        var val = 0
        if states[Keys.PhotosValidatedComplete] != nil && states[Keys.PhotosValidatedComplete]!.value { val = val + 10 }
        if states[Keys.ProductNameComplete] != nil && states[Keys.ProductNameComplete]!.value { val = val + 10 }
        if states[Keys.BrandsComplete] != nil && states[Keys.BrandsComplete]!.value { val = val + 10 }
        if states[Keys.QuantityComplete] != nil && states[Keys.QuantityComplete]!.value { val = val + 10 }
        if states[Keys.PackagingComplete] != nil && states[Keys.PackagingComplete]!.value { val = val + 10 }
        if states[Keys.CategoriesComplete] != nil && states[Keys.CategoriesComplete]!.value { val = val + 10 }
        if states[Keys.NutritionFactsComplete] != nil && states[Keys.NutritionFactsComplete]!.value { val = val + 10 }
        if states[Keys.PhotosUploadedComplete] != nil && states[Keys.PhotosUploadedComplete]!.value { val = val + 10 }
        if states[Keys.IngredientsComplete] != nil && states[Keys.IngredientsComplete]!.value { val = val + 10 }
        if states[Keys.ExpirationDateComplete] != nil && states[Keys.ExpirationDateComplete]!.value { val = val + 10 }
        return val
    }
    
    func keys() -> [String] {
        var keys: [String] = []
        if states[Keys.PhotosValidatedComplete] != nil {
            keys.append(Keys.PhotosValidatedComplete)
        }
        if states[Keys.ProductNameComplete] != nil {
            keys.append(Keys.ProductNameComplete)
        }
        if states[Keys.BrandsComplete] != nil {
            keys.append(Keys.BrandsComplete)
        }
        if states[Keys.QuantityComplete] != nil {
            keys.append(Keys.QuantityComplete)
        }
        if states[Keys.PackagingComplete] != nil {
            keys.append(Keys.PackagingComplete)
        }
        if states[Keys.CategoriesComplete] != nil {
            keys.append(Keys.CategoriesComplete)
        }
        if states[Keys.NutritionFactsComplete] != nil {
            keys.append(Keys.NutritionFactsComplete)
        }
        if states[Keys.PhotosUploadedComplete] != nil {
            keys.append(Keys.PhotosUploadedComplete)
        }
        if states[Keys.IngredientsComplete] != nil {
            keys.append(Keys.IngredientsComplete)
        }
        if states[Keys.ExpirationDateComplete] != nil {
            keys.append(Keys.ExpirationDateComplete)
        }
        return keys
    }
    
    func completionPercentageAsDouble() -> Double {
        return Double(completionPercentage()) / 100.0
    }
    
    func searchStringForState(with key:String) -> String? {
        if key == Keys.PhotosValidatedComplete && states[key] != nil {
            return states[key]!.value ?
                OFF.SearchStatus.photosValidatedCompleted.rawValue :
                OFF.SearchStatus.photosValidatedNotCompleted.rawValue
        }
        if key == Keys.ProductNameComplete && states[Keys.ProductNameComplete] != nil {
            return states[Keys.ProductNameComplete]!.value ?
                OFF.SearchStatus.productNameCompleted.rawValue :
                OFF.SearchStatus.productNameNotCompleted.rawValue
            
        }
        if key == Keys.BrandsComplete && states[Keys.BrandsComplete] != nil {
            return states[Keys.BrandsComplete]!.value ?
                OFF.SearchStatus.brandsCompleted.rawValue :
                OFF.SearchStatus.brandsNotCompleted.rawValue
            
        }
        if key == Keys.QuantityComplete && states[Keys.QuantityComplete] != nil {
            return states[Keys.QuantityComplete]!.value ?
                OFF.SearchStatus.quantityCompleted.rawValue :
                OFF.SearchStatus.quantityNotCompleted.rawValue
            
        }
        if key == Keys.PackagingComplete && states[Keys.PackagingComplete] != nil {
            return states[Keys.PackagingComplete]!.value ?
                OFF.SearchStatus.packagingCompleted.rawValue :
                OFF.SearchStatus.packagingNotCompleted.rawValue
            
        }
        if key == Keys.IngredientsComplete  && states[Keys.IngredientsComplete] != nil {
            return states[Keys.IngredientsComplete]!.value ?
                OFF.SearchStatus.ingredientsCompleted.rawValue :
                OFF.SearchStatus.ingredientsNotCompleted.rawValue
            
        }
        if key == Keys.CategoriesComplete  && states[Keys.CategoriesComplete] != nil {
            return states[Keys.CategoriesComplete]!.value ?
                OFF.SearchStatus.categoriesCompleted.rawValue :
                OFF.SearchStatus.categoriesNotCompleted.rawValue
            
        }
        if key == Keys.ExpirationDateComplete  && states[Keys.ExpirationDateComplete] != nil {
            return states[Keys.ExpirationDateComplete]!.value ?
                OFF.SearchStatus.expirationDateCompleted.rawValue :
                OFF.SearchStatus.expirationDateNotCompleted.rawValue
            
        }
        if key == Keys.PhotosUploadedComplete  && states[Keys.PhotosUploadedComplete] != nil {
            return states[Keys.PhotosUploadedComplete]!.value ?
                OFF.SearchStatus.photosUploadedCompleted.rawValue :
                OFF.SearchStatus.photosUploadedNotCompleted.rawValue
            
        }
        if key == Keys.NutritionFactsComplete  && states[Keys.NutritionFactsComplete] != nil {
            return states[Keys.NutritionFactsComplete]!.value ?
                OFF.SearchStatus.nutritionFactsCompleted.rawValue :
                OFF.SearchStatus.nutritionFactsNotCompleted.rawValue
            
        }
        return nil
    }
    
    static func stateForSearchString(_ string:String) -> [String:CompletionStatus]? {
        let preferredLanguage = Locale.preferredLanguages[0]
        switch string {
        case OFF.SearchStatus.photosUploadedCompleted.rawValue:
            return [CompletionState.Keys.PhotosUploadedComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.PhotosUploaded, language:preferredLanguage))]
            
        case OFF.SearchStatus.nutritionFactsNotCompleted.rawValue:
            return [CompletionState.Keys.PhotosUploadedComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.PhotosUploaded, language:preferredLanguage))]
        
            
        case OFF.SearchStatus.productNameCompleted.rawValue:
            return [CompletionState.Keys.ProductNameComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.ProductName, language:preferredLanguage))]
            
        case OFF.SearchStatus.productNameNotCompleted.rawValue:
            return [CompletionState.Keys.ProductNameComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.ProductNameTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.brandsCompleted.rawValue:
            return [CompletionState.Keys.BrandsComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.Brands, language:preferredLanguage))]
            
        case OFF.SearchStatus.brandsNotCompleted.rawValue:
            return [CompletionState.Keys.BrandsComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.BrandsTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.quantityCompleted.rawValue:
            return [CompletionState.Keys.QuantityComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.Quantity, language:preferredLanguage))]
            
        case OFF.SearchStatus.quantityNotCompleted.rawValue:
            return [CompletionState.Keys.QuantityComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.QuantityTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.packagingCompleted.rawValue:
            return [CompletionState.Keys.PackagingComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.Packaging, language:preferredLanguage))]
            
        case OFF.SearchStatus.packagingNotCompleted.rawValue:
            return [CompletionState.Keys.PackagingComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.PackagingTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.categoriesCompleted.rawValue:
            return [CompletionState.Keys.CategoriesComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.Categories, language:preferredLanguage))]
            
        case OFF.SearchStatus.categoriesNotCompleted.rawValue:
            return [CompletionState.Keys.CategoriesComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.CategoriesTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.nutritionFactsCompleted.rawValue:
            return [CompletionState.Keys.NutritionFactsComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.nutrimentKeys, language:preferredLanguage))]
            
        case OFF.SearchStatus.nutritionFactsNotCompleted.rawValue:
            return [CompletionState.Keys.NutritionFactsComplete:
                CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.nutrimentKeysTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.photosValidatedCompleted.rawValue:
            return [CompletionState.Keys.PhotosValidatedComplete:
                    CompletionStatus.init( true, and: OFFplists.manager.translateStates(OFF.StateCompleteKey.PhotosValidated, language:preferredLanguage))]
            
        case OFF.SearchStatus.photosValidatedNotCompleted.rawValue:
            return [CompletionState.Keys.PhotosValidatedComplete:
                CompletionStatus.init( false, and: OFFplists.manager.translateStates(OFF.StateCompleteKey.PhotosValidatedTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.ingredientsCompleted.rawValue:
            return [CompletionState.Keys.IngredientsComplete:
                CompletionStatus.init( true, and: OFFplists.manager.translateStates(OFF.StateCompleteKey.Ingredients, language:preferredLanguage))]
            
        case OFF.SearchStatus.ingredientsNotCompleted.rawValue:
            return [CompletionState.Keys.IngredientsComplete:
                CompletionStatus.init( false, and: OFFplists.manager.translateStates(OFF.StateCompleteKey.IngredientsTBD, language:preferredLanguage))]
            
        case OFF.SearchStatus.expirationDateCompleted.rawValue:
            return [CompletionState.Keys.ExpirationDateComplete:
                    CompletionStatus.init( true, and: OFFplists.manager.translateStates(OFF.StateCompleteKey.ExpirationDate, language:preferredLanguage))]
            
        case OFF.SearchStatus.expirationDateNotCompleted.rawValue:
            return [CompletionState.Keys.ExpirationDateComplete: CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.StateCompleteKey.ExpirationDateTBD, language:preferredLanguage))]
        default:
            break
        }
        return nil
    }
}



