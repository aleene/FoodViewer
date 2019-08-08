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
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                tableView.reloadData()
            }
        }
    }

    // MARK: - Private Functions / Variables
    
    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
    
    private var editMode: Bool {
        return delegate?.editMode ?? false
    }

    fileprivate enum ProductVersion {
        case remoteUser // data as entered by the user
        case remoteTags // data interpreted by off
        case remoteTagsHierarchy // tags with parents?
        case remoteTagsTranslated // tags with parents?
        case remoteTagsHierarchyTranslated // tags with parents?
        case new // new data as entered by the user locally
        
        var isRemote: Bool {
            switch self {
            case .new:
                return false
            default:
                return true
            }
        }
    }

    // Determines which version of the product needs to be shown, the remote or local
    
    fileprivate var productVersion: ProductVersion = .new

    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate enum SectionType {
        case categories
    }
    
    fileprivate var categoriesToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                return productPair?.localProduct?.categoriesOriginal ?? productPair?.remoteProduct?.categoriesTranslated ?? .undefined
            case .remoteTags:
                return productPair?.remoteProduct?.categoriesInterpreted ?? .undefined
            case .remoteTagsTranslated:
                return productPair?.remoteProduct?.categoriesTranslated ?? .undefined
            case .remoteTagsHierarchy:
                return productPair?.remoteProduct?.categoriesHierarchy ?? .undefined
            case .remoteTagsHierarchyTranslated:
                return productPair?.remoteProduct?.categoriesHierarchyTranslated ?? .undefined
            case .remoteUser:
                return productPair?.remoteProduct?.categoriesOriginal ?? .undefined
            }
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
        
        struct Nib {
            static let LanguageHeaderView = "LanguageHeaderView"
        }

        struct ReusableHeaderFooterView {
            static let Language = "LanguageHeaderView"
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
        cell.width = tableView.frame.size.width
        cell.tag = indexPath.section
        cell.editMode = editMode
        if let oldTags = productPair?.localProduct?.categoriesOriginal {
            switch oldTags {
            case .available:
                cell.editMode = productVersion.isRemote ? false : true
            default:
                break
            }
        }
        cell.delegate = self
        cell.datasource = self
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        var (currentProductSection, _, header) = tableStructureForProduct[section]
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Storyboard.ReusableHeaderFooterView.Language) as! LanguageHeaderView
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        headerView.changeLanguageButton.isHidden = true
        headerView.buttonNotDoubleTap = buttonNotDoubleTap

        switch currentProductSection {
        case .categories:
            switch productVersion {
            case .new:
                if let newCategories = productPair?.localProduct?.categoriesOriginal {
                    switch newCategories {
                    case .available:
                        // the local version has been requested and is available
                        header = TranslatableStrings.CategoriesEdited
                    default:
                        header = TranslatableStrings.CategoriesTranslated
                    }
                } else {
                    header = TranslatableStrings.Categories
                }
            case .remoteUser:
                header = TranslatableStrings.CategoriesOriginal
            case .remoteTags:
                header = TranslatableStrings.CategoriesNormalized
            case .remoteTagsTranslated:
                header = TranslatableStrings.CategoriesTranslated
            case .remoteTagsHierarchy:
                header = TranslatableStrings.CategoriesHierarchy
            case .remoteTagsHierarchyTranslated:
                header = TranslatableStrings.CategoriesHierarchyTranslated
            }
        }
        headerView.title = header
        return headerView
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
        sectionsAndRows.append((
            SectionType.categories,
            TableStructure.CategoriesSectionSize,
            TableStructure.CategoriesSectionHeader))
        return sectionsAndRows
            
    }
    
    // MARK: - Notification Handler Functions
        
    @objc func refreshProduct() {
        productVersion = .new

        tableView.reloadData()
    }

    func refreshInterface() {
        tableView.reloadData()
    }
    
    @objc func removeProduct() {
        productPair!.remoteProduct = nil
        tableView.reloadData()
    }

    @objc func doubleTapOnTableView() {
        switch productVersion {
        case .new:
            productVersion = .remoteTags
        case .remoteTags:
            productVersion = .remoteTagsTranslated
        case .remoteTagsTranslated, .remoteTagsHierarchy, .remoteTagsHierarchyTranslated:
            productVersion = .remoteUser
        case .remoteUser:
            productVersion = productPair?.localProduct != nil ? .new : .remoteTags
        }
        tableView.reloadData()
    }

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: Storyboard.Nib.LanguageHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: Storyboard.Nib.LanguageHeaderView)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableStructureForProduct = setupTableSections()
        tableView.reloadData()

        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name: .ProductPairRemoteStatusChanged, object:nil)
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

// MARK: - LanguageHeaderDelegate Functions

extension CategoriesTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        doubleTapOnTableView()
    }
}

// MARK: - TagListViewCellDelegate Functions

extension CategoriesTableViewController: TagListViewCellDelegate {
    
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that the switch changed
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
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

        switch currentProductSection {
        case .categories :
            return count(categoriesToDisplay)
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories :
            return categoriesToDisplay.tag(at: index)!
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
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
        }
    }
    
    public func didClear(_ tagListView: TagListView) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch  currentProductSection {
        case .categories:
            productPair?.update(categories: [])
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
                
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .categories:
            delegate?.search(for: productPair!.remoteProduct!.categoriesInterpreted.tag(at:index), in: .category)
        }
    }


}
