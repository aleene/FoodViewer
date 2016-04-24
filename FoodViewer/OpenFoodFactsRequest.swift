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
    
    private struct OpenFoodFacts {
        static let JSONExtension = ".json"
        static let APIURLPrefixForProduct = "http://world.openfoodfacts.org/api/v0/product/"
        static let sampleProductBarcode = "40111490"
    }
    
    enum FetchResult {
        case Error(String)
        case Success(FoodProduct)
    }
    
    enum FetchJsonResult {
        case Error(String)
        case Success(NSData)
    }

    var fetched: FetchResult = .Error("Initialised")
    
    func fetchStoredProduct(data: NSData) -> FetchResult {
        return unpackJSONObject(JSON.parse(data))
    }
    
    func fetchProductForBarcode(barcode: BarcodeType) -> FetchResult {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let fetchUrl = NSURL(string: "\(OpenFoodFacts.APIURLPrefixForProduct + barcode.asString() + OpenFoodFacts.JSONExtension)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        // print("\(fetchUrl)")
        if let url = fetchUrl {
            do {
                let data = try NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                return unpackJSONObject(JSON.parse(data))
            } catch let error as NSError {
                print(error);
                return FetchResult.Error(error.description)
            }
        } else {
            return FetchResult.Error(NSLocalizedString("Error: URL not matched", comment: "Retrieved a json file that is no longer relevant for the app."))
        }
    }

    func fetchJsonForBarcode(barcode: BarcodeType) -> FetchJsonResult {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let fetchUrl = NSURL(string: "\(OpenFoodFacts.APIURLPrefixForProduct + barcode.asString() + OpenFoodFacts.JSONExtension)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        if let url = fetchUrl {
            do {
                let data = try NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                return FetchJsonResult.Success(data)
            } catch let error as NSError {
                print(error);
                return FetchJsonResult.Error(error.description)
            }
        } else {
            return FetchJsonResult.Error(NSLocalizedString("Error: URL not matched", comment: "Retrieved a json file that is no longer relevant for the app."))
        }
    }

    func fetchSampleProduct() -> FetchResult {
        let filePath  = NSBundle.mainBundle().pathForResource(OpenFoodFacts.sampleProductBarcode, ofType:OpenFoodFacts.JSONExtension)
        let data = NSData(contentsOfFile:filePath!)
        if let validData = data {
            return unpackJSONObject(JSON.parse(validData))
        } else {
            return FetchResult.Error(NSLocalizedString("Error: No valid data", comment: "No valid data has been received"))
        }
    }
    
    // JSON keys

    private struct OFFJson {
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
        static let IngredientsNKey = "ingredients_n"
        static let NutrimentsKey = "nutriments"
        
        //static let struct Sodium {
        //    static let Key = "sodium"
        //    static let Text = "Sodium"
        //}
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
        //static let SugarsUnitKey = "sugars_unit"
        //static let FatServingKey = "fat_serving"
        //static let SodiumUnitKey = "sodium_unit"
        //static let Sugars100gKey = "sugars_100g"
        //static let SaturatedFatUnitKey = "saturated-fat_unit"
        //static let Sodium100gKey = "sodium_100g"
        //static let SaturatedFatServingKey = "saturated-fat_serving"
        //static let FiberUnitKey = "fiber_unit"
        //static let EnergyKey = "energy"
        //static let EnergyUnitKey = "energy_unit"
        //static let SugarsServingKey = "sugars_serving"
        //static let Carbohydrates100gKey = "carbohydrates_100g"
        //static let NutritionScoreUkKey = "nutrition-score-uk"
        //static let FiberServingKey = "fiber_serving"
        //static let CarbohydratesServingKey = "carbohydrates_serving"
        //static let EnergyServingKey = "energy_serving"
        //static let Fat100gKey = "fat_100g"
        //static let SaturatedFat100gKey = "saturated-fat_100g"
        static let NutritionScoreUk100gKey = "nutrition-score-uk_100g"
        //static let FiberKey = "fiber"
        //static let SaltServingKey = "salt_serving"
        //static let Salt100gKey = "salt_100g"
        //static let CarbohydratesKey = "carbohydrates"
        //static let Fiber100gKey = "fiber_100g"
        //static let Energy100gKey = "energy_100g"
        //static let saturatedFatKey = "saturated-fat"
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
        static let ManufacturingPlacesTags = "manufacturing_places_tags"
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
    
    func unpackJSONObject(jsonObject: JSON?) -> FetchResult {
        
        // All the fields available in the barcode.json are listed below
        // Those that are not used at the moment are edited out
        
        struct ingredientsElement {
            var text: String? = nil
            var id: String? = nil
            var rank: Int? = nil
        }

        if let resultStatus = jsonObject?[OFFJson.StatusKey]?.int {
            if resultStatus == 0 {
                // barcode NOT found in database
                // There is nothing more to decode
                if let statusVerbose = jsonObject?[OFFJson.StatusVerboseKey]?.string {
                    return FetchResult.Error(statusVerbose)
                } else {
                    return FetchResult.Error(NSLocalizedString("Error: No verbose status", comment: "The JSON file is wrongly formatted."))
                }
                
            } else if resultStatus == 1 {
            // barcode exists in OFF database
                let product = FoodProduct()
                product.barcode.string(jsonObject?[OFFJson.CodeKey]?.string)
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LastEditDatesTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsHierarchyKey]?.stringArray
                product.mainUrlThumb = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontSmallUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IIdKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsDebugTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesHierarchyKey]?.stringArray
                    // = jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups1Key]?.string
                decodeCompletionStates(jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesTagsKey]?.stringArray, product:product)
                decodeLastEditDates(jsonObject?[OFFJson.ProductKey]?[OFFJson.LastEditDatesTagsKey]?.stringArray, forProduct:product)
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CheckersTagsKey]?.stringArray
                product.labelArray = decodeGlobalLabels(jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsTagsKey]?.stringArray)
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageSmallUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ProductCodeKey]?.string

                product.traces = decodeAllergens(jsonObject?[OFFJson.ProductKey]?[OFFJson.TracesTagsKey]?.stringArray)

                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesTagsNKey]?.stringArray
                product.primaryLanguage = jsonObject?[OFFJson.ProductKey]?[OFFJson.LangKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.PhotographersKey]?.stringArray
                product.commonName = jsonObject?[OFFJson.ProductKey]?[OFFJson.GenericNameKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsThatMayBeFromPalmOilTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesPrevNKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.KeywordsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.RevKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.EditorsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.InterfaceVersionCreatedKey]?.date
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.MaxImgidKey]?.string
                
                product.additives = decodeAdditives(jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesTagsKey]?.stringArray)
                
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodesOrigKey]?.string
                product.informers = jsonObject?[OFFJson.ProductKey]?[OFFJson.InformersTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsTagsKey]?.stringArray
                product.photographers = jsonObject?[OFFJson.ProductKey]?[OFFJson.PhotographersTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesNKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups2TagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.UnknownNutrientsTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesPrevTagsKey]?.stringArray
                product.packagingArray = jsonObject?[OFFJson.ProductKey]?[OFFJson.PackagingTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ManufacturingPlacesKey]?.stringArray
                product.numberOfIngredients = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsNKey]?.string
                
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SodiumKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreFr100gKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SodiumServingKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreFrKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SodiumUnitKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Sodium100gKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreUkKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreUk100gKey]?.int
                
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.CarbohydratesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Fiber100gKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Energy100gKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.saturatedFatKey]?.string
                product.countryArray(decodeCountries(jsonObject?[OFFJson.ProductKey]?[OFFJson.CountriesTagsKey]?.stringArray))
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsFromPalmOilTagsKey]?.stringArray
                product.purchaseLocationElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.PurchasePlacesTagsKey]?.stringArray)
                product.producerCode = jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodesTagsKey]?.stringArray
                product.brandsArray = jsonObject?[OFFJson.ProductKey]?[OFFJson.BrandsTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.PurchasePlacesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups2Key]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CountriesHierarchyKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.TracesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesOldTagsKey]?.stringArray
                product.nutritionFactsImageUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageNutritionUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsTextDebugKey]?.string
                product.ingredients = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsTextKey]?.string
                product.editors = jsonObject?[OFFJson.ProductKey]?[OFFJson.EditorsTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsPrevTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesOldNKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesPrevHierarchyKey]?.stringArray
                product.additionDate = jsonObject?[OFFJson.ProductKey]?[OFFJson.CreatedTKey]?.time
                product.name = jsonObject?[OFFJson.ProductKey]?[OFFJson.ProductNameKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsFromOrThatMayBeFromPalmOilNKey]?.int
                product.creator = jsonObject?[OFFJson.ProductKey]?[OFFJson.CreatorKey]?.string
                product.mainUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontUrlKey]?.nsurl
                product.servingSize = jsonObject?[OFFJson.ProductKey]?[OFFJson.ServingSizeKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CompletedTKey]?.time
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LastModifiedByKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NewAdditivesNKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesPrevTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.OriginsKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionGradesKey]?.string
            
                var grade: NutritionalGradeLevel = .Undefined
                grade.string(jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionGradeFrKey]?.string)
                product.nutritionGrade = grade
            
            
                let nutrientLevelsSalt = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsSaltKey]?.string
                let nutrientLevelsFat = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsFatKey]?.string
                let nutrientLevelsSaturatedFat = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsSaturatedFatKey]?.string
                let nutrientLevelsSugars = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsSugarsKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesPrevKey]?.string
                product.stores = jsonObject?[OFFJson.ProductKey]?[OFFJson.StoresTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IdKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CountriesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontThumbUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.TracesHierarchyKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.InterfaceVersionModifiedKey]?.date
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.FruitsVegetablesNuts100gEstimateKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.SortkeyKey]?.date
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageNutritionThumbUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LastModifiedTKey]?.time
                product.imageIngredientsUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageIngredientsUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionScoreDebugKey]?.string
                product.imageNutritionSmallUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageNutritionSmallUrlKey]?.nsurl
                product.correctors = jsonObject?[OFFJson.ProductKey]?[OFFJson.CorrectorsTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CorrectorsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesDebugTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.BrandsKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CodesTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.InformersKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.EntryDatesTagsKey]?.stringArray
                product.imageIngredientsSmallUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageIngredientsSmallUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionGradesTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.PackagingKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ServingQuantityKey]?.double
                product.ingredientsOriginElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.OriginsTagsKey]?.stringArray)
                product.producerElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.ManufacturingPlacesTags]?.stringArray)
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionDataPerKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CitiesTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodes20141016Key]?.string
                product.categories = decodeCategories(jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesTagsKey]?.stringArray)
                product.quantity = jsonObject?[OFFJson.ProductKey]?[OFFJson.QuantityKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsPrevHierarchyKey]?.stringArray
                product.expirationDate = decodeDate(jsonObject?[OFFJson.ProductKey]?[OFFJson.ExpirationDateKey]?.string)
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesHierarchyKey]?.stringArray
//                if let allergenArray = jsonObject?[OFFJson.ProductKey]?[OFFJson.AllergensTagsKey]?.stringArray {
//                    product.allergens = [[:]]
//                    for allergen in allergenArray {
//                        let elementsArray = allergen.characters.split{$0 == ":"}.map(String.init)
//                        product.allergens!.append([elementsArray[0]:elementsArray[1]])
//                    }
//                }
                product.allergens = decodeAllergens(jsonObject?[OFFJson.ProductKey]?[OFFJson.AllergensTagsKey]?.stringArray)
                
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsThatMayBeFromPalmOilNKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageIngredientsThumbUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsFromPalmOilNKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsKey]?.array
                
                if let ingredientsJSON = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsKey]?.array {
                    var ingredients: [ingredientsElement] = []
                    for ingredientsJSONElement in ingredientsJSON {
                        var element = ingredientsElement()
                        element.text = ingredientsJSONElement[OFFJson.IngredientsElementTextKey]?.string
                        element.id = ingredientsJSONElement[OFFJson.IngredientsElementIdKey]?.string
                        element.rank = ingredientsJSONElement[OFFJson.IngredientsElementRankKey]?.int
                        ingredients.append(element)
                    }
                }
            
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LcKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsDebugKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups1TagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CheckersKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CompleteKey]?.int
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesDebugTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsIdsDebugKey]?.stringArray

                var nutritionLevelQuantity = NutritionLevelQuantity.Undefined
                nutritionLevelQuantity.string(nutrientLevelsFat)
                let fatNutritionScore = (NutritionItem.Fat, nutritionLevelQuantity)
                nutritionLevelQuantity.string(nutrientLevelsSaturatedFat)
                let saturatedFatNutritionScore = (NutritionItem.SaturatedFat, nutritionLevelQuantity)
                nutritionLevelQuantity.string(nutrientLevelsSugars)
                let sugarNutritionScore = (NutritionItem.Sugar, nutritionLevelQuantity)
                nutritionLevelQuantity.string(nutrientLevelsSalt)
                let saltNutritionScore = (NutritionItem.Salt, nutritionLevelQuantity)
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
                }
           
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
                nutritionDecode(NutritionFacts.SodiumKey, key: OFFJson.SodiumKey, jsonObject: jsonObject, product: product)
                nutritionDecode(NutritionFacts.SaltKey, key: OFFJson.SaltKey, jsonObject: jsonObject, product: product)
                
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
                
                return FetchResult.Success(product)
            } else {
                return FetchResult.Error(NSLocalizedString("Error: Other (>1) result status", comment: "A JSON status which is not supported."))
            }
        } else {
            return FetchResult.Error(NSLocalizedString("Error: No result status in JSON", comment: "Error message when the json input file does not contain any information") )
        }
    }
    
    private func nutritionDecode(fact: String, key: String, jsonObject: JSON?, product: FoodProduct) {
        
        struct Appendix {
            static let HunderdKey = "_100g"
            static let ServingKey = "_serving"
            static let UnitKey = "_unit"
        }
        var nutritionItem = NutritionFactItem()
        let preferredLanguage = NSLocale.preferredLanguages()[0]
        nutritionItem.key = key
        nutritionItem.itemName = OFFplists.manager.translateNutrients(key, language:preferredLanguage)
        nutritionItem.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[key+Appendix.UnitKey]?.string
        if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[key+Appendix.HunderdKey]?.string {
            if let unit = nutritionItem.standardValueUnit {
                // print("value \(value) ; unit \(unit)")
                if unit == "mg" {
                    // is the value translatable to a number?
                    if let doubleValue = Double(value) {
                        nutritionItem.standardValue = "\( doubleValue * 1000)"
                    } else {
                        nutritionItem.standardValue = value
                    }
                } else {
                    nutritionItem.standardValue = value
                }
            }
        } else if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[key]?.string {
            nutritionItem.standardValue = value
        } else {
            return
        }
        nutritionItem.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[key+Appendix.ServingKey]?.string
        
        product.nutritionFacts.append(nutritionItem)
    }
    
    private struct StateCompleteKey {
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
    
    private func decodeAdditives(additives: [String]?) -> [String]? {
        if let adds = additives {
            var translatedAdds:[String]? = []
            let preferredLanguage = NSLocale.preferredLanguages()[0]
            for add in adds {
                translatedAdds!.append(OFFplists.manager.translateAdditives(add, language:preferredLanguage))
            }
            return translatedAdds
        }
        return nil
    }
    
    private func decodeAllergens(allergens: [String]?) -> [String]? {
        if let allergensArray = allergens {
            var translatedAllergens:[String]? = []
            let preferredLanguage = NSLocale.preferredLanguages()[0]
            for allergen in allergensArray {
                translatedAllergens!.append(OFFplists.manager.translateAllergens(allergen, language:preferredLanguage))
            }
            return translatedAllergens
        }
        return nil
    }

    private func decodeCountries(countries: [String]?) -> [String]? {
        if let countriesArray = countries {
            var translatedCountries:[String]? = []
            let preferredLanguage = NSLocale.preferredLanguages()[0]
            for country in countriesArray {
                translatedCountries!.append(OFFplists.manager.translateCountries(country, language:preferredLanguage))
            }
            return translatedCountries
        }
        return nil
    }

    private func decodeGlobalLabels(labels: [String]?) -> [String]? {
        if let labelsArray = labels {
            var translatedLabels:[String]? = []
            let preferredLanguage = NSLocale.preferredLanguages()[0]
            for label in labelsArray {
                translatedLabels!.append(OFFplists.manager.translateGlobalLabels(label, language:preferredLanguage))
            }
            return translatedLabels
        }
        return nil
    }
    
    private func decodeCategories(labels: [String]?) -> [String]? {
        if let labelsArray = labels {
            var translatedTags:[String]? = []
            let preferredLanguage = NSLocale.preferredLanguages()[0]
            for label in labelsArray {
                translatedTags!.append(OFFplists.manager.translateCategories(label, language:preferredLanguage))
            }
            return translatedTags
        }
        return nil
    }


    private func decodeCompletionStates(states: [String]?, product:FoodProduct) {
        if let statesArray = states {
            for currentState in statesArray {
                let preferredLanguage = NSLocale.preferredLanguages()[0]
                if currentState.containsString(StateCompleteKey.PhotosUploaded) {
                    product.state.photosUploadedComplete.value = true
                    product.state.photosUploadedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosUploaded, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.PhotosUploadedTBD) {
                    product.state.photosUploadedComplete.value =  false
                    product.state.photosUploadedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosUploadedTBD, language:preferredLanguage)
                    

                } else if currentState.containsString(StateCompleteKey.ProductName) {
                    product.state.productNameComplete.value =  true
                    product.state.productNameComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ProductName, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.ProductNameTBD) {
                    product.state.productNameComplete.value =  false
                    product.state.productNameComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ProductNameTBD, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.Brands) {
                    product.state.brandsComplete.value =  true
                    product.state.brandsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Brands, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.BrandsTBD) {
                    product.state.brandsComplete.value =  false
                    product.state.brandsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.BrandsTBD, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.Quantity) {
                    product.state.quantityComplete.value =  true
                    product.state.quantityComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Quantity, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.QuantityTBD) {
                    product.state.quantityComplete.value =  false
                    product.state.quantityComplete.text = OFFplists.manager.translateStates(StateCompleteKey.QuantityTBD, language:preferredLanguage)

                } else if currentState.containsString(StateCompleteKey.Packaging) {
                    product.state.packagingComplete.value = true
                    product.state.packagingComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Packaging, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.PackagingTBD) {
                    product.state.packagingComplete.value = false
                    product.state.packagingComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PackagingTBD, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.Categories) {
                    product.state.categoriesComplete.value = true
                    product.state.categoriesComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Categories, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.CategoriesTBD) {
                    product.state.categoriesComplete.value = false
                    product.state.categoriesComplete.text = OFFplists.manager.translateStates(StateCompleteKey.CategoriesTBD, language:preferredLanguage)

                } else if currentState.containsString(StateCompleteKey.NutritionFacts) {
                    product.state.nutritionFactsComplete.value = true
                    product.state.nutritionFactsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.NutritionFacts, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.NutritionFactsTBD) {
                    product.state.nutritionFactsComplete.value = false
                    product.state.nutritionFactsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.NutritionFactsTBD, language:preferredLanguage)

                } else if currentState.containsString(StateCompleteKey.PhotosValidated) {
                    product.state.photosValidatedComplete.value = true
                    product.state.photosValidatedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosValidated, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.PhotosValidatedTBD) {
                    product.state.photosValidatedComplete.value = false
                    product.state.photosValidatedComplete.text = OFFplists.manager.translateStates(StateCompleteKey.PhotosValidatedTBD, language:preferredLanguage)

                } else if currentState.containsString(StateCompleteKey.Ingredients) {
                    product.state.ingredientsComplete.value = true
                    product.state.ingredientsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.Ingredients, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.IngredientsTBD) {
                    product.state.ingredientsComplete.value = false
                    product.state.ingredientsComplete.text = OFFplists.manager.translateStates(StateCompleteKey.IngredientsTBD, language:preferredLanguage)

                } else if currentState.containsString(StateCompleteKey.ExpirationDate) {
                    product.state.expirationDateComplete.value = true
                    product.state.expirationDateComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ExpirationDate, language:preferredLanguage)
                    
                } else if currentState.containsString(StateCompleteKey.ExpirationDateTBD) {
                    product.state.expirationDateComplete.value = false
                    product.state.expirationDateComplete.text = OFFplists.manager.translateStates(StateCompleteKey.ExpirationDateTBD, language:preferredLanguage)
                }
            }
        }
    }
    
    private func decodeLastEditDates(editDates: [String]?, forProduct:FoodProduct) {
        if let dates = editDates {
            var uniqueDates = Set<NSDate>()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = NSLocale(localeIdentifier: "EN_en")
            // use only valid dates
            for date in dates {
                // a valid date format is 2014-07-20
                // I do no want the shortened dates in the array
                if date.rangeOfString( "...-..-..", options: .RegularExpressionSearch) != nil {
                    if let newDate = dateFormatter.dateFromString(date) {
                        uniqueDates.insert(newDate)
                    }
                }
            }
            
            forProduct.lastEditDates = uniqueDates.sort { $0.compare($1) == .OrderedAscending }
        }
    }

    private func decodeDate(date: String?) -> NSDate? {
        if let validDate = date {
            let dateFormatter = NSDateFormatter()
            // dateFormatter.locale = NSLocale(localeIdentifier: "EN_en")
            // a valid date format is 20/07/2014
            // but othe formats are possible
            if validDate.rangeOfString( "../../....", options: .RegularExpressionSearch) != nil {
                dateFormatter.dateFormat = "dd/MM/yyyy"
                if let newDate = dateFormatter.dateFromString(validDate) {
                    
                    return newDate
                }
            }
        }
        return nil
    }


    // This function splits an element in an array in a language and value part
    func splitLanguageElements(inputArray: [String]?) -> [[String: String]]? {
        if let elementsArray = inputArray {
            if !elementsArray.isEmpty {
                var outputArray: [[String:String]] = []
                for element in elementsArray {
                    let elementsPair = element.characters.split{$0 == ":"}.map(String.init)
                    let dict = Dictionary(dictionaryLiteral: (elementsPair[0], elementsPair[1]))
                    outputArray.insert(dict, atIndex: 0)
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





