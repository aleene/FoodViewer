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
    static let AddNutrient = NSLocalizedString("Add Nutrient", comment: "Title of a button in normal state allowing the user to add a nutrient")
    static let Allergens = NSLocalizedString("Allergens", comment: "Text to indicate the allergens of a product.")
    static let AllergenWarnings = NSLocalizedString("Allergen warnings", comment: "TableViewController title for the allergen warnings setting scene.")
    static let Additives = NSLocalizedString("Additives", comment: "Generic used string to indicate the additives of a product.")
    static let AskSavePermissionTitle = NSLocalizedString("Save Product Updates?", comment: "The title of an alert sheet, which allows the user to save he product.")
    static let AskSavePermissionMessage = NSLocalizedString("The local product has been changed. Should these changes be saved?", comment: "The title of an alert sheet, which allows the user to save he product.")
    static let AssignImage = NSLocalizedString("Assign Image", comment: "ViewController title, which allows to set an image to a language and image category (front/ingredients/nutrition).")
    static let AuthenticateForOFFLogin = NSLocalizedString("Authenticate for OFF login", comment: "Reason string in TouchID authenticate alert")
    static let AuthenticateWithTouchIDFailed = NSLocalizedString("Authentication with TouchID failed. Specify your password", comment: "Explanatory text in AlertViewController, which lets the user enter his username/password.")
    static let Available = NSLocalizedString("Available", comment: "Text in a TagListView, when tags are available the product data.")


//
// MARK: - BBBBBBBBBBBBBBBBBBBB strings
//
    
    static let B = NSLocalizedString("B", comment: "String in Segmented Control to indicate the second best nutritional score level")
    static let Barcode = NSLocalizedString("Barcode", comment: "Tableview sectionheader for Barcode")
    static let BadNutrients = NSLocalizedString("Bad nutrients", comment: "Header for a table sectionshowing the appreciations of the bad nutrients")
    static let BeautyProducts = NSLocalizedString("Beauty Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
    static let Beauty = NSLocalizedString("Beauty", comment: "Title of a segmented control.")
    static let BeveragesCategory = NSLocalizedString("Beverages category", comment: "Cell title indicating the product belongs to the beverages category")
    static let Brands = NSLocalizedString("Brands", comment: "Tableview sectionheader for brands.")
    
//
// MARK: - CCCCCCCCCCCCCCCCCCCCCC strings
//
    
    static let C = NSLocalizedString("C", comment: "String in Segmented Control to indicate the thrid best nutritional score level")
    static let Calories = NSLocalizedString("Calories", comment: "Title of third segment in switch, which lets the user select between joule, kilo-calories or Calories")
    static let Cancel = NSLocalizedString("Cancel", comment: "String in button, to let the user indicate he does NOT want to search.")
    static let Categories = NSLocalizedString("Categories", comment: "Text to indicate the product belongs to a category.")
    static let Checker = NSLocalizedString("Checker", comment: "String in PickerViewController to indicate the checker role of a contributor")
    static let CheesesCategory = NSLocalizedString("Cheeses category", comment: "Cell title indicating the product belongs to the cheeses category")
    static let ClearHistory = NSLocalizedString("Clear History", comment: "Title of a button, which removes all items in the product search history.")
    static let CommonName = NSLocalizedString("Common Name", comment: "Tableview sectionheader for long product name")
    static let CommunityEffort = NSLocalizedString("Community Effort", comment: "Viewcontroller title for page with community effort for product.")
    static let Completeness = NSLocalizedString("Completeness", comment: "Header title of the tableview section, indicating whether the productdata is complete.")
    static let Completion = NSLocalizedString("Completion", comment: "Label for a horizontal gauge that indicates the completion percentage of the product data.")
    static let CompletionStates = NSLocalizedString("Completion States", comment: "Generic string to indicate the completion states of a product.")
    static let ContributorNameNotSet = NSLocalizedString("contributor name not set", comment: "Generic string to indicate the completion states of a product.")
    static let Corrector = NSLocalizedString("Corrector", comment: "String in PickerViewController to indicate the corrector role of a corrector")
    static let CorrectorUnicode = NSLocalizedString("🔦", comment: "Image to indicate that the user modified information of the product.")
    static let Contributor = NSLocalizedString("Contributor", comment: "String in PickerViewController to indicate the creator role of a contributor (any role)")
    static let Contributors = NSLocalizedString("Contributors", comment: "Header title of the tableview section, indicating whether which users did contribute.")
    static let CreationDate = NSLocalizedString("Creation date", comment: "String in picker, which lets the user select the search result order. Order on the creation dates.")

    static let Creator = NSLocalizedString("Creator", comment: "String in PickerViewController to indicate the creator role of a contributor")
    static let CreatorUnicode = NSLocalizedString("❤️", comment: "Image to indicate that the user who created the product.")
    static let Countries = NSLocalizedString("Countries", comment: "Generic string (plural) to indicate the countries where the product is sold.")
    //static let CurrentLocale = NSLocalizedString("Current Locale", comment: "Title of segment in segmentedControlto indicate the current local should be used.")

//
// MARK: - DDDDDDDDDDDDDDDD strings
//
    
    static let D = NSLocalizedString("D", comment: "String in Segmented Control to indicate the fourth best nutritional score level")
    static let DailyValue = NSLocalizedString("Daily Value", comment: "Title of third segment in switch, which lets the user select between per daily value (per 100 mg/ml / per serving / per daily value)")
    static let DailyValuesPerServing = NSLocalizedString("Daily Values (per serving)", comment: "Description for NutritionData Daily Value per serving")
    static let DataIsLoaded = NSLocalizedString("Data is loaded", comment: "String presented in a tagView if the data has been loaded")
    static let Discard = NSLocalizedString("Discard", comment: "Title of a button in an alert sheet, which allows the user to discard alle changes to the local product.")
    static let DisplayPrefs = NSLocalizedString("Display Preferences", comment: "Title of a tableView section, which lets the user select display options")
    static let Done = NSLocalizedString("Done", comment: "String in button, to let the user indicate he is ready with username/password input.")
    
//
// MARK: - EEEEEEEEEEEEEEEEE strings
//
    
    static let E = NSLocalizedString("E", comment: "String in Segmented Control to indicate the fifth best (and last) nutrition score level")
    static let Edit = NSLocalizedString("Edit", comment: "Title of viewcontroller which allows editing of the product in a webview.") 
    static let EditDate = NSLocalizedString("Edit date", comment: "String in picker, which lets the user select the search result order")
    static let EditNutrient = NSLocalizedString("Edit Nutrient", comment: "Title of view controller, which allows editing of the nutrients")
    static let Edited = NSLocalizedString("Edited", comment: "Added to a tableview section header to indicated the item has been edited.")
    static let EditedInParentheses = NSLocalizedString("(Edited)", comment: "Added to a tableview section header to indicated the item has been edited.")
    static let Editor = NSLocalizedString("Editor", comment: "String in PickerViewController to indicate the editor role of a contributor")
    static let EditorUnicode = NSLocalizedString("📝", comment: "Image to indicate that the user who added or deleted information of the product.")
    static let EneryUnitPreferences = NSLocalizedString("Default energy unit", comment: "Title of a table section, which allows the user to define the default energy unit (joules, calories, kilocalories).")
    static let EnterBarcode = NSLocalizedString("Enter barcode.", comment: "Placeholder string to explain the purpose of a barcode search in a tableview cell")
    static let EnterCityName = NSLocalizedString("Enter city name", comment: "Placeholder text for field where user should enter a city name.")
    static let EnterContributorName = NSLocalizedString("Enter contributor name to search for", comment: "placeholder in a textField where the user can specify a search for contributors.")
    static let EnterCountryName = NSLocalizedString("Enter country name", comment: "Placeholder text for field where user should enter a country name.")
    static let EnterDate = NSLocalizedString("Enter date", comment: "The user can tap the button to enter a date.")
    static let EnterPostalCode = NSLocalizedString("Enter postal code", comment: "Placeholder text for field where user should enter a postal code.")
    static let EnterShopName = NSLocalizedString("Enter shop name", comment: "Placeholder text for field where user should enter a shop name.")
    static let EnterStreetName = NSLocalizedString("Enter street name", comment: "Placeholder text for field where user should enter a street name.")
    static let EntryDate = NSLocalizedString("Entry Date", comment: "String to indicate the date, when the product was created on OFF.")
    static let EUSet = NSLocalizedString("EU Set", comment: "String of a button, to prefill the nutrients with the standard EU set.")
    static let Exclude = NSLocalizedString("Exclude", comment: "String in Segmented Control to indicate whether the corresponding tag should be EXCLUDED from the search.")
    static let ExpirationDate = NSLocalizedString("Expiration Date", comment: "Header title of the tableview section, indicating the most recent expiration date.")
    
//
// MARK: - FFFFFFFFFFFFFF strings
//
    
    static let FoodProducts = NSLocalizedString("Food Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
    static let Food = NSLocalizedString("Food", comment: "Title of SegmentedControl segment.")

//
// MARK: - GGGGGGGGGGGGGGG strings
//
    
    static let Gallery = NSLocalizedString("Gallery", comment: "Viewcontroller title for page with images of the product")
    static let Gram = NSLocalizedString("gram (g)", comment: "Standard weight unit.")
    static let GoodNutrients = NSLocalizedString("Good nutrients", comment: "Header for a table section showing the appreciations of the good nutrients")
    
    static let Hierarchy = NSLocalizedString("Hierarchy", comment: "Description of the hierarchy tags in the json")
    static let HunderdMgMl = NSLocalizedString("100 mg/ml", comment: "Title of first segment in switch, which lets the user select between per standard unit (per 100 mg/ml / per serving / per daily value)")

//
// MARK: - IIIIIIIIIIIIIIII strings
//
    
    static let Identification = NSLocalizedString("Identification", comment: "Title for the view controller with the product image, title, etc.")
    static let Image = NSLocalizedString("Image", comment: "Title for the viewcontroller with an enlarged image")
    static let ImageDates = NSLocalizedString("Image Dates", comment: "Table Section Header with dates of the images")
    static let ImageIsBeingLoaded = NSLocalizedString("Image is being loaded", comment: "String presented in a tagView if the image is currently being loaded")
    static let ImageLoadingHasFailed = NSLocalizedString("Image loading has failed", comment: "String presented in a tagView if the image loading has failed")
    static let ImageWasEmpty = NSLocalizedString("Image was empty", comment: "String presented in a tagView if the image data contained no data")
    static let Include = NSLocalizedString("Include", comment: "String in Segmented Control to indicate whether the corresponding tag should be INCLUDED in the search.")
    static let Informer = NSLocalizedString("Informer", comment: "String in PickerViewController to indicate the informer role of a contributor")
    static let InformerUnicode = NSLocalizedString("💭", comment: "Image to indicate that the user who added information to the product.")
    static let Ingredients = NSLocalizedString("Ingredients", comment: "Text to indicate the ingredients of a product.")
    static let IngredientsImage = NSLocalizedString("Ingredients Image", comment: "Header title for the ingredients image section, i.e. the image of the package with the ingredients")
    static let IngredientOrigins = NSLocalizedString("Origins of ingredients", comment: "Generic string to indicate the origins of the ingredients")
    static let Initialized = NSLocalizedString("Initialized", comment: "String presented in a tagView if nothing has happened yet")
    static let Interpreted = NSLocalizedString("Interpreted", comment: "Description of the by OFF interpreted tags in the json")
    
//
// MARK: - JJJJJJJJJjjjjJJJJJJ strings
//

    static let Joule = NSLocalizedString("Joules", comment: "Title of first segment in switch, which lets the user select between joules, kilo-calories or Calories")
    
    static let KiloCalorie = NSLocalizedString("Kilocalories", comment: "Title of second segment in switch, which lets the user select between joule, kilo-calories or Calories")
//
// MARK: - LLLLLLLLLLLLLLLL strings
//
    
    static let Labels = NSLocalizedString("Labels", comment: "Generic string for labels on product")
    static let Languages = NSLocalizedString("Languages", comment: "Tableview sectionheader for languages on product")
    static let LastEditDate = NSLocalizedString("Last Edit Date", comment: "Generic string to indicate the last date the product was edited")
    static let Level = NSLocalizedString("Level", comment: "String to indicate the level (score) of the product.")
    static let ListedOnPackage = NSLocalizedString("Listed on package?", comment: "Label to indicate whether any nutrients are indicated on the package")
    static let LoadingFailed = NSLocalizedString("Loading Failed", comment: "Error message when the product failed to load.")
    static let Loading = NSLocalizedString("Loading", comment: "Message as tag when the search is loading.")
    static let LoadMoreResults = NSLocalizedString("Load more results", comment: "String presented in a tagView if there are more results available")

//
// MARK: - MMMMMMMMMMMMMMMMM strings
//
    
    static let MainImage = NSLocalizedString("Main Image", comment: "Tableview sectionheader for main image of package.")
    static let Manufacturer = NSLocalizedString("Manufacturer", comment: "Generic string to indicate the manufaturer of the product.")
    static let Map = NSLocalizedString("Sale Stores", comment: "Header for section of tableView with names of the stores where the product is sold.")
    static let Microgram = NSLocalizedString("microgram (µm)", comment: "Standard weight unit divided by million.")
    static let Milligram = NSLocalizedString("milligram (mg)", comment: "Standard weight unit divided by thousand.")
    static let MoveScale = NSLocalizedString("Move/Scale", comment: "Title of a navigation bar, wich allows the user to adapt an image.")
    
//
// MARK: - NNNNNNNNNNNnNNNNNNN strings
//
    
    static let Name = NSLocalizedString("Name", comment: "Tableview sectionheader for product name")
    static let NoBrandsIndicated = NSLocalizedString("No brands indicated", comment: "Text in a tableview cell, when no brands are available in the product data.")
    static let NoCreationDateAvailable = NSLocalizedString("no creation date available", comment: "Value of the creation date field, if no valid date is available.")
    static let NoEditDateAvailable = NSLocalizedString("no edit date available", comment: "Value of the edit date field, if no valid date is available.")
    static let NoExpirationDate = NSLocalizedString("No expiration date", comment: "Title of cell when no expiration date is avalable")
    static let NoGenericNameAvailable = NSLocalizedString("No generic name available", comment: "String if no generic name is available")
    static let NoImageAvailable = NSLocalizedString("No image available", comment: "String presented in a tagView if no image is available")
    static let NoImageInTheRightLanguage = NSLocalizedString("No image in the right language", comment: "Tag indicating that no image in the correct language is available")
    static let NoIngredients = NSLocalizedString("no ingredients specified", comment: "Text in a TagListView, when no ingredients are available in the product data.")
    static let NoLanguageDefined = NSLocalizedString("no language defined", comment: "Text for language of product, when there is no language defined.")
    static let NoName = NSLocalizedString("no name specified", comment: "Text for productname, when no productname is available in the product data.")
    static let None = NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")
    static let NoNutrients = NSLocalizedString("No nutrients", comment: "Text of Label, indicating that the product has no nutrients defined")
    static let NoQuantityAvailable = NSLocalizedString("No quantity available", comment: "String if no quantity is available")
    static let NoResponse = NSLocalizedString("No reponse", comment: "String presented in a tagView if the site did not respond")
    static let NoSearchDefined = NSLocalizedString("No search defined", comment: "String in TableView section when a search is not defined.")
    static let NoSearchResult = NSLocalizedString("No search result", comment: "String in TableView section when a search is not yet carried out.")
    static let NoServingSizeAvailable = NSLocalizedString("no serving size available", comment: "Text for an entry in a taglist, when no serving size is available. This is also indicated in a separate colour.")
    static let NoTitle = NSLocalizedString("No title", comment: "Title for viewcontroller with detailed product images, when no title is given. ")
    static let NotDone = NSLocalizedString("Not done", comment: "Generic text if an action has not yet been done.")
    static let NotFilled = NSLocalizedString("Not filled", comment: "Text in a TagListView, when the json provided an empty string.")
    static let NoNutritionDataAvailable = NSLocalizedString("no nutrition data available", comment: "Text in a TagListView, when no nutrition data has been specified in the product data.")
    static let NoNutritionDataIndicated = NSLocalizedString("no nutrition data indicated", comment: "Text in a TagListView, when no nutrition data has been specified in the product data.")
    static let NotOnPackage = NSLocalizedString("nutrition data not on package", comment: "Text in a TagListView, when no nutrition data is available on the package.")
    static let NotSearchable = NSLocalizedString("Not searchable", comment: "Text in a search TagListView, when tags can not be set up.")
    static let NotSet = NSLocalizedString("Not set", comment: "Generic text if a value has not yet been set.")
    static let NoProductsListed = NSLocalizedString("No products listed", comment: "Text to indicate that the history of products is empty.")
    static let NoTranslation = NSLocalizedString("No translation", comment: "Text in a pickerView, when no translated text is available")
    static let Nutrients = NSLocalizedString("Nutrients", comment: "Generic text to indicate the nutrients of a product.")
    static let NutrimentsAvailability = NSLocalizedString("Nutriments Availability", comment: "Tableview header for the section with nutriments availability, i.e. whether the nutrients are on the package.")
    static let NutritionalScore = NSLocalizedString("Nutrition Score", comment: "Header for a table section showing the search for nutrition score")
    static let NutritionalScoreFrance = NSLocalizedString("Nutritional Score France", comment: "Header for a table section showing the total results France")
    static let NutritionalScoreUK = NSLocalizedString("Nutritional Score UK", comment: "Header for a table section showing the total results UK")
    static let NutritionFacts = NSLocalizedString("Nutrition Facts", comment: "Text to indicate the nutrition facts of a product.")
    static let NutritionFactsImage = NSLocalizedString("Nutrition Facts Image", comment: "Tableview header section for the image of the nutritional facts")
    static let NutritionFactsPer100gml = NSLocalizedString("Nutrition Facts (per 100g/100ml)", comment: "Description for NutritionData per standard unit")
    static let NutritionFactsPerServing = NSLocalizedString("Nutrition Facts (per serving)", comment: "Description for NutritionData per serving")
    static let NutritionFactsPer1000Gram = NSLocalizedString("Nutrition Facts (per 1 kg)", comment: "Description for NutritionData per one kilogram")
    static let NutritionTableFormatPreferences = NSLocalizedString("Default nutrition facts table style", comment: "Title of table view section which allows the user to set who defines the table format (user or product).")
    static let NutritionUnitPreferences = NSLocalizedString("Default nutrition facts style", comment: "Title of table view section which allows the user to set the reference for nutrition facts (serving or 100g).")

    
    static let OK = NSLocalizedString("OK", comment: "String in button, to let the user indicate he wants to start the search.")
    static let OpenInSafari = NSLocalizedString("Open in Safari", comment: "String for the Activity Action Screen")
    static let Original = NSLocalizedString("Original", comment: "Description of the original tags in the json")
    static let OtherProductType = NSLocalizedString("Other product type", comment: "String presented in a tagView if this is not the current product type")
//
// MARK: - PPPPPPPPPPPPPP strings
//
    
    static let Packaging = NSLocalizedString("Packaging", comment: "Tableview sectionheader for packaging.")
    static let PackagerCodes = NSLocalizedString("Packager Code", comment: "Generic string to indicate the packager codes.")
    static let Password = NSLocalizedString("Password", comment: "String in textField placeholder, to show that the user has to enter his password")
    static let Percentage = NSLocalizedString("percentage (%)", comment: "Fraction of total by volume")
    static let PeriodAfterOpening = NSLocalizedString("Period After Opening", comment: "Header title of tableview section, indicating period after opening for beauty products")
    static let PerServing = NSLocalizedString("Per serving", comment: "Text of 2nd segment of a SegmentedControl, indicating the model of the nutrient values, i.e. the values are indicated per serving")
    static let PerServingAndStandardUnit = NSLocalizedString("nutrition data per serving and standard unit available", comment: "Text in a TagListView, when the nutrition data has been specified in the product data.")
    static let PersonalAccount = NSLocalizedString("Personal Account", comment: "Title in AlertViewController, which lets the user enter his username/password.")
    static let Per100mgml = NSLocalizedString("Per 100 mg/ml", comment: "Text of 1st segment of a SegmentedControl, indicating the model of the nutrient values, i.e. per standard 100g or 100 ml")
    static let PetFood = NSLocalizedString("Petfood", comment: "Title of a segmented control.")
    static let PetFoodProducts = NSLocalizedString("Petfood Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
    static let Photographer = NSLocalizedString("Photographer", comment: "String in PickerViewController to indicate the photographer role of a contributor") + TranslatableStrings.Space + TranslatableStrings.PhotographerUnicode
    static let PhotographerUnicode = NSLocalizedString("📷", comment: "Image to indicate that the user took pictures of the product.")
    static let PlaceholderGenericProductName = NSLocalizedString("Enter the generic name of the product", comment: "Placeholder text of a textView for the generic product name.")
    static let PlaceholderProductNameSearch = NSLocalizedString("Search in name, generic name, label, brand.", comment: "String show to explain the purpose of a search field in a tableview cell")
    static let PlaceholderProductName = NSLocalizedString("Enter the name of the product", comment: "Placeholder text of a textView for the product name.")
    static let PlaceholderIngredients = NSLocalizedString("Enter the ingredients of the product", comment: "Placeholder text of a textView for the ingredients.")
    static let Popularity = NSLocalizedString("Popularity", comment: "String in picker, which lets the user select the search result order. Order on the popularity.")
    static let PortionSize = NSLocalizedString("Portion size", comment: "Tableview header section for the size of a portion")
    static let Preferences = NSLocalizedString("Preferences", comment: "TableViewController title for the settings scene.")
    static let PrefixCorrected = NSLocalizedString("Prefix corrected", comment: "Description of the prefixed corrected tags")
    static let PresentationFormat = NSLocalizedString("Presentation format", comment: "Tableview header for the section per unit shown, i.e. whether the nutrients are shown per 100 mg/ml or per portion.")
    static let Producers = NSLocalizedString("Producers", comment: "Header for section of tableView with information of the producer (name, geographic location).")
    static let Product = NSLocalizedString("Product", comment: "Title of a segmented control.")
    static let ProductCodes = NSLocalizedString("Producer Codes", comment: "Header for section of tableView with codes for the producer (EMB 123456 or FR.666.666).")
    static let ProductDefined = NSLocalizedString("Product Defined", comment: "Title of a segment in a UISegmentedControl, which indicates that the values of the product are leading.")
    static let ProductDoesNotExistAlertSheetMessage = NSLocalizedString("Product does not exist. Add?", comment: "Alert message, when the product could not be retrieved from Internet.")
    static let ProductDoesNotExistAlertSheetActionTitleForCancel = NSLocalizedString("Nope", comment: "Alert title, to indicate product should NOT be added")
    static let ProductDoesNotExistAlertSheetActionTitleForAdd = NSLocalizedString("Sure", comment: "Alert title, to indicate product should be added")
    static let ProductIsLoaded = NSLocalizedString("Product is loaded", comment: "String presented in a tagView if the product has been loaded")
    static let ProductIsUpdated = NSLocalizedString("Product is updated", comment: "String presented in a tagView if the product is updated")
    static let ProductLoading = NSLocalizedString("Product loading", comment: "String presented in a tagView if the product is currently being loaded")
    static let ProductLoadingFailed = NSLocalizedString("Product loading failed", comment: "String presented in a tagView if the product loading has failed")
    static let ProductListIsLoaded = NSLocalizedString("Product list is loaded", comment: "String presented in a tagView if the product list has been loaded")
    static let ProductName = NSLocalizedString("Product name", comment: "String in picker, which lets the user select the search result order. Order on the product names.")
    static let ProductNameMissing = NSLocalizedString("Product name missing", comment: "Secction title, to indicate the product name does not exist")
    static let ProductNotAvailable = NSLocalizedString("Product not available", comment: "String presented in a tagView if no product is available on OFF")
    static let ProductNotLoaded = NSLocalizedString("Product not loaded", comment: "String to indicate a product has not yet been retrieved from OFF yet and is only locally available")
    static let ProductTypePreferences = NSLocalizedString("Default product type", comment: "String to indicate a product has not yet been retrieved from OFF yet and is only locally available")
    static let ProductWebSites = NSLocalizedString("Official product website", comment: "Header title of tableview section, indicating the websites for the product")
    static let PurchaseAddress = NSLocalizedString("Purchase address", comment: "Generic string to indicate the address (street/city/postalcode/country) where the product was bought")
    
    static let OpenFoodFactsAccount = NSLocalizedString("Default OpenFoodFacts account", comment: "Title of a tableView section, which lets the user set the off account to use")
    static let OriginalImages = NSLocalizedString("Original Images", comment: "Gallery header text presenting the original images")
//
// MARK: - QQQQQQQQQQQQQQQQ strings
//
    
    static let Quantity = NSLocalizedString("Quantity", comment: "Tableview sectionheader for size of package.")
    
//
// MARK: - RRRRRRRRRRRRRRRR strings
//
    
    static let Reset = NSLocalizedString("Reset application", comment: "String in button, to let the user indicate he wants to cancel username/password input.")
    static let ResponseReceived = NSLocalizedString("Response received", comment: "String presented in a tagView if a response was received")
    static let RoleNotSelected = NSLocalizedString("not selected", comment: "Text of a button, indicating a contributor role is not selected")
    
//
// MARK: - SSSSSSSSSSSSSSSSS strings
//
    
    static let SalesCountries = NSLocalizedString("Countries where sold", comment: "Text to indicate the sales countries of a product.")
    static let Salt = NSLocalizedString("Salt", comment: "Title of first segment in switch, which lets the user select between salt or sodium")
    static let SaltOrSodiumPreferences = NSLocalizedString("Default for salt/sodium", comment: "Title of a tableView section, which lets the user select between salt or sodium")
    static let SampleGenericProductName = NSLocalizedString("This sample product shows you how a product is presented. Slide to the following pages, in order to see more product details. Once you start scanning barcodes, you will no longer see this sample product.", comment: "An explanatory text in the common name field.")
    static let SampleProductName = NSLocalizedString("Sample Product for Demonstration, the globally known M&M's", comment: "Product name of the product shown at first start")
    static let SaturatedFatToFatRatio = NSLocalizedString("Saturated Fat to Total Fat ratio", comment: "Title in cell with the saturated fat to all fat ratio")
    static let Save = NSLocalizedString("Save", comment: "Title of a button in an alert sheet, which allows the user to save any changes to the local product")
    // static let Search = NSLocalizedString("Search", comment: "Prefix of a title of a Tableview controller")
    static let SearchFoodProducts = NSLocalizedString("Search Food Products", comment: "Title of a Tableview controller, indicating the tableview shows search food products.")
    static let SearchProducts = NSLocalizedString("Search Products", comment: "Title of a Tableview controller, indicating the tableview shows search products.")
    //static let SearchInNameEtc = NSLocalizedString("Search in name, generic name, label, brand.", comment: "String show to explain the purpose of a search field in a tableview cell")
    static let SearchPetFoodProducts = NSLocalizedString("Search PetFood", comment: "Title of a Tableview controller, indicating the tableview shows search pet food products (note the width of the title is constrained).")
    static let SearchBeautyProducts = NSLocalizedString("Search Beauty Products", comment: "Title of a Tableview controller, indicating the tableview shows search beauty products.")
    static let Searching = NSLocalizedString("Searching", comment: "Title of a Tableview controller, indicating a search is in progress.")
    static let SearchLoading = NSLocalizedString("Search loading", comment: "String presented in a tagView if the search query is currently being loaded")
    static let SearchMessage = NSLocalizedString("for %@ in %@", comment: "Explanatory text in AlertViewController, which shows the intended search")
    static let SearchQuery = NSLocalizedString("Search query", comment: "String presented in a tagView for the search query")
    static let SearchResults = NSLocalizedString("search results", comment: "Part of a sentece indicating the number of search results")
    static let SearchSetup = NSLocalizedString("Search set up", comment: "Indicating that a search has been defined")
    static let SearchText = NSLocalizedString("Search Text", comment: "String to indicate the text, which will be used to search multiple fileds of a product.")
    static let Select = NSLocalizedString("Select", comment: "Title of a viewcontroller where the user has to select an element in the picker.")
    static let SelectCompletionStatus = NSLocalizedString("Select Completion Status", comment: "Title of a picker row where the user has to select an element in the picker.")
    static let SelectedFrontImages = NSLocalizedString("Selected Front Images", comment: "Gallery header text presenting the selected front images")
    static let SelectedIngredientImages = NSLocalizedString("Selected Ingredients Images", comment: "Gallery header text presenting the selected ingredients images")
    static let SelectedNutritionImages = NSLocalizedString("Selected Nutrition Images", comment: "Gallery header text presenting the selected nutrition images")
    static let SelectRole = NSLocalizedString("Select role", comment: "First item in a pickerView, indicating what the user should do")
    static let Serving = NSLocalizedString("Serving", comment: "Title of second segment in switch, which lets the user select between per standard unit (per 100 mg/ml / per serving / per daily value)")
    static let Set = NSLocalizedString("Set", comment: "Title of a segment in a segmentedControl indicating that the a search needs to be setup by tapping.")
    static let SetAccount = NSLocalizedString("Set Account", comment: "Title of second segment in switch, which  indicates the user can set another account")
    static let SetupQuery = NSLocalizedString("Setup query", comment: "Title of a tableview header  indicating that the corresding field has been set.")
    static let Sodium = NSLocalizedString("Sodium", comment: "Title of third segment in switch, which lets the user select between salt or sodium")
    static let SpecialCategories = NSLocalizedString("Special categories", comment: "Header for a table section showing the special categories")
    static let SpecifyYourCredentialsForOFF = NSLocalizedString("Specify your credentials for OFF", comment: "Explanatory text in AlertViewController, which lets the user enter his username/password.")
    static let SpecifyPassword = NSLocalizedString("Specify password",
                                                   comment: "Title in AlertViewController, which lets the user enter his username/password.")
    static let StartSearch = NSLocalizedString("Start Search?",
                                               comment: "Title in AlertViewController, which lets the user decide if he wants to start a search.")
    static let Stores = NSLocalizedString("Stores", comment: "Generic string to indicate the stores where the product is sold.")
    static let SupplyChain = NSLocalizedString("Supply Chain", comment: "Title for the view controller with information about the Supply Chain (origin ingredients, producer, shop, locations).")
    
//
// MARK: - TTTTTTTTTTTTTT strings
//
    
    static let Traces = NSLocalizedString("Traces", comment: "Text to indicate the traces of a product.")
    static let Translated = NSLocalizedString("Translated", comment: "Description of the interpreted tags in the json as translated by the taxonomy")
//
// MARK: - UUUUUUUUUUUUUUUU strings
//
    
    static let UnbalancedWarning = NSLocalizedString(" (WARNING: check brackets, they are unbalanced)", comment: "a warning to check the brackets used, they are unbalanced")
    static let Undefined = NSLocalizedString("Undefined", comment: "String (in Segmented Control/Tag) to indicate the nutritional score level is undefined (and will not be used in the search)")
    static let Unknown = NSLocalizedString("Unknown", comment: "Text in a TagListView, when the field in the json was not present.")
    static let UnknownValue = TranslatableStrings.QuestionMark
    static let UploadingImage = NSLocalizedString("Uploading image", comment: "String presented in a tagView if an image is being uploaded")
    static let Use = NSLocalizedString("Use", comment: "Title of a button in a navigation bar, which allows the user to adapt an image and use the result.")
    static let Username = NSLocalizedString("Username", comment: "String in textField placeholder, to show that the user has to enter his username.")
    static let UserDefined = NSLocalizedString("User defined", comment: "Title of a segment in a segmentedControl that this parameter will be set by the user.")
    static let USSet = NSLocalizedString("US Set", comment: "String of a button, to prefill the nutrients with the standard US set.")

    static let Warnings = NSLocalizedString("Set ingredient warnings", comment: "Title of a tableView section, which lets the user set warnings")
    
//
// MARK: - Other strings
//
    static let QuestionMark = NSLocalizedString("?", comment: "a questionmark used for several purposes")
    static let Space = NSLocalizedString(" ", comment: "a space used for several purposes")

}




