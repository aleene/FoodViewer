//
//  CategoriesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    // MARK: - Public functions / variables
    
    public var tableItem: ProductPair? = nil {
        didSet {
            if let item = tableItem?.barcodeType {
                switch item {
                case .search(let template, _):
                    self.query = template
                default:
                    self.productPair = tableItem
                }
            }
        }
    }

    fileprivate var productPair: ProductPair? {
        didSet {
            if productPair != nil {
                tableStructureForProduct = setupTableSections()
                tableView.reloadData()
            }
        }
    }
    
    private var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                tableStructureForProduct = setupTableSections()
                tableView.reloadData()
            }
        }
    }
    
    private var isQuery: Bool {
        return query != nil
    }

    var editMode = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    var delegate: ProductPageViewController? = nil

    // MARK: - Private Functions / Variables
    
    
    fileprivate enum ProductVersion {
        case local
        case remote
        case new
    }
    
    // Determines which version of the product needs to be shown, the remote or local
    
    fileprivate var productVersion: ProductVersion = .new

    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate enum SectionType {
        case categories
        case categoriesSearch
    }
    
    private struct TagsTypeDefault {
        static let Categories: TagsType = .translated
    }

    fileprivate var showCategoriesTagsType: TagsType = TagsTypeDefault.Categories

    fileprivate var categoriesToDisplay: Tags {
        get {
            switch productVersion {

            case .remote:
                return remoteCategories
            case .local:
                return productPair?.localProduct?.categoriesOriginal ?? .undefined
            case .new:
                return productPair?.localProduct?.categoriesOriginal ?? remoteCategories
            }
        }
    }
    
    private var remoteCategories: Tags {
        switch showCategoriesTagsType {
        case .interpreted:
            return productPair?.remoteProduct?.categoriesInterpreted ?? .undefined
        case .original:
            return productPair?.remoteProduct?.categoriesOriginal ?? .undefined
        case .hierarchy:
            return productPair?.remoteProduct?.categoriesHierarchy ?? .undefined
        case .translated:
            return productPair?.remoteProduct?.categoriesTranslated ?? .undefined
        case .prefixed:
            return .undefined
        }

    }
    
    fileprivate var searchCategoriesToDisplay: Tags {
        get {
            if let (tags, _) = query?.categories {
                return tags
            }
            return .undefined
        }
    }
    

    // MARK: - Interface Functions
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - TableView Datasource Functions
    
    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let TagListView = "TagListView Cell Identifier"
            static let TagListViewWithSegmentedControl = "TagListView With SegmentedControl Cell Identifier"
        }
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
        case .categories:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.editMode = editMode
            cell.delegate = self
            cell.datasource = self
            return cell
            
        case .categoriesSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.categories.1 ?? true
            cell.allowInclusionEdit = query!.type != .simple

            return cell

        }

    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (currentProductSection, _, header) = tableStructureForProduct[section]
        
        guard header != nil else { return "No header" }
        switch currentProductSection {
        case .categories:
            switch showCategoriesTagsType {
            case TagsTypeDefault.Categories:
                return header
            default:
                return header! +
                    " " +
                    "(" +
                    showCategoriesTagsType.description +
                ")"
            }
        case .categoriesSearch:
            return header
        }
    }
    
    struct TableStructure {
        static let CategoriesSectionHeader = TranslatableStrings.Categories
        static let CategoriesSectionSize = 1
    }

    fileprivate func setupTableSections() -> [(SectionType, Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        if isQuery {
            sectionsAndRows.append((
                SectionType.categoriesSearch,
                TableStructure.CategoriesSectionSize,
                TableStructure.CategoriesSectionHeader))
        } else {
            sectionsAndRows.append((
                SectionType.categories,
                TableStructure.CategoriesSectionSize,
                TableStructure.CategoriesSectionHeader))
        }
        return sectionsAndRows
            
    }
    
    // MARK: - Notification Handler Functions
        
    @objc func refreshProduct() {
        showCategoriesTagsType = TagsTypeDefault.Categories

        tableView.reloadData()
    }

    @objc func removeProduct() {
        productPair!.remoteProduct = nil
        tableView.reloadData()
    }

    @objc func doubleTapOnTableView() {
        switch productVersion {
        case .remote:
            productVersion = .local
            delegate?.title = TranslatableStrings.Categories + " (Local)"
        case .local:
            productVersion = .new
            delegate?.title = TranslatableStrings.Categories + " (New)"
        case .new:
            productVersion = .remote
            delegate?.title = TranslatableStrings.Categories + " (OFF)"
        }
        tableView.reloadData()
    }

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false
        
        // Add doubletapping to the TableView. Any double tap on headers is now received,
        // and used for changing the productVersion (local and remote)
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(CategoriesTableViewController.doubleTapOnTableView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.cancelsTouchesInView = false
        doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
        tableView.addGestureRecognizer(doubleTapGestureRecognizer)

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate?.title = TranslatableStrings.Categories

        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name: .RemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)

        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        // NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.changeTagsTypeToShow), name:.TagListViewTapped, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

extension CategoriesTableViewController: TagListViewCellDelegate {
    
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that the switch changed
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .categories:
            showCategoriesTagsType.cycle()
            tableView.reloadData()
        // tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        default:
            break
        }
    }
}

// MARK: - TagListViewSegmentedControlCellDelegate Delegate Functions

extension CategoriesTableViewController: TagListViewSegmentedControlCellDelegate {
    
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl: UISegmentedControl) {
        let inclusion = segmentedControl.selectedSegmentIndex == 0 ? false : true
        let (currentProductSection, _, _) = tableStructureForProduct[sender.tag]
        
        switch currentProductSection {
        case .categoriesSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.categories.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        default:
            break
        }
    }
}


// MARK: - TagListView Datasource Functions

extension CategoriesTableViewController: TagListViewDataSource {
    
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

        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]

        switch  currentProductSection {
        case .categories :
            return count(categoriesToDisplay)
        case .categoriesSearch:
            return count(searchCategoriesToDisplay)
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories :
            return categoriesToDisplay.tag(at: index)!
        case .categoriesSearch:
            return searchCategoriesToDisplay.tag(at: index)!
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        // Assume that the tag value corresponds to the section
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }

}


// MARK: - TagListView Delegate Functions

extension CategoriesTableViewController: TagListViewDelegate {
    
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories :
            switch categoriesToDisplay {
            case .undefined, .empty:
                productPair?.update(categories: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(categories: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .categoriesSearch:
            switch searchCategoriesToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.categories.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.categories.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }

        }
        
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories :
            switch categoriesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(categories: list)
            case .notSearchable:
                assert(true, "How can I deleted a tag when the field is non-editable")

            }
        case .categoriesSearch:
            switch searchCategoriesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.categories.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }

        }
    }
    
    public func didClear(_ tagListView: TagListView) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories:
            productPair?.update(categories: [])
        case .categoriesSearch:
            switch searchCategoriesToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.categories.0 = .available(list)
            default:
                assert(true, "How can I clear a tag when there are none")
                
            }

        }
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
                
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .categories:
            delegate?.search(for: productPair!.remoteProduct!.categoriesInterpreted.tag(at:index), in: .category)
        default:
            break
        }
    }


}
