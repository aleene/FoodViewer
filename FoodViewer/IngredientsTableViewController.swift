//
//  IngredientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class IngredientsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    //fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate var tableStructure: [SectionType] = []
    
    fileprivate enum SectionType {
        case ingredients(Int, String)
        case ingredientsSearch(Int, String)
        case allergens(Int, String)
        case allergensSearch(Int, String)
        case traces(Int, String)
        case tracesSearch(Int, String)
        case labels(Int, String)
        case labelsSearch(Int, String)
        case additives(Int, String)
        case additivesSearch(Int, String)
        case image(Int, String)
        case imageSearch(Int, String)

        var header: String {
            switch self {
            case .ingredients(_, let headerTitle),
                 .ingredientsSearch(_, let headerTitle),
                 .allergens(_, let headerTitle),
                 .allergensSearch(_, let headerTitle),
                 .traces(_, let headerTitle),
                 .tracesSearch(_, let headerTitle),
                 .labels(_, let headerTitle),
                 .labelsSearch(_, let headerTitle),
                 .additives(_, let headerTitle),
                 .additivesSearch(_, let headerTitle),
                 .image(_, let headerTitle),
                 .imageSearch(_, let headerTitle):
                return headerTitle
            }
        }
        
        var numberOfRows: Int {
            switch self {
            case .ingredients(let numberOfRows, _),
                 .ingredientsSearch(let numberOfRows, _),
                 .allergens(let numberOfRows, _),
                 .allergensSearch(let numberOfRows, _),
                 .traces(let numberOfRows, _),
                 .tracesSearch(let numberOfRows, _),
                 .labels(let numberOfRows, _),
                 .labelsSearch(let numberOfRows, _),
                 .additives(let numberOfRows, _),
                 .additivesSearch(let numberOfRows, _),
                 .image(let numberOfRows, _),
                 .imageSearch(let numberOfRows, _):
                return numberOfRows
            }
        }
    }
    
    fileprivate var ingredientsImage: UIImage? = nil {
        didSet {
            refreshProduct()
        }
    }
    
// MARK: - Tags variables
    
    private struct TagsTypeDefault {
        static let Labels: TagsType = .translated
        static let Traces: TagsType = .translated
        static let Allergens: TagsType = .translated
        static let Additives: TagsType = .translated
    }
    
    // The interpreted labels have been translated to the interface language
    fileprivate var labelsTagsTypeToShow: TagsType = TagsTypeDefault.Labels
    fileprivate var tracesTagsTypeToShow: TagsType = TagsTypeDefault.Traces
    fileprivate var allergensTagsTypeToShow: TagsType = TagsTypeDefault.Allergens
    fileprivate var additivesTagsTypeToShow: TagsType = TagsTypeDefault.Additives
    

    fileprivate var allergensToDisplay: Tags {
        get {
            // is an updated product available? Is only relevant for the template
            if product != nil && delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.allergensOriginal {
                case .available, .empty:
                    allergensTagsTypeToShow = .edited
                    return delegate!.updatedProduct!.allergensOriginal
                default:
                    allergensTagsTypeToShow = TagsTypeDefault.Allergens
                }
            }

            switch allergensTagsTypeToShow {
            case .interpreted:
                return product!.allergensInterpreted
            case .hierarchy:
                return product!.allergensHierarchy
            case .translated:
                return product!.allergensTranslated
            case .original:
                return product!.allergensOriginal
            case .edited, .prefixed:
                return .undefined
            }
        }
    }
    
    fileprivate var searchAllergensToDisplay: Tags {
        get {
            if let (tags, _) = query?.allergens {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var tracesToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.tracesOriginal {
                case .available, .empty:
                    tracesTagsTypeToShow = .edited
                    return delegate!.updatedProduct!.tracesOriginal
                default:
                    break
                }
            }
            switch tracesTagsTypeToShow {
            case .interpreted:
                return product!.tracesInterpreted
            case .hierarchy:
                return product!.tracesHierarchy
            case .translated:
                return product!.tracesTranslated
            case .original:
                return product!.tracesOriginal
            case .edited, .prefixed:
                return .undefined
            }
        }
    }
    
    fileprivate var searchTracesToDisplay: Tags {
        get {
            if let (tags, _) = query?.traces {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var additivesToDisplay: Tags {
        get {
            // is an updated product available?
            if product != nil && delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.additivesOriginal {
                case .available, .empty:
                    additivesTagsTypeToShow = .edited
                    return delegate!.updatedProduct!.additivesOriginal
                default:
                    additivesTagsTypeToShow = TagsTypeDefault.Additives
                }
            }

            switch additivesTagsTypeToShow {
            case .interpreted:
                return product!.additivesInterpreted
            case .hierarchy, .edited, .original, .prefixed:
                return .undefined
            case .translated:
                return product!.additivesTranslated
            }
        }
    }
    
    fileprivate var searchAdditivesToDisplay: Tags {
        get {
            if let (tags, _) = query?.additives {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var labelsToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have edited labels defined?
                switch delegate!.updatedProduct!.labelsOriginal {
                case .available, .empty:
                    labelsTagsTypeToShow = .edited
                    return delegate!.updatedProduct!.labelsOriginal
                default:
                    break
                }
            }
            switch labelsTagsTypeToShow {
            case .interpreted:
                return product!.labelsInterpreted
            case .translated:
                return product!.translatedLabels()
            case .hierarchy:
                return product!.labelsHierarchy
                // return product!.translatedLabels().prefixed(withAdded:product!.primaryLanguageCode!, andRemoved:Locale.interfaceLanguageCode())
            case .original:
                return product!.labelsOriginal
            case .edited, .prefixed:
                return .undefined
            }
        }
    }

    fileprivate var searchLabelsToDisplay: Tags {
        get {
            if let (tags, _) = query?.labels {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var searchIngredientsToDisplay: Tags {
        get {
            if let tags = query?.ingredients {
                return tags
            }
            return .empty
        }
    }
    
    fileprivate var notSearchableToDisplay: Tags {
        get {
            return .notSearchable
        }
    }

    fileprivate var searchResult: String = ""
        
    private var selectedSection: Int? = nil

    // MARK: - Public variables
    
    public var tableItem: Any? = nil {
        didSet {
            if let item = tableItem as? FoodProduct {
                self.product = item
            } else if let item = tableItem as? SearchTemplate {
                self.query = item
            }
        }
    }
    

    fileprivate var product: FoodProduct? {
        didSet {
            if product != nil {
                ingredientsImage = nil
                tableStructure = setupSections()
                refreshProduct()
            }
        }
    }
    
    
    private var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                product = nil
                tableStructure = setupSections()
                refreshProduct()
            }
        }
    }
    
    private var isQuery: Bool {
        return query != nil
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
        struct CellIdentifier {
            static let Ingredients = "Ingredients Full Cell"
            static let TagListView = "TagListView Cell"
            static let TagListViewWithSegmentedControl = "TagListView With SegmentedControl Cell"
            static let Image = "Ingredients Image Cell"
            //static let NoImage = "No Image Cell"
            static let TagListViewAddImage = "Ingredients TagListView Add Image Cell"
        }
        
        struct SegueIdentifier {
            static let ShowIdentification = "Show Ingredients Image"
            static let SelectLanguage = "Show Ingredients Languages"
        }
        
        struct Nib {
            static let LanguageHeaderView = "LanguageHeaderView"
        }
        
        struct ReusableHeaderFooterView {
            static let Language = "LanguageHeaderView"
        }
    }
    
    fileprivate struct TextConstants {
        static let ShowIdentificationTitle = TranslatableStrings.Image
        static let ViewControllerTitle = TranslatableStrings.Ingredients
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = tableStructure[section].numberOfRows
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // we assume that product exists
        switch tableStructure[indexPath.section] {
            
        case .imageSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.editMode = false
            cell.tag = indexPath.section
            cell.tagListView.normalColorScheme = ColorSchemes.error
            return cell

        case .ingredients:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Ingredients, for: indexPath) as? IngredientsFullTableViewCell
            cell!.delegate = self
            cell!.textViewTag = indexPath.section
            cell!.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if let validCurrentLanguageCode = currentLanguageCode {
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
            
        case .ingredientsSearch:
            if query!.type == .advanced {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.editMode = false
                cell.tag = indexPath.section
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.delegate = self
                cell.editMode = editMode
                cell.tag = indexPath.section
                return cell
            }
            
        case .allergens, .additives:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.tag = indexPath.section
            return cell
            
        case .allergensSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.allergens.1 ?? true
            cell.allowInclusionEdit = query!.type != .simple
            return cell
            
        case .tracesSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.traces.1 ?? true
            cell.allowInclusionEdit = query!.type != .simple
            return cell
            
        case .additivesSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.additives.1 ?? true
            cell.allowInclusionEdit = query!.type != .simple
            return cell
            
        case .labelsSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.labels.1 ?? true
            cell.allowInclusionEdit = query!.type != .simple
            return cell
            
        case .traces, .labels:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            return cell
        
        case .image:
            if currentImage != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                cell.productImage = currentImage
                cell.delegate = self
                return cell
            } else {
                searchResult = ImageFetchResult.noImageAvailable.description
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewAddImage, for: indexPath) as! TagListViewAddImageTableViewCell
                cell.width = tableView.frame.size.width
                cell.scheme = ColorSchemes.error
                cell.editMode = editMode
                cell.datasource = self
                cell.delegate = self
                cell.tag = indexPath.section
                cell.accessoryType = .none
                return cell
            }
        }
    }
    
    private var currentImage: UIImage? {
        // are there any updated ingredient images?
        if delegate?.updatedProduct?.ingredientsImages != nil && !delegate!.updatedProduct!.ingredientsImages.isEmpty  {
            // Is there an updated image corresponding to the current language
            if let image = delegate!.updatedProduct!.ingredientsImages[currentLanguageCode!]!.original?.image {
                return image
            }
            
            // try the regular ingredient images
        } else if !product!.ingredientsImages.isEmpty {
            // is the data for the current language available?
            if let result = product!.ingredientsImages[currentLanguageCode!]?.display?.fetch() {
                switch result {
                case .available:
                    return product!.ingredientsImages[currentLanguageCode!]?.display?.image
                default:
                    break
                }
                // fall back to the primary languagecode ingredient image
                // if we are NOT in edit mode
            } else if !editMode,
                let primaryLanguageCode = product!.primaryLanguageCode,
                let result = product!.ingredientsImages[primaryLanguageCode]?.display?.fetch() {
                switch result {
                case .available:
                    return product!.ingredientsImages[primaryLanguageCode]?.display?.image
                default:
                    break
                }
            }
        }
        // No relevant image is available
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch tableStructure[section] {
        case .image, .ingredients:
            return nil
        case .imageSearch, .ingredientsSearch:
            return tableStructure[section].header
        case .allergens, .allergensSearch:
            switch allergensTagsTypeToShow {
            case TagsTypeDefault.Allergens:
                return tableStructure[section].header
            default:
                return tableStructure[section].header +
                    " " +
                    "(" +
                    allergensTagsTypeToShow.description() +
                    ")"
            }
        case .traces, .tracesSearch:
            switch tracesTagsTypeToShow {
            case TagsTypeDefault.Traces:
                return tableStructure[section].header
            default:
                return tableStructure[section].header +
                    " " +
                    "(" +
                    tracesTagsTypeToShow.description() +
                    ")"
            }
        case .labels, .labelsSearch:
            switch labelsTagsTypeToShow {
            case TagsTypeDefault.Labels:
                return tableStructure[section].header
            default:
                return tableStructure[section].header +
                    " " +
                    "(" +
                    labelsTagsTypeToShow.description() +
                    ")"
            }
        case .additives, .additivesSearch:
            switch additivesTagsTypeToShow {
            case TagsTypeDefault.Additives:
                return tableStructure[section].header
            default:
                return tableStructure[section].header +
                    " " +
                    "(" +
                    additivesTagsTypeToShow.description() +
                ")"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSection = indexPath.section
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        switch tableStructure[indexPath.section] {
        case .image, .ingredients:
            return indexPath
        default:
            break
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch tableStructure[section] {
        case .image, .ingredients :
            let header = tableStructure[section].header
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Storyboard.ReusableHeaderFooterView.Language) as! LanguageHeaderView
            
            headerView.section = section
            headerView.delegate = self
            headerView.title = header
            headerView.languageCode = currentLanguageCode
            headerView.buttonIsEnabled = editMode ? true : ( product!.languageCodes.count > 1 ? true : false )
            
            return headerView
        default:
            return nil
        }
    }

    fileprivate func nextLanguageCode() -> String {
        let currentIndex = (product?.languageCodes.index(of: currentLanguageCode!))!
        
        let nextIndex = currentIndex == ((product?.languageCodes.count)! - 1) ? 0 : (currentIndex + 1)
        return (product?.languageCodes[nextIndex])!
    }

    fileprivate struct TableSection {
        struct Size {
            static let Ingredients = 1
            static let Allergens = 1
            static let Traces = 1
            static let Additives = 1
            static let Labels = 1
            static let Image = 1
        }
        struct Header {
            static let Ingredients = TranslatableStrings.Ingredients
            static let Allergens = TranslatableStrings.Allergens
            static let Traces = TranslatableStrings.Traces
            static let Additives = TranslatableStrings.Additives
            static let Labels = TranslatableStrings.Labels
            static let Image = TranslatableStrings.IngredientsImage
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        
        if query != nil {
            sectionsAndRows.append(.ingredientsSearch(TableSection.Size.Ingredients, TableSection.Header.Ingredients))
            // not needed for .petFood and .beauty
            switch currentProductType {
            case .food:
                // 1:  allergens section
                sectionsAndRows.append(.allergensSearch(TableSection.Size.Allergens, TableSection.Header.Allergens))
                // 2: traces section
                sectionsAndRows.append(.tracesSearch(TableSection.Size.Traces, TableSection.Header.Traces))
            default :
                break
            }
            sectionsAndRows.append(.additivesSearch(TableSection.Size.Additives, TableSection.Header.Additives))
            sectionsAndRows.append(.labelsSearch(TableSection.Size.Labels, TableSection.Header.Labels))
            sectionsAndRows.append(.imageSearch(TableSection.Size.Image, TableSection.Header.Image))
            
        } else {
            sectionsAndRows.append(.ingredients(TableSection.Size.Ingredients, TableSection.Header.Ingredients))
            // not needed for .petFood and .beauty
            switch currentProductType {
            case .food:
                // 1:  allergens section
                sectionsAndRows.append(.allergens(TableSection.Size.Allergens, TableSection.Header.Allergens))
                // 2: traces section
                sectionsAndRows.append(.traces(TableSection.Size.Traces, TableSection.Header.Traces))
            default :
                break
            }
            sectionsAndRows.append(.additives(TableSection.Size.Additives, TableSection.Header.Additives))
            sectionsAndRows.append(.labels(TableSection.Size.Labels, TableSection.Header.Labels))
            sectionsAndRows.append(.image(TableSection.Size.Image, TableSection.Header.Image))
        }
        
        return sectionsAndRows
    }
    
    /*
    fileprivate func analyseProductForTable() -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        if isQuery {
            // 0: ingredients
            sectionsAndRows.append((SectionType.ingredientsSearch,
                                    TableSection.Size.Ingredients,
                                    TableSection.Header.Ingredients))

            // not needed for .petFood and .beauty
            switch currentProductType {
            case .food:
                // 1:  allergens section
                sectionsAndRows.append((
                    SectionType.allergensSearch,
                    TableSection.Size.Allergens,
                    TableSection.Header.Allergens))
                // 2: traces section
                sectionsAndRows.append((
                    SectionType.tracesSearch,
                    TableSection.Size.Traces,
                    TableSection.Header.Traces))
            default :
                break
            }
            
            
            // 3: additives section
            sectionsAndRows.append((
                SectionType.additivesSearch,
                TableSection.Size.Additives,
                TableSection.Header.Additives))
            
            // 4: labels section
            sectionsAndRows.append((
                SectionType.labelsSearch,
                TableSection.Size.Labels,
                TableSection.Header.Labels))
            
            // 5: image section
            sectionsAndRows.append((
                SectionType.imageSearch,
                TableSection.Size.Image,
                TableSection.Header.Image))

        } else {
            // 0: ingredients
            sectionsAndRows.append((SectionType.ingredients,
            TableSection.Size.Ingredients,
            TableSection.Header.Ingredients))
        
        
        // not needed for .petFood and .beauty
        switch currentProductType {
        case .food:
            // 1:  allergens section
            sectionsAndRows.append((
                SectionType.allergens,
                TableSection.Size.Allergens,
                TableSection.Header.Allergens))
            // 2: traces section
            sectionsAndRows.append((
                SectionType.traces,
                TableSection.Size.Traces,
                TableSection.Header.Traces))
        default :
            break
        }

    
        // 3: additives section
        sectionsAndRows.append((
            SectionType.additives,
            TableSection.Size.Additives,
            TableSection.Header.Additives))
        
        // 4: labels section
        sectionsAndRows.append((
            SectionType.labels,
            TableSection.Size.Labels,
            TableSection.Header.Labels))
        
        // 5: image section
            sectionsAndRows.append((
                SectionType.image,
                TableSection.Size.Image,
                TableSection.Header.Image))
        }
        return sectionsAndRows
    }
 */
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowIdentification:
                if let vc = segue.destination as? ImageViewController {
                    vc.imageTitle = TextConstants.ShowIdentificationTitle
                    if delegate?.updatedProduct?.ingredientsImages != nil && !delegate!.updatedProduct!.ingredientsImages.isEmpty {
                        vc.imageData = delegate!.updatedProduct!.image(for:currentLanguageCode!, of:.ingredients)
                    } else {
                        vc.imageData = product!.image(for:currentLanguageCode!, of:.ingredients)
                    }
                }
            case Storyboard.SegueIdentifier.SelectLanguage:
                if let vc = segue.destination as? SelectLanguageViewController {
                    // The segue can only be initiated from a button within a ProductNameTableViewCell
                    if let button = sender as? UIButton {
                        // The button should be in a view,
                        // which is in a TableHeaderFooterView,
                        // which is in a TableView
                        if button.superview?.superview?.superview as? UITableView != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                
                                vc.currentLanguageCode = currentLanguageCode
                                vc.languageCodes = product!.languageCodes
                                vc.updatedLanguageCodes = delegate?.updatedProduct != nil ? delegate!.updatedProduct!.languageCodes : []
                                vc.primaryLanguageCode = product?.primaryLanguageCode
                                vc.sourcePage = 1
                                vc.editMode = editMode
                            }
                        }
                    }
                }
            default: break
            }
        }
    }
    
    // function that defines a pixel on the bottom center of a frame
    private func leftMiddle(_ frame: CGRect) -> CGRect {
        var newFrame = frame
        newFrame.origin.y += frame.size.height / 2
        newFrame.size.height = 1
        newFrame.size.width = 1
        return newFrame
    }
    
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
//
// MARK: - Notification handler
//
    @objc func imageUpdated(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil && imageSectionIndex != nil else { return }
        // only update if the image barcode corresponds to the current product
        if product!.barcode.asString == userInfo![ProductImageData.Notification.BarcodeKey] as! String {
            if userInfo!.count == 1 {
                reloadImageSection()
                return
            }
            var imageTypeCategory: ImageTypeCategory? = nil
            var imageSizeCategory: ImageSizeCategory? = nil
            // We are only interested in medium-sized front images
            if let validValue = userInfo?[ProductImageData.Notification.ImageSizeCategoryKey] as? Int {
                imageSizeCategory = ImageSizeCategory(rawValue: validValue)
            }
            if let validValue = userInfo?[ProductImageData.Notification.ImageTypeCategoryKey] as? Int {
                imageTypeCategory = ImageTypeCategory(rawValue: validValue)
            }
            if imageSizeCategory != nil &&
                imageTypeCategory != nil &&
                imageSizeCategory! == .display && imageTypeCategory! == .ingredients {
                reloadImageSection()
            }
        }
    }

    @objc func reloadImageSection() { // (_ notification: Notification) {
        tableView.reloadSections([imageSectionIndex!], with: .none)
    }
    
    fileprivate var imageSectionIndex: Int? {
        for (index, sectionType) in tableStructure.enumerated() {
            switch sectionType {
            case .image:
                return index
            default:
                continue
            }
        }
        return nil
    }

    @objc func refreshProduct() {
        labelsTagsTypeToShow = TagsTypeDefault.Labels
        tracesTagsTypeToShow = TagsTypeDefault.Traces
        allergensTagsTypeToShow = TagsTypeDefault.Allergens
        additivesTagsTypeToShow = TagsTypeDefault.Additives
        tableView.reloadData()
    }
    
    @objc func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    func changeLanguage() {
        // set the next language in the array
        if currentLanguageCode != nextLanguageCode() {
            currentLanguageCode = nextLanguageCode()
            // reload the first row
            let indexPaths = [IndexPath.init(row: 0, section: 0)]
            tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.fade)
            tableView.deselectRow(at: indexPaths.first!, animated: true)
        }
    }
    
    func takePhoto() {
        // opens the camera and allows the user to take an image and crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.delegate = self
            imagePicker.imagePickerController?.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .camera
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
    
    func selectCameraRollPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .savedPhotosAlbum
            
            
            imagePicker.delegate = self
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()


    fileprivate func newImageSelected(info: [String : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if image != nil {
            delegate?.updated(ingredientsImage: image!, languageCode: currentLanguageCode!)
            tableView.reloadData()
        }
    }

    @objc func imageUploaded(_ notification: Notification) {
        guard !editMode else { return }
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessBarcodeKey] as? String {
            if barcode == product!.barcode.asString {
                // is it relevant to the ingredients image?
                if let id = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessImagetypeKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        OFFProducts.manager.reload(self.product!)
                    }
                }
            }
        }
    }
    
    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageDeleteSuccessBarcodeKey] as? String {
            if barcode == product!.barcode.asString {
                // is it relevant to the ingredients image?
                if let id = notification.userInfo?[OFFUpdate.Notification.ImageDeleteSuccessImagetypeKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        OFFProducts.manager.reload(self.product!)
                    }
                }
            }
        }
    }


    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        // For custom tableView headers
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = TextConstants.ViewControllerTitle
        // print("ing viewWillAppear", self.view.frame, self.parent?.view.frame)

        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageUploaded(_:)), name:.OFFUpdateImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.imageDeleted(_:)), name:.OFFUpdateImageDeleteSuccess, object:nil)
        // NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.changeTagsTypeToShow), name:.TagListViewTapped, object:nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // print("ing didAppear", self.view.frame, self.parent?.view.frame)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - TagListViewCellDelegate Functions

extension IngredientsTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that the switch changed
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that the switch changed
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
        switch tableStructure[tagListView.tag] {
        case .labels:
            labelsTagsTypeToShow.cycle()
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        case .traces:
            tracesTagsTypeToShow.cycle()
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        case .allergens:
            allergensTagsTypeToShow.cycle()
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        case .additives:
            additivesTagsTypeToShow.cycle()
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        default:
            break
        }
    }
}

// MARK: - IngredientsImageCellDelegate Delegate Functions

extension IngredientsTableViewController: ProductImageCellDelegate {
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton) {
        guard currentLanguageCode != nil else { return }
        guard product != nil else { return }
        let update = OFFUpdate()
        update.deselect([currentLanguageCode!], of: .ingredients, for: product!)
    }

}


// MARK: - TagListViewAddImageCellDelegate functions

extension IngredientsTableViewController: TagListViewAddImageCellDelegate {
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
}

// MARK: - IngredientsFullCellDelegate Delegate Functions

extension IngredientsTableViewController: IngredientsFullCellDelegate {
    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, receivedActionOn textView:UITextView) {
        changeLanguage()
    }

}

// MARK: - TagListViewSegmentedControlCellDelegate Delegate Functions

extension IngredientsTableViewController: TagListViewSegmentedControlCellDelegate {
    
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl: UISegmentedControl) {
        let inclusion = segmentedControl.selectedSegmentIndex == 0 ? false : true
        
        switch tableStructure[sender.tag] {
        case .labelsSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.labels.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .tracesSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.traces.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .additivesSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.additives.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .allergensSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.allergens.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        default:
            break
        }
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
        switch tableStructure[textView.tag] {
        case .ingredients:
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
        switch tableStructure[tagListView.tag] {
        case .traces:
            switch tracesToDisplay {
            case .undefined, .empty:
                delegate?.update(tracesTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(tracesTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .tracesSearch:
            switch searchTracesToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.traces.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.traces.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .ingredientsSearch:
            switch searchIngredientsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.ingredients = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.ingredients = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .labels:
            switch labelsToDisplay {
            case .undefined, .empty:
                delegate?.update(labelTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(labelTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .labelsSearch:
            switch searchLabelsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.labels.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.labels.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .additivesSearch:
            switch searchAdditivesToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.additives.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.additives.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .allergensSearch:
            switch searchAllergensToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.allergens.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.allergens.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }

        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        switch tableStructure[tagListView.tag] {
        case .traces:
            switch tracesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(tracesTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .tracesSearch:
            switch searchTracesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.traces.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .ingredientsSearch:
            switch searchIngredientsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.ingredients = Tags.init(list:list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }

        case .labels:
            switch labelsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(labelTags: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .labelsSearch:
            switch searchLabelsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.labels.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .additivesSearch:
            switch searchAdditivesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.additives.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .allergensSearch:
            switch searchAllergensToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.allergens.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }

        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        switch tableStructure[tagListView.tag] {
        case .allergens:
            switch product!.allergensInterpreted {
            case .available:
                delegate?.search(for: product!.allergensInterpreted.tag(at: index), in: .allergen)
            default:
                break
            }
        case .traces:
            // the taxonomy key is used to define the search value
            switch product!.tracesInterpreted {
            case .available:
                delegate?.search(for: product!.tracesInterpreted.tag(at: index), in: .trace)
            default:
                break
            }
            // OFF does not allow searching by additive at the moment
//        case .additives:
//            switch product!.additivesInterpreted {
//            case .available:
//                let rawTag = product!.additivesInterpreted.tag(at: index)
//                OFFProducts.manager.searchValue = rawTag
//                OFFProducts.manager.search = OFF.SearchComponent.additive
//                OFFProducts.manager.list = .search
//            default:
//                break
//            }
        case .labels:
            switch product!.labelsInterpreted {
            case .available:
                delegate?.search(for: product!.labelsInterpreted.tag(at: index), in: .label)
            default:
                break
            }
        default:
            break
        }
    }

}

// MARK: - TagListView DataSource Functions

extension IngredientsTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            case .notSearchable:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            }
        }

        switch tableStructure[tagListView.tag] {
        case .imageSearch:
            return 1
        case .additives:
            return count(additivesToDisplay)
        case .additivesSearch:
            return count(searchAdditivesToDisplay)
        case .allergens:
            return count(allergensToDisplay)
        case .allergensSearch:
            return count(searchAllergensToDisplay)
        case .labels:
            return count(labelsToDisplay)
        case .labelsSearch:
            return count(searchLabelsToDisplay)
        case .image:
            return 1
        case .ingredientsSearch:
            return count(searchIngredientsToDisplay)
        case .traces:
            return count(tracesToDisplay)
        case .tracesSearch:
            return count(searchTracesToDisplay)
        default: break
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        switch tableStructure[tagListView.tag] {
        case .additives:
            return additivesToDisplay.tag(at:index)!
        case .additivesSearch:
            return searchAdditivesToDisplay.tag(at:index)!
        case .allergens:
            return allergensToDisplay.tag(at:index)!
        case .allergensSearch:
            return searchAllergensToDisplay.tag(at:index)!
        case .image:
            return searchResult
        case .imageSearch:
            return notSearchableToDisplay.tag(at:index)!
        case .ingredientsSearch:
            return searchIngredientsToDisplay.tag(at: index)!
        case .labels:
            return labelsToDisplay.tag(at:index)!
        case .labelsSearch:
            return searchLabelsToDisplay.tag(at:index)!
        case .traces:
            return tracesToDisplay.tag(at:index)!
        case .tracesSearch:
            return searchTracesToDisplay.tag(at:index)!
        default: break
        }
        return("tagListView error")
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }

    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        switch tableStructure[tagListView.tag] {
        case .additivesSearch:
            switch searchAdditivesToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.additives.0 = .available(list)
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .allergensSearch:
            switch searchAllergensToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.allergens.0 = .available(list)
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .ingredientsSearch:
            switch searchIngredientsToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.ingredients = .available(list)
            default:
                assert(true, "How can I delete a tag when there are none")
            }
        case .labels:
            switch labelsToDisplay {
            case .available(var list):
                list.removeAll()
                delegate?.update(labelTags: list)
            default:
                assert(true, "How can I delete a tag when there are none")
            }
        case .labelsSearch:
            switch searchLabelsToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.labels.0 = .available(list)
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .traces:
            switch tracesToDisplay {
            case .available(var list):
                list.removeAll()
                delegate?.update(labelTags: list)
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .tracesSearch:
            switch searchTracesToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.traces.0 = .available(list)
            default:
                assert(true, "How can I clear a tag when there are none")
            }

        default:
            break
        }
    }
    

}

// MARK: - UINavigationControllerDelegate Functions


extension IngredientsTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
        // notify the delegate
    }
    
}


extension IngredientsTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        delegate?.updated(ingredientsImage: image, languageCode: currentLanguageCode!)
        tableView.reloadData()
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LanguageHeaderDelegate Functions

extension IngredientsTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectLanguage, sender: sender)
    }
}

// MARK: - UIDragInteractionDelegate Functions

@available(iOS 11.0, *)
extension IngredientsTableViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }

    private func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard currentLanguageCode != nil else { return [] }
        var productImageData: ProductImageData? = nil
        // is there image data?
        if delegate?.updatedProduct?.ingredientsImages != nil && !delegate!.updatedProduct!.ingredientsImages.isEmpty {
            productImageData = delegate!.updatedProduct!.image(for:currentLanguageCode!, of:.ingredients)
        } else {
            productImageData = product!.image(for:currentLanguageCode!, of:.ingredients)
        }
        // The largest image here is the display image, as the url for the original front image is not offered by OFF in an easy way
        guard productImageData != nil else { return [] }
        
        guard let validProductImageData = productImageData else { return [] }
        
        // only allow flocking of another productImageSize
        for item in session.items {
            // Note kUTTypeImage is defined in MobileCoreServices, so need to import
            // This is an image, as that is what I offer to export
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        
        switch tableStructure[indexPath.section] {
        case .image :
            // check if the selected image has not been added yet
            for item in session.items {
                guard item.localObject as! ProductImageData != validProductImageData else { return [] }
            }
            let provider = NSItemProvider(object: validProductImageData)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        default:
            break
        }
        return []
    }
    
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        switch tableStructure[indexPath.section] {
        case .image :
            if let cell = tableView.cellForRow(at: indexPath) as? ProductImageTableViewCell,
                let rect = cell.productImageView.imageRect {
                let parameters = UIDragPreviewParameters.init()
                parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
                return parameters
            }
        default:
            break
        }
        return nil
        
    }
}

// MARK: - UITableViewDropDelegate Functions

@available(iOS 11.0, *)
extension IngredientsTableViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        func setImage(image: UIImage) {
            let cropController = GKImageCropViewController.init()
            cropController.sourceImage = image
            cropController.view.frame = tableView.frame
            //cropController.preferredContentSize = picker.preferredContentSize
            cropController.hasResizableCropArea = true
            cropController.cropSize = CGSize.init(width: 300, height: 300)
            cropController.delegate = self
            cropController.modalPresentationStyle = .fullScreen
            
            present(cropController, animated: true, completion: nil)
            if let popoverPresentationController = cropController.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
        
        guard currentLanguageCode != nil else { return }
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            // Only one image is accepted as ingredients image for the current language
            if let validImage = (images as? [UIImage])?.first {
                setImage(image: validImage)
                //self.delegate?.updated(frontImage: validImage, languageCode:self.currentLanguageCode!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // Only accept if an image is hovered above the image section
        if let validIndexPathSection = destinationIndexPath?.section {
            switch tableStructure[validIndexPathSection] {
            case .image :
                return editMode ? UITableViewDropProposal(operation: .copy, intent: .unspecified) : UITableViewDropProposal(operation: .forbidden, intent: .unspecified)
            default:
                break
            }
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)

    }
}


// MARK: - GKImageCropController Delegate Methods

extension IngredientsTableViewController: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        guard let validLanguage = currentLanguageCode,
            let validImage = croppedImage else { return }
        imageCropController.dismiss(animated: true, completion: nil)
        self.delegate?.updated(ingredientsImage: validImage, languageCode:validLanguage)
        self.reloadImageSection()
    }
}




