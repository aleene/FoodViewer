    //
//  ProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import Foundation

class ProductTableViewController: UITableViewController, UITextFieldDelegate, KeyboardDelegate {

    fileprivate struct Constants {
        fileprivate struct Title {
            static let Food = NSLocalizedString("Food Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
            static let PetFood = NSLocalizedString("Petfood Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
            static let Beauty = NSLocalizedString("Beauty Products", comment: "Title of ViewController with a list of all food products that has been viewed.")
            static let NoSearch = NSLocalizedString("Search Undefined", comment: "Title of ViewController when no search has been defined.")
        }
        // static let ViewControllerTitle = NSLocalizedString("Products", comment: "Title of ViewController with a list of all products that has been viewed.")
        static let AlertSheetMessage = NSLocalizedString("Product does not exist. Add?", comment: "Alert message, when the product could not be retrieved from Internet.")
        static let AlertSheetActionTitleForCancel = NSLocalizedString("Nope", comment: "Alert title, to indicate product should NOT be added")
        static let AlertSheetActionTitleForAdd = NSLocalizedString("Sure", comment: "Alert title, to indicate product should be added")
        static let NoProductsInHistory = NSLocalizedString("No products listed", comment: "Text to indicate that the history of products is empty.")
        static let BusyLoadingProduct = NSLocalizedString("Loading product", comment: "Text to indicate that the it is trying to load.")
        static let ProductNameMissing = NSLocalizedString("No product name", comment: "Text in header of section, indicating that the product name is missing.")
        static let NumberOfNutritionalFactsText = NSLocalizedString("%@ nutritional facts specified", comment: "Cell text for the total number of nutritional facts available.")
    }
    

    fileprivate var products = OFFProducts.manager
    
    fileprivate var barcode: BarcodeType? = nil {
        didSet {
            let index = products.fetchProduct(barcode)
            if  let validIndex = index //,
                //let validFetchResult = products.fetchResultList[indexInHistory!] 
                {
                // let lijst = products.fetchResultList
                switch products.fetchResultList[validIndex]  {
                case .success(let product):
                    selectedProduct = product
                    selectedIndex = 0
                    tableView.reloadData()
                    tableView.scrollToRow(at: IndexPath(row: 0, section: validIndex), at: .middle, animated: true)
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func startInterface(at index:Int) {
        if !products.fetchResultList.isEmpty && index < products.fetchResultList.count {
            switch products.fetchResultList[index] {
            case .success(let product):
                selectedProduct = product
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
            default:
                selectedProduct = nil
                tableView.reloadData()
            }
        } else {
            selectedProduct = nil
            tableView.reloadData()
        }
        setTitle()
    }
    
    fileprivate func refreshInterface() {
        if products.fetchResultList.count > 0 {
            tableView.reloadData()
        }
    }

    var productPageViewController: ProductPageViewController? = nil
    
    fileprivate func setTitle() {
        if OFFProducts.manager.list == .recent {
            switch currentProductType {
            case .food:
                title = Constants.Title.Food
            case .petFood:
                title = Constants.Title.PetFood
            case .beauty:
                title = Constants.Title.Beauty
            }
        } else {
            title = products.searchValue ?? Constants.Title.NoSearch
        }
    }
    
    // MARK: - TextField Methods
    
    var activeTextField = UITextField()
 
 
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            if let searchText = barcode?.asString() {
                searchTextField.text = searchText
            }
        }
    }
 
    func textFieldDidBeginEditing(_ textFieldUser: UITextField) {
        activeTextField = textFieldUser
    }
    
    func initializeCustomKeyboard() {
        // initialize custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        searchTextField.inputView = keyboardView

        // the view controller will be notified by the keyboard whenever a key is tapped
        keyboardView.delegate = self
    }

    func keyWasTapped(_ character: String) {
        activeTextField.insertText(character)
    }
    
    func backspace() {
        activeTextField.deleteBackward()
    }

    func enter() {
        view.endEditing(true)
        if !searchTextField.text!.isEmpty {
            barcode = BarcodeType(barcodeTuple: (searchTextField.text!, currentProductType.rawValue))
        }
    }

    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    // MARK: - Table view methods and vars
    
    fileprivate var selectedProduct: FoodProduct? = nil {
        didSet {
            if selectedIndex == nil {
                selectedIndex = 0
            }
            showSelectedProduct()
        }
    }
    
    fileprivate var selectedIndex: Int? = nil // this indicates which part of the product must be shown
    
    fileprivate var selectedRowType: RowType? = nil
    
    fileprivate func showSelectedProduct() {
        // prevent that to many changes are pushed on the view stack
        // check the current presented controller
        // only segue if we are at the top of the stack
        // i.e. only segue once
        if let parentVC = self.parent as? UINavigationController {
            let testVC = parentVC.visibleViewController as? ProductTableViewController
            if testVC != nil {
                performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
            }
        }
    }

    fileprivate enum RowType {
        case name
        case ingredients
        case traces
        case allergens
        case nutritionFacts
        case nutritionScore
        case categories
        case completion
        case supplyChain
    }

    // defines the order of the rows
    private var tableStructure: [RowType] {
        switch currentProductType {
        case .food:
            return [.name, .nutritionScore, .ingredients, .allergens, .traces, .nutritionFacts, .supplyChain, .categories, .completion]
        case .petFood:
            return [.name, .ingredients, .nutritionFacts, .supplyChain, .categories, .completion]
        case .beauty:
            return [.name, .ingredients, .supplyChain, .categories, .completion ]
        }
    }
    
    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let Name = "Product Name Cell"
            static let Ingredients = "Product Ingredients Cell"
            static let Traces = "Product Traces Cell"
            static let Allergens = "Product Allergens Cell"
            static let Countries = "Countries Cell"
            static let NutritionFacts = "Product Nutrition Facts Name Cell"
            static let NutritionScore = "Product Nutrition Score Cell"
            static let Categories = "Product Categories Cell"
            static let Completion = "Product Completion State Cell"
            static let Producer = "Product Producer Cell"
            static let TagListView = "Product TagListView Cell"
        }
        struct SegueIdentifier {
            static let ToPageViewController = "Show Page Controller"
            static let ShowSettings = "Show Settings Segue"
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return products.fetchResultList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if let validProductFetchResult = products.fetchResultList[section] {
            switch products.fetchResultList[section] {
            case .success:
                return tableStructure.count
            case .more:
                // allow a cell with a button
                return 1
            default:
                break
            }
        // }
        // no rows as the loading failed, the error message is in the header
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.row]
        if !products.fetchResultList.isEmpty && indexPath.section < products.fetchResultList.count {
            //if let fetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch products.fetchResultList[indexPath.section] {
                case .success(let currentProduct):
                    switch currentProductSection {
                    case .name:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Name, for: indexPath) as! NameTableViewCell
                        switch currentProduct.brandsOriginal {
                        case .undefined, .empty:
                            cell.productBrand = [currentProduct.brandsOriginal.description()]
                        case let .available(list):
                            cell.productBrand = list
                        }

                        if let language = currentProduct.primaryLanguageCode {
                            cell.productImage = nil
                            if currentProduct.frontImages != nil && currentProduct.frontImages!.small.count > 0 {
                                if let result = currentProduct.frontImages!.small[language]?.fetch() {
                                    switch result {
                                    case .available:
                                        cell.productImage = currentProduct.frontImages!.small[language]?.image
                                    default:
                                        break
                                    }
                                }
                            }
                        }
                        return cell
                        
                    case .ingredients:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Ingredients, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = NSLocalizedString("Ingredients", comment: "Text to indicate the ingredients of a product.")

                        if let number = currentProduct.numberOfIngredients {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(number)"
                        } else {
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no ingredients defined.")
                        }
                        return cell
                        
                    case .traces:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Traces, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = NSLocalizedString("Traces", comment: "Text to indicate the traces of a product.")
                        switch currentProduct.tracesInterpreted {
                        case .available(let traces):
                            cell.badgeString = "\(traces.count)"
                        default:
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no traces defined.")
                        }
                        return cell
                        
                    case .allergens:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Allergens, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = NSLocalizedString("Allergens", comment: "Text to indicate the allergens of a product.")
                        switch currentProduct.allergensTranslated {
                        case .available(let allergens):
                            cell.badgeString = "\(allergens.count)"
                        default:
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no allergens defined.")
                        }
                        return cell

                    case .nutritionFacts:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionFacts, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = NSLocalizedString("Nutrition Facts", comment: "Text to indicate the nutrition facts of a product.")

                        if let count = currentProduct.nutritionFacts?.count {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(count)"
                        } else {
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no ingredients defined.")
                        }
                        return cell
                        
                    case .nutritionScore:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionScore, for: indexPath) as? NutritionScoreTableViewCell
                        cell?.product = currentProduct
                        return cell!
                        
                    case .categories:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = NSLocalizedString("Categories", comment: "Text to indicate the product belongs to a category.")

                        switch currentProduct.categoriesHierarchy {
                        case .undefined, .empty:
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no categories defined.")
                        case let .available(list):
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(list.count)"
                        }
                        return cell
                    case .completion:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Completion, for: indexPath) as? CompletionTableViewCell
                        cell?.product = currentProduct
                        return cell!
                    case .supplyChain:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Producer, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = NSLocalizedString("Sales countries", comment: "Text to indicate the sales countries of a product.")
                        switch currentProduct.countriesTranslated {
                        case .available(let countries):
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(countries.count)"
                        default:
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no sales countries defined.")
                        }
                        return cell
                    }
                case .more:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = 1
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.error
                    cell?.accessoryType = .none
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = 0
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.normal
                    return cell!
                }
            //}
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as? TagListViewTableViewCell
        return cell!
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        if let index = selectedIndex {
            selectedRowType = tableStructure[index]
        }
        if !products.fetchResultList.isEmpty {
            //if let validProductFetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch products.fetchResultList[indexPath.section] {
                case .success(let product):
                    selectedProduct = product
                case .more:
                    // The next set should be loaded
                    products.fetchSearchProductsForNextPage()
                default: break
                }
            //}
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel.init(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 20))
        tempView.backgroundColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        if !products.fetchResultList.isEmpty && (section < products.fetchResultList.count) {
            switch products.fetchResultList[section] {
            case .success(let product):
                label.text = product.name != nil ? product.name! : Constants.ProductNameMissing
                switch product.tracesInterpreted {
                case .available(let validKeys):
                    if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                        tempView.backgroundColor = UIColor.red
                    }
                default:
                    break
                }
                switch product.tracesInterpreted {
                case .available(let validKeys):
                    if !validKeys.isEmpty {
                        let warn = AllergenWarningDefaults.manager.hasValidWarning(validKeys)
                        if warn {
                            tempView.backgroundColor = UIColor.red
                        }
                    }
                default:
                    break
                }
            case .other(let message):
                label.text = message
            case .more:
                // no header required in this case
                return nil
            default:
                label.text = products.fetchResultList[section].description()
            }
        } else {
            label.text = Constants.NoProductsInHistory
        }
        
        tempView.addSubview(label)
        tempView.tag = section
        return tempView
    }

    // http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch products.fetchResultList[section] {
        case .more:
            // no header required in this case
            return 0.0
        default:
            return UITableViewAutomaticDimension
        }
    }
    
// MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ToPageViewController:
                if let vc = segue.destination as? UINavigationController {
                    if let ppvc = vc.topViewController as? ProductPageViewController {
                        ppvc.product = selectedProduct
                        if let validSelectedRowType = selectedRowType {
                            ppvc.pageIndex = pageIndex(validSelectedRowType)
                        } else {
                            ppvc.pageIndex = 0
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowSettings:
                if let vc = segue.destination as? SettingsTableViewController {
                    vc.storedHistory = products.storedHistory
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    setNeedsStatusBarAppearanceUpdate()
                }

            default: break
            }
        }
    }
    
    private func pageIndex(_ rowType: RowType) -> Int {
        switch currentProductType {
        case .food:
            switch rowType {
            case .name:
                return 0
            case .ingredients, .allergens, .traces:
                return 1
            case .nutritionFacts:
                return 2
            case .supplyChain:
                return 3
            case .categories:
                return 4
            case .completion:
                return 5
            case .nutritionScore:
                return 6
            }
        case .petFood:
            switch rowType {
            case .name:
                return 0
            case .ingredients, .allergens, .traces:
                return 1
            case .nutritionFacts:
                return 2
            case .supplyChain:
                return 3
            case .categories:
                return 4
            case .completion:
                return 5
            default:
                return 0
            }
        case .beauty:
            switch rowType {
            case .name:
                return 0
            case .ingredients, .allergens, .traces:
                return 1
            case .supplyChain:
                return 2
            case .categories:
                return 3
            case .completion:
                return 4
            default:
                return 0
            }
        }
    }

    @IBAction func unwindForCancel(_ segue:UIStoryboardSegue) {
        if let _ = segue.source as? BarcodeScanViewController {
            if products.fetchResultList.count > 0 {
                tableView.reloadData() 
            }
        }
    }
    
    @IBAction func unwindNewSearch(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? BarcodeScanViewController {
            switchToTab(withIndex: 0)
            barcode = BarcodeType(typeCode:vc.type, value:vc.barcode, type:currentProductType)
            searchTextField.text = vc.barcode
            products.list = .recent
            startInterface(at: 0)

            performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
        } else {
            assert(true, "ProductTableViewController: BarcodeScanViewController hierarchy error")
        }
    }
    
    
    @IBAction func settingsDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SettingsTableViewController {
            if vc.historyHasBeenRemoved {
                products.removeAll()
                performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
            }
            // force a reload of all products
            if currentProductType != vc.changedCurrentProductType {
                Preferences.manager.showProductType = vc.changedCurrentProductType
                products.reloadAll()
            }
            tableView.reloadData()
        }
    }
    
    private func switchToTab(withIndex index: Int) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            tabVC.selectedIndex = index
        } else {
            assert(true, "ProductTableViewController: TabBar hierarchy error")
        }
    }
    
    // MARK: - Notification methods
    
    // function is called if an product image has been retrieved via an asynchronous process
    func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        
        // We are only interested in medium-sized front images
        let imageSizeCategory = ImageSizeCategory(rawValue: userInfo![ProductImageData.Notification.ImageSizeCategoryKey] as! Int )
        let imageTypeCategory = ImageTypeCategory(rawValue: userInfo![ProductImageData.Notification.ImageTypeCategoryKey] as! Int )
        if imageSizeCategory == .small && imageTypeCategory == .front {
            tableView.reloadData()
            /*
            // I would like to load only the section with the image
            // results in a NSException
            let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String
            for (index, fetchResult) in products.fetchResultList.enumerated() {
                guard fetchResult != nil else { break }
                switch fetchResult! {
                case .success(let currentProduct):
                    if currentProduct.barcode.asString() == barcodeString {
                        // reload the section and row corresponding to this product
                        let indexPath = IndexPath.init(row: 0, section: index)
                        let indexPaths = [indexPath]
                        tableView.reloadRows(at: indexPaths, with: .none)
                        tableView.reloadSections(sections, with: .fade)
                    }
                default: break
                }
            }
            */
        }

    }
    
    func showAlertProductNotAvailable(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        let error = userInfo!["error"] as? String ?? "No valid error"
        let barcodeString = userInfo![OFFProducts.Notification.BarcodeDoesNotExistKey] as? String
        let alert = UIAlertController(
            title: Constants.AlertSheetMessage,
            message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: Constants.AlertSheetActionTitleForCancel, style: .cancel) { (action: UIAlertAction) -> Void in // do nothing )
            }
        )
        if let validBarcodeString = barcodeString {
            // if there is a valid barcode, allow the user to add it
            alert.addAction(UIAlertAction(title: Constants.AlertSheetActionTitleForAdd, style: .destructive) { (action: UIAlertAction) -> Void in
                let newProduct = FoodProduct.init(withBarcode: BarcodeType(barcodeTuple: (validBarcodeString,self.currentProductType.rawValue)))
                let preferredLanguage = Locale.preferredLanguages[0]
                let currentLanguage = preferredLanguage.characters.split{ $0 == "-" }.map(String.init)

                newProduct.primaryLanguageCode = currentLanguage[0]
                let update = OFFUpdate()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                // TBD kan de queue stuff niet in OFFUpdate gedaan worden?
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    let fetchResult = update.update(product: newProduct)
                    DispatchQueue.main.async(execute: { () -> Void in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        switch fetchResult {
                        case .success:
                            self.barcode = BarcodeType(barcodeTuple: (validBarcodeString, self.currentProductType.rawValue))
                            self.searchTextField.text = validBarcodeString
                            self.performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
                            break
                        case .failure:
                            // no feedback needed
                            break
                        }
                    })
                })
                }
            )
        }
        self.present(alert, animated: true, completion: nil)
    }

    func productLoaded(_ notification: Notification) {
        refreshInterface()
    }
    
    func productUpdated(_ notification: Notification) {
        refreshInterface()
    }
    // 
    func firstProductLoaded(_ notification: Notification) {
        startInterface(at: 0)
    }
    
    func searchLoaded(_ notification: Notification) {
        switchToTab(withIndex: 1)
        if let index = notification.userInfo?[OFFProducts.Notification.SearchOffsetKey] as? Int {
            startInterface(at:index)
        }
    }

    func searchStarted(_ notification: Notification) {
        switchToTab(withIndex: 1)
        if let firstPage = notification.userInfo?[OFFProducts.Notification.SearchPageKey] as? Int {
            // if there is no SearchOffSet, then the search just started
            // If it is the first page, position the interface on the first section
            if firstPage == 0 {
                startInterface(at:0)
            }
        }
    }


//    func addGesture() {
//        let swipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action:#selector(ProductTableViewController.nextProductType))
//        swipeGestureRecognizer.numberOfTouchesRequired = 2
//        swipeGestureRecognizer.direction = .down
//        swipeGestureRecognizer.delegate = self
//        tableView?.addGestureRecognizer(swipeGestureRecognizer)
//    }
    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
                startInterface(at: 0)
            }
        }
    }
    
    // MARK: - Viewcontroller lifecycle
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the recents tab
            tabVC.selectedIndex = 0
            tabVC.delegate = self

            // show history products
            products.list = .recent
            products.search = nil
            products.searchValue = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        
        initializeCustomKeyboard()
        
        startInterface(at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // addGesture()
        setTitle()

        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.showAlertProductNotAvailable(_:)), name:.ProductNotAvailable, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productLoaded(_:)), name:.ProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.searchLoaded(_:)), name:.SearchLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.searchStarted(_:)), name:.SearchStarted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductLoadingError, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProductTableViewController.imageSet(_:)), name: .ImageSet, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshInterface()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
}
   
extension ProductTableViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Identify gesture recognizer and return true else false.
        return gestureRecognizer.isEqual(self.downTwoFingerSwipe) ? true : false
    }
}
   
extension ProductTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        products.list = tabBarController.selectedIndex == 0 ? .recent : .search
        startInterface(at: 0)
    }
    
}
    
    
// MARK: - TagListView DataSource Functions
    
extension ProductTableViewController: TagListViewDataSource {
        
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
        
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if tagListView.tag == 0 {
            let fetchStatus = ProductFetchStatus.loading
            return fetchStatus.description()
        } else if tagListView.tag == 1 {
            let fetchStatus = ProductFetchStatus.more(0)
            return fetchStatus.description()
        }
        return "ProductTableViewController: tagListView.tag not recognized"
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
        
}
    
// MARK: - TagListView Delegate Functions
    
extension ProductTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
}



