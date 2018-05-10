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
    
    var states = Set<Completion>()
    
    func completionPercentage() -> Int {
        var val = 0.0
        let fraction = 100.0 / Double(states.count)
        for state in states {
            if state.value { val += fraction }
        }
        return Int(val)
    }
    
    func keys() -> [String] {
        return states.map( { OFF.string(for: $0) } )
    }
    
    func completionPercentageAsDouble() -> Double {
        return Double(completionPercentage()) / 100.0
    }
    
    var array: [Completion] {
        var array: [Completion] = []
        for item in self.states {
            array.append(item)
        }
        return array
    }
    
    var isEmpty: Bool {
        for state in states {
            if state.value {
                return false
            }
        }
        return true
    }
    
    /*
    func searchStringForState(with key:String) -> String? {
        
        if key == Keys.PhotosValidatedComplete && states[key] != nil {
            return states[key]!.value ?
                OFF.CompletionStatus.photosValidatedCompleted.rawValue :
                OFF.CompletionStatus.photosValidatedNotCompleted.rawValue
        }
        if key == Keys.ProductNameComplete && states[Keys.ProductNameComplete] != nil {
            return states[Keys.ProductNameComplete]!.value ?
                OFF.CompletionStatus.productNameCompleted.rawValue :
                OFF.CompletionStatus.productNameNotCompleted.rawValue
            
        }
        if key == Keys.BrandsComplete && states[Keys.BrandsComplete] != nil {
            return states[Keys.BrandsComplete]!.value ?
                OFF.CompletionStatus.brandsCompleted.rawValue :
                OFF.CompletionStatus.brandsNotCompleted.rawValue
            
        }
        if key == Keys.QuantityComplete && states[Keys.QuantityComplete] != nil {
            return states[Keys.QuantityComplete]!.value ?
                OFF.CompletionStatus.quantityCompleted.rawValue :
                OFF.CompletionStatus.quantityNotCompleted.rawValue
            
        }
        if key == Keys.PackagingComplete && states[Keys.PackagingComplete] != nil {
            return states[Keys.PackagingComplete]!.value ?
                OFF.CompletionStatus.packagingCompleted.rawValue :
                OFF.CompletionStatus.packagingNotCompleted.rawValue
            
        }
        if key == Keys.IngredientsComplete  && states[Keys.IngredientsComplete] != nil {
            return states[Keys.IngredientsComplete]!.value ?
                OFF.CompletionStatus.ingredientsCompleted.rawValue :
                OFF.CompletionStatus.ingredientsNotCompleted.rawValue
            
        }
        if key == Keys.CategoriesComplete  && states[Keys.CategoriesComplete] != nil {
            return states[Keys.CategoriesComplete]!.value ?
                OFF.CompletionStatus.categoriesCompleted.rawValue :
                OFF.CompletionStatus.categoriesNotCompleted.rawValue
            
        }
        if key == Keys.ExpirationDateComplete  && states[Keys.ExpirationDateComplete] != nil {
            return states[Keys.ExpirationDateComplete]!.value ?
                OFF.CompletionStatus.expirationDateCompleted.rawValue :
                OFF.CompletionStatus.expirationDateNotCompleted.rawValue
            
        }
        if key == Keys.PhotosUploadedComplete  && states[Keys.PhotosUploadedComplete] != nil {
            return states[Keys.PhotosUploadedComplete]!.value ?
                OFF.CompletionStatus.photosUploadedCompleted.rawValue :
                OFF.CompletionStatus.photosUploadedNotCompleted.rawValue
            
        }
        if key == Keys.NutritionFactsComplete  && states[Keys.NutritionFactsComplete] != nil {
            return states[Keys.NutritionFactsComplete]!.value ?
                OFF.CompletionStatus.nutritionFactsCompleted.rawValue :
                OFF.CompletionStatus.nutritionFactsNotCompleted.rawValue
            
        }
        return nil
    }
    */
    
    /*
    static func stateForSearchString(_ string:String) -> [String:CompletionStatus]? {
        let preferredLanguage = Locale.preferredLanguages[0]
        switch string {
        case OFF.CompletionStatus.photosUploadedCompleted.rawValue:
            return [CompletionState.Keys.PhotosUploadedComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.completionKey(for: .photosUploadedCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.photosUploadedNotCompleted.rawValue:
            return [CompletionState.Keys.PhotosUploadedComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .photosUploadedNotCompleted), language:preferredLanguage))]
        
            
        case OFF.CompletionStatus.productNameCompleted.rawValue:
            return [CompletionState.Keys.ProductNameComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.completionKey(for: .productNameCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.productNameNotCompleted.rawValue:
            return [CompletionState.Keys.ProductNameComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .productNameNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.brandsCompleted.rawValue:
            return [CompletionState.Keys.BrandsComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.completionKey(for: .brandsCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.brandsNotCompleted.rawValue:
            return [CompletionState.Keys.BrandsComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .brandsNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.quantityCompleted.rawValue:
            return [CompletionState.Keys.QuantityComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.completionKey(for: .quantityCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.quantityNotCompleted.rawValue:
            return [CompletionState.Keys.QuantityComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .quantityNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.packagingCompleted.rawValue:
            return [CompletionState.Keys.PackagingComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.completionKey(for: .packagingCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.packagingNotCompleted.rawValue:
            return [CompletionState.Keys.PackagingComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .packagingNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.categoriesCompleted.rawValue:
            return [CompletionState.Keys.CategoriesComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.completionKey(for: .categoriesCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.categoriesNotCompleted.rawValue:
            return [CompletionState.Keys.CategoriesComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .categoriesNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.nutritionFactsCompleted.rawValue:
            return [CompletionState.Keys.NutritionFactsComplete:
                    CompletionStatus.init( true, and:OFFplists.manager.translateStates(OFF.completionKey(for: .nutritionFactsCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.nutritionFactsNotCompleted.rawValue:
            return [CompletionState.Keys.NutritionFactsComplete:
                CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .nutritionFactsNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.photosValidatedCompleted.rawValue:
            return [CompletionState.Keys.PhotosValidatedComplete:
                    CompletionStatus.init( true, and: OFFplists.manager.translateStates(OFF.completionKey(for: .photosValidatedCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.photosValidatedNotCompleted.rawValue:
            return [CompletionState.Keys.PhotosValidatedComplete:
                CompletionStatus.init( false, and: OFFplists.manager.translateStates(OFF.completionKey(for: .photosValidatedNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.ingredientsCompleted.rawValue:
            return [CompletionState.Keys.IngredientsComplete:
                CompletionStatus.init( true, and: OFFplists.manager.translateStates(OFF.completionKey(for: .ingredientsCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.ingredientsNotCompleted.rawValue:
            return [CompletionState.Keys.IngredientsComplete:
                CompletionStatus.init( false, and: OFFplists.manager.translateStates(OFF.completionKey(for: .ingredientsNotCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.expirationDateCompleted.rawValue:
            return [CompletionState.Keys.ExpirationDateComplete:
                    CompletionStatus.init( true, and: OFFplists.manager.translateStates(OFF.completionKey(for: .expirationDateCompleted), language:preferredLanguage))]
            
        case OFF.CompletionStatus.expirationDateNotCompleted.rawValue:
            return [CompletionState.Keys.ExpirationDateComplete:
                    CompletionStatus.init( false, and:OFFplists.manager.translateStates(OFF.completionKey(for: .expirationDateNotCompleted), language:preferredLanguage))]
        default:
            break
        }
        return nil
    }
     */
}



