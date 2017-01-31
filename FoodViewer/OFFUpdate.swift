//
//  OFFUpdate.swift
//  FoodViewer
//
//  This class updates a given product on th OFF-servers
//
//  Created by arnaud on 29/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class OFFUpdate {
    
    enum FetchJsonResult {
        case error(String)
        case success(Data)
    }
    //
    //  http://world.openfoodfacts.net/cgi/product_jqm2.pl?code=0048151623426&product_name=Maryland%20Choc%20Chip&quantity=230g&nutriment_energy=450&nutriment_energy_unit=kJ&nutrition_data_per=serving&ingredients_text=Fortified%20wheat%20flour%2C%20Chocolate%20chips%20%2825%25%29%2C%20Sugar%2C%20Palm%20oil%2C%20Golden%20syrup%2C%20Whey%20and%20whey%20derivatives%20%28Milk%29%2C%20Raising%20agents%2C%20Salt%2C%20Flavouring&traces=Milk%2C+Soya%2C+Nuts%2C+Wheat
    //  keywords needed
    //  user_id=usernameexample
    //  password=*****&
    //  code = (barcode product)
    //  expiration_date= (date in format dd/MM/YYYY)
    //  purchase_places=city (string)
    //  stores=carrefour (string)
    
    func confirmProduct(product: FoodProduct?, expiryDate: Date?, shop: String?, location:Address?) -> ProductUpdateStatus {
        
        // MARK: TBD use update()
        
        guard product != nil else { return .failure("OFFUpdate: No product defined") }
        
        //  TBD I should remove the contents of some fields first
        //  Shop should be added if required
        //  Expirydate should be replaces
        //  Location should be replaced
        
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        var urlString = OFFWriteAPI.SecureServer
            + OFFWriteAPI.PostPrefix
            + OFFWriteAPI.Barcode + product!.barcode.asString() + OFFWriteAPI.Delimiter
            + OFFWriteAPI.UserId + OFFAccount().userId + OFFWriteAPI.Delimiter
            + OFFWriteAPI.Password + OFFAccount().password
        

        if expiryDate != nil {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ExpirationDate + formatter.string(from: expiryDate! as Date))
        }
        
        if let validPurchasePlace = location?.asSingleString(withSeparator: OFFWriteAPI.CommaDelimiter) {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.PurchasePlaces + validPurchasePlace)
        }
        
        if let validShop = shop {
            let theShops = product?.add(shop:validShop)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Stores + theShops!.flatMap{$0}.joined(separator: ","))

        }
        
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: encodedString) {
                do {
                    
                    let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                    return unpackJSONObject(JSON(data: data))
                } catch let error as NSError {
                    print(error);
                    return ProductUpdateStatus.failure(error.description)
                }
            } else {
                return ProductUpdateStatus.failure(NSLocalizedString("Error: URL is wrong somehow", comment: "Probably a programming error."))
            }
        } else {
                return ProductUpdateStatus.failure(NSLocalizedString("Error: URL encoding failed", comment: "Probably a programming error."))
        }
    }
    
    func update(product: FoodProduct?) -> ProductUpdateStatus {
        // update the product on OFF
        
        // update only the fields that have something defined, i.e. are not nil
        var productUpdated: Bool = false
        
        let interfaceLanguage = Locale.preferredLanguages[0].characters.split{ $0 == "-" }.map(String.init)[0]

        guard product != nil else { return .failure("OFFUpdate: No product defined") }

        var urlString = OFFWriteAPI.SecureServer
            + OFFWriteAPI.PostPrefix
            + OFFWriteAPI.Barcode + product!.barcode.asString() + OFFWriteAPI.Delimiter
            + OFFWriteAPI.UserId + OFFAccount().userId + OFFWriteAPI.Delimiter
            + OFFWriteAPI.Password + OFFAccount().password

        if let name = product!.name {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Name + name)
            productUpdated = true
        }
        
        /* Not yet supported by OFF
        if product!.nameLanguage.count > 0 {
            for name in product!.nameLanguage {
                if let validName = name.value {
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
         */

        if let genericName = product!.genericName {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.GenericName + genericName)
            productUpdated = true
        }
        
        /* Not yet supported by OFF
        if product!.genericNameLanguage.count > 0 {
            for genericName in product!.genericNameLanguage {
                if let name = genericName.value {
                    urlString.append(OFFWriteAPI.Delimiter +
                        OFFWriteAPI.GenericName +
                        OFFWriteAPI.LanguageSpacer +
                        genericName.key +
                        name)
                    productUpdated = true
                }
            }
        }
         */
        
        if let quantity = product!.quantity {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Quantity + quantity)
            productUpdated = true
        }
        
        if let ingredients = product!.ingredients {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Ingredients + ingredients)
            productUpdated = true
        }

        if let primaryLanguage = product!.primaryLanguageCode {
            // TODO - this is also updated if no change has taken place
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.PrimaryLanguageCode + primaryLanguage)
            productUpdated = true
        }

        if let expirationDate = product!.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.ExpirationDate + formatter.string(from: expirationDate as Date) )
            productUpdated = true
        }
        
        if let validPurchasePlace = product!.purchaseLocation?.asSingleString(withSeparator: ",") {
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.PurchasePlaces + validPurchasePlace )
            productUpdated = true
            // maybe the location is available as raw data
        } else if let validPurchasePlace = product!.purchaseLocation?.rawArray {
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.PurchasePlaces + validPurchasePlace.flatMap{$0}.joined(separator: ",") )
            productUpdated = true
        }
        
        if let validShop = product!.stores {
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.Stores + validShop.flatMap{$0}.joined(separator: ",") )
            productUpdated = true
        }
        
        if let validNutritionFacts = product!.nutritionFacts {
            for fact in validNutritionFacts {
                if fact != nil {
                    if let validValue = fact?.standardValue,
                        let validKey = fact?.key {
                        urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: validKey) + OFFWriteAPI.Equal + validValue)
                        urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPer100g)
                    } else if let validValue = fact?.servingValue,
                        let validKey = fact?.key {
                        urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: validKey) + OFFWriteAPI.Equal + validValue)
                        urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPerServing)
                    }

                    if let validValueUnit = fact?.standardValueUnit?.short(),
                        let validKey = fact?.key {
                        urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: validKey))
                        urlString.append(OFFWriteAPI.NutrimentUnit + OFFWriteAPI.Equal + validValueUnit)
                    } else if let validValueUnit = fact?.servingValueUnit?.short(),
                        let validKey = fact?.key {
                        urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NutrimentPrefix + removeLanguage(from: validKey))
                        urlString.append(OFFWriteAPI.NutrimentUnit + OFFWriteAPI.Equal + validValueUnit)
                    }

                    productUpdated = true
                }
            }
        }
        
        switch product!.brands {
        case let .available(list):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Brands + list.flatMap{$0}.joined(separator: ","))
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Brands)
            productUpdated = true
        default:
            break
        }

        switch product!.packagingArray {
        case .available:
            // take into account the language of the tags
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging + product!.packagingArray.prefixedList(interfaceLanguage).joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging)
            productUpdated = true
        default:
            break
        }

        switch product!.labelArray {
        case .available:
            // take into account the language of the tags
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels + product!.labelArray.prefixedList(interfaceLanguage).joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels)
            productUpdated = true
        default:
            break
        }

        switch product!.traces {
        case .available:
            // take into account the language of the tags
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces + product!.traces.prefixedList(interfaceLanguage).joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces)
            productUpdated = true
        default:
            break
        }

        switch product!.categories {
        case .available:
            // take into account the language of the tags
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories + product!.categories.prefixedList(interfaceLanguage).joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories)
            productUpdated = true
        default:
            break
        }
        
        if let validManufacturingLocation = product?.producer?.rawArray {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Producer + validManufacturingLocation.joined( separator: ",") )
            productUpdated = true
        }

        if let validIngredientsOrigin = product?.ingredientsOrigin?.rawArray {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.IngredientsOrigin + validIngredientsOrigin.joined( separator: ",") )
            productUpdated = true
        }
        
        if let validProducerCodes = product?.producerCode {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ProducerCode + validProducerCodes.flatMap{ $0.raw }.joined( separator: ",") )
            productUpdated = true
        }

        if let validCountries = product!.countries {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Countries + validCountries.flatMap{ $0.country }.joined(separator: ",") )
            productUpdated = true
        }

        if let validLinks = product!.links {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Links + validLinks.flatMap{ $0.absoluteString }.joined(separator: ",") )
            productUpdated = true
        }

        if let validServingSize = product!.servingSize {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ServingSize + validServingSize )
            productUpdated = true
        }
        
        if let validHasNutritionFacts = product!.hasNutritionFacts {
            if !validHasNutritionFacts {
                urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.NoNutriments )
                productUpdated = true
            }
        }

        if productUpdated {
            if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: encodedString) {
                    do {
                        let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                        return unpackJSONObject( JSON(data: data) )
                    } catch let error as NSError {
                        print(error);
                        return .failure(error.description)
                    }
                } else {
                    return .failure("OFFUpdate Error: URL is wrong somehow")
                }
            } else {
                return .failure("OFFUpdate Error: URL encoding failed")
            }
        }
        return .failure("OFFUpdate Error: No product changes detected")
    }

    
    fileprivate struct OFFJson {
        static let StatusKey = "status"
        static let StatusVerboseKey = "status_verbose"
    }
    
    private func unpackJSONObject(_ jsonObject: JSON) -> ProductUpdateStatus {
        
        // a json file is returned upon posting
        // {"status_verbose":"fields saved","status":1}

        
        if let resultStatus = jsonObject[OFFJson.StatusKey].int {
            if resultStatus == 0 {
                // posting product updates did not work
                if let statusVerbose = jsonObject[OFFJson.StatusVerboseKey].string {
                    return ProductUpdateStatus.failure(statusVerbose)
                }
            } else if resultStatus == 1 {
                // posting did work out
                // upon a realize update
                // a json file is returned
                // {"status_verbose":"fields saved","status":1}

                if let statusVerbose = jsonObject[OFFJson.StatusVerboseKey].string {
                    return ProductUpdateStatus.success(statusVerbose)
                }
            }
        }
        return ProductUpdateStatus.failure(NSLocalizedString("Error: No verbose status", comment: "The JSON file is wrongly formatted."))
    }
    
    // remove the language identifier before the colon
    private func removeLanguage(from key: String) -> String {
        let elementsPair = key.characters.split{$0 == ":"}.map(String.init)
        if elementsPair.count == 1 {
            return elementsPair[0]
        } else {
            return elementsPair[1]

        }
    }

    
}

