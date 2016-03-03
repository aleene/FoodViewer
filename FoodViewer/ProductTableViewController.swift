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
                for var index = 0; index < [products].count; ++index {
                    print("products \(products[index].barcode.asString()); update \(productToUpdate.barcode.asString())")
                    if products[index].barcode.asString() == productToUpdate.barcode.asString() {
                        indexExistingProduct = index
                    }
                }
                if indexExistingProduct == nil {
                    // new product not yet in products array
                    self.products.insert(productToUpdate, atIndex: 0)
                    self.products[0].barcode = self.barcode!
                } else {
                    // reset product information to the retrieved one
                    self.products[indexExistingProduct!] = productToUpdate
                }
            } else {
                // new product not yet in products array
                products.insert(productToUpdate, atIndex: 0)
            }
            // add product barcode to history
            self.storedHistory.addBarcode(barcode: productToUpdate.barcode.asString())
            tableView.reloadData()
            // launch image retrieval if needed
            if (productToUpdate.mainUrl != nil) {
                if (productToUpdate.mainImageData == nil) {
                // get image only if the data is not there yet
                    self.retrieveImage(productToUpdate.mainUrl!)
                }
            }
        }
    }

    private var storedHistory = History()

    // defines the order of the rows
    private var tableStructure: [RowType] = [.Name, .Ingredients, .NutritionFacts, .NutritionScore, .Categories, .Completion, .SupplyChain]
    
    private var selectedProduct: FoodProduct? = nil
    
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

    private struct Constants {
        static let ViewControllerTitle = "Products"
        static let OpenFoodFactsWebEditURL = "http://fr.openfoodfacts.org/cgi/product.pl?type=edit&code="
        static let AlertSheetMessage = "Error retrieving product"
        static let AlertSheetActionTitle = "Pity"
        static let NoProductsInHistory = "No products listed"
        static let ProductNameMissing = "No product name"
        static let NutritionalText = " nutritional facts noted"
    }
    
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // number of section depends on the existence of the data
        return products.count
    }
    
    private struct Storyboard {
        static let NameCellIdentifier = "Product Name Cell"
        static let IngredientsCellIdentifier = "Product Ingredients Cell"
        static let CountriesCellIdentifier = "Countries Cell"
        static let NutritionFactsCellIdentifier = "Product Nutrition Facts Name Cell"
        static let NutritionScoreCellIdentifier = "Product Nutrition Score Cell"
        static let CategoriesCellIdentifier = "Product Categories Cell"
        static let CompletionCellIdentifier = "Product Completion State Cell"
        static let ProducerCellIdentifier = "Product Producer Cell"
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
        
        let currentProductSection = tableStructure[indexPath.row]
        selectedProduct = products[indexPath.section]
        // we assume that product exists
        switch currentProductSection {
        case .Name:
            performSegueWithIdentifier(Segues.ShowIdentificationSegueIdentifier, sender: self)
        case .Ingredients:
            performSegueWithIdentifier(Segues.ShowIngredientsSegueIdentifier, sender: self)
        case .NutritionFacts:
            performSegueWithIdentifier(Segues.ShowNutritionFactsSegueIdentifier, sender: self)
        case .Categories:
            performSegueWithIdentifier(Segues.ShowCategoriesSegueIdentifier, sender: self)
        case .Completion:
            performSegueWithIdentifier(Segues.ShowCommunityEffortSegueIdentifier, sender: self)
        case .SupplyChain:
            performSegueWithIdentifier(Segues.ShowSupplyChainSegueIdentifier, sender: self)
        default:
            break
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
                                self.tableView.reloadData()
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

    // MARK: - Segues
    
    private struct Segues {
        static let ShowIdentificationSegueIdentifier = "Show Product Identification"
        static let ShowIngredientsSegueIdentifier = "Show Product Ingredients"
        static let ShowCommunityEffortSegueIdentifier = "Show Community Effort"
        static let ShowSupplyChainSegueIdentifier = "Show Supply Chain"
        static let ShowCategoriesSegueIdentifier = "Show Categories"
        static let ShowNutritionFactsSegueIdentifier = "Show Nutrition Facts"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            // note that the destinationViewController can be a NavigationViewController,
            // so we should look what is inside it
            destination = navCon.topViewController!
        }
        if let identifier = segue.identifier {
            if let currentProduct = selectedProduct {
                switch identifier {
                case Segues.ShowIdentificationSegueIdentifier:
                    if let vc = destination as? IdentificationTableViewController {
                        vc.product = currentProduct
                    }
                case Segues.ShowIngredientsSegueIdentifier:
                    if let vc = destination as? IngredientsTableViewController {
                        vc.product = currentProduct
                    }
                case Segues.ShowCommunityEffortSegueIdentifier:
                    if let vc = destination as? CompletionStatesTableViewController {
                        vc.product = currentProduct
                    }
                case Segues.ShowCategoriesSegueIdentifier:
                    if let vc = destination as? CategoriesTableViewController {
                        vc.product = currentProduct
                    }
                case Segues.ShowSupplyChainSegueIdentifier:
                    if let vc = destination as? ProductionTableViewController {
                        vc.product = currentProduct
                    }
                case Segues.ShowNutritionFactsSegueIdentifier:
                    if let vc = destination as? NutrientsTableViewController {
                        vc.product = currentProduct
                    }
                default: break
                }
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
        /*
        // start out with the first product if any
        if products.first != nil {
            selectedProduct = products.first
            // and show the identification detail pane
            performSegueWithIdentifier(Segues.ShowIdentificationSegueIdentifier, sender: self)
            tableView.reloadData()
        }
*/
        title = Constants.ViewControllerTitle
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // suggested by http://useyourloaf.com/blog/self-sizing-table-view-cells/
        if products.count > 0 {
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
}


