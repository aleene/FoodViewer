//
//  SingleProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class SingleProductTableViewController: UITableViewController {


    fileprivate struct Constants {
        
        struct Height {
            static let TagListCell = CGFloat(27.0)
        }
        struct Margin {
            static let TagListCell = CGFloat(11.0)
        }

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
        // All values >= 10 are used for defining rows
        // Values below 10 are used to encode the download status
        // There are no sections, so encoding/decoding is not needed
        
        struct TagValue {
            struct Row {
                static let Image = 10
                static let Diets = 20
            }
            struct Product {
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
    
    private var tagCellHeight = Constants.Height.TagListCell
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    fileprivate var products = OFFProducts.manager
    
    fileprivate func startInterface(at index:Int) {
        if let validProductPair = products.productPair(at: index),
            let validFetchResult = products.productPair(at: index)?.status {
            switch validFetchResult {
            case .available, .loading:
                selectedProductPair = validProductPair
                // if we are on the iPad we should show the first page of the product
                // Can we check on regular or compact width? Or if we are in a split view.
                if let vc = parent?.parent.self as? UISplitViewController {
                    if vc.viewControllers.count == 2 {
                        showProductPage()
                    }
                }
                
            default:
                selectedProductPair = nil
                tableView.reloadData()
            }
        } else {
            selectedProductPair = nil
            tableView.reloadData()
        }
        setTitle()
    }
    
    fileprivate func refreshInterface() {
        guard products.count > 0 else { return }
        tableView.reloadData()
    }
    
    var productPageViewController: ProductPageViewController? = nil
    
    // Function to set the title of this viewController
    // It is important to set the title at the right moment in the lifecycle
    // Just after reloading the data seems to be the best moment.
    
    fileprivate func setTitle() {
        title = selectedProductPair?.name ?? TranslatableStrings.NoName
    }
    
    // MARK: - Table view methods and vars
    
    var selectedProductPair: ProductPair? = nil {
        didSet {
            if let isExistingProduct = selectedProductPair?.localProduct?.hasImages, !isExistingProduct {
                selectedPageIndex = 1
            }
            if selectedPageIndex == nil {
                selectedPageIndex = 0
            }
        }
    }
    
    fileprivate var selectedPageIndex: Int? = nil // this indicates which part of the product must be shown
    
    // fileprivate var selectedRowType: RowType? = nil
    
    // is the current device in compact orientation?
    private var deviceHasCompactOrientation: Bool {
        get {
            return self.splitViewController?.traitCollection.horizontalSizeClass == .compact
        }
    }
    
    fileprivate func showProductPage() {
        if let validProductPageViewController = productPageViewController {
            validProductPageViewController.productPair = selectedProductPair
            validProductPageViewController.currentProductPage = tableStructure[selectedPageIndex ?? 0].productSection()
        }
    }
    
    fileprivate func showProductPage2() {
        if let validProductPageViewController = productPageViewController {
            validProductPageViewController.productPair = selectedProductPair
            validProductPageViewController.currentProductPage = tableStructure[selectedPageIndex ?? 0].productSection()
        } else {
            performSegue(withIdentifier: segueIdentifier(to: ProductPageViewController.self), sender: self)
        }
    }

    // The row types are mapped onto custom cells
    fileprivate enum RowType {
        case name
        case image
        case ingredientsAllergensTraces
        case ingredients
        case nutritionFacts
        case nutritionScore
        case environment
        case categories
        case completion
        case diets
        case supplyChain
        
        // map the row types to corresponding product sections
        func productSection() -> ProductPage {
            switch self {
            case .name:
                return .identification
            case .image:
                return .gallery
            case .ingredientsAllergensTraces, .ingredients:
                return .ingredients
            case .nutritionFacts:
                return .nutritionFacts
            case .nutritionScore:
                return .nutritionScore
            case .categories:
                return .categories
            case .completion:
                return .completion
            case .supplyChain:
                return .supplyChain
            case .diets:
                return .dietCompliancy
            case .environment:
                return .environment
            }
        }
    }
    
    // defines the order of the rows
    private var tableStructure: [RowType] {
        switch currentProductType {
        case .food:
            return [.name, .image, .nutritionScore, .ingredientsAllergensTraces, .diets, .nutritionFacts, .supplyChain, .environment, .categories, .completion]
        case .petFood:
            return [.name, .image, .ingredients, .nutritionFacts, .supplyChain, .categories, .completion]
        case .beauty:
            return [.name, .image, .ingredients, .supplyChain, .categories, .completion ]
        case .product:
            return [.name, .image, .ingredients, .supplyChain, .categories, .completion ]
        }
    }
    
    // The product is presented in a single section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Each row corresponds to a page of the pageViewControlle
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.row]
        switch currentProductSection {
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: NameTableViewCell.self), for: indexPath) as! NameTableViewCell
                    //print(productPair?.remoteProduct?.brandsOriginal, productPair?.localProduct?.brandsOriginal)
            if let validBrands = selectedProductPair?.remoteProduct?.brandsOriginal ?? selectedProductPair?.localProduct?.brandsOriginal {
                switch validBrands {
                case .undefined, .empty:
                    cell.productBrand = [validBrands.description()]
                case let .available(list):
                    cell.productBrand = list
                case .notSearchable:
                    assert(true, "ProductTableViewController Error: How can I set a brand a tag when the field is non-editable")
                }
            }
            return cell
                    
        case .image:
            if let language = selectedProductPair?.primaryLanguageCode,
                let frontImages = selectedProductPair?.remoteProduct?.frontImages ?? selectedProductPair?.localProduct?.frontImages,
                !frontImages.isEmpty,
                let result = frontImages[language]?.display?.fetch() {
                switch result {
                case .success(let image):
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ImagesPageTableViewCell.self), for: indexPath) as! ImagesPageTableViewCell
                        cell.productImage = image
                    cell.tag = Constants.TagValue.Row.Image
                    return cell
                default:
                    break
                }
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: nil, width: nil, tag: Constants.TagValue.Row.Image)
            return cell
            
        case .ingredientsAllergensTraces:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: IngredientsPageTableViewCell.self), for: indexPath) as! IngredientsPageTableViewCell
                    
            cell.ingredientsText = TranslatableStrings.Ingredients
            if let number = selectedProductPair?.remoteProduct?.numberOfIngredients {
                cell.ingredientsBadgeText = "\(number)"
            } else {
                cell.ingredientsBadgeText = TranslatableStrings.Undefined
            }
                    
            cell.allergensText = TranslatableStrings.Allergens
            if let validAllergens = selectedProductPair?.remoteProduct?.allergensTranslated ?? selectedProductPair?.localProduct?.allergensOriginal {
                switch validAllergens {
                case .available(let allergens):
                    cell.allergensBadgeText = "\(allergens.count)"
                default:
                    cell.allergensBadgeText = TranslatableStrings.Undefined
                }
            }
                    
            cell.tracesText = TranslatableStrings.Traces
            if let validTraces = selectedProductPair?.remoteProduct?.tracesInterpreted ?? selectedProductPair?.localProduct?.tracesOriginal {
                switch validTraces {
                case .available(let traces):
                    cell.tracesBadgeText = "\(traces.count)"
                default:
                    cell.tracesBadgeText = TranslatableStrings.Undefined
                }
            }
            return cell
            
        case .diets:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.tagListView.alignment = .left
            cell.setup(datasource: self, delegate: nil, width: tableView.frame.size.width - 16, tag: Constants.TagValue.Row.Diets)
            return cell
            
        case .ingredients:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: LabelWithBadgeTableViewCell.self), for: indexPath) as! LabelWithBadgeTableViewCell
                    cell.labelText = TranslatableStrings.Ingredients
            if let number = selectedProductPair?.remoteProduct?.numberOfIngredients ?? selectedProductPair?.localProduct?.numberOfIngredients {
                cell.badgeText = number
            }
            return cell
                    
        case .nutritionFacts:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: LabelWithBadgeTableViewCell.self), for: indexPath) as! LabelWithBadgeTableViewCell
                    cell.labelText = TranslatableStrings.NutritionFacts
                    
            if let facts = selectedProductPair?.remoteProduct?.nutritionFacts[.unprepared]
                ?? selectedProductPair?.localProduct?.nutritionFacts[.unprepared]
                ?? selectedProductPair?.remoteProduct?.nutritionFacts[.prepared]
                ?? selectedProductPair?.localProduct?.nutritionFacts[.prepared] {
                cell.badgeText = "\(facts.count)"
            } else {
                cell.badgeText = TranslatableStrings.Undefined
            }
            return cell
                    
        case .nutritionScore:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: NutritionScoreTableViewCell.self), for: indexPath) as? NutritionScoreTableViewCell
            cell?.product = selectedProductPair?.remoteProduct ?? selectedProductPair?.localProduct
            return cell!
                    
        case .environment:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: PackagingTableViewCell.self), for: indexPath) as? PackagingTableViewCell
            cell?.ecoscore = selectedProductPair?.remoteProduct?.ecoscore
            return cell!

        case .categories:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: LabelWithBadgeTableViewCell.self), for: indexPath) as! LabelWithBadgeTableViewCell
            cell.labelText = TranslatableStrings.Categories
            if let validCategories = selectedProductPair?.remoteProduct?.categoriesHierarchy ?? selectedProductPair?.localProduct?.categoriesOriginal {
                switch validCategories {
                case .undefined, .empty:
                    cell.badgeText = TranslatableStrings.Undefined
                case let .available(list):
                    cell.badgeText = "\(list.count)"
                case .notSearchable:
                    assert(true, "ProductTableViewController Error: How can I set a categorie is non-editable")
                }
            }
            return cell
                    
        case .completion:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: CompletionTableViewCell.self), for: indexPath) as? CompletionTableViewCell
                    cell?.product = selectedProductPair?.remoteProduct ?? selectedProductPair?.localProduct
            return cell!
                    
        case .supplyChain:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: LabelWithBadgeTableViewCell.self), for: indexPath) as! LabelWithBadgeTableViewCell
            cell.labelText = TranslatableStrings.SalesCountries
            if let validCountries = ( selectedProductPair?.remoteProduct?.countriesTranslated ?? selectedProductPair?.localProduct?.countriesOriginal ) {
                switch validCountries {
                case .available(let countries):
                    cell.badgeText = "\(countries.count)"
                default:
                    cell.badgeText = TranslatableStrings.Undefined
                }
            }
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPageIndex = indexPath.row
        showProductPage2()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableStructure[indexPath.row] {
        case .diets:
            return tagCellHeight + 2 * Constants.Margin.TagListCell
        default:
            break
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        }
    }

    // MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdentifier(to: ProductPageViewController.self):
                if let vc = segue.destination as? UINavigationController {
                    if let ppvc = vc.topViewController as? ProductPageViewController {
                        ppvc.productPair = selectedProductPair
                        ppvc.currentProductPage = tableStructure[selectedPageIndex ?? 0].productSection()
                        ppvc.sourcePage = self
                    }
                // on an iPhone?
                } else if let ppvc = segue.destination as? ProductPageViewController {
                    ppvc.productPair = selectedProductPair
                    ppvc.currentProductPage = tableStructure[selectedPageIndex ?? 0].productSection()
                    ppvc.sourcePage = self
                }

            default: break
            }
        }
    }
    
    // convert between the search categories and the display pages type
    private func searchRowType(_ component: SearchComponent) -> ProductPage {
        switch component {
        case .barcode, .searchText, .brand, .language, .packaging:
            return .identification
        case .category:
            return .categories
        case .country, .origin, .purchasePlace, .producerCode, .manufacturingPlaces, .store:
            return .supplyChain
        case .label, .additive, .trace, .allergen, .ingredient:
            return .ingredients
        case .contributor, .creator, .informer, .editor, .photographer, .corrector, .state, .checker, .lastEditDate, .entryDates:
            return .completion
        case .nutritionGrade:
            return .nutritionScore
        case .nutrient:
            return .nutritionFacts
            
        }
    }
    
    @objc func showAlertAddFrontImage(forProductWith index:Int) {
        let alert = UIAlertController(
            title: TranslatableStrings.AddFrontImage,
            message: TranslatableStrings.AddFrontImageMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Constants.AlertSheet.ActionTitleForCancel, style: .cancel) { (action: UIAlertAction) -> Void in
            // the user cancels to add image
        })
        alert.addAction(UIAlertAction(title: TranslatableStrings.AddFrontImageFromCamera, style: .destructive) { (action: UIAlertAction) -> Void in
            self.takePhoto(forProductWith: index)
        })
        alert.addAction(UIAlertAction(title: TranslatableStrings.AddFrontImageFromPhotos, style: .destructive) { (action: UIAlertAction) -> Void in
            self.selectCameraRollPhoto(forProductWith: index)
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    
    private var productIndexForMainImage: Int? = nil
    
    func takePhoto(forProductWith index:Int) {
        // opens the camera and allows the user to take an image and crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            productIndexForMainImage = index
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.delegate = self
            imagePicker.imagePickerController?.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .camera
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
    
    private func selectCameraRollPhoto(forProductWith index:Int) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            productIndexForMainImage = index
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .savedPhotosAlbum
            
            imagePicker.delegate = self
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
    
    @IBAction func unwindForCancel(_ segue:UIStoryboardSegue) {
        startInterface(at:0)
        showProductPage()
    }
    
    private func switchToTab(withIndex index: Int) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            tabVC.selectedIndex = index
        } else {
            assert(true, "ProductTableViewController:switchToTab: TabBar hierarchy error")
        }
        setTitle()
    }
    
    
    // MARK: - Notification methods
    
    // function is called if an product image has been retrieved via an asynchronous process
    @objc func imageSet(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil else { return }
        
        // only update if the image barcode corresponds to the current product
        if let barcodeString = userInfo![ProductImageData.Notification.BarcodeKey] as? String,
            let productBarcode = selectedProductPair?.barcodeType.asString,
            productBarcode == barcodeString {
                tableView.reloadData()
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
                setTitle()
                let visibleIndexPaths = self.tableView.indexPathsForVisibleRows
                let indexPathForProductPair = IndexPath(row: 0, section: index)
                if let validVisibleIndexPaths = visibleIndexPaths,
                    // only look for rows with an image
                    validVisibleIndexPaths.contains(indexPathForProductPair) {
                    tableView.reloadData()
                }
            }
        }
        /*
        // keep focus on selectedProduct
        if let validProductPair = selectedProductPair,
            let validIndex = products.index(of: validProductPair) {
            tableView.scrollToRow(at: IndexPath(row: 0, section: validIndex), at: .top, animated: true)
        }
 */
    }
    
    //
    @objc func firstProductLoaded(_ notification: Notification) {
        startInterface(at: 0)
        showProductPage()
    }

    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
                products.reloadAll()
                startInterface(at: 0)
                showProductPage()
            }
        }
    }
    
    // MARK: - Viewcontroller lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // splitViewController?.delegate = self
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
        }
        
        if let splitVC = self.splitViewController,
            let detailNavVC = splitVC.viewControllers.last as? UINavigationController,
            let pageVC = detailNavVC.topViewController as? ProductPageViewController {
            productPageViewController = pageVC
        }
        // show history products
        //products.list = .recent
        //products.search = nil
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.allowsSelection = true
        
        // Is there a scanned product?
        if let validSelectedProductIndex = products.currentScannedProduct {
            startInterface(at: validSelectedProductIndex)
        // has a selected product been passed in?
        } else if let validProductPair = selectedProductPair,
            let validIndex = products.index(of: validProductPair) {
            startInterface(at: validIndex)
        // just start at the top
        } else if products.count > 0 {
            // If nothing has been selected yet, start with the first product in the list, and on the iPad
            startInterface(at: 0)
        }
        
        showProductPage()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // add the back button
        if let rightNavController = splitViewController?.viewControllers.last as? UINavigationController,
            let detailViewController = rightNavController.topViewController as? UIPageViewController {
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
                detailViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        }
        
        
        // Notifications coming from ProductPair,
        // which indicate that something in the productPair has changed
        // either the local product or the remote product
        NotificationCenter.default.addObserver(self, selector:#selector(SingleProductTableViewController.productUpdated(_:)), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SingleProductTableViewController.productUpdated(_:)), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SingleProductTableViewController.firstProductLoaded(_:)), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SingleProductTableViewController.firstProductLoaded(_:)), name:.SampleLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SingleProductTableViewController.imageSet(_:)), name: .ImageSet, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTitle()
        refreshInterface()
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
// MARK: - GKImagePickerDelegate Functions
//
extension SingleProductTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        guard let validIndex = productIndexForMainImage else { return }
        guard let validLanguageCode =  products.productPair(at: validIndex)?.primaryLanguageCode else { return }
        products.productPair(at: validIndex)?.update(frontImage: image, for: validLanguageCode)
        imagePicker.dismiss(animated: true, completion: nil)
        // The app should now move to edit mode and the first page
        //selectedRowType = .name
        selectedProductPair = products.productPair(at: validIndex)
        performSegue(withIdentifier: segueIdentifier(to: ProductPageViewController.self), sender: self)
    }
}

// MARK: - ButtonCellDelegate Functions


extension SingleProductTableViewController: ButtonCellDelegate {
    // function to let the delegate know that a button was tapped
    func buttonTableViewCell(_ sender: ButtonTableViewCell, receivedTapOn button:UIButton) {
    }
}

// MARK: - UIGestureRecognizerDelegate Functions

extension SingleProductTableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Identify gesture recognizer and return true else false.
        return gestureRecognizer.isEqual(self.downTwoFingerSwipe) ? true : false
    }
}

// MARK: - UITabBarControllerDelegate Functions

extension SingleProductTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        startInterface(at: 0)
        showProductPage()
    }
    
}

// MARK: - TagListViewCellDelegate Functions

extension SingleProductTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}


// MARK: - TagListView DataSource Functions

extension SingleProductTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        if tagListView.tag == Constants.TagValue.Row.Image {
            return 1
        } else if tagListView.tag == Constants.TagValue.Row.Diets {
            if (selectedProductPair?.remoteProduct ?? selectedProductPair?.localProduct) != nil {
                return SelectedDietsDefaults.manager.selected.count
            }
        }
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if tagListView.tag == Constants.TagValue.Row.Image {
            if let language = selectedProductPair?.primaryLanguageCode,
                let frontImages = selectedProductPair?.remoteProduct?.frontImages ?? selectedProductPair?.localProduct?.frontImages,
                !frontImages.isEmpty,
                let result = frontImages[language]?.small?.fetch() {
                switch result {
                case .uploading:
                    return ImageFetchResult.description(for: Constants.TagValue.Row.Image)
                default:
                    break
                }
            }
            return TranslatableStrings.NoImageAvailable

        } else if tagListView.tag == Constants.TagValue.Row.Diets {
            if (selectedProductPair?.remoteProduct ?? selectedProductPair?.localProduct) != nil{
            let dietKey = SelectedDietsDefaults.manager.selected[index]
            //let conclusion = Diets.manager.conclusion(validProduct, forDietWith:dietKey)
            return Diets.manager.name(forDietWith: dietKey, in:Locale.interfaceLanguageCode) ?? "No diet name found "
            // return (name ?? "No diet name found ") + "\(conclusion ?? 0)"
            }
        }
        
        return ProductFetchStatus.description(for: tagListView.tag)
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        if tagListView.tag == Constants.TagValue.Row.Diets {
            if let validProduct = selectedProductPair?.remoteProduct ?? selectedProductPair?.localProduct {
                let dietKey = SelectedDietsDefaults.manager.selected[index]
                guard let validConclusion = Diets.manager.conclusion(validProduct, forDietWith:dietKey) else { return nil }
                switch validConclusion {
                case -13:
                    return ColorScheme(text: .white, background: .systemPurple, border: .systemPurple)
                case -2:
                    return ColorScheme(text: .white, background: .systemRed, border: .systemRed)
                case -1:
                    return ColorScheme(text: .white, background: .systemOrange, border: .systemOrange)
                case 0:
                    return ColorScheme(text: .black, background: .systemYellow, border: .lightGray)
                case 1:
                    return ColorScheme(text: .white, background: .systemGreen, border: .systemGreen)
                case 2:
                    return ColorScheme(text: .white, background: .darkGray, border: .darkGray)
                case 3:
                    return ColorScheme(text: .white, background: .black, border: .black)
                default:
                    return ColorScheme(text: .black, background: .white, border: .white)
                }
            }
        } else if tagListView.tag == Constants.TagValue.Row.Image {
            return ColorScheme(text: .white, background: .systemRed, border: .systemRed)
        }
        return nil
    }

    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        if abs(tagCellHeight - height) > CGFloat(3.0) {
            tagCellHeight = height
            tableView.setNeedsLayout()
        }
    }

}

// MARK: - UIPopoverPresentationControllerDelegate Functions

extension SingleProductTableViewController: UIPopoverPresentationControllerDelegate {
    
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


// MARK: - UIDragInteractionDelegate Functions

@available(iOS 11.0, *)
extension SingleProductTableViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if let validFetchResult = products.productPair(at: indexPath.section)?.remoteStatus,
            let validProduct = products.productPair(at: indexPath.section)?.remoteProduct {
            switch validFetchResult {
            case .available:
                let currentProductSection = tableStructure[indexPath.row]
                switch currentProductSection {
                case .image:
                    if let language = validProduct.primaryLanguageCode,
                        !validProduct.frontImages.isEmpty,
                        let fetchResult = validProduct.frontImages[language]?.largest?.fetch() {
                        switch fetchResult {
                        case .success(let image):
                            let provider = NSItemProvider(object: image)
                            let item = UIDragItem(itemProvider: provider)
                            item.localObject = image
                            return [item]
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            default:
                break
            }
            
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let currentProductSection = tableStructure[indexPath.row]
        switch currentProductSection {
        case .image :
            if let cell = tableView.cellForRow(at: indexPath) as? ImagesPageTableViewCell {
                if let rect = cell.productImageView.imageRect {
                    let parameters = UIDragPreviewParameters.init()
                    parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
                    return parameters
                }
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        
        // only allow flocking of another image
        for item in session.items {
            // Note kUTTypeImage needs an import of MobileCoreServices
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        if let validFetchResult = products.productPair(at: indexPath.section)?.remoteStatus,
            let validProduct = products.productPair(at: indexPath.section)?.remoteProduct {
            switch validFetchResult {
            case .available:
                let currentProductSection = tableStructure[indexPath.row]
                switch currentProductSection {
                case .image:
                    if let language = validProduct.primaryLanguageCode,
                        !validProduct.frontImages.isEmpty,
                        let fetchResult = validProduct.frontImages[language]?.largest?.fetch() {
                        switch fetchResult {
                        case .success(let image):
                            // check if the selected image has not been added yet
                            for item in session.items {
                                guard item.localObject as! UIImage != image else { return [] }
                            }
                            let provider = NSItemProvider(object: image)
                            let item = UIDragItem(itemProvider: provider)
                            item.localObject = image
                            return [item]
                        default:
                            break
                        }
                    }
                default:
                    break
                }
            default:
                break
            }
        }
        return []
    }
    
}

extension SingleProductTableViewController: UISplitViewControllerDelegate {

}
