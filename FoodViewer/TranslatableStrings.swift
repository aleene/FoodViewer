//
//  TranslatableStrings.swift
//  FoodViewer
//
//  Created by arnaud on 07/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

struct TranslatableStrings {
    
    //
    // MARK: - AAAAAAAAAAAAAAAAAAAA strings
    //
    static let A = NSLocalizedString("A", comment: "String (in Segmented Control) to indicate the best nutritional score level")
    static let Allergens = NSLocalizedString("Allergens", comment: "Text to indicate the allergens of a product.")
    static let Additives = NSLocalizedString("Additives", comment: "Generic used string to indicate the additives of a product.")

    //
    // MARK: - BBBBBBBBBBBBBBBBBBBB strings
    //
    
    static let B = NSLocalizedString("B", comment: "String in Segmented Control to indicate the second best nutritional score level")
    static let Barcode = NSLocalizedString("Barcode", comment: "Tableview sectionheader for Barcode")
    static let BadNutrients = NSLocalizedString("Bad nutrients", comment: "Header for a table sectionshowing the appreciations of the bad nutrients")
    static let BeautyProducts = NSLocalizedString("Beauty Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
    static let BeveragesCategory = NSLocalizedString("Beverages category", comment: "Cell title indicating the product belongs to the beverages category")
    static let Brands = NSLocalizedString("Brands", comment: "Tableview sectionheader for brands.")
    
    //
    // MARK: - CCCCCCCCCCCCCCCCCCCCCC strings
    //
    
    static let C = NSLocalizedString("C", comment: "String in Segmented Control to indicate the thrid best nutritional score level")
    static let Categories = NSLocalizedString("Categories", comment: "Text to indicate the product belongs to a category.")
    static let Checker = NSLocalizedString("Checker", comment: "String in PickerViewController to indicate the checker role of a contributor")
    static let CheesesCategory = NSLocalizedString("Cheeses category", comment: "Cell title indicating the product belongs to the cheeses category")
    static let CommonName = NSLocalizedString("Common Name", comment: "Tableview sectionheader for long product name")
    static let CompletionStates = NSLocalizedString("Completion States", comment: "Generic string to indicate the completion states of a product.")
    static let Corrector = NSLocalizedString("Corrector", comment: "String in PickerViewController to indicate the corrector role of a corrector")
    static let Contributor = NSLocalizedString("Cotributor", comment: "String in PickerViewController to indicate the creator role of a contributor (any role)")
    static let Creator = NSLocalizedString("Creator", comment: "String in PickerViewController to indicate the creator role of a contributor")
    static let Countries = NSLocalizedString("Countries", comment: "Generic string (plural) to indicate the countries where the product is sold.")
    
    //
    // MARK: - DDDDDDDDDDDDDDDD strings
    //
    
    static let D = NSLocalizedString("D", comment: "String in Segmented Control to indicate the fourth best nutritional score level")
    
    
    //
    // MARK: - EEEEEEEEEEEEEEEEE strings
    //
    

    static let E = NSLocalizedString("E", comment: "String in Segmented Control to indicate the fifth best (and last) nutritional score level")
    static let Editor = NSLocalizedString("Editor", comment: "String in PickerViewController to indicate the editor role of a contributor")
    static let EntryDate = NSLocalizedString("Entry Date", comment: "String to indicate the date, when the product was created on OFF.")
    static let Exclude = NSLocalizedString("Exclude", comment: "String in Segmented Control to indicate whether the corresponding tag should be EXCLUDED from the search.")
    
    //
    // MARK: - FFFFFFFFFFFFFF strings
    //
    
    static let FoodProducts = NSLocalizedString("Food Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
    
    //
    // MARK: - GGGGGGGGGGGGGGG strings
    //
    
    static let GoodNutrients = NSLocalizedString("Good nutrients", comment: "Header for a table section showing the appreciations of the good nutrients")
    
    //
    // MARK: - IIIIIIIIIIIIIIII strings
    //
    
    static let Include = NSLocalizedString("Include", comment: "String in Segmented Control to indicate whether the corresponding tag should be INCLUDED in the search.")
    static let Informer = NSLocalizedString("Informer", comment: "String in PickerViewController to indicate the informer role of a contributor")
    static let Ingredients = NSLocalizedString("Ingredients", comment: "Text to indicate the ingredients of a product.")
    static let IngredientOrigins = NSLocalizedString("Ingredients Origin", comment: "Generic string to indicate the origins of the ingredients")
    //
    // MARK: - LLLLLLLLLLLLLLLL strings
    //
    
    static let Labels = NSLocalizedString("Labels", comment: "Generic string for labels on product")
    static let Languages = NSLocalizedString("Languages", comment: "Tableview sectionheader for languages on product")
    static let LastEditDate = NSLocalizedString("Last Edit Date", comment: "Generic string to indicate the last date the product was edited")
    static let LoadingFailed = NSLocalizedString("Loading Failed", comment: "Error message when the product failed to load.")
    //
    // MARK: - MMMMMMMMMMMMMMMMM strings
    //
    
    static let MainImage = NSLocalizedString("Main Image", comment: "Tableview sectionheader for main image of package.")
    static let Manufacturer = NSLocalizedString("Manufacturer", comment: "Generic string to indicate the manufaturer of the product.")
    
    
    static let Name = NSLocalizedString("Name", comment: "Tableview sectionheader for product name")
    static let NoImageInTheRightLanguage = NSLocalizedString("No image in the right language", comment: "Tag indicating that no image in the correct language is available")
    static let None = NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")
    static let NutritionFacts = NSLocalizedString("Nutrition Facts", comment: "Text to indicate the nutrition facts of a product.")
    static let NoProductsListed = NSLocalizedString("No products listed", comment: "Text to indicate that the history of products is empty.")
    static let Nutrients = NSLocalizedString("Nutrients", comment: "Generic text to indicate the nutrients of a product.")
    static let NutritionalScore = NSLocalizedString("Nutritional Score", comment: "Header for a table section showing the search for nutritional score")
    static let NutritionalScoreFrance = NSLocalizedString("Nutritional Score France", comment: "Header for a table section showing the total results France")
    static let NutritionalScoreUK = NSLocalizedString("Nutritional Score UK", comment: "Header for a table section showing the total results UK")

    //
    // MARK: - PPPPPPPPPPPPPP strings
    //
    
    static let Packaging = NSLocalizedString("Packaging", comment: "Tableview sectionheader for packaging.")
    static let PackagerCodes = NSLocalizedString("Packager Code", comment: "Gneric string to indicate the packager codes.")
    static let PetFoodProducts = NSLocalizedString("Petfood Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
    static let Photographer = NSLocalizedString("Photographer", comment: "String in PickerViewController to indicate the photographer role of a contributor") + " " + TranslatableStrings.PhotographerUnicode
    static let PhotographerUnicode = NSLocalizedString("📷", comment: "Image to indicate that the user took pictures of the product.")
    static let ProductDoesNotExistAlertSheetMessage = NSLocalizedString("Product does not exist. Add?", comment: "Alert message, when the product could not be retrieved from Internet.")
    static let ProductDoesNotExistAlertSheetActionTitleForCancel = NSLocalizedString("Nope", comment: "Alert title, to indicate product should NOT be added")
    static let ProductDoesNotExistAlertSheetActionTitleForAdd = NSLocalizedString("Sure", comment: "Alert title, to indicate product should be added")
    static let ProductNameMissing = NSLocalizedString("Product name missing", comment: "Secction title, to indicate the product name does not exist")
    static let PurchaseAddress = NSLocalizedString("Purchase address", comment: "Generic string to indicate the address (street/city/postalcode/country) where the product was bought")

    
    static let Quantity = NSLocalizedString("Quantity", comment: "Tableview sectionheader for size of package.")

    static let RoleNotSelected = NSLocalizedString("not selected", comment: "Text of a button, indicating a contributor role is not selected")

    static let SalesCountries = NSLocalizedString("Sales countries", comment: "Text to indicate the sales countries of a product.")
    // static let Search = NSLocalizedString("Search", comment: "Prefix of a title of a Tableview controller")
    static let SearchFoodProducts = NSLocalizedString("Search Food Products", comment: "Title of a Tableview controller, indicating the tableview shows search food products.")
    static let SearchPetFoodProducts = NSLocalizedString("Search PetFood", comment: "Title of a Tableview controller, indicating the tableview shows search pet food products (note the width of the title is constrained).")
    static let SearchBeautyProducts = NSLocalizedString("Search Beauty Products", comment: "Title of a Tableview controller, indicating the tableview shows search beauty products.")
    static let SearchResults = NSLocalizedString("search results", comment: "Part of a sentece indicating the number of search results")
    static let SearchText = NSLocalizedString("Search Text", comment: "String to indicate the text, which will be used to search multiple fileds of a product.")
    static let SelectRole = NSLocalizedString("select role", comment: "First item in a pickerView, indicating what the user should do")
    static let SpecialCategories = NSLocalizedString("Special categories", comment: "Header for a table section showing the special categories")
    static let Stores = NSLocalizedString("Stores", comment: "Generic string to indicate the stores where the product is sold.")
    
    //
    // MARK: - TTTTTTTTTTTTTT strings
    //
    
    static let Traces = NSLocalizedString("Traces", comment: "Text to indicate the traces of a product.")
    static let Undefined = NSLocalizedString("Undefined", comment: "String (in Segmented Control/Tag) to indicate the nutritional score level is undefined (and will not be used in the search)")
    }




