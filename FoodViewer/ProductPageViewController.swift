//
//  ProductPageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 06/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

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


class ProductPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    struct Constants {
        static let StoryBoardIdentifier = "Main"
        // static let OpenFoodFactsWebEditURL = "http://fr.openfoodfacts.org/cgi/product.pl?type=edit&code="
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
