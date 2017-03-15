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
    import UIKit
    import CoreGraphics

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
        
        let interfaceLanguageCode = Locale.preferredLanguages[0].characters.split{ $0 == "-" }.map(String.init)[0]

        guard product != nil else { return .failure("OFFUpdate: No product defined") }

        var urlString = OFFWriteAPI.SecureServer
            + OFFWriteAPI.PostPrefix
            + OFFWriteAPI.Barcode + product!.barcode.asString() + OFFWriteAPI.Delimiter
            + OFFWriteAPI.UserId + OFFAccount().userId + OFFWriteAPI.Delimiter
            + OFFWriteAPI.Password + OFFAccount().password
        /*

        if let name = product!.name {
            urlString.append(
                OFFWriteAPI.Delimiter +
                OFFWriteAPI.Name +
                OFFWriteAPI.Equal +
                name)
            productUpdated = true
        }
         */

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

        /*

        if let genericName = product!.genericName {
            urlString.append(
                OFFWriteAPI.Delimiter +
                OFFWriteAPI.GenericName +
                OFFWriteAPI.Equal +
                 genericName)
            productUpdated = true
        }
         */

        if product!.genericNameLanguage.count > 0 {
            for genericName in product!.genericNameLanguage {
                if let name = genericName.value {
                    urlString.append(OFFWriteAPI.Delimiter +
                        OFFWriteAPI.GenericName +
                        OFFWriteAPI.LanguageSpacer +
                        genericName.key +
                        OFFWriteAPI.Equal +
                        name)
                    productUpdated = true
                }
            }
        }
 
        if let quantity = product!.quantity {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Quantity + quantity)
            productUpdated = true
        }
        
        // Using this for writing in a specific language (ingredients_text_fr=) has no effect
        if product!.ingredientsLanguage.count > 0 {
            for name in product!.ingredientsLanguage {
                urlString.append(
                    OFFWriteAPI.Delimiter +
                    OFFWriteAPI.Ingredients +
                    OFFWriteAPI.LanguageSpacer +
                    name.key +
                    OFFWriteAPI.Equal +
                    name.value)
                productUpdated = true
            }
        }
        /*

        if let ingredients = product!.ingredients {
            urlString.append(
                OFFWriteAPI.Delimiter +
                OFFWriteAPI.Ingredients +
                OFFWriteAPI.Equal +
                ingredients)
            productUpdated = true
        }
         */


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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging + product!.packagingArray.prefixedList(interfaceLanguageCode).joined(separator: ",") )
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels + product!.labelArray.prefixedList(interfaceLanguageCode).joined(separator: ",") )
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces + product!.traces.prefixedList(interfaceLanguageCode).joined(separator: ",") )
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories + product!.categories.prefixedList(interfaceLanguageCode).joined(separator: ",") )
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
        
        let languageCodeToUse = product!.primaryLanguageCode != nil ? product!.primaryLanguageCode! : interfaceLanguageCode

        if let frontImages = product!.frontImages?.display {
            uploadImages(frontImages, barcode: product!.barcode.asString(), id:"front", primaryLanguageCode: languageCodeToUse)
        }

        if let ingredientsImages = product!.ingredientsImages?.display {
            uploadImages(ingredientsImages, barcode: product!.barcode.asString(), id:"ingredients", primaryLanguageCode: languageCodeToUse)
        }

        if let nutritionImages = product!.nutritionImages?.display {
            uploadImages(nutritionImages, barcode: product!.barcode.asString(), id:"nutrition", primaryLanguageCode: languageCodeToUse)
        }

        if productUpdated {
            if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                if let url = URL(string: encodedString) {
                    do {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
                        let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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

    private func uploadImages(_ images: [String:ProductImageData], barcode: String, id: String, primaryLanguageCode: String) {

        for image in images {
            guard image.value.image != nil else { return }

            // start by unselecting any existing image
            postDelete(parameters: [OFFHttpPost.UnselectParameter.CodeKey:barcode,
                                         OFFHttpPost.UnselectParameter.IdKey:OFFHttpPost.idValue(for:id, in:image.key)
                                // Adding credentials are not accepted
                                //, OFFHttpPost.UnselectParameter.UserId: OFFAccount().userId
                                //, OFFHttpPost.UnselectParameter.Password: OFFAccount().password
                                        ],
                            url: OFFHttpPost.URL.Unselect)
            post(image: image.value.image!,
                      parameters: [OFFHttpPost.AddParameter.BarcodeKey: barcode,
                                   OFFHttpPost.AddParameter.ImageField.Key:OFFHttpPost.idValue(for:id, in:image.key),
                                   OFFHttpPost.AddParameter.UserId: OFFAccount().userId,
                                   OFFHttpPost.AddParameter.Password: OFFAccount().password],
                      imageType: id, url: OFFHttpPost.URL.Add,
                      languageCode: image.key)
        
        }
    }
    
    private func post(image: UIImage, parameters : Dictionary<String, String>, imageType: String, url : String, languageCode: String) {
        let urlString = URL(string: url)
        guard urlString != nil else { return }
        
        /*
        if image.imageOrientation == UIImageOrientation.left {
            print("left")
        } else if image.imageOrientation == UIImageOrientation.right {
            print("right")
        } else if image.imageOrientation == UIImageOrientation.down {
            print("down")
        } else if image.imageOrientation == UIImageOrientation.up {
            print("up")
        }
        let ewImage = image.fixOrientation()
        
        if ewImage.imageOrientation == UIImageOrientation.left {
            print("left")
        } else if ewImage.imageOrientation == UIImageOrientation.right {
            print("right")
        } else if ewImage.imageOrientation == UIImageOrientation.down {
            print("down")
        } else if ewImage.imageOrientation == UIImageOrientation.up {
            print("up")
        }
         */

        let data: Data? = UIImagePNGRepresentation(image.setOrientationToLeftUpCorner())
        
        guard data != nil else { return }
        
        
        // let TWITTERFON_FORM_BOUNDARY:String = "FoodViewer"
        // let MPboundary:String = "--\(TWITTERFON_FORM_BOUNDARY)"
        // let endMPboundary:String = "\(MPboundary)--"
        
        let body:NSMutableString = NSMutableString();
        
        // parameters
        for (key, value) in parameters {
            body.appendFormat( Constants.TwoDash + HTTP.BoundaryValue + Constants.RN as NSString ) // "\(MPboundary)\r\n" as NSString)
            body.appendFormat( HTTP.ContentDisposition + HTTP.NameKey + Constants.EscapedQuote + key + Constants.EscapedQuote + Constants.RN + Constants.RN as NSString ) //"Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n" as NSString)
            body.appendFormat( value + Constants.RN  as NSString) // "\(value)\r\n" as NSString)
        }
        
        // image upload
        body.appendFormat( Constants.TwoDash + HTTP.BoundaryValue + Constants.RN as NSString ) //"%@\r\n",MPboundary)

        let string1 = HTTP.ContentDisposition
        let string2 = HTTP.NameKey + Constants.EscapedQuote + OFFHttpPost.imageName(for: imageType, in: languageCode) + Constants.EscapedQuote + Constants.SemiColonSpace
        let string3 = HTTP.FilenameKey + Constants.EscapedQuote + imageType + Constants.PNG + Constants.EscapedQuote + Constants.RN // "filename=\"\(imageType).png\"\r\n"
        // "Content-Disposition: form-data; name=\"imgupload_\(imageType)_\(languageCode)\"; filename=\"\(imageType).png\"\r\n"
        let string = string1 + string2 + string3 as NSString
        body.appendFormat(string)
        // print("string", string)
        
        body.appendFormat( HTTP.ContentTypeImage + Constants.RN + Constants.RN as NSString ) // "Content-Type: image/png\r\n\r\n")
        let end:String = Constants.RN + Constants.TwoDash + HTTP.BoundaryValue + Constants.TwoDash // "\r\n\(endMPboundary)"
        
        let myRequestData:NSMutableData = NSMutableData();
        myRequestData.append(body.data(using: String.Encoding.utf8.rawValue)!)
        myRequestData.append(data!)
        myRequestData.append(end.data(using: String.Encoding.utf8)!)
        
        let content:String = HTTP.FormData + HTTP.BoundaryKey + HTTP.BoundaryValue // "multipart/form-data; boundary=\(TWITTERFON_FORM_BOUNDARY)"
        let request = NSMutableURLRequest(url: urlString!) //, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = HTTP.Post
        request.setValue(content, forHTTPHeaderField: HTTP.ContentType)
        request.setValue("\(myRequestData.length)", forHTTPHeaderField: HTTP.ContentLength)
        request.httpBody = myRequestData as Data
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            if error != nil {
                print(error as Any)
                return
            }
            guard let data = data else { return }
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let result = self.unpackImageJSONObject( JSON(data: data) )
                switch result {
                case .success(let error):
                    let userInfo = [Notification.ImageUploadSuccessStatusKey:error as Any,
                                    Notification.ImageUploadSuccessBarcodeKey: parameters[OFFHttpPost.UnselectParameter.CodeKey] as Any,
                                    Notification.ImageUploadSuccessImagetypeKey: imageType]
                    NotificationCenter.default.post(name: .OFFUpdateImageUploadSuccess, object: nil, userInfo: userInfo)
                default:
                    break
                }
                return
            })

        })
        task.resume()
    }
    
    internal struct Notification {
        static let ImageUploadSuccessStatusKey = "OFFUpdate.Notification.ImageUploadSuccessStatus.Key"
        static let ImageUploadSuccessBarcodeKey = "OFFUpdate.Notification.ImageUploadSuccessBarcode.Key"
        static let ImageUploadSuccessImagetypeKey = "OFFUpdate.Notification.ImageUploadSuccessImageType.Key"
    }
    
     private struct Constants {
        static let TwoDash = "--"
        static let EscapedQuote = "\""
        static let RN = "\r\n"
        static let ColonSpace = ": "
        static let PNG = ".png"
        static let SemiColonSpace = "; "
     }
     
     private struct HTTP {
        static let BoundaryValue = "FoodViewer"
        static let ContentType = "Content-Type"
        static let ContentTypeImage = "Content-Type: image/png"
        static let ContentLength = "Content-Length"
        static let Post = "POST"
        static let FormData = "multipart/form-data; "
        static let ContentDisposition = "Content-Disposition: form-data; "
        static let PNG = "image/png"
        static let BoundaryKey = "boundary="
        static let FilenameKey = "filename="
        static let NameKey = "name="
     }
     
    
    private func postDelete(parameters : Dictionary<String, String>, url : String) {
        let urlString = URL(string: url)
        guard urlString != nil else { return }
          
        let body:NSMutableString = NSMutableString();
     
        // parameters
        for (key, value) in parameters {
            body.appendFormat(Constants.TwoDash + HTTP.BoundaryValue + Constants.RN as NSString)
            body.appendFormat(
                HTTP.ContentDisposition +
                    HTTP.NameKey + Constants.EscapedQuote + "\(key)" + Constants.EscapedQuote +
                    Constants.RN + Constants.RN as NSString
            )
            body.appendFormat("\(value)" + Constants.RN as NSString)
        }
     
        let end:String = Constants.RN + Constants.TwoDash + HTTP.BoundaryValue + Constants.TwoDash
     
        let myRequestData:NSMutableData = NSMutableData();
        myRequestData.append(body.data(using: String.Encoding.utf8.rawValue)!)
        myRequestData.append(end.data(using: String.Encoding.utf8)!)
        
        let content = HTTP.FormData + HTTP.BoundaryKey + HTTP.BoundaryValue
        let request = NSMutableURLRequest(url: urlString!) //, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.httpMethod = HTTP.Post
        request.setValue(content, forHTTPHeaderField: HTTP.ContentType)
        request.setValue("\(myRequestData.length)", forHTTPHeaderField: HTTP.ContentLength)
        request.httpBody = myRequestData as Data
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            if error != nil {
                print(error as Any)
                return
            }
            guard let data = data else { return }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            _ = self.unpackImageJSONObject( JSON(data: data) )
        })
        task.resume()
    }

    fileprivate struct OFFJson {
        static let StatusKey = "status"
        static let StatusCodeKey = "status_code"
        static let ImageFieldKey = "imagefield"
        static let StatusVerboseKey = "status_verbose"
        static let ImageIDKey = "imgid" // Int?
        static let ErrorKey = "error"
    }
    private func unpackImageJSONObject(_ jsonObject: JSON) -> ProductUpdateStatus {
        
        // a json file is returned upon posting
        
        if let status = jsonObject[OFFHttpPost.ResultJson.Key.Status].string {
            print("status", status)
            if status != OFFHttpPost.ResultJson.Value.StatusOK {
                // Post did NOT succeed
                if let statusCode = jsonObject[OFFHttpPost.ResultJson.Key.StatusCode].string {
                    print("statusCode not ok", statusCode)
                }

                if let imgid = jsonObject[OFFHttpPost.ResultJson.Key.ImageID].string {
                    print("imgid not ok", imgid)
                }
                if let error = jsonObject[OFFHttpPost.ResultJson.Key.Error].string {
                    print("error after not ok", error)
                    return ProductUpdateStatus.failure(error)
                }
            } else {
                // Post DID succeed
                if let statusCode = jsonObject[OFFHttpPost.ResultJson.Key.StatusCode].string {
                    print("statusCode ok", statusCode)
                }
                if let imageField = jsonObject[OFFHttpPost.ResultJson.Key.ImageField].string {
                    print("imageField ok", imageField)
                }

                if let imgid = jsonObject[OFFHttpPost.ResultJson.Key.ImageID].int {
                    print("imgid", imgid)
                }
                if let error = jsonObject[OFFHttpPost.ResultJson.Key.Error].string {
                    print("error", error)
                    return ProductUpdateStatus.failure(error)
                }
                return ProductUpdateStatus.success("Image upload succeeded")
            }
        }
        return ProductUpdateStatus.failure("Error: No verbose status")
    }

    
    private func unpackJSONObject(_ jsonObject: JSON) -> ProductUpdateStatus {
        
        // a json file is returned upon posting
        // {"status_verbose":"fields saved","status":1}

        
        if let resultStatus = jsonObject[OFFJson.StatusKey].int {
            if resultStatus == 0 {
                // posting product updates did not work
                if let statusVerbose = jsonObject[OFFJson.ErrorKey].string {
                    return ProductUpdateStatus.failure(statusVerbose)
                }
                if let error = jsonObject[OFFJson.StatusVerboseKey].string {
                    return ProductUpdateStatus.failure(error)
                }
            } else if resultStatus == 1 {
                // posting did work out
                // upon a realize update
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

// Definition:
extension Notification.Name {
    static let OFFUpdateImageUploadSuccess = Notification.Name("OFFUpdate.Notification.ImageUploadSuccess")
}

/*
//  The orientation of a UIIamge is determined by the orientation of the camera when the picture was taken.
//  This consists of two parts:
//  - the origin of the image wrt the device: origin is always top-left, 
//      when the device is in landscape with the button on the right.
//  - the imageOrientation (up/left/down/right)
//
//  External apps might not follow the imageOrientation, encoded in the EXIF.
//  So better to fix the origin to the top-left of the image
 */
extension UIImage {
    func setOrientationToLeftUpCorner() -> UIImage {
        
        // up images should not be fixed
        guard self.imageOrientation != UIImageOrientation.up else { return self }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        // Rotate image clockwise by 90 degree

        var transform = CGAffineTransform.identity
        if (self.imageOrientation == UIImageOrientation.down
            || self.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        }
        
        if (self.imageOrientation == UIImageOrientation.left
            || self.imageOrientation == UIImageOrientation.leftMirrored) {
            
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }
        
        if (self.imageOrientation == UIImageOrientation.right
            || self.imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
        }
        
        if (self.imageOrientation == UIImageOrientation.upMirrored
            || self.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (self.imageOrientation == UIImageOrientation.leftMirrored
            || self.imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext.init(data: nil,
                                            width: Int(self.size.width),
                                            height: Int(self.size.height),
                                            bitsPerComponent: self.cgImage!.bitsPerComponent,
                                            bytesPerRow: 0,
                                            space: self.cgImage!.colorSpace!,
                                            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (self.imageOrientation == UIImageOrientation.left
            || self.imageOrientation == UIImageOrientation.leftMirrored
            || self.imageOrientation == UIImageOrientation.right
            || self.imageOrientation == UIImageOrientation.rightMirrored
            || self.imageOrientation == UIImageOrientation.up
            ) {
            
             ctx.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.height, height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg: CGImage = ctx.makeImage()!
        let imgEnd: UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }
}

