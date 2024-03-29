//
//  AllProductsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class AllProductsTableViewController: UITableViewController, UITextFieldDelegate {

    fileprivate struct Constants {

        struct AlertSheet {
            static let Message = TranslatableStrings.ProductDoesNotExistAlertSheetMessage
            static let ActionTitleForCancel = TranslatableStrings.ProductDoesNotExistAlertSheetActionTitleForCancel
            static let ActionTitleForAdd = TranslatableStrings.ProductDoesNotExistAlertSheetActionTitleForAdd
        }
        
        struct Tag {
            static let NoProductsInHistory = TranslatableStrings.NoProductsListed
            static let ProductNameMissing = TranslatableStrings.ProductNameMissing
        }
        
        // The tag-value of a cell is used to codify the type of cell
        // The product index is given by the ProductMultiplier, i.e. section * multipier
        // The product loading status (ProductFetchStatus.rawValue) is the remainer if < Offset.Image
        // image-loading status (ImageFetchResult) is the remainer if > Offset.Image < Offset.SearchQuery
        // searchQuery (add Offset.SearchQuery) is the remainer if > Offset.SearchQuery
        //
        //
        
        struct TagValue {
            static let Image = 10
            struct Product {
                // if there is a list of products, their tag values start at 1000
                static let Multiplier = 1000
                // no list of products yet, so the status of the query is encoded as:
                static let Initialized = 0
                static let NotLoaded = 1
                static let Loading = 2
                static let Success = 3
                static let Available = 4
                static let Updating = 5
                static let NotAvailable = 6
                static let LoadingFailed = 7
            }
        }
        
        struct Table {
            static let NumberOfSections = 1
        }
    }
        
    @IBOutlet weak var navItem: UINavigationItem! {
        didSet {
            setTitle()
        }
    }
    
    private func tagValue(for status: ProductFetchStatus) -> Int {
        switch status {
        case .productNotLoaded:
            return Constants.TagValue.Product.NotLoaded
        case .loading:
            return Constants.TagValue.Product.Loading
        case .success:
            return Constants.TagValue.Product.Success
        case .available:
            return Constants.TagValue.Product.Available
        case .updated:
            return Constants.TagValue.Product.Updating
        case .productNotAvailable:
            return Constants.TagValue.Product.NotAvailable
        case .loadingFailed:
            return Constants.TagValue.Product.LoadingFailed
        default:
            return Constants.TagValue.Product.Initialized
        }
    }
    

    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    fileprivate var products = OFFProducts.manager
    
    fileprivate func startInterface(at index:Int) {
        tableView.reloadData()
        if let validProductPair = products.loadProductPair(at: index),
            let validFetchResult = products.productPair(at: index)?.status {
                switch validFetchResult {
                case .available, .loading:
                    selectedProductPair = validProductPair
                    tableView.scrollToRow(at: IndexPath(row: index, section: Constants.Table.NumberOfSections - 1), at: .top, animated: true)
                default:
                    selectedProductPair = nil
                }
         } else {
            selectedProductPair = nil
        }
        setTitle()
    }
    
    fileprivate func refreshInterface() {
        guard products.count > 0 else { return }
        tableView.reloadData()
    }
    
    // Function to set the title of this viewController
    // It is important to set the title at the right moment in the lifecycle
    // Just after reloading the data seems to be the best moment.
    
    fileprivate func setTitle() {
        //self.navItem?.title = TranslatableStrings.History
        // When using the navItem.prompt an autolayout error is triggered
        switch currentProductType {
        case .food:
            self.navItem?.title = TranslatableStrings.FoodProducts + " " + TranslatableStrings.History
        case .petFood:
            self.navItem?.title = TranslatableStrings.PetFoodProducts + " " + TranslatableStrings.History
        case .beauty:
            self.navItem?.title = TranslatableStrings.BeautyProducts + " " + TranslatableStrings.History
        case .product:
            self.navItem?.title = TranslatableStrings.SearchProducts + " " + TranslatableStrings.History
        }
        //self.title = TranslatableStrings.History
    }
    
    // MARK: - Table view methods and vars
    
    fileprivate var selectedProductPair: ProductPair? = nil
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.Table.NumberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = products.count
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // The list should reflect the status on OFF
        if let validFetchResult = products.productPair(at: indexPath.row)?.status {
            switch validFetchResult {
            case .available, .updated:
                products.loadProductPair(at: indexPath.row) //make sure the next set is loaded
                let productPair = products.productPair(at: indexPath.row)
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: UITableViewCell.self), for: indexPath)
                // cell.isEditing = true
                cell.backgroundColor = allergenAndTraceWarningColour(for: productPair)
                cell.textLabel?.text = productPair?.name ?? productPair?.barcodeType.asString
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
                } else {
                    cell.imageView?.image = nil
                }
                return cell
                
            case .productNotAvailable,
                .loading,
                .loadingFailed:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell //
                // encode the product number and result into the tag
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, width: nil, tag: indexPath.row * Constants.TagValue.Product.Multiplier + validFetchResult.rawValue)
                return cell
                    
            case .initialized, .productNotLoaded:
                products.loadProductPair(at: indexPath.row)
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
                cell.setup(datasource: self, delegate: nil, width: nil, tag: tagValue(for: validFetchResult))

                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
                cell.setup(datasource: self, delegate: nil, width: nil, tag: validFetchResult.rawValue + Constants.TagValue.Product.Multiplier * indexPath.row)
                return cell
                }
        } else { // No validFetchResult
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: nil, width: nil, tag: tagValue(for: .initialized))
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        }
    }
    
    fileprivate func allergenAndTraceWarningColour(for productPair:ProductPair?) -> UIColor {
        if let validProduct = productPair?.remoteProduct?.tracesInterpreted ?? productPair?.localProduct?.tracesInterpreted {
            switch validProduct {
            case .available(let validKeys):
                if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                    return UIColor.systemRed.withAlphaComponent(0.4)
            }
            default:
                break
            }
        }
        if let validProduct = productPair?.remoteProduct?.allergensInterpreted ?? productPair?.localProduct?.allergensInterpreted {
            switch validProduct {
            case .available(let validKeys):
                if (!validKeys.isEmpty) && (AllergenWarningDefaults.manager.hasValidWarning(validKeys)) {
                    return UIColor.systemRed.withAlphaComponent(0.4)
            }
            default:
                break
            }
        }
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedProductPair = products.productPair(at: indexPath.row)
        return indexPath
    }
        
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            products.removeProductPair(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
 
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // if the user starts scrolling the barcode search focus can be reset
        products.currentScannedProduct = nil
        selectedProductPair = nil
    }
    
// MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdentifier(to: SingleProductTableViewController.self):
                if let vc = segue.destination as? SingleProductTableViewController {
                    vc.selectedProductPair = selectedProductPair
                }
            default: break
            }
        }
    }
        
    private func switchToTab(withIndex index: Int) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            tabVC.selectedIndex = index
        } else {
            assert(true, "ProductTableViewController:switchToTab: TabBar hierarchy error")
        }
        setTitle()
    }
    
    func start() {
        // Is there a scanned product?
        if let validSelectedProductIndex = products.currentScannedProduct {
            // Then open de product details right away
            startInterface(at: validSelectedProductIndex)
            performSegue(withIdentifier: segueIdentifier(to: SingleProductTableViewController.self), sender: self)
        } else if let validProductPair = selectedProductPair,
            let validIndex = products.index(of: validProductPair) {
            startInterface(at: validIndex)
            // just start at the top
        } else if products.count > 0 {
            // If nothing has been selected yet, start with the first product in the list, and on the iPad
            startInterface(at: 0)
        }
    }
    
    
    // MARK: - Notification methods
    
    // function is called if an product image has been retrieved via an asynchronous process
    @objc func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        
        // only update if the image barcode corresponds to the current product
        if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String,
            let row = products.indexOfProductPair(with: BarcodeType(barcodeString: barcodeString, type:Preferences.manager.showProductType)) {
            let visibleIndexPaths = self.tableView.indexPathsForVisibleRows
            let indexPathForProductPair = IndexPath(row: row, section: Constants.Table.NumberOfSections - 1)
            if let validVisibleIndexPaths = visibleIndexPaths,
                // only look for rows with an image
                validVisibleIndexPaths.contains(indexPathForProductPair) {
                tableView.reloadData()
            }
        }
    }
    
    @objc func productLoaded(_ notification: Notification) {
        
        // This is needed to increase the tablesize as each product is added.
        // The issue is the size of the product array that is determined by the number of received products.
        // It should be related to the size of the history file.
        // At least I think that that is the issue.

        tableView.reloadData()

    }

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
                let visibleIndexPaths = self.tableView.indexPathsForVisibleRows
                let indexPathForProductPair = IndexPath(row: index, section: Constants.Table.NumberOfSections - 1)
                if let validVisibleIndexPaths = visibleIndexPaths,
                // only look for rows with an image
                    validVisibleIndexPaths.contains(indexPathForProductPair) {
                    tableView.reloadData()
                }
            }
        }
        // keep focus on selectedProduct
        if let validProductPair = selectedProductPair,
            let validIndex = products.index(of: validProductPair) {
            tableView.scrollToRow(at: IndexPath(row: validIndex, section: Constants.Table.NumberOfSections - 1), at: .top, animated: true)
        }
    }
    
    // 
    @objc func firstProductLoaded(_ notification: Notification) {
        startInterface(at: 0)
    }
    
    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
                products.reloadAll()
                startInterface(at: 0)
            }
        }
        /////
    }
    
// MARK: - Viewcontroller lifecycle

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.allowsSelection = true
        //tableView.isEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //start()
        
        // Notifications coming from ProductPair,
        // which indicate that something in the productPair has changed
        // either the local product or the remote product
        NotificationCenter.default.addObserver(self, selector:#selector(AllProductsTableViewController.productUpdated(_:)), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(AllProductsTableViewController.productUpdated(_:)), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(AllProductsTableViewController.firstProductLoaded(_:)), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(AllProductsTableViewController.firstProductLoaded(_:)), name:.SampleLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AllProductsTableViewController.imageSet(_:)), name: .ImageSet, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // refreshInterface()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        products.currentScannedProduct = nil
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
    
}
    
// MARK: - UITabBarControllerDelegate Functions
    
extension AllProductsTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
}
 
// MARK: - TagListViewCellDelegate Functions
    
extension AllProductsTableViewController: TagListViewCellDelegate {
        
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}
    

// MARK: - TagListView DataSource Functions
    
extension AllProductsTableViewController: TagListViewDataSource {
        
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
        
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {

        // find the product that has been tapped on
        //let productIndex = Int( tagListView.tag / Constants.Offset.ProductMultiplier )
        // find the status of the product
        let code = tagListView.tag % Constants.TagValue.Product.Multiplier
        
         if code >= Constants.TagValue.Image {
            return ImageFetchResult.description(for: code - Constants.TagValue.Image)
        }
        
        return ProductFetchStatus.description(for: code)
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.setNeedsLayout()
    }

}
    
// MARK: - TagListView Delegate Functions
    
extension AllProductsTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        
        // find the product that has been tapped on
        let productIndex = Int( tagListView.tag / Constants.TagValue.Product.Multiplier )
        // find the status of the product
        let code = tagListView.tag % Constants.TagValue.Product.Multiplier
        // try to reload the product
        if code == ProductFetchStatus.productNotLoaded("").rawValue  ||
            code == ProductFetchStatus.loadingFailed("").rawValue {
            _ = products.loadProductPair(at: productIndex)
        }
    }
        
}
