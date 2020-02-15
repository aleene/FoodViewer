//
//  SearchesHistoryTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 26/01/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class SearchesHistoryTableViewController: UITableViewController, UITextFieldDelegate {
    
    fileprivate struct Constants {
        struct TagValue {
            struct Multiplier {
                static let Section = 1000
                static let Row = 10
            }
            struct Search {
                static let Unitialized = SearchFetchStatus.uninitialized.rawValue
                static let Initialized = SearchFetchStatus.initialized.rawValue
                static let NotDefined = SearchFetchStatus.notDefined.rawValue
                static let NotLoaded = SearchFetchStatus.notLoaded.rawValue
                static let Loading = SearchFetchStatus.loading.rawValue
                static let Loaded = SearchFetchStatus.loaded.rawValue
                static let Failed = SearchFetchStatus.loadingFailed("").rawValue
            }
        }
    }
    
    fileprivate var searches = OFFSearchProducts.manager
    
    //fileprivate var focusOnNewSearchedProductPair = false
    
    private var selectedSearch: Search? = nil
    
    fileprivate func startInterface(at index:Int) {
        setTitle()
    }
        
    // Function to set the title of this viewController
    // It is important to set the title at the right moment in the lifecycle
    // Just after reloading the data seems to be the best moment.
    
    fileprivate func setTitle() {
        switch currentProductType {
        case .food:
            title = TranslatableStrings.SearchFoodProducts
        case .petFood:
            title = TranslatableStrings.SearchPetFoodProducts
        case .beauty:
            title = TranslatableStrings.SearchBeautyProducts
        case .product:
            title = TranslatableStrings.SearchProducts
        }
        guard title != nil else { return }
        
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    // MARK: - Table view methods and vars
        
    // There is a section for each search
    override func numberOfSections(in tableView: UITableView) -> Int {
        return searches.allSearchQueries.count != 0 ? searches.allSearchQueries.count : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // A search-description consists of three parts:
        // - the search components, one row per component (SearchComponent)
        // - search result sort order (SearchSortOrder)
        // - the search status (Search.status)
        
        guard searches.allSearchQueries.count != 0 else { return 1 }
        // Are there any search components defined?
        guard let numberOfQueryElements = searches.allSearchQueries[section].query?.searchPairsWithArray().count else { return 2 } // no search defined and sort
        
        return numberOfQueryElements + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tagValue = Constants.TagValue.Search.NotDefined
        if searches.allSearchQueries.count > 0 {
            let search = searches.allSearchQueries[indexPath.section]
            tagValue = tag(for: indexPath, for: search)
            // if a query is defined show the query
            if search.isDefined {
                // is there a search with one or more search components?
                // for each component show a row with a description
                if indexPath.row < search.componentsCount  {
                    // Search labels with switches to include or exclude the label
                    //  -- tag values as tags and inclusion as labelText
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewLabelTableViewCell.self), for: indexPath) as! TagListViewLabelTableViewCell //
                    cell.setup(datasource: self, delegate: nil, editMode: false, width: tableView.frame.size.width, tag: tagValue, prefixLabelText: nil, scheme: nil, text: search.category(for:indexPath.row) ?? "", text2:search.text(for:indexPath.row) ?? TranslatableStrings.NotSet)
                    return cell
                }
            }
            // cell for the sortOrder
            // if there is a search query, the penultimate (row n)
            // if there is no search query the last (row 1)
            if (search.isDefined && indexPath.row == search.componentsCount) ||
                (!search.isDefined && indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: NameTableViewCell.self), for: indexPath) as! NameTableViewCell //
                cell.brandLabel.text = "Results sorted by " + ( search.sortOrder?.description ?? "No sort order defined" )
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ButtonTableViewCell.self), for: indexPath) as! ButtonTableViewCell
            cell.tag = tagValue
            cell.editMode = true
            switch search.status {
            case .loaded, .loading, .partiallyLoaded:
                cell.title = "Show search results"
            case .notLoaded:
                cell.title = "Load search results"
            default:
                cell.title = "????"
            }
            cell.accessoryType = .none
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ButtonTableViewCell.self), for: indexPath) as! ButtonTableViewCell
            cell.tag = tagValue
            cell.editMode = true
            cell.title = "Create search query"
                cell.accessoryType = .none
            cell.delegate = self
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searches.allSearchQueries.count > 0 {
            selectedSearch = searches.allSearchQueries[indexPath.section]
            if let validSearch = selectedSearch {
                if validSearch.isDefined {
                    // the search is defined let's edit it
                    if indexPath.row < validSearch.componentsCount  {
                        performSegue(withIdentifier: segueIdentifier(to: AddSearchQueryTableViewController.self), sender: self)
                    } else if indexPath.row == validSearch.componentsCount {
                        performSegue(withIdentifier: segueIdentifier(to: SetSortOrderViewController.self), sender: self)
                    } else if indexPath.row == validSearch.componentsCount + 1 {
                        performSegue(withIdentifier: segueIdentifier(to: SearchResultsTableViewController.self), sender: self)
                    }
                } else if
                    // the penultimate row
                    (!validSearch.isDefined && indexPath.row == 1) {
                    performSegue(withIdentifier: segueIdentifier(to: SetSortOrderViewController.self), sender: self)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewLabelTableViewCell {
            validCell.willDisappear()
        }
    }

    private func tag(for indexPath:IndexPath, for search:Search?) -> Int {
        // the section indicates the query
        var tag = indexPath.section * Constants.TagValue.Multiplier.Section
        if let validSearch = search {
            // has the search a validQuery?
            if validSearch.isDefined {
                // the first rows define the search
                if indexPath.row < validSearch.componentsCount {
                    // the row counts start after the multiplier
                    tag = tag + indexPath.row + Constants.TagValue.Multiplier.Row
                } else {
                    // the last row defines the search status for a defined query
                    switch validSearch.status {
                    case .notLoaded:
                        tag = tag + Constants.TagValue.Search.NotLoaded
                    case .loading:
                        tag = tag + Constants.TagValue.Search.Loading
                    case .loadingFailed:
                        tag = tag + Constants.TagValue.Search.Failed
                    default:
                        break
                    }
                }
            } else {
                // the status if there is not a query
                switch validSearch.status {
                case .initialized:
                    tag = tag + Constants.TagValue.Search.Initialized
                case .notDefined:
                    tag = tag + Constants.TagValue.Search.NotDefined
                default:
                    break
                }
            }
        } else {
            
            tag = tag + Constants.TagValue.Search.Unitialized
        }
        return tag
    }
    
    private func title(for tag:Int) -> String {
        guard searches.allSearchQueries.count > 0 else { return TranslatableStrings.NotSet }
        let remainder = tag % Constants.TagValue.Multiplier.Section
        let section = ( tag - remainder ) / Constants.TagValue.Multiplier.Section
        let search = searches.allSearchQueries[section]
        if remainder < Constants.TagValue.Multiplier.Row {
            // the last row defines the search status for a defined query
            return search.status.description
        } else {
            let row = remainder - Constants.TagValue.Multiplier.Row
            if row < search.componentsCount {
                return search.label(for: row) ?? TranslatableStrings.NotSet
            } else {
                return "Results sorted by " + ( search.sortOrder?.description ?? "No sort order defined" )
            }
        }
    }

    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel.init(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 20))
        tempView.backgroundColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        let search = products.allSearchQueries[section]
        switch search.status {
            //case .loading(let barcodeString):
            //    label.text = barcodeString
            //case .more:
                // no header required in this case https://world.openfoodfacts.org/api/v0/product/737628064502.json
            //    return nil
            case .loadingFailed(let error):
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
                /*
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
 */
            case .loading:
                label.text = TranslatableStrings.Searching
            default:
                label.text = "What to put here?"
            }
        
        tempView.addSubview(label)
        tempView.tag = section
        return tempView
    }
 */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard searches.allSearchQueries.count > 0 else { return nil }
        let search = searches.allSearchQueries[section]
        if search.isDefined {
            let category = search.category(for: 0) ?? "?"
            return "Searching in " + category
        }
        return TranslatableStrings.NoSearchDefined
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard searches.allSearchQueries.count > 0 else { return nil }
        let search = searches.allSearchQueries[section]
        if search.isDefined  {
            switch search.status {
            case .loaded, .partiallyLoaded:
                let numberOfResults = search.query?.numberOfSearchResults
                let string = numberOfResults != nil ? "\(numberOfResults!)" : "none"
                return "Number of results " +  string
            default:
                break
            }
        }
        return ""
    }
    /*
    // http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
 */
    // MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdentifier(to: SearchResultsTableViewController.self):
                if let vc = segue.destination as? SearchResultsTableViewController {
                    vc.search = selectedSearch
                }
            case segueIdentifier(to: SetSortOrderViewController.self):
                if let vc = segue.destination as? SetSortOrderViewController {
                    vc.currentSortOrder = selectedSearch?.sortOrder
                }
            case segueIdentifier(to: AddSearchQueryTableViewController.self):
                if let vc = segue.destination as? AddSearchQueryTableViewController {
                    vc.search = nil
                }

            default: break
            }
        }
    }
    
    @IBAction func unwindSetSortOrder(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SetSortOrderViewController {
            if let validSortOrder = vc.selectedSortOrder {
                selectedSearch?.query?.sortOrder = validSortOrder
                selectedSearch?.startSearch()
            }
        }
    }
    
    @IBAction func unwindAddSearchQueryForCancel(_ segue:UIStoryboardSegue) {
        // nothing needs to be done?
        
    }

    @IBAction func unwindAddSearchQueryForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? AddSearchQueryTableViewController {
            if let validSearch = vc.search,
                validSearch.isDefined {
                searches.allSearchQueries.append(validSearch)
                selectedSearch = validSearch
                tableView.reloadData()
            }
        }
    }

    /*
     
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
     
     */
    /*
    private func switchToTab(withIndex index: Int) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            tabVC.selectedIndex = index
        } else {
            assert(true, "ProductTableViewController:switchToTab: TabBar hierarchy error")
        }
        setTitle()
    }
    */
    
    // MARK: - Notification methods
    
    // function is called if an product image has been retrieved via an asynchronous process
    /*
    @objc func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        
        // only update if the image barcode corresponds to the current product
        if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String,
            let section = products.indexOfProductPair(with: BarcodeType(barcodeString: barcodeString, type:Preferences.manager.showProductType)) {
            let visibleIndexPaths = self.tableView.indexPathsForVisibleRows
            let indexPathForProductPair = IndexPath(row: 1, section: section)
            if let validVisibleIndexPaths = visibleIndexPaths,
                // only look for rows with an image
                validVisibleIndexPaths.contains(indexPathForProductPair) {
                tableView.reloadData()
            }
            // If the user just scanned a product, it should stays focussed on that product
            if focusOnNewSearchedProductPair {
                if let validSelectedIndex = products.index(of: selectedProductPair) {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: validSelectedIndex), at: .top, animated: false)
                }
            }
        }
    }
 */
    /*
    @objc func productLoaded(_ notification: Notification) {
        
        // This is needed to increase the tablesize as each product is added.
        // The issue is the size of the product array that is determined by the number of received products.
        // It should be related to the size of the history file.
        // At least I think that that is the issue.
        
        tableView.reloadData()
        
    }
 */
    /*
    @objc func productUpdated(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        if let barcodeString = userInfo![ProductPair.Notification.BarcodeKey] as? String {
            if let index = products.indexOfProductPair(with: BarcodeType(barcodeString: barcodeString, type: Preferences.manager.showProductType)) {
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
                // If the user just scanned a product, it should stays focussed on that product
                if focusOnNewSearchedProductPair {
                    if let validSelectedIndex = products.index(of: selectedProductPair) {
                        tableView.reloadData()
                        tableView.scrollToRow(at: IndexPath(row: 0, section: validSelectedIndex), at: .top, animated: false)
                    }
                } else {
                    let visibleIndexPaths = self.tableView.indexPathsForVisibleRows
                    let indexPathForProductPair = IndexPath(row: 0, section: index)
                    if let validVisibleIndexPaths = visibleIndexPaths,
                        // only look for rows with an image
                        validVisibleIndexPaths.contains(indexPathForProductPair) {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
 */
    
    /*
    @objc func firstProductLoaded(_ notification: Notification) {
        startInterface(at: 0)
        showProductPage()
    }
 */
    
    @objc func searchLoaded(_ notification: Notification) {
        tableView.reloadData()
    }
    
    @objc func searchStarted(_ notification: Notification) {
        tableView.reloadData()
    }
    
    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
                //products.reloadAll()
                startInterface(at: 0)
                //showProductPage()
            }
        }
    }
    
    // MARK: - Viewcontroller lifecycle
    /*
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the recents tab
            tabVC.selectedIndex = 0
            tabVC.delegate = self
            
            // show history products
            //products.list = .recent
            products.search = nil
        }
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.allowsSelection = true
        
        tableView.register(UINib(nibName: "SearchHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        setTitle()
        
        // Notifications coming from ProductPair,
        // which indicate that something in the productPair has changed
        // either the local product or the remote product
        //NotificationCenter.default.addObserver(self, selector:#selector(SearchesHistoryTableViewController.firstProductLoaded(_:)), name:.SampleLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SearchesHistoryTableViewController.searchLoaded(_:)), name:.SearchLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SearchesHistoryTableViewController.searchStarted(_:)), name:.SearchStarted, object:nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //refreshInterface()
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

// MARK: - SearchHeaderDelegate Functions

extension SearchesHistoryTableViewController: ButtonCellDelegate {

    // function to let the delegate know that a tag was single tapped
    func buttonTableViewCell(_ sender: ButtonTableViewCell, receivedTapOn button:UIButton) {
        if searches.allSearchQueries.count > 0 {
            let remainder = sender.tag % Constants.TagValue.Multiplier.Section
            let section = ( sender.tag - remainder ) / Constants.TagValue.Multiplier.Section
            selectedSearch = searches.allSearchQueries[section]
            switch searches.allSearchQueries[section].status {
            case .notLoaded,
                 .partiallyLoaded,
                 .loaded,
                 .loading:
                performSegue(withIdentifier: segueIdentifier(to: SearchResultsTableViewController.self), sender: self)
            default:
                break
            }
        } else {
            performSegue(withIdentifier: segueIdentifier(to: AddSearchQueryTableViewController.self), sender: self)
        }
    }
}


// MARK: - SearchHeaderDelegate Functions

extension SearchesHistoryTableViewController: SearchHeaderDelegate {
    
    func sortButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
    }
    
    func clearButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
    }
}

// MARK: - UIGestureRecognizerDelegate Functions

extension SearchesHistoryTableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Identify gesture recognizer and return true else false.
        return gestureRecognizer.isEqual(self.downTwoFingerSwipe) ? true : false
    }
}

// MARK: - UITabBarControllerDelegate Functions

extension SearchesHistoryTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
    
}

// MARK: - TagListViewCellDelegate Functions

extension SearchesHistoryTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
        if searches.allSearchQueries.count > 0 {
            let remainder = tagListView.tag % Constants.TagValue.Multiplier.Section
            let section = ( tagListView.tag - remainder ) / Constants.TagValue.Multiplier.Section
            selectedSearch = searches.allSearchQueries[section]
            switch searches.allSearchQueries[section].status {
            case .notLoaded,
                 .partiallyLoaded,
                 .loaded,
                 .loading:
                performSegue(withIdentifier: segueIdentifier(to: SearchResultsTableViewController.self), sender: self)
            default:
                break
            }
        } else {
            performSegue(withIdentifier: segueIdentifier(to: AddSearchQueryTableViewController.self), sender: self)
        }
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
        
    }
}


// MARK: - TagListView DataSource Functions

extension SearchesHistoryTableViewController: TagListViewDataSource {
    
    
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return title(for:tagListView.tag)
    }
    
    func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return ColorScheme(text: .white, background: .systemGreen, border: .systemGreen)
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.setNeedsLayout()
    }

}
