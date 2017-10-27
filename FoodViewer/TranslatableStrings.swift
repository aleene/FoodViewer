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
    static let Cancel = NSLocalizedString("Cancel", comment: "String in button, to let the user indicate he does NOT want to search.")
    static let Categories = NSLocalizedString("Categories", comment: "Text to indicate the product belongs to a category.")
    static let Checker = NSLocalizedString("Checker", comment: "String in PickerViewController to indicate the checker role of a contributor")
    static let CheesesCategory = NSLocalizedString("Cheeses category", comment: "Cell title indicating the product belongs to the cheeses category")
    static let CommonName = NSLocalizedString("Common Name", comment: "Tableview sectionheader for long product name")
    static let Completion = NSLocalizedString("Completion", comment: "Label for a horizontal gauge that indicates the completion percentage of the product data.")
    static let CompletionStates = NSLocalizedString("Completion States", comment: "Generic string to indicate the completion states of a product.")
    static let ContributorNameNotSet = NSLocalizedString("contributor name not set", comment: "Generic string to indicate the completion states of a product.")
    static let Corrector = NSLocalizedString("Corrector", comment: "String in PickerViewController to indicate the corrector role of a corrector")
    static let CorrectorUnicode = NSLocalizedString("🔦", comment: "Image to indicate that the user modified information of the product.")
    static let Contributor = NSLocalizedString("Contributor", comment: "String in PickerViewController to indicate the creator role of a contributor (any role)")
    static let CreationDate = NSLocalizedString("Creation date", comment: "String in picker, which lets the user select the search result order. Order on the creation dates.")

    static let Creator = NSLocalizedString("Creator", comment: "String in PickerViewController to indicate the creator role of a contributor")
    static let CreatorUnicode = NSLocalizedString("❤️", comment: "Image to indicate that the user who created the product.")
    static let Countries = NSLocalizedString("Countries", comment: "Generic string (plural) to indicate the countries where the product is sold.")
    
//
// MARK: - DDDDDDDDDDDDDDDD strings
//
    
    static let D = NSLocalizedString("D", comment: "String in Segmented Control to indicate the fourth best nutritional score level")
    
//
// MARK: - EEEEEEEEEEEEEEEEE strings
//
    
    static let E = NSLocalizedString("E", comment: "String in Segmented Control to indicate the fifth best (and last) nutritional score level")
    static let EditDate = NSLocalizedString("Edit date", comment: "String in picker, which lets the user select the search result order")
    static let EditNutrient = NSLocalizedString("Edit Nutrient", comment: "Title of view controller, which allows editing of the nutrients")
    static let Editor = NSLocalizedString("Editor", comment: "String in PickerViewController to indicate the editor role of a contributor")
    static let EditorUnicode = NSLocalizedString("📝", comment: "Image to indicate that the user who added or deleted information of the product.")
    static let EnterContributorName = NSLocalizedString("Enter contributor name to search for", comment: "placeholder in a textField where the user can specify a search for contributors.")
    static let EnterDate = NSLocalizedString("Enter date", comment: "The user can tap the button to enter a date.")
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
    static let InformerUnicode = NSLocalizedString("💭", comment: "Image to indicate that the user who added information to the product.")
    static let Ingredients = NSLocalizedString("Ingredients", comment: "Text to indicate the ingredients of a product.")
    static let IngredientOrigins = NSLocalizedString("Ingredients Origin", comment: "Generic string to indicate the origins of the ingredients")
    static let Initialized = NSLocalizedString("Initialized", comment: "String presented in a tagView if nothing has happened yet")

    
//
// MARK: - LLLLLLLLLLLLLLLL strings
//
    
    static let Labels = NSLocalizedString("Labels", comment: "Generic string for labels on product")
    static let Languages = NSLocalizedString("Languages", comment: "Tableview sectionheader for languages on product")
    static let LastEditDate = NSLocalizedString("Last Edit Date", comment: "Generic string to indicate the last date the product was edited")
    static let Level = NSLocalizedString("Level", comment: "String to indicate the level (score) of the product.")
    static let ListedOnPackage = NSLocalizedString("Listed on package?", comment: "Label to indicate whether any nutrients are indicated on the package")
    static let LoadingFailed = NSLocalizedString("Loading Failed", comment: "Error message when the product failed to load.")
    static let LoadMoreResults = NSLocalizedString("Load more results", comment: "String presented in a tagView if there are more results available")

//
// MARK: - MMMMMMMMMMMMMMMMM strings
//
    
    static let MainImage = NSLocalizedString("Main Image", comment: "Tableview sectionheader for main image of package.")
    static let Manufacturer = NSLocalizedString("Manufacturer", comment: "Generic string to indicate the manufaturer of the product.")
    
//
// MARK: - NNNNNNNNNNNnNNNNNNN strings
//
    
    static let Name = NSLocalizedString("Name", comment: "Tableview sectionheader for product name")
    static let NoBrandsIndicated = NSLocalizedString("No brands indicated", comment: "Text in a tableview cell, when no brands are available in the product data.")
    static let NoExpirationDate = NSLocalizedString("No expiration date", comment: "Title of cell when no expiration date is avalable")
    static let NoImageInTheRightLanguage = NSLocalizedString("No image in the right language", comment: "Tag indicating that no image in the correct language is available")
    static let NoIngredients = NSLocalizedString("no ingredients specified", comment: "Text in a TagListView, when no ingredients are available in the product data.")
    static let NoLanguage = NSLocalizedString("no language defined", comment: "Text for language of product, when there is no language defined.")
    static let NoName = NSLocalizedString("no name specified", comment: "Text for productname, when no productname is available in the product data.")
    static let None = NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")
    static let NoNutrients = NSLocalizedString("No nutrients", comment: "Text of Label, indicating that the product has no nutrients defined")
    static let NoSearchDefined = NSLocalizedString("No search defined", comment: "String in TableView section when a search is not defined.")
    static let NoSearchResult = NSLocalizedString("No search result", comment: "String in TableView section when a search is not yet carried out.")
    static let NoServingSizeAvailable = NSLocalizedString("no serving size available", comment: "Text for an entry in a taglist, when no serving size is available. This is also indicated in a separate colour.")
    static let NotSet = NSLocalizedString("not set", comment: "Generic text if q vqlue hqs not yet been set.")
    static let NutritionFacts = NSLocalizedString("Nutrition Facts", comment: "Text to indicate the nutrition facts of a product.")
    static let NoProductsListed = NSLocalizedString("No products listed", comment: "Text to indicate that the history of products is empty.")
    static let Nutrients = NSLocalizedString("Nutrients", comment: "Generic text to indicate the nutrients of a product.")
    static let NutritionalScore = NSLocalizedString("Nutritional Score", comment: "Header for a table section showing the search for nutritional score")
    static let NutritionalScoreFrance = NSLocalizedString("Nutritional Score France", comment: "Header for a table section showing the total results France")
    static let NutritionalScoreUK = NSLocalizedString("Nutritional Score UK", comment: "Header for a table section showing the total results UK")

    
    static let OK = NSLocalizedString("OK",
                                      comment: "String in button, to let the user indicate he wants to start the search.")
    static let OtherProductType = NSLocalizedString("Other product type", comment: "String presented in a tagView if this is not the current product type")
//
// MARK: - PPPPPPPPPPPPPP strings
//
    
    static let Packaging = NSLocalizedString("Packaging", comment: "Tableview sectionheader for packaging.")
    static let PackagerCodes = NSLocalizedString("Packager Code", comment: "Generic string to indicate the packager codes.")
    static let PerServing = NSLocalizedString("Per serving", comment: "Text of 2nd segment of a SegmentedControl, indicating the model of the nutrient values, i.e. the values are indicated per serving")
    static let Per100mgml = NSLocalizedString("Per 100 mg/ml", comment: "Text of 1st segment of a SegmentedControl, indicating the model of the nutrient values, i.e. per standard 100g or 100 ml")
    static let PetFoodProducts = NSLocalizedString("Petfood Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
    static let Photographer = NSLocalizedString("Photographer", comment: "String in PickerViewController to indicate the photographer role of a contributor") + TranslatableStrings.Space + TranslatableStrings.PhotographerUnicode
    static let PhotographerUnicode = NSLocalizedString("📷", comment: "Image to indicate that the user took pictures of the product.")
    static let Popularity = NSLocalizedString("Popularity", comment: "String in picker, which lets the user select the search result order. Order on the popularity.")
    static let ProductDoesNotExistAlertSheetMessage = NSLocalizedString("Product does not exist. Add?", comment: "Alert message, when the product could not be retrieved from Internet.")
    static let ProductDoesNotExistAlertSheetActionTitleForCancel = NSLocalizedString("Nope", comment: "Alert title, to indicate product should NOT be added")
    static let ProductDoesNotExistAlertSheetActionTitleForAdd = NSLocalizedString("Sure", comment: "Alert title, to indicate product should be added")
    static let ProductIsLoaded = NSLocalizedString("Product is loaded", comment: "String presented in a tagView if the product has been loaded")
    static let ProductLoading = NSLocalizedString("Product loading", comment: "String presented in a tagView if the product is currently being loaded")
    static let ProductLoadingFailed = NSLocalizedString("Product loading failed", comment: "String presented in a tagView if the product loading has failed")
    static let ProductListIsLoaded = NSLocalizedString("Product list is loaded", comment: "String presented in a tagView if the product list has been loaded")
    static let ProductName = NSLocalizedString("Product name", comment: "String in picker, which lets the user select the search result order. Order on the product names.")
    static let ProductNameMissing = NSLocalizedString("Product name missing", comment: "Secction title, to indicate the product name does not exist")
    static let ProductNotAvailable = NSLocalizedString("Product not available", comment: "String presented in a tagView if no product is available on OFF")
    static let PurchaseAddress = NSLocalizedString("Purchase address", comment: "Generic string to indicate the address (street/city/postalcode/country) where the product was bought")
    
//
// MARK: - QQQQQQQQQQQQQQQQ strings
//
    
    static let Quantity = NSLocalizedString("Quantity", comment: "Tableview sectionheader for size of package.")
    
//
// MARK: - RRRRRRRRRRRRRRRR strings
//
    
    static let RoleNotSelected = NSLocalizedString("not selected", comment: "Text of a button, indicating a contributor role is not selected")
    
//
// MARK: - SSSSSSSSSSSSSSSSS strings
//
    
    static let SalesCountries = NSLocalizedString("Sales countries", comment: "Text to indicate the sales countries of a product.")
    // static let Search = NSLocalizedString("Search", comment: "Prefix of a title of a Tableview controller")
    static let SearchFoodProducts = NSLocalizedString("Search Food Products", comment: "Title of a Tableview controller, indicating the tableview shows search food products.")
    static let SearchPetFoodProducts = NSLocalizedString("Search PetFood", comment: "Title of a Tableview controller, indicating the tableview shows search pet food products (note the width of the title is constrained).")
    static let SearchBeautyProducts = NSLocalizedString("Search Beauty Products", comment: "Title of a Tableview controller, indicating the tableview shows search beauty products.")
    static let Searching = NSLocalizedString("Searching", comment: "Title of a Tableview controller, indicating a search is in progress.")
    static let SearchLoading = NSLocalizedString("Search loading", comment: "String presented in a tagView if the search query is currently being loaded")
    static let SearchMessage = NSLocalizedString("for %@ in %@",
                                                 comment: "Explanatory text in AlertViewController, which shows the intended search")
    static let SearchQuery = NSLocalizedString("Search query", comment: "String presented in a tagView for the search query")
    static let SearchResults = NSLocalizedString("search results", comment: "Part of a sentece indicating the number of search results")
    static let SearchSetup = NSLocalizedString("Search set up", comment: "Indicating that a search has been defined")
    static let SearchText = NSLocalizedString("Search Text", comment: "String to indicate the text, which will be used to search multiple fileds of a product.")
    static let Select = NSLocalizedString("Select", comment: "Title of a viewcontroller where the user has to select an element in the picker.")
    static let SelectRole = NSLocalizedString("Select role", comment: "First item in a pickerView, indicating what the user should do")
    static let SpecialCategories = NSLocalizedString("Special categories", comment: "Header for a table section showing the special categories")
    static let StartSearch = NSLocalizedString("Start Search?",
                                               comment: "Title in AlertViewController, which lets the user decide if he wants to start a search.")
    static let Stores = NSLocalizedString("Stores", comment: "Generic string to indicate the stores where the product is sold.")
    static let SupplyChain = NSLocalizedString("Supply Chain", comment: "Title for the view controller with information about the Supply Chain (origin ingredients, producer, shop, locations).")
    
//
// MARK: - TTTTTTTTTTTTTT strings
//
    
    static let Traces = NSLocalizedString("Traces", comment: "Text to indicate the traces of a product.")
    
//
// MARK: - UUUUUUUUUUUUUUUU strings
//
    
    static let UnbalancedWarning = NSLocalizedString(" (WARNING: check brackets, they are unbalanced)", comment: "a warning to check the brackets used, they are unbalanced")
    static let Undefined = NSLocalizedString("Undefined", comment: "String (in Segmented Control/Tag) to indicate the nutritional score level is undefined (and will not be used in the search)")
    static let UnknownValue = TranslatableStrings.QuestionMark
    
//
// MARK: - Other strings
//
    
    static let QuestionMark = NSLocalizedString("?", comment: "a questionmark used for several purposes")
    static let Space = NSLocalizedString(" ", comment: "a space used for several purposes")

}




