//
//  ProductUpdate.swift
//  FoodViewer
//
//  Created by arnaud on 28/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit
class ProductUpdate: OFFProductUpdateAPI {
    
    func update(product: FoodProduct, completionHandler: @escaping (ProductUpdateStatus?) -> () ) {
        
        // update only the fields that have something defined, i.e. are not nil
        var productUpdated: Bool = false
        switch product.barcode {
        case .notSet:
            assert(true,"ProductUpdate: barcode not set")
        default:
            break
        }
        let interfaceLanguageCode = Locale.preferredLanguages[0].split(separator:"-").map(String.init)[0]
        
        // The OFF interface assumes that values are in english
        let languageCodeToUse = "en"
        
        var urlString = OFFWriteAPI.SecurePrefix
            + ( product.type?.rawValue ?? ProductType.food.rawValue )
            + OFFWriteAPI.Domain
            + OFFWriteAPI.PostPrefix
            + OFFWriteAPI.Barcode + product.barcode.asString + OFFWriteAPI.Delimiter
            + OFFWriteAPI.UserId + OFFAccount().userId + OFFWriteAPI.Delimiter
            + OFFWriteAPI.Password + OFFAccount().password
        
        if product.nameLanguage.count > 0 {
            for name in product.nameLanguage {
                if let validName = name.value?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                    urlString.append(OFFWriteAPI.Delimiter +
                        OFFWriteAPI.Name +
                        OFFWriteAPI.LanguageSpacer +
                        name.key +
                        OFFWriteAPI.Equal +
                        validName)
                    productUpdated = true
                }
            }
        }
        
        if product.genericNameLanguage.count > 0 {
            for genericName in product.genericNameLanguage {
                if let name = genericName.value?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                    urlString.append(OFFWriteAPI.Delimiter +
                        OFFWriteAPI.GenericName +
                        OFFWriteAPI.LanguageSpacer +
                        genericName.key +
                        OFFWriteAPI.Equal +
                        name )
                    productUpdated = true
                }
            }
        }
        
        if let quantity = product.quantity?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Quantity + quantity)
            productUpdated = true
        }
        
        // Using this for writing in a specific language (ingredients_text_fr=) has no effect
        if product.ingredientsLanguage.count > 0 {
            for name in product.ingredientsLanguage {
                if let validName = name.value?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                    urlString.append(
                        OFFWriteAPI.Delimiter +
                            OFFWriteAPI.Ingredients +
                            OFFWriteAPI.LanguageSpacer +
                            name.key +
                            OFFWriteAPI.Equal +
                        validName
                    )
                    productUpdated = true
                }
            }
        }
        
        if let primaryLanguage = product.primaryLanguageCode?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            // TODO - this is also updated if no change has taken place
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.PrimaryLanguageCode + primaryLanguage)
            productUpdated = true
        }
        
        if let expirationDate = product.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            if let validString = formatter.string(from: expirationDate as Date).addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.ExpirationDate + validString )
            }
            productUpdated = true
        }
        
        switch product.purchasePlacesOriginal {
        case .available(let location):
            let string = location.flatMap{
                $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
                }.joined(separator: ",")
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.PurchasePlaces + string )
            productUpdated = true
        // maybe the location is available as raw data
        default:
            break
        }
        
        switch product.storesOriginal {
        case .available(let validShop):
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.Stores + validShop.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
            
        default:
            break
        }
        
        if product.type != nil && product.type != .beauty {
            for fact in product.nutritionFactsDict {
                if let validValue = fact.value.standardValue {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: fact.key) + OFFWriteAPI.Equal + validValue)
                            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPer100g)
                } else if let validValue = fact.value.servingValue {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: fact.key) + OFFWriteAPI.Equal + validValue)
                            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPerServing)
                }
                        
                if let validValueUnit = fact.value.standardValueUnit?.short() {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: fact.key))
                            urlString.append(OFFWriteAPI.NutrimentUnit + OFFWriteAPI.Equal + validValueUnit.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
                } else if let validValueUnit = fact.value.servingValueUnit?.short() {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: fact.key))
                    urlString.append(OFFWriteAPI.NutrimentUnit + OFFWriteAPI.Equal + validValueUnit.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
                }
                productUpdated = true
            }
        }
        
        switch product.brandsOriginal {
        case let .available(list):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Brands + list.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ","))
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Brands)
            productUpdated = true
        default:
            break
        }
        
        switch product.packagingOriginal {
        case .available:
            // take into account the language of the tags
            // if a tag has no prefix, a prefix must be added
            let list = product.packagingOriginal.tags(withAdded: interfaceLanguageCode, andRemoved: languageCodeToUse)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging + list.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging)
            productUpdated = true
        default:
            break
        }
        
        switch product.labelsOriginal {
        case .available:
            // take into account the language of the tags
            let list = product.labelsOriginal.tags(withAdded: interfaceLanguageCode, andRemoved: languageCodeToUse)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels + list.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels)
            productUpdated = true
        default:
            break
        }
        
        switch product.tracesOriginal {
        case .available:
            // take into account the language of the tags
            let list = product.tracesOriginal.tags(withAdded: interfaceLanguageCode, andRemoved: languageCodeToUse)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces + list.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces)
            productUpdated = true
        default:
            break
        }
        
        switch product.categoriesOriginal {
        case .available:
            // take into account the language of the tags
            let list = product.categoriesOriginal.tags(withAdded: interfaceLanguageCode, andRemoved: languageCodeToUse)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories + list.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories)
            productUpdated = true
        default:
            break
        }
        
        switch product.manufacturingPlacesOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Producer + places.flatMap{ $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        switch product.originsOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.IngredientsOrigin + places.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        switch product.embCodesOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ProducerCode + places.flatMap{ $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        switch product.countriesOriginal {
        case .available:
            let list = product.countriesOriginal.tags(withAdded: interfaceLanguageCode, andRemoved: languageCodeToUse)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Countries + list.flatMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        if let validLinks = product.links {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Links + validLinks.flatMap{ $0.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined(separator: ",") )
            productUpdated = true
        }
        
        if let validServingSize = product.servingSize {
            if let encodedServingSize = validServingSize.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ServingSize + encodedServingSize)
                productUpdated = true
            }
        }
        
        if product.type != nil && product.type != .beauty {
            if let validHasNutritionFacts = product.hasNutritionFacts {
                if !validHasNutritionFacts {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NoNutriments )
                } else {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Nutriments )
                }
                productUpdated = true
            }
        }
        
        if let validPeriodAfterOpeningString = product.periodAfterOpeningString {
            if let encodedValidPeriodAfterOpeningString = validPeriodAfterOpeningString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.PeriodAfterOpening + encodedValidPeriodAfterOpeningString )
                productUpdated = true
            }
        }
        
        if let validID = UIDevice.current.identifierForVendor?.uuidString {
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.Comment + (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String) + "-" + validID )
        }
        
        if productUpdated {
            super.update(urlString: urlString ) {
                ( json: OFFProductUploadResultJson? ) in
                if let validJson = json {
                    if let validStatus = validJson.status {
                        if validStatus == 0 {
                            return completionHandler (ProductUpdateStatus.failure(product.barcode.asString, "\(validStatus)") )
                        } else if validJson.status == 1 {
                            return completionHandler (ProductUpdateStatus.success(product.barcode.asString, "\(validStatus)"))
                        } else {
                            return completionHandler (ProductUpdateStatus.failure(product.barcode.asString, "ProductUpdate: unexpected status_code"))
                        }
                    }
                    completionHandler(nil)
                }
            }
        } else {
            completionHandler(nil)
        }
    }
    
    // remove the language identifier before the colon
    private func removeLanguage(from key: String) -> String {
        let elementsPair = key.split(separator:":").map(String.init)
        if elementsPair.count == 1 {
            return elementsPair[0]
        } else {
            return elementsPair[1]
        }
    }

}