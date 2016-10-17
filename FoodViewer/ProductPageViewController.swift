//
//  ProductPageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 06/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import LocalAuthentication

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class ProductPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UITextFieldDelegate {

    struct Constants {
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
    var currentLanguageCode: String? = nil

    @IBOutlet weak var confirmBarButtonItem: UIBarButtonItem!
    
    
    // MARK: - Storyboard Actions
        
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
            
        var sharingItems = [AnyObject]()
            
        if let text = product?.name {
            sharingItems.append(text as AnyObject)
        }
            
        if let data = product?.mainImageSmallData,
            let image = UIImage(data:data as Data) {
            sharingItems.append(image)
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
        // befor continuing to let the user enter data
        // check how the data should be saved
        // Did the user already login into the app?
        if !Preferences.manager.OFFLogInCredentialsSet {
            credentialProtocolToUse()
        }
        self.performSegue(withIdentifier: Constants.ConfirmProductViewControllerSegue, sender: self)
    }
        
    var pageIndex: Int? = nil {
        didSet {
            // has the initialisation been done?
            if pages.isEmpty {
                initPages()
            }
                // do we have a valid pageIndex?
            if pageIndex < 0 || pageIndex > pages.count || pageIndex == nil {
                pageIndex = 0
            }
                // open de corresponding page
            setViewControllers(
                [pages[pageIndex!]],
                direction: .forward,
                animated: true, completion: nil)
            title = titles[pageIndex!]
        }
    }
        
    // MARK: - Pages initialization
        
    fileprivate var pages: [UIViewController] = []
        
    fileprivate func initPages () {
        // initialise pages
        if pages.isEmpty {
            pages.append(page1)
            pages.append(page2)
            pages.append(page3)
            pages.append(page4)
            pages.append(page5)
            pages.append(page6)
            pages.append(page7)
        }
    }
        
        
    fileprivate var titles = [NSLocalizedString("Identification", comment: "Viewcontroller title for page with product identification info."),
                                NSLocalizedString("Ingredients", comment: "Viewcontroller title for page with ingredients for product."),
                                NSLocalizedString("Nutritional facts", comment: "Viewcontroller title for page with nutritional facts for product."),
                                NSLocalizedString("Supply Chain", comment: "Viewcontroller title for page with supply chain for product."),
                                NSLocalizedString("Categories", comment: "Viewcontroller title for page with categories for product."),
                                NSLocalizedString("Community Effort", comment: "Viewcontroller title for page with community effort for product."),
                                NSLocalizedString("Nutritional Score", comment: "Viewcontroller title for page with explanation of the nutritional score of the product.")]
    
    var page1: UIViewController {
        get {
            return storyboard!.instantiateViewController(withIdentifier: Constants.IdentificationVCIdentifier)
        }
    }
    var page2: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.IngredientsVCIdentifier)
        }
    }
    var page3: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutrientsVCIdentifier)
        }
    }
    var page4: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.SupplyChainVCIdentifier)
        }
    }
    var page5: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CategoriesVCIdentifier)
        }
    }
    var page6: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.CommunityEffortVCIdentifier)
        }
    }
    var page7: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewController(withIdentifier: Constants.NutritionalScoreVCIdentifier)
        }
    }
        
    var product: FoodProduct? = nil {
        didSet {
            setCurrentLanguage()
                
            // initialise pages
            initPages()
            if let vc = pages[0] as? IdentificationTableViewController {
                vc.product = product
                vc.currentLanguageCode = currentLanguageCode
                title = titles[0]
            }
            if let vc = pages[1] as? IngredientsTableViewController {
                vc.product = product
                vc.currentLanguageCode = currentLanguageCode
            }
            if let vc = pages[2] as? NutrientsTableViewController {
                vc.product = product
            }
            if let vc = pages[3] as? SupplyChainTableViewController {
                vc.product = product
            }
            if let vc = pages[4] as? CategoriesTableViewController {
                vc.product = product
            }
            if let vc = pages[5] as? CompletionStatesTableViewController {
                vc.product = product
            }
            if let vc = pages[6] as? NutritionScoreTableViewController {
                vc.product = product
            }
        }
    }
        
        // This function finds the language that must be used to display the product
        fileprivate func setCurrentLanguage() {
            // is there already a current language?
            guard currentLanguageCode == nil  else { return }
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
        
        // MARK: - Pageview Controller data source
        
        
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
        
        
    // MARK: - Notification actions
        
    func loadFirstProduct() {
    // handle a notification that the first product has been set
    // this sets the current product and shows the first page
        let products = OFFProducts.manager
        if let validProductFetchResult = products.fetchResultList[0] {
            switch validProductFetchResult {
            case .success(let firstProduct):
                product = firstProduct
                pageIndex = 0
            default: break
            }
        }
    }
    
    func changeConfirmButtonToSuccess() {
        confirmBarButtonItem.tintColor = UIColor.green
    }
        
    func changeConfirmButtonToFailure() {
        confirmBarButtonItem.tintColor = .red
    }
    
    // MARK: - Credential functions
    
    let MyKeychainWrapper = KeychainWrapper()
    var context = LAContext()

    private var username: String? = nil {
        didSet {
            privateCredentialsHaveBeenSet()
        }
    }
    private var password: String? = nil {
        didSet {
            privateCredentialsHaveBeenSet()
        }
    }
    
    private func privateCredentialsHaveBeenSet() {
        var logInProtocol = LogIn()
        logInProtocol.useFoodViewerOFFAccount = false
        // only write if both items have been set
        if self.username != nil && self.password != nil {
            self.MyKeychainWrapper.mySetObject(self.username!, forKey:kSecAttrAccount)
            self.MyKeychainWrapper.mySetObject(self.password!, forKey:kSecValueData)
            self.MyKeychainWrapper.writeToKeychain()
            // once stored in the keychain, remove the items
            self.username = nil
            self.password = nil
            logInProtocol.personalOFFAcountAvailable = true
            Preferences.manager.keyChainUnlocked = true
        }
    }
    
    private func credentialProtocolToUse() {
        var logInProtocol = LogIn()

        // allow the user to set how he wants to use the app
        // he can later change it under Preferences
        // is this a first run?
        if logInProtocol.useFoodViewerOFFAccount == nil {
            let alertController = UIAlertController(title: NSLocalizedString("Set OFF Account",
                                                                             comment: "title in AlertController, which lets the user set which OFF Credentials should be used."),
                                                    message: NSLocalizedString("Which OFF account should be used for editing products?",
                                                                               comment: "explanatory text in AlertController, which lets the user set which OFF Credentials should be used."),
                                                    preferredStyle: .alert)
            let useFoodViewer = UIAlertAction(title: NSLocalizedString("FoodViewer",
                                                                       comment: "String in button, to let the user indicate he wants to use the FoodViewer OFF credentials."),
                                              style: .default) { action -> Void in
                logInProtocol.useFoodViewerOFFAccount = true
            }
            let useMyOwn = UIAlertAction(title: NSLocalizedString("Use My Own",
                                                                  comment: "String in button, to let the user indicate he wants to use his own OFF credentials."),
                                         style: .default) { action -> Void in
                logInProtocol.useFoodViewerOFFAccount = false
                // now the user can set username / password
                self.setUserNamePassword()
            }

            alertController.addAction(useFoodViewer)
            alertController.addAction(useMyOwn)
            // TBD I can also run the setUserNamePassword upon present-completion??
            self.present(alertController, animated: true, completion: nil)
        // Has a personal off-account been set?
        } else if !logInProtocol.useFoodViewerOFFAccount! {
            // has the username/password already been set?
            if logInProtocol.personalOFFAcountAvailable == nil || !logInProtocol.personalOFFAcountAvailable! {
                setUserNamePassword()
            } else {
                // let the user ID himself with TouchID
                // The username and password will then be retrieved from the keychain if needed
                if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    // the device knows TouchID
                    Preferences.manager.keyChainUnlocked = true
                } else {
                    // let the user login normally
                    setUserNamePassword()
                }

            }
        }
        // The login stuff has been done for the duration of this app run
        // so we will not bother the user any more
        Preferences.manager.OFFLogInCredentialsSet = true
    }
    
    // Function to ask username/password and store it in the keychain
    private func setUserNamePassword() {

        let alertController = UIAlertController(title: NSLocalizedString("Personal Account",
                                                                         comment: "Title in AlertViewController, which lets the user enter his username/password."),
                                                message: NSLocalizedString("Specify your credentials for OFF?",
                                                                           comment: "Explanatory text in AlertViewController, which lets the user enter his username/password."),
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   comment: "String in button, to let the user indicate he wants to cancel username/password input."),
                                          style: .default) { action -> Void in
                                            Preferences.manager.keyChainUnlocked = false
        }
        
        let useMyOwn = UIAlertAction(title: NSLocalizedString("Done", comment: "String in button, to let the user indicate he is ready with username/password input."), style: .default) { action -> Void in
            // alertController.view.resignFirstResponder()
            // all depends on other asynchronic processes
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 0
            textField.placeholder = NSLocalizedString("Username", comment: "String in textField placeholder, to show that the user has to enter his username.")
            textField.delegate = self
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 1
            textField.placeholder = NSLocalizedString("Password", comment: "String in textField placeholder, to show that the user has to enter his password")
            textField.delegate = self
        }

        alertController.addAction(useFoodViewer)
        alertController.addAction(useMyOwn)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - TextField stuff
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // username
        switch textField.tag {
        case 0:
            if let validText = textField.text {
                username = validText
            }
        // password
        default:
            if let validText = textField.text {
                password = validText
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
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
            currentLanguageCode = vc.currentLanguageCode
            updateCurrentLanguage()
            pageIndex = vc.sourcePage
        }
    }
        
    @IBAction func unwindSetLanguageForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectLanguageViewController {
            currentLanguageCode = vc.selectedLanguageCode
            updateCurrentLanguage()
            pageIndex = vc.sourcePage
        }
    }
        
    @IBAction func unwindConfirmProductForDone(_ segue:UIStoryboardSegue) {
        /*
        if let vc = segue.source as? ConfirmProductTableViewController {
        // nothing to happen
        }
            */
    }
        
        
    func updateCurrentLanguage() {
        if let vc = pages[0] as? IdentificationTableViewController {
            vc.currentLanguageCode = currentLanguageCode
        }
        if let vc = pages[1] as? IngredientsTableViewController {
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
        
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
        
}
