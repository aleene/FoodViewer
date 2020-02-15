 //
//  ProductPageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 06/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import LocalAuthentication

class ProductPageViewController: UIPageViewController, ProductUpdatedProtocol {
    
//
// MARK: - Interface Actions
//
    @IBOutlet weak var confirmBarButtonItem: UIBarButtonItem! {
        didSet {
            setupEditButton()
        }
    }
    
    @IBOutlet weak var actionButton: UIBarButtonItem! {
        didSet {
            actionButton.isEnabled = productPair == nil ? false : true
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
            
        guard productPair != nil else { return }
        
        var sharingItems = [AnyObject]()
            
        if let text = productPair?.name {
            sharingItems.append(text as AnyObject)
        }
        // add the front image for the primary languageCode if any
        if let languageCode = productPair?.primaryLanguageCode {
            if let fetchResult = productPair?.frontImages[languageCode]?.small?.fetch() {
                switch fetchResult {
                case .success(let image):
                    sharingItems.append(image)
                default: break
                }
            }
        }
        
        if let url = productPair?.regionURL {
            sharingItems.append(url as AnyObject)
        }
            
        let activity = TUSafariActivity()
            
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: [activity])
            
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.print, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.addToReadingList]
            
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
            
            self.askSavePermission()
        }
        editMode = !editMode
    }
//
// MARK: - Save product functions
//
    private func askSavePermission() {
        
        let alertController = UIAlertController(title: TranslatableStrings.AskSavePermissionTitle,
                                                message: TranslatableStrings.AskSavePermissionMessage,
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: TranslatableStrings.Discard,
                                          style: .default)
        { action -> Void in
            self.productPair?.localProduct = nil
            self.refreshPageInterface()
        }
        
        let useMyOwn = UIAlertAction(title: TranslatableStrings.Save, style: .default)
        { action -> Void in
            if OFFAccount().personalExists() {
                // maybe the user has to authenticate himself before continuing
                self.authenticate()
            }
            // Saving can be done
            if !self.loginInProcess {
                self.saveUpdatedProduct()
            }
        }
        alertController.addAction(useFoodViewer)
        alertController.addAction(useMyOwn)
        self.present(alertController, animated: true, completion: nil)
    }

    private var userWantsToSave = false
    
    private var loginInProcess = false // while the user is busy authenticating no save can be done
    
    func saveUpdatedProduct() {
        // Current mode
        // if editMode {
            if userWantsToSave {
                // time to save
                //productPair?.upload()
                if let validProductPair = self.productPair {
                    OFFProducts.manager.startUpload(for: validProductPair)
                }
                userWantsToSave = false
            }
        //}
    }
//
// MARK: - Public variables and functions
//
    var sourcePage: Any? = nil {
        didSet {
            guard let validSourcePage = sourcePage else { return }
            if validSourcePage is SingleProductTableViewController {
                originPage = .singleProductTableViewController
            }
        }
    }
    
    var productPair: ProductPair? = nil {
        didSet {
            setupEditButton()
            guard let validProductPair = productPair else {
                actionButton?.isEnabled = false
                return
            }
            actionButton?.isEnabled = true

            switch validProductPair.remoteStatus {
            case .productNotAvailable:
                currentProductPage = .gallery
            default:
                currentProductPage = .identification
            }
            initPages()
            refreshPageInterface()
            currentLanguageCode = validProductPair.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
            //}
        }
    }
    
    var currentProductPage: ProductPage = .notSet {
        didSet {
            guard let validProductPair = productPair else {
                currentProductPage = .notSet
                return
            }
            switch validProductPair.remoteStatus {
            case .productNotAvailable:
                currentProductPage = .gallery
            default:
                break
            }
            // If a product image is on screen, get rid of it.
            popImageViewController()
            setViewControllers(
                    [viewController(for:currentProductPage)],
                    direction: .forward,
                    animated: false, completion: nil)
            initPage(currentProductPage)
            refreshPageInterface()
        }
    }
    
    private func popImageViewController () {
        if let splitVC = self.splitViewController,
            splitVC.viewControllers.count > 1,
            let navVC = splitVC.viewControllers[1] as? UINavigationController,
            navVC.children.count > 1,
            navVC.children[1] is ImageViewController {
            navVC.popViewController(animated: true)
        }

    }
    
    // The languageCode for the language in which the fields are shown
    var currentLanguageCode: String? = nil {
        didSet {
            // pass the changed language on
            if currentLanguageCode != oldValue {
                refreshPageInterface()
            }
        }
    }
    
    public var editMode: Bool = Preferences.manager.editMode {
        didSet {
            if editMode != oldValue {
                setupEditButton()
                refreshPageInterface()
                Preferences.manager.editMode = editMode
            }
        }
    }
//
// MARK: - Privaye variables
//
    private enum SourcePage {
        case singleProductTableViewController
    }
    
    private var originPage: SourcePage? = nil
    
    private func setupEditButton() {
        guard let validProductPair = productPair else {
            confirmBarButtonItem?.isEnabled = false
            return
        }
        confirmBarButtonItem.isEnabled = validProductPair.updateIsAllowed
        
        if editIsProhibited {
            confirmBarButtonItem?.isEnabled = false
            if let image = UIImage.init(named: Constant.Button.NotEditable) {
                confirmBarButtonItem.image = image
            }
        } else {
            // change look edit button
            if editMode {
                if let image = UIImage.init(named: Constant.Button.Save) {
                    confirmBarButtonItem.image = image
                }
            } else {
            if let image = UIImage.init(named: Constant.Button.Edit) {
                confirmBarButtonItem.image = image
                }
            }
        }

    }
    private var editIsProhibited: Bool {
        // This should check the brand of the current product against the prohibited brands.
        if let validBrands = productPair?.remoteProduct?.brandsInterpreted {
            switch validBrands {
            case .available(let brands):
                return ProhibitedBrands.manager.contains(brands: brands)
            default:
                break
            }
        }
        return false
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    private func refreshPageInterface() {
        setTitle()
        if let vc = viewController(for: currentProductPage) as? IdentificationTableViewController {
            vc.refreshProduct()
            
        } else if let vc = viewController(for: currentProductPage) as? IngredientsTableViewController {
                vc.refreshProduct()
            
        } else if let vc = viewController(for: currentProductPage) as? NutrientsTableViewController {
            vc.refreshProduct()
            
        } else if let vc = viewController(for: currentProductPage) as? SupplyChainTableViewController {
            vc.refreshProduct()

        } else if let vc = viewController(for: currentProductPage) as? CategoriesTableViewController {
            vc.refreshProduct()

        } else if let vc = viewController(for: currentProductPage) as? NutritionScoreTableViewController {
            vc.refreshProduct()

        } else if let vc = viewController(for: currentProductPage) as? DietCompliancyTableViewController {
            vc.refreshProduct()

        } else if let vc = viewController(for: currentProductPage) as? JSONViewController {
            vc.refreshProduct()

        } else if let vc = viewController(for: currentProductPage) as? ProductImagesCollectionViewController {
            vc.reloadImages()
        }

    }
    
    private func type(for viewController: UIViewController) -> ProductPage {
        
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

        } else if viewController is DietCompliancyTableViewController {
            return .dietCompliancy

        } else if viewController is JSONViewController {
               return .json

        } else if viewController is NotSetPageViewController {
            return .notSet
            
        } else {
            return .identification
        }

    }
    //
    // MARK: - Init the individual pages
    //

    private var pages: [ProductPage] = []

    private func initPages() {
        guard let validProductPair = productPair else {
            pages = [.notSet]
            return
        }
        
        switch validProductPair.remoteStatus {
        case .productNotAvailable:
            editMode = true
            // This will show a page, which allows the user to add all necessary images.
            pages = [.gallery]
        default:
            // define the pages (and order), which will be shown
            switch currentProductType {
            case .food:
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories, .gallery, .nutritionScore, .dietCompliancy, .completion, .json]
            case .beauty:
                pages = [.identification, .ingredients, .supplyChain, .categories, .gallery, .completion, .json]
            case .petFood:
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories, .gallery, .completion, .json]
            case .product:
                pages = [.identification, .ingredients, .supplyChain, .categories, .gallery, .completion, .json]
            }
        }
    }
    
    // This function finds the language that must be used to display the product
    private func setCurrentLanguage() {
        currentLanguageCode = currentLanguageCode ?? productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }

    private func initPage(_ page: ProductPage) {
        
        // setup individual pages
        switch page {
        case .identification:
            identificationVC.delegate = self
            
        case .ingredients:
            ingredientsVC.delegate = self
            
        case .nutritionFacts:
            nutritionFactsVC.delegate = self
            
        case .supplyChain:
            supplyChainVC.delegate = self
            
        case .categories:
            categoriesVC.delegate = self
            
        case .nutritionScore:
            nutritionScoreVC.delegate = self
            
        case .completion :
            completionStatusVC.delegate = self
            
        case .gallery, .notAvailable:
            galleryVC.delegate = self

        case .dietCompliancy:
            dietCompliancyVC.delegate = self

        case .json:
            jsonVC.delegate = self
            
        case .notSet:
            break
        }
        
    }
//
// MARK: - ViewController
//
    fileprivate struct Constant {
        static let StoryBoardIdentifier = "Main"
        struct Button {
            static let Edit = "Edit"
            static let Save = "CheckMark"
            static let NotEditable = "NotOK"
        }
        struct ViewControllerIdentifier {
            static let Identification = "IdentificationTableViewController"
            static let Ingredients = "IngredientsTableViewController"
            static let Nutrients = "NutrientsTableViewController"
            static let SupplyChain = "SupplyChainTableViewController"
            static let Categories = "CategoriesTableViewController"
            static let CommunityEffort = "CommunityEffortTableViewController"
            static let NutritionalScore = "NutritionScoreTableViewController"
            static let ProductImages = "ProductImagesCollectionViewController"
            static let DietCompliancy = "DietCompliancyTableViewController"
            static let Json = "JSONViewController"
            static let NotSet = "NotSetViewController"
            static let NotAvailable = "NotAvailableViewController"
        }
        static let ConfirmProductViewControllerSegue = "Confirm Product Segue"
    }
    

    private func viewController(for section: ProductPage) -> UIViewController {
        switch section {
        case .identification:
            return identificationVC
        case .ingredients:
            return ingredientsVC
        case .gallery, .notAvailable:
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
        case .dietCompliancy:
            return dietCompliancyVC
        case .json:
            return jsonVC
        case .notSet:
            return notSetVC
        }
    }
    
    //  The prefix adds two characters for the existence of the product locally and remote
    private var prefix: String {
        var temp = ""
        // Does the product exist on OFF?
        if let remotePair = productPair?.remoteProduct {
            if remotePair.state.isEmpty {
                temp += "○" // product exists , but is empty
            } else {
                temp += "✓" // product exists
            }
        } else {
            temp += "✕"
        }
        // Does the product exist locally?
        if productPair?.localProduct != nil {
            temp += "✓" // product exists locally
        } else {
            temp += "✕" // product does not exist locally
        }
        return temp
    }
    
    private func setTitle() {
        switch currentProductPage {
        case .notSet:
                 if let vc = self.parent as? UINavigationController {
                     if let vc2 = vc.parent as? UISplitViewController {
                         let vc2s = vc2.viewControllers
                         if vc2s.count > 1 {
                             if let vc3 = vc2s[0] as? UINavigationController {
                                 let vc3s = vc3.viewControllers
                                 if vc3s.count > 0 {
                                     if vc3s[0] is AllProductsTableViewController {
                                         title = "All History Products"
                                     } else if vc3s[0] is SearchesHistoryTableViewController {
                                         title = "All Search Queries"
                                     } else if vc3s[0] is SearchResultsTableViewController {
                                         title = "All Search Products"
                                     }
                                 }
                             }
                         }
                     }
                 }
        default:
            title = currentProductPage.description + " " + prefix
        }
    }
    
    fileprivate let identificationVC: IdentificationTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.Identification) as! IdentificationTableViewController

    fileprivate let ingredientsVC: IngredientsTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.Ingredients) as! IngredientsTableViewController
    
    fileprivate let nutritionFactsVC: NutrientsTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.Nutrients) as! NutrientsTableViewController
    
    fileprivate let supplyChainVC: SupplyChainTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.SupplyChain) as! SupplyChainTableViewController
    
    fileprivate let categoriesVC: CategoriesTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.Categories) as! CategoriesTableViewController
    
    fileprivate let completionStatusVC: CompletionStatesTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.CommunityEffort) as! CompletionStatesTableViewController
    
    fileprivate let nutritionScoreVC: NutritionScoreTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.NutritionalScore) as! NutritionScoreTableViewController

    fileprivate let galleryVC: ProductImagesCollectionViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.ProductImages) as! ProductImagesCollectionViewController

    fileprivate let dietCompliancyVC: DietCompliancyTableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.DietCompliancy) as! DietCompliancyTableViewController

    fileprivate let notSetVC: NotSetPageViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.NotSet) as! NotSetPageViewController

    fileprivate let jsonVC: JSONViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.Json) as! JSONViewController

    //fileprivate let notAvailableVC: NotAvailableViewController = UIStoryboard(name: Constant.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.NotAvailable) as! NotAvailableViewController

//
// MARK: - Notification Functions
//
    @objc func loadFirstProduct() {
    // handle a notification that the first product has been set
    // this sets the current product and shows the first page
        let products = OFFProducts.manager
        if let validFetchResult = products.productPair(at: 0)?.remoteStatus,
            let validProductPair = products.productPair(at: 0) {
            switch validFetchResult {
            case .available:
                productPair = validProductPair
                currentProductPage = .identification
                initPage(currentProductPage)
            default: break
            }
        }
    }
    
    @objc func changeConfirmButtonToSuccess() {
        confirmBarButtonItem?.tintColor = .systemGreen

        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ProductPageViewController.resetSaveButtonColor), userInfo: nil, repeats: false)
    }
  
    @objc func changeConfirmButtonToFailure() {
        confirmBarButtonItem?.tintColor = .systemRed
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ProductPageViewController.resetSaveButtonColor), userInfo: nil, repeats: false)
    }
    
    // function to reset the SaveButton to the default IOS color
    @objc func resetSaveButtonColor() {
        if #available(iOS 13.0, *) {
            confirmBarButtonItem.tintColor = .link
        } else {
            confirmBarButtonItem.tintColor = .systemBlue
        }
    }
    
    @objc func setPrefixedTitle(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcodeString = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if let validBarcodeString = productPair?.barcodeType.asString {
                if barcodeString == validBarcodeString {
                    setTitle()
                }
            }
        }
    }
    
    @objc func changeTitle(_ notification: Notification) {
        setTitle()
    }

//
// MARK: - Authentication
//
    private func authenticate() {
        
        // Is authentication necessary?
        // only for personal accounts and has not yet authenticated
        if OFFAccount().personalExists() && !Preferences.manager.userDidAuthenticate {
            loginInProcess = true
            // let the user ID himself with TouchID
            let context = LAContext()
            // The username and password will then be retrieved from the keychain if needed
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                let reason = String(format: TranslatableStrings.AuthenticateForOFFLogin)
                // the device knows TouchID
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {
                    (success: Bool, error: Error? ) -> Void in
                    
                    // 3. Inside the reply block, you handling the success case first. By default, the policy evaluation happens on a private thread, so your code jumps back to the main thread so it can update the UI. If the authentication was successful, you call the segue that dismisses the login view.
                    
                    DispatchQueue.main.async(execute: {
                    if success {
                        Preferences.manager.userDidAuthenticate = true
                        self.loginInProcess = false
                        // Saving can be done
                        self.saveUpdatedProduct()
                    } else {
                        self.askPassword()
                    }

                    } )
                } )
            } else {
                self.saveUpdatedProduct()
            }
            // The login stuff has been done for the duration of this app run
            // so we will not bother the user any more
            Preferences.manager.userDidAuthenticate = true
        }
    }
    
    fileprivate var password: String? = nil
    
    private func askPassword() {
        
        let alertController = UIAlertController(title: TranslatableStrings.SpecifyPassword,
                                                message: TranslatableStrings.AuthenticateWithTouchIDFailed,
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: TranslatableStrings.Reset,
                                          style: .default)
        { action -> Void in
            // set the foodviewer selected index
            OFFAccount().removePersonal()
            Preferences.manager.userDidAuthenticate = false
        }
        
        let useMyOwn = UIAlertAction(title: TranslatableStrings.Done, style: .default)
        { action -> Void in
            // I should check the password here
            if let validString = self.password {
                Preferences.manager.userDidAuthenticate = OFFAccount().check(password: validString) ? true : false
                self.loginInProcess = false
                self.saveUpdatedProduct()
            }
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 0
            textField.placeholder = TranslatableStrings.Password
            textField.delegate = self
        }
        
        alertController.addAction(useFoodViewer)
        alertController.addAction(useMyOwn)
        self.present(alertController, animated: true, completion: nil)
    }
//
// MARK: - Unwinds
//
    /*
    @IBAction func unwindSetLanguageForCancel(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageViewController {
            // currentLanguageCode = vc.currentLanguageCode
            // updateCurrentLanguage()
            if vc.sourcePage > 0 && vc.sourcePage < pages.count {
                currentProductPage = pages[vc.sourcePage]
            } else {
                currentProductPage = .identification
            }
        }
    }
        
    @IBAction func unwindSetLanguageForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageViewController {
            currentLanguageCode = vc.selectedLanguageCode
//            update(addLanguageCode: vc.selectedLanguageCode!)
            if vc.sourcePage > 0 && vc.sourcePage < pages.count {
                currentProductPage = pages[vc.sourcePage]
            } else {
                currentProductPage = .identification
            }
        }
    }
    */
    @IBAction func unwindConfirmProductForDone(_ segue:UIStoryboardSegue) {
        
    }

    func search(for string: String?, in component: SearchComponent) {
        if let validString = string {
            askUserToSearch(for: validString, in: component)
        }
    }
    
    func askUserToSearch(for string: String, in component: SearchComponent) {
        
        let parts = string.split(separator:":").map(String.init)
        var stringToUse = ""
        if parts.count >= 2 {
            stringToUse = parts[1]
        } else if parts.count >= 1 {
            stringToUse = parts[0]
        }
        
        let alertController = UIAlertController(title: TranslatableStrings.StartSearch,
                                                message: String(format: TranslatableStrings.SearchMessage, stringToUse, component.description),
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
        OFFSearchProducts.manager.search(string, in:component)
        switchToTab(withIndex:2)
    }
    
    private func switchToTab(withIndex index: Int) {
        // TabBarController -> SplitViewController -> NavigationController -> PageViewController - ViewController
        if let tabVC = self.parent?.parent?.parent as? UITabBarController {
            tabVC.selectedIndex = index
        } else {
            assert(true, "ProductPageViewController:switchToTab: TabBar hierarchy error")
        }
    }
    
    // Show an alert if the product can not be loaded
    @objc func alertUser(_ notification: Notification) {
        
        let error = "Load error"
        let message = "Could not load your request. Server down? Internet down?"
        let alertController = UIAlertController(title: error,
                                                message: message,
                                                preferredStyle:.alert)
        let ok = UIAlertAction(title: TranslatableStrings.OK,
                               style: .default)
        { action -> Void in
        }
        
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)

    }

    @objc func infoClicked() {
        //TODO: why is this function?
        //productPair!.remoteProduct = nil
    }
//
// MARK: - ViewController Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        initPages()
        dataSource = self
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshPageInterface()
        setViewControllers(
                [viewController(for:currentProductPage)],
                direction: .forward,
                animated: false, completion: nil)
        // listen if a product is set outside of the MasterViewController
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToSuccess), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToFailure), name:.ProductUpdateFailed, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.setPrefixedTitle(_:)), name:.ProductPairUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeTitle(_:)), name:.SearchLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.alertUser(_:)), name:.ProductLoadingError, object:nil)
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
//
// MARK: - TextField Delegate Functions
//
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
 //
 // MARK: - Pageview Controller DataSource Functions
 //
 extension ProductPageViewController : UIPageViewControllerDataSource {
        
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
        if let viewControllerIndex = pages.firstIndex(where: { $0 == type(for: viewController) } ) {
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
            
        if let viewControllerIndex = pages.firstIndex(where: { $0 == type(for: viewController) } ) {
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
            currentProductPage = type(for: pendingViewControllers.first!)
        }
    }
        
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
            
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.firstIndex(where: { $0 == currentProductPage } ) ?? 0
    }
            
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            setTitle()
    }
 }

 extension ProductPageViewController : UIPageViewControllerDelegate {
 }
