 //
//  ProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController, UITextFieldDelegate, KeyboardDelegate {

    private struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Products", comment: "Title of ViewController with a list of all products that has been viewed.")
        static let AlertSheetMessage = NSLocalizedString("Error retrieving product", comment: "Alert message, when the product could not be retrieved from Internet.")
        static let AlertSheetActionTitle = NSLocalizedString("Pity", comment: "Alert title, to indicate retrieving product did not work")
        static let NoProductsInHistory = NSLocalizedString("No products listed", comment: "Text to indicate that the history of products is empty.")
        static let ProductNameMissing = NSLocalizedString("No product name", comment: "Text in header of section, indicating that the product name is missing.")
        static let NumberOfNutritionalFactsText = NSLocalizedString("%@ nutritional facts specified", comment: "Cell text for the total number of nutritional facts available.")
    }
    

    private var product: ProductsArray? = nil
    
    private var barcode: BarcodeType? = nil {
        didSet {
            product!.fetchProduct(barcode)
        }
    }
    
    private func refreshInterface() {
        if product!.list.count > 0 {
            selectedProduct = product!.list.first
            tableView.reloadData()
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        }
    }
    
    var productPageViewController: ProductPageViewController? = nil
    
    // MARK: - Actions
 
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
            if let _ = parentVC.visibleViewController as? ProductTableViewController {
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
        static let ToPageViewControllerSegue = "Show Page Controller"
        static let ShowSettingsSegueIdentifier = "Show Settings"
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //
        return product != nil ? product!.list.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.row]
        let currentProduct = product!.list[indexPath.section]
        
        // we assume that product exists
        switch currentProductSection {
        case .Name:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NameCellIdentifier, forIndexPath: indexPath) as! NameTableViewCell
            cell.productBrand = currentProduct.brandsArray
            if currentProduct.mainImageData?.length > 0 {
                cell.productImage = UIImage(data:currentProduct.mainImageData!)
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
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row < 6 {
            // row 6 is the nutritional score, which has no correponding page
            selectedIndex = indexPath.row
            selectedProduct = product!.list[indexPath.section]
            // performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
        }
    }
   
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if product!.list.isEmpty {
            return Constants.NoProductsInHistory
        } else {
            return product!.list[section].name != nil ? product!.list[section].name : Constants.ProductNameMissing
        }
    }

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
                        ppvc.showSaltOrSodium = showSaltOrSodium
                        if let index = selectedIndex {
                            ppvc.pageIndex = index
                        }
                    }
                }
            case Storyboard.ShowSettingsSegueIdentifier:
                if let vc = segue.destinationViewController as? SettingsTableViewController {
                        vc.storedHistory = product!.storedHistory
                }

            default: break
            }
        }
    }

    @IBAction func unwindForCancel(segue:UIStoryboardSegue) {
        if let _ = segue.sourceViewController as? BarcodeScanViewController {
            if product!.list.count > 0 {
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func unwindNewSearch(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? BarcodeScanViewController {
            barcode = BarcodeType(typeCode:vc.type, value:vc.barcode)
            searchTextField.text = vc.barcode
        }
    }
    
    private var showSaltOrSodium: NatriumChloride = .Salt
    
    @IBAction func settingsDone(segue:UIStoryboardSegue) {
        if let settingsVC = segue.sourceViewController as? SettingsTableViewController {
            product!.storedHistory = History()
            product!.list = []
            showSaltOrSodium = settingsVC.showSaltOrSodium
        }
    }

    // MARK: - Notification methods
    
    func showAlertProducNotAvailable(notification: NSNotification) {
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
        tableView.reloadData()
    }

    func firstProductLoaded(notification: NSNotification) {
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)

    }

    // MARK: - Viewcontroller lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.showAlertProducNotAvailable(_:)), name:ProductsArray.Notification.ProductNotAvailable, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.productLoaded(_:)), name:ProductsArray.Notification.ProductLoaded, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:ProductsArray.Notification.FirstProductLoaded, object:nil)

        
        initializeCustomKeyboard()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        title = Constants.ViewControllerTitle
        
        // setup the products if not already done
        product = ProductsArray()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }
}


