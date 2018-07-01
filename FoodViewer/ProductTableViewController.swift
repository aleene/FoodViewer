//
//  ProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class ProductTableViewController: UITableViewController, UITextFieldDelegate, KeyboardDelegate {

    fileprivate struct Constants {

        struct AlertSheet {
            static let Message = TranslatableStrings.ProductDoesNotExistAlertSheetMessage
            static let ActionTitleForCancel = TranslatableStrings.ProductDoesNotExistAlertSheetActionTitleForCancel
            static let ActionTitleForAdd = TranslatableStrings.ProductDoesNotExistAlertSheetActionTitleForAdd
        }
        
        struct Tag {
            static let NoProductsInHistory = TranslatableStrings.NoProductsListed
            static let ProductNameMissing = TranslatableStrings.ProductNameMissing
        }
        
        // The tag-value of a cell is used to codify the type of cell
        // The product index is given by the ProductMultiplier, i.e. section * multipier
        // The product loading status (ProductFetchStatus.rawValue) is the remainer if < Offset.Image
        // image-loading status (ImageFetchResult) is the remainer if > Offset.Image < Offset.SearchQuery
        // searchQuery (add Offset.SearchQuery) is the remainer if > Offset.SearchQuery
        //
        //
        
        struct TagValue {
            static let Image = 10
            struct Search {
                static let NotDefined = 100
                static let Loading = 101
                static let MoreResults = 102
                static let List = 103
                static let Query = 104
            }
            struct Product {
                // if there is a list of products, their tag values start at 1000
                static let Multiplier = 1000
                // no list of products yet, so the status of the query is encoded as:
                static let Initialized = 0
                static let NotLoaded = 1
                static let Loading = 2
                static let Success = 3
                static let Available = 4
                static let Updating = 5
                static let NotAvailable = 6
                static let LoadingFailed = 7
            }
        }
    }
    
    private func tagValue(for status: ProductFetchStatus) -> Int {
        switch status {
        case .productNotLoaded: return Constants.TagValue.Product.NotLoaded
        case .loading: return Constants.TagValue.Product.Loading
        case .success: return Constants.TagValue.Product.Success
        case .available: return Constants.TagValue.Product.Available
        case .updating: return Constants.TagValue.Product.Updating
        case .productNotAvailable: return Constants.TagValue.Product.NotAvailable
        case .loadingFailed: return Constants.TagValue.Product.LoadingFailed
            
        case .noSearchDefined: return Constants.TagValue.Search.NotDefined
        case .searchLoading: return Constants.TagValue.Search.Loading
        case .searchQuery: return Constants.TagValue.Search.Query
        case .searchList: return Constants.TagValue.Search.List
        case .more: return Constants.TagValue.Search.MoreResults
        default: return Constants.TagValue.Product.Initialized
        }
    }
    

    fileprivate var products = OFFProducts.manager
    
    //TODO: can I create a barcode type for not initialized?
    fileprivate var barcodeType = BarcodeType(barcodeString: TranslatableStrings.EnterBarcode, type: Preferences.manager.showProductType) {
        didSet {
            var section = 0
            // get the index of the existing productPair
            if let validSection = products.indexOfProduct(with: barcodeType) {
                section = validSection
           } else {
                // create a new productPair
                let validSection = products.createProduct(with: barcodeType)
                section = validSection
                // do a reload as the  number of products has changed
                tableView.reloadData()
            }
            // set the selectedProductPair
            selectedProductPair = products.productPair(at: section)
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: section), at: .middle, animated: true)
        }
    }
    
    fileprivate func startInterface(at index:Int) {
        if let validProductPair = products.productPair(at: index),
            let validFetchResult = products.productPair(at: index)?.status {
                switch validFetchResult {
                case .available:
                    selectedProductPair = validProductPair
                    tableView.reloadData()
                case .searchQuery:
                    selectedProductPair = validProductPair
                    refreshInterface()
                default:
                    selectedProductPair = nil
                    tableView.reloadData()
                }
         } else {
            selectedProductPair = nil
            tableView.reloadData()
        }
        setTitle()
    }
    
    fileprivate func refreshInterface() {
        guard products.count > 0 else { return }
        tableView.reloadData()
    }

    var productPageViewController: ProductPageViewController? = nil
    
    // Function to set the title of this viewController
    // It is important to set the title at the right moment in the lifecycle
    // Just after reloading the data seems to be the best moment.
    
    fileprivate func setTitle() {
        if tabBarController!.selectedIndex == 0 {
            switch currentProductType {
            case .food:
                title = TranslatableStrings.FoodProducts
            case .petFood:
                title = TranslatableStrings.PetFoodProducts
            case .beauty:
                title = TranslatableStrings.BeautyProducts
            }
        } else {
            switch currentProductType {
            case .food:
                title = TranslatableStrings.SearchFoodProducts
            case .petFood:
                title = TranslatableStrings.SearchPetFoodProducts
            case .beauty:
                title = TranslatableStrings.SearchBeautyProducts
            }
        }
        guard title != nil else { return }
        
    }
    
    // MARK: - TextField Methods
    
    var activeTextField = UITextField()
 
 
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = barcodeType.asString
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
            barcodeType = BarcodeType(barcodeString: searchTextField.text!, type: currentProductType)
        }
    }

    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    // MARK: - Table view methods and vars
    
    fileprivate var selectedProductPair: ProductPair? = nil {
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
                //print("perform", testVC?.view?.frame, testVC?.parent)
                performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
            }
        }
    }

    // The row types are mapped onto custom cells
    fileprivate enum RowType {
        case name
        case image
        case ingredientsAllergensTraces
        case ingredients
        case nutritionFacts
        case nutritionScore
        case categories
        case completion
        case supplyChain
        
        // map the row types to corresponding product sections
        func productSection() -> ProductSection {
            switch self {
            case .name:
                return .identification
            case .image:
                return .gallery
            case .ingredientsAllergensTraces, .ingredients:
                return .ingredients
            case .nutritionFacts:
                return .nutritionFacts
            case .nutritionScore:
                return .nutritionScore
            case .categories:
                return .categories
            case .completion:
                return .completion
            case .supplyChain:
                return .supplyChain
            }
        }
    }

    // defines the order of the rows
    private var tableStructure: [RowType] {
        switch currentProductType {
        case .food:
            return [.name, .image, .nutritionScore, .ingredientsAllergensTraces, .nutritionFacts, .supplyChain, .categories, .completion]
        case .petFood:
            return [.name, .image, .ingredients, .nutritionFacts, .supplyChain, .categories, .completion]
        case .beauty:
            return [.name, .image, .ingredients, .supplyChain, .categories, .completion ]
        }
    }
    
    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let Name = "Product Name Cell"
            static let Image = "Images Page Cell"
            static let Ingredients = "Product Ingredients Cell"
            static let IngredientsPage = "Ingredients Page Cell"
            // static let Traces = "Product Traces Cell"
            // static let Allergens = "Product Allergens Cell"
            static let Countries = "Countries Cell"
            static let NutritionFacts = "Product Nutrition Facts Name Cell"
            static let NutritionScore = "Product Nutrition Score Cell"
            static let Categories = "Product Categories Cell"
            static let Completion = "Product Completion State Cell"
            static let Producer = "Product Producer Cell"
            static let TagListView = "Product TagListView Cell"
            static let TagListViewWithLabel = "TagListView With Label Cell Identifier"
            static let Button = "Products More Button Cell"
        }
        struct SegueIdentifier {
            static let ToPageViewController = "Show Page Controller"
            static let ShowSettings = "Show Settings Segue"
            static let ShowSortOrder = "Set Sort Order Segue Identifier"
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let count = products.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let validFetchResult = products.productPair(at: section)?.status {
            switch validFetchResult {
            case .available:
                return tableStructure.count
            case .searchQuery:
                if section == 0 {
                    switch validFetchResult {
                    case .searchQuery(let query):
                        if !query.isEmpty {
                            return query.searchPairsWithArray().count }
                        else {
                            return 1
                        }
                    default:
                        break
                    }
                }
                return tableStructure.count
            default:
                return 1
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let validFetchResult = products.productPair(at: indexPath.section)?.status {
            switch validFetchResult {
            case .available:
                products.loadProductPair(at: indexPath.section) //make sure the next set is loaded
                let productPair = products.productPair(at: indexPath.section)
                let currentProductSection = tableStructure[indexPath.row]
                switch currentProductSection {
                case .name:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Name, for: indexPath) as! NameTableViewCell
                    //print(productPair?.remoteProduct?.brandsOriginal, productPair?.localProduct?.brandsOriginal)
                    if let validBrands = productPair?.remoteProduct?.brandsOriginal ?? productPair?.localProduct?.brandsOriginal {
                        switch validBrands {
                        case .undefined, .empty:
                            cell.productBrand = [validBrands.description()]
                        case let .available(list):
                            cell.productBrand = list
                        case .notSearchable:
                            assert(true, "ProductTableViewController Error: How can I set a brand a tag when the field is non-editable")
                        }
                    }
                    return cell
                        
                case .image:
                    if let language = productPair?.primaryLanguageCode,
                        let frontImages = productPair?.remoteProduct?.frontImages ?? productPair?.localProduct?.frontImages,
                        !frontImages.isEmpty,
                        let result = frontImages[language]?.small?.fetch() {
                        switch result {
                        case .success(let image):
                            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ImagesPageTableViewCell
                            cell.productImage = image
                            return cell
                        default:
                            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                            cell.datasource = self
                            cell.tag = Constants.TagValue.Image + result.rawValue
                            cell.width = tableView.frame.size.width
                            cell.scheme = ColorSchemes.error
                            cell.accessoryType = .disclosureIndicator
                            return cell

                        }
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                    cell.datasource = self
                    cell.tag = Constants.TagValue.Image + ImageFetchResult.noImageAvailable.rawValue
                    //cell.width = tableView.frame.size.width
                    cell.scheme = ColorSchemes.error
                    cell.accessoryType = .disclosureIndicator
                    return cell
                
                case .ingredientsAllergensTraces:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.IngredientsPage, for: indexPath) as! IngredientsPageTableViewCell
                        
                    cell.ingredientsText = TranslatableStrings.Ingredients
                    if let number = productPair?.remoteProduct?.numberOfIngredients {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        cell.ingredientsBadgeText = "\(number)"
                    } else {
                        cell.ingredientsBadgeText = TranslatableStrings.Undefined
                    }
                        
                    cell.allergensText = TranslatableStrings.Allergens
                    if let validAllergens = productPair?.remoteProduct?.allergensTranslated ?? productPair?.localProduct?.allergensOriginal {
                        switch validAllergens {
                        case .available(let allergens):
                            cell.allergensBadgeText = "\(allergens.count)"
                        default:
                            cell.allergensBadgeText = TranslatableStrings.Undefined
                        }
                    }
                        
                    cell.tracesText = TranslatableStrings.Traces
                    if let validTraces = productPair?.remoteProduct?.tracesInterpreted ?? productPair?.localProduct?.tracesOriginal {
                        switch validTraces {
                        case .available(let traces):
                            cell.tracesBadgeText = "\(traces.count)"
                        default:
                            cell.tracesBadgeText = TranslatableStrings.Undefined
                        }
                    }
                    return cell
                        
                case .ingredients:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
                    cell.labelText = TranslatableStrings.Ingredients
                    if let number = productPair?.remoteProduct?.numberOfIngredients ?? productPair?.localProduct?.numberOfIngredients {
                        cell.badgeText = number
                    }
                    return cell
                        
                case .nutritionFacts:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
                    cell.labelText = TranslatableStrings.NutritionFacts

                    if let facts = productPair?.remoteProduct?.nutritionFactsDict ?? productPair?.localProduct?.nutritionFactsDict {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        cell.badgeText = "\(facts.count)"
                    } else {
                        cell.badgeText = TranslatableStrings.Undefined
                    }
                    return cell
                        
                case .nutritionScore:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionScore, for: indexPath) as? NutritionScoreTableViewCell
                    cell?.product = productPair?.remoteProduct ?? productPair?.localProduct
                    return cell!
                        
                case .categories:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
                    cell.labelText = TranslatableStrings.Categories
                    if let validCategories = productPair?.remoteProduct?.categoriesHierarchy ?? productPair?.localProduct?.categoriesOriginal {
                        switch validCategories {
                        case .undefined, .empty:
                            cell.badgeText = TranslatableStrings.Undefined
                        case let .available(list):
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeText = "\(list.count)"
                        case .notSearchable:
                            assert(true, "ProductTableViewController Error: How can I set a categorie is non-editable")
                        }
                    }
                    return cell
                
                case .completion:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Completion, for: indexPath) as? CompletionTableViewCell
                    cell?.product = productPair?.remoteProduct ?? productPair?.localProduct
                    return cell!
                
                case .supplyChain:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
                    cell.labelText = TranslatableStrings.SalesCountries
                    if let validCountries = productPair?.remoteProduct?.countriesTranslated ?? productPair?.localProduct?.countriesOriginal {
                        switch validCountries {
                        case .available(let countries):
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeText = "\(countries.count)"
                        default:
                            cell.badgeText = TranslatableStrings.Undefined
                        }
                    }
                    return cell
                }
            case .more:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Button, for: indexPath) as! ButtonTableViewCell //
                cell.delegate = self
                cell.title = validFetchResult.description
                cell.editMode = true
                cell.tag = indexPath.section * Constants.TagValue.Product.Multiplier + validFetchResult.rawValue
                return cell
                    
            case .productNotAvailable,
                .loading,
                .loadingFailed:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell //
                cell.datasource = self
                cell.delegate = self
                // encode the product number and result into the tag
                cell.tag = indexPath.section * Constants.TagValue.Product.Multiplier + validFetchResult.rawValue
                // cell.width = tableView.frame.size.width
                cell.scheme = ColorSchemes.error
                cell.accessoryType = .none
                return cell
                    
            case .searchQuery(let query):
                // What should appear in this cell depends on the search query element
                let searchPairs = query.searchPairsWithArray()
                if searchPairs.count > 0 && indexPath.row < searchPairs.count {
                    // Search labels with switches to include or exclude the label
                    //  -- tag values as tags and inclusion as labelText
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithLabel, for: indexPath) as! TagListViewLabelTableViewCell //
                    cell.datasource = self
                    cell.tag = tagValue(for: validFetchResult) + indexPath.row
                    cell.categoryLabel.text = searchPairs[indexPath.row].0.description
                    switch searchPairs[indexPath.row].0 {
                    case .searchText:
                        cell.labelText = ""
                    default:
                        cell.labelText = searchPairs[indexPath.row].2
                    }
                    cell.width = tableView.frame.size.width
                    cell.accessoryType = .none
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for:indexPath) as! TagListViewTableViewCell
                    cell.datasource = self
                    cell.tag = tagValue(for: validFetchResult)
                    //cell.width = tableView.frame.size.width
                    cell.scheme = ColorSchemes.normal
                    return cell
                }
            case .searchLoading:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell //
                cell.datasource = self
                cell.tag = tagValue(for: validFetchResult)
                cell.width = tableView.frame.size.width
                cell.accessoryType = .none
                return cell
            case .initialized, .productNotLoaded:
                products.loadProductPair(at: indexPath.section)
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.datasource = self
                cell.tag = tagValue(for: validFetchResult)
                cell.scheme = ColorSchemes.normal
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.datasource = self
                cell.tag = validFetchResult.rawValue + Constants.TagValue.Product.Multiplier * indexPath.section
                cell.scheme = ColorSchemes.normal
                return cell
                }
        } // No validFetchResult
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
        cell.datasource = self
        cell.tag = tagValue(for: .initialized)
        cell.scheme = ColorSchemes.normal
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        if let index = selectedIndex {
            selectedRowType = tableStructure[index]
        }
        if products.count > 0,
            let validFetchResult = products.productPair(at: indexPath.section)?.remoteStatus,
            let validProductPair = products.productPair(at: indexPath.section) {
                switch validFetchResult {
                case .available,
                     .loading,
                     .productNotLoaded:
                    selectedProductPair = validProductPair
                case .productNotAvailable,
                     .loadingFailed:
                    selectedProductPair = validProductPair
                case .searchQuery(let query):
                    selectedProductPair = ProductPair.init(barcodeType: .search(query, Preferences.manager.showProductType))
                default: break
                }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel.init(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 20))
        tempView.backgroundColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        if let validFetchResult = products.productPair(at: section)?.status {
            switch validFetchResult {
            case .available:
                if let validProduct = products.productPair(at: section)?.remoteProduct ?? products.productPair(at: section)?.localProduct,
                let languageCode = products.productPair(at: section)?.primaryLanguageCode {
                    label.text = products.productPair(at: section)?.remoteProduct?.nameLanguage[languageCode] ?? products.productPair(at: section)?.localProduct?.nameLanguage[languageCode] ?? Constants.Tag.ProductNameMissing
                    switch validProduct.tracesInterpreted {
                    case .available(let validKeys):
                        if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                            tempView.backgroundColor = UIColor.red
                        }
                    default:
                        break
                    }
                    switch validProduct.tracesInterpreted {
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
                } else {
                    assert(true, "remoteStatus is available, but there is no product")
                }
            case .loading(let barcodeString):
                label.text = barcodeString
            case .more:
                // no header required in this case https://world.openfoodfacts.org/api/v0/product/737628064502.json
                return nil
            case.loadingFailed(let error):
                label.text = error
                // Can we supply a specific error message?
                if error.contains("NSCocoaErrorDomain Code=256") {
                    // The error message when the server can not be reached:
                    // "Error Domain=NSCocoaErrorDomain Code=256 \"The file “7610207742059.json” couldn’t be opened.\" UserInfo={NSURL=http://world.openfoodfacts.org/api/v0/product/7610207742059.json}"
                    let parts = error.components(separatedBy: ".json")
                    if !parts.isEmpty {
                        let partsTwo = parts[0].components(separatedBy:"\'")
                        if partsTwo.count > 1 {
                            label.text = partsTwo[1]
                        }
                    }
                }
                
            case .searchQuery(let query):
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SearchHeaderView") as! SearchHeaderView
                headerView.delegate = self
                if !query.isEmpty {
                    // The buttons can function
                    headerView.buttonsAreEnabled = true
                    // Sorting is possible
                    headerView.sortButtonIsEnabled = query.type == .simple ? false : true
                } else {
                    headerView.buttonsAreEnabled = false
                }
                if !query.isEmpty {
                    headerView.title = query.numberOfSearchResults != nil ? "\(query.numberOfSearchResults!)" + " " +  TranslatableStrings.SearchResults : TranslatableStrings.SearchSetup
                } else {
                    headerView.title = TranslatableStrings.NoSearchDefined
                }
                return headerView
            case .searchLoading:
                label.text = TranslatableStrings.Searching
            default:
                label.text = products.productPair(at: section)?.barcodeType.asString
            }
        } else {
            label.text = Constants.Tag.NoProductsInHistory
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
        if let validFetchResult = products.productPair(at: section)?.remoteStatus {
            switch validFetchResult {
            case .more:
                // no header required in this case
                return 0.0
            default:
                break
            }
        }
        return UITableViewAutomaticDimension
    }
    
// MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ToPageViewController:
                if let vc = segue.destination as? UINavigationController {
                    if let ppvc = vc.topViewController as? ProductPageViewController {
                        ppvc.tableItem = selectedProductPair
                        if let validSelectedRowType = selectedRowType,
                            let validProductPair = selectedProductPair {
                            switch validProductPair.barcodeType {
                            case .search(let template, _):
                                if let validIndex = selectedIndex {
                                    let array = template.searchPairsWithArray()
                                    if array.count > 0 && validIndex < array.count {
                                        ppvc.pageIndex = searchRowType(array[validIndex].0)
                                    } else {
                                        ppvc.pageIndex = .identification
                                    }
                                }
                            default:
                                ppvc.pageIndex = validSelectedRowType.productSection()
                            }
                        } else {
                            ppvc.pageIndex = .identification
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowSettings:
                if let vc = segue.destination as? SettingsTableViewController {
                    vc.storedHistory = products.storedHistory
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    setNeedsStatusBarAppearanceUpdate()
                }
            case Storyboard.SegueIdentifier.ShowSortOrder:
                if let vc = segue.destination as? SetSortOrderViewController {
                    // The segue can only be initiated from a button within a searchHeaderView
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? SearchHeaderView != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of  the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                ppc.delegate = self
                                
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
                                    switch validFetchResult {
                                    case .searchQuery(let query):
                                        vc.currentSortOrder = query.sortOrder
                                    default:
                                        break
                                    }

                                }
                            }
                        }
                    }
                }

            default: break
            }
        }
    }
    
    // convert between the search categories and the display pages type
    private func searchRowType(_ component: SearchComponent) -> ProductSection {
        switch component {
        case .barcode, .searchText, .brand, .language, .packaging:
            return .identification
        case .category:
            return .categories
        case .country, .origin, .purchasePlace, .producerCode, .manufacturingPlaces, .store:
            return .supplyChain
        case .label, .additive, .trace, .allergen, .ingredient:
            return .ingredients
    case .contributor, .creator, .informer, .editor, .photographer, .corrector, .state, .checker, .lastEditDate, .entryDates:
            return .completion
        case .nutritionGrade:
            return .nutritionScore
        case .nutrient:
            return .nutritionFacts

        }
    }
    
    @IBAction func unwindForCancel(_ segue:UIStoryboardSegue) {
        startInterface(at:0)
    }
    
    @IBAction func unwindNewSearch(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? BarcodeScanViewController {
            // the user has done a barcode scan, so switch to the right tab
            switchToTab(withIndex: 0)
            // This will retrieve the corresponding product
            barcodeType = BarcodeType(typeCode:vc.type, value:vc.barcode, type:currentProductType)
            // update the interface
            searchTextField.text = vc.barcode
            // TODO: Should this be here?
            //products.list = .recent
            //startInterface(at: selectedIndex ?? 0)
            performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
        } else {
            assert(true, "ProductTableViewController:unwindNewSearch BarcodeScanViewController hierarchy error")
        }
    }
    
    @IBAction func unwindSetSortOrder(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SetSortOrderViewController {
            if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
                switch validFetchResult {
                case .searchQuery(let query):
                    if let validNewSortOrder = vc.selectedSortOrder {
                        if validNewSortOrder != query.sortOrder && !query.isEmpty {
                            query.sortOrder =  validNewSortOrder
                            OFFProducts.manager.startSearch()
                        }
                    }
                default:
                    break
                }

            }
        }
    }

    
    @IBAction func settingsDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SettingsTableViewController {
            if vc.historyHasBeenRemoved {
                products.removeAllProductPairs()
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
            assert(true, "ProductTableViewController:switchToTab: TabBar hierarchy error")
        }
        setTitle()
    }
    
    // MARK: - Notification methods
    
    // function is called if an product image has been retrieved via an asynchronous process
    @objc func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        
        // only update if the image barcode corresponds to the current product
        if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String,
            let section = products.productPairIndex(BarcodeType(barcodeString: barcodeString, type:Preferences.manager.showProductType)) {
            // let indexPaths = [IndexPath.init(row: 1, section: section)]
            let aantal = tableView.numberOfSections
            if section < aantal {
                tableView.reloadData()
                // tableView.reloadRows(at: indexPaths, with: .none)
            }
        }
    }
    
    /*
    @objc func showAlertProductNotAvailable(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        let error = userInfo!["error"] as? String ?? "ProductTableViewController:showAlertProductNotAvailable: No valid error"
        let barcodeString = userInfo![OFFProducts.Notification.BarcodeDoesNotExistKey] as? String
        let alert = UIAlertController(
            title: Constants.AlertSheet.Message,
            message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: Constants.AlertSheet.ActionTitleForCancel, style: .cancel) { (action: UIAlertAction) -> Void in
            // As the product was already create, it can now be deleted
                self.products.removeProduct(with:self.barcodeType)
            }
        )
        if let validBarcodeString = barcodeString {
            // if there is a valid barcode, allow the user to add it
            alert.addAction(UIAlertAction(title: Constants.AlertSheet.ActionTitleForAdd, style: .destructive) { (action: UIAlertAction) -> Void in
                let newProduct = FoodProduct(with: BarcodeType(barcodeTuple: (validBarcodeString, self.currentProductType.rawValue)))
                let preferredLanguage = Locale.preferredLanguages[0]
                let currentLanguage = preferredLanguage.split(separator:"-").map(String.init)

                newProduct.primaryLanguageCode = currentLanguage[0]
            })
        }
        self.present(alert, animated: true, completion: nil)
    }
     */

    @objc func productLoaded(_ notification: Notification) {
        
        // This is needed to increase the tablesize as each product is added.
        // The issue is the size of the product array that is determined by the number of received products.
        // It should be related to the size of the history file.
        // At least I think that that is the issue.

        tableView.reloadData()

    }
    
    @objc func productUpdated(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        if let barcodeString = userInfo![ProductPair.Notification.BarcodeKey] as? String {
            if let index = products.productPairIndex(BarcodeType(barcodeString: barcodeString, type: Preferences.manager.showProductType)) {
                if index == 0 {
                    if let validProductPair = products.productPair(at: index) {
                    // If this is the product at the top,
                    // save the updates also locally.
                        switch validProductPair.remoteStatus {
                        case .available:
                            MostRecentProduct().save(product:validProductPair.remoteProduct)
                        default:
                            break
                        }
                    }
                }
                
                // This codepart results sometimes in a crash. No idea what is happening
                // I like to reload only the product that has been updated
                
                //if self.tableView.numberOfSections > index + 1 {
                //    self.tableView.reloadSections([index], with: .automatic)
                //} else {
                    self.tableView.reloadData()
                //}
            }
        }
    }
    
    // 
    @objc func firstProductLoaded(_ notification: Notification) {
        startInterface(at: 0)
    }
    
    @objc func searchLoaded(_ notification: Notification) {
        switchToTab(withIndex: 1)
        if let index = notification.userInfo?[OFFProducts.Notification.SearchOffsetKey] as? Int {
            startInterface(at:index >= 0 ? index : 0)
        }
    }

    @objc func searchStarted(_ notification: Notification) {
        switchToTab(withIndex: 1)
        if let firstPage = notification.userInfo?[OFFProducts.Notification.SearchPageKey] as? Int {
            // if there is no SearchOffSet, then the search just started
            // If it is the first page, position the interface on the first section
            if firstPage == 0 {
                startInterface(at:0)
            }
        }
    }

    //func showPopOver() {
    //}
    
    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
                products.reloadAll()
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: "SearchHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SearchHeaderView")

        initializeCustomKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // addGesture()
        // setTitle()
        // make sure we show the right tab
        if products.list == .recent {
            switchToTab(withIndex: 0)
        } else {
            switchToTab(withIndex: 1)
        }

        if products.count > 0 && selectedProductPair == nil {
            // If nothing has been selected yet, start with the first product in the list
            startInterface(at: 0)
        }
        
        // Notifications coming from ProductPair,
        // which indicate that something in the productPair has changed
        // either the local product or the remote product
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductPairLocalStatusChanged, object:nil)
        //NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductUpdated, object:nil)
        //NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productLoaded(_:)), name:.ProductLoaded, object:nil)

        //NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.showAlertProductNotAvailable(_:)), name:.ProductNotAvailable, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:.SampleLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.searchLoaded(_:)), name:.SearchLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.searchStarted(_:)), name:.SearchStarted, object:nil)
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
    
    // MARK: - ButtonCellDelegate Functions
    

extension ProductTableViewController: ButtonCellDelegate {
        
    // function to let the delegate know that a button was tapped
    func buttonTableViewCell(_ sender: ButtonTableViewCell, receivedTapOn button:UIButton) {
        products.fetchSearchProductsForNextPage()
    }
}

// MARK: - SearchHeaderDelegate Functions
    
extension ProductTableViewController: SearchHeaderDelegate {
    
    func sortButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowSortOrder, sender: button)
    }
    
    func clearButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
        if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
            switch validFetchResult {
            case .searchQuery(let query):
                query.clear()
                products.reloadAll()
                tableView.reloadData()
            default:
                break
            }

        }
    }
}
    
// MARK: - UIGestureRecognizerDelegate Functions
    
extension ProductTableViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Identify gesture recognizer and return true else false.
        return gestureRecognizer.isEqual(self.downTwoFingerSwipe) ? true : false
    }
}
    
// MARK: - UITabBarControllerDelegate Functions
    
extension ProductTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        products.list = tabBarController.selectedIndex == 0 ? .recent : .search
        // refreshInterface()
        startInterface(at: 0)
    }
    
}
 
// MARK: - TagListViewCellDelegate Functions
    
extension ProductTableViewController: TagListViewCellDelegate {
        
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}
    

// MARK: - TagListView DataSource Functions
    
extension ProductTableViewController: TagListViewDataSource {
        
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        // is this a searchQuery section?
        if tagListView.tag >= Constants.TagValue.Search.Query {
            if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
                switch validFetchResult {
                case .searchQuery(let query):
                    let searchPairs = query.searchPairsWithArray()
                    let index = tagListView.tag - Constants.TagValue.Search.Query
                    if index > 0 && index < searchPairs.count && !query.isEmpty {
                        return searchPairs[index].1.count
                    }
                default:
                    break
                }

            }
        }
        return 1
    }
        
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {

        // find the product that has been tapped on
        //let productIndex = Int( tagListView.tag / Constants.Offset.ProductMultiplier )
        // find the status of the product
        let code = tagListView.tag % Constants.TagValue.Product.Multiplier
        
        // Is the cell related to a query?
        if code >= Constants.TagValue.Search.NotDefined {
            // is this a no search defined cell
            if code == Constants.TagValue.Search.NotDefined {
                return ProductFetchStatus.noSearchDefined.description
            // is this a search Loading cell?
            } else if code == Constants.TagValue.Search.Loading {
                return TranslatableStrings.Loading
            } else if code == Constants.TagValue.Search.MoreResults {
                return ProductFetchStatus.noSearchDefined.description
            // is this (part of ) a search query cell?
            } else if code >= Constants.TagValue.Search.Query {
                    if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
                switch validFetchResult {
                case .searchQuery(let query):
                    if query.isEmpty {
                        return TranslatableStrings.SetupQuery
                    } else {
                        let searchPairs = query.searchPairsWithArray()
                        let tagIndex = tagListView.tag - Constants.TagValue.Search.Query
                        if tagIndex >= 0 && tagIndex < searchPairs.count {
                            let array = searchPairs[tagIndex].1
                            if index >= 0 && index < array.count {
                                return array[index]
                            }
                        }
                    }
                default:
                    break
                }
        
                return ProductFetchStatus.description(for: code  - Constants.TagValue.Search.Query)
                }
            }
        } else if code >= Constants.TagValue.Image {
            return ImageFetchResult.description(for: code - Constants.TagValue.Image)
        }
        
        return ProductFetchStatus.description(for: code)
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
        
}
    
// MARK: - TagListView Delegate Functions
    
extension ProductTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
        //tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        
        // find the product that has been tapped on
        let productIndex = Int( tagListView.tag / Constants.TagValue.Product.Multiplier )
        // find the status of the product
        let code = tagListView.tag % Constants.TagValue.Product.Multiplier
        // try to reload the product
        if code == ProductFetchStatus.productNotLoaded("").rawValue  ||
            code == ProductFetchStatus.loadingFailed("").rawValue {
            _ = products.loadProductPair(at: productIndex)
        }
    }
        
}

    
// MARK: - UIPopoverPresentationControllerDelegate Functions
    
extension ProductTableViewController: UIPopoverPresentationControllerDelegate {
        
    // MARK: - Popover delegation functions
        
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
        
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
}
    

// MARK: - UIDragInteractionDelegate Functions

@available(iOS 11.0, *)
extension ProductTableViewController: UITableViewDragDelegate {
        
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if let validFetchResult = products.productPair(at: indexPath.section)?.remoteStatus,
            let validProduct = products.productPair(at: indexPath.section)?.remoteProduct {
            switch validFetchResult {
            case .available:
                let currentProductSection = tableStructure[indexPath.row]
                switch currentProductSection {
                case .image:
                    if let language = validProduct.primaryLanguageCode,
                        !validProduct.frontImages.isEmpty,
                        let fetchResult = validProduct.frontImages[language]?.largest?.fetch() {
                        switch fetchResult {
                        case .success(let image):
                            let provider = NSItemProvider(object: image)
                            let item = UIDragItem(itemProvider: provider)
                            item.localObject = image
                            return [item]
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            default:
                break
            }

        }
        return []
    }
        
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let currentProductSection = tableStructure[indexPath.row]
        switch currentProductSection {
        case .image :
            if let cell = tableView.cellForRow(at: indexPath) as? ImagesPageTableViewCell {
                if let rect = cell.productImageView.imageRect {
                    let parameters = UIDragPreviewParameters.init()
                    parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
                    return parameters
                }
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {

        // only allow flocking of another image
        for item in session.items {
            // Note kUTTypeImage needs an import of MobileCoreServices
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        if let validFetchResult = products.productPair(at: indexPath.section)?.remoteStatus,
            let validProduct = products.productPair(at: indexPath.section)?.remoteProduct {
            switch validFetchResult {
            case .available:
                let currentProductSection = tableStructure[indexPath.row]
                switch currentProductSection {
                case .image:
                    if let language = validProduct.primaryLanguageCode,
                        !validProduct.frontImages.isEmpty,
                        let fetchResult = validProduct.frontImages[language]?.largest?.fetch() {
                        switch fetchResult {
                        case .success(let image):
                                // check if the selected image has not been added yet
                                for item in session.items {
                                    guard item.localObject as! UIImage != image else { return [] }
                                }
                                let provider = NSItemProvider(object: image)
                                let item = UIDragItem(itemProvider: provider)
                                item.localObject = image
                                return [item]
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            default:
                break
            }
        }
        return []
    }

}

