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
                tableStructureForProduct = analyseProductForTable(product!)
                tableView.reloadData()
            }
        }
    }
    
    private var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                tableView.reloadData()
            }
        }
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
    
    fileprivate struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Categories", comment: "Title of ViewController with the categories the product belongs to.")
    }
    
    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate enum SectionType {
        case categories
    }
    
    private struct TagsTypeDefault {
        static let Categories: TagsType = .translated
    }

    private var showCategoriesTagsType: TagsType = TagsTypeDefault.Categories

    fileprivate var categoriesToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.categoriesOriginal {
                case .available, .empty:
                    showCategoriesTagsType = .edited
                    return delegate!.updatedProduct!.categoriesOriginal
                default:
                    break
                }
            }
            switch showCategoriesTagsType {
            case .interpreted:
                return product!.categoriesInterpreted
            case .original:
                return product!.categoriesOriginal
            case .hierarchy:
                return product!.categoriesHierarchy
            case .translated:
                return product!.categoriesTranslated
            case .edited, .prefixed:
                return .undefined
            }
        }
    }
    
    // MARK: - Interface Functions
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - TableView Datasource Functions
    
    fileprivate struct Storyboard {
        static let CellIdentifier = "Categories Cell Identifier"
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.editMode = editMode
            cell.delegate = self
            cell.datasource = self
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
                    showCategoriesTagsType.description() +
                ")"
            }
        }
    }
    
    struct TableStructure {
        static let CategoriesSectionHeader = NSLocalizedString("Categories", comment: "Header title for table section with product Categories") 
        static let CategoriesSectionSize = 1
    }

    fileprivate func analyseProductForTable(_ product: FoodProduct) -> [(SectionType, Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        // nutritionFacts section
        sectionsAndRows.append((
            SectionType.categories,
            TableStructure.CategoriesSectionSize,
            TableStructure.CategoriesSectionHeader))
        return sectionsAndRows
    }
    
    // MARK: - Notification Handler Functions
        
    func refreshProduct() {
        showCategoriesTagsType = TagsTypeDefault.Categories

        tableView.reloadData()
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    func changeTagsTypeToShow(_ notification: Notification) {
        if let tag = notification.userInfo?[TagListViewTableViewCell.Notification.TagKey] as? Int {
            let (currentProductSection, _, _) = tableStructureForProduct[tag]
            switch currentProductSection {
            case .categories:
                showCategoriesTagsType.cycle()
                tableView.reloadData()
                // tableView.reloadSections(IndexSet.init(integer: tag), with: .fade)
            }
        }
    }

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false

        title = Constants.ViewControllerTitle
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // tableView.reloadData() // does not help

        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name: .ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.changeTagsTypeToShow), name:.TagListViewTapped, object:nil)
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

// MARK: - TagListView Datasource Functions

extension CategoriesTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]

        switch  currentProductSection {
        case .categories :
            switch categoriesToDisplay {
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
                return 1
            }
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories :
            switch categoriesToDisplay {
            case .undefined, .empty, .notSearchable:
                return categoriesToDisplay.description()
            case let .available(list):
                if index >= 0 && index < list.count {
                    return list[index]
                } else {
                    assert(true, "categories array - index out of bounds")
                }
            }
        }
        return("TagListView titleForTagAt error")
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
                delegate?.update(categories: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(categories: list)
            case .notSearchable:
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
                delegate?.update(categories: list)
            case .notSearchable:
                assert(true, "How can I deleted a tag when the field is non-editable")

            }

        }
    }
    
    public func didClear(_ tagListView: TagListView) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories:
            delegate?.update(categories: [])
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
                
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .categories:
            delegate?.search(for: product!.categoriesInterpreted.tag(at:index), in: .category)
        }
    }


}
