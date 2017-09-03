//
//  OFF.swift
//  FoodViewer
//
//  Created by arnaud on 20/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// JSON keys

public struct OFF {
    
    public struct URL {
        // structure of the url is:
        // "https://static.openfoodfacts.org/images/products/40111490/ingredients_en.11.400.jpg"
        //
        public struct ImageType {
            static let Front = "front"
            static let Ingredients = "ingredients"
            static let Nutrition = "nutrition"
        }
        public struct ImageSize {
            static let Thumb = ".100"
            static let Small = ".200"
            static let Display = ".400"
            static let Original = ""
        }
        public struct Divider {
            static let Slash = "/"
            static let Dot = "."
        }
        public struct PartNumber {
            static let Barcode = 5
        }
        
        static let Scheme = "http://"
        static let Prefix = "http://world."
        static let TopDomain = ".org/"
        static let EnglishProduct = "en:product/"
        static let Postfix = ".org/api/v0/product/"
        static let JSONExtension = ".json"
        static let JPGextension = ".jpg"
        static let Images = "images/products/"
        
    }
    
    public enum Server: String {
        case food = "openfoodfacts"
        case beauty = "openbeautyfacts"
        case petFood = "openpetfoodfacts"
    }
    
    public enum ImageSize: String {
        case thumb = "100"
        case medium = "200"
        case large = "400"
        case original = "original"
    }
    
    // The strings are used in the URL's of the search query, so we look for the right thing
    public enum SearchComponent: String {
        case name = "name"
        case brand = "brand"
        case category = "category"
        case codes = "codes"
        case country = "country"
        case label = "label"
        case language = "language"
        case packaging = "packaging"
        case purchasePlace = "purchase-place"
        case additive = "additive"
        case trace = "trace"
        case allergen = "allergen"
        case producerCode = "packager-code"
        case manufacturingPlaces = "manufacturing-place"
        case store = "store"
        case entryDates = "entry-dates"
        case lastEditDate = "last-edit-date"
        case contributor = "contributor"
        case creator = "creator"
        case informer = "informer"
        case editor = "editor"
        case photographer = "photographer"
        case corrector = "corrector"
        case state = "state"
    }
    
    static func description(for component: SearchComponent) -> String {
        switch component {
        case .name:
            return "name"
        case .brand:
            return "brand"
        case .category:
            return "category"
        case .codes:
            return "codes"
        case .country:
            return "country"
        case .label:
            return "label"
        case .language:
            return "language"
        case .packaging:
            return "packaging"
        case .purchasePlace:
            return "purchase-place"
        case .additive:
            return "additive"
        case .trace:
            return "trace"
        case .allergen:
            return "allergen"
        case .producerCode:
            return "packager-code"
        case .manufacturingPlaces:
            return "manufacturing-place"
        case .store:
            return "store"
        case .entryDates:
            return "entry-dates"
        case .lastEditDate:
            return "last-edit-date"
        case .contributor:
            return "contributor"
        case .creator:
            return "creator"
        case .informer:
            return "informer"
        case .editor:
            return "editor"
        case .photographer:
            return "photographer"
        case .corrector:
            return "corrector"
        case .state:
            return "state"
        }
    }
    
    public enum SearchStatus: String {
        case productNameCompleted = "product-name-completed"
        case productNameNotCompleted = "product-name-to-be-completed"
        case brandsCompleted = "brands-completed"
        case brandsNotCompleted = "brands-to-be-completed"
        case quantityCompleted = "quantity-completed"
        case quantityNotCompleted = "quantity-to-be-completed"
        case packagingCompleted = "packaging-code-completed"
        case packagingNotCompleted = "packaging-code-to-be-completed"
        case ingredientsCompleted = "ingredients-completed"
        case ingredientsNotCompleted = "ingredients-to-be-completed"
        case categoriesCompleted = "categories-completed"
        case categoriesNotCompleted = "categories-to-be-completed"
        case expirationDateCompleted = "expiration-date-completed"
        case expirationDateNotCompleted = "expiration-date-to-be-completed"
        case nutritionFactsCompleted = "nutrition-facts-completed"
        case nutritionFactsNotCompleted = "nutrition-facts-to-be-completed"
        case photosUploadedCompleted = "photos-uploaded"
        case photosUploadedNotCompleted = "photos-to-be-uploaded"
        case photosValidatedCompleted = "photos-validated"
        case photosValidatedNotCompleted = "photos-to-be-validated"
    }

    

    static func fetchString(for barcode: BarcodeType, with productType: ProductType) -> String {
        var fetchUrlString = URL.Prefix
        // add the right server
        fetchUrlString += productType.rawValue
        fetchUrlString += URL.Postfix
        fetchUrlString += barcode.asString() + URL.JSONExtension
        return fetchUrlString
    }

    static func searchString(for component: SearchComponent, with value: String ) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        // use the currrent product type
        urlString += server(for:Preferences.manager.showProductType)
        urlString += URL.TopDomain
        urlString += component.rawValue
        urlString += "/"
        urlString += value
        urlString += URL.JSONExtension
        return urlString
    }
    
    static func searchString(for component: SearchComponent, with value: String, on page:Int ) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        // use the currrent product type
        urlString += server(for:Preferences.manager.showProductType)
        urlString += URL.TopDomain
        urlString += component.rawValue
        urlString += "/"
        urlString += value
        urlString += "/"
        urlString += "\(page)"
        urlString += URL.JSONExtension
        return urlString
    }

    
    static func webProductURLFor(_ barcode: BarcodeType) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType() ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.EnglishProduct
        urlString += barcode.asString()
        urlString += "/"
        return urlString
    }
    
    static func imageURLFor(_ barcode: BarcodeType) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType() ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.Images
        if let str = imageURLComponentFor(barcode.asString()) {
            urlString += str
        }
        urlString += "/"
        return urlString
    }
    
    // https://world.openfoodfacts.org/images/products/803/409/462/0006/3.100.jpg
    
    static func imageURLFor(_ barcode: BarcodeType, with id:String, size:ImageSizeCategory) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType() ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.Images
        if let str = imageURLComponentFor(barcode.asString()) {
            urlString += str
        }
        urlString += "/"
        urlString += id
        switch size {
        case .thumb:
            urlString += OFF.URL.ImageSize.Thumb
        case .small:
            urlString += OFF.URL.ImageSize.Small
        case .large:
            urlString += OFF.URL.ImageSize.Display
        case .original:
            urlString += OFF.URL.ImageSize.Original
        default:
            assert(false, "OFF.imageURLFor(_:with:size:)")
        }
        urlString += OFF.URL.JPGextension
        return urlString
    }

    static func imageURLComponentFor(_ barcode: String) -> String? {
        if barcode.characters.count == 8 {
            // Lidl product
            return barcode
        } else if barcode.characters.count == 13 {
            let part1 = barcode.index(barcode.startIndex, offsetBy: 0)...barcode.index(barcode.startIndex, offsetBy: 2)
            let part2 = barcode.index(barcode.startIndex, offsetBy: 3)...barcode.index(barcode.startIndex, offsetBy: 5)
            let part3 = barcode.index(barcode.startIndex, offsetBy: 6)...barcode.index(barcode.startIndex, offsetBy: 8)
            let part4 = barcode.index(barcode.startIndex, offsetBy: 9)...barcode.index(barcode.startIndex, offsetBy: 12)
//
            return barcode[part1] + OFF.URL.Divider.Slash +
                barcode[part2] + OFF.URL.Divider.Slash +
                barcode[part3] + OFF.URL.Divider.Slash  +
                barcode[part4]
        } else if barcode.characters.count == 11 {
            // US products
            let part1 = barcode.index(barcode.startIndex, offsetBy: 0)...barcode.index(barcode.startIndex, offsetBy: 2)
            let part2 = barcode.index(barcode.startIndex, offsetBy: 3)...barcode.index(barcode.startIndex, offsetBy: 5)
            let part3 = barcode.index(barcode.startIndex, offsetBy: 6)...barcode.index(barcode.startIndex, offsetBy: 8)
            let part4 = barcode.index(barcode.startIndex, offsetBy: 9)...barcode.index(barcode.startIndex, offsetBy: 10)
            //
            return barcode[part1] + OFF.URL.Divider.Slash +
                barcode[part2] + OFF.URL.Divider.Slash +
                barcode[part3] + OFF.URL.Divider.Slash  +
                barcode[part4]
        }
        print("OFF.imageURLFor : barcode can not be translated to url-string")
        return nil
    }

    
    static func server(for productType: ProductType) -> String {
        switch productType {
        case .food:
            return OFF.Server.food.rawValue
        case .petFood:
            return OFF.Server.petFood.rawValue
        case .beauty:
            return OFF.Server.beauty.rawValue
        }
    }

}


struct OFFReadAPIkeysJSON {
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
    static let ImagesKey = "images"
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
    static let SelectedImagesKey = "selected_images"
    static let FrontImageKey = "front"
    static let NutritionImageKey = "nutrition"
    static let IngredientsImageKey = "ingredients"
    static let DisplayKey = "display"
    static let SmallKey = "small"
    static let ThumbKey = "thumb"
    
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
    static let NutritionScoreFr100gKey = "nutrition-score-fr_100g"
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
    static let AllergensKey = "allergens"
    static let AllergensHierarchyKey = "allergens_hierarchy"
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
    
    static let PeriodsAfterOpeningKey = "periods_after_opening"
    static let NewServerKey = "new_server"
    
    // specific keys for product lists
    static let SkipKey = "skip"  // Int
    static let PageSizeKey = "page_size" // Int
    static let ProductsKey = "products" //Array
    static let PageKey = "page" // Int
    static let CountKey = "count" // Int
}


