//
//  AddSearchQueryTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 13/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class AddSearchQueryTableViewController: UITableViewController {

    var search: Search? = nil
    
    fileprivate var searchBarcodeToDisplay: Tags {
        get {
            if let validBarcodeString = search?.query?.barcode?.asString {
                return Tags(string: validBarcodeString)
            }
            return .undefined
        }
    }

    fileprivate var searchBrandsToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.brands {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var notSearchableToDisplay: Tags {
        get {
            return .notSearchable
        }
    }
    
    fileprivate var searchPackagingToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.packaging {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchAllergensToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.allergens {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchTracesToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.traces {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var searchAdditivesToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.additives {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var searchLabelsToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.labels {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var searchLanguagesToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.languages {
                return tags
            }
            return .undefined
        }
    }

    
    // The search names are stored a string, not tags
    fileprivate var searchTextToDisplay: Tags {
        get {
            if let validText = search?.query?.text {
                return Tags(string: validText)
            }
            return .undefined
        }
    }

    fileprivate var searchProducerTagsToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.manufacturing_places {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchProducerCodeTagsToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.emb_codes {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchIngredientOriginLocationTagsToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.origins {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchPurchaseLocationTagsToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.purchase_places {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchStoreTagsToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.stores {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchCountriesToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.countries {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchCategoriesToDisplay: Tags {
        get {
            if let (tags, _) = search?.query?.categories {
                return tags
            }
            return .undefined
        }
    }

    // MARK: - Table view data source

    fileprivate var tableStructure: [SectionType] = []

    fileprivate enum SectionType {
        case barcodeSearch(Int, String)
        case textSearch(Int, String)
        case languagesSearch(Int, String)
        case brandsSearch(Int, String)
        case packagingSearch(Int, String)
        //case quantitySearch(Int, String) // not supported by OFF
        //case ingredientsSearch(Int, String) is free text
        case allergensSearch(Int, String)
        case tracesSearch(Int, String)
        case labelsSearch(Int, String)
        case additivesSearch(Int, String)
        case ingredientOriginSearch(Int, String)
        case producerSearch(Int, String)
        case producerCodeSearch(Int, String)
        case locationSearch(Int, String)
        case storeSearch(Int, String)
        case countrySearch(Int, String)
        case categorySearch(Int, String)

        var header: String {
            switch self {
            case .barcodeSearch(_, let headerTitle),
                 .textSearch(_, let headerTitle),
                 .languagesSearch(_, let headerTitle),
                 .brandsSearch(_, let headerTitle),
                 .packagingSearch(_, let headerTitle),
                //.quantitySearch(_, let headerTitle),
                //.ingredientsSearch(_, let headerTitle),
                .allergensSearch(_, let headerTitle),
                .tracesSearch(_, let headerTitle),
                .labelsSearch(_, let headerTitle),
                .additivesSearch(_, let headerTitle),
                .ingredientOriginSearch(_, let headerTitle),
                .producerSearch(_, let headerTitle),
                .producerCodeSearch(_, let headerTitle),
                .locationSearch(_, let headerTitle),
                .storeSearch(_, let headerTitle),
                .categorySearch(_, let headerTitle),
                .countrySearch(_, let headerTitle):
                return headerTitle
            }
        }
        var numberOfRows: Int {
            switch self {
            case .barcodeSearch(let numberOfRows, _),
                 .textSearch(let numberOfRows, _),
                 .languagesSearch(let numberOfRows, _),
                 .brandsSearch(let numberOfRows, _),
                 .packagingSearch(let numberOfRows, _),
                 .allergensSearch(let numberOfRows, _),
                 .tracesSearch(let numberOfRows, _),
                 .labelsSearch(let numberOfRows, _),
                 .additivesSearch(let numberOfRows, _),
                 .ingredientOriginSearch(let numberOfRows, _),
                 .producerSearch(let numberOfRows, _),
                 .producerCodeSearch(let numberOfRows, _),
                 .locationSearch(let numberOfRows, _),
                 .storeSearch(let numberOfRows, _),
                 .categorySearch(let numberOfRows, _),
                 .countrySearch(let numberOfRows, _):
                //.quantitySearch(let numberOfRows, _),
                return numberOfRows
            }
        }
    }

    fileprivate struct TableSection {
        struct Size {
            static let Barcode = 1
            static let Name = 1
            static let CommonName = 1
            static let Languages = 1
            static let Brands = 1
            static let Packaging = 1
            static let Ingredients = 1
            static let Allergens = 1
            static let Traces = 1
            static let Additives = 1
            static let Labels = 1
            static let Producer = 1
            static let ProducerCode = 1
            static let IngredientOrigin = 1
            static let Location = 1
            static let Countries = 1
            static let Stores = 1
            static let Categories = 1
        }
        struct Header {
            static let Barcode = TranslatableStrings.Barcode
            static let Name = TranslatableStrings.Name
            static let CommonName = TranslatableStrings.GenericName
            static let Languages = TranslatableStrings.Languages
            static let Brands = TranslatableStrings.Brands
            static let Packaging = TranslatableStrings.Packaging
            static let Ingredients = TranslatableStrings.Ingredients
            static let Allergens = TranslatableStrings.DetectedAllergens
            static let Traces = TranslatableStrings.Traces
            static let Additives = TranslatableStrings.DetectedAdditives
            static let Labels = TranslatableStrings.Labels
            static let Producer = TranslatableStrings.Producer
            static let ProducerCode = TranslatableStrings.ProductCodes
            static let IngredientOrigin = TranslatableStrings.IngredientOrigins
            static let Location = TranslatableStrings.PurchaseAddress
            static let Countries = TranslatableStrings.SalesCountries
            static let Stores = TranslatableStrings.Stores
            static let Categories = TranslatableStrings.Categories
        }
    }

    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    private var cellHeights: [Int:CGFloat] = [:]

    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        var row = 0
        sectionsAndRows.append(.barcodeSearch(TableSection.Size.Barcode, TableSection.Header.Barcode))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1
        
        sectionsAndRows.append(.textSearch(TableSection.Size.Name, TableSection.Header.Name))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        sectionsAndRows.append(.languagesSearch(TableSection.Size.Languages, TableSection.Header.Languages))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

         sectionsAndRows.append(.brandsSearch(TableSection.Size.Brands, TableSection.Header.Brands))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

         sectionsAndRows.append(.packagingSearch(TableSection.Size.Packaging, TableSection.Header.Packaging))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        //sectionsAndRows.append(.ingredientsSearch(TableSection.Size.Ingredients, TableSection.Header.Ingredients))
        // not needed for .petFood, .product and .beauty
        switch currentProductType {
        case .food:
            // 1:  allergens section
            sectionsAndRows.append(.allergensSearch(TableSection.Size.Allergens, TableSection.Header.Allergens))
            cellHeights[row] = Constants.Cell.DefaultHeight
            row += 1

            // 2: traces section
            sectionsAndRows.append(.tracesSearch(TableSection.Size.Traces, TableSection.Header.Traces))
            cellHeights[row] = Constants.Cell.DefaultHeight
            row += 1
            
        default :
            break
        }
        sectionsAndRows.append(.additivesSearch(TableSection.Size.Additives, TableSection.Header.Additives))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        sectionsAndRows.append(.labelsSearch(TableSection.Size.Labels, TableSection.Header.Labels))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        // ingredient origin section
        //sectionsAndRows.append((
        sectionsAndRows.append(.ingredientOriginSearch(TableSection.Size.IngredientOrigin, TableSection.Header.IngredientOrigin))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        // producer section
        sectionsAndRows.append(.producerSearch(TableSection.Size.Producer, TableSection.Header.Producer))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        // producer codes section
        sectionsAndRows.append(.producerCodeSearch(TableSection.Size.ProducerCode, TableSection.Header.ProducerCode))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        // stores section
        sectionsAndRows.append(.storeSearch(TableSection.Size.Stores, TableSection.Header.Stores))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        // purchase Location section
        sectionsAndRows.append(.locationSearch(TableSection.Size.Location, TableSection.Header.Location))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        // countries section
        sectionsAndRows.append(.countrySearch(TableSection.Size.Countries, TableSection.Header.Countries))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        sectionsAndRows.append(.categorySearch(TableSection.Size.Categories, TableSection.Header.Categories))
        cellHeights[row] = Constants.Cell.DefaultHeight
        row += 1

        return sectionsAndRows
    }

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let Name = "Add Search TextView With Clear Button Cell Identifier"
            static let Barcode = "Add Search TextField Control Cell Identifier"
            static let TagListView = "Add Search TagListView Cell Identifier"
            static let TagListViewWithSegmentedControl = "Add Search TagListView With SegmentedControl Cell Identifier"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableStructure[section].numberOfRows
    }

    fileprivate struct Constants {
        struct Cell {
            static let DefaultHeight = CGFloat(44.0)
            static let HeightChangeTrigger = CGFloat(3.0)
        }
        static let CellContentViewMargin = CGFloat(8)
        static let CellContentViewMarginSegmentedControl = CGFloat(100)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableStructure[indexPath.section] {
        case .barcodeSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Barcode, for: indexPath) as! BarcodeEditTableViewCell
            cell.barcode = search?.query?.barcode
            cell.editMode = true
            cell.tag = indexPath.section
            cell.barcodeTextField.placeholder = TranslatableStrings.Barcode
            // cell.datasource = self
            cell.delegate = self
            return cell

        case .textSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: self, editMode: true, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: nil)

            return cell
            
        case .brandsSearch,
             .languagesSearch,
             .packagingSearch,
             .allergensSearch,
             .tracesSearch,
             .labelsSearch,
             .additivesSearch,
             .ingredientOriginSearch,
             .producerSearch,
             .producerCodeSearch,
             .locationSearch,
             .storeSearch,
             .countrySearch,
             .categorySearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            var inclusion = false
            switch tableStructure[indexPath.section] {
            case .brandsSearch:
                inclusion = search?.query?.brands.1 ?? true
            case .languagesSearch:
                inclusion = search?.query?.languages.1 ?? true
            case .packagingSearch:
                inclusion = search?.query?.packaging.1 ?? true
            case .allergensSearch:
                inclusion = search?.query?.allergens.1 ?? true
            case .tracesSearch:
                inclusion = search?.query?.traces.1 ?? true
            case .labelsSearch:
                inclusion = search?.query?.labels.1 ?? true
            case .additivesSearch:
                inclusion = search?.query?.additives.1 ?? true
            case .ingredientOriginSearch:
                inclusion = search?.query?.origins.1 ?? true
            case .producerSearch:
                inclusion = search?.query?.manufacturing_places.1 ?? true
            case .producerCodeSearch:
                inclusion = search?.query?.emb_codes.1 ?? true
            case .locationSearch:
                inclusion = search?.query?.purchase_places.1 ?? true
            case .storeSearch:
                inclusion = search?.query?.stores.1 ?? true
            case .countrySearch:
                inclusion = search?.query?.countries.1 ?? true
            case .categorySearch:
                inclusion = search?.query?.categories.1 ?? true
            case .barcodeSearch,
                 .textSearch:
                break
            }
            cell.setup(datasource: self, delegate: self, editMode: true, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: nil, inclusion: inclusion, inclusionEditAllowed:true)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStructure[section].header
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.section] ?? Constants.Cell.DefaultHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create an empty search on start
        if search == nil {
            search = Search.init()
        }
        tableStructure = setupSections()
        title = "Define Search"
        tableView.allowsSelection = true
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
        OFFplists.manager.flush()
    }

}

//
// MARK: - TagListView DataSource Functions
//
extension AddSearchQueryTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return 0
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return 0
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            case .notSearchable:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            }
        }
        
        let currentProductSection = tableStructure[tagListView.tag]
        
        switch currentProductSection {
        case .barcodeSearch:
            return count(searchBarcodeToDisplay)
        case .textSearch:
            return count(searchTextToDisplay)
        case .brandsSearch:
            return count(searchBrandsToDisplay)
        case .packagingSearch:
            return count(searchPackagingToDisplay)
        case .languagesSearch:
           return count(searchLanguagesToDisplay)
        case .allergensSearch:
            return count(searchAllergensToDisplay)
        case .tracesSearch:
            return count(searchTracesToDisplay)
        case .labelsSearch:
            return count(searchLabelsToDisplay)
        case .additivesSearch:
            return count(searchAdditivesToDisplay)
        case .ingredientOriginSearch:
            return count(searchIngredientOriginLocationTagsToDisplay)
        case .producerSearch:
            return count(searchProducerTagsToDisplay)
        case .producerCodeSearch:
            return count(searchProducerCodeTagsToDisplay)
        case .locationSearch:
            return count(searchPurchaseLocationTagsToDisplay)
        case .storeSearch:
            return count(searchStoreTagsToDisplay)
        case .countrySearch:
            return count(searchCountriesToDisplay)
        case .categorySearch:
            return count(searchCategoriesToDisplay)
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        // print("height", tagListView.frame.size.height)
        
        func title(_ tags: Tags) -> String {
            switch tags {
            case .undefined, .empty, .notSearchable:
                return tags.description()
            case .available:
                return tags.tag(at:index) ?? "AddSearchQueryTableViewController: Tag index out of bounds"
            }
        }
        
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
            //case .quantitySearch, .imageSearch:
            //   return title(notSearchableToDisplay)
        case .barcodeSearch:
            return title(searchBarcodeToDisplay)
        case .textSearch:
            return title(searchTextToDisplay)
        case .brandsSearch:
            return title(searchBrandsToDisplay)
        case .packagingSearch:
            return title(searchPackagingToDisplay)
        case .languagesSearch:
            return title(searchLanguagesToDisplay)
        case .allergensSearch:
            return title(searchAllergensToDisplay)
        case .tracesSearch:
            return title(searchTracesToDisplay)
        case .labelsSearch:
            return title(searchLabelsToDisplay)
        case .additivesSearch:
            return title(searchAdditivesToDisplay)
        case .ingredientOriginSearch:
            return title(searchAdditivesToDisplay)
        case .producerSearch:
            return title(searchProducerTagsToDisplay)
        case .producerCodeSearch:
            return title(searchProducerCodeTagsToDisplay)
        case .locationSearch:
            return title(searchPurchaseLocationTagsToDisplay)
        case .storeSearch:
            return title(searchStoreTagsToDisplay)
        case .countrySearch:
            return title(searchCountriesToDisplay)
        case .categorySearch:
            return title(searchCategoriesToDisplay)
        }
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
}
//
// MARK: - TagListViewDelegate Functions
//
extension AddSearchQueryTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {

    }
    
    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .brandsSearch:
            switch searchBrandsToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.brands.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .barcodeSearch:
            switch searchBarcodeToDisplay {
            case .available(var list):
                guard list.first != nil else { return }
                list.removeAll()
                search?.query?.barcode = BarcodeType(barcodeString: list.first!, type: Preferences.manager.showProductType)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .textSearch:
            switch searchBarcodeToDisplay {
            case .available(var list):
                guard list.first != nil else { return }
                list.removeAll()
                search?.query?.text = list.first!
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .languagesSearch:
            switch searchLanguagesToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.languages.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
        case .packagingSearch:
            switch searchPackagingToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.packaging.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
        case .allergensSearch:
            switch searchAllergensToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.allergens.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .tracesSearch:
            switch searchTracesToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.traces.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .labelsSearch:
            switch searchLabelsToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.labels.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .additivesSearch:
            switch searchAdditivesToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.additives.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .ingredientOriginSearch:
            switch searchIngredientOriginLocationTagsToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.origins.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .producerSearch(_, _):
            switch searchProducerTagsToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.manufacturing_places.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .producerCodeSearch:
            switch searchProducerCodeTagsToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.emb_codes.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .locationSearch:
            switch searchPurchaseLocationTagsToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.purchase_places.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .storeSearch:
            switch searchStoreTagsToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.stores.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        case .countrySearch:
            switch searchCountriesToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.countries.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
        case .categorySearch:
            switch searchCategoriesToDisplay {
            case .available(var list):
                list.removeAll()
                search?.query?.categories.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I clear a tag when there are none")
            }
            
        }
    }
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tableStructure[tagListView.tag] {
        case .brandsSearch:
            switch searchBrandsToDisplay {
            case .undefined, .empty:
                search?.query?.brands.0 = .available([title])
            case .available(var list):
                list.append(title)
                search?.query?.brands.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }
        case .barcodeSearch:
            switch searchBarcodeToDisplay {
            case .undefined, .empty:
                search?.query?.barcode = nil
            case .available(let list):
                guard let validBarcode = list.first else { return }
                search?.query?.barcode = BarcodeType(barcodeString: validBarcode, type: Preferences.manager.showProductType)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }
        case .textSearch:
            switch searchTextToDisplay {
            case .undefined, .empty:
                search?.query?.text = title
            case .available(let list):
                search?.query?.text = list.first
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .languagesSearch:
            switch searchLanguagesToDisplay {
            case .undefined, .empty:
                search?.query?.languages.0 = .available([title])
            case .available(var list):
                list.append(title)
                search?.query?.languages.0 = .available(list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a search languages tag when the field is non-editable")
            }
        case .packagingSearch:
            switch searchPackagingToDisplay {
            case .undefined, .empty:
                search?.query?.packaging.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.packaging.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }
        case .allergensSearch:
            switch searchAllergensToDisplay {
            case .undefined, .empty:
                search?.query?.allergens.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.allergens.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .tracesSearch:
            switch searchTracesToDisplay {
            case .undefined, .empty:
                search?.query?.traces.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.traces.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .labelsSearch:
            switch searchLabelsToDisplay {
            case .undefined, .empty:
                search?.query?.labels.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.labels.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .additivesSearch:
            switch searchAdditivesToDisplay {
            case .undefined, .empty:
                search?.query?.additives.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.additives.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .ingredientOriginSearch:
            switch searchIngredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                search?.query?.origins.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.origins.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .producerSearch:
            switch searchProducerTagsToDisplay {
            case .undefined, .empty:
                search?.query?.manufacturing_places.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.manufacturing_places.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .producerCodeSearch:
            switch searchProducerCodeTagsToDisplay {
            case .undefined, .empty:
                search?.query?.emb_codes.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.emb_codes.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .locationSearch:
            switch searchPurchaseLocationTagsToDisplay {
            case .undefined, .empty:
                search?.query?.purchase_places.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.purchase_places.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .storeSearch:
            switch searchStoreTagsToDisplay {
            case .undefined, .empty:
                search?.query?.stores.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.stores.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        case .countrySearch:
            switch searchCountriesToDisplay {
            case .undefined, .empty:
                search?.query?.countries.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.countries.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }
            
        case .categorySearch:
            switch searchCategoriesToDisplay {
            case .undefined, .empty:
                search?.query?.categories.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                search?.query?.categories.0 = Tags.init(list:list)
            default:
                assert(true, "AddSearchQueryTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        }
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .brandsSearch:
            switch searchBrandsToDisplay {
            case .undefined, .empty:
            assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.brands.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
                }
            
        case .barcodeSearch:
            switch searchBarcodeToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.barcode = nil
            case .notSearchable:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }
            
        case .textSearch:
            switch searchTextToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available:
                search?.query?.text = nil
            case .notSearchable:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }

        case .packagingSearch:
            switch searchPackagingToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
            search?.query?.packaging.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }
        case .languagesSearch:
            switch searchLanguagesToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.languages.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .allergensSearch:
            switch searchAllergensToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.allergens.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .tracesSearch:
            switch searchTracesToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.traces.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .labelsSearch:
            switch searchLabelsToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.labels.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .additivesSearch:
            switch searchAdditivesToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.additives.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .ingredientOriginSearch:
            switch searchIngredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.origins.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .producerSearch:
            switch searchProducerTagsToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.manufacturing_places.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .producerCodeSearch:
            switch searchProducerCodeTagsToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.emb_codes.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .locationSearch:
            switch searchPurchaseLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.purchase_places.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .storeSearch:
            switch searchStoreTagsToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.stores.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        case .countrySearch:
            switch searchCountriesToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.countries.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }
        case .categorySearch:
            switch searchCategoriesToDisplay {
            case .undefined, .empty:
                assert(true, "AddSearchQueryTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                search?.query?.categories.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "AddSearchQueryTableViewController: How can I add a tag when the field is non-editable")
            }

        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        if abs(height - (cellHeights[tagListView.tag] ?? Constants.Cell.DefaultHeight)) > Constants.Cell.HeightChangeTrigger {
            cellHeights[tagListView.tag] = height
            tableView.setNeedsDisplay()
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        // no action
    }
    
}

//
// MARK: - TagListViewSegmentedControlCellDelegate Functions
//
extension AddSearchQueryTableViewController: TagListViewSegmentedControlCellDelegate {
    
    // function to let the delegate know that the switch changed
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
        
    }
}

//
// MARK: - ProductNameCellDelegate Delegate Functions
//
extension AddSearchQueryTableViewController:  ProductNameCellDelegate {
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedDoubleTap textView:UITextView) {
        // no action required
    }
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedTapOn button:UIButton) {
        // no action required
    }

}


//
// MARK: - TagListViewCellDelegate Functions
//
extension AddSearchQueryTableViewController: BarcodeEditCellDelegate {
    
    // function to let the delegate know that the switch changed
    func barcodeEditTableViewCell(_ sender: BarcodeEditTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
        if let validCode = search?.query?.barcode?.asString,
            let validProductType = search?.query?.barcode?.productType {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                search!.query!.barcode = .ean8(validCode, validProductType)
            case 1:
                search!.query!.barcode = .upc12(validCode, validProductType)
            case 2:
                search!.query!.barcode = .ean13(validCode, validProductType)
            default:
                break
            }
        }
    }
}

//
// MARK: - UITextField Delegate Functions
//
extension AddSearchQueryTableViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        
        let newText = oldText.replacingCharacters(in: r, with: string)
        if newText.isEmpty || (Double(newText) != nil) {
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let currentProductSection = tableStructure[textField.tag]
        switch currentProductSection {
        case .barcodeSearch:
            // barcode updated?
            if let validText = textField.text {
                if validText.count == 8 {
                    search?.query?.barcode = BarcodeType.ean8(validText, Preferences.manager.showProductType)
                } else if validText.count == 12 {
                    search?.query?.barcode = BarcodeType.upc12(validText, Preferences.manager.showProductType)
                } else if validText.count == 13 {
                    search?.query?.barcode = BarcodeType.ean13(validText, Preferences.manager.showProductType)
                }
            }
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let currentProductSection = tableStructure[textField.tag]
        switch currentProductSection {
        case .barcodeSearch:
            return true
        default:
            break
        }
        return false
    }
    
}
//
// MARK: - TagListViewCellDelegate Functions
//
extension AddSearchQueryTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}
