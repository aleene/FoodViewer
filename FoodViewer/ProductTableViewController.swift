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
        case Allergens
        case NutritionFacts
        case NutritionScore
        case Categories
    }
    
    private var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                tableView.reloadData()
            }
        }
    }
    
    var searchText: String? = "3178530402674" {
        didSet {
            product = nil
            refresh()
        }
    }
    
    private var request = OpenFoodFactsRequest()
    
    private func refresh() {
        if searchText != nil {
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                self.product =  self.request.fetchProductForBarcode(self.searchText!)
                if self.product != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            })
        }
    }

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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // number of section depends on the existence of the data
        return tableStructureForProduct.count
    }
    
    private struct Storyboard {
        static let NameCellIdentifier = "Product Name Cell"
        static let IngredientsCellIdentifier = "Product Ingredients Cell"
        static let AllergensCellIdentifier = "Product Allergens Cell"
        static let NutritionFactsCellIdentifier = "Product Nutrition Facts Name Cell"
        static let NutritionScoreCellIdentifier = "Product Nutrition Score Cell"
        static let CategoriesCellIdentifier = "Product Categories Cell"
        static let TracesCellIdentifier = "Product Traces Cell"
        static let ShowIdentificationSegueIdentifier = "Show Product Identification"
        static let ShowIngredientsSegueIdentifier = "Show Product Ingredients"

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
        case .Allergens:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.AllergensCellIdentifier, forIndexPath: indexPath) as? AllergensTableViewCell
            cell?.product = product!
            return cell!
        case .NutritionFacts:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactsCellIdentifier, forIndexPath: indexPath) as? NutritionFactsTableViewCell
                cell?.product = indexPath.row == 0 ? product! : nil
                cell?.nutritionFactItem = product!.nutritionFacts?[indexPath.row]
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
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
    
    /*
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    */
    
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
                    break
                }
            }
        default:
            header.contentView.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    
    struct TableStructure {
        static let NameSectionSize = 1
        static let IngredientsSectionSize = 1
        static let AllergensSectionSize = 1
        static let NutritionScoreSectionSize = 1
        static let CategoriesSectionSize = 1
        static let TracesSectionSize = 1
        static let NameSectionHeader = ""
        static let IngredientsSectionHeader = "Ingredients"
        static let AllergensSectionHeader = "Allergens"
        static let TracesSectionHeader = "Traces"
        static let NutritionScoreSectionHeader = "Nutritional score"
        static let NutritionFactsSectionHeader = "Nutrition Facts (100g)"
        static let CategoriesSectionHeader = "Categories"
    }
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections 
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        // identification section always exists
        sectionsAndRows.append((SectionType.Name, TableStructure.NameSectionSize, nil))
        // ingredients section
        if product.ingredients != nil {
            sectionsAndRows.append((
                SectionType.Ingredients,
                TableStructure.IngredientsSectionSize,
                TableStructure.IngredientsSectionHeader))
        }
        // allergens section
        if product.allergens != nil {
            sectionsAndRows.append((
                SectionType.Allergens,
                TableStructure.AllergensSectionSize,
                TableStructure.AllergensSectionHeader))
        }
        // nutritionFacts section
        if product.nutritionFacts != nil {
            sectionsAndRows.append((
                SectionType.NutritionFacts,
                product.nutritionFacts!.count,
                TableStructure.NutritionFactsSectionHeader))
        }
        // nutritionScore section
        if product.nutritionScore != nil {
            sectionsAndRows.append((
                SectionType.NutritionScore,
                TableStructure.NutritionScoreSectionSize,
                TableStructure.NutritionScoreSectionHeader))
        }
        // categories section
        if product.categories != nil {
            sectionsAndRows.append((
                SectionType.Categories,
                TableStructure.CategoriesSectionSize,
                TableStructure.CategoriesSectionHeader))
        }
        // traces section
        if product.traces != nil {
            sectionsAndRows.append((
                SectionType.Traces,
                TableStructure.TracesSectionSize,
                TableStructure.TracesSectionHeader))
        }
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }
    
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

            default: break
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 108.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        title = "Product"
    }
}








