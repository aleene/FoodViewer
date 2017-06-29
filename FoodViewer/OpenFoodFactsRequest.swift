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
        static let APIURLPrefixForFoodProduct = "http://world.openfoodfacts.org/api/v0/product/"
        static let APIURLPrefixForBeautyProduct = "http://world.openbeautyfacts.org/api/v0/product/"
        static let FoodSampleProductBarcode = "40111490"
        static let BeautySampleProductBarcode = "4005900122063"
        static let PetFoodSampleProductBarcode = "3166780740950"
    }
    
    enum FetchJsonResult {
        case error(String)
        case success(Data)
    }

    var fetched: ProductFetchStatus = .initialized
    
    var currentBarcode: BarcodeType? = nil
    
    func fetchStoredProduct(_ data: Data) -> ProductFetchStatus {
        return unpackJSONObject(JSON(data: data))
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    func fetchProductForBarcode(_ barcode: BarcodeType) -> ProductFetchStatus {
        self.currentBarcode = barcode
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var fetchUrlString = OFF.URL.Prefix
        // add the right server
        fetchUrlString += barcode.productType() != nil ? barcode.productType()!.rawValue : currentProductType.rawValue
        fetchUrlString += OFF.URL.Postfix
        fetchUrlString += barcode.asString() + OFF.URL.JSONExtension
        let fetchUrl = URL(string: fetchUrlString)
        if debug { print("OpenFoodFactsRequest:fetchProductForBarcode(_:_) - \(String(describing: fetchUrl))") }

        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        if let url = fetchUrl {
            do {
                let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                return unpackJSONObject(JSON(data: data))
            } catch let error as NSError {
                if debug { print("OpenFoodFactsRequest:fetchJsonForBarcode(_:_) - \(error.description)") }
                return ProductFetchStatus.loadingFailed(error.description)
            }
        } else {
            return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: URL not matched", comment: "Retrieved a json file that is no longer relevant for the app."))
        }
    }

    func fetchJsonForBarcode(_ barcode: BarcodeType) -> FetchJsonResult {
        self.currentBarcode = barcode
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //var fetchUrlString = OFF.URL.Prefix
        // add the right server
        //fetchUrlString += Preferences.manager.useOpenFactsServer.rawValue
        //fetchUrlString += OFF.URL.Postfix
        //fetchUrlString += barcode.asString() + OFF.URL.JSONExtension
        let fetchUrl = URL(string: OFF.fetchString(for: barcode, with: currentProductType)) // URL(string: fetchUrlString)
        // let fetchUrl = URL(string: "\(OpenFoodFacts.APIURLPrefixForFoodProduct + barcode.asString() + OFF.URL.JSONExtension)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
            return FetchJsonResult.error(NSLocalizedString("Error: URL not matched", comment: "Retrieved a json file that is no longer relevant for the app."))
        }
    }
    
    func fetchProducts(for component: OFF.SearchComponent, with value:String) -> ProductFetchStatus {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // encode the url-string
        let search = OFF.searchString(for: component, with: value)
        let fetchUrl = URL(string:search)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if let url = fetchUrl {
            do {
                let data = try Data(contentsOf: url, options: NSData.ReadingOptions.mappedIfSafe)
                return unpackJSONObject(JSON(data: data))
            } catch let error as NSError {
                print(error);
                return ProductFetchStatus.loadingFailed(error.description)
            }
        } else {
            return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: URL not matched", comment: "Retrieved a json file that is no longer relevant for the app."))
        }
    }
    
    func fetchSampleProduct() -> ProductFetchStatus {
        var resource: String = ""
        switch currentProductType {
        case .food:
            resource = OpenFoodFacts.FoodSampleProductBarcode
        case .petFood:
            resource = OpenFoodFacts.PetFoodSampleProductBarcode
        case .beauty:
            resource = OpenFoodFacts.BeautySampleProductBarcode
        }
        let filePath  = Bundle.main.path(forResource: resource, ofType:OFF.URL.JSONExtension)
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        if let validData = data {
            return unpackJSONObject(JSON(data: validData))
        } else {
            return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: No valid data", comment: "No valid data has been received"))
        }
    }
    
    // MARK: - The keys for decoding the json-files
    
    typealias jsonKeys = OFFReadAPIkeysJSON
    
    typealias nutrimentKeys = NutrimentsFactKeys
    
    // MARK: - unpack JSON
    
    func unpackJSONObject(_ jsonObject: JSON) -> ProductFetchStatus {
        
        func addPrefix(keys:[String]?, languageCode: String) -> [String]?  {
            if keys != nil {
                var newKeys: [String] = []
                for key in keys! {
                    if !key.contains(":") {
                        newKeys.append(languageCode + key)
                    } else {
                        newKeys.append(key)
                    }
                }
                return newKeys
            }
            return nil
        }
        // All the fields available in the barcode.json are listed below
        // Those that are not used at the moment are edited out
        
        // is this a single product page
        if let resultStatus = jsonObject[jsonKeys.StatusKey].int {
            if resultStatus == 0 {
                // barcode NOT found in database
                // There is nothing more to decode
                if let statusVerbose = jsonObject[jsonKeys.StatusVerboseKey].string {
                    return ProductFetchStatus.productNotAvailable(statusVerbose)
                } else {
                    return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: No verbose status", comment: "The JSON file is wrongly formatted."))
                }
                
            } else if resultStatus == 1 {
                // barcode exists in OFF database
                // print(product.name, product.nutritionFacts)
                return ProductFetchStatus.success(decode(JSON.init(jsonObject[jsonKeys.ProductKey].dictionaryValue) ))
            } else {
                return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: Other (>1) result status", comment: "A JSON status which is not supported."))
            }
        // is this a multi product page?
        } else if let jsonProducts = jsonObject[jsonKeys.ProductsKey].array {
            var products: [FoodProduct] = []
            for jsonProduct in jsonProducts {
                let product = decode(jsonProduct)
                products.append(product)
            }
            return ProductFetchStatus.list(products)
        } else {
            return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: Not a valid OFF JSON", comment: "Error message when the json input file does not contain any information") )
        }

    }
    
    private func decode(_ jsonObject: JSON) -> FoodProduct {
        
        struct ingredientsElement {
            var text: String? = nil
            var id: String? = nil
            var rank: Int? = nil
        }

        let product = FoodProduct()
        
        // print(jsonObject[jsonKeys.LangKey].string)
        product.primaryLanguageCode = jsonObject[jsonKeys.LangKey].string
        
        if let validCurrentBarcode = currentBarcode,
            let validJsonBarcodeString = jsonObject[jsonKeys.CodeKey].string{
            if  validJsonBarcodeString == validCurrentBarcode.asString() {
                product.barcode = validCurrentBarcode
            } else {
                product.barcode.string(jsonObject[jsonKeys.CodeKey].string)
            }
        } else {
            let test = jsonObject[jsonKeys.CodeKey].string
            product.barcode.string(test)
        }
        
        
        // product.mainUrlThumb = jsonObject[jsonKeys.ImageFrontSmallUrlKey].url
        
        decodeCompletionStates(jsonObject[jsonKeys.StatesTagsKey].stringArray, product:product)
        decodeLastEditDates(jsonObject[jsonKeys.LastEditDatesTagsKey].stringArray, forProduct:product)
        
        // the labels as interpreted by OFF (a list of strings)
        product.labelArray = Tags(decodeGlobalLabels(jsonObject[jsonKeys.LabelsTagsKey].stringArray))
        // the labels as the user has entered them (a comma delimited string)
        let tags = Tags(jsonObject[jsonKeys.LabelsKey].string)
        product.originalLabels = tags
        
        product.traceKeys = jsonObject[jsonKeys.TracesTagsKey].stringArray
        
        
        if let languages = jsonObject[jsonKeys.LanguagesHierarchy].stringArray {
            // product.languageCodes = []
            for language in languages {
                let isoCode = OFFplists.manager.translateLanguage(language, language: "iso")
                // it can already be set by the primary language
                if !product.contains(languageCode: isoCode) {
                    product.languageCodes.append(isoCode)
                }
                var key = jsonKeys.IngredientsTextKey + "_" + isoCode
                product.ingredientsLanguage[isoCode] = jsonObject[key].string
                key = jsonKeys.ProductNameKey + "_" + isoCode
                product.nameLanguage[isoCode] = jsonObject[key].string
                key = jsonKeys.GenericNameKey + "_" + isoCode
                product.genericNameLanguage[isoCode] = jsonObject[key].string
            }
        }
        // print(product.name)
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.FrontImageKey][jsonKeys.DisplayKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.frontImages == nil { product.frontImages = ProductImageSize() }
            product.frontImages?.display = images
        }
        
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.FrontImageKey][jsonKeys.ThumbKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.frontImages == nil { product.frontImages = ProductImageSize() }
            product.frontImages?.thumb = images
        }
        
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.FrontImageKey][jsonKeys.SmallKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.frontImages == nil { product.frontImages = ProductImageSize() }
            product.frontImages?.small = images
        }
        
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.NutritionImageKey][jsonKeys.DisplayKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.nutritionImages == nil { product.nutritionImages = ProductImageSize() }
            product.nutritionImages?.display = images
        }
        
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.NutritionImageKey][jsonKeys.ThumbKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.nutritionImages == nil { product.nutritionImages = ProductImageSize() }
            product.nutritionImages?.thumb = images
        }
        
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.NutritionImageKey][jsonKeys.SmallKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.nutritionImages == nil { product.nutritionImages = ProductImageSize() }
            product.nutritionImages?.small = images
        }
        
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.IngredientsImageKey][jsonKeys.DisplayKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.ingredientsImages == nil { product.ingredientsImages = ProductImageSize() }
            product.ingredientsImages?.display = images
        }
        
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.IngredientsImageKey][jsonKeys.ThumbKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.ingredientsImages == nil { product.ingredientsImages = ProductImageSize() }
            product.ingredientsImages?.thumb = images
        }
        if let valid = jsonObject[jsonKeys.SelectedImagesKey][jsonKeys.IngredientsImageKey][jsonKeys.SmallKey].dictionaryObject {
            var images: [String:ProductImageData] = [:]
            for element in valid {
                if let validString = element.value as? String {
                    if let url = URL.init(string: validString) {
                        images[element.key] = ProductImageData.init(url: url)
                    }
                }
            }
            if product.ingredientsImages == nil { product.ingredientsImages = ProductImageSize() }
            product.ingredientsImages?.small = images
        }
        
        // print(product.name, product.languageCodes, product.nameLanguage)
        // Is no longer needed, is part of the language array
        // product.genericName = jsonObject[jsonKeys.GenericNameKey].string
        product.additives = Tags(decodeAdditives(jsonObject[jsonKeys.AdditivesTagsKey].stringArray))
        
        product.informers = jsonObject[jsonKeys.InformersTagsKey].stringArray
        product.photographers = jsonObject[jsonKeys.PhotographersTagsKey].stringArray
        // it happens that the primary language code is not defined
        product.packagingArray = Tags.init(jsonObject[jsonKeys.PackagingTagsKey].stringArray)
        product.originalPackagingTags = Tags.init(jsonObject[jsonKeys.PackagingKey].string)
        
        product.numberOfIngredients = jsonObject[jsonKeys.IngredientsNKey].string
        
        product.set(countries:decodeCountries(jsonObject[jsonKeys.CountriesTagsKey].stringArray))
        product.producerCode = decodeProducerCodeArray(jsonObject[jsonKeys.EmbCodesKey].string)
        
        product.brands = Tags.init(jsonObject[jsonKeys.BrandsKey].string)
        product.brandsTags = Tags.init(jsonObject[jsonKeys.BrandsTagsKey].stringArray)
        
        // The links for the producer are stored as a string. This string might contain multiple links.
        let linksString = jsonObject[jsonKeys.LinkKey].string
        if let validLinksString = linksString {
            // assume that the links are separated by a comma ","
            let validLinksComponents = validLinksString.characters.split{$0 == ","}.map(String.init)
            product.links = []
            for component in validLinksComponents {
                if let validFirstURL = URL.init(string: component) {
                    product.links!.append(validFirstURL)
                }
            }
        }
        product.server = jsonObject[jsonKeys.NewServerKey].string
        
        product.purchaseLocationString(jsonObject[jsonKeys.PurchasePlacesKey].string)
        //product.nutritionFactsImageUrl = jsonObject[jsonKeys.ImageNutritionUrlKey].url
        // product.ingredients = jsonObject[jsonKeys.IngredientsTextKey].string
        
        product.editors = jsonObject[jsonKeys.EditorsTagsKey].stringArray
        product.additionDate = jsonObject[jsonKeys.CreatedTKey].time
        // product.name = jsonObject[jsonKeys.ProductNameKey].string
        product.creator = jsonObject[jsonKeys.CreatorKey].string
        //product.mainImageUrl = jsonObject[jsonKeys.ImageFrontUrlKey].url
        product.hasNutritionFacts = decodeNutritionDataAvalailable(jsonObject[jsonKeys.NoNutritionDataKey].string)
        product.servingSize = jsonObject[jsonKeys.ServingSizeKey].string
        var grade: NutritionalScoreLevel = .undefined
        grade.string(jsonObject[jsonKeys.NutritionGradeFrKey].string)
        product.nutritionGrade = grade
        
        
        let nutrientLevelsSalt = jsonObject[jsonKeys.NutrientLevelsKey][jsonKeys.NutrientLevelsSaltKey].string
        let nutrientLevelsFat = jsonObject[jsonKeys.NutrientLevelsKey][jsonKeys.NutrientLevelsFatKey].string
        let nutrientLevelsSaturatedFat = jsonObject[jsonKeys.NutrientLevelsKey][jsonKeys.NutrientLevelsSaturatedFatKey].string
        let nutrientLevelsSugars = jsonObject[jsonKeys.NutrientLevelsKey][jsonKeys.NutrientLevelsSugarsKey].string
        product.stores = jsonObject[jsonKeys.StoresKey].string?.components(separatedBy: ",")
        //product.imageIngredientsUrl = jsonObject[jsonKeys.ImageIngredientsUrlKey].url
        (product.nutritionalScoreUK, product.nutritionalScoreFR) = decodeNutritionalScore(jsonObject[jsonKeys.NutritionScoreDebugKey].string)
        //product.imageNutritionSmallUrl = jsonObject[jsonKeys.ImageNutritionSmallUrlKey].url
        product.correctors = jsonObject[jsonKeys.CorrectorsTagsKey].stringArray
        
        //product.imageIngredientsSmallUrl = jsonObject[jsonKeys.ImageIngredientsSmallUrlKey].url
        product.ingredientsOriginElements(jsonObject[jsonKeys.OriginsTagsKey].stringArray)
        product.producerElements(jsonObject[jsonKeys.ManufacturingPlacesKey].string)
        product.categories = Tags(decodeCategories(jsonObject[jsonKeys.CategoriesTagsKey].stringArray))
        product.quantity = jsonObject[jsonKeys.QuantityKey].string
        product.nutritionFactsIndicationUnit = decodeNutritionFactIndicationUnit(jsonObject[jsonKeys.NutritionDataPerKey].string)
        product.periodAfterOpeningString  = jsonObject[jsonKeys.PeriodsAfterOpeningKey].string
        product.expirationDateString = jsonObject[jsonKeys.ExpirationDateKey].string
        product.allergenKeys = jsonObject[jsonKeys.AllergensTagsKey].stringArray
        if let ingredientsJSON = jsonObject[jsonKeys.IngredientsKey].array {
            var ingredients: [ingredientsElement] = []
            for ingredientsJSONElement in ingredientsJSON {
                var element = ingredientsElement()
                element.text = ingredientsJSONElement[jsonKeys.IngredientsElementTextKey].string
                element.id = ingredientsJSONElement[jsonKeys.IngredientsElementIdKey].string
                element.rank = ingredientsJSONElement[jsonKeys.IngredientsElementRankKey].int
                ingredients.append(element)
            }
        }
        
        var nutritionLevelQuantity = NutritionLevelQuantity.undefined
        nutritionLevelQuantity.string(nutrientLevelsFat)
        let fatNutritionScore = (NutritionItem.fat, nutritionLevelQuantity)
        nutritionLevelQuantity.string(nutrientLevelsSaturatedFat)
        let saturatedFatNutritionScore = (NutritionItem.saturatedFat, nutritionLevelQuantity)
        nutritionLevelQuantity.string(nutrientLevelsSugars)
        let sugarNutritionScore = (NutritionItem.sugar, nutritionLevelQuantity)
        nutritionLevelQuantity.string(nutrientLevelsSalt)
        let saltNutritionScore = (NutritionItem.salt, nutritionLevelQuantity)
        product.nutritionScore = [fatNutritionScore, saturatedFatNutritionScore, sugarNutritionScore, saltNutritionScore]
        
        // Warning: the order of these nutrients is important. It will be displayed as such.
        
        nutritionDecode(nutrimentKeys.EnergyKey, key: jsonKeys.EnergyKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.FatKey, key: jsonKeys.FatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MonounsaturatedFatKey, key: jsonKeys.MonounsaturatedFatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.PolyunsaturatedFatKey, key: jsonKeys.PolyunsaturatedFatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SaturatedFatKey, key: jsonKeys.SaturatedFatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.Omega3FatKey, key: jsonKeys.Omega3FatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.Omega6FatKey, key: jsonKeys.Omega6FatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.Omega9FatKey, key: jsonKeys.Omega9FatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.TransFatKey, key: jsonKeys.TransFatKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CholesterolKey, key: jsonKeys.CholesterolKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CarbohydratesKey, key: jsonKeys.CarbohydratesKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SugarsKey, key: jsonKeys.SugarsKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SucroseKey, key: jsonKeys.SucroseKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.GlucoseKey, key: jsonKeys.GlucoseKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.FructoseKey , key: jsonKeys.FructoseKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.LactoseKey, key: jsonKeys.LactoseKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MaltoseKey, key: jsonKeys.MaltoseKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.PolyolsKey, key: jsonKeys.PolyolsKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MaltodextrinsKey, key: jsonKeys.MaltodextrinsKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.FiberKey, key: jsonKeys.FiberKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ProteinsKey, key: jsonKeys.ProteinsKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SodiumKey, key: jsonKeys.SodiumKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SaltKey, key: jsonKeys.SaltKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.AlcoholKey, key: jsonKeys.AlcoholKey, jsonObject: jsonObject, product: product)
        
        nutritionDecode(nutrimentKeys.BiotinKey, key: jsonKeys.BiotinKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CaseinKey, key: jsonKeys.CaseinKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SerumProteinsKey, key: jsonKeys.SerumProteinsKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.NucleotidesKey , key: jsonKeys.NucleotidesKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.StarchKey, key: jsonKeys.StarchKey, jsonObject: jsonObject, product: product)
        
        nutritionDecode(nutrimentKeys.VitaminAKey, key: jsonKeys.VitaminAKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminB1Key, key: jsonKeys.VitaminB1Key, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminB2Key, key: jsonKeys.VitaminB2Key, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminPPKey, key: jsonKeys.VitaminPPKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminB6Key, key: jsonKeys.VitaminB6Key, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminB9Key, key: jsonKeys.VitaminB9Key, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminB12Key, key: jsonKeys.VitaminB12Key, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminCKey, key: jsonKeys.VitaminCKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminDKey, key: jsonKeys.VitaminDKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminEKey, key: jsonKeys.VitaminEKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VitaminKKey, key: jsonKeys.VitaminKKey, jsonObject: jsonObject, product: product)
        
        nutritionDecode(nutrimentKeys.CalciumKey, key: jsonKeys.CalciumKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ChlorideKey, key: jsonKeys.ChlorideKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ChromiumKey, key: jsonKeys.ChromiumKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CopperKey, key: jsonKeys.CopperKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.BicarbonateKey, key: jsonKeys.BicarbonateKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.FluorideKey, key: jsonKeys.FluorideKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.IodineKey, key: jsonKeys.IodineKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.IronKey, key: jsonKeys.IronKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MagnesiumKey, key: jsonKeys.MagnesiumKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ManganeseKey, key: jsonKeys.ManganeseKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MolybdenumKey, key: jsonKeys.MolybdenumKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.PhosphorusKey, key: jsonKeys.PhosphorusKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.PotassiumKey, key: jsonKeys.PotassiumKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SeleniumKey, key: jsonKeys.SeleniumKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.SilicaKey, key: jsonKeys.SilicaKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ZincKey, key: jsonKeys.ZincKey, jsonObject: jsonObject, product: product)
        
        nutritionDecode(nutrimentKeys.AlphaLinolenicAcidKey, key: jsonKeys.AlphaLinolenicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ArachidicAcidKey, key: jsonKeys.ArachidicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ArachidonicAcidKey, key: jsonKeys.ArachidonicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.BehenicAcidKey, key: jsonKeys.BehenicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ButyricAcidKey, key: jsonKeys.ButyricAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CapricAcidKey, key: jsonKeys.CapricAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CaproicAcidKey, key: jsonKeys.CaproicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CaprylicAcidKey, key: jsonKeys.CaprylicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.CeroticAcidKey, key: jsonKeys.CeroticAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.DihomoGammaLinolenicAcidKey, key: jsonKeys.DihomoGammaLinolenicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.DocosahexaenoicAcidKey, key: jsonKeys.EicosapentaenoicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.EicosapentaenoicAcidKey, key: jsonKeys.EicosapentaenoicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ElaidicAcidKey, key: jsonKeys.ElaidicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.ErucicAcidKey, key: jsonKeys.ErucicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.GammaLinolenicAcidKey, key: jsonKeys.GammaLinolenicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.GondoicAcidKey, key: jsonKeys.GondoicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.LauricAcidKey, key: jsonKeys.LauricAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.LignocericAcidKey, key: jsonKeys.LignocericAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.LinoleicAcidKey, key: jsonKeys.LinoleicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MeadAcidKey, key: jsonKeys.MeadAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MelissicAcidKey, key: jsonKeys.MelissicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MontanicAcidKey, key: jsonKeys.MontanicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.MyristicAcidKey, key: jsonKeys.MyristicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.NervonicAcidKey, key: jsonKeys.NervonicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.PalmiticAcidKey, key: jsonKeys.PalmiticAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.PantothenicAcidKey, key: jsonKeys.PantothenicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.StearicAcidKey, key: jsonKeys.StearicAcidKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.VoleicAcidKey, key: jsonKeys.VoleicAcidKey, jsonObject: jsonObject, product: product)
        
        nutritionDecode(nutrimentKeys.CaffeineKey, key: jsonKeys.CaffeineKey, jsonObject: jsonObject, product: product)
        nutritionDecode(nutrimentKeys.TaurineKey, key: jsonKeys.TaurineKey, jsonObject: jsonObject, product: product)
        
        nutritionDecode(nutrimentKeys.PhKey, key: jsonKeys.PhKey, jsonObject: jsonObject, product:product)
        nutritionDecode(nutrimentKeys.CacaoKey, key: jsonKeys.CacaoKey, jsonObject: jsonObject, product:product)
        
        return product
    }
    
    // MARK: - Decoding Functions

    private func nutritionDecode(_ fact: String, key: String, jsonObject: JSON, product: FoodProduct) {
        
        var nutritionItem = NutritionFactItem()

        struct Appendix {
            static let HunderdKey = "_100g"
            static let ServingKey = "_serving"
            static let UnitKey = "_unit"
            static let ValueKey = "_value"
        }
        
        nutritionItem.key = key
        nutritionItem.itemName = OFFplists.manager.translateNutrients(key, language:Locale.preferredLanguages[0])
        switch OFFplists.manager.nutrientUnit(for: key) {
        case .Milligram, .Microgram:
            nutritionItem.standardValueUnit = .Gram
        default:
            nutritionItem.standardValueUnit = OFFplists.manager.nutrientUnit(for: key)

        }
        nutritionItem.servingValueUnit = nutritionItem.standardValueUnit
        
        // value of a _100g field is either a number or a string
        if let doubleValue = jsonObject[jsonKeys.NutrimentsKey][key+Appendix.HunderdKey].double {
            nutritionItem.standardValue = "\(doubleValue)"
        } else if let value = jsonObject[jsonKeys.NutrimentsKey][key+Appendix.HunderdKey].string {
            nutritionItem.standardValue = value
        } else {
            nutritionItem.standardValue = nil
        }
        
        if let doubleValue = jsonObject[jsonKeys.NutrimentsKey][key+Appendix.ServingKey].double {
            nutritionItem.servingValue = "\(doubleValue)"
        } else if let value = jsonObject[jsonKeys.NutrimentsKey][key+Appendix.ServingKey].string {
            nutritionItem.servingValue = value
        } else {
            nutritionItem.servingValue = nil
        }
        
        if nutritionItem.standardValueUnit == .Gram {
            var value: String? = nil
            var unit: NutritionFactUnit = .Gram
            
            (value, unit) = normalize(nutritionItem.standardValue)
            nutritionItem.standardValue = value
            nutritionItem.standardValueUnit = unit
            
            (value, unit) = normalize(nutritionItem.servingValue)
            nutritionItem.servingValue = value
            nutritionItem.servingValueUnit = unit
        }

        // only add a fact if it has valid values
        if nutritionItem.standardValue != nil || nutritionItem.servingValue != nil {
            product.add(fact: nutritionItem)
        }
    }
    
    fileprivate struct StateCompleteKey {
        static let nutrimentKeys = "en:nutrition-facts-completed"
        static let nutrimentKeysTBD = "en:nutrition-facts-to-be-completed"
        static let Ingredients = "en:ingredients-completed"
        static let IngredientsTBD = "en:ingredients-to-be-completed"
        static let ExpirationDate = "en:expiration-date-completed"
        static let ExpirationDateTBD = "en:expiration-date-to-be-completed"
        static let PhotosValidated = "en:photos-validated"
        static let PhotosValidatedTBD = "en:photos-to-be-validated"
        static let Categories = "en:categories-completed"
        static let CategoriesTBD = "en:categories-to-be-completed"
        static let Brands = "en:brands-completed"
        static let BrandsTBD = "en:brands-to-be-completed"
        static let Packaging = "en:packaging-completed"
        static let PackagingTBD = "en:packaging-to-be-completed"
        static let Quantity = "en:quantity-completed"
        static let QuantityTBD = "en:quantity-to-be-completed"
        static let ProductName = "en:product-name-completed"
        static let ProductNameTBD = "en:product-name-to-be-completed"
        static let PhotosUploaded = "en:photos-uploaded"
        static let PhotosUploadedTBD = "en:photos-to-be-uploaded"
    }
    
    fileprivate func decodeAdditives(_ additives: [String]?) -> [String]? {
        if let adds = additives {
            var translatedAdds:[String]? = []
            let preferredLanguage = Locale.preferredLanguages[0]
            for add in adds {
                translatedAdds!.append(OFFplists.manager.translateAdditives(add, language:preferredLanguage))
            }
            return translatedAdds
        }
        return nil
    }
    
    // checks whether a valid value is in the json-data
    fileprivate func decodeNutritionDataAvalailable(_ code: String?) -> Bool? {
        if let validCode = code {
            // "no_nutrition_data":"on" indicates that there are NO nutriments on the package
            return validCode.hasPrefix("on") ? false : true
        }
        // not a valid json-code, so return do not know
        return nil
    }
    
    fileprivate func decodeCountries(_ countries: [String]?) -> [String]? {
        if let countriesArray = countries {
            var translatedCountries:[String]? = []
            let preferredLanguage = Locale.preferredLanguages[0]
            for country in countriesArray {
                translatedCountries!.append(OFFplists.manager.translateCountries(country, language:preferredLanguage))
            }
            return translatedCountries
        }
        return nil
    }

    fileprivate func decodeGlobalLabels(_ labels: [String]?) -> [String]? {
        if let labelsArray = labels {
            var translatedLabels:[String]? = []
            let preferredLanguage = Locale.preferredLanguages[0]
            for label in labelsArray {
                translatedLabels!.append(OFFplists.manager.translateGlobalLabels(label, language:preferredLanguage))
            }
            return translatedLabels
        }
        return nil
    }
    
    fileprivate func decodeCategories(_ labels: [String]?) -> [String]? {
        if let labelsArray = labels {
            var translatedTags:[String]? = []
            let preferredLanguage = Locale.preferredLanguages[0]
            for label in labelsArray {
                translatedTags!.append(OFFplists.manager.translateCategories(label, language:preferredLanguage))
            }
            return translatedTags
        }
        return nil
    }


    fileprivate func decodeCompletionStates(_ states: [String]?, product:FoodProduct) {
        if let statesArray = states {
            for currentState in statesArray {
                let preferredLanguage = Locale.preferredLanguages[0]
                if currentState.contains(StateCompleteKey.PhotosUploaded) {
                    product.state.photosUploadedComplete.value = true
                    product.state.photosUploadedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosUploaded, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.PhotosUploadedTBD) {
                    product.state.photosUploadedComplete.value =  false
                    product.state.photosUploadedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosUploadedTBD, language:preferredLanguage)
                    

                } else if currentState.contains(StateCompleteKey.ProductName) {
                    product.state.productNameComplete.value =  true
                    product.state.productNameComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ProductName, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.ProductNameTBD) {
                    product.state.productNameComplete.value =  false
                    product.state.productNameComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ProductNameTBD, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.Brands) {
                    product.state.brandsComplete.value =  true
                    product.state.brandsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Brands, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.BrandsTBD) {
                    product.state.brandsComplete.value =  false
                    product.state.brandsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.BrandsTBD, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.Quantity) {
                    product.state.quantityComplete.value =  true
                    product.state.quantityComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Quantity, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.QuantityTBD) {
                    product.state.quantityComplete.value =  false
                    product.state.quantityComplete.text = OFFplists.manager.translateStates(StateCompleteKey.QuantityTBD, language:preferredLanguage)

                } else if currentState.contains(StateCompleteKey.Packaging) {
                    product.state.packagingComplete.value = true
                    product.state.packagingComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Packaging, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.PackagingTBD) {
                    product.state.packagingComplete.value = false
                    product.state.packagingComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PackagingTBD, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.Categories) {
                    product.state.categoriesComplete.value = true
                    product.state.categoriesComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Categories, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.CategoriesTBD) {
                    product.state.categoriesComplete.value = false
                    product.state.categoriesComplete.text = OFFplists.manager.translateStates(StateCompleteKey.CategoriesTBD, language:preferredLanguage)

                } else if currentState.contains(StateCompleteKey.nutrimentKeys) {
                    product.state.nutritionFactsComplete.value = true
                    product.state.nutritionFactsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.nutrimentKeys, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.nutrimentKeysTBD) {
                    product.state.nutritionFactsComplete.value = false
                    product.state.nutritionFactsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.nutrimentKeysTBD, language:preferredLanguage)

                } else if currentState.contains(StateCompleteKey.PhotosValidated) {
                    product.state.photosValidatedComplete.value = true
                    product.state.photosValidatedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosValidated, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.PhotosValidatedTBD) {
                    product.state.photosValidatedComplete.value = false
                    product.state.photosValidatedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosValidatedTBD, language:preferredLanguage)

                } else if currentState.contains(StateCompleteKey.Ingredients) {
                    product.state.ingredientsComplete.value = true
                    product.state.ingredientsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Ingredients, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.IngredientsTBD) {
                    product.state.ingredientsComplete.value = false
                    product.state.ingredientsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.IngredientsTBD, language:preferredLanguage)

                } else if currentState.contains(StateCompleteKey.ExpirationDate) {
                    product.state.expirationDateComplete.value = true
                    product.state.expirationDateComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ExpirationDate, language:preferredLanguage)
                } else if currentState.contains(StateCompleteKey.ExpirationDateTBD) {
                    product.state.expirationDateComplete.value = false
                    product.state.expirationDateComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ExpirationDateTBD, language:preferredLanguage)
                }
            }
        }
    }
    
    fileprivate func decodeLastEditDates(_ editDates: [String]?, forProduct:FoodProduct) {
        if let dates = editDates {
            var uniqueDates = Set<Date>()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "EN_en")
            // use only valid dates
            for date in dates {
                // a valid date format is 2014-07-20
                // I do no want the shortened dates in the array
                if date.range( of: "...-..-..", options: .regularExpression) != nil {
                    if let newDate = dateFormatter.date(from: date) {
                        uniqueDates.insert(newDate)
                    }
                }
            }
            
            forProduct.lastEditDates = uniqueDates.sorted { $0.compare($1) == .orderedAscending }
        }
    }
    
    // This function decodes a string with comma separated producer codes into an array of valid addresses
    fileprivate func decodeProducerCodeArray(_ codes: String?) -> [Address]? {
        if let validCodes = codes {
            if !validCodes.isEmpty {
            let elements = validCodes.characters.split{$0 == ","}.map(String.init)
                var addressArray: [Address] = []
                for code in elements {
                    if let newAddress = decodeProducerCode(code) {
                        addressArray.append(newAddress)
                    }
                }
                return addressArray
            }
        }
        return nil
    }
    
    fileprivate func decodeNutritionFactIndicationUnit(_ value: String?) -> NutritionEntryUnit? {
        if let validValue = value {
            if validValue.contains(NutritionEntryUnit.perStandardUnit.key()) {
                return .perStandardUnit
            } else if validValue.contains(NutritionEntryUnit.perServing.key()) {
                return .perServing
            }
        }
        return nil
    }

    // This function extracts the postalcode out of the producer code and created an Address instance
    fileprivate func decodeProducerCode(_ code: String?) -> Address? {
        let newAddress = Address()
        if let validCode = code {
            newAddress.raw = validCode
            if validCode.hasPrefix("FR ") {
                newAddress.country = "France"
                // FR\s..\....\.... is the original regex string
                if validCode.range(of: "FR\\s..\\....\\....", options: .regularExpression) != nil {
                    let elementsSeparatedBySpace = validCode.characters.split{$0 == " "}.map(String.init)
                    let elementsSeparatedByDot = elementsSeparatedBySpace[1].characters.split{$0 == "."}.map(String.init)
                    // combine into a valid french postal code
                    newAddress.postalcode = elementsSeparatedByDot[0] + elementsSeparatedByDot[1]
                }
                return newAddress
            } else if validCode.hasPrefix("ES ") {
                newAddress.country = "Spain"
                if validCode.range(of: "ES\\s..\\....\\....", options: .regularExpression) != nil {
                    let elementsSeparatedBySpace = validCode.characters.split{$0 == " "}.map(String.init)
                    let elementsSeparatedByDot = elementsSeparatedBySpace[1].characters.split{$0 == "."}.map(String.init)
                    // combine into a valid french postal code
                    newAddress.postalcode = elementsSeparatedByDot[0] + elementsSeparatedByDot[1]
                }
                return newAddress
            } else if validCode.hasPrefix("IT ") {
                newAddress.country = "Italy"
                if validCode.range(of: "IT\\s..\\....\\....", options: .regularExpression) != nil {
                    let elementsSeparatedBySpace = validCode.characters.split{$0 == " "}.map(String.init)
                    let elementsSeparatedByDot = elementsSeparatedBySpace[1].characters.split{$0 == "."}.map(String.init)
                    // combine into a valid french postal code
                    newAddress.postalcode = elementsSeparatedByDot[0] + elementsSeparatedByDot[1]
                }
                return newAddress
            } else if validCode.range(of: "EMB\\s\\d{5}", options: .regularExpression) != nil {
                newAddress.country = "France"
                
                // start after the first four characters
                if validCode.length() >= 9 {
                    newAddress.postalcode = validCode.substring(4, length: 5)
                }
                return newAddress
                // Is this an EMB-code for Belgium?
            } else if validCode.hasPrefix("EMB B-") {
                newAddress.country = "Belgium"
                // a valid code has 11 characters
                // the last 4 characters contain the postal code
                // there might be leading 0, which has no meaning in Belgium
                if validCode.length() >= 10 {
                    newAddress.postalcode = validCode.substring(validCode.length() - 4, length: 4)
                }
                return newAddress
            } else if validCode.hasPrefix("BE ") {
                newAddress.country = "Belgium"
                return newAddress
            } else if validCode.hasPrefix("DE ") {
                newAddress.country = "Germany"
                return newAddress
            } else if validCode.hasPrefix("NL ") {
                newAddress.country = "Netherlands"
                return newAddress
            }

            print("Producer code '\(validCode)' could not be recognized")
        }
        return nil
    }
    
    func decodeNutritionalScore(_ jsonString: String?) -> (LocalizedNutritionalScoreUK?, LocalizedNutritionalScoreFR?) {
    
        var nutrionalScoreUK: LocalizedNutritionalScoreUK? = nil
        var nutrionalScoreFrance: LocalizedNutritionalScoreFR? = nil
        
        if let validJsonString = jsonString {

            /* now parse the jsonString to create the right values
             sample string:
             0 --
             1 --
             0
             0
             energy 5
             1   +
             sat-fat 10
             2   +
             fr-sat-fat-for-fats 2
             3   +
             sugars 6
             4   +
             sodium 0
             1   -
             0
             fruits
             1
             0%
             2
             0
             2   -
             0
             fiber
             1
             4
             3   -
             proteins 4
             2  --
             0
             fsa
             1
             17
             3  --
             fr 17"
             */
            // print("\(validJsonString)")
            // is there useful info in the string?
            if (validJsonString.contains("-- energy ")) {
                nutrionalScoreUK = LocalizedNutritionalScoreUK()
                nutrionalScoreFrance = LocalizedNutritionalScoreFR()
                // split on --, should give 4 parts: empty, nutriments, fsa, fr
                let dashParts = validJsonString.components(separatedBy: "-- ")
                var offset = 0
                if dashParts.count == 5 {
                    offset = 1
                    if dashParts[1].contains("beverages") {
                        nutrionalScoreFrance?.beverage = true
                    } else if dashParts[1].contains("cheeses") {
                        nutrionalScoreFrance?.cheese = true
                    }
                }
                // find the total fsa score
                var spaceParts2 = dashParts[2+offset].components(separatedBy: " ")
                if let validScore = Int.init(spaceParts2[1]) {
                    nutrionalScoreUK?.score = validScore
                } else {
                    nutrionalScoreUK?.score = 0
                }
                
                spaceParts2 = dashParts[3+offset].components(separatedBy: " ")
                if let validScore = Int.init(spaceParts2[1]) {
                    nutrionalScoreFrance?.score = validScore
                } else {
                    nutrionalScoreFrance?.score = 0
                }

                
                if nutrionalScoreFrance != nil && nutrionalScoreFrance!.beverage {
                    // the french calculation for beverages uses a different table and evaluation
                    // use after the :
                    let colonParts = dashParts[1].components(separatedBy: ": ")
                    // split on +
                    let plusParts = colonParts[1].components(separatedBy: " + ")
                    // split on space to find the numbers
                    // energy
                    var spacePart = plusParts[0].components(separatedBy: " ")
                    if nutrionalScoreFrance != nil {

                        if let validValue = Int.init(spacePart[1]) {
                            var newValue = nutrionalScoreFrance!.pointsA[0]
                            newValue.points = validValue
                            nutrionalScoreFrance!.pointsA[0] = newValue
                        }
                        // sat_fat
                        spacePart = plusParts[1].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValue = nutrionalScoreFrance!.pointsA[1]
                            newValue.points = validValue
                            nutrionalScoreFrance!.pointsA[1] = newValue
                        }
                        // sugars
                        spacePart = plusParts[2].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValue = nutrionalScoreFrance!.pointsA[2]
                            newValue.points = validValue
                            nutrionalScoreFrance!.pointsA[2] = newValue
                        }
                        // sodium
                        spacePart = plusParts[3].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValue = nutrionalScoreFrance!.pointsA[3]
                            newValue.points = validValue
                            nutrionalScoreFrance!.pointsA[3] = newValue
                        }
                    }
                    
                } else {
                    if nutrionalScoreUK != nil && nutrionalScoreFrance != nil {
                        // split on -,
                        let minusparts = dashParts[1+offset].components(separatedBy: " - ")
                        
                        var spacePart = minusparts[1].components(separatedBy: " ")
                        // fruits 0%
                        if let validValue = Int.init(spacePart[2]) {
                            var newValueFrance = nutrionalScoreFrance!.pointsC[0]
                            var newValueUK = nutrionalScoreUK!.pointsC[0]
                            newValueFrance.points = validValue
                            newValueUK.points = validValue
                            nutrionalScoreFrance!.pointsC[0] = newValueFrance
                            nutrionalScoreUK!.pointsC[0] = newValueUK
                        }
                        // fiber
                        spacePart = minusparts[2].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValueFrance = nutrionalScoreFrance!.pointsC[1]
                            var newValueUK = nutrionalScoreUK!.pointsC[1]
                            newValueFrance.points = validValue
                            newValueUK.points = validValue
                            nutrionalScoreFrance!.pointsC[1] = newValueFrance
                            nutrionalScoreUK!.pointsC[1] = newValueUK
                        }
                        // proteins
                        spacePart = minusparts[3].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValueFrance = nutrionalScoreFrance!.pointsC[2]
                            var newValueUK = nutrionalScoreUK!.pointsC[2]
                            newValueFrance.points = validValue
                            newValueUK.points = validValue
                            nutrionalScoreFrance!.pointsC[2] = newValueFrance
                            nutrionalScoreUK!.pointsC[2] = newValueUK
                        }
                        
                        let plusParts = minusparts[0].components(separatedBy: " + ")
                        // energy
                        spacePart = plusParts[0].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValueFrance = nutrionalScoreFrance!.pointsA[0]
                            var newValueUK = nutrionalScoreUK!.pointsA[0]
                            newValueFrance.points = validValue
                            newValueUK.points = validValue
                            nutrionalScoreFrance!.pointsA[0] = newValueFrance
                            nutrionalScoreUK!.pointsA[0] = newValueUK
                        }
                        // saturated fats
                        spacePart = plusParts[1].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValueUK = nutrionalScoreUK!.pointsA[1]
                            newValueUK.points = validValue
                            nutrionalScoreUK!.pointsA[1] = newValueUK
                        }
                        // saturated fat ratio
                        spacePart = plusParts[2].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValueFrance = nutrionalScoreFrance!.pointsA[1]
                            newValueFrance.points = validValue
                            nutrionalScoreFrance!.pointsA[1] = newValueFrance
                        }
                    
                        // sugars
                        spacePart = plusParts[3].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValueFrance = nutrionalScoreFrance!.pointsA[2]
                            var newValueUK = nutrionalScoreUK!.pointsA[2]
                            newValueFrance.points = validValue
                            newValueUK.points = validValue
                            nutrionalScoreFrance!.pointsA[2] = newValueFrance
                            nutrionalScoreUK!.pointsA[2] = newValueUK
                        }
                        // sodium
                        spacePart = plusParts[4].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            var newValueFrance = nutrionalScoreFrance!.pointsA[3]
                            var newValueUK = nutrionalScoreUK!.pointsA[3]
                            newValueFrance.points = validValue
                            newValueUK.points = validValue
                            nutrionalScoreFrance!.pointsA[3] = newValueFrance
                            nutrionalScoreUK!.pointsA[3] = newValueUK
                        }
                    }
                }
            }
        }
        return (nutrionalScoreUK, nutrionalScoreFrance)
    }

    
    // MARK: - Extensions


    // This function splits an element in an array in a language and value part
    func splitLanguageElements(_ inputArray: [String]?) -> [[String: String]]? {
        if let elementsArray = inputArray {
            if !elementsArray.isEmpty {
                var outputArray: [[String:String]] = []
                for element in elementsArray {
                    let elementsPair = element.characters.split{$0 == ":"}.map(String.init)
                    let dict = Dictionary(dictionaryLiteral: (elementsPair[0], elementsPair[1]))
                    outputArray.insert(dict, at: 0)
                }
                return outputArray
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // assume we start with grams
    func normalize(_ value: String?) -> (String?, NutritionFactUnit) {
        var newValue: String? = nil
        var newUnit: NutritionFactUnit = .None
        
        guard value != nil else { return (nil, NutritionFactUnit.Gram) }
        
         if var doubleValue = Double(value!) {
            // the value can be converted to a number
            if doubleValue < 0.99 {
            //change to the milli version
            doubleValue = doubleValue * 1000.0
                if doubleValue < 0.99 {
                    // change to the microversion
                    doubleValue = doubleValue * 1000.0
                    // we use only the values standerdized on g
                    if doubleValue < 0.99 {
                        // this is nanogram, probably the value is just 0
                        newUnit = NutritionFactUnit.Gram
                    } else {
                        newUnit = NutritionFactUnit.Microgram
                    }
                } else {
                    // more than 1 milligram, use milligram
                    newUnit = NutritionFactUnit.Milligram
                }
            } else {
                // larger than 1, use gram
                newUnit = NutritionFactUnit.Gram
            }
            // print("standard: \(key) \(doubleValue) " + nutritionItem.standardValueUnit! )
            newValue = "\(doubleValue)"
        } else {
            // not a number, maybe some text
            newValue = value
        }
        
        return (newValue, newUnit)
    }

}





