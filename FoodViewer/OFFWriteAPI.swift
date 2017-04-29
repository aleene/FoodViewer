//
//  OFFWriteAPI.swift
//  FoodViewer
//
//  Created by arnaud on 20/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

struct OFFWriteAPI {
    static let Server = "http://world.openfoodfacts.org/"
    static let SecureServer = "https://ssl-api.openfoodfacts.org/"
    // static let BeautySecureServer = "https://ssl-api.openbeautyfacts.org/"
    // static let PetFoodSecureServer = "https://ssl-api.openpetfoodfacts.org/"
    static let PostPrefix = "cgi/product_jqm2.pl?"
    static let Prefix = "http://world."
    static let Domain = ".org/"
    static let SecurePrefix = "https://ssl-api."
    static let Barcode = "code="
    static let UserId = "user_id="
    static let Password = "password="
    static let Name = "product_name"
    static let GenericName = "generic_name"
    static let Quantity  = "quantity="
    static let Ingredients = "ingredients_text"
    static let ExpirationDate = "expiration_date="
    static let PurchasePlaces = "purchase_places="
    static let Stores = "stores="
    static let PrimaryLanguageCode = "lang="
    static let NoNutriments = "no_nutriments"
    static let NutrimentPrefix = "nutriment_"
    static let NutrimentUnit = "_unit"
    static let NutrimentPerServing = "nutrition_data_per=serving"
    static let NutrimentPer100g = "nutrition_data_per=100g"
    static let Brands = "brands="
    static let Packaging = "packaging="
    static let Traces = "traces="
    static let TracesPrefix = "traces"
    static let Labels = "labels="
    static let Categories = "categories="
    static let Producer = "manufacturing_places="
    static let ProducerCode = "emb_codes="
    static let IngredientsOrigin = "origins="
    static let Countries = "countries="
    static let Links = "link="
    static let ServingSize = "serving_size="
    static let Delimiter = "&"
    static let CommaDelimiter = ", "
    static let LanguageSpacer = "_"
    static let Equal = "="
}
