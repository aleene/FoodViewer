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
        static let ViewControllerTitle = NSLocalizedString("Products", comment: "Title of ViewController with a list of all products that has been viewed.")
        static let AlertSheetMessage = NSLocalizedString("Product does not exist. Add?", comment: "Alert message, when the product could not be retrieved from Internet.")
        static let AlertSheetActionTitleForCancel = NSLocalizedString("Nope", comment: "Alert title, to indicate product should NOT be added")
        static let AlertSheetActionTitleForAdd = NSLocalizedString("Sure", comment: "Alert title, to indicate product should be added")
        static let NoProductsInHistory = NSLocalizedString("No products listed", comment: "Text to indicate that the history of products is empty.")
        static let BusyLoadingProduct = NSLocalizedString("Loading product", comment: "Text to indicate that the it is trying to load.")
        static let ProductNameMissing = NSLocalizedString("No product name", comment: "Text in header of section, indicating that the product name is missing.")
        static let NumberOfNutritionalFactsText = NSLocalizedString("%@ nutritional facts specified.", comment: "Cell text for the total number of nutritional facts available.")
    }
    

    fileprivate let products = OFFProducts.manager
    
    fileprivate var barcode: BarcodeType? = nil {
        didSet {
            let indexInHistory = products.fetchProduct(barcode)
            if  indexInHistory != nil,
                let validFetchResult = products.fetchResultList[indexInHistory!] {
                switch validFetchResult  {
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
            if let validFetchResult = products.fetchResultList[0] {
                switch validFetchResult {
                case .success(let product):
                    selectedProduct = product
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            default: break
            }
        }
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
            barcode = BarcodeType(value:searchTextField.text!)
        }
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
    
    fileprivate func showSelectedProduct() {
        // prevent that to many changes are pushed on the view stack
        // check the current presented controller
        // only segue if we are at the top of the stack
        // i.e. only segue once
        if let parentVC = self.parent as? UINavigationController {
            let testVC = parentVC.visibleViewController as? ProductTableViewController
            if testVC != nil {
                performSegue(withIdentifier: Storyboard.ToPageViewControllerSegue, sender: self)
            }
        }
    }

    fileprivate enum RowType {
        case name
        case ingredients
        case nutritionFacts
        case nutritionScore
        case categories
        case completion
        case supplyChain
    }

    // defines the order of the rows
    fileprivate var tableStructure: [RowType] = [.name, .ingredients, .nutritionFacts, .supplyChain, .categories, .completion, .nutritionScore]

    fileprivate struct Storyboard {
        static let NameCellIdentifier = "Product Name Cell"
        static let IngredientsCellIdentifier = "Product Ingredients Cell"
        static let CountriesCellIdentifier = "Countries Cell"
        static let NutritionFactsCellIdentifier = "Product Nutrition Facts Name Cell"
        static let NutritionScoreCellIdentifier = "Product Nutrition Score Cell"
        static let CategoriesCellIdentifier = "Product Categories Cell"
        static let CompletionCellIdentifier = "Product Completion State Cell"
        static let ProducerCellIdentifier = "Product Producer Cell"
        static let BeingLoadedCellIdentifier = "Product Being Loaded Cell"
        static let ToPageViewControllerSegue = "Show Page Controller"
        static let ShowSettingsSegueIdentifier = "Show Settings Segue"
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return products.fetchResultList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let validProductFetchResult = products.fetchResultList[section] {
            switch validProductFetchResult {
            case .success:
                return products.fetchResultList[section] != nil ? tableStructure.count : 1
            default:
                break
            }
        }
        // no rows as the loading failed, the error message is in the header
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[(indexPath as NSIndexPath).row]
        if !products.fetchResultList.isEmpty {
            if let fetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch fetchResult {
                case .success(let currentProduct):
                    switch currentProductSection {
                    case .name:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NameCellIdentifier, for: indexPath) as! NameTableViewCell
                        switch currentProduct.brands {
                        case .undefined, .empty:
                            cell.productBrand = [currentProduct.brands.description()]
                        case let .available(list):
                            cell.productBrand = list
                        }
                    
                        // TBD I do not think the logic is right here
                        if let data = currentProduct.mainImageSmallData {
                            // try small image
                            cell.productImage = UIImage(data:data)
                            return cell
                        } else if currentProduct.mainImageUrl != nil {
                            // show small image icon
                            cell.productImage = nil
                            return cell
                        }
                        if let result = currentProduct.mainImageData {
                            switch result {
                            case .success(let data):
                                cell.productImage = UIImage(data:data)
                            default:
                                cell.productImage = nil
                            }
                        } else {
                            cell.productImage = nil
                        }
                        return cell
                    case .ingredients:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.IngredientsCellIdentifier, for: indexPath) as! IngredientsTableViewCell
                        cell.product = currentProduct
                        return cell
                    case .nutritionFacts:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactsCellIdentifier, for: indexPath)
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        let formattedCount = currentProduct.nutritionFacts != nil ? formatter.string(from: NSNumber.init(integerLiteral: currentProduct.nutritionFacts!.count)) :
                        formatter.string(from: NSNumber.init(integerLiteral: 0))
                    
                        cell.textLabel!.text = String.localizedStringWithFormat(Constants.NumberOfNutritionalFactsText, formattedCount!)
                        return cell
                    case .nutritionScore:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionScoreCellIdentifier, for: indexPath) as? NutritionScoreTableViewCell
                        cell?.product = currentProduct
                        return cell!
                    case .categories:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CategoriesCellIdentifier, for: indexPath) as! CategoriesTableViewCell
                        cell.categories = currentProduct.categories
                        return cell
                    case .completion:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CompletionCellIdentifier, for: indexPath) as? CompletionTableViewCell
                        cell?.product = currentProduct
                        return cell!
                    case .supplyChain:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ProducerCellIdentifier, for: indexPath) as? ProducerTableViewCell
                        cell?.product = currentProduct
                        return cell!
                    }
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BeingLoadedCellIdentifier, for: indexPath) as? BeingLoadedTableViewCell
                    cell?.status = fetchResult
                }
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BeingLoadedCellIdentifier, for: indexPath) as? BeingLoadedTableViewCell
            
        cell?.status = nil
        return cell!
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = (indexPath as NSIndexPath).row
        if !products.fetchResultList.isEmpty {
            if let validProductFetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch validProductFetchResult {
                case .success(let product):
                    selectedProduct = product
                default: break
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel.init(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 20))
        tempView.backgroundColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        if !products.fetchResultList.isEmpty {
            if let validProductFetchResult = products.fetchResultList[section] {
                switch validProductFetchResult {
                case .success(let product):
                    
                    label.text = product.name != nil ? product.name! : Constants.ProductNameMissing
                    if let validKeys = product.allergenKeys {
                        if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                            tempView.backgroundColor = UIColor.red
                        }
                    } else {
                        if let validKeys = product.traceKeys {
                            if AllergenWarningDefaults.manager.hasValidWarning(validKeys) {
                                tempView.backgroundColor = UIColor.red
                            }
                        }
                    }
                default:
                    label.text = validProductFetchResult.description()
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
            case Storyboard.ToPageViewControllerSegue:
                if let vc = segue.destination as? UINavigationController {
                    if let ppvc = vc.topViewController as? ProductPageViewController {
                        ppvc.product = selectedProduct
                        ppvc.pageIndex = selectedIndex
                    }
                }
            case Storyboard.ShowSettingsSegueIdentifier:
                if let vc = segue.destination as? SettingsTableViewController {
                    vc.storedHistory = products.storedHistory
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    setNeedsStatusBarAppearanceUpdate()
                }

            default: break
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
            barcode = BarcodeType(typeCode:vc.type, value:vc.barcode)
            searchTextField.text = vc.barcode
            performSegue(withIdentifier: Storyboard.ToPageViewControllerSegue, sender: self)
        }
    }
    
    
    @IBAction func settingsDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SettingsTableViewController {
            tableView.reloadData()
            if vc.historyHasBeenRemoved {
                products.removeAll()
                performSegue(withIdentifier: Storyboard.ToPageViewControllerSegue, sender: self)
            }
            
        }
    }
    
    // MARK: - Notification methods
    
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
                let newProduct = FoodProduct.init(withBarcode: BarcodeType(value: validBarcodeString))
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
                            self.barcode = BarcodeType(value: validBarcodeString)
                            self.searchTextField.text = validBarcodeString
                            self.performSegue(withIdentifier: Storyboard.ToPageViewControllerSegue, sender: self)
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

        title = Constants.ViewControllerTitle

        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.showAlertProductNotAvailable(_:)), name:.ProductNotAvailable, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productLoaded(_:)), name:.ProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductLoadingError, object:nil)
        // listen if a product has been changed through an update
        //NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductUpdateSucceeded, object:nil)
        

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


