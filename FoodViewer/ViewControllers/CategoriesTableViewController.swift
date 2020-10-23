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

    var coordinator: CategoriesCoordinator? = nil
    
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
        case new
        // new data as entered by the user locally.
        // This should be a mix of existing edited data and new data
        
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

    fileprivate var tableStructure: [SectionType] = []
    
    fileprivate enum SectionType {
        case categories(Int)
        
        var numberOfRows: Int {
            switch self {
            case .categories(let numberOfRows):
                return numberOfRows
            }
        }
    }
    
    fileprivate var categoriesToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                // Show the categories in the interface language
                if var list = productPair?.localProduct?.categoriesTranslated.list {
                    // if nothing has been added, initialise with the existing categories
                    if list.isEmpty,
                        let oldList = productPair?.remoteProduct?.categoriesTranslated.list {
                        list = oldList
                    }
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
        return tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewButtonTableViewCell.self), for: indexPath) as! TagListViewButtonTableViewCell
        cell.setup(datasource: self, delegate: self, showButton: !editMode, width:  tableView.frame.size.width, tag: indexPath.section)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewButtonTableViewCell {
            validCell.willDisappear()
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
               
        var header: String
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LanguageHeaderView.identifier) as! LanguageHeaderView
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        headerView.changeLanguageButton.isHidden = true
        headerView.buttonNotDoubleTap = buttonNotDoubleTap

        switch tableStructure[section] {
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

    fileprivate struct TableSection {
        struct Size {
            static let Categories = 1
        }
    }

    struct TableStructure {
        static let CategoriesSectionHeader = TranslatableStrings.Categories
        static let CategoriesSectionSize = 1
    }

    fileprivate func setupTableSections() -> [SectionType] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [SectionType] = []
        sectionsAndRows.append(.categories(TableSection.Size.Categories))
        return sectionsAndRows
            
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
        coordinator = CategoriesCoordinator.init(with:self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableStructure = setupTableSections()
        
        if delegate != nil {
            tableView.reloadData()
        }

        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name: .ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
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

        switch tableStructure[tagListView.tag] {
        case .categories :
            guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .category),
                let validTags = editMode
                ? categoriesToDisplay
                : Tags.add(right: categoriesToDisplay,
                                         left: Tags(list:questions.map({ $0.value ?? "No value" })))
            else {
                return count(.undefined)
            }
            return count(validTags)
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        
        switch  tableStructure[tagListView.tag] {
        case .categories :
            guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .category),
                let validTags = editMode
                ? categoriesToDisplay
                : Tags.add(right: categoriesToDisplay,
                                         left: Tags(list:questions.map({ $0.value ?? "No value" }))) else { return "" }
            return validTags.tag(at:index)!
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        if abs(tagListViewHeight - height) > CGFloat(3.0) {
            tagListViewHeight = height
            tableView.setNeedsLayout()
        }
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        
        func colorScheme(_ tags: Tags) -> ColorScheme {
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
        
        switch tableStructure[tagListView.tag] {
        case .categories :
            // Do I need to take into account any regular tags?
            if let count = categoriesToDisplay.count,
            index <= count - 1 {
                return colorScheme(categoriesToDisplay)
            } else {
                if !editMode,
                    let questions = productPair?.remoteProduct?.robotoffQuestions(for: .category), !questions.isEmpty {
                    return ColorSchemes.robotoff
                } else {
                    return colorScheme(categoriesToDisplay)
                }
            }
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
        
        switch  tableStructure[tagListView.tag] {
        case .categories :
            switch categoriesToDisplay {
            case .undefined, .empty:
                productPair?.update(categories: [title])
            case var .available(list):
                // the list contains the old, edited and new entries
                list.append(title)
                productPair?.update(categories: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        }
        
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        
        switch  tableStructure[tagListView.tag] {
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
        
        switch  tableStructure[tagListView.tag] {
        case .categories:
            productPair?.update(categories: [])
        }
    }
    
    public func tagListView(_ tagListView: TagListView, canTapTagAt index: Int) -> Bool {
        
        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return false
        }
        guard !editMode else { return false }

        switch tableStructure[tagListView.tag] {
        case .categories:
            // Do I need to take into account any regular tags?
            if let count = categoriesToDisplay.count {
                if index <= count - 1 {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        }

    }

    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        
        func askQuestion(for type: RobotoffQuestionType, at index:Int) {
            guard let question = productPair?.remoteProduct?.robotoffQuestions(for: type)[index] else { return }
            var image: ProductImageSize?
            if let validID = productPair?.remoteProduct?.imageID(for: question.imageID) {
                if let validImages = productPair?.remoteProduct?.images {
                    image = validImages[validID]
                }
            }
            coordinator?.showQuestion(for: productPair, question: question, image: image)
        }

        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return
        }
        guard !editMode else { return }

        switch tableStructure[tagListView.tag] {
        case .categories:
            // Do I need to take into account any regular tags?
            if let count = categoriesToDisplay.count {
                if index <= count - 1 {
                    return
                } else {
                    askQuestion(for: .category, at: index - count)
                }
            } else {
                askQuestion(for: .category, at: index)
            }
        }
    }

    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
                
        switch tableStructure[tagListView.tag] {
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
        coordinator?.selectCategory(for: productPair)
        //performSegue(withIdentifier: segueIdentifier(to: SelectPairViewController.self), sender: button)
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
