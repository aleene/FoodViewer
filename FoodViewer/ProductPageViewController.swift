 //
//  ProductPageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 06/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import LocalAuthentication

 protocol ProductPageViewControllerDelegate: class {
    
    func productPageViewControllerProductPairChanged(_ sender: ProductPageViewController)
    func productPageViewControllerEditModeChanged(_ sender: ProductPageViewController)
    func productPageViewControllerCurrentLanguageCodeChanged(_ sender: ProductPageViewController)
 }

class ProductPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ProductUpdatedProtocol {
    
    var productPageViewControllerdelegate: ProductPageViewControllerDelegate? = nil

// MARK: - Interface Actions
    
    @IBOutlet weak var confirmBarButtonItem: UIBarButtonItem! {
        didSet {
            confirmBarButtonItem.isEnabled = productPair?.updateIsAllowed ?? true
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
            
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
    
    private func askSavePermission() {
        
        let alertController = UIAlertController(title: TranslatableStrings.AskSavePermissionTitle,
                                                message: TranslatableStrings.AskSavePermissionMessage,
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: TranslatableStrings.Discard,
                                          style: .default)
        { action -> Void in
            self.productPair?.localProduct = nil
            //self.pageIndex = .identification
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

// MARK: - Save product functions

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
    
    var productPair: ProductPair? = nil {
        didSet {
            initPages()
            confirmBarButtonItem?.isEnabled = productPair?.updateIsAllowed ?? true
            guard let validProductPair = productPair else { return }
            if oldValue == nil ||
                validProductPair.barcodeType.asString != oldValue!.barcodeType.asString {
                productPageViewControllerdelegate?.productPageViewControllerProductPairChanged(self)
                title = prefixedTitle
                currentLanguageCode = validProductPair.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
            }
        }
    }
    
    var pageIndex: ProductPage = .identification {
        didSet {
            switch pageIndex {
            case .notSet:
                setViewControllers(
                    [viewController(for:pageIndex)],
                    direction: .forward,
                    animated: false, completion: nil)
            default:
                if pageIndex != oldValue {
                    // has the initialisation been done?
                    if let oldIndex = pages.firstIndex(where: { $0 == oldValue } ),
                        let newIndex = pages.firstIndex(where: { $0 == pageIndex } ) {
                        // open de corresponding page
                        if newIndex > oldIndex {
                            setViewControllers(
                                [viewController(for:pageIndex)],
                                direction: .forward,
                                animated: false, completion: nil)
                        } else {
                            setViewControllers(
                                [viewController(for:pageIndex)],
                                direction: .reverse,
                                animated: false, completion: nil)
                        }
                    }
                } else {
                    setViewControllers(
                        [viewController(for:pageIndex)],
                        direction: .forward,
                        animated: false, completion: nil)
                }
                
                initPage(pageIndex)
            }
                
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    
    // The languageCode for the language in which the fields are shown
    var currentLanguageCode: String? = nil {
        didSet {
            // pass the changed language on
            if currentLanguageCode != oldValue {
                productPageViewControllerdelegate?.productPageViewControllerEditModeChanged(self)
            }
        }
    }

    public var editMode: Bool = Preferences.manager.editMode {
        didSet {
            if editMode != oldValue {
                productPageViewControllerdelegate?.productPageViewControllerEditModeChanged(self)
                Preferences.manager.editMode = editMode
            }
            // change look edit button
            let buttonText = "CheckMark"
            if let image = UIImage.init(named: editMode ? buttonText  : "Edit") {
                confirmBarButtonItem.image = image
            }
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
        if productPair == nil {
            pages = [.notSet]
            pageIndex = .notSet
        } else {
            pageIndex = .identification
            // define the pages (and order), which will be shown
            switch currentProductType {
            case .food:
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories, .gallery, .nutritionScore, .completion]
            case .beauty:
                pages = [.identification, .ingredients, .supplyChain, .categories, .gallery, .completion]
            case .petFood:
                pages = [.identification, .ingredients, .nutritionFacts, .supplyChain, .categories, .gallery, .completion]
            case .product:
                pages = [.identification, .ingredients, .supplyChain, .categories, .gallery, .completion]
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
            
        case .gallery:
            galleryVC.delegate = self
            
        case .notSet:
            break
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
        static let ProductImagesVCIdentifier = "ProductImagesCollectionViewController"
        static let NotSetVCIdentifier = "NotSetViewController"
        static let ConfirmProductViewControllerSegue = "Confirm Product Segue"
    }
    

    private func viewController(for section: ProductPage) -> UIViewController {
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

    private var prefixedTitle: String {
        switch pageIndex {
        case .notSet:
            return pageIndex.description
        default:
            return pageIndex.description + " " + prefix
        }
    }
    
    fileprivate let identificationVC: IdentificationTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.IdentificationVCIdentifier) as! IdentificationTableViewController

    fileprivate let ingredientsVC: IngredientsTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.IngredientsVCIdentifier) as! IngredientsTableViewController
    
    fileprivate let nutritionFactsVC: NutrientsTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutrientsVCIdentifier) as! NutrientsTableViewController
    
    fileprivate let supplyChainVC: SupplyChainTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.SupplyChainVCIdentifier) as! SupplyChainTableViewController
    
    fileprivate let categoriesVC: CategoriesTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CategoriesVCIdentifier) as! CategoriesTableViewController
    
    fileprivate let completionStatusVC: CompletionStatesTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CommunityEffortVCIdentifier) as! CompletionStatesTableViewController
    
    fileprivate let nutritionScoreVC: NutritionScoreTableViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutritionalScoreVCIdentifier) as! NutritionScoreTableViewController

    fileprivate let galleryVC: ProductImagesCollectionViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.ProductImagesVCIdentifier) as! ProductImagesCollectionViewController

    fileprivate let notSetVC: NotSetPageViewController = UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NotSetVCIdentifier) as! NotSetPageViewController

//
//          MARK: - Pageview Controller DataSource Functions
//

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
            pageIndex = type(for: pendingViewControllers.first!)
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
        
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.firstIndex(where: { $0 == pageIndex } ) ?? 0
    }
        
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.title = prefixedTitle
    }
    
    // MARK: - Notification Functions
        
    @objc func loadFirstProduct() {
    // handle a notification that the first product has been set
    // this sets the current product and shows the first page
        let products = OFFProducts.manager
        if let validFetchResult = products.productPair(at: 0)?.remoteStatus,
            let validProductPair = products.productPair(at: 0) {
            switch validFetchResult {
            case .available:
                productPair = validProductPair
                pageIndex = .identification
                initPage(pageIndex)
            default: break
            }
        }
    }
    
    @objc func changeConfirmButtonToSuccess() {
        confirmBarButtonItem.tintColor = .green
        //NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToSuccess), name:.ProductUpdateSucceeded, object:nil)

        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ProductPageViewController.resetSaveButtonColor), userInfo: nil, repeats: false)
    }
  
    @objc func changeConfirmButtonToFailure() {
        confirmBarButtonItem.tintColor = .red
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ProductPageViewController.resetSaveButtonColor), userInfo: nil, repeats: false)
    }
    
    // function to reset the SaveButton to the default IOS color
    @objc func resetSaveButtonColor() {
        confirmBarButtonItem.tintColor = self.view.tintColor
    }
    
    @objc func setPrefixedTitle(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcodeString = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if let validBarcodeString = productPair?.barcodeType.asString {
                if barcodeString == validBarcodeString {
                    title = prefixedTitle
                }
            }
        }
    }
    
// MARK: - Product Updated Protocol functions

    // The updated product contains only those fields that have been edited.
    // Thus one can always revert to the original product
    // And we know exactly what has changed
    // The user can undo an edit in progress by stepping back, i.e. selecting another product
    // First it is checked whether a change to the field has been made
    
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
    
// MARK: - Segues
    
    
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
    
    @IBAction func unwindExtendLanguagesForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? MainLanguageViewController {
            if let newLanguageCode = vc.selectedLanguageCode {
                currentLanguageCode = newLanguageCode

                // the languageCodes have been edited, so with have now an updated product
                productPair?.update(addLanguageCode: newLanguageCode)
                if vc.sourcePage > 0 && vc.sourcePage < pages.count {
                    pageIndex = pages[vc.sourcePage]
                } else {
                    pageIndex = .identification
                }
            }
        }
    }
    
    @IBAction func unwindExtendLanguagesForCancel(_ segue:UIStoryboardSegue) {
        // nothing needs to be done
    }

        /*
    func updateCurrentLanguage() {
        if let index = pages.index(where: { $0 == .identification } ),
            let _ = viewController(for: pages[index]) as? IdentificationTableViewController {
            // vc.currentLanguageCode = currentLanguageCode
        }
        if let index = pages.index(where: { $0 == .ingredients } ),
            let vc = viewController(for: pages[index]) as? IngredientsTableViewController {
            //vc.currentLanguageCode = currentLanguageCode
        }
        if let index = pages.index(where: { $0 == .nutritionFacts } ),
            let vc = viewController(for: pages[index]) as? NutrientsTableViewController {
            // vc.currentLanguageCode = currentLanguageCode
        }

    }
  */
    
    func search(for string: String?, in component: SearchComponent) {
        if let validString = string {
            askUserToSearch(for: validString, in: component)
        }
    }
    
    func askUserToSearch(for string: String, in component: SearchComponent) {
        let searchMessage = TranslatableStrings.SearchMessage
        
        let parts = string.split(separator:":").map(String.init)
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
        OFFSearchProducts.manager.search(string, in:component)
        switchToTab(withIndex:2)
    }

    //@objc func searchStarted() {
    //    switchToTab(withIndex:2)
        // performSegue(withIdentifier: "Unwind For Cancel", sender: self)
    //}
    
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
    
    // MARK: - ViewController Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // set look edit button
        if let image = UIImage.init(named: editMode ? "CheckMark"  : "Edit") {
            confirmBarButtonItem.image = image
        }

        initPages()
        title = prefixedTitle

        // listen if a product is set outside of the MasterViewController
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToSuccess), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.changeConfirmButtonToFailure), name:.ProductUpdateFailed, object:nil)
        //NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.searchStarted), name:.SearchStarted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductPageViewController.setPrefixedTitle(_:)), name:.ProductPairUpdated, object:nil)
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
