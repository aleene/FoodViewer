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
    
    
    //enum FetchJsonResult {
    //    case error(String)
    //    case success(Data)
    //}
    //
    //  http://world.openfoodfacts.net/cgi/product_jqm2.pl?code=0048151623426&product_name=Maryland%20Choc%20Chip&quantity=230g&nutriment_energy=450&nutriment_energy_unit=kJ&nutrition_data_per=serving&ingredients_text=Fortified%20wheat%20flour%2C%20Chocolate%20chips%20%2825%25%29%2C%20Sugar%2C%20Palm%20oil%2C%20Golden%20syrup%2C%20Whey%20and%20whey%20derivatives%20%28Milk%29%2C%20Raising%20agents%2C%20Salt%2C%20Flavouring&traces=Milk%2C+Soya%2C+Nuts%2C+Wheat
    //  keywords needed
    //  user_id=usernameexample
    //  password=*****&
    //  code = (barcode product)
    //  expiration_date= (date in format dd/MM/YYYY)
    //  purchase_places=city (string)
    //  stores=carrefour (string)
    
    /*
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
            + OFFWriteAPI.Barcode + product!.barcode.asString + OFFWriteAPI.Delimiter
            + OFFWriteAPI.UserId + OFFAccount().userId + OFFWriteAPI.Delimiter
            + OFFWriteAPI.Password + OFFAccount().password
        

        if expiryDate != nil {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ExpirationDate + formatter.string(from: expiryDate! as Date))
        }
        
        if let validPurchasePlace = location?.asSingleString(withSeparator: OFFWriteAPI.CommaDelimiter) {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.PurchasePlaces + validPurchasePlace.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        
        if let validShop = shop {
            let theShops = product?.add(shop:validShop.addingPercentEncoding(withAllowedCharacters: .alphanumerics))
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Stores + theShops!.flatMap{$0}.joined(separator: ","))

        }
        
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: encodedString) {
                do {
                    
                    let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                    // return unpackJSONObject(JSON(data: data))
                    return unpackProductUploadResultJson(data)
                } catch let error as NSError {
                    print(error);
                    return ProductUpdateStatus.failure(error.description)
                }
            } else {
                return ProductUpdateStatus.failure("OFFUpdate: URL is wrong somehow")
            }
        } else {
                return ProductUpdateStatus.failure("OFFUpdate: URL encoding failed")
        }
    }
    */
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    func update(productPair: ProductPair) -> ProductUpdateStatus {
        // update the product on OFF
        
        // update only the fields that have something defined, i.e. are not nil
        var productUpdated: Bool = false
        
        let interfaceLanguageCode = Locale.preferredLanguages[0].split(separator:"-").map(String.init)[0]

        // The OFF interface assumes that values are in english
        let languageCodeToUse = "en"

        guard let product = productPair.localProduct else { return .failure("No product", "OFFUpdate: No product defined") }

        var urlString = OFFWriteAPI.SecurePrefix
            + currentProductType.rawValue
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
            let string = location.compactMap{
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
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.Stores + validShop.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Brands + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ","))
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Packaging + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Labels + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Traces + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
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
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        case .empty:
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Categories)
            productUpdated = true
        default:
            break
        }
        
        switch product.manufacturingPlacesOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Producer + places.compactMap{ $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }

        switch product.originsOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.IngredientsOrigin + places.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }
        
        switch product.embCodesOriginal {
        case .available(let places):
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.ProducerCode + places.compactMap{ $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined( separator: ",") )
            productUpdated = true
        default:
            break
        }

        switch product.countriesOriginal {
        case .available:
            let list = product.countriesOriginal.tags(withAdded: interfaceLanguageCode, andRemoved: languageCodeToUse)
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Countries + list.compactMap{$0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)}.joined(separator: ",") )
            productUpdated = true
        default:
            break
        }

        if let validLinks = product.links {
            urlString.append(OFFWriteAPI.Delimiter + OFFWriteAPI.Links + validLinks.compactMap{ $0.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) }.joined(separator: ",") )
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
            urlString.append( OFFWriteAPI.Delimiter + OFFWriteAPI.Comment)
            if let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String {
                urlString.append("-" + appName)
            }
            if let version = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String {
                urlString.append("-" + version)
            }
            if let build = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                urlString.append("-" + build)
            }
            urlString.append("-" + validID)
        }
        

        var imagesUpdated = false
        if product.frontImages.count > 0 {
            uploadImages(product.frontImages, barcode: product.barcode.asString, id:"front", productPair: productPair)
            imagesUpdated = true
        }
        
        if product.ingredientsImages.count > 0 {
            uploadImages(product.ingredientsImages, barcode: product.barcode.asString, id:"ingredients", productPair: productPair)
            imagesUpdated = true
        }

        if product.nutritionImages.count > 0 {
            uploadImages(product.nutritionImages, barcode: product.barcode.asString, id:"nutrition", productPair: productPair)
            imagesUpdated = true
        }
        if product.images.count > 0 {
            uploadImages(product.images, barcode: product.barcode.asString, id:"general", productPair: productPair)
            imagesUpdated = true
        }
//  This class seems to be no longer in use
        if productUpdated {
            if let url = URL(string: urlString) {
                
                do {
                    let data = try Data( contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe )
                    return data.resultForProductUpload(barcode:product.barcode.asString)
                } catch let error as NSError {
                    print(error);
                    return .failure(urlString, error.description)
                }
            } else {
                return .failure(urlString, "OFFUpdate Error: URL is wrong somehow")
            }
        } else if imagesUpdated {
            return .images(product.barcode.asString)
        } else {
            return .failure(urlString, "OFFUpdate Error: No product changes detected")
        }
    }

    private func uploadImages(_ dict: [String:ProductImageSize], barcode: String, id: String, productPair: ProductPair) {
        // any image to upload?
        guard dict.count > 0 else { return }
        
        for element in dict {
            
            // Is there a valid original image?
            if let imageData = element.value.largest {
                if let image = imageData.image {
                    guard image != UIImage() else { return }
                    // Is this a selected image?
                    if id != "general" {
                        // start by unselecting any existing image
                        postDelete(parameters: [OFFHttpPost.UnselectParameter.CodeKey:barcode,
                                                OFFHttpPost.UnselectParameter.IdKey:OFFHttpPost.idValue(for:id, in:element.key)
                            // Adding credentials is not accepted by OFF
                            //, OFFHttpPost.UnselectParameter.UserId: OFFAccount().userId
                            //, OFFHttpPost.UnselectParameter.Password: OFFAccount().password
                            ],
                                    url: OFFHttpPost.URL.SecurePrefix +
                                    currentProductType.rawValue +
                                    OFFHttpPost.URL.Domain +
                                    OFFHttpPost.URL.UnselectPostFix
                        )
                    }
                        
                    post(image: image,
                            parameters: [OFFHttpPost.AddParameter.BarcodeKey: barcode,
                                          OFFHttpPost.AddParameter.ImageField.Key:OFFHttpPost.idValue(for:id, in:element.key),
                                        OFFHttpPost.AddParameter.UserId: OFFAccount().userId,
                                        OFFHttpPost.AddParameter.Password: OFFAccount().password],
                            imageType: id,
                            url: OFFHttpPost.URL.SecurePrefix +
                            currentProductType.rawValue +
                            OFFHttpPost.URL.Domain +
                            OFFHttpPost.URL.AddPostFix,
                            languageCode: element.key, productPair: productPair)
                }
            }
        }
    }
    
    private func post(image: UIImage, parameters: Dictionary<String, String>, imageType: String, url: String, languageCode: String, productPair: ProductPair) {
        let urlString = URL(string: url)
        guard urlString != nil else { return }
        
        
        //if image.imageOrientation == UIImageOrientation.left {
        //    print("left")
        //} else if image.imageOrientation == UIImageOrientation.right {
        //    print("right")
        //} else if image.imageOrientation == UIImageOrientation.down {
        //    print("down")
        //} else if image.imageOrientation == UIImageOrientation.up {
        //    print("up")
        //}
        let ewImage = image.setOrientationToLeftUpCorner()
        
        //if ewImage.imageOrientation == UIImageOrientation.left {
        //    print("left")
        //} else if ewImage.imageOrientation == UIImageOrientation.right {
        //    print("right")
        //} else if ewImage.imageOrientation == UIImageOrientation.down {
        //    print("down")
        //} else if ewImage.imageOrientation == UIImageOrientation.up {
        //    print("up")
        //}
        //print(image.description)
        let data = UIImagePNGRepresentation(ewImage)
        //print(ewImage.description)

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
        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
        var result:ProductUpdateStatus? = nil
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
            if error != nil {
                print(error as Any)
                return
            }
            guard let data = data else { return }
            //result = self.unpackImageJSONObject( JSON(data: data) )
            result = data.resultForImageUpload(productPair: productPair)
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if result != nil {
                    switch result! {
                    case .success(_, let error):
                        print("OFFUpdate:post", error)
                        let userInfo = [Notification.ImageUploadSuccessStatusKey:error as String,
                                        Notification.ImageUploadSuccessBarcodeKey: parameters[OFFHttpPost.AddParameter.BarcodeKey]! as String,
                                        Notification.ImageUploadSuccessImagetypeKey: parameters[OFFHttpPost.AddParameter.ImageField.Key]! as String]
                        NotificationCenter.default.post(name: .OFFUpdateImageUploadSuccess, object: nil, userInfo: userInfo)
                    default:
                        break
                    }
                }
            })
        })
        task.resume()
    }
    
    internal struct Notification {
        static let ImageUploadSuccessStatusKey = "OFFUpdate.Notification.ImageUploadSuccessStatus.Key"
        static let ImageUploadSuccessBarcodeKey = "OFFUpdate.Notification.ImageUploadSuccessBarcode.Key"
        static let ImageUploadSuccessImagetypeKey = "OFFUpdate.Notification.ImageUploadSuccessImageType.Key"
        static let ImageDeleteSuccessStatusKey = "OFFUpdate.Notification.ImageDeleteSuccessStatus.Key"
        static let ImageDeleteSuccessBarcodeKey = "OFFUpdate.Notification.ImageDeleteSuccessBarcode.Key"
        static let ImageDeleteSuccessImagetypeKey = "OFFUpdate.Notification.ImageDeleteSuccessImageType.Key"
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
    
    // The dict specifies which language must be deselected
    // the image category is .identification, .nutrition or .ingredients
    // And naturally the product
    func deselect(_ languageCodes: [String], of imageCategory: ImageTypeCategory, for productPair: ProductPair) {
        for element in languageCodes {
            switch imageCategory {
            case .front, .ingredients, .nutrition:
                postDelete(parameters: [OFFHttpPost.UnselectParameter.CodeKey:productPair.barcodeType.asString,
                                        OFFHttpPost.UnselectParameter.IdKey:OFFHttpPost.idValue(for:imageCategory.description, in:element)],
                           url: OFFHttpPost.URL.SecurePrefix +
                            currentProductType.rawValue +
                            OFFHttpPost.URL.Domain +
                            OFFHttpPost.URL.UnselectPostFix
                )
            default:
                break
            }
        }
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
        DispatchQueue.main.async(execute: { () -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
        var result: ProductUpdateStatus? = nil
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            data, response, error in
                if error != nil {
                    print(error as Any)
                    return
                }
                guard let data = data else { return }
            result = data.resultForImageDeselect(barcode: url)
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if result != nil {
                    switch result! {
                    case .success(_, let error):
                        print("OFFUpdate:postDelete", error)
                        let userInfo = [Notification.ImageDeleteSuccessStatusKey:error as Any,
                                        Notification.ImageDeleteSuccessBarcodeKey: parameters[OFFHttpPost.UnselectParameter.CodeKey]! as String,
                                        Notification.ImageDeleteSuccessImagetypeKey: parameters[OFFHttpPost.UnselectParameter.IdKey]! as String]
                        NotificationCenter.default.post(name: .OFFUpdateImageDeleteSuccess, object: nil, userInfo: userInfo)
                    default:
                        break
                    }
                }
            })
        })
        task.resume()
    }

    /*
    fileprivate struct OFFJson {
        static let StatusKey = "status"
        static let StatusCodeKey = "status_code"
        static let ImageFieldKey = "imagefield"
        static let StatusVerboseKey = "status_verbose"
        static let ImageIDKey = "imgid" // Int?
        static let ErrorKey = "error"
    }
  */
    /*
    private func unpackImageJSONObject(_ jsonObject: JSON) -> ProductUpdateStatus {
        
        // a json file is returned upon posting
        
        if let status = jsonObject[OFFHttpPost.ResultJson.Key.Status].string {
            print("unpackImageJSONObject: status", status)
            if status != OFFHttpPost.ResultJson.Value.StatusOK {
                // Post did NOT succeed
                if let statusCode = jsonObject[OFFHttpPost.ResultJson.Key.StatusCode].string {
                    print("unpackImageJSONObject: statusCode not ok", statusCode)
                }

                if let imgid = jsonObject[OFFHttpPost.ResultJson.Key.ImageID].string {
                    print("unpackImageJSONObject: imgid not ok", imgid)
                }
                if let error = jsonObject[OFFHttpPost.ResultJson.Key.Error].string {
                    print("unpackImageJSONObject: error after not ok", error)
                    return ProductUpdateStatus.failure(error)
                }
            } else {
                // Post DID succeed
                if let statusCode = jsonObject[OFFHttpPost.ResultJson.Key.StatusCode].string {
                    print("unpackImageJSONObject: statusCode ok", statusCode)
                }
                if let imageField = jsonObject[OFFHttpPost.ResultJson.Key.ImageField].string {
                    print("unpackImageJSONObject: imageField ok", imageField)
                }

                if let imgid = jsonObject[OFFHttpPost.ResultJson.Key.ImageID].int {
                    print("unpackImageJSONObject: imgid", imgid)
                }
                if let error = jsonObject[OFFHttpPost.ResultJson.Key.Error].string {
                    print("unpackImageJSONObject: error", error)
                    return ProductUpdateStatus.failure(error)
                }
                return ProductUpdateStatus.success("unpackImageJSONObject: Image upload succeeded")
            }
        }
        return ProductUpdateStatus.failure("Error: No verbose status")
    }
    */

    /*
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
        return ProductUpdateStatus.failure("OFFUpdate: No verbose status")
    }
     */

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

// Definition:
extension Notification.Name {
    static let OFFUpdateImageUploadSuccess = Notification.Name("OFFUpdate.Notification.ImageUploadSuccess")
    static let OFFUpdateImageDeleteSuccess = Notification.Name("OFFUpdate.Notification.ImageDeleteSuccess")
}
 
 extension Data {
    
    fileprivate func resultForImageUpload(productPair: ProductPair) -> ProductUpdateStatus {
        do {
            let result = try JSONDecoder().decode(OFFImageUploadResultJson.self, from:self)
            if let validStatus = result.status {
                if validStatus == "status ok" {
                    if let valid = result.imagefield {
                        var elements = valid.split(separator: "_").map(String.init)
                        switch elements[0] {
                        case "general":
                            productPair.localProduct?.images.removeValue(forKey: elements[1])
                        case "front":
                            productPair.localProduct?.frontImages.removeValue(forKey: elements[1])
                        case "ingredients":
                            productPair.localProduct?.ingredientsImages.removeValue(forKey: elements[1])
                        case "nutrition":
                            productPair.localProduct?.nutritionImages.removeValue(forKey: elements[1])
                        default:
                            break
                        }
                        productPair.removeLocalProduct()
                    }
                    return ProductUpdateStatus.success(productPair.barcodeType.asString, "\(validStatus)")
                } else {
                    return ProductUpdateStatus.failure(productPair.barcodeType.asString, "OFFImageUploadResultJson \(validStatus)")
                }
            }
        } catch(let error) {
            return ProductUpdateStatus.failure(productPair.barcodeType.asString, error.localizedDescription)
        }
        return ProductUpdateStatus.failure(productPair.barcodeType.asString, "OFFUpdate: no valid status")
    }

    fileprivate func resultForImageDeselect(barcode: String) -> ProductUpdateStatus {
        do {
            let result = try JSONDecoder().decode(OFFImageDeselectResultJson.self, from:self)
            if let validStatus = result.status {
                if let validStatus_code = result.status_code {
                    if validStatus_code == 0 {
                        return ProductUpdateStatus.success(barcode, validStatus)
                    } else if validStatus_code == 1 {
                        return ProductUpdateStatus.failure(barcode, validStatus)
                    } else {
                        return ProductUpdateStatus.failure(barcode, "OFFUpdate:unexpected status_code: \(validStatus_code)")
                    }
                } else {
                    return ProductUpdateStatus.failure(barcode, validStatus)
                }
            }
        } catch(let error) {
            return ProductUpdateStatus.failure(barcode, error.localizedDescription)
        }
        return ProductUpdateStatus.failure(barcode, "OFFUpdate: no valid status")
    }

    
    fileprivate func resultForProductUpload(barcode: String) -> ProductUpdateStatus {
        do {
            let result = try JSONDecoder().decode(OFFProductUploadResultJson.self, from:self)
            if let validStatus = result.status {
                if validStatus == 0 {
                    return ProductUpdateStatus.failure(barcode, "\(validStatus)")
                } else if result.status == 1 {
                    return ProductUpdateStatus.success(barcode, "\(validStatus)")
                } else {
                    return ProductUpdateStatus.failure(barcode, "OFFUpdate:unexpected status_code")
                }
            }
        } catch(let error) {
            return ProductUpdateStatus.failure(barcode,error.localizedDescription)
        }
        return ProductUpdateStatus.failure(barcode, "OFFUpdate: no valid status")

    }
    
 }
