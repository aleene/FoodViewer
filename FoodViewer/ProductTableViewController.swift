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
        }
        static let ViewControllerTitle = NSLocalizedString("Products", comment: "Title of ViewController with a list of all products that has been viewed.")
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
            let indexInHistory = products.fetchProduct(barcode)
            if  indexInHistory != nil//,
                //let validFetchResult = products.fetchResultList[indexInHistory!] 
                {
                // let lijst = products.fetchResultList
                switch products.fetchResultList[indexInHistory!]  {
                case .success(let product):
                    selectedProduct = product
                    selectedIndex = 0
                    tableView.reloadData()
                    tableView.scrollToRow(at: IndexPath(row: 0, section: indexInHistory!), at: .middle, animated: true)
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func startInterface() {
        if !products.fetchResultList.isEmpty {
            //if let validFetchResult = products.fetchResultList[0] {
                switch products.fetchResultList[0] {
                case .success(let product):
                    selectedProduct = product
                    tableView.reloadData()
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                default: break
                }
            //}
        } else {
            selectedProduct = nil
        }
    }
    
    fileprivate func refreshInterface() {
        if products.fetchResultList.count > 0 {
            tableView.reloadData()
        }
    }

    var productPageViewController: ProductPageViewController? = nil
     
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
            static let BeingLoaded = "Product Being Loaded Cell"
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
            default:
                break
            }
        // }
        // no rows as the loading failed, the error message is in the header
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[(indexPath as NSIndexPath).row]
        if !products.fetchResultList.isEmpty {
            //if let fetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch products.fetchResultList[(indexPath as NSIndexPath).section] {
                case .success(let currentProduct):
                    switch currentProductSection {
                    case .name:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Name, for: indexPath) as! NameTableViewCell
                        switch currentProduct.brands {
                        case .undefined, .empty:
                            cell.productBrand = [currentProduct.brands.description()]
                        case let .available(list):
                            cell.productBrand = list
                        }

                        if let language = currentProduct.primaryLanguageCode {
                            if currentProduct.frontImages != nil && currentProduct.frontImages!.small.count > 0 {
                                if let result = currentProduct.frontImages!.small[language]?.fetch() {
                                    switch result {
                                    case .success:
                                        cell.productImage = currentProduct.frontImages!.small[language]?.image
                                    default:
                                    cell.productImage = nil
                                    }
                                }
                            } else {
                                cell.productImage = nil
                            }
                        } else {
                            cell.productImage = nil
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
                        if let count = currentProduct.traceKeys?.count {
                            cell.badgeString = "\(count)"
                        } else {
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no traces defined.")
                        }
                        return cell
                        
                    case .allergens:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Allergens, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = NSLocalizedString("Allergens", comment: "Text to indicate the allergens of a product.")
                        if let count = currentProduct.allergenKeys?.count {
                            cell.badgeString = "\(count)"
                        } else {
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

                        switch currentProduct.categories {
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
                        if let count = currentProduct.countries?.count {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(count)"
                        } else {
                            cell.badgeString = NSLocalizedString("undefined", comment: "Text to indicate the product has no sales countries defined.")
                        }
                        return cell
                    }
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BeingLoaded, for: indexPath) as? BeingLoadedTableViewCell
                    cell?.status = products.fetchResultList[(indexPath as NSIndexPath).section]
                }
            //}
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BeingLoaded, for: indexPath) as? BeingLoadedTableViewCell
            
        cell?.status = nil
        return cell!
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = (indexPath as NSIndexPath).row
        if let index = selectedIndex {
            selectedRowType = tableStructure[index]
        }
        if !products.fetchResultList.isEmpty {
            //if let validProductFetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch products.fetchResultList[(indexPath as NSIndexPath).section] {
                case .success(let product):
                    selectedProduct = product
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
        if !products.fetchResultList.isEmpty {
            if !products.fetchResultList.isEmpty{
                switch products.fetchResultList[section] {
                case .success(let product):
                    
                    label.text = product.name != nil ? product.name! : Constants.ProductNameMissing
                    if let validKeys = product.allergenKeys {
                        if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                            tempView.backgroundColor = UIColor.red
                        }
                    } else {
                        if let validKeys = product.traceKeys {
                            if !validKeys.isEmpty {
                                let warn = AllergenWarningDefaults.manager.hasValidWarning(validKeys)
                                if warn {
                                    tempView.backgroundColor = UIColor.red
                                }
                            }
                        }
                    }
                case .other(let message):
                    label.text = message
                default:
                    label.text = products.fetchResultList[section].description()
                }
            } else {
                label.text = Constants.BusyLoadingProduct
            }
        } else {
            label.text = Constants.NoProductsInHistory
        }
        
        tempView.addSubview(label)
        tempView.tag = section;
        return tempView;
    }
   
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !products.fetchResultList.isEmpty {
            if let validProductFetchResult = products.fetchResultList[section] {
                switch validProductFetchResult {
                case .Success(let product):
                    return product.name != nil ? product.name! : Constants.ProductNameMissing
                default:
                    return validProductFetchResult.description()
                }
            }
            return Constants.BusyLoadingProduct
        }
        return Constants.NoProductsInHistory
    }
  */

    // http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
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
            barcode = BarcodeType(typeCode:vc.type, value:vc.barcode, type:currentProductType)
            searchTextField.text = vc.barcode
            performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
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
        startInterface()
    }

    // MARK: - Viewcontroller lifecycle
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        
        initializeCustomKeyboard()
        // Preferences.manager
        startInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch currentProductType {
        case .food:
            title = Constants.Title.Food
        case .petFood:
            title = Constants.Title.PetFood
        case .beauty:
            title = Constants.Title.Beauty
        }

        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.showAlertProductNotAvailable(_:)), name:.ProductNotAvailable, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productLoaded(_:)), name:.ProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductLoadingError, object:nil)
        // listen if a product has been changed through an update
        //NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductUpdateSucceeded, object:nil)
        // listen to see if any images have been retrieved asynchronously
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


