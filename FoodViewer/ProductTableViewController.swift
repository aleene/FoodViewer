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

        struct AlertSheet {
            static let Message = TranslatableStrings.ProductDoesNotExistAlertSheetMessage
            static let ActionTitleForCancel = TranslatableStrings.ProductDoesNotExistAlertSheetActionTitleForCancel
            static let ActionTitleForAdd = TranslatableStrings.ProductDoesNotExistAlertSheetActionTitleForAdd
        }
        
        struct Tag {
            static let NoProductsInHistory = TranslatableStrings.NoProductsListed
            static let ProductNameMissing = TranslatableStrings.ProductNameMissing
        }
    }
    

    fileprivate var products = OFFProducts.manager
    
    fileprivate var barcode: BarcodeType? = nil {
        didSet {
            let index = products.fetchProduct(barcode)
            if  let validIndex = index {
                switch products.fetchResultList[validIndex]  {
                case .success(let product):
                    selectedProduct = product
                    selectedIndex = validIndex
                    tableView.reloadData()
                    tableView.scrollToRow(at: IndexPath(row: 0, section: validIndex), at: .middle, animated: true)
                default:
                    break
                }
            }
        }
    }
    
    fileprivate func startInterface(at index:Int) {
        if !products.fetchResultList.isEmpty && index < products.fetchResultList.count {
            switch products.fetchResultList[index] {
            case .success(let product):
                selectedProduct = product
                tableView.reloadData()
            //tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
            case .searchQuery(let query):
                selectedProduct = query
                tableView.reloadData()
            //tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
            default:
                selectedProduct = nil
                tableView.reloadData()
            }
        } else {
            selectedProduct = nil
            tableView.reloadData()
        }
        setTitle()
    }
    
    fileprivate func refreshInterface() {
        if products.fetchResultList.count > 0 {
            tableView.reloadData()
        }
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
    
    fileprivate var selectedProduct: Any? = nil {
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
            case .searchQuery:
                if section == 0 {
                    switch products.fetchResultList[0] {
                    case .searchQuery(let query):
                        return query.searchPairsWithArray().count
                    default:
                        break
                    }
                }
                return tableStructure.count
            case .more, .loadingFailed:
                // allow a cell with a button
                return 1
            default:
                break
            }
        // }
        // no rows as the loading failed, the error message is in the header
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !products.fetchResultList.isEmpty && indexPath.section < products.fetchResultList.count {
            //if let fetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch products.fetchResultList[indexPath.section] {
                case .success(let currentProduct):
                    let currentProductSection = tableStructure[indexPath.row]
                    switch currentProductSection {
                    case .name:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Name, for: indexPath) as! NameTableViewCell
                        switch currentProduct.brandsOriginal {
                        case .undefined, .empty:
                            cell.productBrand = [currentProduct.brandsOriginal.description()]
                        case let .available(list):
                            cell.productBrand = list
                        case .notSearchable:
                            assert(true, "ProductTableViewController Error: How can I set a brand a tag when the field is non-editable")
                        }
                        return cell
                        
                    case .image:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ImagesPageTableViewCell
                        if let language = currentProduct.primaryLanguageCode {
                            cell.productImage = nil
                            if !currentProduct.frontImages.isEmpty {
                                if let result = currentProduct.frontImages[language]?.small?.fetch() {
                                    switch result {
                                    case .available:
                                        cell.productImage = currentProduct.frontImages[language]?.small?.image
                                    default:
                                        break
                                    }
                                }
                            }
                        }
                        return cell

                    case .ingredientsAllergensTraces:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.IngredientsPage, for: indexPath) as! IngredientsPageTableViewCell
                        
                        cell.ingredientsLabel?.text = TranslatableStrings.Ingredients

                        if let number = currentProduct.numberOfIngredients {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.ingredientsBadgeString = "\(number)"
                        } else {
                            cell.ingredientsBadgeString = TranslatableStrings.Undefined
                        }
                        
                        cell.allergensLabel?.text = TranslatableStrings.Allergens
                        switch currentProduct.allergensTranslated {
                        case .available(let allergens):
                            cell.allergensBadgeString = "\(allergens.count)"
                        default:
                            cell.allergensBadgeString = TranslatableStrings.Undefined
                        }
                        
                        cell.tracesLabel?.text = TranslatableStrings.Traces
                        switch currentProduct.tracesInterpreted {
                        case .available(let traces):
                            cell.tracesBadgeString = "\(traces.count)"
                        default:
                            cell.tracesBadgeString = TranslatableStrings.Undefined
                        }
                        return cell
                        
                    case .ingredients:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Ingredients, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = TranslatableStrings.Ingredients
                        if let number = currentProduct.numberOfIngredients {
                            cell.badgeString = number
                        }
                        return cell
                        
                    case .nutritionFacts:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionFacts, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = TranslatableStrings.NutritionFacts

                        if let count = currentProduct.nutritionFacts?.count {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(count)"
                        } else {
                            cell.badgeString = TranslatableStrings.Undefined
                        }
                        return cell
                        
                    case .nutritionScore:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionScore, for: indexPath) as? NutritionScoreTableViewCell
                        cell?.product = currentProduct
                        return cell!
                        
                    case .categories:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = TranslatableStrings.Categories

                        switch currentProduct.categoriesHierarchy {
                        case .undefined, .empty:
                            cell.badgeString = TranslatableStrings.Undefined
                        case let .available(list):
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(list.count)"
                        case .notSearchable:
                            assert(true, "ProductTableViewController Error: How can I set a categorie is non-editable")
                        }
                        return cell
                    case .completion:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Completion, for: indexPath) as? CompletionTableViewCell
                        cell?.product = currentProduct
                        return cell!
                    case .supplyChain:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Producer, for: indexPath) as! TDBadgedCell
                        cell.textLabel!.text = TranslatableStrings.SalesCountries
                        switch currentProduct.countriesTranslated {
                        case .available(let countries):
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .decimal
                            cell.badgeString = "\(countries.count)"
                        default:
                            cell.badgeString = TranslatableStrings.Undefined
                        }
                        return cell
                    }
                case .more:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell //
                    cell.datasource = self
                    cell.tag = 1
                    cell.width = tableView.frame.size.width
                    cell.scheme = ColorSchemes.error
                    cell.accessoryType = .none
                    return cell
                    
                case .loadingFailed:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell //
                    cell.datasource = self
                    cell.tag = 2
                    cell.width = tableView.frame.size.width
                    cell.scheme = ColorSchemes.error
                    cell.accessoryType = .none
                    return cell
                    
                case .searchQuery(let query):
                    // What should appear in this cell depends on the search query element
                    
                    let searchPairs = query.searchPairsWithArray()
                    if searchPairs.count > 0 {
                        switch searchPairs[indexPath.row].0 {
                        case .searchText:
                            // Search text
                            // -- element name as prefix, search text value as tag
                            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell //
                            cell.datasource = self
                            // The hundreds define a searchQuery section, the rest is just the row
                            cell.tag = 300 + indexPath.row
                            cell.prefixLabelText = searchPairs[indexPath.row].0.description
                            cell.width = tableView.frame.size.width
                            cell.accessoryType = .none
                            return cell
                        default:
                            // Search labels with switches to include or exclude the label
                            //  -- tag values as tags and inclusion as labelText
                            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithLabel, for: indexPath) as! TagListViewLabelTableViewCell //
                            cell.datasource = self
                            // The hundreds define a searchQuery section, the rest is just the row
                            cell.tag = 300 + indexPath.row
                            cell.prefixLabelText = searchPairs[indexPath.row].0.description
                            cell.labelText = searchPairs[indexPath.row].2
                            cell.width = tableView.frame.size.width
                            cell.accessoryType = .none
                            return cell
                        }
                    }

                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = 0
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.normal
                    return cell!
                }
            //}
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as? TagListViewTableViewCell
        return cell!
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        if let index = selectedIndex {
            selectedRowType = tableStructure[index]
        }
        if !products.fetchResultList.isEmpty {
            //if let validProductFetchResult = products.fetchResultList[(indexPath as NSIndexPath).section] {
                switch products.fetchResultList[indexPath.section] {
                case .success(let product):
                    selectedProduct = product
                case .searchQuery(let query):
                    selectedProduct = query
                case .more:
                    // The next set should be loaded
                    products.fetchSearchProductsForNextPage()
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
        if !products.fetchResultList.isEmpty && (section < products.fetchResultList.count) {
            switch products.fetchResultList[section] {
            case .success(let product):
                label.text = product.name != nil ? product.name! : Constants.Tag.ProductNameMissing
                switch product.tracesInterpreted {
                case .available(let validKeys):
                    if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                        tempView.backgroundColor = UIColor.red
                    }
                default:
                    break
                }
                switch product.tracesInterpreted {
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
            case .other(let message):
                label.text = message
            case .more:
                // no header required in this case
                return nil
            case.loadingFailed(let error):
                label.text = error
                // Can we supply a specific error message?
                if error.contains("NSCocoaErrorDomain Code=256") {
                    // The error message when the server can not be reached:
                    // "Error Domain=NSCocoaErrorDomain Code=256 \"The file “7610207742059.json” couldn’t be opened.\" UserInfo={NSURL=http://world.openfoodfacts.org/api/v0/product/7610207742059.json}"
                    let parts = error.components(separatedBy: ".json")
                    if !parts.isEmpty {
                        let partsTwo = parts[0].components(separatedBy:"The file “")
                        if partsTwo.count > 0 {
                            label.text = partsTwo[1]
                        }
                    }
                }
            case .searchQuery(let query):
                if !query.isEmpty {
                    label.text = query.numberOfSearchResults != nil ? "\(query.numberOfSearchResults!)" + " " +  TranslatableStrings.SearchResults : TranslatableStrings.NoSearchResult
                } else {
                    label.text = TranslatableStrings.NoSearchDefined
                }
            default:
                label.text = products.fetchResultList[section].description()
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
        switch products.fetchResultList[section] {
        case .more:
            // no header required in this case
            return 0.0
        default:
            return UITableViewAutomaticDimension
        }
    }
    
// MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ToPageViewController:
                if let vc = segue.destination as? UINavigationController {
                    if let ppvc = vc.topViewController as? ProductPageViewController {
                        ppvc.tableItem = selectedProduct
                        if let validSelectedRowType = selectedRowType {
                            if selectedProduct != nil && selectedProduct! is FoodProduct {
                                ppvc.pageIndex = validSelectedRowType.productSection()
                            } else if let search = selectedProduct as? SearchTemplate {
                                if let validIndex = selectedIndex {
                                    let array = search.searchPairsWithArray()
                                    if array.count > 0 && validIndex < array.count {
                                        ppvc.pageIndex = searchRowType(array[validIndex].0)
                                    }
                                }
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
        case .label, .additive, .trace, .allergen:
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
        if let _ = segue.source as? BarcodeScanViewController {
            if products.fetchResultList.count > 0 {
                tableView.reloadData() 
            }
        }
    }
    
    func unwindForBack() {
        tableView.reloadData()
    }
    
    @IBAction func unwindNewSearch(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? BarcodeScanViewController {
            switchToTab(withIndex: 0)
            barcode = BarcodeType(typeCode:vc.type, value:vc.barcode, type:currentProductType)
            searchTextField.text = vc.barcode
            products.list = .recent
            startInterface(at: selectedIndex ?? 0)
                

            performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
        } else {
            assert(true, "ProductTableViewController: BarcodeScanViewController hierarchy error")
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
    
    private func switchToTab(withIndex index: Int) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            tabVC.selectedIndex = index
        } else {
            assert(true, "ProductTableViewController: TabBar hierarchy error")
        }
        setTitle()
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

// being more specific on what is reloaded results in a very jittery interface
//            if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String {
//                if let index = OFFProducts.manager.index(BarcodeType.init(value: barcodeString)) {
//                    let indexPaths = [IndexPath.init(row: 0, section: index)]
//                    tableView.beginUpdates()
//                    tableView.reloadRows(at: indexPaths, with: .fade)
//                    //tableView.reloadSections([index], with: .none)
//
//                    tableView.endUpdates()
//                }
//            }
        }
    }
    
    func showAlertProductNotAvailable(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        let error = userInfo!["error"] as? String ?? "ProductTableViewController: No valid error"
        let barcodeString = userInfo![OFFProducts.Notification.BarcodeDoesNotExistKey] as? String
        let alert = UIAlertController(
            title: Constants.AlertSheet.Message,
            message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: Constants.AlertSheet.ActionTitleForCancel, style: .cancel) { (action: UIAlertAction) -> Void in // do nothing )
            }
        )
        if let validBarcodeString = barcodeString {
            // if there is a valid barcode, allow the user to add it
            alert.addAction(UIAlertAction(title: Constants.AlertSheet.ActionTitleForAdd, style: .destructive) { (action: UIAlertAction) -> Void in
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
        tableView.reloadData()
//
//  THIS PART RESULTS IN AN EXCEPTION on reloadSections
//
//        let userInfo = (notification as NSNotification).userInfo
//        guard userInfo != nil else { return }
//        if let barcodeString = userInfo![OFFProducts.Notification.BarcodeKey] as? String {
//            if let index = OFFProducts.manager.index(BarcodeType.init(value: barcodeString)) {
//                if self.tableView.numberOfSections > index + 1 {
//                    let path = IndexPath.init(row: 0, section: index)
//                    self.tableView.reloadSections([index], with: .none)
//                } else {
//                    self.tableView.reloadData()
//                }
//            }
//        }
    }
    
    func productUpdated(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        if let barcodeString = userInfo![OFFProducts.Notification.BarcodeKey] as? String {
            if let index = OFFProducts.manager.index(BarcodeType.init(value: barcodeString)) {
                if self.tableView.numberOfSections > index + 1 {
                    self.tableView.reloadSections([index], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            }
        }
    }
    // 
    func firstProductLoaded(_ notification: Notification) {
        startInterface(at: 0)
    }
    
    func searchLoaded(_ notification: Notification) {
        switchToTab(withIndex: 1)
        if let index = notification.userInfo?[OFFProducts.Notification.SearchOffsetKey] as? Int {
            startInterface(at:index)
        }
    }

    func searchStarted(_ notification: Notification) {
        switchToTab(withIndex: 1)
        if let firstPage = notification.userInfo?[OFFProducts.Notification.SearchPageKey] as? Int {
            // if there is no SearchOffSet, then the search just started
            // If it is the first page, position the interface on the first section
            if firstPage == 0 {
                startInterface(at:0)
            }
        }
    }

    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0
        
        initializeCustomKeyboard()
        // DO WE NEED THIS?
        // startInterface(at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // addGesture()
        // setTitle()

        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.showAlertProductNotAvailable(_:)), name:.ProductNotAvailable, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productLoaded(_:)), name:.ProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.firstProductLoaded(_:)), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.searchLoaded(_:)), name:.SearchLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.searchStarted(_:)), name:.SearchStarted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ProductTableViewController.productUpdated(_:)), name:.ProductLoadingError, object:nil)
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
   
extension ProductTableViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Identify gesture recognizer and return true else false.
        return gestureRecognizer.isEqual(self.downTwoFingerSwipe) ? true : false
    }
}
   
extension ProductTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        products.list = tabBarController.selectedIndex == 0 ? .recent : .search
        // refreshInterface()
        startInterface(at: 0)
    }
    
}
    
    
// MARK: - TagListView DataSource Functions
    
extension ProductTableViewController: TagListViewDataSource {
        
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        // is this a searchQuery section?
        if tagListView.tag >= 300 {
            switch products.fetchResultList[0] {
            case .searchQuery:
                switch products.fetchResultList[0] {
                case .searchQuery(let query):
                    // print(tagListView.tag, product.searchPairsWithArray())
                    return query.searchPairsWithArray()[tagListView.tag - 300].1.count
                default:
                    break
                }
            default:
                break
            }
        }
        return 1
    }
        
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if tagListView.tag == 0 {
            let fetchStatus = ProductFetchStatus.loading
            return fetchStatus.description()
        } else if tagListView.tag == 1 {
            let fetchStatus = ProductFetchStatus.more(0)
            return fetchStatus.description()
        } else if tagListView.tag == 2 {
            let fetchStatus = ProductFetchStatus.loadingFailed(TranslatableStrings.LoadingFailed)
            return fetchStatus.description()
        } else if tagListView.tag >= 300 {
            switch products.fetchResultList[0] {
            case .searchQuery:
                switch products.fetchResultList[0] {
                case .searchQuery(let query):
                    let array = query.searchPairsWithArray()[tagListView.tag - 300].1
                    return array[index]
                default:
                    break
                }
            default:
                break
            }
        }
        return "ProductTableViewController: tagListView.tag not recognized"
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
        
}
    
// MARK: - TagListView Delegate Functions
    
extension ProductTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
}



