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
                static let Initialized = 0
                static let NotDefined = 1
                static let NotLoaded = 2
                static let Loading = 3
                static let Loaded = 4
                static let Failed = 5
            }
        }
    }
    
    fileprivate var products = OFFSearchProducts.manager
    
    //fileprivate var focusOnNewSearchedProductPair = false
    
    private var selectedSearch: Search? = nil
    
    fileprivate func startInterface(at index:Int) {
        setTitle()
    }
    
    // var productPageViewController: ProductPageViewController? = nil
    
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
    
    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let TagListViewWithLabel = "Search History TagListView With Label Cell Identifier"
            static let TagListView = "Search History TagListView Cell Identifier"
            static let Label = "Search History Label Cell Identifier"
        }
        struct SegueIdentifier {
            static let ShowSearchResults = "Show Search Results Segue Identifier"
        }
    }
    
    // There is a section for each search
    override func numberOfSections(in tableView: UITableView) -> Int {
        return products.allSearchQueries.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfQueryElements = products.allSearchQueries[section].query?.searchPairsWithArray().count else { return 2 }
        // For each search we specify:
        // - the search definition (not set or the query elements
        // - the search results
        return numberOfQueryElements + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let search = products.allSearchQueries[indexPath.section]
        let tagValue = tag(for: indexPath, for: search)
        // if a query is defined show the query
        if search.isDefined && indexPath.row < search.componentsCount  {
            // Search labels with switches to include or exclude the label
            //  -- tag values as tags and inclusion as labelText
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithLabel, for: indexPath) as! TagListViewLabelTableViewCell //
            cell.datasource = self
            cell.tag = tagValue
            cell.categoryLabel.text = search.category(for:indexPath.row) ?? TranslatableStrings.NotSet
            cell.labelText = search.text(for:indexPath.row) ?? TranslatableStrings.NotSet
            cell.width = tableView.frame.size.width
            cell.accessoryType = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
        cell.datasource = self
        cell.tag = tagValue
        cell.scheme = ColorSchemes.normal
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSearch = products.allSearchQueries[indexPath.section]
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowSearchResults, sender: self)
    }
    
    private func tag(for indexPath:IndexPath, for search:Search) -> Int {
        // the section indicates the query
        var tag = indexPath.section * Constants.TagValue.Multiplier.Section
        let search = products.allSearchQueries[indexPath.section]
        // has the search a validQuery?
        if search.isDefined {
            // the first rows define the search
            if indexPath.row != search.componentsCount {
                // the row counts start after the multiplier
                tag = indexPath.row + Constants.TagValue.Multiplier.Row
            } else {
            // the last row defines the search status for a defined query
                switch search.status {
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
            switch search.status {
            case .initialized:
                tag = tag + Constants.TagValue.Search.Initialized
            case .notDefined:
                tag = tag + Constants.TagValue.Search.NotDefined
            default:
                break
            }
        }
        return tag
    }
    
    private func title(for tag:Int) -> String {
        let remainder = tag % Constants.TagValue.Multiplier.Section
        let section = ( tag - remainder ) / Constants.TagValue.Multiplier.Section
        let search = products.allSearchQueries[section]
        if remainder < Constants.TagValue.Multiplier.Row {
            // the last row defines the search status for a defined query
            return search.status.description
        } else {
            return search.label(for: remainder - Constants.TagValue.Multiplier.Row) ?? TranslatableStrings.NotSet
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
    /*
    // http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
 */
    /*
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let validFetchResult = products.searchStatus {
            switch validFetchResult {
            case .more:
                // no header required in this case
                return 0.0
            default:
                break
            }
        }
        return UITableViewAutomaticDimension
    }
 */
    /*
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // if the user starts scrolling the barcode search focus can be reset
        self.focusOnNewSearchedProductPair = false
    }
 */
    
    // MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowSearchResults:
                if let vc = segue.destination as? SearchResultsTableViewController {
                    vc.search = selectedSearch
                }
            default: break
            }
        }
    }
    
    
    // private var productIndexForMainImage: Int? = nil
    
    /*
     @IBAction func unwindNewSearch(_ segue:UIStoryboardSegue) {
     if let vc = segue.source as? BarcodeScanViewController {
     // the user has done a barcode scan, so switch to the right tab
     switchToTab(withIndex: 0)
     // This will retrieve the corresponding product
     barcodeType = BarcodeType(typeCode:vc.type, value:vc.barcode, type:currentProductType)
     // update the interface
     searchTextField.text = vc.barcode
     focusOnNewSearchedProductPair = true
     performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
     } else {
     assert(true, "ProductTableViewController:unwindNewSearch BarcodeScanViewController hierarchy error")
     }
     }
     */
    
    /*
    @IBAction func unwindSetSortOrder(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SetSortOrderViewController {
            if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
                switch validFetchResult {
                case .searchQuery(let query):
                    if let validNewSortOrder = vc.selectedSortOrder {
                        if validNewSortOrder != query.sortOrder && !query.isEmpty {
                            query.sortOrder =  validNewSortOrder
                            OFFProducts.manager.startSearch()
                        }
                    }
                default:
                    break
                }
            }
        }
    }
 */
    
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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.allowsSelection = true
        
        tableView.register(UINib(nibName: "SearchHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        // addGesture()
        setTitle()
        // make sure we show the right tab
        //if products.list == .recent {
        //    switchToTab(withIndex: 1)
        //} else {
        //    switchToTab(withIndex: 2)
        //}
        
        /*
        if let validSelectedProductIndex = products.currentScannedProduct {
            startInterface(at: validSelectedProductIndex)
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: validSelectedProductIndex), at: .top, animated: true)
            showProductPage()
        } else if products.count > 0 && selectedProductPair == nil {
            // If nothing has been selected yet, start with the first product in the list, and on the iPad
            startInterface(at: 0)
            showProductPage()
        }
 */
        
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
    }
}

// MARK: - SearchHeaderDelegate Functions

extension SearchesHistoryTableViewController: SearchHeaderDelegate {
    
    func sortButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
        //performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowSortOrder, sender: button)
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
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}


// MARK: - TagListView DataSource Functions

extension SearchesHistoryTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        // is this a searchQuery section?
        //if tagListView.tag >= Constants.TagValue.Search.Query {
            //if let validFetchResult = products.searchStatus {
        /*
                switch products.searchStatus {
                case .searchQuery(let query):
                    let searchPairs = query.searchPairsWithArray()
                    let index = tagListView.tag - Constants.TagValue.Search.Query
                    if index > 0 && index < searchPairs.count && !query.isEmpty {
                        return searchPairs[index].1.count
                    }
                default:
                    break
                }
                
            //}
        //}
 */
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return title(for:tagListView.tag)
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
}

// MARK: - TagListView Delegate Functions

extension SearchesHistoryTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        
    }
    
}
