//
//  ProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController, UITextFieldDelegate {

    private var products: [FoodProduct] = []
    
    private func updateProduct(product: FoodProduct?) {
        if let productToUpdate = product {
            // should check if the product is not already available
            if !products.isEmpty {
                // look at all products
                var indexExistingProduct: Int? = nil
                for var index = 0; index < products.count; ++index {
                    print("products \(products[index].barcode.asString()); update \(productToUpdate.barcode.asString())")
                    if products[index].barcode.asString() == productToUpdate.barcode.asString() {
                        indexExistingProduct = index
                    }
                }
                if indexExistingProduct == nil {
                    // new product not yet in products array
                    print("ADD product \(productToUpdate.barcode.asString())")
                    self.products.insert(productToUpdate, atIndex: 0)
                    // self.products[0].barcode = self.barcode!
                } else {
                    print("UPDATE product \(productToUpdate.barcode.asString())")
                    // reset product information to the retrieved one
                    self.products[indexExistingProduct!] = productToUpdate
                }
            } else {
                print("FIRST product \(productToUpdate.barcode.asString())")

                // new product not yet in products array
                products.insert(productToUpdate, atIndex: 0)
            }
            // add product barcode to history
            self.storedHistory.addBarcode(barcode: productToUpdate.barcode.asString())
            // launch image retrieval if needed
            if (productToUpdate.mainUrl != nil) {
                if (productToUpdate.mainImageData == nil) {
                // get image only if the data is not there yet
                    self.retrieveImage(productToUpdate.mainUrl!)
                }
            }
            refreshInterface()
        }
    }

    private var storedHistory = History()

    // defines the order of the rows
    private var tableStructure: [RowType] = [.Name, .Ingredients, .NutritionFacts, .SupplyChain, .Categories, .Completion, .NutritionScore]
    
    private var selectedProduct: FoodProduct? = nil
    
    private var selectedIndex = 0
    
    private enum RowType {
        case Name
        case Ingredients
        case NutritionFacts
        case NutritionScore
        case Categories
        case Completion
        case SupplyChain
    }
    
    private var barcode: BarcodeType? = BarcodeType.EAN13("3608580744184") {
        didSet {
            // get the corresponding data from OFF
            refresh(barcode)
        }
    }
    
    
    private func refreshProduct(product: FoodProduct) {
        refresh(product.barcode)
    }
    
    private func refresh(barcode: BarcodeType?) {
        if barcode != nil {
            let request = OpenFoodFactsRequest()
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                let fetchResult = request.fetchProductForBarcode(barcode!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    switch fetchResult {
                    case .Success(let newProduct):
                        self.updateProduct(newProduct)
                        self.tableView.reloadData()
                    case .Error(let error):
                        let alert = UIAlertController(
                            title: Constants.AlertSheetMessage,
                            message: error, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: Constants.AlertSheetActionTitle, style: .Cancel) { (action: UIAlertAction) -> Void in // do nothing )
                            }
                        )
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            })
        }
    }

    private func refreshInterface() {
        if products.count > 0 {
            tableView.reloadData()
            selectedProduct = products.first
            selectedIndex = 0
            performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
        }
    }
    
    private func retrieveImage(url: NSURL?) {
        if let imageURL = url {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data
                            // as we are on another thread I should find the product to add it to
                            if !self.products.isEmpty {
                                // look at all products
                                var indexExistingProduct: Int? = nil
                                for var index = 0; index < self.products.count; ++index {
                                    if self.products[index].mainUrl == imageURL {
                                        indexExistingProduct = index
                                    }
                                }
                                if indexExistingProduct != nil {
                                    self.products[indexExistingProduct!].mainImageData = imageData
                                }
                                self.refreshInterface()
                            } // else bad luck corresponding product is no longer there
                        })
                    }
                }
                catch {
                    print(error)
                }
            })
        }
    }
    
    private struct Constants {
        static let ViewControllerTitle = "Products"
        static let OpenFoodFactsWebEditURL = "http://fr.openfoodfacts.org/cgi/product.pl?type=edit&code="
        static let AlertSheetMessage = "Error retrieving product"
        static let AlertSheetActionTitle = "Pity"
        static let NoProductsInHistory = "No products listed"
        static let ProductNameMissing = "No product name"
        static let NutritionalText = " nutritional facts noted"
    }
    
    var productPageViewController: ProductPageViewController? = nil
    
    // MARK: - Actions
    
    @IBAction func openSafari(sender: UIBarButtonItem) {
        
        if let barcode = selectedProduct?.barcode.asString() {
            let urlString = Constants.OpenFoodFactsWebEditURL + barcode
            if let requestUrl = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(requestUrl)
            }
        }
    }
    
    
    // MARK: - TextField

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            if let searchText = barcode?.asString() {
                searchTextField.text = searchText
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            if let searchText = textField.text {
                barcode = BarcodeType(value:searchText)
            }
        }
        return true
    }

    // MARK: - Table view data source
    
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
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // number of section depends on the existence of the data
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.row]
        let currentProduct = products[indexPath.section]
        
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
                cell.textLabel!.text = "\(currentProduct.nutritionFacts.count)" + Constants.NutritionalText
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
            selectedProduct = products[indexPath.section]
            performSegueWithIdentifier(Storyboard.ToPageViewControllerSegue, sender: self)
        }
    }
   
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if products.isEmpty {
            return Constants.NoProductsInHistory
        } else {
            return products[section].name != nil ? products[section].name : Constants.ProductNameMissing
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
                        ppvc.pageIndex = selectedIndex
                    }
                }
            default: break
            }
        }
    }

    @IBAction func unwindForCancel(segue:UIStoryboardSegue) {
        if let _ = segue.sourceViewController as? BarcodeScanViewController {
            if products.count > 0 {
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func unwindNewSearch(segue:UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? BarcodeScanViewController {
            // searchText = vc.barcode
            barcode = BarcodeType(typeCode:vc.type, value:vc.barcode)
            searchTextField.text = vc.barcode
        }
    }

    // MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // need to find out the detail controller of the splitview controller, which should be a navigationcontroller with a pageviewcontroller
        
        if let navigationMasterViewController = self.parentViewController as? UINavigationController {
            if let splitViewController = navigationMasterViewController.parentViewController as? UISplitViewController {
                if let unv = splitViewController.viewControllers[splitViewController.viewControllers.count - 1] as? UINavigationController {
                    if let ppvc = unv.topViewController as? ProductPageViewController {
                        productPageViewController = ppvc
                    }
                }
            }
        }


        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        
        if products.isEmpty {
        // check if there is history available
        // and init products with History
            for storedBarcode in storedHistory.barcodes {
                // this fills the database of products
                let newProduct = FoodProduct(withBarcode: BarcodeType(value: storedBarcode))
                refreshProduct((newProduct))
            }
        }


        title = Constants.ViewControllerTitle
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
}


