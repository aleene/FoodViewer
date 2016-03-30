//
//  ProductPageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 03/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    struct Constants {
        static let StoryBoardIdentifier = "Main"
        static let OpenFoodFactsWebEditURL = "http://fr.openfoodfacts.org/cgi/product.pl?type=edit&code="
        static let IdentificationVCIdentifier = "IdentificationTableViewController"
        static let IngredientsVCIdentifier = "IngredientsTableViewController"
        static let NutrientsVCIdentifier = "NutrientsTableViewController"
        static let SupplyChainVCIdentifier = "SupplyChainTableViewController"
        static let CategoriesVCIdentifier = "CategoriesTableViewController"
        static let CommunityEffortVCIdentifier = "CommunityEffortTableViewController"
    }
    
    @IBAction func actionButtonTapped(sender: UIBarButtonItem) {
        if let barcode = product?.barcode.asString() {
            let urlString = Constants.OpenFoodFactsWebEditURL + barcode
            if let requestUrl = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(requestUrl)
            }
        }

    }
    
    var pageIndex = 0 {
        didSet {
            if product != nil {
                if pages.isEmpty {
                    initPages()
                }
                if pageIndex < 0 || pageIndex > pages.count {
                    self.pageIndex = 0
                }
                // open de corresponding page
                setViewControllers(
                    [pages[pageIndex]],
                    direction: .Forward,
                    animated: true, completion: nil)
                title = titles[pageIndex]
            }
        }
    }
    
    private var pages: [UIViewController] = []
    
    func initPages () {
        // set up pages
        if pages.isEmpty {
            pages.append(page1)
            pages.append(page2)
            pages.append(page3)
            pages.append(page4)
            pages.append(page5)
            pages.append(page6)
        }
    }
    
    private var titles = [NSLocalizedString("Identification", comment: "Viewcontroller title for page with product identification info."),
        NSLocalizedString("Ingredients", comment: "Viewcontroller title for page with ingredients for product."),
        NSLocalizedString("Nutritional facts", comment: "Viewcontroller title for page with nutritional facts for product."),
        NSLocalizedString("Supply Chain", comment: "Viewcontroller title for page with supply chain for product."),
        NSLocalizedString("Categories", comment: "Viewcontroller title for page with categories for product."),
        NSLocalizedString("Community Effort", comment: "Viewcontroller title for page with community effort for product.")]
    
    var page1: UIViewController {
        get {
            return storyboard!.instantiateViewControllerWithIdentifier(Constants.IdentificationVCIdentifier)
        }
    }
    var page2: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewControllerWithIdentifier(Constants.IngredientsVCIdentifier)
        }
    }
    var page3: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewControllerWithIdentifier(Constants.NutrientsVCIdentifier)
        }
    }
    var page4: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewControllerWithIdentifier(Constants.SupplyChainVCIdentifier)
        }
    }
    var page5: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewControllerWithIdentifier(Constants.CategoriesVCIdentifier)
        }
    }
    var page6: UIViewController {
        get {
            return UIStoryboard(name: Constants.StoryBoardIdentifier, bundle: nil).instantiateViewControllerWithIdentifier(Constants.CommunityEffortVCIdentifier)
        }
    }

    var product: FoodProduct? = nil {
        didSet {
            if pages.isEmpty {
                initPages()
                if let vc = pages[0] as? IdentificationTableViewController {
                    vc.product = product
                    title = titles[0]
                }
                if let vc = pages[1] as? IngredientsTableViewController {
                    vc.product = product
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
            }
        }
    }
    
    // MARK: - Pageview Controller data source
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = pages.indexOf(viewController) else {
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
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
     
        guard let viewControllerIndex = pages.indexOf(viewController) else {
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
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            firstViewControllerIndex = pages.indexOf(firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let current = viewControllers?.first,
            let viewControllerIndex = pages.indexOf(current) {
                title = titles[viewControllerIndex]
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true

        dataSource = self
        delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        initPages()
    }
}
