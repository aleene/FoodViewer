//
//  CategoriesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    fileprivate struct Constants {
        struct CellHeight {
            static let TagListViewCell = CGFloat(27.0)
        }
        struct CellMargin {
            static let ContentView = CGFloat(11.0)
        }
    }

    // MARK: - Public functions / variables
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue && delegate != nil {
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
        //case remoteTagsHierarchy // tags with parents?
        case remoteTagsTranslated // tags with parents?
        //case remoteTagsHierarchyTranslated // tags with parents?
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

    private var tagListViewHeight: CGFloat = Constants.CellHeight.TagListViewCell

    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate enum SectionType {
        case categories
    }
    
    fileprivate var categoriesToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if var list = productPair?.localProduct?.categoriesTranslated.list {
                    list = list.sorted(by: { $0 < $1 })
                    return Tags.init(list:list)
                }
            case .remoteTags:
                return productPair?.remoteProduct?.categoriesInterpreted ?? .undefined
            //case .remoteTagsHierarchy:
            //    return productPair?.remoteProduct?.categoriesHierarchy ?? .undefined
            //case .remoteTagsHierarchyTranslated:
            //    return productPair?.remoteProduct?.categoriesHierarchyTranslated ?? .undefined
            case .remoteUser:
                return productPair?.remoteProduct?.categoriesOriginal ?? .undefined
            default: break
            }
            return productPair?.remoteProduct?.categoriesTranslated ?? .undefined

        }
    }
    
    fileprivate func checkedTags(_ tags:Tags?) -> Tags? {
        if let validTags = tags,
            validTags.isAvailable {
            return validTags
        }
        return nil
    }

    // MARK: - Interface Functions
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - TableView Functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructureForProduct.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewButtonTableViewCell.self), for: indexPath) as! TagListViewButtonTableViewCell
        cell.setup(datasource: self, delegate: self, showButton: !editMode, width: tableView.frame.size.width, tag: indexPath.section)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewButtonTableViewCell {
            validCell.willDisappear()
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        var (currentProductSection, _, header) = tableStructureForProduct[section]
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LanguageHeaderView.identifier) as! LanguageHeaderView
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
            //case .remoteTagsHierarchy:
                //header = TranslatableStrings.CategoriesHierarchy
            //case .remoteTagsHierarchyTranslated:
                //header = TranslatableStrings.CategoriesHierarchyTranslated
            }
        }
        headerView.title = header
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let validView = view as? LanguageHeaderView {
            validView.willDisappear()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tagListViewHeight + 2 * Constants.CellMargin.ContentView
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
//
// MARK: - Navigation
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdentifier(to: SelectPairViewController.self):
                if  let vc = segue.destination as? SelectPairViewController {
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? TagListViewButtonTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {

                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame
                                ppc.delegate = self
                            }
                                
                            // transfer the categories of the local product (if any or after edit)
                            // or the categories of the remote product
                            // The categories will be interpreted (i.e. as english keys)
                            vc.configure(original: productPair?.categoriesInterpreted?.list,
                                         allPairs: OFFplists.manager.allCategories,
                                         multipleSelectionIsAllowed: true,
                                         showOriginalsAsSelected: true,
                                         assignedHeader: TranslatableStrings.SelectedCategories,
                                         unAssignedHeader: TranslatableStrings.UnselectedCategories,
                                         undefinedText: TranslatableStrings.NoCategoryDefined,
                                         cellIdentifierExtension: CategoriesTableViewController.identifier)
                            }
                        }
                    }

                default: break
                }
            }
        }
            
    @IBAction func unwindSetCategoryForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectPairViewController {
        // The categories are encoded as keys "en:english"
            productPair?.update(categories: vc.selected)
            tableView.reloadData()
        }
    }
        
    @IBAction func unwindSetCategoryForCancel(_ segue:UIStoryboardSegue) {
    }

//
// MARK: - Notification Handler Functions
//
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
        case .remoteTagsTranslated:
            productVersion = .remoteUser
        case .remoteUser:
            productVersion = productPair?.localProduct != nil ? .new : .remoteTags
        }
        tableView.reloadData()
    }
//
// MARK: - Controller Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableStructureForProduct = setupTableSections()
        
        if delegate != nil {
            tableView.reloadData()
        }

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
        OFFplists.manager.flush()
    }

}
//
// MARK: - LanguageHeaderDelegate Functions
//
extension CategoriesTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        doubleTapOnTableView()
    }
}
//
// MARK: - TagListView Datasource Functions
//
extension CategoriesTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ tags: Tags) -> Int {
            switch tags {
            case .undefined, .empty:
                return editMode ? 0 : 1
            case let .available(list):
                return list.count
            default:
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
        if abs(tagListViewHeight - height) > CGFloat(3.0) {
            tagListViewHeight = height
            tableView.setNeedsLayout()
        }
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        
        func count(_ tags: Tags) -> ColorScheme {
            switch tags {
            case .undefined, .notSearchable:
                return ColorSchemes.error
            case .empty:
                return ColorSchemes.none
            case let .available(list):
                if list[index].contains(":") {
                    return ColorScheme(text: .white, background: .systemOrange, border: .systemOrange)
                } else {
                    return ColorSchemes.normal
                }
            }
        }
        
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch currentProductSection {
        case .categories :
            return count(categoriesToDisplay)
        }
    }
}


// MARK: - TagListView Delegate Functions

extension CategoriesTableViewController: TagListViewDelegate {
        
    public func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool {
        return editMode
    }
    
    public func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool {
        return editMode
    }
    
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
    
    public func didDeleteAllTags(_ tagListView: TagListView) {
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
//
// MARK: - TagListViewButtonCellDelegate Functions
//
extension CategoriesTableViewController: TagListViewButtonCellDelegate {
    
    // function to let the delegate know that the button was tapped
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedTapOn button:UIButton) {
        performSegue(withIdentifier: segueIdentifier(to: SelectPairViewController.self), sender: button)
    }
}
//
// MARK: - UIPopoverPresentationControllerDelegate Functions
//
extension CategoriesTableViewController: UIPopoverPresentationControllerDelegate {
        
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
