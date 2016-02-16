//
//  ProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController, UITextFieldDelegate {

    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private enum SectionType {
        case Name
        case Ingredients
        case Traces
        case Countries
        case NutritionFacts
        case NutritionScore
        case Categories
        case Community
        case Completion
        case Producer
    }
    
    private var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
            }
        }
    }
    
    private var searchText: String? = "3608580744184" {
        didSet {
            product = nil
            tableStructureForProduct = []
            refresh()
        }
    }
    
    private var request = OpenFoodFactsRequest()
    
    private func refresh() {
        if searchText != nil {
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                let newProduct =  self.request.fetchProductForBarcode(self.searchText!)
                if newProduct != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.product = newProduct
                        self.tableView.reloadData()
                    })
                }
            })
        }
    }

    // MARK: - TextField

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // number of section depends on the existence of the data
        return tableStructureForProduct.count
    }
    
    private struct Storyboard {
        static let NameCellIdentifier = "Product Name Cell"
        static let IngredientsCellIdentifier = "Product Ingredients Cell"
        static let CountriesCellIdentifier = "Countries Cell"
        static let NutritionFactsCellIdentifier = "Product Nutrition Facts Name Cell"
        static let NutritionScoreCellIdentifier = "Product Nutrition Score Cell"
        static let CategoriesCellIdentifier = "Product Categories Cell"
        static let TracesCellIdentifier = "Product Traces Cell"
        static let CommunityCellIdentifier = "Product Community Cell"
        static let CompletionCellIdentifier = "Product Completion State Cell"
        static let ProducerCellIdentifier = "Product Producer Cell"
        static let ShowIdentificationSegueIdentifier = "Show Product Identification"
        static let ShowIngredientsSegueIdentifier = "Show Product Ingredients"
        static let ShowCompletionStatesSegueIdentifier = "Show Completion States"
        static let ShowContributorsSegueIdentifier = "Show Contributors"
        static let ShowPurchaseLocationSegueIdentifier = "Show Purchase Location"
        static let ShowProductionSegueIdentifier = "Show Production"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.section]
        
        // we assume that product exists
        switch currentProductSection {
        case .Name:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NameCellIdentifier, forIndexPath: indexPath) as! NameTableViewCell
            cell.product = product!
            return cell
        case .Ingredients:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IngredientsCellIdentifier, forIndexPath: indexPath) as! IngredientsTableViewCell
            cell.product = product!
            return cell
        case .Countries:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CountriesCellIdentifier, forIndexPath: indexPath) as? CountriesTableViewCell
            cell?.product = product!
            return cell!
        case .NutritionFacts:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactsCellIdentifier, forIndexPath: indexPath) as? NutritionFactsTableViewCell
                cell?.product = indexPath.row == 0 ? product! : nil
                cell?.nutritionFactItem = product!.nutritionFacts[indexPath.row]
                return cell!
        case .NutritionScore:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionScoreCellIdentifier, forIndexPath: indexPath) as? NutritionScoreTableViewCell
            cell?.product = product!
            return cell!
        case .Categories:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CategoriesCellIdentifier, forIndexPath: indexPath) as? CategoriesTableViewCell
            cell?.product = product!
            return cell!
        case .Traces:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TracesCellIdentifier, forIndexPath: indexPath) as? TracesTableViewCell
            cell?.product = product!
            return cell!
        case .Community:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CommunityCellIdentifier, forIndexPath: indexPath) as? CommunityTableViewCell
            cell?.product = product!
            return cell!
        case .Completion:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CompletionCellIdentifier, forIndexPath: indexPath) as? CompletionTableViewCell
            cell?.product = product!
            return cell!
        case .Producer:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ProducerCellIdentifier, forIndexPath: indexPath) as? ProducerTableViewCell
            cell?.tagList = product!.producerCode!
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
        
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var (sectionType, _, header) = tableStructureForProduct[section]
        switch sectionType {
        case .NutritionScore:
            if let score = product?.nutritionGrade {
                switch  score {
                case .A:
                    header = header != nil ? header! + "  A" : header
                case .B:
                    header = header != nil ? header! + "  B" : header
                case .C:
                    header = header != nil ? header! + "  C" : header
                case .D:
                    header = header != nil ? header! + "  D" : header
                case .E:
                    header = header != nil ? header! + "  E" : header
                default:
                    break
                }
            }
        default: break
        }
        return header
    }
    
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
    
    
    struct TableStructure {
        static let NameSectionSize = 1
        static let IngredientsSectionSize = 1
        static let CountriesSectionSize = 1
        static let NutritionScoreSectionSize = 1
        static let CategoriesSectionSize = 1
        static let TracesSectionSize = 1
        static let CommunitySectionSize = 1
        static let CompletionSectionSize = 1
        static let ProducerSectionSize = 1
        static let NameSectionHeader = ""
        static let IngredientsSectionHeader = "Ingredients"
        static let CountriesSectionHeader = "Countries"
        static let TracesSectionHeader = "Traces"
        static let NutritionScoreSectionHeader = "Nutritional score"
        static let NutritionFactsSectionHeader = "Nutrition Facts (100g)"
        static let CategoriesSectionHeader = "Categories"
        static let CommunitySectionHeader = "Community Involvement"
        static let CompletionSectionHeader = "Completion State"
        static let ProducerSectionHeader = "Producer Code"
    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections 
        // And each element is a tuple with the section type and number of rows
        // 
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 1: name section always exists
        sectionsAndRows.append((SectionType.Name, TableStructure.NameSectionSize, nil))
        
        // 2:  ingredients section
        if product.ingredients != nil {
            sectionsAndRows.append((
                SectionType.Ingredients,
                TableStructure.IngredientsSectionSize,
                TableStructure.IngredientsSectionHeader))
        }
        
        // 3: nutritionFacts section
        if product.nutritionFacts.count > 0 {
            sectionsAndRows.append((
                SectionType.NutritionFacts,
                product.nutritionFacts.count,
                TableStructure.NutritionFactsSectionHeader))
        }
        
        // 4: nutritionScore section
        if product.nutritionScore != nil {
            sectionsAndRows.append((
                SectionType.NutritionScore,
                TableStructure.NutritionScoreSectionSize,
                TableStructure.NutritionScoreSectionHeader))
        }
        
        // 5: categories section
        if product.categories != nil {
            sectionsAndRows.append((
                SectionType.Categories,
                TableStructure.CategoriesSectionSize,
                TableStructure.CategoriesSectionHeader))
        }
        
        // 6: allergens section
        if product.countries != nil {
            sectionsAndRows.append((
                SectionType.Countries,
                TableStructure.CountriesSectionSize,
                TableStructure.CountriesSectionHeader))
        }

        // 7: traces section
        if product.traces != nil {
            sectionsAndRows.append((
                SectionType.Traces,
                TableStructure.TracesSectionSize,
                TableStructure.TracesSectionHeader))
        }
        
        // 8: producer section
        if product.producerCode != nil {
            sectionsAndRows.append((
                SectionType.Producer,
                TableStructure.ProducerSectionSize,
                TableStructure.ProducerSectionHeader))
        }

        // 9: community section
        if product.uniqueContributors.count > 0 {
            sectionsAndRows.append((
                SectionType.Community,
                TableStructure.CommunitySectionSize,
                TableStructure.CommunitySectionHeader))
        }
        
        // 10: completion status section
        sectionsAndRows.append((
            SectionType.Completion,
            TableStructure.CompletionSectionSize,
            TableStructure.CompletionSectionHeader))

        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowIdentificationSegueIdentifier:
                if let vc = segue.destinationViewController as? IdentificationViewController {
                    vc.product = product
                }
            case Storyboard.ShowIngredientsSegueIdentifier:
                if let vc = segue.destinationViewController as? IngredientsViewController {
                    vc.product = product
                }
            case Storyboard.ShowCompletionStatesSegueIdentifier:
                if let vc = segue.destinationViewController as? CompletionStatesTableViewController {
                    vc.product = product
                }
            case Storyboard.ShowContributorsSegueIdentifier:
                if let vc = segue.destinationViewController as? ContributorsTableViewController {
                    vc.product = product
                }
            case Storyboard.ShowPurchaseLocationSegueIdentifier:
                if let vc = segue.destinationViewController as? PurchaseLocationTableViewController {
                    vc.product = product
                }
            case Storyboard.ShowProductionSegueIdentifier:
                if let vc = segue.destinationViewController as? ProductionTableViewController {
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
            searchText = vc.barcode
            searchTextField.text = vc.barcode
        }
    }

    // MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 108.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
        title = "Summary"
    }
}






