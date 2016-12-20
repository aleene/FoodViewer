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
    
    fileprivate struct OpenFoodFacts {
        static let JSONExtension = ".json"
        static let APIURLPrefixForProduct = "http://world.openfoodfacts.org/api/v0/product/"
        static let sampleProductBarcode = "40111490"
    }
    
    enum FetchJsonResult {
        case error(String)
        case success(Data)
    }

    var fetched: ProductFetchStatus = .initialized
    
    func fetchStoredProduct(_ data: Data) -> ProductFetchStatus {
        return unpackJSONObject(JSON(data: data))
    }
    
    func fetchProductForBarcode(_ barcode: BarcodeType) -> ProductFetchStatus {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let fetchUrl = URL(string: "\(OpenFoodFacts.APIURLPrefixForProduct + barcode.asString() + OpenFoodFacts.JSONExtension)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        // print("\(fetchUrl)")
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

    func fetchJsonForBarcode(_ barcode: BarcodeType) -> FetchJsonResult {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let fetchUrl = URL(string: "\(OpenFoodFacts.APIURLPrefixForProduct + barcode.asString() + OpenFoodFacts.JSONExtension)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
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

    func fetchSampleProduct() -> ProductFetchStatus {
        let filePath  = Bundle.main.path(forResource: OpenFoodFacts.sampleProductBarcode, ofType:OpenFoodFacts.JSONExtension)
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        if let validData = data {
            return unpackJSONObject(JSON(data: validData))
        } else {
            return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: No valid data", comment: "No valid data has been received"))
        }
    }
    
    // JSON keys

    fileprivate struct OFFJson {
        static let StatusKey = "status"
        static let StatusVerboseKey = "status_verbose"
        static let ProductKey = "product"
        static let CodeKey = "code"
        static let LastEditDatesTagsKey = "last_edit_dates_tags"
        static let LabelsHierarchyKey = "labels_hierarchy"
        static let ImageFrontSmallUrlKey = "image_front_small_url"
        static let IIdKey = "_id"
        static let LabelsDebugTagsKey = "labels_debug_tags"
        static let CategoriesHierarchyKey = "categories_hierarchy"
        static let PnnsGroups1Key = "pnns_groups_1"
        static let StatesTagsKey = "states_tags"
        static let CheckersTagsKey = "checkers_tags"
        static let LabelsTagsKey = "labels_tags"
        static let ImageSmallUrlKey = "image_small_url"
        static let ProductCodeKey = "code"
        static let AdditivesTagsNKey = "additives_tags_n"
        static let TracesTagsKey = "traces_tags"
        static let LangKey = "lang"
        static let DebugParamSortedLangsKey = "debug_param_sorted_langs"
        static let LanguagesHierarchy = "languages_hierarchy"
        static let PhotographersKey = "photographers"
        static let GenericNameKey = "generic_name"
        static let IngredientsThatMayBeFromPalmOilTagsKey = "ingredients_that_may_be_from_palm_oil_tags"
        static let AdditivesPrevNKey = "additives_prev_n"
        static let KeywordsKey = "_keywords"
        static let RevKey = "rev"
        static let EditorsKey = "editors"
        static let InterfaceVersionCreatedKey = "interface_version_created"
        static let EmbCodesKey = "emb_codes"
        static let MaxImgidKey = "max_imgid"
        static let AdditivesTagsKey = "additives_tags"
        static let EmbCodesOrigKey = "emb_codes_orig"
        static let InformersTagsKey = "informers_tags"
        static let NutrientLevelsTagsKey = "nutrient_levels_tags"
        static let PhotographersTagsKey = "photographers_tags"
        static let AdditivesNKey = "additives_n"
        static let PnnsGroups2TagsKey = "pnns_groups_2_tags"
        static let UnknownNutrientsTagsKey = "unknown_nutrients_tags"
        static let CategoriesPrevTagsKey = "categories_prev_tags"
        static let PackagingTagsKey = "packaging_tags"
        static let ManufacturingPlacesKey = "manufacturing_places"
        static let LinkKey = "link"
        static let IngredientsNKey = "ingredients_n"
        static let NutrimentsKey = "nutriments"
        static let SodiumKey = "sodium"
        static let SaltKey = "salt"
        static let SugarsKey = "sugars"
        static let EnergyKey = "energy"
        static let ProteinsKey = "proteins"
        static let CaseinKey = "casein"
        static let SerumProteinsKey = "serum-proteins"
        static let NucleotidesKey = "nucleotides"
        static let CarbohydratesKey = "carbohydrates"
        static let SucroseKey = "sucrose"
        static let GlucoseKey = "glucose"
        static let FructoseKey = "fructose"
        static let LactoseKey = "lactose"
        static let MaltoseKey = "maltose"
        static let MaltodextrinsKey = "maltodextrins"
        static let StarchKey = "starch"
        static let PolyolsKey = "polyols"
        static let FatKey = "fat"
        static let SaturatedFatKey = "saturated-fat"
        static let ButyricAcidKey = "butyric-acid"
        static let CaproicAcidKey = "caproic-acid"
        static let CaprylicAcidKey = "caprylic-acid"
        static let CapricAcidKey = "capric-acid"
        static let LauricAcidKey = "lauric-acid"
        static let MyristicAcidKey = "myristic-acid"
        static let PalmiticAcidKey = "palmitic-acid"
        static let StearicAcidKey = "stearic-acid"
        static let ArachidicAcidKey = "arachidic-acid"
        static let BehenicAcidKey = "behenic-acid"
        static let LignocericAcidKey = "lignoceric-acid"
        static let CeroticAcidKey = "cerotic-acid"
        static let MontanicAcidKey = "montanic-acid"
        static let MelissicAcidKey = "melissic-acid"
        static let MonounsaturatedFatKey = "monounsaturated-fat"
        static let PolyunsaturatedFatKey = "polyunsaturated-fat"
        static let Omega3FatKey = "omega-3-fat"
        static let AlphaLinolenicAcidKey = "alpha-linolenic-acid"
        static let EicosapentaenoicAcidKey = "eicosapentaenoic-acid"
        static let DocosahexaenoicAcidKey = "docosahexaenoic-acid"
        static let Omega6FatKey = "omega-6-fat"
        static let LinoleicAcidKey = "linoleic-acid"
        static let ArachidonicAcidKey = "arachidonic-acid"
        static let GammaLinolenicAcidKey = "gamma-linolenic-acid"
        static let DihomoGammaLinolenicAcidKey = "dihomo-gamma-linolenic-acid"
        static let Omega9FatKey = "omega-9-fat"
        static let VoleicAcidKey = "voleic-acid"
        static let ElaidicAcidKey = "elaidic-acid"
        static let GondoicAcidKey = "gondoic-acid"
        static let MeadAcidKey = "mead-acid"
        static let ErucicAcidKey = "erucic-acid"
        static let NervonicAcidKey = "nervonic-acid"
        static let TransFatKey = "trans-fat"
        static let CholesterolKey = "cholesterol"
        static let FiberKey = "fiber"
        static let AlcoholKey = "alcohol"
        static let VitaminAKey = "vitamin-a"
        static let VitaminDKey = "vitamin-d"
        static let VitaminEKey = "vitamin-e"
        static let VitaminKKey = "vitamin-k"
        static let VitaminCKey = "vitamin-c"
        static let VitaminB1Key = "vitamin-b1"
        static let VitaminB2Key = "vitamin-b2"
        static let VitaminPPKey = "vitamin-pp"
        static let VitaminB6Key = "vitamin-b6"
        static let VitaminB9Key = "vitamin-b9"
        static let VitaminB12Key = "vitamin-b12"
        static let BiotinKey = "biotin"
        static let PantothenicAcidKey = "pantothenic-acid"
        static let SilicaKey = "silica"
        static let BicarbonateKey = "bicarbonate"
        static let PotassiumKey = "potassium"
        static let ChlorideKey = "chloride"
        static let CalciumKey = "calcium"
        static let PhosphorusKey = "phosphorus"
        static let IronKey = "iron"
        static let MagnesiumKey = "magnesium"
        static let ZincKey = "zinc"
        static let CopperKey = "copper"
        static let ManganeseKey = "manganese"
        static let FluorideKey = "fluoride"
        static let SeleniumKey = "selenium"
        static let ChromiumKey = "chromium"
        static let MolybdenumKey = "molybdenum"
        static let IodineKey = "iodine"
        static let CaffeineKey = "caffeine"
        static let TaurineKey = "taurine"
        static let PhKey = "ph"
        static let CacaoKey = "cocoa"
        
        //static let CarbohydratesUnitKey = "carbohydrates_unit"
        //static let FatUnitKey = "fat_unit"
        static let NutritionScoreFr100gKey = "nutrition-score-fr_100g"
        //static let FatKey = "fat"
        //static let SodiumServingKey = "sodium_serving"
        //static let ProteinsKey = "proteins"
        //static let ProteinsServingKey = "proteins_serving"
        //static let Proteins100gKey = "proteins_100g"
        //static let ProteinsUnitKey = "proteins_unit"
        static let NutritionScoreFrKey = "nutrition-score-fr"
        static let NutritionScoreUk100gKey = "nutrition-score-uk_100g"
        static let CountriesTagsKey = "countries_tags"
        static let IngredientsFromPalmOilTagsKey = "ingredients_from_palm_oil_tags"
        static let EmbCodesTagsKey = "emb_codes_tags"
        static let BrandsTagsKey = "brands_tags"
        static let PurchasePlacesKey = "purchase_places"
        static let PnnsGroups2Key = "pnns_groups_2"
        static let CountriesHierarchyKey = "countries_hierarchy"
        static let TracesKey = "traces"
        static let AdditivesOldTagsKey = "additives_old_tags"
        static let ImageNutritionUrlKey = "image_nutrition_url"
        static let CategoriesKey = "categories"
        static let IngredientsTextDebugKey = "ingredients_text_debug"
        static let IngredientsTextKey = "ingredients_text"
        static let EditorsTagsKey = "editors_tags"
        static let LabelsPrevTagsKey = "labels_prev_tags"
        static let AdditivesOldNKey = "additives_old_n"
        static let CategoriesPrevHierarchyKey = "categories_prev_hierarchy"
        static let CreatedTKey = "created_t"
        static let ProductNameKey = "product_name"
        static let IngredientsFromOrThatMayBeFromPalmOilNKey = "ingredients_from_or_that_may_be_from_palm_oil_n"
        static let CreatorKey = "creator"
        static let ImageFrontUrlKey = "image_front_url"
        static let NoNutritionDataKey = "no_nutrition_data" // TBD
        static let ServingSizeKey = "serving_size"
        static let CompletedTKey = "completed_t"
        static let LastModifiedByKey = "last_modified_by"
        static let NewAdditivesNKey = "new_additives_n"
        static let AdditivesPrevTagsKey = "additives_prev_tags"
        static let OriginsKey = "origins"
        static let StoresKey = "stores"
        static let NutritionGradesKey = "nutrition_grades"
        static let NutritionGradeFrKey = "nutrition_grade_fr"
        static let NutrientLevelsKey = "nutrient_levels"
        static let NutrientLevelsSaltKey = "salt"
        static let NutrientLevelsFatKey = "fat"
        static let NutrientLevelsSugarsKey = "sugars"
        static let NutrientLevelsSaturatedFatKey = "saturated-fat"
        static let AdditivesPrevKey = "additives_prev"
        static let StoresTagsKey = "stores_tags"
        static let IdKey = "id"
        static let CountriesKey = "countries"
        static let ImageFrontThumbUrlKey = "image_front_thumb_url"
        static let PurchasePlacesTagsKey = "purchase_places_tags"
        static let TracesHierarchyKey = "traces_hierarchy"
        static let InterfaceVersionModifiedKey = "interface_version_modified"
        static let FruitsVegetablesNuts100gEstimateKey = "fruits-vegetables-nuts_100g_estimate"
        static let ImageThumbUrlKey = "image_thumb_url"
        static let SortkeyKey = "sortkey"
        static let ImageNutritionThumbUrlKey = "image_nutrition_thumb_url"
        static let LastModifiedTKey = "last_modified_t"
        static let ImageIngredientsUrlKey = "image_ingredients_url"
        static let NutritionScoreDebugKey = "nutrition_score_debug"
        static let ImageNutritionSmallUrlKey = "image_nutrition_small_url"
        static let CorrectorsTagsKey = "correctors_tags"
        static let CorrectorsKey = "correctors"
        static let CategoriesDebugTagsKey = "categories_debug_tags"
        static let BrandsKey = "brands"
        static let IngredientsTagsKey = "ingredients_tags"
        static let CodesTagsKey = "codes_tags"
        static let StatesKey = "states"
        static let InformersKey = "informers"
        static let EntryDatesTagsKey = "entry_dates_tags"
        static let ImageIngredientsSmallUrlKey = "image_ingredients_small_url"
        static let NutritionGradesTagsKey = "nutrition_grades_tags"
        static let PackagingKey = "packaging"
        static let ServingQuantityKey = "serving_quantity"
        static let OriginsTagsKey = "origins_tags"
        static let ManufacturingPlacesTagsKey = "manufacturing_places_tags"
        static let NutritionDataPerKey = "nutrition_data_per"
        static let LabelsKey = "labels"
        static let CitiesTagsKey = "cities_tags"
        static let EmbCodes20141016Key = "emb_codes_20141016"
        static let CategoriesTagsKey = "categories_tags"
        static let QuantityKey = "quantity"
        static let LabelsPrevHierarchyKey = "labels_prev_hierarchy"
        static let ExpirationDateKey = "expiration_date"
        static let StatesHierarchyKey = "states_hierarchy"
        static let AllergensTagsKey = "allergens_tags"
        static let IngredientsThatMayBeFromPalmOilNKey = "ingredients_that_may_be_from_palm_oil_n"
        static let ImageIngredientsThumbUrlKey = "image_ingredients_thumb_url"
        static let IngredientsFromPalmOilNKey = "ingredients_from_palm_oil_n"
        static let ImageUrlKey = "image_url"
        static let IngredientsKey = "ingredients" // TBD
        static let IngredientsElementTextKey = "text"
        static let IngredientsElementRankKey = "rank"
        static let IngredientsElementIdKey = "id"
        static let LcKey = "lc"
        static let IngredientsDebugKey = "ingredients_debug"
        static let PnnsGroups1TagsKey = "pnns_groups_1_tags"
        static let CheckersKey = "checkers"
        static let AdditivesKey = "additives"
        static let CompleteKey = "complete"
        static let AdditivesDebugTagsKey = "additives_debug_tags"
        static let IngredientsIdsDebugKey = "ingredients_ids_debug"
    }
    
    // MARK: - unpack JSON
    
    func unpackJSONObject(_ jsonObject: JSON) -> ProductFetchStatus {
        
        // All the fields available in the barcode.json are listed below
        // Those that are not used at the moment are edited out
        
        struct ingredientsElement {
            var text: String? = nil
            var id: String? = nil
            var rank: Int? = nil
        }
        
        if let resultStatus = jsonObject[OFFJson.StatusKey].int {
            if resultStatus == 0 {
                // barcode NOT found in database
                // There is nothing more to decode
                if let statusVerbose = jsonObject[OFFJson.StatusVerboseKey].string {
                    return ProductFetchStatus.productNotAvailable(statusVerbose)
                } else {
                    return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: No verbose status", comment: "The JSON file is wrongly formatted."))
                }
                
            } else if resultStatus == 1 {
                // barcode exists in OFF database
                let product = FoodProduct()
                
                product.barcode.string(jsonObject[OFFJson.CodeKey].string)
                
                product.mainUrlThumb = jsonObject[OFFJson.ProductKey][OFFJson.ImageFrontSmallUrlKey].url

                decodeCompletionStates(jsonObject[OFFJson.ProductKey][OFFJson.StatesTagsKey].stringArray, product:product)
                decodeLastEditDates(jsonObject[OFFJson.ProductKey][OFFJson.LastEditDatesTagsKey].stringArray, forProduct:product)
                
                
                product.labelArray = Tags(decodeGlobalLabels(jsonObject[OFFJson.ProductKey][OFFJson.LabelsTagsKey].stringArray))
                
                product.traceKeys = jsonObject[OFFJson.ProductKey][OFFJson.TracesTagsKey].stringArray

                product.primaryLanguageCode = jsonObject[OFFJson.ProductKey][OFFJson.LangKey].string
                
                if let languages = jsonObject[OFFJson.ProductKey][OFFJson.LanguagesHierarchy].stringArray {
                    product.languageCodes = []
                    for language in languages {
                        let isoCode = OFFplists.manager.translateLanguage(language, language: "iso")
                        product.languageCodes.append(isoCode)
                        var key = OFFJson.IngredientsTextKey + "_" + isoCode
                        product.ingredientsLanguage[isoCode] = jsonObject[OFFJson.ProductKey][key].string
                        key = OFFJson.ProductNameKey + "_" + isoCode
                        product.nameLanguage[isoCode] = jsonObject[OFFJson.ProductKey][key].string
                        key = OFFJson.GenericNameKey + "_" + isoCode
                        product.genericNameLanguage[isoCode] = jsonObject[OFFJson.ProductKey][key].string
                    }
                }
                product.genericName = jsonObject[OFFJson.ProductKey][OFFJson.GenericNameKey].string
                product.additives = Tags(decodeAdditives(jsonObject[OFFJson.ProductKey][OFFJson.AdditivesTagsKey].stringArray))
                
                product.informers = jsonObject[OFFJson.ProductKey][OFFJson.InformersTagsKey].stringArray
                product.photographers = jsonObject[OFFJson.ProductKey][OFFJson.PhotographersTagsKey].stringArray
                product.packagingArray = Tags.init(jsonObject[OFFJson.ProductKey][OFFJson.PackagingKey].string)
                product.numberOfIngredients = jsonObject[OFFJson.ProductKey][OFFJson.IngredientsNKey].string
                
                product.countryArray(decodeCountries(jsonObject[OFFJson.ProductKey][OFFJson.CountriesTagsKey].stringArray))
                
                product.producerCode = decodeProducerCodeArray(jsonObject[OFFJson.ProductKey][OFFJson.EmbCodesOrigKey].string)
                
                product.brands = Tags.init(jsonObject[OFFJson.ProductKey][OFFJson.BrandsKey].string)
                
                // The links for the producer are stored as a string. This string might contain multiple links.
                let linksString = jsonObject[OFFJson.ProductKey][OFFJson.LinkKey].string
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
                
                product.purchaseLocationString(jsonObject[OFFJson.ProductKey][OFFJson.PurchasePlacesKey].string)
                product.nutritionFactsImageUrl = jsonObject[OFFJson.ProductKey][OFFJson.ImageNutritionUrlKey].url
                product.ingredients = jsonObject[OFFJson.ProductKey][OFFJson.IngredientsTextKey].string
                
                product.editors = jsonObject[OFFJson.ProductKey][OFFJson.EditorsTagsKey].stringArray
                product.additionDate = jsonObject[OFFJson.ProductKey][OFFJson.CreatedTKey].time
                product.name = jsonObject[OFFJson.ProductKey][OFFJson.ProductNameKey].string
                product.creator = jsonObject[OFFJson.ProductKey][OFFJson.CreatorKey].string
                product.mainImageUrl = jsonObject[OFFJson.ProductKey][OFFJson.ImageFrontUrlKey].url
                product.nutritionFactsAreAvailable = decodeNutritionDataAvalailable(jsonObject[OFFJson.ProductKey][OFFJson.NoNutritionDataKey].string)
                product.servingSize = jsonObject[OFFJson.ProductKey][OFFJson.ServingSizeKey].string
                var grade: NutritionalScoreLevel = .undefined
                grade.string(jsonObject[OFFJson.ProductKey][OFFJson.NutritionGradeFrKey].string)
                product.nutritionGrade = grade
                
                
                let nutrientLevelsSalt = jsonObject[OFFJson.ProductKey][OFFJson.NutrientLevelsKey][OFFJson.NutrientLevelsSaltKey].string
                let nutrientLevelsFat = jsonObject[OFFJson.ProductKey][OFFJson.NutrientLevelsKey][OFFJson.NutrientLevelsFatKey].string
                let nutrientLevelsSaturatedFat = jsonObject[OFFJson.ProductKey][OFFJson.NutrientLevelsKey][OFFJson.NutrientLevelsSaturatedFatKey].string
                let nutrientLevelsSugars = jsonObject[OFFJson.ProductKey][OFFJson.NutrientLevelsKey][OFFJson.NutrientLevelsSugarsKey].string
                product.stores = jsonObject[OFFJson.ProductKey][OFFJson.StoresKey].string?.components(separatedBy: ",")
                product.imageIngredientsUrl = jsonObject[OFFJson.ProductKey][OFFJson.ImageIngredientsUrlKey].url
                (product.nutritionalScoreUK, product.nutritionalScoreFrance) = decodeNutritionalScore(jsonObject[OFFJson.ProductKey][OFFJson.NutritionScoreDebugKey].string)
                product.imageNutritionSmallUrl = jsonObject[OFFJson.ProductKey][OFFJson.ImageNutritionSmallUrlKey].url
                product.correctors = jsonObject[OFFJson.ProductKey][OFFJson.CorrectorsTagsKey].stringArray

                product.imageIngredientsSmallUrl = jsonObject[OFFJson.ProductKey][OFFJson.ImageIngredientsSmallUrlKey].url
                product.ingredientsOriginElements(jsonObject[OFFJson.ProductKey][OFFJson.OriginsTagsKey].stringArray)
                product.producerElements(jsonObject[OFFJson.ProductKey][OFFJson.ManufacturingPlacesKey].string)
                product.categories = decodeCategories(jsonObject[OFFJson.ProductKey][OFFJson.CategoriesTagsKey].stringArray)
                product.quantity = jsonObject[OFFJson.ProductKey][OFFJson.QuantityKey].string
                product.nutritionFactsIndicationUnit = decodeNutritionFactIndicationUnit(jsonObject[OFFJson.ProductKey][OFFJson.NutritionDataPerKey].string)
                product.expirationDate = decodeDate(jsonObject[OFFJson.ProductKey][OFFJson.ExpirationDateKey].string)
                product.allergenKeys = jsonObject[OFFJson.ProductKey][OFFJson.AllergensTagsKey].stringArray
                if let ingredientsJSON = jsonObject[OFFJson.ProductKey][OFFJson.IngredientsKey].array {
                    var ingredients: [ingredientsElement] = []
                    for ingredientsJSONElement in ingredientsJSON {
                        var element = ingredientsElement()
                        element.text = ingredientsJSONElement[OFFJson.IngredientsElementTextKey].string
                        element.id = ingredientsJSONElement[OFFJson.IngredientsElementIdKey].string
                        element.rank = ingredientsJSONElement[OFFJson.IngredientsElementRankKey].int
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
                
                struct NutritionFacts {
                    static let EnergyKey = "Energy"
                    static let FatKey = "Fat"
                    static let MonounsaturatedFatKey = "Monounsaturated fat"
                    static let PolyunsaturatedFatKey = "Polyunsaturated fat"
                    static let SaturatedFatKey = "Saturated fat"
                    static let Omega3FatKey = "Omega-3 fat"
                    static let Omega6FatKey = "Omega-6 fat"
                    static let Omega9FatKey = "Omega-9 fat"
                    static let TransFatKey = "Trans fat"
                    static let CholesterolKey = "Cholesterol"
                    static let CarbohydratesKey = "Carbohydrates"
                    static let SugarsKey = "Sugars"
                    static let SucroseKey = "Sucrose"
                    static let GlucoseKey = "Glucose"
                    static let FructoseKey = "Fructose"
                    static let LactoseKey = "Lactose"
                    static let MaltoseKey = "Maltose"
                    static let PolyolsKey = "Polyols"
                    static let MaltodextrinsKey = "Maltodextrins"
                    static let FiberKey = "Fiber"
                    static let ProteinsKey = "Proteins"
                    static let AlcoholKey = "Alcohol"
                    static let SodiumKey = "Sodium"
                    static let SaltKey = "Salt"
                    
                    static let BiotinKey = "Biotin"
                    static let CaseinKey = "Casein"
                    static let SerumProteinsKey = "Serum proteins"
                    static let NucleotidesKey = "Nucleotides"
                    static let StarchKey = "Starch"
                    
                    static let AlphaLinolenicAcidKey = "Alpha-linolenic acid"
                    static let ArachidicAcidKey = "Arachidic acid"
                    static let ArachidonicAcidKey = "Arachidonic acid"
                    static let BehenicAcidKey = "Behenic acid"
                    static let ButyricAcidKey = "Butyric acid"
                    static let CapricAcidKey = "Capric acid"
                    static let CaproicAcidKey = "Caproic acid"
                    static let CaprylicAcidKey = "Caprylic-acid"
                    static let CeroticAcidKey = "Cerotic acid"
                    static let DihomoGammaLinolenicAcidKey = "Dihomo-gamma-linolenic acid"
                    static let DocosahexaenoicAcidKey = "Docosahexaenoic acid"
                    static let EicosapentaenoicAcidKey = "Eicosapentaenoic acid"
                    static let ElaidicAcidKey = "Elaidic acid"
                    static let ErucicAcidKey = "Erucic acid"
                    static let GammaLinolenicAcidKey = "Gamma-linolenic acid"
                    static let GondoicAcidKey = "Gondoic acid"
                    static let LauricAcidKey = "Lauric acid"
                    static let LignocericAcidKey = "Lignoceric acid"
                    static let LinoleicAcidKey = "Linoleic acid"
                    static let MeadAcidKey = "Mead acid"
                    static let MelissicAcidKey = "Melissic acid"
                    static let MontanicAcidKey = "Montanic acid"
                    static let MyristicAcidKey = "Myristic acid"
                    static let NervonicAcidKey = "Nervonic acid"
                    static let PalmiticAcidKey = "Palmitic acid"
                    static let PantothenicAcidKey = "Pantothenic acid"
                    static let StearicAcidKey = "Stearic acid"
                    static let VoleicAcidKey = "Voleic acid"
                    
                    static let VitaminAKey = "Vitamin A"
                    static let VitaminB1Key = "Vitamin B1"
                    static let VitaminB2Key = "Vitamin B2"
                    static let VitaminPPKey = "Vitamin PP"
                    static let VitaminB6Key = "Vitamin B6"
                    static let VitaminB9Key = "Vitamin B9"
                    static let VitaminB12Key = "Vitamin B12"
                    static let VitaminCKey = "Vitamin C"
                    static let VitaminDKey = "Vitamin D"
                    static let VitaminEKey = "Vitamin E"
                    static let VitaminKKey = "Vitamin K"
                    
                    static let CalciumKey = "Calcium"
                    static let ChlorideKey = "Chloride"
                    static let ChromiumKey = "Chromium"
                    static let CopperKey = "Copper"
                    static let BicarbonateKey = "Bicarbonate"
                    static let FluorideKey = "Fluoride"
                    static let IodineKey = "Iodine"
                    static let IronKey = "Iron"
                    static let MagnesiumKey = "Magnesium"
                    static let ManganeseKey = "Manganese"
                    static let MolybdenumKey = "Molybdenum"
                    static let PhosphorusKey = "Phosphorus"
                    static let PotassiumKey = "Potassium"
                    static let SeleniumKey = "Selenium"
                    static let SilicaKey = "Silica"
                    static let ZincKey = "Zinc"
                    
                    static let CaffeineKey = "Caffeine"
                    static let TaurineKey = "Taurine"
                    
                    static let PhKey = "ph"
                    static let CacaoKey = "Cacao Min."
                }
                
                // Warning: the order of these nutrients is important. It will be displayed as such.
                
                nutritionDecode(NutritionFacts.EnergyKey, key: OFFJson.EnergyKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.FatKey, key: OFFJson.FatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MonounsaturatedFatKey, key: OFFJson.MonounsaturatedFatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.PolyunsaturatedFatKey, key: OFFJson.PolyunsaturatedFatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SaturatedFatKey, key: OFFJson.SaturatedFatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.Omega3FatKey, key: OFFJson.Omega3FatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.Omega6FatKey, key: OFFJson.Omega6FatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.Omega9FatKey, key: OFFJson.Omega9FatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.TransFatKey, key: OFFJson.TransFatKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CholesterolKey, key: OFFJson.CholesterolKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SodiumKey, key: OFFJson.SodiumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SaltKey, key: OFFJson.SaltKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CarbohydratesKey, key: OFFJson.CarbohydratesKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SugarsKey, key: OFFJson.SugarsKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SucroseKey, key: OFFJson.SucroseKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.GlucoseKey, key: OFFJson.GlucoseKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.FructoseKey , key: OFFJson.FructoseKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.LactoseKey, key: OFFJson.LactoseKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MaltoseKey, key: OFFJson.MaltoseKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.PolyolsKey, key: OFFJson.PolyolsKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MaltodextrinsKey, key: OFFJson.MaltodextrinsKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.FiberKey, key: OFFJson.FiberKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ProteinsKey, key: OFFJson.ProteinsKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.AlcoholKey, key: OFFJson.AlcoholKey, jsonObject: jsonObject, product: product)
                
                nutritionDecode(NutritionFacts.BiotinKey, key: OFFJson.BiotinKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CaseinKey, key: OFFJson.CaseinKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SerumProteinsKey, key: OFFJson.SerumProteinsKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.NucleotidesKey , key: OFFJson.NucleotidesKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.StarchKey, key: OFFJson.StarchKey, jsonObject: jsonObject, product: product)
                
                nutritionDecode(NutritionFacts.AlphaLinolenicAcidKey, key: OFFJson.AlphaLinolenicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ArachidicAcidKey, key: OFFJson.ArachidicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ArachidonicAcidKey, key: OFFJson.ArachidonicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.BehenicAcidKey, key: OFFJson.BehenicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ButyricAcidKey, key: OFFJson.ButyricAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CapricAcidKey, key: OFFJson.CapricAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CaproicAcidKey, key: OFFJson.CaproicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CaprylicAcidKey, key: OFFJson.CaprylicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CeroticAcidKey, key: OFFJson.CeroticAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.DihomoGammaLinolenicAcidKey, key: OFFJson.DihomoGammaLinolenicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.DocosahexaenoicAcidKey, key: OFFJson.EicosapentaenoicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.EicosapentaenoicAcidKey, key: OFFJson.EicosapentaenoicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ElaidicAcidKey, key: OFFJson.ElaidicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ErucicAcidKey, key: OFFJson.ErucicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.GammaLinolenicAcidKey, key: OFFJson.GammaLinolenicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.GondoicAcidKey, key: OFFJson.GondoicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.LauricAcidKey, key: OFFJson.LauricAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.LignocericAcidKey, key: OFFJson.LignocericAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.LinoleicAcidKey, key: OFFJson.LinoleicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MeadAcidKey, key: OFFJson.MeadAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MelissicAcidKey, key: OFFJson.MelissicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MontanicAcidKey, key: OFFJson.MontanicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MyristicAcidKey, key: OFFJson.MyristicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.NervonicAcidKey, key: OFFJson.NervonicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.PalmiticAcidKey, key: OFFJson.PalmiticAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.PantothenicAcidKey, key: OFFJson.PantothenicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.StearicAcidKey, key: OFFJson.StearicAcidKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VoleicAcidKey, key: OFFJson.VoleicAcidKey, jsonObject: jsonObject, product: product)
                
                nutritionDecode(NutritionFacts.VitaminAKey, key: OFFJson.VitaminAKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminB1Key, key: OFFJson.VitaminB1Key, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminB2Key, key: OFFJson.VitaminB2Key, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminPPKey, key: OFFJson.VitaminPPKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminB6Key, key: OFFJson.VitaminB6Key, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminB9Key, key: OFFJson.VitaminB9Key, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminB12Key, key: OFFJson.VitaminB12Key, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminCKey, key: OFFJson.VitaminCKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminDKey, key: OFFJson.VitaminDKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminEKey, key: OFFJson.VitaminEKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.VitaminKKey, key: OFFJson.VitaminKKey, jsonObject: jsonObject, product: product)
                
                nutritionDecode(NutritionFacts.CalciumKey, key: OFFJson.CalciumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ChlorideKey, key: OFFJson.ChlorideKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ChromiumKey, key: OFFJson.ChromiumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.CopperKey, key: OFFJson.CopperKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.BicarbonateKey, key: OFFJson.BicarbonateKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.FluorideKey, key: OFFJson.FluorideKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.IodineKey, key: OFFJson.IodineKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.IronKey, key: OFFJson.IronKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MagnesiumKey, key: OFFJson.MagnesiumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ManganeseKey, key: OFFJson.ManganeseKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.MolybdenumKey, key: OFFJson.MolybdenumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.PhosphorusKey, key: OFFJson.PhosphorusKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.PotassiumKey, key: OFFJson.PotassiumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SeleniumKey, key: OFFJson.SeleniumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SilicaKey, key: OFFJson.SilicaKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.ZincKey, key: OFFJson.ZincKey, jsonObject: jsonObject, product: product)
                
                nutritionDecode(NutritionFacts.CaffeineKey, key: OFFJson.CaffeineKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.TaurineKey, key: OFFJson.TaurineKey, jsonObject: jsonObject, product: product)
                
                nutritionDecode(NutritionFacts.PhKey, key: OFFJson.PhKey, jsonObject: jsonObject, product:product)
                nutritionDecode(NutritionFacts.CacaoKey, key: OFFJson.CacaoKey, jsonObject: jsonObject, product:product)
                
                return ProductFetchStatus.success(product)
            } else {
                return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: Other (>1) result status", comment: "A JSON status which is not supported."))
            }
        } else {
            return ProductFetchStatus.loadingFailed(NSLocalizedString("Error: No result status in JSON", comment: "Error message when the json input file does not contain any information") )
        }

    }
    
    // MARK: - Decoding Functions

    fileprivate func nutritionDecode(_ fact: String, key: String, jsonObject: JSON, product: FoodProduct) {
        
    //TBD decoding needs to be improved
        struct Appendix {
            static let HunderdKey = "_100g"
            static let ServingKey = "_serving"
            static let UnitKey = "_unit"
            static let ValueKey = "_value"
        }
        var nutritionItem = NutritionFactItem()
        let preferredLanguage = Locale.preferredLanguages[0]
        nutritionItem.key = key
        nutritionItem.itemName = OFFplists.manager.translateNutrients(key, language:preferredLanguage)
        // we use only the values standerdized on g
        if nutritionItem.key!.contains("energy") {
            nutritionItem.standardValueUnit = NutritionFactUnit.Joule
            nutritionItem.servingValueUnit = NutritionFactUnit.Joule
            if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.HunderdKey].string {
                nutritionItem.standardValue = value
            } else if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ValueKey].string {
                nutritionItem.standardValue = value
            }
            if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ServingKey].string {
                nutritionItem.servingValue = value
            } else if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ValueKey].string {
                nutritionItem.servingValue = value
            }

        } else if (nutritionItem.key!.contains("alcohol")) || (nutritionItem.key!.contains("cocoa")){
            nutritionItem.standardValueUnit = NutritionFactUnit.Percent
            nutritionItem.servingValueUnit = NutritionFactUnit.Percent
            if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.HunderdKey].string {
                nutritionItem.standardValue = value
            } else if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ValueKey].string {
                nutritionItem.standardValue = value
            }
            if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ServingKey].string {
                nutritionItem.servingValue = value
            } else if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ValueKey].string {
                nutritionItem.servingValue = value
            }
        } else {
            nutritionItem.standardValueUnit = NutritionFactUnit.Gram
            nutritionItem.servingValueUnit = NutritionFactUnit.Gram
            if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.HunderdKey].string {
                // is the value translatable to a number?
                if var doubleValue = Double(value) {

                    if doubleValue < 0.99 {
                        //change to the milli version
                        doubleValue = doubleValue * 1000.0
                        if doubleValue < 0.99 {
                            // change to the microversion
                            doubleValue = doubleValue * 1000.0
                            // we use only the values standerdized on g
                            if doubleValue < 0.99 {
                                nutritionItem.standardValueUnit = NutritionFactUnit.Gram
                            } else {
                                nutritionItem.standardValueUnit = NutritionFactUnit.Microgram
                            }
                        } else {
                            // we use only the values standerdized on g
                            nutritionItem.standardValueUnit = NutritionFactUnit.Milligram
                        }
                    } else {
                        // we use only the values standerdized on g
                        nutritionItem.standardValueUnit = NutritionFactUnit.Gram

                    }
                    // print("standard: \(key) \(doubleValue) " + nutritionItem.standardValueUnit! )
                    nutritionItem.standardValue = "\(doubleValue)"
                } else {
                    nutritionItem.standardValue = value
                }
            } else if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ValueKey].string {
                nutritionItem.standardValue = value
            }
        
            if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ServingKey].string {
                // is the value translatable to a number?
                if var doubleValue = Double(value) {
                    // use the original values to calculate the daily fraction
                    let dailyValue = ReferenceDailyIntakeList.manager.dailyValue(value: doubleValue, forKey:key)
                    // print("serving: \(key) \(doubleValue)" )
                    nutritionItem.dailyFractionPerServing = dailyValue
                
                    if doubleValue < 0.99 {
                        //change to the milli version
                        doubleValue = doubleValue * 1000.0
                        if doubleValue < 0.99 {
                            // change to the microversion
                            doubleValue = doubleValue * 1000.0
                            if doubleValue < 0.99 {
                                nutritionItem.servingValueUnit = nutritionItem.servingValueUnit!
                            } else {
                                // we use only the values standerdized on g
                                if nutritionItem.servingValueUnit! == .Gram {
                                    nutritionItem.servingValueUnit = .Microgram
                                } else if nutritionItem.servingValueUnit! == .Liter {
                                    nutritionItem.servingValueUnit = .Microliter
                                }
                            }
                        } else {
                            // we use only the values standerdized on g
                            if nutritionItem.servingValueUnit! == .Gram {
                                nutritionItem.servingValueUnit = .Milligram
                            } else if nutritionItem.servingValueUnit! == .Liter {
                                nutritionItem.servingValueUnit = .Milliliter
                            }
                        }
                    } else {
                        // we use only the values standerdized on g
                        nutritionItem.servingValueUnit = nutritionItem.servingValueUnit!
                    }

                    nutritionItem.servingValue = "\(doubleValue)"

                } else {
                    nutritionItem.servingValue = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.HunderdKey].string
                }

            } else if let value = jsonObject[OFFJson.ProductKey][OFFJson.NutrimentsKey][key+Appendix.ValueKey].string {
                nutritionItem.servingValue = value
            }
        }
        // what data is defined?
        if (nutritionItem.standardValue == nil) {
            if (nutritionItem.servingValue == nil) {
                if product.nutritionFactsImageUrl != nil {
                // the user did ot enter the nutrition data
                    product.nutritionFactsAreAvailable = .notIndicated
                } else {
                    product.nutritionFactsAreAvailable = .notAvailable
                }
                return
            } else {
                product.nutritionFactsAreAvailable = .perServing
            }
        } else {
            if (nutritionItem.servingValue == nil) {
                product.nutritionFactsAreAvailable = .perStandardUnit
            } else {
                product.nutritionFactsAreAvailable = .perServingAndStandardUnit
            }
        }
        product.add(fact: nutritionItem)
    }
    
    fileprivate struct StateCompleteKey {
        static let NutritionFacts = "en:nutrition-facts-completed"
        static let NutritionFactsTBD = "en:nutrition-facts-to-be-completed"
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
    
    fileprivate func decodeNutritionDataAvalailable(_ code: String?) -> NutritionAvailability {
        if let validCode = code {
            return validCode.hasPrefix("on") ? NutritionAvailability.notOnPackage : NutritionAvailability.notIndicated
        }
        return NutritionAvailability.notIndicated
        
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

                } else if currentState.contains(StateCompleteKey.NutritionFacts) {
                    product.state.nutritionFactsComplete.value = true
                    product.state.nutritionFactsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.NutritionFacts, language:preferredLanguage)
                    
                } else if currentState.contains(StateCompleteKey.NutritionFactsTBD) {
                    product.state.nutritionFactsComplete.value = false
                    product.state.nutritionFactsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.NutritionFactsTBD, language:preferredLanguage)

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

    fileprivate func decodeDate(_ date: String?) -> Date? {
        if let validDate = date {
            if !validDate.isEmpty {
                let types: NSTextCheckingResult.CheckingType = [.date]
                let dateDetector = try? NSDataDetector(types: types.rawValue)
            
                let dateMatches = dateDetector?.matches(in: validDate, options: [], range: NSMakeRange(0, (validDate as NSString).length))
            
                if let matches = dateMatches {
                    if !matches.isEmpty {
                        // did we find a date?
                        if matches[0].resultType == NSTextCheckingResult.CheckingType.date {
                            return matches[0].date
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                // This is for formats not recognized by NSDataDetector
                // such as 07/2014
                // but other formats are possible and still need to be found
                if validDate.range( of: "../....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM/yyyy"
                    return dateFormatter.date(from: validDate)
                } else if validDate.range( of: ".-....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM/yyyy"
                    return dateFormatter.date(from: "0"+validDate)
                } else if validDate.range( of: "..-....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM-yyyy"
                    return dateFormatter.date(from: validDate)
                } else if validDate.range( of: "....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "yyyy"
                    return dateFormatter.date(from: validDate)
                }
                print("Date '\(validDate)' could not be recognized")
            }
        }
        return nil
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
            // FR\s..\....\.... is the original regex string
            if validCode.range(of: "FR\\s..\\....\\....", options: .regularExpression) != nil {
                newAddress.country = "France"
                let elementsSeparatedBySpace = validCode.characters.split{$0 == " "}.map(String.init)
                let elementsSeparatedByDot = elementsSeparatedBySpace[1].characters.split{$0 == "."}.map(String.init)
                // combine into a valid french postal code
                newAddress.postalcode = elementsSeparatedByDot[0] + elementsSeparatedByDot[1]
                return newAddress
                
            } else if validCode.range(of: "ES\\s..\\....\\....", options: .regularExpression) != nil {
                newAddress.country = "Spain"
                let elementsSeparatedBySpace = validCode.characters.split{$0 == " "}.map(String.init)
                let elementsSeparatedByDot = elementsSeparatedBySpace[1].characters.split{$0 == "."}.map(String.init)
                // combine into a valid french postal code
                newAddress.postalcode = elementsSeparatedByDot[0] + elementsSeparatedByDot[1]
                return newAddress
                
            } else if validCode.range(of: "IT\\s..\\....\\....", options: .regularExpression) != nil {
                newAddress.country = "Italy"
                let elementsSeparatedBySpace = validCode.characters.split{$0 == " "}.map(String.init)
                let elementsSeparatedByDot = elementsSeparatedBySpace[1].characters.split{$0 == "."}.map(String.init)
                // combine into a valid french postal code
                newAddress.postalcode = elementsSeparatedByDot[0] + elementsSeparatedByDot[1]
                return newAddress
                
            } else if validCode.range(of: "EMB\\s\\d{5}", options: .regularExpression) != nil {
                newAddress.country = "France"
                
                // start after the first four characters
                if validCode.length() >= 9 {
                    newAddress.postalcode = validCode.substring(4, length: 5)
                    return newAddress
                }
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
            }
            print("Producer code '\(validCode)' could not be recognized")

        }
        return nil
    }
    
    func decodeNutritionalScore(_ jsonString: String?) -> (NutritionalScoreUK, NutritionalScoreFrance) {
    
        var nutrionalScoreUK = NutritionalScoreUK()
        var nutrionalScoreFrance = NutritionalScoreFrance()
        
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
                // split on --, should give 4 parts: empty, nutriments, fsa, fr
                let dashParts = validJsonString.components(separatedBy: "-- ")
                var offset = 0
                if dashParts.count == 5 {
                    offset = 1
                    if dashParts[1].contains("beverages") {
                        nutrionalScoreFrance.beverage = true
                    } else if dashParts[1].contains("cheeses") {
                        nutrionalScoreFrance.cheese = true
                    }
                }
                // find the total fsa score
                var spaceParts2 = dashParts[2+offset].components(separatedBy: " ")
                if let validScore = Int.init(spaceParts2[1]) {
                    nutrionalScoreUK.score = validScore
                } else {
                    nutrionalScoreUK.score = 0
                }
                
                spaceParts2 = dashParts[3+offset].components(separatedBy: " ")
                if let validScore = Int.init(spaceParts2[1]) {
                    nutrionalScoreFrance.score = validScore
                } else {
                    nutrionalScoreFrance.score = 0
                }

                
                if nutrionalScoreFrance.beverage {
                    // the french calculation for beverages uses a different table and evaluation
                    // use after the :
                    let colonParts = dashParts[1].components(separatedBy: ": ")
                    // split on +
                    let plusParts = colonParts[1].components(separatedBy: " + ")
                    // split on space to find the numbers
                    // energy
                    var spacePart = plusParts[0].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValue = nutrionalScoreFrance.pointsA[0]
                        newValue.points = validValue
                        nutrionalScoreFrance.pointsA[0] = newValue
                    }
                    // sat_fat
                    spacePart = plusParts[1].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValue = nutrionalScoreFrance.pointsA[1]
                        newValue.points = validValue
                        nutrionalScoreFrance.pointsA[1] = newValue
                    }
                    // sugars
                    spacePart = plusParts[2].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValue = nutrionalScoreFrance.pointsA[2]
                        newValue.points = validValue
                        nutrionalScoreFrance.pointsA[2] = newValue
                    }
                    // sodium
                    spacePart = plusParts[3].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValue = nutrionalScoreFrance.pointsA[3]
                        newValue.points = validValue
                        nutrionalScoreFrance.pointsA[3] = newValue
                    }
                    
                } else {
                    // split on -,
                    let minusparts = dashParts[1+offset].components(separatedBy: " - ")
                    
                    // fruits 0%
                    var spacePart = minusparts[1].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[2]) {
                        var newValueFrance = nutrionalScoreFrance.pointsC[0]
                        var newValueUK = nutrionalScoreUK.pointsC[0]
                        newValueFrance.points = validValue
                        newValueUK.points = validValue
                        nutrionalScoreFrance.pointsC[0] = newValueFrance
                        nutrionalScoreUK.pointsC[0] = newValueUK
                    }
                    // fiber
                    spacePart = minusparts[2].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValueFrance = nutrionalScoreFrance.pointsC[1]
                        var newValueUK = nutrionalScoreUK.pointsC[1]
                        newValueFrance.points = validValue
                        newValueUK.points = validValue
                        nutrionalScoreFrance.pointsC[1] = newValueFrance
                        nutrionalScoreUK.pointsC[1] = newValueUK
                    }
                    // proteins
                    spacePart = minusparts[3].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValueFrance = nutrionalScoreFrance.pointsC[2]
                        var newValueUK = nutrionalScoreUK.pointsC[2]
                        newValueFrance.points = validValue
                        newValueUK.points = validValue
                        nutrionalScoreFrance.pointsC[2] = newValueFrance
                        nutrionalScoreUK.pointsC[2] = newValueUK
                    }
                    
                    let plusParts = minusparts[0].components(separatedBy: " + ")
                    // energy
                    spacePart = plusParts[0].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValueFrance = nutrionalScoreFrance.pointsA[0]
                        var newValueUK = nutrionalScoreUK.pointsA[0]
                        newValueFrance.points = validValue
                        newValueUK.points = validValue
                        nutrionalScoreFrance.pointsA[0] = newValueFrance
                        nutrionalScoreUK.pointsA[0] = newValueUK
                    }
                    // saturated fats
                    spacePart = plusParts[1].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValueUK = nutrionalScoreUK.pointsA[1]
                        newValueUK.points = validValue
                        nutrionalScoreUK.pointsA[1] = newValueUK
                    }
                    // saturated fat ratio
                    spacePart = plusParts[2].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValueFrance = nutrionalScoreFrance.pointsA[1]
                        newValueFrance.points = validValue
                        nutrionalScoreFrance.pointsA[1] = newValueFrance
                    }
                    
                    // sugars
                    spacePart = plusParts[3].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValueFrance = nutrionalScoreFrance.pointsA[2]
                        var newValueUK = nutrionalScoreUK.pointsA[2]
                        newValueFrance.points = validValue
                        newValueUK.points = validValue
                        nutrionalScoreFrance.pointsA[2] = newValueFrance
                        nutrionalScoreUK.pointsA[2] = newValueUK
                    }
                    // sodium
                    spacePart = plusParts[4].components(separatedBy: " ")
                    if let validValue = Int.init(spacePart[1]) {
                        var newValueFrance = nutrionalScoreFrance.pointsA[3]
                        var newValueUK = nutrionalScoreUK.pointsA[3]
                        newValueFrance.points = validValue
                        newValueUK.points = validValue
                        nutrionalScoreFrance.pointsA[3] = newValueFrance
                        nutrionalScoreUK.pointsA[3] = newValueUK
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

}





