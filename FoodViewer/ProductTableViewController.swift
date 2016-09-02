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

    private struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Products", comment: "Title of ViewController with a list of all products that has been viewed.")
        static let AlertSheetMessage = NSLocalizedString("Error retrieving product", comment: "Alert message, when the product could not be retrieved from Internet.")
        static let AlertSheetActionTitle = NSLocalizedString("Pity", comment: "Alert title, to indicate retrieving product did not work")
        static let NoProductsInHistory = NSLocalizedString("No products listed", comment: "Text to indicate that the history of products is empty.")
        static let BusyLoadingProduct = NSLocalizedString("Busy loading product", comment: "Text to indicate that the it is trying to load.")
        static let ProductNameMissing = NSLocalizedString("No product name", comment: "Text in header of section, indicating that the product name is missing.")
        static let NumberOfNutritionalFactsText = NSLocalizedString("%@ nutritional facts specified.", comment: "Cell text for the total number of nutritional facts available.")
    }
    

    private let products = OFFProducts.manager
    
    private var barcode: BarcodeType? = nil {
        didSet {
            let indexInHistory = products.fetchProduct(barcode)
            if  indexInHistory != nil,
                let validFetchResult = products.fetchResultList[indexInHistory!] {
                switch validFetchResult  {
                case .Success(let product):
                    selectedProduct = product
                    selectedIndex = 0
                    tableView.reloadData()
                    tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: indexInHistory!), atScrollPosition: .Middle, animated: true)
                default:
                    break
                }
            }
        }
    }
    
    private func startInterface() {
        if !products.fetchResultList.isEmpty {
            if let validFetchResult = products.fetchResultList[0] {
                switch validFetchResult {
                case .Success(let product):
                    selectedProduct = product
                tableView.reloadData()
                tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
            default: break
            }
        }
        }
    }
    
    private func refreshInterface() {
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
 
    func textFieldDidBeginEditing(textFieldUser: UITextField) {
        activeTextField = textFieldUser
    }
    
    func initializeCustomKeyboard() {
        // initialize custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        searchTextField.inputView = keyboardView

        // the view controller will be notified by the keyboard whenever a key is tapped
        keyboardView.delegate = self
    }

    func keyWasTapped(character: String) {
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
    
    private var selectedProduct: FoodProduct? = nil {
        didSet {
            if selectedIndex == nil {
                selectedIndex = 0
            }
            showSelectedProduct()
        }
    }
    
    private var selectedIndex: Int? = nil // this indicates which part of the product must be shown
    
    private func showSelectedProduct() {
        // prevent that to many changes are pushed on the view stack
        // check the current presented controller
        // only segue if we are at the top of the stack
        // i.e. only segue once
        if let parentVC = self.parentViewController as? UINavigationController {
            let testVC = parentVC.visibleViewController as? ProductTableViewController
            if testVC != nil {
                performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
            }
        }
    }

    private enum RowType {
        case Name
        case Ingredients
        case NutritionFacts
        case NutritionScore
        case Categories
        case Completion
        case SupplyChain
    }

    // defines the order of the rows
    private var tableStructure: [RowType] = [.Name, .Ingredients, .NutritionFacts, .SupplyChain, .Categories, .Completion, .NutritionScore]

    private struct Storyboard {
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
        static let ShowSettingsSegueIdentifier = "Show Settings"
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return products.fetchResultList.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let validProductFetchResult = products.fetchResultList[section] {
            switch validProductFetchResult {
            case .Success:
                return products.fetchResultList[section] != nil ? tableStructure.count : 1
            default:
                break
            }
        }
        // no rows as the loading failed, the error message is in the header
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.row]
        if let fetchResult = products.fetchResultList[indexPath.section] {
            switch fetchResult {
            case .Success(let currentProduct):
                switch currentProductSection {
                case .Name:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NameCellIdentifier, forIndexPath: indexPath) as! NameTableViewCell
                    
                    cell.productBrand = currentProduct.brandsArray
                    
                    // TBD I do not think the logic is right here
                    if let data = currentProduct.mainImageSmallData {
                        // try small image
                        cell.productImage = UIImage(data:data)
                        return cell
                    } else if currentProduct.mainUrl != nil {
                        // show small image icon
                        cell.productImage = nil
                        return cell
                    }
                    if let result = currentProduct.mainImageData {
                        switch result {
                        case .Success(let data):
                            cell.productImage = UIImage(data:data)
                        default:
                            cell.productImage = nil
                        }
                    } else {
                        cell.productImage = nil
                    }
                    return cell
                case .Ingredients:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IngredientsCellIdentifier, forIndexPath: indexPath) as! IngredientsTableViewCell
                    cell.product = currentProduct
                    return cell
                case .NutritionFacts:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactsCellIdentifier, forIndexPath: indexPath)
                    let formatter = NSNumberFormatter()
                    formatter.numberStyle = .DecimalStyle
                    let formattedCount = formatter.stringFromNumber(currentProduct.nutritionFacts.count)
                    
                    cell.textLabel!.text = String.localizedStringWithFormat(Constants.NumberOfNutritionalFactsText, formattedCount!)
                    return cell
                case .NutritionScore:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionScoreCellIdentifier, forIndexPath: indexPath) as? NutritionScoreTableViewCell
                    cell?.product = currentProduct
                    return cell!
                case .Categories:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CategoriesCellIdentifier, forIndexPath: indexPath) as? CategoriesTableViewCell
                    cell?.product = currentProduct
                    return cell!
                case .Completion:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CompletionCellIdentifier, forIndexPath: indexPath) as? CompletionTableViewCell
                    cell?.product = currentProduct
                    return cell!
                case .SupplyChain:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ProducerCellIdentifier, forIndexPath: indexPath) as? ProducerTableViewCell
                    cell?.product = currentProduct
                    return cell!
                }
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BeingLoadedCellIdentifier, forIndexPath: indexPath) as? BeingLoadedTableViewCell
                cell?.status = fetchResult
            }
            
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BeingLoadedCellIdentifier, forIndexPath: indexPath) as? BeingLoadedTableViewCell
        cell?.status = nil
        return cell!
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedIndex = indexPath.row
        if let validProductFetchResult = products.fetchResultList[indexPath.section] {
            switch validProductFetchResult {
            case .Success(let product):
                selectedProduct = product
            default: break
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRectMake(0, 0, tableView.frame.size.width, 25))
        let label = UILabel.init(frame: CGRectMake(10, 5, tableView.frame.size.width, 20))
        tempView.backgroundColor = UIColor.grayColor()
        label.font = UIFont.boldSystemFontOfSize(20)
        label.textColor = UIColor.whiteColor()
        if !products.fetchResultList.isEmpty {
            if let validProductFetchResult = products.fetchResultList[section] {
                switch validProductFetchResult {
                case .Success(let product):
                    label.text = product.name != nil ? product.name! : Constants.ProductNameMissing
                    if let validKeys = product.allergenKeys {
                        if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                            tempView.backgroundColor = UIColor.redColor()
                        }
                    } else {
                        if let validKeys = product.traceKeys {
                            if AllergenWarningDefaults.manager.hasValidWarning(validKeys) {
                                tempView.backgroundColor = UIColor.redColor()
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
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Scene changes
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ToPageViewControllerSegue:
                if let vc = segue.destinationViewController as? UINavigationController {
                    if let ppvc = vc.topViewController as? ProductPageViewController {
                        ppvc.product = selectedProduct
                        ppvc.pageIndex = selectedIndex
                    }
                }
            case Storyboard.ShowSettingsSegueIdentifier:
                if let vc = segue.destinationViewController as? SettingsTableViewController {
                    vc.storedHistory = products.storedHistory
                    // vc.modalPresentationCapturesStatusBarAppearance = true
                    // setNeedsStatusBarAppearanceUpdate()
                }

            default: break
            }
        }
    }

    @IBAction func unwindForCancel(segue:UIStoryboardSegue) {
        if let _ = segue.sourceViewController as? BarcodeScanViewController {
            if products.fetchResultList.count > 0 {
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func unwindNewSearch(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? BarcodeScanViewController {
            barcode = BarcodeType(typeCode:vc.type, value:vc.barcode)
            searchTextField.text = vc.barcode
            performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
        }
    }
    
    
    @IBAction func settingsDone(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? SettingsTableViewController {
            tableView.reloadData()
            if vc.historyHasBeenRemoved {
                products.removeAll()
                selectedProduct = nil
                performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
            }
            
        }
    }

    // MARK: - Notification methods
    
    func showAlertProductNotAvailable(notification: NSNotification) {
        let userInfo = notification.userInfo
        let error = userInfo!["error"] as? String?
        let alert = UIAlertController(
            title: Constants.AlertSheetMessage,
            message: error!, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: Constants.AlertSheetActionTitle, style: .Cancel) { (action: UIAlertAction) -> Void in // do nothing )
            }
        )
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func productLoaded(notification: NSNotification) {
        refreshInterface()
    }
    
    func productUpdated(notification: NSNotification) {
        refreshInterface()
    }
    
    func firstProductLoaded(notification: NSNotification) {
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
        Preferences.manager
        
        startInterface()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        title = Constants.ViewControllerTitle
        refreshInterface()

        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.showAlertProductNotAvailable(_:)), name:OFFProducts.Notification.ProductNotAvailable, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.productLoaded(_:)), name:OFFProducts.Notification.ProductLoaded, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:OFFProducts.Notification.FirstProductLoaded, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:OFFProducts.Notification.ProductUpdated, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:OFFProducts.Notification.ProductLoadingError, object:nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshInterface()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
}


