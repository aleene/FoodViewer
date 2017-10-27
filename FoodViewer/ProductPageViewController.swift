 //
//  ProductPageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 06/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import LocalAuthentication

class ProductPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ProductUpdatedProtocol {
    
// MARK: - Interface Actions
    
    @IBOutlet weak var confirmBarButtonItem: UIBarButtonItem!
    
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
            
        var sharingItems = [AnyObject]()
            
        if let text = product?.name {
            sharingItems.append(text as AnyObject)
        }
        // add the front image for the primary languageCode if any
        if let languageCode = product?.primaryLanguageCode {
            if let image = product?.frontImages[languageCode]?.small?.image {
                sharingItems.append(image)
            }
        }
        
        if let url = product?.regionURL() {
            sharingItems.append(url as AnyObject)
        }
            
        let activity = TUSafariActivity()
            
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: [activity])
            
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.print, UIActivityType.openInIBooks, UIActivityType.assignToContact, UIActivityType.addToReadingList]
            
        // This is necessary for the iPad
        let presCon = activityViewController.popoverPresentationController
        presCon?.barButtonItem = sender
            
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIBarButtonItem) {
        if editMode {
            // the user was editing AND tapped the save button
            userWantsToSave = true
            // wait a few seconds, so the other processes (UITextField, UITextView) have time to finish
            //Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ProductPageViewController.saveUpdatedProduct), userInfo: nil, repeats: false)
            self.view.endEditing(true)
            if isQuery {
                // start a new search
                OFFProducts.manager.startSearch()
            } else {
                if OFFAccount().personalExists() {
                    // maybe the user has to authenticate himself before continuing
                    authenticate()
                }
                
                // Saving can be done
                saveUpdatedProduct()
            }
        }
        editMode = !editMode
    }
    
// MARK: - Save product functions

    private var userWantsToSave = false
    
    func saveUpdatedProduct() {
        // Current mode
        if editMode {
            if userWantsToSave {
                // time to save
                if let validUpdatedProduct = updatedProduct {
                    let update = OFFUpdate()
                    confirmBarButtonItem?.isEnabled = false
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true

                    // TBD kan de queue stuff niet in OFFUpdate gedaan worden?
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                        let fetchResult = update.update(product: validUpdatedProduct)
                        DispatchQueue.main.async(execute: { () -> Void in
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            switch fetchResult {
                            case .success:
                                // get the new product data
                                OFFProducts.manager.reload(self.product!)
                                self.updatedProduct = nil
                                // send notification of success, so feedback can be given
                                NotificationCenter.default.post(name: .ProductUpdateSucceeded, object:nil)
                                break
                            case .failure:
                                // send notification of failure, so feedback can be given
                                NotificationCenter.default.post(name: .ProductUpdateFailed, object:nil)
                                break
                            }
                            self.confirmBarButtonItem?.isEnabled = true
                        })
                    })
                }
                userWantsToSave = false
            }
        }
    }
//
// MARK: - Public variables and functions
//
    
    public var tableItem: Any? = nil {
        didSet {
            if let item = tableItem as? FoodProduct {
                self.product = item
                self.query = nil
            } else if let item = tableItem as? SearchTemplate {
                self.query = item
                self.product = nil
            }
        }
    }

    private var product: FoodProduct? = nil {
        didSet {
            if oldValue == nil && product != nil {
            // has the product been initailised?
                setCurrentLanguage()
                //setupProduct()
            } else if oldValue != nil && product != nil && oldValue!.barcode.asString() != product!.barcode.asString() {
            // was there a product change?
                setCurrentLanguage()
            } // otherwise the language can not be set
        }
    }
    
    private var query: SearchTemplate? = nil
    
    private var isQuery: Bool {
        return query != nil
    }

    var pageIndex: ProductSection = .identification {
        didSet {
            if pageIndex != oldValue {
                // has the initialisation been done?
                if pages.isEmpty {
                    initPages()
                }
                if let oldIndex = pages.index(where: { $0 == oldValue } ),
                    let newIndex = pages.index(where: { $0 == pageIndex } ) {
                    // open de corresponding page
                    if newIndex > oldIndex {
                        setViewControllers(
                            [viewController(for:pageIndex)],
                            direction: .forward,
                            animated: true, completion: nil)
                    } else {
                        setViewControllers(
                            [viewController(for:pageIndex)],
                            direction: .reverse,
                            animated: true, completion: nil)
                    }
                }
            } else {
                setViewControllers(
                    [viewController(for:pageIndex)],
                    direction: .forward,
                    animated: true, completion: nil)
            }
            
            initPage(pageIndex)
            title = pageIndex.description()
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    
    // The languageCode for the language in which the fields are shown
    fileprivate var currentLanguageCode: String? = nil {
        didSet {
            // pass the changed language on
            if currentLanguageCode != oldValue {
                setupCurrentLanguage()
            }
        }
    }

    fileprivate var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                // change look edit button
                let test = isQuery ? "Search" : "CheckMark"
                if let image = UIImage.init(named: editMode ? test : "Edit") {
                    confirmBarButtonItem.image = image
                }

                setupEditMode()
            }
        }
    }
    
    private func type(for viewController: UIViewController) -> ProductSection {
        
        if viewController is IdentificationTableViewController {
            return .identification
        
        } else if viewController is IngredientsTableViewController {
            return .ingredients
                
        } else if viewController is NutrientsTableViewController {
            return .nutritionFacts
                
        } else if viewController is SupplyChainTableViewController {
            return .supplyChain
                
        } else if viewController is CategoriesTableViewController {
            return .categories
                
        } else if viewController is NutritionScoreTableViewController {
            return .nutritionScore
                
        } else if viewController is CompletionStatesTableViewController {
            return .completion
                
        } else if viewController is ProductImagesCollectionViewController {
                return .gallery
            
        } else {
            return .identification
        }

    }
    //
    // MARK: - Init the individual pages
    //

    private var pages: [ProductSection] = []

    private func initPages() {
        // define the pages (and order), which will be shown
        switch currentProductType {
        case .food:
            if isQuery {
                // search page has no gallery
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories,
                         .nutritionScore, .completion]
            } else {
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories,
                         .gallery, .nutritionScore, .completion]
            }
        case .beauty:
            if isQuery {
                // search page has no gallery
                pages = [.identification, .ingredients, .supplyChain, .categories, .completion]
            } else {
                pages = [.identification, .ingredients, .supplyChain, .categories, .gallery, .completion]
            }
        case .petFood:
            if isQuery {
                // search page has no gallery
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories, .completion]
            } else {
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories, .gallery, .completion]
            }
        }
    }
    
    private func setupDelegates() {
        identificationVC.delegate = self
        ingredientsVC.delegate = self
        nutritionFactsVC.delegate = self
        supplyChainVC.delegate = self
        categoriesVC.delegate = self
        completionStatusVC.delegate = self
        nutritionScoreVC.delegate = self
        galleryVC.delegate = self
    }
    
    private func setupProduct() {
        ingredientsVC.tableItem = tableItem
        identificationVC.tableItem = tableItem
        nutritionFactsVC.tableItem = tableItem
        supplyChainVC.tableItem = tableItem
        categoriesVC.tableItem = tableItem
        nutritionScoreVC.tableItem = tableItem
        completionStatusVC.tableItem = tableItem
        galleryVC.product = product
    }

    private func setupEditMode() {
        // pass changed value on
        identificationVC.editMode = editMode
        ingredientsVC.editMode = editMode
        nutritionFactsVC.editMode = editMode
        supplyChainVC.editMode = editMode
        categoriesVC.editMode = editMode
        nutritionScoreVC.editMode = editMode
        completionStatusVC.editMode = editMode
        galleryVC.editMode = editMode
    }
    
    private func setupCurrentLanguage() {
        identificationVC.currentLanguageCode = currentLanguageCode
        ingredientsVC.currentLanguageCode = currentLanguageCode
        nutritionFactsVC.currentLanguageCode = currentLanguageCode
    }

    // This function finds the language that must be used to display the product
    private func setCurrentLanguage() {
        // is there already a current language?
        guard currentLanguageCode == nil else { return }
        // find the first preferred language that can be used
        for languageLocale in Locale.preferredLanguages {
            // split language and locale
            let preferredLanguage = languageLocale.characters.split{$0 == "-"}.map(String.init)[0]
            if let languageCodes = product?.languageCodes {
                if languageCodes.contains(preferredLanguage) {
                    currentLanguageCode = preferredLanguage
                    // found a valid code
                    return
                }
            }
        }
        // there is no match between preferred languages and product languages
        if currentLanguageCode == nil {
            currentLanguageCode = product?.primaryLanguageCode
        }
    }

    private func initPage(_ page: ProductSection) {
        
        // setup individual pages
        switch page {
        case .identification:
            identificationVC.delegate = self
            identificationVC.tableItem = tableItem
            identificationVC.currentLanguageCode = currentLanguageCode
            identificationVC.editMode = editMode
            
        case .ingredients:
            ingredientsVC.delegate = self
            ingredientsVC.tableItem = tableItem
            ingredientsVC.editMode = editMode
            ingredientsVC.currentLanguageCode = currentLanguageCode
            
        case .nutritionFacts:
            nutritionFactsVC.delegate = self
            nutritionFactsVC.tableItem = tableItem
            nutritionFactsVC.currentLanguageCode = currentLanguageCode
            nutritionFactsVC.editMode = editMode
            
        case .supplyChain:
            supplyChainVC.delegate = self
            supplyChainVC.tableItem = tableItem
            supplyChainVC.editMode = editMode
            
        case .categories:
            categoriesVC.delegate = self
            categoriesVC.tableItem = tableItem
            categoriesVC.editMode = editMode
            
        case .nutritionScore:
            nutritionScoreVC.tableItem = tableItem
            nutritionScoreVC.delegate = self
            
        case .completion :
            completionStatusVC.tableItem = tableItem
            completionStatusVC.delegate = self
            
        case .gallery:
            galleryVC.delegate = self
            galleryVC.product = product
            galleryVC.editMode = editMode
        }
        
    }
    
    // MARK: - ViewController
    
    fileprivate struct Constants {
        static let StoryBoardIdentifier = "Main"
        static let IdentificationVCIdentifier = "IdentificationTableViewController"
        static let IngredientsVCIdentifier = "IngredientsTableViewController"
        static let NutrientsVCIdentifier = "NutrientsTableViewController"
        static let SupplyChainVCIdentifier = "SupplyChainTableViewController"
        static let CategoriesVCIdentifier = "CategoriesTableViewController"
        static let CommunityEffortVCIdentifier = "CommunityEffortTableViewController"
        static let NutritionalScoreVCIdentifier = "NutritionScoreTableViewController"
        static let ProductImagesVCIndentifier = "ProductImagesCollectionViewController"
        static let ConfirmProductViewControllerSegue = "Confirm Product Segue"
    }
    

    private func viewController(for section: ProductSection) -> UIViewController {
        switch section {
        case .identification:
            return identificationVC
        case .ingredients:
            return ingredientsVC
        case .gallery:
            return galleryVC
        case .nutritionFacts:
            return nutritionFactsVC
        case .nutritionScore:
            return nutritionScoreVC
        case .categories:
            return categoriesVC
        case .completion:
            return completionStatusVC
        case .supplyChain:
            return supplyChainVC
        }
    }
    
    fileprivate let identificationVC: IdentificationTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.IdentificationVCIdentifier) as! IdentificationTableViewController

    fileprivate let ingredientsVC: IngredientsTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.IngredientsVCIdentifier) as! IngredientsTableViewController
    
    fileprivate let nutritionFactsVC: NutrientsTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutrientsVCIdentifier) as! NutrientsTableViewController
    
    fileprivate let supplyChainVC: SupplyChainTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.SupplyChainVCIdentifier) as! SupplyChainTableViewController
    
    fileprivate let categoriesVC: CategoriesTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CategoriesVCIdentifier) as! CategoriesTableViewController
    
    fileprivate let completionStatusVC: CompletionStatesTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CommunityEffortVCIdentifier) as! CompletionStatesTableViewController
    
    fileprivate let nutritionScoreVC: NutritionScoreTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutritionalScoreVCIdentifier) as! NutritionScoreTableViewController

    fileprivate let galleryVC: ProductImagesCollectionViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.ProductImagesVCIndentifier) as! ProductImagesCollectionViewController

//
//          MARK: - Pageview Controller DataSource Functions
//

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = pages.index(where: { $0 == type(for: viewController) } ) {
            
            guard pages.count != viewControllerIndex + 1 else {
                return nil
            }
            
            guard pages.count > viewControllerIndex + 1 else {
                return nil
            }
            return self.viewController(for:pages[viewControllerIndex + 1])

        } else {
            return nil
        }
        
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = pages.index(where: { $0 == type(for: viewController) } ) {

            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
            return nil
            }
            
            guard pages.count > previousIndex else {
                return nil
            }
        
            return self.viewController(for:pages[previousIndex])
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                                     willTransitionTo pendingViewControllers: [UIViewController]) {
        // inform us what is happening, so the page can be setup
        if !pendingViewControllers.isEmpty && pendingViewControllers.first != nil {
            pageIndex = type(for: pendingViewControllers.first!)
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
        
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.index(where: { $0 == pageIndex } ) ?? 0
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        title = pageIndex.description()
    }
    
    // MARK: - Notification Functions
        
    func loadFirstProduct() {
    // handle a notification that the first product has been set
    // this sets the current product and shows the first page
        let products = OFFProducts.manager
        if !products.fetchResultList.isEmpty {
            switch products.fetchResultList[0] {
            case .success(let firstItem):
                tableItem = firstItem
                pageIndex = .identification
                initPage(pageIndex)
            default: break
            }
        }
    }
    
    func changeConfirmButtonToSuccess() {
        confirmBarButtonItem.tintColor = .green
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToSuccess), name:.ProductUpdateSucceeded, object:nil)

        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ProductPageViewController.resetSaveButtonColor), userInfo: nil, repeats: false)
        updatedProduct = nil
    }
  
    func changeConfirmButtonToFailure() {
        confirmBarButtonItem.tintColor = .red
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ProductPageViewController.resetSaveButtonColor), userInfo: nil, repeats: false)
    }
    
    // function to reset the SaveButton to the default IOS color
    func resetSaveButtonColor() {
        confirmBarButtonItem.tintColor = self.view.tintColor
    }
    
    // MARK: - Product Updated Protocol functions

    // The updated product contains only those fields that have been edited.
    // Thus one can always revert to the original product
    // And we know exactly what has changed
    // The user can undo an edit in progress by stepping back, i.e. selecting another product
    // First it is checked whether a change to the field has been made
    
    var updatedProduct: FoodProduct? = nil // Stays nil when no changes are made

    func updated(name: String, languageCode: String) {
        guard product != nil else { return }
        if !product!.contains(name: name, for: languageCode) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.set(newName: name, for: languageCode)
            saveUpdatedProduct()
        }
    }
    
    func updated(genericName: String, languageCode: String) {
        guard product != nil else { return }
        if !product!.contains(genericName: genericName, for: languageCode) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.set(newGenericName: genericName, for: languageCode)
            saveUpdatedProduct()
        }
    }
    
    func updated(searchText: String) {
        guard product != nil else { return }
        initUpdatedProductWith(product: product!)
        // updatedProduct?.searchText = searchText
        saveUpdatedProduct()
    }

    func updated(ingredients: String, languageCode: String) {
        guard product != nil else { return }
        if !product!.contains(ingredients: ingredients, in:languageCode) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.set(newIngredients: ingredients, for: languageCode)
            saveUpdatedProduct()
        }
    }
    
    func updated(portion: String) {
        guard product != nil else { return }
        if !product!.contains(servingSize: portion) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.servingSize = portion
            saveUpdatedProduct()
        }
    }

    func updated(barcode: String) {
        guard product != nil else { return }
        if !product!.contains(barcode: barcode) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.barcode.string(barcode)
            saveUpdatedProduct()
        }
    }
    
    func updated(expirationDate: Date) {
        guard product != nil else { return }
        if !product!.contains(expirationDate: expirationDate) {
            initUpdatedProductWith(product: product!)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            updatedProduct?.expirationDateString = formatter.string(from: expirationDate)
            saveUpdatedProduct()
        }
    }
    
    func updated(expirationDateString: String) {
        guard product != nil else { return }
        if !product!.contains(expirationDateString: expirationDateString) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.expirationDateString = expirationDateString
            saveUpdatedProduct()
        }
    }

    func updated(primaryLanguageCode: String) {
        guard product != nil else { return }
        if !product!.contains(primaryLanguageCode: primaryLanguageCode) {
            initUpdatedProductWith(product: product!)
            // what happens if the primary language is already an existing language?
            if !product!.contains(languageCode: primaryLanguageCode) {
                // add a NEW language
                updatedProduct?.add(languageCode: primaryLanguageCode)
            } else {
                // use the existing language
                // copy existing fields so that they can be edited
                if let validName = product!.nameLanguage[primaryLanguageCode] {
                    if let name = validName {
                        updated(name: name, languageCode: primaryLanguageCode)
                    }
                }
                if let name = product?.genericNameLanguage[primaryLanguageCode] {
                    if let validGenericName = name  {
                        updated(genericName: validGenericName, languageCode: primaryLanguageCode)
                    }
                }
                if let validIngredients = product!.ingredientsLanguage[primaryLanguageCode]{
                    updated(ingredients: validIngredients, languageCode: primaryLanguageCode)
                }
            }
            // now it is possible to change the primary languageCode
            updatedProduct?.primaryLanguageCode = primaryLanguageCode
            saveUpdatedProduct()
            currentLanguageCode = primaryLanguageCode
        }
    }

    func update(addLanguageCode languageCode: String) {
        guard product != nil else { return }
        if !product!.contains(languageCode: languageCode) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.add(languageCode: languageCode)
            saveUpdatedProduct()
        }
    }

    func update(shop: (String, Address)?) {
        if let validShop = shop {
            guard product != nil else { return }
            if !product!.contains(shop: validShop.0) {
                initUpdatedProductWith(product: product!)
                switch product!.storesOriginal {
                case .available(var currentStores):
                    currentStores.append(validShop.0)
                    updatedProduct?.storesOriginal = .available(currentStores)
                default:
                    updatedProduct?.storesOriginal = .available([validShop.0])
                }
            }
            // replace the new product place in all cases 
            updatedProduct?.purchasePlacesAddress = Address.init(with: validShop)
            if let purchasePlace = updatedProduct?.purchasePlacesAddress?.asSingleString(withSeparator: ",") {
                updatedProduct?.purchasePlacesOriginal = Tags.init(purchasePlace)
            }
            saveUpdatedProduct()
        }
    }
    
    func update(brandTags: [String]?) {
        if let validTags = brandTags {
            guard product != nil else { return }
            // Have the tags changed?
            if !product!.contains(brands: validTags) {
                // create an updated product if needed
                initUpdatedProductWith(product: product!)
                // should the include be added
                updatedProduct?.brandsOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }

    func update(packagingTags: [String]?) {
        if let validTags = packagingTags {
            guard product != nil else { return }
            if !product!.contains(packaging: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.packagingOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }
    
    func update(tracesTags: [String]?) {
        if let validTags = tracesTags {
            guard product != nil else { return }
            if !product!.contains(traces: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.tracesOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }

    func update(labelTags: [String]?) {
        if let validTags = labelTags {
            guard product != nil else { return }
            if !product!.contains(labels: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.labelsOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }
    
    func update(categories: [String]?) {
        if let validTags = categories {
            guard product != nil else { return }
            if !product!.contains(categories: validTags) {
                initUpdatedProductWith(product: product!)
                if validTags.isEmpty {
                    updatedProduct?.categoriesOriginal = .empty
                } else {
                    updatedProduct?.categoriesOriginal = .available(validTags)
                }
                saveUpdatedProduct()
            }
        }
    }

    func update(producer: [String]?) {
        if let validTags = producer {
            guard product != nil else { return }
            if !product!.contains(producer: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.manufacturingPlacesOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }

    func update(producerCode: [String]?) {
        if let validTags = producerCode {
            guard product != nil else { return }
            if !product!.contains(producerCode: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.embCodesOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }
    
    func update(ingredientsOrigin: [String]?) {
        if let validTags = ingredientsOrigin {
            guard product != nil else { return }
            if !product!.contains(ingredientsOrigin: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.originsOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }

    func update(stores: [String]?) {
        if let validTags = stores {
            guard product != nil else { return }
            if !product!.contains(stores: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.storesOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }
    
    func update(purchaseLocation: [String]?) {
        if let validTags = purchaseLocation {
            guard product != nil else { return }
            if !product!.contains(purchaseLocation: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct?.purchasePlacesOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }

    func update(countries: [String]?) {
        if let validTags = countries {
            guard product != nil else { return }
            guard !validTags.isEmpty else { return }
            switch product!.countriesOriginal {
            case .available:
                if !product!.contains(purchaseLocation: validTags) {
                    initUpdatedProductWith(product: product!)
                    updatedProduct?.countriesOriginal = .available(validTags)
                    saveUpdatedProduct()
                }
            default:
                initUpdatedProductWith(product: product!)
                updatedProduct?.countriesOriginal = .available(validTags)
                saveUpdatedProduct()
            }
        }
    }
    
    func update(quantity: String) {
        guard product != nil else { return }
        if !product!.contains(quantity: quantity) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.quantity = quantity
            saveUpdatedProduct()
        }
    }
    
    func update(periodAfterOpeningString: String) {
        guard product != nil else { return }
        if !product!.contains(periodAfterOpeningString: periodAfterOpeningString) {
            initUpdatedProductWith(product: product!)
            updatedProduct?.periodAfterOpeningString = periodAfterOpeningString
            saveUpdatedProduct()
        }
    }


    func update(links: [String]?) {
        if let validTags = links {
            guard product != nil else { return }
            if !product!.contains(links: validTags) {
                initUpdatedProductWith(product: product!)
                updatedProduct!.links = []
                for tag in validTags {
                    if let validURL = URL.init(string:tag) {
                        updatedProduct!.links!.append(validURL)
                    }
                }
                saveUpdatedProduct()
            }
        }
    }
    
    func updated(availability: Bool) {
        guard product != nil else { return }
        initUpdatedProductWith(product: product!)
        updatedProduct?.hasNutritionFacts = availability
        saveUpdatedProduct()
    }
    
    func updated(fact: NutritionFactItem?) {
        if let validFact = fact {
            guard product != nil else { return }
            // initialize an updated product if it does not exist yet
            initUpdatedProductWith(product: product!)
            // editing or first nutrient of product
            if let originalFacts = product?.nutritionFacts {
                // there were already some facts
                if updatedProduct?.nutritionFacts == nil {
                    // first edit
                    updatedProduct?.nutritionFacts = Array.init(repeating: nil, count: originalFacts.count)
                }
                var factExists = false
                // has an existing fact been edited?
                for (index, currentFact) in originalFacts.enumerated() {
                    if currentFact?.key == fact?.key {
                        updatedProduct?.nutritionFacts?[index] = fact
                        factExists = true
                        break
                    }
                }
                // the fact does not exist yet
                if !factExists {
                    for (index, currentFact) in updatedProduct!.nutritionFacts!.enumerated() {
                        if currentFact?.key == fact?.key {
                            updatedProduct?.nutritionFacts?[index] = fact
                            factExists = true
                            break
                        }
                    }
                    if !factExists {
                        // add it to both arrays
                        updatedProduct?.nutritionFacts?.append(fact)
                        product!.nutritionFacts?.append(nil)
                    }
                }
            } else {
                // no facts are available for this product
                if updatedProduct?.nutritionFacts == nil {
                    // add the first fact
                    updatedProduct?.nutritionFacts = [validFact]
                } else {
                    // has an existing edited fact been edited again
                    var factExists = false
                    for (index, currentFact) in updatedProduct!.nutritionFacts!.enumerated() {
                        if currentFact?.key == fact?.key {
                            updatedProduct?.nutritionFacts?[index] = fact
                            factExists = true
                            break
                        }
                    }
                    // if the fact has not been found, add it
                    if !factExists {
                        // add it to both arrays
                        updatedProduct?.nutritionFacts?.append(fact)
                        product!.nutritionFacts = Array.init(repeating: nil, count: 1)
                    }
                }
            }
            saveUpdatedProduct()
        }
    }

    func updated(facts: [NutritionFactItem?]) {
        // TODO: need to check if a fact has been updated
        
        initUpdatedProductWith(product: product!)
        // make sure we have an nillified nutritionFacts array
        if updatedProduct!.nutritionFacts == nil {
            // the new array should be based on the size of the edited array
            updatedProduct!.nutritionFacts = Array.init(repeating: nil, count: facts.count)
        } else {
            // make sure the updated nutritionFacts array is long enough
            for _ in updatedProduct!.nutritionFacts!.count ..< facts.count {
                updatedProduct!.nutritionFacts!.append(nil)
            }
        }
        
        // only replace the fact that has been edited
        for (index, fact) in facts.enumerated() {
            if fact != nil {
                updatedProduct?.nutritionFacts![index] = fact
            }
        }
        // make sure both nutritionFacts arrays have the same length
        for _ in product!.nutritionFacts!.count ..< updatedProduct!.nutritionFacts!.count {
            product!.nutritionFacts!.append(nil)
        }
        saveUpdatedProduct()
    }

    func updated(frontImage: UIImage, languageCode: String) {
        initUpdatedProductWith(product: product!)
        updatedProduct!.frontImages[languageCode] = ProductImageSize()
        updatedProduct!.frontImages[languageCode]?.original = ProductImageData.init(image: frontImage)
        saveUpdatedProduct()
    }

    func updated(nutritionImage: UIImage, languageCode: String) {
        initUpdatedProductWith(product: product!)
        updatedProduct!.nutritionImages[languageCode] = ProductImageSize()
        updatedProduct!.nutritionImages[languageCode]?.original = ProductImageData.init(image: nutritionImage)
        saveUpdatedProduct()
    }

    func updated(ingredientsImage: UIImage, languageCode: String) {
        initUpdatedProductWith(product: product!)
        updatedProduct!.ingredientsImages[languageCode] = ProductImageSize()
        updatedProduct!.ingredientsImages[languageCode]?.original = ProductImageData.init(image: ingredientsImage)
        saveUpdatedProduct()
    }

    func updated(image: UIImage, id: String) {
        initUpdatedProductWith(product: product!)
        updatedProduct!.images[id] = ProductImageSize()
        updatedProduct!.images[id]?.display = ProductImageData.init(image: image)
        saveUpdatedProduct()
    }

    private func initUpdatedProductWith(product: FoodProduct) {
        if updatedProduct == nil {
            updatedProduct = FoodProduct.init(product:product)
        }
        saveUpdatedProduct()
    }
    
    // MARK: - Authentication
    
    private func authenticate() {
        
        // Is authentication necessary?
        // only for personal accounts and has not yet authenticated
        if OFFAccount().personalExists() && !Preferences.manager.userDidAuthenticate {
            // let the user ID himself with TouchID
            let context = LAContext()
            // The username and password will then be retrieved from the keychain if needed
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                // the device knows TouchID
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Logging in with Touch ID", reply: {
                    (success: Bool, error: Error? ) -> Void in
                    
                    // 3. Inside the reply block, you handling the success case first. By default, the policy evaluation happens on a private thread, so your code jumps back to the main thread so it can update the UI. If the authentication was successful, you call the segue that dismisses the login view.
                    
                    // DispatchQueue.main.async(execute: {
                    if success {
                        Preferences.manager.userDidAuthenticate = true
                    } else {
                        self.askPassword()
                    }
                    // } )
                } )
            }
            
        }
        // The login stuff has been done for the duration of this app run
        // so we will not bother the user any more
        Preferences.manager.userDidAuthenticate = true
    }
    
    fileprivate var password: String? = nil
    
    private func askPassword() {
        
        let alertController = UIAlertController(title: NSLocalizedString("Specify password",
                                                                         comment: "Title in AlertViewController, which lets the user enter his username/password."),
                                                message: NSLocalizedString("Authentication with TouchID failed. Specify your password",
                                                                           comment: "Explanatory text in AlertViewController, which lets the user enter his username/password."),
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: NSLocalizedString("Reset",
                                                                   comment: "String in button, to let the user indicate he wants to cancel username/password input."),
                                          style: .default)
        { action -> Void in
            // set the foodviewer selected index
            OFFAccount().removePersonal()
            Preferences.manager.userDidAuthenticate = false
        }
        
        let useMyOwn = UIAlertAction(title: NSLocalizedString("Done", comment: "String in button, to let the user indicate he is ready with username/password input."), style: .default)
        { action -> Void in
            // I should check the password here
            if let validString = self.password {
                Preferences.manager.userDidAuthenticate = OFFAccount().check(password: validString) ? true : false
            }
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 0
            textField.placeholder = NSLocalizedString("Password", comment: "String in textField placeholder, to show that the user has to enter his password")
            textField.delegate = self
        }
        
        alertController.addAction(useFoodViewer)
        alertController.addAction(useMyOwn)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    /*
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.ConfirmProductViewControllerSegue:
                if let ppvc = segue.destination as? ConfirmProductTableViewController {
                    ppvc.product = product
                }
            default: break
            }
        }
    }
  */
        
    // MARK: TBD This is not very elegant
        
    @IBAction func unwindSetLanguageForCancel(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageViewController {
            // currentLanguageCode = vc.currentLanguageCode
            // updateCurrentLanguage()
            if vc.sourcePage > 0 && vc.sourcePage < pages.count {
                pageIndex = pages[vc.sourcePage]
            } else {
                pageIndex = .identification
            }
        }
    }
        
    @IBAction func unwindSetLanguageForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageViewController {
            currentLanguageCode = vc.selectedLanguageCode
//            update(addLanguageCode: vc.selectedLanguageCode!)
            if vc.sourcePage > 0 && vc.sourcePage < pages.count {
                pageIndex = pages[vc.sourcePage]
            } else {
                pageIndex = .identification
            }
        }
    }
    
    @IBAction func unwindConfirmProductForDone(_ segue:UIStoryboardSegue) {
    }
        
        
    func updateCurrentLanguage() {
        if let index = pages.index(where: { $0 == .identification } ),
            let vc = viewController(for: pages[index]) as? IdentificationTableViewController {
            vc.currentLanguageCode = currentLanguageCode
        }
        if let index = pages.index(where: { $0 == .ingredients } ),
            let vc = viewController(for: pages[index]) as? IngredientsTableViewController {
            vc.currentLanguageCode = currentLanguageCode
        }
        if let index = pages.index(where: { $0 == .nutritionFacts } ),
            let vc = viewController(for: pages[index]) as? NutrientsTableViewController {
            vc.currentLanguageCode = currentLanguageCode
        }

    }
    
    func search(for string: String?, in component: SearchComponent) {
        if let validString = string {
            askUserToSearch(for: validString, in: component)
        }
    }
    
    func askUserToSearch(for string: String, in component: SearchComponent) {
        let searchMessage = TranslatableStrings.SearchMessage
        
        let parts = string.characters.split{$0 == ":"}.map(String.init)
        var stringToUse = ""
        if parts.count >= 2 {
            stringToUse = parts[1]
        } else if parts.count >= 1 {
            stringToUse = parts[0]
        }
        
        let alertController = UIAlertController(title: TranslatableStrings.StartSearch,
                                                message: String(format: searchMessage, stringToUse, component.description),
                                                preferredStyle:.alert)
        let ok = UIAlertAction(title: TranslatableStrings.OK,
                               style: .default)
        { action -> Void in
            self.startSearch(for: string, in: component)
        }
        
        let cancel = UIAlertAction(title: TranslatableStrings.Cancel, style: .default)
        { action -> Void in
            
        }
        
        alertController.addAction(cancel)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    internal func startSearch(for string: String, in component: SearchComponent) {
        OFFProducts.manager.search(string, in:component)
    }

    // MARK: - ViewController Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setProductListButton()
        
        dataSource = self
        delegate = self
        
        if pages.isEmpty {
            initPages()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = pageIndex.description() // Make sure there is an initial title

        // listen if a product is set outside of the MasterViewController
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToSuccess), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToFailure), name:.ProductUpdateFailed, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
        
}

// Definition:
extension Notification.Name {
    static let ProductUpdateSucceeded = Notification.Name("Product Update Succeeded")
    static let ProductUpdateFailed = Notification.Name("Product Update Failed")
}

// MARK: - TextField Delegation Functions

extension ProductPageViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // username
        switch textField.tag {
        case 0:
            if let validText = textField.text {
                password = validText
            }
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }

}
