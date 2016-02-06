//
//  OpenFoodFactsRequest.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class OpenFoodFactsRequest {

    var product = FoodProduct()
    
    private var jsonProduct = jsonProductParameter()
    
    private struct OpenFoodFacts {
        static let JSONExtension = ".json"
        static let APIURLPrefixForProduct = "http://world.openfoodfacts.org/api/v0/product/"
        static let testProductBarcode = "737628064502"
    }
    
    func fetchProductForBarcode(search: String) -> FoodProduct? {
        let fetchUrl = NSURL(string: "\(OpenFoodFacts.APIURLPrefixForProduct + search + OpenFoodFacts.JSONExtension)")
        // print("\(fetchUrl)")
        if let url = fetchUrl {
            do {
                let data = try NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let jsonObject = JSON.parse(data)
                let product = unpackProductJSON(jsonObject)
                return product
            } catch let error as NSError {
                print(error);
                return nil
            }
        } else {
            return nil
        }
    }

    func testWithLocalfile() -> FoodProduct? {
        let filePath  = NSBundle.mainBundle().pathForResource(OpenFoodFacts.testProductBarcode, ofType:OpenFoodFacts.JSONExtension)
        let data = NSData(contentsOfFile:filePath!)
        if let validData = data {
            let jsonObject = JSON.parse(validData)
            let product = unpackProductJSON(jsonObject)
            return product
        } else {
            return nil
        }
    }
    
    // debug println with identifying prefix
    
    private func log(whatToLog: AnyObject) {
        debugPrint("TwitterRequest: \(whatToLog)")
    }

    private struct jsonProductParameter {
        var status: Int? = nil
        var statusVerbose: String? = nil
        var product: NSDictionary? = nil
        // barcode of the product (can be EAN-13 or internal codes for some food stores), for products without a barcode, Open Food Facts assigns a number starting with the 200 reserved prefix
        // var code: String? = nil
        var lastEditDatesTags: [String]? = []
        var labelsHierarchy: [String]? = nil
        var imageFrontSmallUrl: NSURL? = nil
        var iid: String? = nil
        var labelsDebugTags: [String]? = nil
        var categoriesHierarchy: [String]? = nil
        var pnnsGroups1: String? = nil
        var statesTags: [String]? = nil
        var checkersTags: [String]? = nil
        var labelsTags: [String]? = nil
        var imageSmallUrl: NSURL? = nil
        var productCode: String? = nil
        var additivesTagsN: String? = nil
        var tracesTags: [String]? = nil
        var lang: String? = nil
        var photographers: [String]? = nil
        var genericName: String? = nil
        var ingredientsThatMayBeFromPalmOilTags: [String]? = nil
        var additivesPrevN: Int? = nil
        var keywords: [String]? = nil
        var rev: Int? = nil
        var editors: [String]? = nil
        var interfaceVersionCreated: NSDate? = nil
        var embCodes: String? = nil
        var maxImgid: String? = nil
        var additivesTags: [String]? = nil
        var embCodesOrig: String? = nil
        var informersTags: [String]? = nil
        var nutrientLevelsTags: [String]? = nil
        var photographersTags: [String]? = nil
        var additivesN: Int? = nil
        var pnnsGroups2Tags: [String]? = nil
        var unknownNutrientsTags: [String]? = nil
        var categoriesPrevTags: [String]? = nil
        var packagingTags: [String]? = nil
        var nutriments: NSDictionary? = nil
        var sodium: String? = nil
        var sugars: String? = nil
        var carbohydratesUnit: String? = nil
        var fatUnit: String? = nil
        var proteinsUnit: String? = nil
        var nutritionScoreFr100g: Int? = nil
        var fat: String? = nil
        var proteinsServing: String? = nil
        var sodiumServing: String? = nil
        var salt: String? = nil
        var proteins: String? = nil
        var nutritionScoreFr: Int? = nil
        var sugarsUnit: String? = nil
        var fatServing: String? = nil
        var sodiumUnit: String? = nil
        var sugars100g: String? = nil
        var saturatedFatUnit: String? = nil
        var sodium100g: String? = nil
        var saturatedFatServing: String? = nil
        var fiberUnit: String? = nil
        var energy: String? = nil
        var energyUnit: String? = nil
        var sugarsServing: String? = nil
        var carbohydrates100g: String? = nil
        var nutritionScoreUk: Int? = nil
        var proteins100g: String? = nil
        var fiberServing: String? = nil
        var carbohydratesServing: String? = nil
        var energyServing: String? = nil
        var fat100g: String? = nil
        var saturatedFat100g: String? = nil
        var nutritionScoreUk100g: Int? = nil
        var fiber: String? = nil
        var saltServing: String? = nil
        var salt100g: String? = nil
        var carbohydrates: String? = nil
        var fiber100g: String? = nil
        var energy100g: String? = nil
        var saturatedFat: String? = nil
        var countriesTags: [String]? = nil
        var ingredientsFromPalmOilTags: [String]? = nil
        var embCodesTags: [String]? = nil
        var brandsTags: [String]? = nil
        var purchasePlaces: String? = nil
        var pnnsGroups2: String? = nil
        var countriesHierarchy: [String]? = nil
        var traces: String? = nil
        var additivesOldTags: [String]? = nil
        var imageNutritionUrl: NSURL? = nil
        var categories: String? = nil
        var ingredientsTextDebug: String? = nil
        var ingredientsText: String? = nil
        var editorsTags: [String]? = nil
        var labelsPrevTags: [String]? = nil
        var additivesOldN: Int? = nil
        var categoriesPrevHierarchy: [String]? = nil
        var createdT: NSDate? = nil
        var productName: String? = nil
        var ingredientsFromOrThatMayBeFromPalmOilN: Int? = nil
        var creator: String? = nil
        var imageFrontUrl: NSURL? = nil
        var servingSize: String? = nil
        var completedT: NSDate? = nil
        var lastModifiedBy: String? = nil
        var newAdditivesN: Int? = nil
        var additivesPrevTags: [String]? = nil
        var origins: String? = nil
        var stores: String? = nil
        var nutritionGrades: String? = nil
        var nutritionGradeFr: String? = nil
        var nutrientLevels: NSDictionary? = nil
        var nutrientLevelsSalt: String? = nil
        var nutrientLevelsFat: String? = nil
        var nutrientLevelsSaturatedFat: String? = nil
        var nutrientLevelsSugars: String? = nil
        var additivesPrev: String? = nil
        var storesTags: [String]? = nil
        var id: String? = nil
        var countries: String? = nil
        var imageFrontThumbUrl: NSURL? = nil
        var purchasePlacesTags: [String]? = nil
        var tracesHierarchy: [String]? = nil
        var interfaceVersionModified: NSDate? = nil
        var fruitsVegetablesNuts100gEstimate: Int? = nil
        var imageThumbUrl: NSURL? = nil
        var sortkey: NSDate? = nil
        var imageNutritionThumbUrl: NSURL? = nil
        var lastModifiedT: NSDate? = nil
        var imageIngredientsUrl: NSURL? = nil
        var nutritionScoreDebug: String? = nil
        var imageNutritionSmallUrl: NSURL? = nil
        var correctorsTags: [String]? = nil
        var correctors: [String]? = nil
        var categoriesDebugTags: [String]? = nil
        var brands: String? = nil
        var ingredientsTags: [String]? = nil
        var codesTags: [String]? = nil
        var states: String? = nil
        var informers: [String]? = nil
        var entryDatesTags: [String]? = nil
        var imageIngredientsSmallUrl: NSURL? = nil
        var nutritionGradesTags: [String]? = nil
        var packaging: String? = nil
        var servingQuantity: Double? = nil
        var originsTags: [String]? = nil
        var nutritionDataPer: String? = nil
        var labels: String? = nil
        var citiesTags: [String]? = nil
        var embCodes20141016: String? = nil
        var categoriesTags: [String]? = nil
        var quantity: String? = nil
        var labelsPrevHierarchy: [String]? = nil
        var expirationDate: NSDate? = nil
        var statesHierarchy: [String]? = nil
        var ingredientsThatMayBeFromPalmOilN: Int? = nil
        var imageIngredientsThumbUrl: NSURL? = nil
        var ingredientsFromPalmOilN: Int? = nil
        var imageUrl: NSURL? = nil
        var ingredientsJSON: [JSON]? = nil
        var ingredients: [ingredientsElement]? = nil
        var lc: String? = nil
        var ingredientsDebug: [String]? = nil
        var pnnsGroups1Tags: [String]? = nil
        var checkers: [String]? = nil
        var additives: String? = nil
        var complete: Int? = nil
        var additivesDebugTags: [String]? = nil
        var ingredientsIdsDebug: [String]? = nil
   }
    struct ingredientsElement {
        var text: String? = nil
        var id: String? = nil
        var rank: Int? = nil

    }
    
    // constants

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
        static let NutritionDataPerKey = "nutrition_data_per"
        static let LabelsKey = "labels"
        static let CitiesTagsKey = "cities_tags"
        static let EmbCodes20141016Key = "emb_codes_20141016"
        static let CategoriesTagsKey = "categories_tags"
        static let QuantityKey = "quantity"
        static let LabelsPrevHierarchyKey = "labels_prev_hierarchy"
        static let ExpirationDateKey = "expiration_date"
        static let StatesHierarchyKey = "states_hierarchy"
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
    
    func unpackProductJSON(jsonObject: JSON?) -> FoodProduct {
        
        // All the fields available in the barcode.json are listed below
        // Those that are not used at the moment are edited out
        
//        jsonProduct.status = jsonObject?[OFFJson.StatusKey]?.int
//        jsonProduct.statusVerbose = jsonObject?[OFFJson.StatusVerboseKey]?.string
            product.barcode.string(jsonObject?[OFFJson.CodeKey]?.string)
//         jsonProduct.lastEditDatesTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.LastEditDatesTagsKey]?.stringArray
//         jsonProduct.labelsHierarchy = jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsHierarchyKey]?.stringArray
//         jsonProduct.imageFrontSmallUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontSmallUrlKey]?.nsurl
//         jsonProduct.iid = jsonObject?[OFFJson.ProductKey]?[OFFJson.IIdKey]?.string
        // jsonProduct.labelsDebugTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsDebugTagsKey]?.stringArray
        // jsonProduct.categoriesHierarchy = jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesHierarchyKey]?.stringArray
        // jsonProduct.pnnsGroups1 = jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups1Key]?.string
        // jsonProduct.statesTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesTagsKey]?.stringArray
        // jsonProduct.checkersTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.CheckersTagsKey]?.stringArray
        // jsonProduct.labelsTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsTagsKey]?.stringArray
        // jsonProduct.imageSmallUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageSmallUrlKey]?.nsurl
        // jsonProduct.productCode = jsonObject?[OFFJson.ProductKey]?[OFFJson.ProductCodeKey]?.string
        product.traces = jsonObject?[OFFJson.ProductKey]?[OFFJson.TracesTagsKey]?.stringArray
        product.allergens = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesTagsNKey]?.stringArray
        // jsonProduct.lang = jsonObject?[OFFJson.ProductKey]?[OFFJson.LangKey]?.string
        // jsonProduct.photographers = jsonObject?[OFFJson.ProductKey]?[OFFJson.PhotographersKey]?.stringArray
        product.commonName = jsonObject?[OFFJson.ProductKey]?[OFFJson.GenericNameKey]?.string
        // jsonProduct.ingredientsThatMayBeFromPalmOilTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsThatMayBeFromPalmOilTagsKey]?.stringArray
        // jsonProduct.additivesPrevN = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesPrevNKey]?.int
        // jsonProduct.keywords = jsonObject?[OFFJson.ProductKey]?[OFFJson.KeywordsKey]?.stringArray
        // jsonProduct.rev = jsonObject?[OFFJson.ProductKey]?[OFFJson.RevKey]?.int
        // jsonProduct.editors = jsonObject?[OFFJson.ProductKey]?[OFFJson.EditorsKey]?.stringArray
        // jsonProduct.interfaceVersionCreated = jsonObject?[OFFJson.ProductKey]?[OFFJson.InterfaceVersionCreatedKey]?.date
        // jsonProduct.embCodes = jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodesKey]?.string
        // jsonProduct.maxImgid = jsonObject?[OFFJson.ProductKey]?[OFFJson.MaxImgidKey]?.string
        product.additives = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesTagsKey]?.stringArray
        // jsonProduct.embCodesOrig = jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodesOrigKey]?.string
        // jsonProduct.informersTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.InformersTagsKey]?.stringArray
        // jsonProduct.nutrientLevelsTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsTagsKey]?.stringArray
        // jsonProduct.photographersTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.PhotographersKey]?.stringArray
        // jsonProduct.additivesN = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesNKey]?.int
        // jsonProduct.pnnsGroups2Tags = jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups2TagsKey]?.stringArray
        // jsonProduct.unknownNutrientsTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.UnknownNutrientsTagsKey]?.stringArray
        // jsonProduct.categoriesPrevTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesPrevTagsKey]?.stringArray
            product.container = jsonObject?[OFFJson.ProductKey]?[OFFJson.PackagingTagsKey]?.stringArray
            jsonProduct.sodium = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SodiumKey]?.string
            jsonProduct.sugars = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SugarsKey]?.string
            jsonProduct.carbohydratesUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.CarbohydratesUnitKey]?.string
            jsonProduct.fatUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FatUnitKey]?.string
            jsonProduct.proteinsUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.ProteinsUnitKey]?.string
        jsonProduct.nutritionScoreFr100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreFr100gKey]?.int
        jsonProduct.fat = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FatKey]?.string
        jsonProduct.proteinsServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.ProteinsServingKey]?.string
        jsonProduct.sodiumServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SodiumServingKey]?.string
        jsonProduct.salt = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaltKey]?.string
        jsonProduct.proteins = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.ProteinsKey]?.string
        // jsonProduct.nutritionScoreFr = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreFrKey]?.int
        jsonProduct.sugarsUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SugarsUnitKey]?.string
        jsonProduct.fatServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FatServingKey]?.string
        // jsonProduct.sodiumUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SodiumUnitKey]?.string
        jsonProduct.sugars100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Sugars100gKey]?.string
        jsonProduct.saturatedFatUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaturatedFatUnitKey]?.string
//        jsonProduct.sodium100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Sodium100gKey]?.string
        jsonProduct.saturatedFatServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaturatedFatServingKey]?.string
        jsonProduct.fiberUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FiberUnitKey]?.string
        jsonProduct.energy = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.EnergyKey]?.string
        jsonProduct.energyUnit = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.EnergyUnitKey]?.string
        jsonProduct.sugarsServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SugarsServingKey]?.string
        jsonProduct.carbohydrates100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Carbohydrates100gKey]?.string
//        jsonProduct.nutritionScoreUk = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreUkKey]?.int
        jsonProduct.proteins100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Proteins100gKey]?.string
        jsonProduct.fiberServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FiberServingKey]?.string
        jsonProduct.carbohydratesServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.CarbohydratesServingKey]?.string
        jsonProduct.energyServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.EnergyServingKey]?.string
        jsonProduct.fat100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Fat100gKey]?.string
        jsonProduct.saturatedFat100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaturatedFat100gKey]?.string
        jsonProduct.nutritionScoreUk100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.NutritionScoreUk100gKey]?.int
        jsonProduct.fiber = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.FiberKey]?.string
        jsonProduct.saltServing = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.SaltServingKey]?.string
        jsonProduct.salt100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Salt100gKey]?.string
//        jsonProduct.carbohydrates = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.CarbohydratesKey]?.string
//        jsonProduct.fiber100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Fiber100gKey]?.string
//        jsonProduct.energy100g = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.Energy100gKey]?.string
//        jsonProduct.saturatedFat = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrimentsKey]?[OFFJson.saturatedFatKey]?.string
            product.countries = jsonObject?[OFFJson.ProductKey]?[OFFJson.CountriesTagsKey]?.stringArray
//        jsonProduct.ingredientsFromPalmOilTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsFromPalmOilTagsKey]?.stringArray
            product.purchaseLocation = jsonObject?[OFFJson.ProductKey]?[OFFJson.PurchasePlacesTagsKey]?.stringArray
//        jsonProduct.embCodesTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodesTagsKey]?.stringArray
        product.brand = jsonObject?[OFFJson.ProductKey]?[OFFJson.BrandsTagsKey]?.stringArray
//        jsonProduct.purchasePlaces = jsonObject?[OFFJson.ProductKey]?[OFFJson.PurchasePlacesKey]?.string
//        jsonProduct.pnnsGroups2 = jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups2Key]?.string
//        jsonProduct.countriesHierarchy = jsonObject?[OFFJson.ProductKey]?[OFFJson.CountriesHierarchyKey]?.stringArray
//        jsonProduct.traces = jsonObject?[OFFJson.ProductKey]?[OFFJson.TracesKey]?.string
//        jsonProduct.additivesOldTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesOldTagsKey]?.stringArray
//        jsonProduct.imageNutritionUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageNutritionUrlKey]?.nsurl
//        jsonProduct.categories = jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesKey]?.string
//        jsonProduct.ingredientsTextDebug = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsTextDebugKey]?.string
            product.ingredients = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsTextKey]?.string
//        jsonProduct.editorsTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.EditorsTagsKey]?.stringArray
//        jsonProduct.labelsPrevTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsPrevTagsKey]?.stringArray
//        jsonProduct.additivesOldN = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesOldNKey]?.int
//        jsonProduct.categoriesPrevHierarchy = jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesPrevHierarchyKey]?.stringArray
            product.additionDate = jsonObject?[OFFJson.ProductKey]?[OFFJson.CreatedTKey]?.time
            product.name = jsonObject?[OFFJson.ProductKey]?[OFFJson.ProductNameKey]?.string
//        jsonProduct.ingredientsFromOrThatMayBeFromPalmOilN = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsFromOrThatMayBeFromPalmOilNKey]?.int
            product.additionUser = jsonObject?[OFFJson.ProductKey]?[OFFJson.CreatorKey]?.string
//        jsonProduct.imageFrontUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontUrlKey]?.nsurl
            product.servingSize = jsonObject?[OFFJson.ProductKey]?[OFFJson.ServingSizeKey]?.string
//        jsonProduct.completedT = jsonObject?[OFFJson.ProductKey]?[OFFJson.CompletedTKey]?.time
//        jsonProduct.lastModifiedBy = jsonObject?[OFFJson.ProductKey]?[OFFJson.LastModifiedByKey]?.string
//        jsonProduct.newAdditivesN = jsonObject?[OFFJson.ProductKey]?[OFFJson.NewAdditivesNKey]?.int
//        jsonProduct.additivesPrevTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesPrevTagsKey]?.stringArray
//        jsonProduct.origins = jsonObject?[OFFJson.ProductKey]?[OFFJson.OriginsKey]?.string
//        jsonProduct.nutritionGrades = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionGradesKey]?.string
        
        jsonProduct.nutritionGradeFr = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionGradeFrKey]?.string
        var grade: FoodProduct.NutritionalGradeLevel = .Undefined
        grade.string(jsonProduct.nutritionGradeFr)
        product.nutritionGrade = grade
        
        
            jsonProduct.nutrientLevelsSalt = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsSaltKey]?.string
            jsonProduct.nutrientLevelsFat = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsFatKey]?.string
            jsonProduct.nutrientLevelsSaturatedFat = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsSaturatedFatKey]?.string
            jsonProduct.nutrientLevelsSugars = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutrientLevelsKey]?[OFFJson.NutrientLevelsSugarsKey]?.string
//        jsonProduct.additivesPrev = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesPrevKey]?.string
            product.stores = jsonObject?[OFFJson.ProductKey]?[OFFJson.StoresTagsKey]?.stringArray
//        jsonProduct.id = jsonObject?[OFFJson.ProductKey]?[OFFJson.IdKey]?.string
//        jsonProduct.countries = jsonObject?[OFFJson.ProductKey]?[OFFJson.CountriesKey]?.string
//        jsonProduct.imageFrontThumbUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontThumbUrlKey]?.nsurl
//        jsonProduct.tracesHierarchy = jsonObject?[OFFJson.ProductKey]?[OFFJson.TracesHierarchyKey]?.stringArray
//        jsonProduct.interfaceVersionModified = jsonObject?[OFFJson.ProductKey]?[OFFJson.InterfaceVersionModifiedKey]?.date
//        jsonProduct.fruitsVegetablesNuts100gEstimate = jsonObject?[OFFJson.ProductKey]?[OFFJson.FruitsVegetablesNuts100gEstimateKey]?.int
//        jsonProduct.imageThumbUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageFrontUrlKey]?.nsurl
//        jsonProduct.sortkey = jsonObject?[OFFJson.ProductKey]?[OFFJson.SortkeyKey]?.date
//        jsonProduct.imageNutritionThumbUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageNutritionThumbUrlKey]?.nsurl
//        jsonProduct.lastModifiedT = jsonObject?[OFFJson.ProductKey]?[OFFJson.LastModifiedTKey]?.time
//        jsonProduct.imageIngredientsUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageIngredientsUrlKey]?.nsurl
        jsonProduct.nutritionScoreDebug = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionScoreDebugKey]?.string
        jsonProduct.imageNutritionSmallUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageNutritionSmallUrlKey]?.nsurl
//        jsonProduct.correctorsTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.CorrectorsTagsKey]?.stringArray
//        jsonProduct.correctors = jsonObject?[OFFJson.ProductKey]?[OFFJson.CorrectorsKey]?.stringArray
//        jsonProduct.categoriesDebugTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesDebugTagsKey]?.stringArray
//        jsonProduct.brands = jsonObject?[OFFJson.ProductKey]?[OFFJson.BrandsKey]?.string
//        jsonProduct.ingredientsTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsTagsKey]?.stringArray
        jsonProduct.codesTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.CodesTagsKey]?.stringArray
//        jsonProduct.states = jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesKey]?.string
//        jsonProduct.informers = jsonObject?[OFFJson.ProductKey]?[OFFJson.InformersKey]?.stringArray
//        jsonProduct.entryDatesTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.EntryDatesTagsKey]?.stringArray
//        jsonProduct.imageIngredientsSmallUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageIngredientsSmallUrlKey]?.nsurl
        jsonProduct.nutritionGradesTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionGradesTagsKey]?.stringArray
//        jsonProduct.packaging = jsonObject?[OFFJson.ProductKey]?[OFFJson.PackagingKey]?.string
//        jsonProduct.servingQuantity = jsonObject?[OFFJson.ProductKey]?[OFFJson.ServingQuantityKey]?.double
//        jsonProduct.originsTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.OriginsTagsKey]?.stringArray
//        jsonProduct.nutritionDataPer = jsonObject?[OFFJson.ProductKey]?[OFFJson.NutritionDataPerKey]?.string
//        jsonProduct.labels = jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsKey]?.string
//        jsonProduct.citiesTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.CitiesTagsKey]?.stringArray
//        jsonProduct.embCodes20141016 = jsonObject?[OFFJson.ProductKey]?[OFFJson.EmbCodes20141016Key]?.string
            product.categories = jsonObject?[OFFJson.ProductKey]?[OFFJson.CategoriesTagsKey]?.stringArray
            product.quantity = jsonObject?[OFFJson.ProductKey]?[OFFJson.QuantityKey]?.string
//        jsonProduct.labelsPrevHierarchy = jsonObject?[OFFJson.ProductKey]?[OFFJson.LabelsPrevHierarchyKey]?.stringArray
//        jsonProduct.expirationDate = jsonObject?[OFFJson.ProductKey]?[OFFJson.ExpirationDateKey]?.date
//        jsonProduct.statesHierarchy = jsonObject?[OFFJson.ProductKey]?[OFFJson.StatesHierarchyKey]?.stringArray
//        jsonProduct.ingredientsThatMayBeFromPalmOilN = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsThatMayBeFromPalmOilNKey]?.int
//        jsonProduct.imageIngredientsThumbUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageIngredientsThumbUrlKey]?.nsurl
//        jsonProduct.ingredientsFromPalmOilN = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsFromPalmOilNKey]?.int
//        jsonProduct.imageUrl = jsonObject?[OFFJson.ProductKey]?[OFFJson.ImageUrlKey]?.nsurl
        
//        jsonProduct.ingredientsJSON = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsKey]?.array
        if let ingredientsJSON = jsonProduct.ingredientsJSON {
            jsonProduct.ingredients = []
            for ingredientsJSONElement in ingredientsJSON {
                var element = ingredientsElement()
                element.text = ingredientsJSONElement[OFFJson.IngredientsElementTextKey]?.string
                element.id = ingredientsJSONElement[OFFJson.IngredientsElementIdKey]?.string
                element.rank = ingredientsJSONElement[OFFJson.IngredientsElementRankKey]?.int
                jsonProduct.ingredients!.append(element)
            }
        }
        
//        jsonProduct.lc = jsonObject?[OFFJson.ProductKey]?[OFFJson.LcKey]?.string
//        jsonProduct.ingredientsDebug = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsDebugKey]?.stringArray
//        jsonProduct.pnnsGroups1Tags = jsonObject?[OFFJson.ProductKey]?[OFFJson.PnnsGroups1TagsKey]?.stringArray
//        jsonProduct.checkers = jsonObject?[OFFJson.ProductKey]?[OFFJson.CheckersKey]?.stringArray
//        jsonProduct.additives = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesKey]?.string
//        jsonProduct.complete = jsonObject?[OFFJson.ProductKey]?[OFFJson.CompleteKey]?.int
//        jsonProduct.additivesDebugTags = jsonObject?[OFFJson.ProductKey]?[OFFJson.AdditivesDebugTagsKey]?.stringArray
//        jsonProduct.ingredientsIdsDebug = jsonObject?[OFFJson.ProductKey]?[OFFJson.IngredientsIdsDebugKey]?.stringArray
        
        var nutritionLevelQuantity = FoodProduct.NutritionLevelQuantity.Undefined
        nutritionLevelQuantity.string(jsonProduct.nutrientLevelsFat)
        let fatNutritionScore = (FoodProduct.NutritionItem.Fat, nutritionLevelQuantity)
        nutritionLevelQuantity.string(jsonProduct.nutrientLevelsSaturatedFat)
        let saturatedFatNutritionScore = (FoodProduct.NutritionItem.SaturatedFat,nutritionLevelQuantity)
        nutritionLevelQuantity.string(jsonProduct.nutrientLevelsSugars)
        let sugarNutritionScore = (FoodProduct.NutritionItem.Sugar, nutritionLevelQuantity)
        nutritionLevelQuantity.string(jsonProduct.nutrientLevelsSalt)
        let saltNutritionScore = (FoodProduct.NutritionItem.Salt, nutritionLevelQuantity)
        product.nutritionScore = [fatNutritionScore, saturatedFatNutritionScore, sugarNutritionScore, saltNutritionScore]
        
        var energie = FoodProduct.NutritionFactItem()
        energie.itemName = "Energie"
        energie.servingValue = jsonProduct.energyServing
        energie.servingValueUnit = jsonProduct.energyUnit
        if let value = jsonProduct.energy100g {
            energie.standardValue = value
        } else if let value = jsonProduct.energy {
            energie.standardValue = value
        }
        energie.standardValueUnit = jsonProduct.energyUnit
        
        var fat = FoodProduct.NutritionFactItem()
        fat.itemName = "Fat"
        fat.servingValue = jsonProduct.fatServing
        fat.servingValueUnit = jsonProduct.fatUnit
        if let value = jsonProduct.fat100g {
            fat.standardValue = value
        } else if let value = jsonProduct.fat {
            fat.standardValue = value
        }
        fat.standardValueUnit = jsonProduct.fatUnit
        
        var saturatedFat = FoodProduct.NutritionFactItem()
        saturatedFat.itemName = "Saturated Fat"
        saturatedFat.servingValue = jsonProduct.saturatedFatServing
        saturatedFat.servingValueUnit = jsonProduct.saturatedFatUnit
        if let value = jsonProduct.saturatedFat100g {
            saturatedFat.standardValue = value
        } else if let value = jsonProduct.saturatedFat {
            saturatedFat.standardValue = value
        }
        saturatedFat.standardValueUnit = jsonProduct.saturatedFatUnit
        var carbohydrate = FoodProduct.NutritionFactItem()
        
        carbohydrate.itemName = "Carbohydrate"
        carbohydrate.servingValue = jsonProduct.carbohydratesServing
        carbohydrate.servingValueUnit = jsonProduct.carbohydratesUnit
        if let value = jsonProduct.carbohydrates100g {
            carbohydrate.standardValue = value
        } else if let value = jsonProduct.carbohydrates {
            carbohydrate.standardValue = value
        }
        carbohydrate.standardValueUnit = jsonProduct.carbohydratesUnit
        
        var sugars = FoodProduct.NutritionFactItem()
        sugars.itemName = "Sugars"
        sugars.servingValue = jsonProduct.sugarsServing
        sugars.servingValueUnit = jsonProduct.sugarsUnit
        if let value = jsonProduct.sugars100g {
            sugars.standardValue = value
        } else if let value = jsonProduct.sugars {
            sugars.standardValue = value
        }
        sugars.standardValueUnit = jsonProduct.sugarsUnit
        
        var fiber = FoodProduct.NutritionFactItem()
        fiber.itemName = "Fibers"
        fiber.servingValue = jsonProduct.fiberServing
        fiber.servingValueUnit = jsonProduct.fiberUnit
        if let value = jsonProduct.fiber100g {
            fiber.standardValue = value
        } else if let value = jsonProduct.fiber {
            fiber.standardValue = value
        }
        fiber.standardValueUnit = jsonProduct.fiberUnit

        fiber.standardValueUnit = jsonProduct.fiberUnit

        var protein = FoodProduct.NutritionFactItem()
        protein.itemName = "Protein"
        protein.servingValue = jsonProduct.proteinsServing
        protein.servingValueUnit = jsonProduct.proteinsUnit
        if let value = jsonProduct.proteins100g {
            protein.standardValue = value
        } else if let value = jsonProduct.proteins {
            protein.standardValue = value
        }
        protein.standardValueUnit = jsonProduct.proteinsUnit
        
        var salt = FoodProduct.NutritionFactItem()
        salt.itemName = "Salt"
        salt.servingValue = jsonProduct.saltServing
        salt.servingValueUnit = "g"
        if let value = jsonProduct.salt100g {
            salt.standardValue = value
        } else if let value = jsonProduct.salt {
            salt.standardValue = value
        }
        salt.standardValueUnit = "g"
        
        product.nutritionFacts = [energie, fat, saturatedFat, carbohydrate, sugars, fiber, protein, salt]
        
        return product
    }
    
}