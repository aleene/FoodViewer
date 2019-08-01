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
    
    private var product: FoodProduct? = nil
    private var productUpdateCompletion: ((ResultType<OFFProductUploadResultJson>) -> () ) = { _ in }
    
    init(product: FoodProduct, completion: @escaping (ResultType<OFFProductUploadResultJson>) -> () ) {
        super.init(URLString: nil, completion: {
            ( myCompletionHandler: ResultType<OFFProductUploadResultJson> ) in
            switch myCompletionHandler {
            case .success(let json):
                if let validStatus = json.status {
                    if validStatus == 0 {
                        let error = NSError.init(domain: "FoodViewer",
                                                 code: 13,
                                                 userInfo:["Class": "ProductUpdate",
                                                           "Function": "update(product: FoodProduct, completion: @escaping (ResultType<OFFProductUploadResultJson>) -> () )",
                                                           "Reason": "status 0 received"])
                        return completion(.failure(error))
                    } else if json.status == 1 {
                        return completion (.success(json))
                    } else {
                        let error = NSError.init(domain: "FoodViewer",
                                                 code: 13,
                                                 userInfo:["Class": "ProductUpdate",
                                                           "Function": "update(product: FoodProduct, completion: @escaping (ResultType<OFFProductUploadResultJson>) -> () )",
                                                           "Reason": "Unrecognized status_code received"])
                        return completion(.failure(error))
                    }
                }
                let error = NSError.init(domain: "FoodViewer",
                                         code: 13,
                                         userInfo:["Class": "ProductUpdate",
                                                   "Function": "update(product: FoodProduct, completion: @escaping (ResultType<OFFProductUploadResultJson>) -> () )",
                                                   "Reason": "no valid status_code received"])
                return completion(.failure(error))
                
            case .failure(let error):
                return completion (.failure(error))
            }
        })
        self.product = product
        self.productUpdateCompletion = completion
    }
    
    override func main() {
        guard let validProduct = product else { return }
        // update only the fields that have something defined, i.e. are not nil
        var productUpdated: Bool = false
        switch validProduct.barcode {
        case .notSet:
            assert(true,"ProductUpdate: barcode not set")
        default:
            break
        }
        
        // The language code used to write tags is either the product language code or the interface language code
        
        let interfaceLanguageCode = Locale.preferredLanguages[0].split(separator:"-").map(String.init)[0]
        let productLanguageCode = validProduct.primaryLanguageCode
        
        var useProductLanguageCode: Bool {
            return TagEntryLanguageDefaults.manager.productLanguageNotSystemLanguage ??  true
        }
        let languageCodeForWrite = useProductLanguageCode ? (productLanguageCode ?? interfaceLanguageCode) : interfaceLanguageCode
        
        // The OFF interface assumes that values are in english
        let defaultLanguageCode = "en"
        
        var urlString = OFFWriteAPI.SecurePrefix
            + ( validProduct.type?.rawValue ?? ProductType.food.rawValue )
            + OFFWriteAPI.Domain
            + OFFWriteAPI.PostPrefix
            + OFFWriteAPI.Barcode + validProduct.barcode.asString + OFFWriteAPI.Delimiter
            + OFFWriteAPI.UserId + OFFAccount().userId + OFFWriteAPI.Delimiter
            + OFFWriteAPI.Password + OFFAccount().password
        
        if validProduct.nameLanguage.count > 0 {
            for name in validProduct.nameLanguage {
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
        
        if validProduct.genericNameLanguage.count > 0 {
            for genericName in validProduct.genericNameLanguage {
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
        
        if let quantity = validProduct.quantity?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Quantity + quantity)
            productUpdated = true
        }
        
        // Using this for writing in a specific language (ingredients_text_fr=) has no effect
        if validProduct.ingredientsLanguage.count > 0 {
            for name in validProduct.ingredientsLanguage {
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
        
        if let primaryLanguage = validProduct.primaryLanguageCode?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            // TODO - this is also updated if no change has taken place
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.PrimaryLanguageCode + primaryLanguage)
            productUpdated = true
        }
        
        if let expirationDate = validProduct.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            if let validString = formatter.string(from: expirationDate as Date).addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.ExpirationDate + validString )
            }
            productUpdated = true
        }
        
        switch validProduct.purchasePlacesOriginal {
        case .available(let location):
            let string = location.compactMap{
                $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
                }.joined(separator: ",")
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.PurchasePlaces + string )
            productUpdated = true
        // maybe the location is available as raw data
        default:
            break
        }
        
        switch validProduct.storesOriginal {
        case .available(let validShop):
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.Stores + validShop.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
            
        default:
            break
        }
        
        if validProduct.type != nil && validProduct.type != .beauty {
            for fact in validProduct.nutritionFactsDict {
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
        
        switch validProduct.brandsOriginal {
        case let .available(list):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Brands + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ","))
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Brands)
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.packagingOriginal {
        case .available:
            // take into account the language of the tags
            // if a tag has no prefix, a prefix must be added
            let list = validProduct.packagingOriginal.tags(withAdded: languageCodeForWrite, andRemoved: defaultLanguageCode)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging)
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.labelsOriginal {
        case .available:
            // take into account the language of the tags
            let list = validProduct.labelsOriginal.tags(withAdded: languageCodeForWrite, andRemoved: defaultLanguageCode)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels)
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.tracesOriginal {
        case .available:
            // take into account the language of the tags
            let list = validProduct.tracesOriginal.tags(withAdded: languageCodeForWrite, andRemoved: defaultLanguageCode)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces)
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.categoriesOriginal {
        case .available:
            // take into account the language of the tags
            let list = validProduct.categoriesOriginal.tags(withAdded: languageCodeForWrite, andRemoved: defaultLanguageCode)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories)
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.manufacturingPlacesOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Producer + places.compactMap{ $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.originsOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.IngredientsOrigin + places.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.embCodesOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ProducerCode + places.compactMap{ $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        switch validProduct.countriesOriginal {
        case .available:
            let list = validProduct.countriesOriginal.tags(withAdded: languageCodeForWrite, andRemoved: defaultLanguageCode)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Countries + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        if let validLinks = validProduct.links {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Links + validLinks.compactMap{ $0.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined(separator: ",") )
            productUpdated = true
        }
        
        if let validServingSize = validProduct.servingSize {
            if let encodedServingSize = validServingSize.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ServingSize + encodedServingSize)
                productUpdated = true
            }
        }
        
        if validProduct.type != nil && validProduct.type != .beauty {
            if let validHasNutritionFacts = validProduct.hasNutritionFacts {
                if !validHasNutritionFacts {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NoNutriments )
                } else {
                    urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Nutriments )
                }
                productUpdated = true
            }
        }
        
        if let validPeriodAfterOpeningString = validProduct.periodAfterOpeningString {
            if let encodedValidPeriodAfterOpeningString = validPeriodAfterOpeningString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.PeriodAfterOpening + encodedValidPeriodAfterOpeningString )
                productUpdated = true
            }
        }
        
        if let validID = UIDevice.current.identifierForVendor?.uuidString {
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.Comment)
            if let validAppName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String {
                urlString.append("-" + validAppName)
            }
            if let validVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                urlString.append("-" + validVersion)
            }

            if let validBuild = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String {
                urlString.append("-" + validBuild)
            }
            urlString.append("-" + validID)
        }

        if productUpdated {
            self.URLString = urlString
            super.main()
        }
        return
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
