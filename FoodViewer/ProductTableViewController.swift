//
//  ProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController, UITextFieldDelegate {

    private var tableStructureForProduct: [(RowType, Int, String?)] = []
    
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
            product = nil
            tableStructureForProduct = []
            refresh()
        }
    }
    
    private var product: FoodProduct? {
        didSet {
            if product != nil {
                if let inputBarcode = barcode {
                    // update the json data in order to add the barcode type
                    product?.barcode = inputBarcode
                }
                tableStructureForProduct = analyseProductForTable(product!)
                if product?.mainUrl != nil {
                    retrieveImage(product!.mainUrl!)
                }
                performSegueWithIdentifier(Segues.ShowIdentificationSegueIdentifier, sender: self)
                // add product to history
            }
        }
    }
    
    private var mainProductImage: UIImage? = nil {
        didSet {
            if mainProductImage != nil {
                tableView.reloadData()
            }
        }
    }

    /*private var searchText: String? = "3608580744184" {
        didSet {
            product = nil
            tableStructureForProduct = []
            refresh()
        }
    }*/
    
    private var request = OpenFoodFactsRequest()
    
    private func refresh() {
        if barcode != nil {
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                let fetchResult =  self.request.fetchProductForBarcode(self.barcode!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    switch fetchResult {
                    case .Success(let newProduct):
                        self.product = newProduct
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
    }
    
    // MARK: - Actions
    
    @IBAction func openSafari(sender: UIBarButtonItem) {
        
        if let barcode = product?.barcode.asString() {
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
        return 1
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
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.row]
        
        // we assume that product exists
        switch currentProductSection {
        case .Name:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NameCellIdentifier, forIndexPath: indexPath) as! NameTableViewCell
            // cell.productName = product!.name
            cell.productBrand = product!.brandsArray
            cell.productImage = mainProductImage
            return cell
        case .Ingredients:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IngredientsCellIdentifier, forIndexPath: indexPath) as! IngredientsTableViewCell
            cell.product = product!
            return cell
        case .NutritionFacts:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactsCellIdentifier, forIndexPath: indexPath)
                cell.textLabel!.text = "\(product!.nutritionFacts.count) nutritional facts noted"
                return cell
        case .NutritionScore:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionScoreCellIdentifier, forIndexPath: indexPath) as? NutritionScoreTableViewCell
            cell?.product = product!
            return cell!
        case .Categories:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CategoriesCellIdentifier, forIndexPath: indexPath) as? CategoriesTableViewCell
            cell?.product = product!
            return cell!
        case .Completion:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CompletionCellIdentifier, forIndexPath: indexPath) as? CompletionTableViewCell
            cell?.product = product!
            return cell!
        case .SupplyChain:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ProducerCellIdentifier, forIndexPath: indexPath) as? ProducerTableViewCell
            cell?.product = product!
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructureForProduct.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.row]
        
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
        if tableStructureForProduct.isEmpty {
            return "No products listed"
        } else {
            let (_, _, header) = tableStructureForProduct[0]
            // print("section: \(section) with header \(header)")
            return header
        }
    }
     /*
    //
    // Thanks to http://www.elicere.com/mobile/swift-blog-2-uitableview-section-header-color/
    //
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView

        let (sectionType, _, _) = tableStructureForProduct[section]
        
        switch sectionType {
        case .NutritionScore:
            if let score = product?.nutritionGrade {
                switch  score {
                case .A:
                    header.contentView.backgroundColor = UIColor.greenColor()
                case .B:
                    header.contentView.backgroundColor = UIColor.yellowColor()
                case .C:
                    header.contentView.backgroundColor = UIColor.orangeColor()
                case .D:
                    header.contentView.backgroundColor = UIColor.magentaColor()
                case .E:
                    header.contentView.backgroundColor = UIColor.redColor()
                default:
                    header.contentView.backgroundColor = nil
                }
            }
        default:
            header.contentView.backgroundColor = nil
        }
    }
     */
    // http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    struct TableStructure {
        static let NameSectionSize = 1
        static let IngredientsSectionSize = 1
        static let CountriesSectionSize = 1
        static let NutritionScoreSectionSize = 1
        static let NutritionFactsSectionSize = 1
        static let CategoriesSectionSize = 1
        static let TracesSectionSize = 1
        static let CommunitySectionSize = 1
        static let CompletionSectionSize = 1
        static let SupplyChainSectionSize = 1
        static let NameSectionHeader = ""
        static let IngredientsSectionHeader = "Ingredients"
        static let CountriesSectionHeader = "Sales info"
        static let TracesSectionHeader = "Traces"
        static let NutritionScoreSectionHeader = "Nutritional score"
        static let NutritionFactsSectionHeader = "Nutrition Facts (100g; 100ml)"
        static let CategoriesSectionHeader = "Categories"
        static let CommunitySectionHeader = "Community Involvement"
        static let CompletionSectionHeader = "Completion State"
        static let SupplyChainSectionHeader = "Producer"
    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(RowType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections 
        // And each element is a tuple with the section type and number of rows
        // 
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(RowType,Int, String?)] = []
        
        // 1: name section always exists
        if let productName = product.name {
            sectionsAndRows.append((RowType.Name, TableStructure.NameSectionSize, productName))
        } else {
            sectionsAndRows.append((RowType.Name, TableStructure.NameSectionSize, nil))
        }
        
        // 2:  ingredients section
        if product.ingredients != nil {
            sectionsAndRows.append((
                RowType.Ingredients,
                TableStructure.IngredientsSectionSize,
                TableStructure.IngredientsSectionHeader))
        }
        
        // 3: nutritionFacts section
        if product.nutritionFacts.count > 0 {
            sectionsAndRows.append((
                RowType.NutritionFacts,
                TableStructure.NutritionFactsSectionSize,
                TableStructure.NutritionFactsSectionHeader))
        }
        
        // 4: nutritionScore section
        if product.nutritionScore != nil {
            sectionsAndRows.append((
                RowType.NutritionScore,
                TableStructure.NutritionScoreSectionSize,
                TableStructure.NutritionScoreSectionHeader))
        }
        
        // 5: categories section
        if product.categories != nil {
            sectionsAndRows.append((
                RowType.Categories,
                TableStructure.CategoriesSectionSize,
                TableStructure.CategoriesSectionHeader))
        }
        
        /* 6: purchase location section
            sectionsAndRows.append((
                RowType.Countries,
                TableStructure.CountriesSectionSize,
                TableStructure.CountriesSectionHeader))
        */
        // 7: producer section
        sectionsAndRows.append((
            RowType.SupplyChain,
            TableStructure.SupplyChainSectionSize,
            TableStructure.SupplyChainSectionHeader))
        
        // 8: completion status section
        sectionsAndRows.append((
            RowType.Completion,
            TableStructure.CompletionSectionSize,
            TableStructure.CompletionSectionHeader))

        // print("\(sectionsAndRows)")
        return sectionsAndRows
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
                            // set the received image
                            self.mainProductImage = UIImage(data: imageData)
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
            switch identifier {
            case Segues.ShowIdentificationSegueIdentifier:
                if let vc = destination as? IdentificationTableViewController {
                    vc.product = product
                }
            case Segues.ShowIngredientsSegueIdentifier:
                if let vc = destination as? IngredientsTableViewController {
                    vc.product = product
                }
            case Segues.ShowCommunityEffortSegueIdentifier:
                if let vc = destination as? CompletionStatesTableViewController {
                    vc.product = product
                }
            case Segues.ShowCategoriesSegueIdentifier:
                if let vc = destination as? CategoriesTableViewController {
                    vc.product = product
                }
            case Segues.ShowSupplyChainSegueIdentifier:
                if let vc = destination as? ProductionTableViewController {
                    vc.product = product
                }
            case Segues.ShowNutritionFactsSegueIdentifier:
                if let vc = destination as? NutrientsTableViewController {
                    vc.product = product
                }
            default: break
            }
        }
    }
    
    @IBAction func unwindForCancel(segue:UIStoryboardSegue) {
        if let _ = segue.sourceViewController as? BarcodeScanViewController {
            if product != nil {
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
        self.tableView.estimatedRowHeight = 300.0
        if product != nil {
            tableView.reloadData()
        }
        title = Constants.ViewControllerTitle
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // suggested by http://useyourloaf.com/blog/self-sizing-table-view-cells/
        if product != nil {
            tableView.reloadData()
        }
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
}


