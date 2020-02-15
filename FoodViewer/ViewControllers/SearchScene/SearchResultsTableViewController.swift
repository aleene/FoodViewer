//
//  SearchResultsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class SearchResultsTableViewController: UITableViewController, UITextFieldDelegate {
    
    fileprivate var searchHistory = OFFSearchProducts.manager
    
    var search: Search? = nil
    
    fileprivate var focusOnNewSearchedProductPair = false
    
    // Function to set the title of this viewController
    // It is important to set the title at the right moment in the lifecycle
    // Just after reloading the data seems to be the best moment.
    
    fileprivate func setTitle() {

    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    fileprivate var selectedSearch: Search? = nil
    
    fileprivate var selectedProductPair: ProductPair? = nil
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let validSearch = search else { return 1 }
        switch validSearch.status {
        case .partiallyLoaded:
            return validSearch.productPairs.count + 1
        case .loaded: // all products have been loaded
            return validSearch.productPairs.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let validSearch = search {
            if validSearch.productPairs.count > 0 {
                if indexPath.row < validSearch.productPairs.count {
                    let productPair = validSearch.productPair(at: indexPath.row)
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: UITableViewCell.self), for: indexPath)
                    cell.textLabel?.text = productPair?.name ?? TranslatableStrings.NoName
                    cell.detailTextLabel?.text = productPair?.brand ?? TranslatableStrings.NoBrandsIndicated
                    if let language = productPair?.primaryLanguageCode,
                        let frontImages = productPair?.remoteProduct?.frontImages ?? productPair?.localProduct?.frontImages,
                        !frontImages.isEmpty,
                        let result = frontImages[language]?.thumb?.fetch() {
                        switch result {
                        case .success(let image):
                            cell.imageView?.image = image
                        default:
                            break
                        }
                    }
                    return cell
                } else if indexPath.row == validSearch.productPairs.count {
                    // if there is a row beyound the number of search results, show a button
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ButtonTableViewCell.self), for: indexPath) as! ButtonTableViewCell
                    cell.delegate = self
                    cell.editMode = true
                    cell.title = TranslatableStrings.LoadMoreResults
                    return cell
                }
            }
        }
        // This should cover all exceptions
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
        cell.setup(datasource: self, delegate: nil, width: tableView.frame.width, tag: tag(for: indexPath, for: search))

        return cell
    }
    
    
    private func tag(for indexPath:IndexPath, for search:Search?) -> Int {
        // Has a search object been defined at all?
        guard let validSearch = search else { return SearchFetchStatus.uninitialized.rawValue }
        return validSearch.status.rawValue
    }
    
    private func title(for tag:Int) -> String {
        return SearchFetchStatus.description(for:tag)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let validSearch = search {
            if validSearch.productPairs.count > 0 {
                if indexPath.row < validSearch.productPairs.count {
                    selectedProductPair = validSearch.productPair(at: indexPath.row)
                    selectedSearch = validSearch
                    performSegue(withIdentifier: segueIdentifier(to: SingleSearchProductTableViewController.self), sender: self)
                } else if indexPath.row == validSearch.productPairs.count {
                    // start loading more
                    search?.fetchSearchProductsForNextPage()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        }
    }

    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel.init(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 20))
        tempView.backgroundColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        if let validFetchResult = products.productPair(at: section)?.status {
            switch validFetchResult {
            case .available:
                if let validProduct = products.productPair(at: section)?.remoteProduct ?? products.productPair(at: section)?.localProduct,
                    let languageCode = products.productPair(at: section)?.primaryLanguageCode {
                    label.text = products.productPair(at: section)?.remoteProduct?.nameLanguage[languageCode] ?? products.productPair(at: section)?.localProduct?.nameLanguage[languageCode] ?? Constants.Tag.ProductNameMissing
                    switch validProduct.tracesInterpreted {
                    case .available(let validKeys):
                        if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                            tempView.backgroundColor = UIColor.red
                        }
                    default:
                        break
                    }
                    switch validProduct.tracesInterpreted {
                    case .available(let validKeys):
                        if !validKeys.isEmpty {
                            let warn = AllergenWarningDefaults.manager.hasValidWarning(validKeys)
                            if warn {
                                tempView.backgroundColor = UIColor.red
                            }
                        }
                    default:
                        break
                    }
                } else {
                    assert(true, "remoteStatus is available, but there is no product")
                }
            case .loading(let barcodeString):
                label.text = barcodeString
            //case .more:
                // no header required in this case https://world.openfoodfacts.org/api/v0/product/737628064502.json
            //    return nil
            case.loadingFailed(let error):
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
            //case .searchLoading:
            //    label.text = TranslatableStrings.Searching
            default:
                label.text = products.productPair(at: section)?.barcodeType.asString
            }
        } else {
            label.text = Constants.Tag.NoProductsInHistory
        }
        
        tempView.addSubview(label)
        tempView.tag = section
        return tempView
    }
    
    // http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
*/
/*
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //if let validFetchResult = products.productPair(at: section)?.remoteStatus {
            //switch validFetchResult {
            //case .more:
                // no header required in this case
        
                return 0.0
            //default:
             //   break
            }
        }
        return UITableViewAutomaticDimension
    }
 */
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // if the user starts scrolling the barcode search focus can be reset
        self.focusOnNewSearchedProductPair = false
    }
    
    // MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdentifier(to: SingleSearchProductTableViewController.self):
                if let vc = segue.destination as? SingleSearchProductTableViewController {
                    vc.selectedProductPair = selectedProductPair
                }
            default: break
            }

        }
    }
    
    // MARK: - Notification methods
    
    // function is called if an product image has been retrieved via an asynchronous process
    @objc func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        tableView.reloadData()
        /*
        // only update if the image barcode corresponds to the current product
        if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String,
            let section = search?.indexOfProductPair(with: BarcodeType(barcodeString: barcodeString, type:Preferences.manager.showProductType)) {
            let visibleIndexPaths = self.tableView.indexPathsForVisibleRows
            let indexPathForProductPair = IndexPath(row: 1, section: section)
            if let validVisibleIndexPaths = visibleIndexPaths,
                // only look for rows with an image
                validVisibleIndexPaths.contains(indexPathForProductPair) {
                tableView.reloadData()
            }
            // If the user just scanned a product, it should stays focussed on that product
            if focusOnNewSearchedProductPair {
                if let validSelectedIndex = search?.index(of: selectedProductPair) {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: validSelectedIndex), at: .top, animated: false)
                }
            }
        }
 */
    }
    
    @objc func productLoaded(_ notification: Notification) {
        
        // This is needed to increase the tablesize as each product is added.
        // The issue is the size of the product array that is determined by the number of received products.
        // It should be related to the size of the history file.
        // At least I think that that is the issue.
        
        tableView.reloadData()
        
    }
    
    
    
    @objc func searchLoaded(_ notification: Notification) {
        tableView.reloadData()
    }
    
    @objc func searchStarted(_ notification: Notification) {
        if let firstPage = notification.userInfo?[Search.Notification.SearchPageKey] as? Int {
            // if there is no SearchOffSet, then the search just started
            // If it is the first page, position the interface on the first section
            if firstPage == 0 {
                tableView.reloadData()
                //startInterface(at:0)
                //showProductPage()
            }
        }
    }
    
    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: "SearchHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        
        if let validSearch = search {
            switch validSearch.status {
            case .notLoaded:
                search?.startSearch()
            default:
                tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector:#selector(SearchResultsTableViewController.searchLoaded(_:)), name:.SearchLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SearchResultsTableViewController.searchStarted(_:)), name:.SearchStarted, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchResultsTableViewController.imageSet(_:)), name: .ImageSet, object: nil)
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

// Notification definitions

extension Notification.Name {
    static let SearchResultsLoaded = Notification.Name("SearchResultsTableViewController.Notification.SearchResultsLoaded")
}

// MARK: - ButtonCellDelegate Functions


extension SearchResultsTableViewController: ButtonCellDelegate {
    
    // function to let the delegate know that a button was tapped
    func buttonTableViewCell(_ sender: ButtonTableViewCell, receivedTapOn button:UIButton) {
        //if sender.tag < 0 {
        //    showAlertAddFrontImage(forProductWith: -1 * sender.tag)
        //} else {
            search?.fetchSearchProductsForNextPage()
        //}
    }
}

// MARK: - SearchHeaderDelegate Functions

extension SearchResultsTableViewController: SearchHeaderDelegate {
    
    func sortButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
        //performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowSortOrder, sender: button)
    }
    
    func clearButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
        //if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
            //switch search.status {
            //case .searchQuery(let query):
            //    query.clear()
             //   products.reloadAll()
             //   tableView.reloadData()
           // default:
             //   break
         //   }
            
        //}
    }
}

// MARK: - UIGestureRecognizerDelegate Functions

extension SearchResultsTableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Identify gesture recognizer and return true else false.
        return gestureRecognizer.isEqual(self.downTwoFingerSwipe) ? true : false
    }
}

// MARK: - UITabBarControllerDelegate Functions

extension SearchResultsTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
    
}

// MARK: - TagListViewCellDelegate Functions

extension SearchResultsTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}


// MARK: - TagListView DataSource Functions

extension SearchResultsTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return title(for: tagListView.tag)
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.setNeedsLayout()
    }

}

// MARK: - UIPopoverPresentationControllerDelegate Functions

extension SearchResultsTableViewController: UIPopoverPresentationControllerDelegate {
    
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
}
