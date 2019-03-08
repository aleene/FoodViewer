//
//  SingleSearchProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class SingleSearchProductTableViewController: UITableViewController {
    
    
    fileprivate struct Constants {
        
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
    
    // var selectedSearch: Search? = nil
    
    /*
    fileprivate func startInterface(at index:Int) {
        if let validProductPair = selectedSearch?.productPair(at: index),
            let validFetchResult = selectedSearch?.productPair(at: index)?.status {
            switch validFetchResult {
            case .available, .loading:
                selectedProductPair = validProductPair
                // tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
                showProductPage()
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
 */
    
    /*
    fileprivate func refreshInterface() {
        guard selectedSearch != nil else { return }
        guard selectedSearch!.productPairs.count > 0 else { return }
        tableView.reloadData()
    }
 */
    
    var productPageViewController: ProductPageViewController? = nil
    
    // Function to set the title of this viewController
    // It is important to set the title at the right moment in the lifecycle
    // Just after reloading the data seems to be the best moment.
    
    fileprivate func setTitle() {
        switch currentProductType {
        case .food:
            title = TranslatableStrings.FoodProducts
        case .petFood:
            title = TranslatableStrings.PetFoodProducts
        case .beauty:
            title = TranslatableStrings.BeautyProducts
        case .product:
            title = TranslatableStrings.SearchProducts
        }
        guard title != nil else { return }
    }
    
    // MARK: - Table view methods and vars
    
    var selectedProductPair: ProductPair? = nil {
        didSet {
            if selectedPageIndex == nil {
                selectedPageIndex = 0
            }
        }
    }
    
    fileprivate var selectedPageIndex: Int? = nil // this indicates which part of the product must be shown
    
    fileprivate var selectedRowType: RowType? = nil
    
    // is the current device in compact orientation?
    private var deviceHasCompactOrientation: Bool {
        get {
            return self.splitViewController?.traitCollection.horizontalSizeClass == .compact
        }
    }
    
    fileprivate func showProductPage() {
        // only segue if we are at the top of the stack
        if  let pVC = self.parent as? UINavigationController {
            //if let ppVC = pVC.parent as? UINavigationController {
              //  if let pppVC = ppVC.parent as? UINavigationController {
            if let parentParentVC = pVC.parent as? UISplitViewController {
            if let detailVC = parentParentVC.viewControllers.last as? UINavigationController,
            let ppvc = detailVC.childViewControllers.first as? ProductPageViewController {
            ppvc.productPair = selectedProductPair
            if let validSelectedRowType = selectedRowType,
                let validProductPair = selectedProductPair {
                switch validProductPair.barcodeType {
                case .search(let template, _):
                    if let validIndex = selectedPageIndex {
                        let array = template.searchPairsWithArray()
                        if array.count > 0 && validIndex < array.count {
                            ppvc.pageIndex = searchRowType(array[validIndex].0)
                        } else {
                            ppvc.pageIndex = .identification
                        }
                    }
                default:
                    ppvc.pageIndex = validSelectedRowType.productSection()
                }
            } else {
                ppvc.pageIndex = .identification
            }
        }
        }
            }
    //    }
     //   }
    }
    
    // The row types are mapped onto custom cells
    fileprivate enum RowType {
        case name
        case image
        case ingredientsAllergensTraces
        case ingredients
        case nutritionFacts
        case nutritionScore
        case categories
        case completion
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
            }
        }
    }
    
    // defines the order of the rows
    private var tableStructure: [RowType] {
        switch currentProductType {
        case .food:
            return [.name, .image, .nutritionScore, .ingredientsAllergensTraces, .nutritionFacts, .supplyChain, .categories, .completion]
        case .petFood:
            return [.name, .image, .ingredients, .nutritionFacts, .supplyChain, .categories, .completion]
        case .beauty:
            return [.name, .image, .ingredients, .supplyChain, .categories, .completion ]
        case .product:
            return [.name, .image, .ingredients, .supplyChain, .categories, .completion ]
        }
    }
    
    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let Name = "Single Search Product Name Cell Identifier"
            static let Image = "Single Search Product Image Cell Identifier"
            static let Ingredients = "Single Search Product Ingredients Cell Identifier"
            //static let IngredientsPage = "Ingredients Page Cell"
            //static let Countries = "Countries Cell"
            //static let NutritionFacts = "Product Nutrition Facts Name Cell"
            static let NutritionScore = "Single Search Product Nutrition Score Cell Identifier"
            static let Categories = "Single Search Product Categories Cell Identifier"
            static let Completion = "Single Search Product Completion Cell Identifier"
            //static let Producer = "Product Producer Cell"
            static let TagListView = "Single Search Product TagListView Cell Identifier"
        }
        struct SegueIdentifier {
            static let ToPageViewController = "Show Page Controller"
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Name, for: indexPath) as! NameTableViewCell
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
                let result = frontImages[language]?.small?.fetch() {
                switch result {
                case .success(let image):
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ImagesPageTableViewCell
                    cell.productImage = image
                    return cell
                default:
                    break
                }
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            return cell
        case .ingredientsAllergensTraces:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Ingredients, for: indexPath) as! IngredientsPageTableViewCell
            
            cell.ingredientsText = TranslatableStrings.Ingredients
            if let number = selectedProductPair?.remoteProduct?.numberOfIngredients {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                cell.ingredientsBadgeText = "\(number)"
            } else {
                cell.ingredientsBadgeText = TranslatableStrings.Undefined
            }
            
            cell.allergensText = TranslatableStrings.DetectedAllergens
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
            
        case .ingredients:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
            cell.labelText = TranslatableStrings.Ingredients
            if let number = selectedProductPair?.remoteProduct?.numberOfIngredients ?? selectedProductPair?.localProduct?.numberOfIngredients {
                cell.badgeText = number
            }
            return cell
            
        case .nutritionFacts:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
            cell.labelText = TranslatableStrings.NutritionFacts
            
            if let facts = selectedProductPair?.remoteProduct?.nutritionFactsDict ?? selectedProductPair?.localProduct?.nutritionFactsDict {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                cell.badgeText = "\(facts.count)"
            } else {
                cell.badgeText = TranslatableStrings.Undefined
            }
            return cell
            
        case .nutritionScore:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionScore, for: indexPath) as? NutritionScoreTableViewCell
            cell?.product = selectedProductPair?.remoteProduct ?? selectedProductPair?.localProduct
            return cell!
            
        case .categories:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
            cell.labelText = TranslatableStrings.Categories
            if let validCategories = selectedProductPair?.remoteProduct?.categoriesHierarchy ?? selectedProductPair?.localProduct?.categoriesOriginal {
                switch validCategories {
                case .undefined, .empty:
                    cell.badgeText = TranslatableStrings.Undefined
                case let .available(list):
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    cell.badgeText = "\(list.count)"
                case .notSearchable:
                    assert(true, "ProductTableViewController Error: How can I set a categorie is non-editable")
                }
            }
            return cell
            
        case .completion:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Completion, for: indexPath) as? CompletionTableViewCell
            cell?.product = selectedProductPair?.remoteProduct ?? selectedProductPair?.localProduct
            return cell!
            
        case .supplyChain:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Categories, for: indexPath) as! LabelWithBadgeTableViewCell
            cell.labelText = TranslatableStrings.SalesCountries
            if let validCountries = ( selectedProductPair?.remoteProduct?.countriesTranslated ?? selectedProductPair?.localProduct?.countriesOriginal ) {
                switch validCountries {
                case .available(let countries):
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    cell.badgeText = "\(countries.count)"
                default:
                    cell.badgeText = TranslatableStrings.Undefined
                }
            }
            return cell
        }
        //let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
        //return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedPageIndex = indexPath.row
        if let index = selectedPageIndex {
            selectedRowType = tableStructure[index]
        }
        showProductPage()
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
     */
    
    // http://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    /*
     override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     if let validFetchResult = products.productPair(at: section)?.remoteStatus {
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
    
    // MARK: - Scene changes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ToPageViewController:
                if let vc = segue.destination as? UINavigationController {
                    if let ppvc = vc.topViewController as? ProductPageViewController {
                        ppvc.productPair = selectedProductPair
                        if let validSelectedRowType = selectedRowType,
                            let validProductPair = selectedProductPair {
                            switch validProductPair.barcodeType {
                            case .search(let template, _):
                                if let validIndex = selectedPageIndex {
                                    let array = template.searchPairsWithArray()
                                    if array.count > 0 && validIndex < array.count {
                                        ppvc.pageIndex = searchRowType(array[validIndex].0)
                                    } else {
                                        ppvc.pageIndex = .identification
                                    }
                                }
                            default:
                                ppvc.pageIndex = validSelectedRowType.productSection()
                            }
                        } else {
                            ppvc.pageIndex = .identification
                        }
                    }
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
            message: TranslatableStrings.AddFrontImageMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "What to put?", style: .cancel) { (action: UIAlertAction) -> Void in
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
        if let barcodeString = userInfo![ProductPair.Notification.BarcodeKey] as? String,
            let validProductPair = selectedProductPair,
            barcodeString == validProductPair.barcodeType.asString {
                tableView.reloadData()
        }
    }

    /*
     @objc func searchLoaded(_ notification: Notification) {
     switchToTab(withIndex: 1)
     if let index = notification.userInfo?[OFFProducts.Notification.SearchOffsetKey] as? Int {
     startInterface(at:index >= 0 ? index : 0)
     showProductPage()
     }
     }
     
     @objc func searchStarted(_ notification: Notification) {
     switchToTab(withIndex: 1)
     if let firstPage = notification.userInfo?[OFFProducts.Notification.SearchPageKey] as? Int {
     // if there is no SearchOffSet, then the search just started
     // If it is the first page, position the interface on the first section
     if firstPage == 0 {
     startInterface(at:0)
     showProductPage()
     }
     }
     }
     */
    
    @IBOutlet var downTwoFingerSwipe: UISwipeGestureRecognizer!
    
    @IBAction func nextProductType(_ sender: UISwipeGestureRecognizer) {
        if let tabVC = self.parent?.parent as? UITabBarController {
            // start out with the history tab
            if tabVC.selectedIndex == 0 {
                Preferences.manager.cycleProductType()
                //selectedSearch?.reloadAll()
                //startInterface(at: 0)
                showProductPage()
            }
        }
    }
    
    // MARK: - Viewcontroller lifecycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.allowsSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if selectedProductPair != nil {
            tableView.reloadData()
            // show the productPage as detailVC
            showProductPage()
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
        if let validName = selectedProductPair?.name {
            title = validName
        }
        //tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
}

//
// MARK: - GKImagePickerDelegate Functions
//
extension SingleSearchProductTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        guard let validIndex = productIndexForMainImage else { return }
        guard let validLanguageCode =  selectedProductPair?.primaryLanguageCode else { return }
        selectedProductPair?.update(frontImage: image, for: validLanguageCode)
        imagePicker.dismiss(animated: true, completion: nil)
        // The app should now move to edit mode and the first page
        selectedRowType = .name
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ToPageViewController, sender: self)
    }
}

// MARK: - ButtonCellDelegate Functions


extension SingleSearchProductTableViewController: ButtonCellDelegate {
    // function to let the delegate know that a button was tapped
    func buttonTableViewCell(_ sender: ButtonTableViewCell, receivedTapOn button:UIButton) {
        /*
         if sender.tag < 0 {
         showAlertAddFrontImage(forProductWith: -1 * sender.tag)
         } else {
         products.fetchSearchProductsForNextPage()
         }
         */
    }
}
/*
 // MARK: - SearchHeaderDelegate Functions
 
 extension SingleProductTableViewController: SearchHeaderDelegate {
 
 func sortButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
 performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowSortOrder, sender: button)
 }
 
 func clearButtonTapped(_ sender: SearchHeaderView, button: UIButton) {
 if let validFetchResult = products.productPair(at: 0)?.remoteStatus {
 switch validFetchResult {
 case .searchQuery(let query):
 query.clear()
 products.reloadAll()
 tableView.reloadData()
 default:
 break
 }
 
 }
 }
 }
 */

// MARK: - UIGestureRecognizerDelegate Functions

extension SingleSearchProductTableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //Identify gesture recognizer and return true else false.
        return gestureRecognizer.isEqual(self.downTwoFingerSwipe) ? true : false
    }
}

// MARK: - UITabBarControllerDelegate Functions

extension SingleSearchProductTableViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
    
}

// MARK: - TagListViewCellDelegate Functions

extension SingleSearchProductTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}


// MARK: - TagListView DataSource Functions

extension SingleSearchProductTableViewController: TagListViewDataSource {
    
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
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
}

// MARK: - TagListView Delegate Functions

extension SingleSearchProductTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
        //tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
    }
    
}


// MARK: - UIPopoverPresentationControllerDelegate Functions

extension SingleSearchProductTableViewController: UIPopoverPresentationControllerDelegate {
    
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
