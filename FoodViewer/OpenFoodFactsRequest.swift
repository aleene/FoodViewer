//
//  OpenFoodFactsRequest.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class OpenFoodFactsRequest {
    
    private struct OpenFoodFacts {
        static let JSONExtension = ".json"
        static let APIURLPrefixForProduct = "http://world.openfoodfacts.org/api/v0/product/"
        static let testProductBarcode = "3608580744184"
    }
    
    enum FetchResult {
        case Error(String)
        case Success(FoodProduct)
    }
    
    var fetched: FetchResult = .Error("Initialised")
    func fetchProductForBarcode(barcode: BarcodeType) -> FetchResult {
        let fetchUrl = NSURL(string: "\(OpenFoodFacts.APIURLPrefixForProduct + barcode.asString() + OpenFoodFacts.JSONExtension)")
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
            return FetchResult.Error("URL not matched")
        }
    }

    func testWithLocalfile() -> FetchResult {
        let filePath  = NSBundle.mainBundle().pathForResource(OpenFoodFacts.testProductBarcode, ofType:OpenFoodFacts.JSONExtension)
        let data = NSData(contentsOfFile:filePath!)
        if let validData = data {
            return unpackJSONObject(JSON.parse(validData))
        } else {
            return FetchResult.Error("No valid data")
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
        static let SodiumKey = "sodium"
        static let SugarsKey = "sugars"
        static let CarbohydratesUnitKey = "carbohydrates_unit"
        static let FatUnitKey = "fat_unit"
        static let ProteinsUnitKey = "proteins_unit"
        static let NutritionScoreFr100gKey = "nutrition-score-fr_100g"
        static let FatKey = "fat"
        static let ProteinsServingKey = "proteins_serving"
        static let SodiumServingKey = "sodium_serving"
        static let SaltKey = "salt"
        static let ProteinsKey = "proteins"
        static let NutritionScoreFrKey = "nutrition-score-fr"
        static let SugarsUnitKey = "sugars_unit"
        static let FatServingKey = "fat_serving"
        static let SodiumUnitKey = "sodium_unit"
        static let Sugars100gKey = "sugars_100g"
        static let SaturatedFatUnitKey = "saturated-fat_unit"
        static let Sodium100gKey = "sodium_100g"
        static let SaturatedFatServingKey = "saturated-fat_serving"
        static let FiberUnitKey = "fiber_unit"
        static let EnergyKey = "energy"
        static let EnergyUnitKey = "energy_unit"
        static let SugarsServingKey = "sugars_serving"
        static let Carbohydrates100gKey = "carbohydrates_100g"
        static let NutritionScoreUkKey = "nutrition-score-uk"
        static let Proteins100gKey = "proteins_100g"
        static let FiberServingKey = "fiber_serving"
        static let CarbohydratesServingKey = "carbohydrates_serving"
        static let EnergyServingKey = "energy_serving"
        static let Fat100gKey = "fat_100g"
        static let SaturatedFat100gKey = "saturated-fat_100g"
        static let NutritionScoreUk100gKey = "nutrition-score-uk_100g"
        static let FiberKey = "fiber"
        static let SaltServingKey = "salt_serving"
        static let Salt100gKey = "salt_100g"
        static let CarbohydratesKey = "carbohydrates"
        static let Fiber100gKey = "fiber_100g"
        static let Energy100gKey = "energy_100g"
        static let saturatedFatKey = "saturated-fat"
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
                    return FetchResult.Error("No verbose status")
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
                decodeCompletionStates(jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesTagsKey]?.stringArray, forProduct:product)
                
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CheckersTagsKey]?.stringArray
                product.labelArray = splitLanguageElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsTagsKey]?.stringArray)
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageSmallUrlKey]?.nsurl
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ProductCodeKey]?.string

                product.traces = splitLanguageElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.TracesTagsKey]?.stringArray)

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
                product.additives = splitLanguageElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesTagsKey]?.stringArray)
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
                product.countries = splitLanguageElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.CountriesTagsKey]?.stringArray)
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsFromPalmOilTagsKey]?.stringArray
                product.purchaseLocation = jsonObject?[OFFJson.ProductKey]?[OFFJson.PurchasePlacesTagsKey]?.stringArray
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
                product.ingredientsOrigin = jsonObject?[OFFJson.ProductKey]?[OFFJson.OriginsTagsKey]?.stringArray
                product.producer = jsonObject?[OFFJson.ProductKey]?[OFFJson.ManufacturingPlacesTags]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionDataPerKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.CitiesTagsKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodes20141016Key]?.string
                product.categories = splitLanguageElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesTagsKey]?.stringArray)
                product.quantity = jsonObject?[OFFJson.ProductKey]?[OFFJson.QuantityKey]?.string
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsPrevHierarchyKey]?.stringArray
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.ExpirationDateKey]?.date
                    // jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesHierarchyKey]?.stringArray
//                if let allergenArray = jsonObject?[OFFJson.ProductKey]?[OFFJson.AllergensTagsKey]?.stringArray {
//                    product.allergens = [[:]]
//                    for allergen in allergenArray {
//                        let elementsArray = allergen.characters.split{$0 == ":"}.map(String.init)
//                        product.allergens!.append([elementsArray[0]:elementsArray[1]])
//                    }
//                }
                    product.allergens = splitLanguageElements(jsonObject?[OFFJson.ProductKey]?[OFFJson.AllergensTagsKey]?.stringArray)
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
                    static let FatText = "Fat"
                    static let EnergyText = "Energy"
                    static let SaturatedFatText = "Saturated Fat"
                    static let CarbohydrateText = "Carbohydrates"
                    static let SugarsText = "Sugars"
                    static let FiberText = "Fibers"
                    static let ProteinText = "Protein"
                    static let SaltText = "Salt"
                    static let SaltUnit = "g"
                }
                var energie = FoodProduct.NutritionFactItem()
                energie.itemName = NutritionFacts.EnergyText
                energie.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.EnergyServingKey]?.string
                energie.standardValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.EnergyKey]?.string
                energie.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.EnergyUnitKey]?.string
    
                
                var fat = FoodProduct.NutritionFactItem()
                fat.itemName = NutritionFacts.FatText
                fat.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FatServingKey]?.string
                if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Fat100gKey]?.string {
                    fat.standardValue = value
                } else if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FatKey]?.string {
                    fat.standardValue = value
                }
                fat.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FatUnitKey]?.string
    
                var saturatedFat = FoodProduct.NutritionFactItem()
                saturatedFat.itemName = NutritionFacts.SaturatedFatText
                saturatedFat.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaturatedFatServingKey]?.string
                saturatedFat.standardValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaturatedFat100gKey]?.string
                saturatedFat.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaturatedFatUnitKey]?.string
                
                var carbohydrate = FoodProduct.NutritionFactItem()
                carbohydrate.itemName = NutritionFacts.CarbohydrateText
                carbohydrate.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.CarbohydratesServingKey]?.string
                carbohydrate.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.CarbohydratesUnitKey]?.string
    
                var sugars = FoodProduct.NutritionFactItem()
                sugars.itemName = NutritionFacts.SugarsText
                sugars.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SugarsServingKey]?.string
                if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Sugars100gKey]?.string {
                    sugars.standardValue = value
                } else if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SugarsKey]?.string {
                    sugars.standardValue = value
                }
                sugars.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SugarsUnitKey]?.string
    
                var fiber = FoodProduct.NutritionFactItem()
                fiber.itemName = NutritionFacts.FiberText
                fiber.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FiberServingKey]?.string
                fiber.standardValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FiberKey]?.string
                fiber.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FiberUnitKey]?.string
        
                var protein = FoodProduct.NutritionFactItem()
                protein.itemName = NutritionFacts.ProteinText
                protein.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.ProteinsServingKey]?.string
                if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Proteins100gKey]?.string {
                    protein.standardValue = value
                } else if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.ProteinsKey]?.string {
                    protein.standardValue = value
                }
                protein.standardValueUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.ProteinsUnitKey]?.string
    
                var salt = FoodProduct.NutritionFactItem()
                salt.itemName = NutritionFacts.SaltText
                salt.servingValue = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaltServingKey]?.string
                if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Salt100gKey]?.string {
                    salt.standardValue = value
                } else if let value = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaltKey]?.string {
                    salt.standardValue = value
                }
                salt.standardValueUnit = NutritionFacts.SaltUnit
    
                if energie.standardValue != nil {
                    product.nutritionFacts.append(energie)
                }
                if fat.standardValue != nil {
                    product.nutritionFacts.append(fat)
                }
                if saturatedFat.standardValue != nil {
                    product.nutritionFacts.append(saturatedFat)
                }
                if carbohydrate.standardValue != nil {
                    product.nutritionFacts.append(carbohydrate)
                }
                if sugars.standardValue != nil {
                    product.nutritionFacts.append(sugars)
                }
                if fiber.standardValue != nil {
                    product.nutritionFacts.append(fiber)
                }
                if protein.standardValue != nil {
                    product.nutritionFacts.append(protein)
                }
                if salt.standardValue != nil {
                    product.nutritionFacts.append(salt)
                }
                return FetchResult.Success(product)
            } else {
                return FetchResult.Error("Other (>1) result status")
            }
        } else {
            return FetchResult.Error("No result status in JSON")
        }
    }
    
    private struct StateCompleteKey {
        static let NutritionFacts = "en:nutrition-facts-completed"
        static let Ingredients = "en:ingredients-completed"
        static let ExpirationDate = "en:expiration-date-completed"
        static let PhotosValidated = "en:photos-validated"
        static let Categories = "en:categories-completed"
        static let Brands = "en:brands-completed"
        static let Packaging = "en:packaging-completed"
        static let Quantity = "en:quantity-completed"
        static let ProductName = "en:product-name-completed"
        static let PhotosUploaded = "en:photos-uploaded"
    }
    
    private func decodeCompletionStates(states: [String]?, forProduct:FoodProduct) {
        if let statesArray = states {
            for currentState in statesArray {
                if currentState.containsString(StateCompleteKey.PhotosUploaded) {
                    forProduct.state.photosUploadedComplete = true
                } else if currentState.containsString(StateCompleteKey.ProductName) {
                    forProduct.state.productNameComplete =  true
                } else if currentState.containsString(StateCompleteKey.Brands) {
                    forProduct.state.brandsComplete =  true
                } else if currentState.containsString(StateCompleteKey.Quantity) {
                    forProduct.state.quantityComplete =  true
                } else if currentState.containsString(StateCompleteKey.Packaging) {
                    forProduct.state.packagingComplete = true
                } else if currentState.containsString(StateCompleteKey.Categories) {
                    forProduct.state.categoriesComplete = true
                } else if currentState.containsString(StateCompleteKey.NutritionFacts) {
                    forProduct.state.nutritionFactsComplete = true
                } else if currentState.containsString(StateCompleteKey.PhotosValidated) {
                    forProduct.state.photosValidatedComplete = true
                } else if currentState.containsString(StateCompleteKey.Ingredients) {
                    forProduct.state.ingredientsComplete = true
                } else if currentState.containsString(StateCompleteKey.ExpirationDate) {
                    forProduct.state.expirationDateComplete = true
                }
            }
        }
    }

    // This function splits an element in an array in a language and value part
    func splitLanguageElements(inputArray: [String]?) -> [[String: String]]? {
        if let elementsArray = inputArray {
            if !elementsArray.isEmpty {
                var outputArray: [[String:String]] = [[:]]
                for element in elementsArray {
                    let elementsPair = element.characters.split{$0 == ":"}.map(String.init)
                    outputArray.append([elementsPair[0]:elementsPair[1]])
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





