//
//  IngredientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsTableViewController: UITableViewController {

    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate var ingredientsImage: UIImage? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    fileprivate enum SectionType {
        case ingredients
        case allergens
        case traces
        case additives
        case labels
        case image
    }
    
    
    fileprivate var allergensToDisplay: Tags {
        get {
            return product!.translatedAllergens
        }
    }
    
    fileprivate var tracesToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.traces {
                case .available, .empty:
                    return delegate!.updatedProduct!.traces
                default:
                    break
                }
            }
            return product!.translatedTraces
        }
    }
    
    fileprivate var additivesToDisplay: Tags {
        get {
            return product!.additives
        }
    }
    
    fileprivate var labelsToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.labelArray {
                case .available, .empty:
                    return delegate!.updatedProduct!.labelArray
                default:
                    break
                }
            }
            return product!.labelArray
        }
    }

    // MARK: - Public variables
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                ingredientsImage = nil
                tableStructureForProduct = analyseProductForTable(product!)
                refreshProduct()
            }
        }
    }
    
    var currentLanguageCode: String? = nil {
        didSet {
            if currentLanguageCode != oldValue {
                tableView.reloadData()
            }
        }
    }

    var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }

    var delegate: ProductPageViewController? = nil

    // MARK: - Actions and Outlets
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    fileprivate struct Storyboard {
        static let IngredientsCellIdentifier = "Ingredients Full Cell"
        static let AllergensCellIdentifier = "Allergens TagList Cell"
        static let TracesCellIdentifier = "Traces TagList Cell"
        static let AdditivesCellIdentifier = "Additives TagList Cell"
        static let LabelsCellIdentifier = "Labels TagList Cell"
        static let IngredientsImageCellIdentifier = "Ingredients Image Cell"
        static let NoImageCellIdentifier = "No Image Cell"
        static let ShowIdentificationSegueIdentifier = "Show Ingredients Image"
        static let SelectLanguageSegueIdentifier = "Show Ingredients Languages"
    }
    
    fileprivate struct TextConstants {
        static let ShowIdentificationTitle = NSLocalizedString("Image", comment: "Title for the ViewController with the image of the product ingredients.")
        static let ViewControllerTitle = NSLocalizedString("Ingredients", comment: "Title for the ViewController with the product ingredients.")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructureForProduct.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        // we assume that product exists
        switch currentProductSection {
        case .ingredients:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.IngredientsCellIdentifier, for: indexPath) as? IngredientsFullTableViewCell
            cell!.numberOfLanguages = product!.languageCodes.count
            cell!.textViewDelegate = self
            cell!.textViewTag = 0
            cell!.editMode = editMode
            if let validCurrentLanguageCode = currentLanguageCode {
                cell!.languageCode = validCurrentLanguageCode
                // has the product been edited?
                if let validName = delegate?.updatedProduct?.ingredientsLanguage[validCurrentLanguageCode] {
                    cell!.ingredients = validName
                } else if let validName = product?.ingredientsLanguage[validCurrentLanguageCode] {
                        cell!.ingredients = validName
                } else {
                    cell!.ingredients = nil
                }
            }
            return cell!
            
        case .allergens:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.AllergensCellIdentifier, for: indexPath) as! AllergensFullTableViewCell
            cell.datasource = self
            cell.tag = 0
            return cell
            
        case .traces:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TracesCellIdentifier, for: indexPath) as! TracesFullTableViewCell
            // cell.editMode = editMode
            cell.datasource = self
            cell.delegate = self
            cell.tag = 1
            return cell
            
        case .additives:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.AdditivesCellIdentifier, for: indexPath) as! AdditivesFullTableViewCell
            cell.datasource = self
            cell.tag = 2
            return cell
            
        case .labels:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LabelsCellIdentifier, for: indexPath) as! LabelsFullTableViewCell
            // cell.editMode = editMode
            cell.datasource = self
            cell.delegate = self
            cell.tag = 3
            return cell
            
        case .image:
            if let result = product?.getIngredientsImageData() {
                switch result {
                case .success(let data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.IngredientsImageCellIdentifier, for: indexPath) as? IngredientsImageTableViewCell
                    cell?.ingredientsImage = UIImage(data:data)
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoImageCellIdentifier, for: indexPath) as? NoImageTableViewCell
                    cell?.imageFetchStatus = result
                    return cell!
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoImageCellIdentifier, for: indexPath) as? NoImageTableViewCell
                cell?.imageFetchStatus = ImageFetchResult.noImageAvailable
                return cell!
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        switch currentProductSection {
        case .ingredients:
            changeLanguage()
        default:
            break
        }
        return
    }
    
    fileprivate func nextLanguageCode() -> String {
        let currentIndex = (product?.languageCodes.index(of: currentLanguageCode!))!
        
        let nextIndex = currentIndex == ((product?.languageCodes.count)! - 1) ? 0 : (currentIndex + 1)
        return (product?.languageCodes[nextIndex])!
    }

    fileprivate struct TableStructure {
        static let IngredientsSectionSize = 1
        static let AllergensSectionSize = 1
        static let TracesSectionSize = 1
        static let AdditivesSectionSize = 1
        static let LabelsSectionSize = 1
        static let ImageSectionSize = 1
        static let IngredientsSectionHeader = NSLocalizedString("Ingredients", comment: "Header title for the product ingredients section.")
        static let AllergensSectionHeader = NSLocalizedString("Allergens", comment: "Header title for the product allergens section, i.e. the allergens derived from the ingredients.")
        static let TracesSectionHeader = NSLocalizedString("Traces", comment: "Header title for the product traces section, i.e. the traces are from products which are worked with in the factory and are indicated separate on the label.")
        static let AdditivesSectionHeader = NSLocalizedString("Additives", comment: "Header title for the product additives section, i.e. the additives are derived from the ingredients list.")
        static let LabelsSectionHeader = NSLocalizedString("Labels", comment: "Header title for the product labels section, i.e. images, logos, etc.")
        static let ImageSectionHeader = NSLocalizedString("Ingredients Image", comment: "Header title for the ingredients image section, i.e. the image of the package with the ingredients")
    }
    
    fileprivate func analyseProductForTable(_ product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 0: ingredients
        sectionsAndRows.append((SectionType.ingredients,
            TableStructure.IngredientsSectionSize,
            TableStructure.IngredientsSectionHeader))
        
        // 1:  allergens section
        sectionsAndRows.append((
            SectionType.allergens,
            TableStructure.AllergensSectionSize,
            TableStructure.AllergensSectionHeader))
        
        // 2: traces section
        sectionsAndRows.append((
            SectionType.traces,
            TableStructure.TracesSectionSize,
            TableStructure.TracesSectionHeader))
    
        // 3: additives section
        sectionsAndRows.append((
            SectionType.additives,
            TableStructure.AdditivesSectionSize,
            TableStructure.AdditivesSectionHeader))
        
        // 4: labels section
        sectionsAndRows.append((
            SectionType.labels,
            TableStructure.LabelsSectionSize,
            TableStructure.LabelsSectionHeader))
        
        
        // 5: image section
        sectionsAndRows.append((
            SectionType.image,
            TableStructure.ImageSectionSize,
            TableStructure.ImageSectionHeader))
        
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowIdentificationSegueIdentifier:
                if let vc = segue.destination as? imageViewController {
                    if let result = product?.getIngredientsImageData() {
                        // try large image
                        switch result {
                        case .success(let data):
                            vc.image = UIImage(data: data)
                            vc.imageTitle = TextConstants.ShowIdentificationTitle
                        default:
                            vc.image = nil
                        }
                    }
                }
            case Storyboard.SelectLanguageSegueIdentifier:
                // pass the current language on to the popup vc
                if let vc = segue.destination as? SelectLanguageViewController {
                    vc.currentLanguageCode = currentLanguageCode
                    vc.languageCodes = product!.languageCodes
                    vc.updatedLanguageCodes = delegate?.updatedProduct != nil ? delegate!.updatedProduct!.languageCodes : []
                    vc.primaryLanguageCode = product?.primaryLanguageCode
                    vc.sourcePage = 1
                    vc.editMode = editMode
                }
            default: break
            }
        }
    }
    // MARK: - Notification handler
    
    func reloadImageSection(_ notification: Notification) {
        tableView.reloadData()
        // tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 5)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func refreshProduct() {
        tableView.reloadData()
    }
    
    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    func changeLanguage() {
        // set the next language in the array
        if currentLanguageCode != nextLanguageCode() {
            currentLanguageCode = nextLanguageCode()
            // reload the first two rows
            let indexPaths = [IndexPath.init(row: 0, section: 0)]
            tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.fade)
            tableView.deselectRow(at: indexPaths.first!, animated: true)
        }
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
        title = TextConstants.ViewControllerTitle
        
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.reloadImageSection(_:)), name:.IngredientsImageSet, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.changeLanguage), name:.IngredientsTextViewTapped, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - TextView Delegate Functions

extension IngredientsTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editMode
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.isFirstResponder { textView.resignFirstResponder() }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            // productname
            if let validText = textView.text {
                delegate?.updated(ingredients: validText, languageCode: currentLanguageCode!)
            }
        default:
            break
        }
    }
    
    func textViewHeightForAttributedText(text: NSAttributedString, andWidth width: CGFloat) -> CGFloat {
        let calculationView = UITextView()
        calculationView.attributedText = text
        let size = calculationView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
    
}

// MARK: - TagListView Delegate functions

extension IngredientsTableViewController: TagListViewDelegate {
    
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tagListView.tag {
        case 1:
            switch tracesToDisplay {
            case .undefined, .empty:
                delegate?.update(tracesTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(tracesTags: list)
            }
            tableView.reloadData()
        case 3:
            switch labelsToDisplay {
            case .undefined, .empty:
                delegate?.update(labelTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(labelTags: list)
            }
            tableView.reloadData()
        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        switch tagListView.tag {
        case 1:
            switch tracesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(tracesTags: list)
            }
            tableView.reloadData()
        case 3:
            switch labelsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(labelTags: list)
            }
            tableView.reloadData()
        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        /*
         switch tagListView.tag {
         case 0:
         case 1:
         
         default:
         break
         }
         */
        tableView.setNeedsLayout()
    }

    // TagListView function stubs
    
    public func tagListView(_ tagListView: TagListView, didSelectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, willSelectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didDeselectTagAt index: Int) {
    }

    public func tagListView(_ tagListView: TagListView, willDeselectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, willBeginEditingTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, targetForMoveFromTagAt sourceIndex: Int,
                            toProposed proposedDestinationIndex: Int) -> Int {
        return proposedDestinationIndex
    }
    
    public func tagListView(_ tagListView: TagListView, didEndEditingTagAt index: Int) {
    }
    
}

// MARK: - TagListView DataSource Functions

extension IngredientsTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        switch tagListView.tag {
        case 0:
            switch allergensToDisplay {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
            
        case 1:
            switch tracesToDisplay {
            case .undefined:
                tagListView.allowsRemoval = false
                tagListView.allowsCreation = false
                tagListView.clearButtonIsEnabled = false
                tagListView.removeButtonIsEnabled = false
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.allowsRemoval = editMode
                tagListView.allowsCreation = editMode
                tagListView.clearButtonIsEnabled = editMode
                tagListView.removeButtonIsEnabled = editMode
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.allowsRemoval = editMode
                tagListView.allowsCreation = editMode
                tagListView.clearButtonIsEnabled = editMode
                tagListView.removeButtonIsEnabled = editMode
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
        case 2:
            switch additivesToDisplay {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
        case 3:
            switch labelsToDisplay {
            case .undefined:
                tagListView.allowsRemoval = false
                tagListView.allowsCreation = false
                tagListView.clearButtonIsEnabled = false
                tagListView.removeButtonIsEnabled = false
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.allowsRemoval = editMode
                tagListView.allowsCreation = editMode
                tagListView.clearButtonIsEnabled = editMode
                tagListView.removeButtonIsEnabled = editMode
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.allowsRemoval = editMode
                tagListView.allowsCreation = editMode
                tagListView.clearButtonIsEnabled = editMode
                tagListView.removeButtonIsEnabled = editMode
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            }
        default: break
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        switch tagListView.tag {
        case 0:
            return allergensToDisplay.tag(index)!
        case 1:
            return tracesToDisplay.tag(index)!
        case 2:
            return additivesToDisplay.tag(index)!
        case 3:
            return labelsToDisplay.tag(index)!
        default: break
        }
        return("tagListView error")
    }
    /*
    // TagListView function stubs
    
    public func didClear(_ tagListView: TagListView) {
    }
    
    public func tagListView(_ tagListView: TagListView, canEditTagAt index: Int) -> Bool {
        return editMode
    }

    public func tagListView(_ tagListView: TagListView, canMoveTagAt index: Int) -> Bool {
        return false
    }
    
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Stub collapsed text"
    }
    
    public func tagListView(_ tagListView: TagListView, moveTagAt sourceIndex: Int, to destinationIndex: Int) {
    }
     */

}


