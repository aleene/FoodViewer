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

    fileprivate struct Constants {
        static let StoryBoardIdentifier = "Main"
        static let IdentificationVCIdentifier = "IdentificationTableViewController"
        static let IngredientsVCIdentifier = "IngredientsTableViewController"
        static let NutrientsVCIdentifier = "NutrientsTableViewController"
        static let SupplyChainVCIdentifier = "SupplyChainTableViewController"
        static let CategoriesVCIdentifier = "CategoriesTableViewController"
        static let CommunityEffortVCIdentifier = "CommunityEffortTableViewController"
        static let NutritionalScoreVCIdentifier = "NutritionScoreTableViewController"
        static let ConfirmProductViewControllerSegue = "Confirm Product Segue"
    }
    
    // The languageCode for the language in which the fields are shown
    fileprivate var currentLanguageCode: String? = nil {
        didSet {
            // if a valid page is presented, the currentLanguageCode can be passed on
            guard pageIndex != nil else { return }
            if currentLanguageCode != oldValue {
                if let vc = pages[0] as? IdentificationTableViewController {
                    vc.currentLanguageCode = currentLanguageCode
                }
                if let vc = pages[1] as? IngredientsTableViewController {
                    vc.currentLanguageCode = currentLanguageCode
                }
                
                // not relevant for openBeautyFacts, but fails gently in that case
                if let vc = pages[2] as? NutrientsTableViewController {
                    vc.currentLanguageCode = currentLanguageCode
                }
            }
        }
    }
    
    // MARK: - Interface Actions
    
    @IBOutlet weak var confirmBarButtonItem: UIBarButtonItem!
    
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
            
        var sharingItems = [AnyObject]()
            
        if let text = product?.name {
            sharingItems.append(text as AnyObject)
        }
        // add the front image for the primary languageCode if any
        if let languageCode = product?.primaryLanguageCode {
            if let image = product?.frontImages?.small[languageCode]?.image {
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
            // Saving can be done
            saveUpdatedProduct()
        }
        editMode = !editMode
    }
    
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
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    fileprivate var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                confirmBarButtonItem.image = editMode ? UIImage.init(named: "CheckMark") : UIImage.init(named: "Edit")
                // pushdown any change
                if let vc = pages[0] as? IdentificationTableViewController {
                    vc.editMode = editMode
                }
                if let vc = pages[1] as? IngredientsTableViewController {
                    vc.editMode = editMode
                }
                // not relevant for openBeautyFacts, but fails gently in that case
                if let vc = pages[2] as? NutrientsTableViewController {
                    vc.editMode = editMode
                }
                
                var index = 0
                switch currentProductType {
                case .food, .petFood:
                    index += 3
                case .beauty:
                    index += 2
                }
                
                if let vc = pages[index] as? SupplyChainTableViewController {
                    vc.editMode = editMode
                }
                if let vc = pages[index + 1] as? CategoriesTableViewController {
                    vc.editMode = editMode
                }
            }
        }
    }

    // MARK: - Pages initialization
    
    var pageIndex: Int? = nil {
        didSet {
            if pageIndex != oldValue {
                // has the initialisation been done?
                if pages.isEmpty {
                    initPages()
                }
                
                // do we have a valid pageIndex?
                if pageIndex == nil {
                    pageIndex = 0
                } else if pageIndex! < 0 || pageIndex! > pages.count - 1 {
                    pageIndex = 0
                }
                if oldValue != nil {
                    // open de corresponding page
                    if pageIndex! > oldValue! {
                        setViewControllers(
                            [pages[pageIndex!]],
                            direction: .forward,
                            animated: true, completion: nil)
                    } else {
                        setViewControllers(
                            [pages[pageIndex!]],
                            direction: .reverse,
                            animated: true, completion: nil)
                    }
                } else {
                    setViewControllers(
                        [pages[pageIndex!]],
                        direction: .forward,
                        animated: true, completion: nil)
                }
                title = titles[pageIndex!]
                
                initPage(pageIndex!)
            }
        }
    }
    
    
    fileprivate var pages: [UIViewController] = []
    
    fileprivate func initPages () {
        
        // only initialise when a page needs to be shown
        guard pageIndex != nil else { return }
        // initialise pages
        if pages.isEmpty {
            pages.append(page1)
            pages.append(page2)
            // Beauty products do not have nutriments
            if currentProductType != .beauty {
                pages.append(page3)
            }
            pages.append(page4)
            pages.append(page5)
            pages.append(page6)
            // Only food products do have a nutition score
            if currentProductType == .food {
                pages.append(page7)
            }

            var index = 0
            if let vc = pages[index] as? IdentificationTableViewController {
                vc.delegate = self
                title = titles[index]
                index += 1
            }
            if let vc = pages[index] as? IngredientsTableViewController {
                vc.delegate = self
                index += 1
            }
            
            // Beauty products do not have nutriments
            if currentProductType != .beauty {
                
                if let vc = pages[index] as? NutrientsTableViewController {
                    vc.delegate = self
                    index += 1
                }
            }
            if let vc = pages[index] as? SupplyChainTableViewController {
                vc.delegate = self
                index += 1
            }
            if let vc = pages[index] as? CategoriesTableViewController {
                vc.delegate = self
                index += 1
            }

        }
    }
    
    private func initPage(_ index: Int) {

        if let vc = pages[index] as? IdentificationTableViewController {
            vc.product = product
            vc.currentLanguageCode = currentLanguageCode
            vc.editMode = editMode
        } else if let vc = pages[index] as? IngredientsTableViewController {
            vc.product = product
            vc.editMode = editMode
            vc.currentLanguageCode = currentLanguageCode
        } else if let vc = pages[index] as? NutrientsTableViewController {
            vc.product = product
            vc.currentLanguageCode = currentLanguageCode
            vc.editMode = editMode
        } else if let vc = pages[index] as? SupplyChainTableViewController {
            vc.product = product
            vc.editMode = editMode
        } else if let vc = pages[index] as? CategoriesTableViewController {
            vc.product = product
            vc.editMode = editMode
        } else if let vc = pages[index] as? CompletionStatesTableViewController {
            vc.product = product
        } else if let vc = pages[index] as? NutritionScoreTableViewController {
            vc.product = product
        }
    }
    
    private struct Title {
        static let Identification = NSLocalizedString("Identification", comment: "Viewcontroller title for page with product identification info.")
        static let Ingredients = NSLocalizedString("Ingredients", comment: "Viewcontroller title for page with ingredients for product.")
        static let Facts = NSLocalizedString("Nutritional facts", comment: "Viewcontroller title for page with nutritional facts for product.")
        static let SupplyChain = NSLocalizedString("Supply Chain", comment: "Viewcontroller title for page with supply chain for product.")
        static let Categories = NSLocalizedString("Categories", comment: "Viewcontroller title for page with categories for product.")
        static let Effort = NSLocalizedString("Community Effort", comment: "Viewcontroller title for page with community effort for product.")
        static let Score = NSLocalizedString("Nutritional Score", comment: "Viewcontroller title for page with explanation of the nutritional score of the product.")
    }
    
    fileprivate var titles: [String] {
        get {
            var titles: [String] = []
            switch currentProductType {
            case .food:
                titles.append("1 - " + Title.Identification)
                titles.append("2 - " + Title.Ingredients)
                titles.append("3 - " + Title.Facts)
                titles.append("4 - " + Title.SupplyChain)
                titles.append("5 - " + Title.Categories)
                titles.append("6 - " + Title.Effort)
                titles.append("7 - " + Title.Score)
            case .petFood:
                titles.append("1 - " + Title.Identification)
                titles.append("2 - " + Title.Ingredients)
                titles.append("3 - " + Title.Facts)
                titles.append("4 - " + Title.SupplyChain)
                titles.append("5 - " + Title.Categories)
                titles.append("6 - " + Title.Effort)

            case .beauty:
                titles.append("1 - " + Title.Identification)
                titles.append("2 - " + Title.Ingredients)
                titles.append("3 - " + Title.SupplyChain)
                titles.append("4 - " + Title.Categories)
                titles.append("5 - " + Title.Effort)
            }
            return titles
        }
    }
    
    fileprivate var page1: UIViewController {
        get {
            return storyboard!.instantiateViewController(withIdentifier: Constants.IdentificationVCIdentifier)
        }
    }
    fileprivate var page2: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.IngredientsVCIdentifier)
        }
    }
    fileprivate var page3: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutrientsVCIdentifier)
        }
    }
    fileprivate var page4: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.SupplyChainVCIdentifier)
        }
    }
    fileprivate var page5: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CategoriesVCIdentifier)
        }
    }
    fileprivate var page6: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CommunityEffortVCIdentifier)
        }
    }
    fileprivate var page7: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutritionalScoreVCIdentifier)
        }
    }
        
    var product: FoodProduct? = nil {
        didSet {
            if product != nil {
                
                setCurrentLanguage()
                
                // only set the field of a page if we have a valid page
                
                if let index = pageIndex {
                    if let vc = pages[index] as? IdentificationTableViewController {
                        vc.product = product
                    } else if let vc = pages[index] as? IngredientsTableViewController {
                        vc.product = product
                    } else if let vc = pages[index] as? NutrientsTableViewController {
                        vc.product = product
                    } else if let vc = pages[index] as? SupplyChainTableViewController {
                        vc.product = product
                    } else if let vc = pages[index] as? CategoriesTableViewController {
                        vc.product = product
                    } else if let vc = pages[index] as? CompletionStatesTableViewController {
                        vc.product = product
                    } else if let vc = pages[index] as? NutritionScoreTableViewController {
                        vc.product = product
                    }
                }
            }
        }
    }
        
    // This function finds the language that must be used to display the product
    func setCurrentLanguage() {
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
        
// MARK: - Pageview Controller DataSource Functions
        
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
            
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = pages.count
            
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
            
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return pages[nextIndex]
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
            
        let previousIndex = viewControllerIndex - 1
            
        guard previousIndex >= 0 else {
            return nil
        }
            
        guard pages.count > previousIndex else {
            return nil
        }
        
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                                     willTransitionTo pendingViewControllers: [UIViewController]) {
        // inform us what is happening, so the page can be setup
        if let vc = pendingViewControllers.first {
            pageIndex = pages.index(of:vc)
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
        
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = pages.index(of: firstViewController) else {
                return 0
        }
            
        return firstViewControllerIndex
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let current = viewControllers?.first,
            let viewControllerIndex = pages.index(of: current) {
            title = titles[viewControllerIndex]
        }
    }
        
    // MARK: - Notification Functions
        
    func loadFirstProduct() {
    // handle a notification that the first product has been set
    // this sets the current product and shows the first page
        let products = OFFProducts.manager
        if !products.fetchResultList.isEmpty {
            switch products.fetchResultList[0] {
            case .success(let firstProduct):
                product = firstProduct
                pageIndex = 0
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
                updatedProduct?.purchasePlacesAddress = Address.init(with: validShop)
                if let purchasePlace = updatedProduct?.purchasePlacesAddress?.asSingleString(withSeparator: ",") {
                    updatedProduct?.purchasePlacesOriginal = Tags.init(purchasePlace)
                }
            }
            saveUpdatedProduct() 
        }
    }
    
    func update(brandTags: [String]?) {
        if let validTags = brandTags {
            guard product != nil else { return }
            if !product!.contains(brands: validTags) {
                initUpdatedProductWith(product: product!)
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
                    updatedProduct?.categories = .empty
                } else {
                    updatedProduct?.categories = .available(validTags)
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
            switch product!.countriesOriginal {
            case .available:
                if !product!.contains(purchaseLocation: validTags) {
                    initUpdatedProductWith(product: product!)
                    updatedProduct?.countriesOriginal = .available(validTags)
                    saveUpdatedProduct()
                }
            default:
                break
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
        if updatedProduct!.frontImages == nil { updatedProduct!.frontImages = ProductImageSize() }

        var images: [String:ProductImageData] = [:]
        images[languageCode] = ProductImageData.init(image: frontImage)
        updatedProduct?.frontImages?.display = images
        saveUpdatedProduct()
    }

    func updated(nutritionImage: UIImage, languageCode: String) {
        initUpdatedProductWith(product: product!)
        if updatedProduct!.nutritionImages == nil { updatedProduct!.nutritionImages = ProductImageSize() }
        
        var images: [String:ProductImageData] = [:]
        images[languageCode] = ProductImageData.init(image: nutritionImage)
        updatedProduct?.nutritionImages?.display = images
        saveUpdatedProduct()
    }

    func updated(ingredientsImage: UIImage, languageCode: String) {
        initUpdatedProductWith(product: product!)
        if updatedProduct!.ingredientsImages == nil { updatedProduct!.ingredientsImages = ProductImageSize() }
        
        var images: [String:ProductImageData] = [:]
        images[languageCode] = ProductImageData.init(image: ingredientsImage)

        updatedProduct?.ingredientsImages?.display = images
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
        
    // MARK: TBD This is not very elegant
        
    @IBAction func unwindSetLanguageForCancel(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageViewController {
            // currentLanguageCode = vc.currentLanguageCode
            // updateCurrentLanguage()
            pageIndex = vc.sourcePage
        }
    }
        
    @IBAction func unwindSetLanguageForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageViewController {
            currentLanguageCode = vc.selectedLanguageCode
//            update(addLanguageCode: vc.selectedLanguageCode!)
            pageIndex = vc.sourcePage
        }
    }
    
    @IBAction func unwindConfirmProductForDone(_ segue:UIStoryboardSegue) {
    }
        
        
    func updateCurrentLanguage() {
        if let vc = pages[0] as? IdentificationTableViewController {
            vc.currentLanguageCode = currentLanguageCode
        }
        if let vc = pages[1] as? IngredientsTableViewController {
            vc.currentLanguageCode = currentLanguageCode
        }
        if let vc = pages[2] as? NutrientsTableViewController {
            vc.currentLanguageCode = currentLanguageCode
        }

    }
    
    // MARK: - ViewController Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
            
        dataSource = self
        delegate = self
            
        initPages()
    }
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        // listen if a product is set outside of the MasterViewController
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToSuccess), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToFailure), name:.ProductUpdateFailed, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if OFFAccount().personalExists() {
            // maybe the user has to authenticate himself before continuing
            authenticate()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
        
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
