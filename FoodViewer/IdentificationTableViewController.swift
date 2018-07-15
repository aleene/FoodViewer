//
//  IdentificationTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class IdentificationTableViewController: UITableViewController {
    
    private struct TextConstants {
        static let ShowIdentificationTitle = TranslatableStrings.Image
        static let ViewControllerTitle = TranslatableStrings.Identification
        static let NoCommonName = TranslatableStrings.NoGenericNameAvailable
        static let NoName = TranslatableStrings.NoName
        static let NoQuantity = TranslatableStrings.NoQuantityAvailable
    }
    
    fileprivate var tableStructure: [SectionType] = []
    
    fileprivate enum SectionType {
        case barcode(Int, String)
        case barcodeSearch(Int, String)
        case name(Int, String)
        case nameSearch(Int, String)
        case genericName(Int, String)
        case genericNameSearch(Int, String)
        case languages(Int, String)
        case languagesSearch(Int, String)
        case brands(Int, String)
        case brandsSearch(Int, String)
        case packaging(Int, String)
        case packagingSearch(Int, String)
        case quantity(Int, String)
        case quantitySearch(Int, String)
        case image(Int, String)
        case imageSearch(Int, String)
        
        var header: String {
            switch self {
            case .barcode(_, let headerTitle),
                 .barcodeSearch(_, let headerTitle),
                 .name(_, let headerTitle),
                 .nameSearch(_, let headerTitle),
                 .genericName(_, let headerTitle),
                 .genericNameSearch(_, let headerTitle),
                 .languages(_, let headerTitle),
                 .languagesSearch(_, let headerTitle),
                 .brands(_, let headerTitle),
                 .brandsSearch(_, let headerTitle),
                 .packaging(_, let headerTitle),
                 .packagingSearch(_, let headerTitle),
                 .quantity(_, let headerTitle),
                 .quantitySearch(_, let headerTitle),
                 .image(_, let headerTitle),
                 .imageSearch(_, let headerTitle):
                return headerTitle
            }
        }
        
        var numberOfRows: Int {
            switch self {
            case .barcode(let numberOfRows, _),
                 .barcodeSearch(let numberOfRows, _),
                 .name(let numberOfRows, _),
                 .nameSearch(let numberOfRows, _),
                 .genericName(let numberOfRows, _),
                 .genericNameSearch(let numberOfRows, _),
                 .languages(let numberOfRows, _),
                 .languagesSearch(let numberOfRows, _),
                 .brands(let numberOfRows, _),
                 .brandsSearch(let numberOfRows, _),
                 .packaging(let numberOfRows, _),
                 .packagingSearch(let numberOfRows, _),
                 .quantity(let numberOfRows, _),
                 .quantitySearch(let numberOfRows, _),
                 .image(let numberOfRows, _),
                 .imageSearch(let numberOfRows, _):
                return numberOfRows
            }
        }
    }
    
    private var selectedSection: Int? = nil
    
    fileprivate enum ProductVersion {
        //case local
        case remote
        case new // mix of local and remote
    }
    
    // Determines which version of the product needs to be shown, the remote or local
    
    fileprivate var productVersion: ProductVersion = .new

    // MARK: - public variables
    
    public var tableItem: ProductPair? = nil {
        didSet {
            if let validProductPair = tableItem {
                switch validProductPair.barcodeType {
                case .search(let template, _):
                    self.query = template
                    self.productPair = nil
                default:
                    self.productPair = validProductPair
                    query = nil
                }
            }
        }
    }
    
    fileprivate var productPair: ProductPair? {
        didSet {
            if productPair != nil {
                tableStructure = setupSections()
                //currentLanguageCode = newCurrentLanguage
                refreshProduct()
            }
        }
    }
    
    fileprivate var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                tableStructure = setupSections()
                refreshProduct()
            }
        }
    }
    
    var delegate: ProductPageViewController? = nil
    
    var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }

    // The languageCode as defined by the user (double tapping/selecting)
    // The user can set for which language he wants to see the name/genericName and front image
    var currentLanguageCode: String? = nil {
        didSet {
            if currentLanguageCode != oldValue {
                // reload the name/generic name/image
                //let indexPaths = [IndexPath.init(row: 0, section: 1),
                 //                 IndexPath.init(row: 0, section: 2),
                  //                IndexPath.init(row: 0, section: 6)]
                // tableView.reloadSections([1,2,7], with: .fade)
                tableView.reloadData()
                //tableView.deselectRow(at: indexPaths.first!, animated: true)
                //tableView.deselectRow(at: indexPaths.last!, animated: true)
            }
        }
    }
    
    // This variable defined the languageCode that must be used to display the product data
    // This is either the languageCode selected by the user or the best match for the current product
    private var displayLanguageCode: String? {
        return currentLanguageCode ?? productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }
    
// MARK: - Fileprivate Functions/variables
    
    fileprivate var nameToDisplay: Tags {
        get {
            switch productVersion {
            case .remote:
                guard let validLanguageCode = displayLanguageCode else { return .empty }
                guard let text = productPair?.remoteProduct?.nameLanguage[validLanguageCode] else { return .empty }
                guard let validText = text else { return .empty }
                return Tags.init(text: validText)
            //case .local:
            //    guard let validLanguageCode = currentLanguageCode else { return .empty }
            //    guard let text = productPair?.localProduct?.nameLanguage[validLanguageCode] else { return .empty }
            //    guard let validText = text else { return .empty }
            //    return Tags.init(text: validText)
            case .new:
                guard let validLanguageCode = displayLanguageCode else { return .empty }
                guard let text = productPair?.localProduct?.nameLanguage[validLanguageCode] ??
                    productPair?.remoteProduct?.nameLanguage[validLanguageCode] else { return .empty }
                guard let validText = text else { return .empty }
                return Tags.init(text: validText)
            }
        }
    }

    fileprivate var genericNameToDisplay: Tags {
        get {
            switch productVersion {
            case .remote:
                guard let validLanguageCode = displayLanguageCode else { return .empty }
                guard let text = productPair?.remoteProduct?.genericNameLanguage[validLanguageCode] else { return .empty }
                guard let validText = text else { return .empty }
                return Tags.init(text: validText)
            //case .local:
            //    guard let validLanguageCode = currentLanguageCode else { return .empty }
            //    guard let text = productPair?.localProduct?.genericNameLanguage[validLanguageCode] else { return .empty }
            //    guard let validText = text else { return .empty }
            //    return Tags.init(text: validText)
            case .new:
                guard let validLanguageCode = displayLanguageCode else { return .empty }
                guard let text = productPair?.localProduct?.genericNameLanguage[validLanguageCode] ?? productPair?.remoteProduct?.genericNameLanguage[validLanguageCode] else { return .empty }
                guard let validText = text else { return .empty }
                return Tags.init(text: validText)
            }
        }
    }

    fileprivate var primaryLanguageCodeToDisplay: String {
        get {
            switch productVersion {
            case .remote:
                return productPair?.remoteProduct?.primaryLanguageCode ?? productPair?.localProduct?.primaryLanguageCode ?? TranslatableStrings.QuestionMark
            case .new:
                return productPair?.localProduct?.primaryLanguageCode ?? productPair?.remoteProduct?.primaryLanguageCode ?? TranslatableStrings.QuestionMark
            }
        }
    }

    fileprivate var quantityToDisplay: Tags {
        get {
            switch productVersion {
            case .remote:
                guard let text = productPair?.remoteProduct?.quantity else { return .empty }
                return Tags.init(text: text)
            //case .local:
            //    guard let text = productPair?.localProduct?.quantity else { return .empty }
            //    return Tags.init(text: text)
            case .new:
                guard let text = productPair?.localProduct?.quantity ??
                productPair?.remoteProduct?.quantity else { return .empty }
                return Tags.init(text: text)
            }
        }
    }

    fileprivate var brandsToDisplay: Tags {
        get {
            switch productVersion {
            case .remote:
                switch showBrandTagsType {
                case .interpreted:
                    return productPair?.remoteProduct?.brandsInterpreted ?? .undefined
                case .original:
                    return productPair?.remoteProduct?.brandsOriginal ?? .undefined
                default:
                    return .undefined
                }
            //case .local:
            //    return productPair?.localProduct?.brandsOriginal ?? .undefined
            case .new:
                if let oldTags = productPair?.localProduct?.brandsOriginal {
                    switch oldTags {
                    case .available:
                        return oldTags
                    default:
                        break
                    }
                }
                if let oldTags = productPair?.remoteProduct?.brandsOriginal {
                    switch oldTags {
                    case .available:
                        return oldTags
                    default:
                        break
                    }
                }
                return .undefined
            }
        }
    }
    
    fileprivate var searchBrandsToDisplay: Tags {
        get {
            if let (tags, _) = query?.brands {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var notSearchableToDisplay: Tags {
        get {
            return .notSearchable
        }
    }

    fileprivate var searchPackagingToDisplay: Tags {
        get {
            if let (tags, _) = query?.packaging {
                return tags
            }
            return .undefined
        }
    }

    fileprivate var searchLanguagesToDisplay: Tags {
        get {
            if let (tags, _) = query?.languages {
                return tags
            }
            return .undefined
        }
    }

    private struct TagsTypeDefault {
        static let Brands: TagsType = .original
        static let Packaging: TagsType = .prefixed
        static let Languages: TagsType = .translated
        static let Name: TagsType = .original
        static let GenericName: TagsType = .original
        static let Quantity: TagsType = .original
    }
    
    fileprivate var showPackagingTagsType: TagsType = TagsTypeDefault.Packaging
    fileprivate var showBrandTagsType: TagsType = TagsTypeDefault.Brands
    fileprivate var showNameTagsType: TagsType = TagsTypeDefault.Name
    fileprivate var showGenericNameTagsType: TagsType = TagsTypeDefault.GenericName
    fileprivate var showQuantityTagsType: TagsType = TagsTypeDefault.Quantity

    private var showLanguagesTagsType: TagsType = TagsTypeDefault.Languages

    fileprivate var packagingToDisplay: Tags {
        get {
            switch productVersion {
            case .remote:
                return remotePackaging
            //case .local:
            //    return productPair?.localProduct?.packagingOriginal ?? .undefined
            case .new:
                if let packaging = productPair?.localProduct?.packagingOriginal {
                    switch packaging {
                    case .available:
                        return packaging
                    default:
                        break
                    }
                }
                switch remotePackaging {
                case .available:
                    return remotePackaging
                default:
                    break
                }
                return .undefined
            }
        }
    }
    
    fileprivate var languagesToDisplay: Tags {
        get {
            switch productVersion {
            case .remote:
                return remoteLanguages
            //case .local:
            //    return productPair?.localProduct?.languageTags ?? .undefined
            case .new:
                return productPair?.localProduct?.languageTags ?? remoteLanguages
            }
        }
    }
    
    private var remoteLanguages: Tags {
        switch showLanguagesTagsType {
        case .translated:
            // show the languageCodes in a localized language
            return productPair?.remoteProduct?.languageTags ?? .undefined
        default:
            return .undefined
        }
    }
    
    private var remotePackaging: Tags {
        switch showPackagingTagsType {
        case .interpreted:
            return productPair?.remoteProduct?.packagingInterpreted ?? .undefined
        case .original:
            return productPair?.remoteProduct?.packagingOriginal ?? .undefined
        case .hierarchy:
            return productPair?.remoteProduct?.packagingHierarchy ?? .undefined
        case .prefixed:
            return productPair?.remoteProduct?.packagingOriginal.prefixed(withAdded:productPair?.remoteProduct?.primaryLanguageCode ?? "??", andRemoved:Locale.interfaceLanguageCode) ?? .undefined
        case .translated:
            return .undefined
        }
    }

    fileprivate var searchResult: String = ""

    // MARK: - Action methods
    
    // should redownload the current product and reload it in this scene
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let TextField = "Identification Basic Cell"
            static let ProductName = "Product Name Cell"
            static let Barcode = "Barcode Cell"
            static let BarcodeEdit = "Barcode Edit Cell"
            static let Quantity = "Quantity Cell"
            static let TagListView = "TagListView Cell"
            // static let Packaging = "Identification Packaging Cell"
            static let TagListViewWithSegmentedControl = "TagListView With SegmentedControl Cell"
            static let Image = "Identification Image Cell"
            static let TagListViewAddImage = "Identification TagListView Add Image Cell"
            static let TagListViewButton = "TagListView Button Cell"
        }
        struct SegueIdentifier {
            static let ShowIdentificationImage = "Show Identification Image"
            static let ShowNamesLanguages = "Show Names Languages"
            static let ShowSelectMainLanguage = "Show Select Main Language Segue"
            static let ShowImageSourceSelector = "Show Select Image Source Segue"
            static let ShowAddLanguage = "Show Extend Languages Segue"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections
        return tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print(tableView.frame.size.width)
        switch tableStructure[indexPath.section] {
        case .barcode:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Barcode, for: indexPath) as! BarcodeTableViewCell
            cell.barcode = productPair?.barcodeType.asString
            cell.mainLanguageCode = primaryLanguageCodeToDisplay
            cell.editMode = editMode
            return cell
            
        case .barcodeSearch:
            if query?.barcode != nil || editMode {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BarcodeEdit, for: indexPath) as! BarcodeEditTableViewCell
                cell.barcode = query?.barcode
                cell.delegate = self
                cell.editMode = editMode
                cell.tag = indexPath.section
                cell.barcodeTextField.placeholder = TranslatableStrings.EnterBarcode
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.editMode = false
                cell.tag = indexPath.section
                return cell
            }
            
        case .quantitySearch, .imageSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.editMode = false
            cell.tag = indexPath.section
            cell.tagListView.normalColorScheme = ColorSchemes.error
            return cell
            
        case .nameSearch, .genericNameSearch:
            if query?.text != nil || editMode {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ProductName, for: indexPath) as! ProductNameTableViewCell
                cell.delegate = self
                if let validQueryText = query?.text {
                    cell.name =  validQueryText
                } else {
                    cell.name =  editMode ? nil : TranslatableStrings.PlaceholderProductNameSearch
                }
                cell.tag = indexPath.section
                cell.editMode = query!.type == .simple ? false : editMode
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.editMode = false
                cell.tag = indexPath.section
                return cell
            }
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ProductName, for: indexPath) as! ProductNameTableViewCell
            cell.delegate = self
            cell.tag = indexPath.section
            cell.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            cell.name = editMode ? TranslatableStrings.PlaceholderProductName : nil
            cell.nameTextView.textColor = .gray
            switch nameToDisplay {
            case .available(let array):
                if !array.isEmpty && !array.first!.isEmpty {
                    cell.name = array.first
                    cell.nameTextView.textColor = .black
                }
            default:
                break
            }
            return cell
            
        case .genericName:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ProductName, for: indexPath) as! ProductNameTableViewCell
            cell.delegate = self
            cell.tag = indexPath.section
            cell.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            cell.name = editMode ? TranslatableStrings.PlaceholderGenericProductName : nil
            cell.nameTextView.textColor = .gray
            switch genericNameToDisplay {
            case .available(let array):
                if !array.isEmpty && !array.first!.isEmpty {
                    cell.name = array.first
                    cell.nameTextView.textColor = .black
                }
            default:
                break
            }
            return cell

        case .languages:
            if editMode {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewButton, for: indexPath) as! TagListViewButtonTableViewCell
                cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.delegate = self
                cell.editMode = query != nil ? editMode : false
                cell.tag = indexPath.section
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.delegate = self
                cell.editMode = query != nil ? editMode : false
                cell.tag = indexPath.section

                return cell
            }
        case .brands, .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            //print("Cell", cell.frame)

            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            return cell
            
        case .brandsSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.allowInclusionEdit = query!.type != .simple
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.brands.1 ?? true
            return cell
            
        case  .languagesSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.allowInclusionEdit = query!.type != .simple
            cell.inclusion = OFFProducts.manager.searchQuery?.languages.1 ?? true
            return cell

        case .packagingSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.packaging.1 ?? true
            cell.allowInclusionEdit = query!.type != .simple
            return cell
            
        case .quantity:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Quantity, for: indexPath) as! QuantityTableViewCell
            switch quantityToDisplay {
            case .available(let array):
                cell.tekst = array[0]
            default:
                cell.tekst = nil
            }
            cell.editMode = editMode
            cell.delegate = self
            cell.tag = indexPath.section
            return cell
            
        case .image:
            if currentImage.0 != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                cell.productImage = currentImage.0
                cell.delegate = self
                return cell
            } else {
                searchResult = currentImage.1
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewAddImage, for: indexPath) as! TagListViewAddImageTableViewCell
                cell.width = tableView.frame.size.width
                cell.scheme = ColorSchemes.error
                cell.editMode = editMode
                cell.datasource = self
                cell.delegate = self
                cell.tag = indexPath.section
                cell.accessoryType = .none
                return cell
            }

        }
    }
    
    
    public var currentImage: (UIImage?, String) {
        switch productVersion {
        //case .local:
        //    return localFrontImage ?? (nil, TranslatableStrings.NoImageAvailable)
        case .remote:
            return remoteFrontImage ?? (nil, TranslatableStrings.NoImageAvailable)
        case .new:
            return localFrontImage ?? remoteFrontImage ?? ( nil,TranslatableStrings.NoImageAvailable)
        }
    }
    
    private var localFrontImage: (UIImage?, String)? {
        if let frontImages = productPair?.localProduct?.frontImages,
            let validLanguageCode = displayLanguageCode,
            !frontImages.isEmpty,
            let fetchResult = frontImages[validLanguageCode]?.original?.fetch() {
            switch fetchResult {
            case .success(let image):
                return (image, "Updated Image")
            default: break
            }
        }
        return nil
    }
    
    private var remoteFrontImage: (UIImage?, String)? {
        // are there any updated front images?
        if let frontImages = productPair?.remoteProduct?.frontImages,
            let validLanguageCode = displayLanguageCode,
            !frontImages.isEmpty,
            let result = frontImages[validLanguageCode]?.display?.fetch() {
            switch result {
            case .success(let image):
                return (image, "Current Language Image")
            case .loading:
                return (nil, ImageFetchResult.loading.description)
            case .loadingFailed(let error):
                return (nil, error.localizedDescription)
            case .noResponse:
                return (nil, ImageFetchResult.noResponse.description)
            default:
                break
            }
            // fall back to the primary languagecode nutrition image
            // if we are NOT in edit mode
        } else if !editMode,
            let primaryLanguageCode = productPair?.remoteProduct?.primaryLanguageCode,
            let image = productPair?.remoteProduct?.frontImages[primaryLanguageCode]?.display,
            let fetch = image.fetch() {
            switch fetch {
            case .success(let image):
                return (image, "Current Language Image")
            case .loading:
                return (nil, ImageFetchResult.loading.description)
            case .loadingFailed(let error):
                return (nil, error.localizedDescription)
            case .noResponse:
                return (nil, ImageFetchResult.noResponse.description)
            default:
                break
            }
        }
        // No relevant image is available
        return nil
    }

    fileprivate var currentProductImageSize: ProductImageSize? {
        // are there any updated front images?
        if let frontImages = productPair?.localProduct?.frontImages,
            !frontImages.isEmpty,
            let validLanguageCode = displayLanguageCode {
            // Is there an updated image corresponding to the current language
            if let productImageSize = frontImages[validLanguageCode] {
                return productImageSize
            }
            
            // try the regular front images
        } else if !productPair!.remoteProduct!.frontImages.isEmpty,
            let validLanguageCode = displayLanguageCode {
            // is the data for the current language available?
            if let productImageSize = productPair!.remoteProduct!.frontImages[validLanguageCode] {
                return productImageSize
                // fall back to the primary languagecode nutrition image
                // if we are NOT in edit mode
            } else if !editMode,
                let primaryLanguageCode = productPair!.remoteProduct!.primaryLanguageCode,
                let productImageSize = productPair!.remoteProduct!.frontImages[primaryLanguageCode] {
                return productImageSize
            }
        }
        // No relevant imageData is available
        return nil
    }

    func changeLanguage() {
        // set the next language in the array
        if let availableLanguages = productPair!.remoteProduct?.languageCodes {
            if availableLanguages.count > 1 && currentLanguageCode != nextLanguageCode() {
                currentLanguageCode = nextLanguageCode()
            }
        }
    }
    
    fileprivate func nextLanguageCode() -> String {
        if let product = productPair?.remoteProduct {
            if let validLanguageCode = currentLanguageCode,
                let currentIndex = product.languageCodes.index(of: validLanguageCode) {
                    let nextIndex = currentIndex == ( product.languageCodes.count - 1 ) ? 0 : currentIndex + 1
                    return product.languageCodes[nextIndex]
            } else {
                if let code = product.primaryLanguageCode {
                    return code
                }
            }
        }
        return "??"
    }
        
    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentProductSection = tableStructure[section]
        switch currentProductSection {
        case .barcode:
            switch productVersion {
            case .remote:
                break
            case .new:
                if productPair?.localProduct != nil && productPair?.localProduct?.primaryLanguageCode != productPair?.remoteProduct?.primaryLanguageCode {
                    return tableStructure[section].header + " " + TranslatableStrings.EditedInParentheses
                }
            }
            
        case .image, .name, .genericName :
            return nil
            
        case .brands:
            switch productVersion {
            case .remote:
                break
            case .new:
                if let oldTags = productPair?.localProduct?.brandsOriginal {
                    switch oldTags {
                    case .available:
                        return tableStructure[section].header +
                            " " +
                            "(" +
                            TranslatableStrings.Edited +
                        ")"
                    default:
                        break
                    }
                }
            }
        case .packaging:
            switch productVersion {
            case .remote:
                switch showPackagingTagsType {
                case TagsTypeDefault.Packaging:
                    return tableStructure[section].header
                default:
                    return tableStructure[section].header +
                        " " +
                        "(" +
                        showPackagingTagsType.description +
                        ")"
                }
            case .new:
                if let oldTags = productPair?.localProduct?.packagingOriginal {
                    switch oldTags {
                    case .available:
                        return tableStructure[section].header +
                            " " +
                            "(" +
                        TranslatableStrings.Edited +
                    ")"
                    default:
                        break
                    }
                }
            }
        default:
            break
        }
        return tableStructure[section].header
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentProductSection = tableStructure[section]
        
        switch currentProductSection {
        case .image, .name, .genericName, .barcode :
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LanguageHeaderView") as! LanguageHeaderView
            headerView.section = section
            headerView.delegate = self
            headerView.title = tableStructure[section].header
            switch productVersion {
            case .remote:
                break
            case .new:
                switch currentProductSection {
                case .image:
                    guard let localPair = localFrontImage else { break }
                    if localPair.0 != nil {
                        headerView.title = tableStructure[section].header + " " + TranslatableStrings.EditedInParentheses
                    }
                case .name:
                    guard let validLanguageCode = displayLanguageCode else { break }
                    if productPair?.localProduct?.nameLanguage[validLanguageCode] != nil {
                        headerView.title = tableStructure[section].header + " " + TranslatableStrings.EditedInParentheses
                    }
                case .genericName :
                    guard let validLanguageCode = displayLanguageCode else { break }
                    if productPair?.localProduct?.genericNameLanguage[validLanguageCode] != nil {
                        headerView.title = tableStructure[section].header + " " + TranslatableStrings.EditedInParentheses
                    }
                default:
                    break
                }
            }
            headerView.buttonText = OFFplists.manager.languageName(for: displayLanguageCode)
            if let validCount = productPair?.remoteProduct?.languageCodes.count {
                headerView.buttonIsEnabled = editMode ? true : ( validCount > 1 ? true : false )
            } else {
                headerView.buttonIsEnabled = false
            }
            return headerView
        default:
            return nil
        }
    }


    fileprivate struct TableSection {
        struct Size {
            static let Barcode = 1
            static let Name = 1
            static let CommonName = 1
            static let Languages = 1
            static let Brands = 1
            static let Packaging = 1
            static let Quantity = 1
            static let Image = 1
        }
        struct Header {
            static let Barcode = TranslatableStrings.Barcode
            static let Name = TranslatableStrings.Name
            static let CommonName = TranslatableStrings.CommonName
            static let Languages = TranslatableStrings.Languages
            static let Brands = TranslatableStrings.Brands
            static let Packaging = TranslatableStrings.Packaging
            static let Quantity = TranslatableStrings.Quantity
            static let Image = TranslatableStrings.MainImage
        }
    }

    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        
        if query != nil {
            sectionsAndRows.append(.barcodeSearch(TableSection.Size.Barcode, TableSection.Header.Barcode))
            sectionsAndRows.append(.nameSearch(TableSection.Size.Name, TableSection.Header.Name))
            sectionsAndRows.append(.genericNameSearch(TableSection.Size.CommonName, TableSection.Header.CommonName))
            sectionsAndRows.append(.languagesSearch(TableSection.Size.Languages, TableSection.Header.Languages))
            sectionsAndRows.append(.brandsSearch(TableSection.Size.Brands, TableSection.Header.Brands))
            sectionsAndRows.append(.packagingSearch(TableSection.Size.Packaging, TableSection.Header.Packaging))
            sectionsAndRows.append(.quantitySearch(TableSection.Size.Quantity, TableSection.Header.Quantity))
            sectionsAndRows.append(.imageSearch(TableSection.Size.Image, TableSection.Header.Image))

        } else {
            sectionsAndRows.append(.barcode(TableSection.Size.Barcode, TableSection.Header.Barcode))
            sectionsAndRows.append(.name(TableSection.Size.Name, TableSection.Header.Name))
            sectionsAndRows.append(.genericName(TableSection.Size.CommonName, TableSection.Header.CommonName))
            sectionsAndRows.append(.languages(TableSection.Size.Languages, TableSection.Header.Languages))
            sectionsAndRows.append(.brands(TableSection.Size.Brands, TableSection.Header.Brands))
            sectionsAndRows.append(.packaging(TableSection.Size.Packaging, TableSection.Header.Packaging))
            sectionsAndRows.append(.quantity(TableSection.Size.Quantity, TableSection.Header.Quantity))
            sectionsAndRows.append(.image(TableSection.Size.Image,TableSection.Header.Image))
       }
        
        return sectionsAndRows
    }

    // MARK: - Segue stuff

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowIdentificationImage:
                if let vc = segue.destination as? ImageViewController,
                    let validLanguageCode = displayLanguageCode {
                    vc.imageTitle = TextConstants.ShowIdentificationTitle
                    // is there an updated image?
                    if let localProduct = productPair?.localProduct,
                        !localProduct.frontImages.isEmpty {
                        vc.imageData = localProduct.image(for:validLanguageCode, of:.front)
                    } else {
                        vc.imageData = productPair?.localProduct?.image(for:validLanguageCode, of:.front)
                    }
                }
            case Storyboard.SegueIdentifier.ShowNamesLanguages:
                if let vc = segue.destination as? SelectLanguageViewController {
                    // The segue can only be initiated from a button within a ProductNameTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview?.superview as? UITableView != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                ppc.delegate = self
                                
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentLanguageCode = displayLanguageCode
                                vc.primaryLanguageCode = productPair?.localProduct?.primaryLanguageCode != nil ? productPair!.localProduct!.primaryLanguageCode : productPair!.remoteProduct!.primaryLanguageCode
                                vc.languageCodes = productPair!.remoteProduct!.languageCodes
                                vc.updatedLanguageCodes = productPair?.localProduct?.languageCodes ?? []
                                vc.editMode = editMode
                                vc.productPair = productPair
                                vc.sourcePage = 0
                            }
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowSelectMainLanguage:
                if let vc = segue.destination as? MainLanguageViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? BarcodeTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentLanguageCode = productPair?.primaryLanguageCode ?? "en"
                            }
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowImageSourceSelector:
                if let vc = segue.destination as? SelectImageSourceViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? ProductImageTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.delegate = self
                            }
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowAddLanguage:
                if let vc = segue.destination as? ExtendLanguagesViewController { if
                    let languageCodes = productPair?.languageCodes { if
                    let button = sender as? UIButton { if
                    button.superview?.superview as? TagListViewButtonTableViewCell != nil { if
                    let ppc = vc.popoverPresentationController {
                        // set the main language button as the anchor of the popOver
                        ppc.permittedArrowDirections = .any
                        // I need the button coordinates in the coordinates of the current controller view
                        let anchorFrame = button.convert(button.bounds, to: self.view)
                        ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                        ppc.delegate = self
                    vc.currentLanguageCodes = languageCodes
                    vc.sourcePage = 0
                    vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                        } }}}}
            default: break
            }
        }
    }

    @IBAction func unwindChangeMainLanguageForCancel(_ segue:UIStoryboardSegue) {
        // nothing needs to be done
    }
    
    @IBAction func unwindChangeMainLanguageForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? MainLanguageViewController {
            if let newLanguageCode = vc.selectedLanguageCode {
                productPair?.update(primaryLanguageCode: newLanguageCode)
                currentLanguageCode = newLanguageCode
                tableView.reloadData()
            }
        }
    }
//
// MARK: - Notification handlers
//
    @objc func imageUpdated(_ notification: Notification) {
        guard !editMode else { return }
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil && imageSectionIndex != nil else { return }
        // only update if the image barcode corresponds to the current product
        if let barcodeString = productPair?.remoteProduct?.barcode.asString,
            let info = userInfo?[ProductImageData.Notification.BarcodeKey] as? String,
            barcodeString == info {
            reloadImageSection()
            
            /* We are only interested in medium-sized front images
            let imageSizeCategory = ImageSizeCategory(rawValue: userInfo![ProductImageData.Notification.ImageSizeCategoryKey] as! Int )
            let imageTypeCategory = ImageTypeCategory(rawValue: userInfo![ProductImageData.Notification.ImageTypeCategoryKey] as! Int )
            if imageSizeCategory == .display && imageTypeCategory == .front {
                reloadImageSection()
 
            }*/
        }
    }
    
    private func reloadImageSection() {
        // The reloading of the image sectionresults in a crash
        tableView.reloadData() //.reloadSections([imageSectionIndex!], with: .none)
    }
    
    fileprivate var imageSectionIndex: Int? {
        for (index, sectionType) in tableStructure.enumerated() {
            switch sectionType {
            case .image:
                return index
            default:
                continue
            }
        }
        return nil
    }
    
    @objc func refreshProduct() {
        showPackagingTagsType = TagsTypeDefault.Packaging
        showBrandTagsType = TagsTypeDefault.Brands
        showNameTagsType = TagsTypeDefault.Name
        showGenericNameTagsType = TagsTypeDefault.GenericName
        showQuantityTagsType = TagsTypeDefault.Quantity
        tableView.reloadData()
    }
    
    @objc func loadFirstProduct() {
        let products = OFFProducts.manager
        if let validProduct = products.productPair(at: 0)?.remoteProduct {
            self.productPair = ProductPair(product: validProduct)
            tableView.reloadData()
        }
    }
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    
    fileprivate func newImageSelected(info: [String : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
    }
    
    func takePhoto() {
        // opens the camera and allows the user to take an image and crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
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
    
    func selectCameraRollPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
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

    @objc func imageUploaded(_ notification: Notification) {
        guard !editMode else { return }
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if let productBarcode = productPair!.remoteProduct?.barcode.asString {
                if barcode == productBarcode {
                    // is it relevant to the main image?
                    if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                        if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) {
                            // reload product data
                            self.productPair?.reload()
                        }
                    }
                }
            }
        }
    }
    
    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if barcode == productPair!.remoteProduct!.barcode.asString {
                // is it relevant to the main image?
                if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) {
                        // reload product data
                        self.productPair?.reload()
                    }
                }
            }
        }
    }

    @objc func removeProduct() {
        //TODO: why is this function?
        //productPair!.remoteProduct = nil
        tableView.reloadData()
    }
    
    @objc func doubleTapOnTableView() {
        switch productVersion {
        case .remote:
            //productVersion = .local
        //case .local:
            productVersion = .new
        case .new:
            productVersion = .remote
        }
        tableView.reloadData()
    }

//
// MARK: - ViewController Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        // reset the current languagecode
        // currentLanguageCode = nil
        
        self.tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")
        // print("viewDidLoad", self.view.frame, self.parent?.view.frame)
        
        // Add doubletapping to the TableView. Any double tap on headers is now received,
        // and used for changing the productVersion (local and remote)
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(IdentificationTableViewController.doubleTapOnTableView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.cancelsTouchesInView = false
        doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
        tableView.addGestureRecognizer(doubleTapGestureRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //delegate?.title = TranslatableStrings.Identification

        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.SearchTypeChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded(_:)), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)
    }
    
    //override func viewDidAppear(_ animated: Bool) {
    //    super.viewDidAppear(animated)
        //print("id viewDidAppear frame", self.view.frame.size.width, "parent", self.parent?.view.frame.size.width, "tableView", self.tableView.frame.size.width)
        // suggested by http://useyourloaf.com/blog/self-sizing-table-view-cells/
    //}
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
//
// MARK: - TagListViewButtonCellDelegate Functions
//
extension IdentificationTableViewController: TagListViewButtonCellDelegate {
    
    // function to let the delegate know that a tag was single tapped
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedSingleTapOn tagListView:TagListView) {
        
    }
    // function to let the delegate know that a tag was double tapped
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
        
    }
    // function to let the delegate know that the switch changed
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedTapOn button:UIButton) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowAddLanguage, sender: button)
    }
}

//
// MARK: - TagListViewCellDelegate Functions
//
extension IdentificationTableViewController: BarcodeEditCellDelegate {
    
    // function to let the delegate know that the switch changed
    func barcodeEditTableViewCell(_ sender: BarcodeEditTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
        if let validCode = query!.barcode?.asString,
            let validProductType = query!.barcode?.productType {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                query!.barcode = .ean8(validCode, validProductType)
            case 1:
                query!.barcode = .upc12(validCode, validProductType)
            case 2:
                query!.barcode = .ean13(validCode, validProductType)
            default:
                break
            }
        }
    }
}
//
// MARK: - TagListViewCellDelegate Functions
//
extension IdentificationTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }

    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .packaging:
            showPackagingTagsType.cycle()
            tableView.reloadData()
            //tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        case .brands:
            showBrandTagsType.cycle()
            tableView.reloadData()
            //tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        default:
            break
        }
    }
}
//
// MARK: - ProductNameCellDelegate Functions
//
extension IdentificationTableViewController: ProductNameCellDelegate {
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedDoubleTap textView:UITextView) {
        changeLanguage()
    }
}
//
// MARK: - IdentificationImageCellDelegate Functions
//
extension IdentificationTableViewController: ProductImageCellDelegate {
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
        }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton) {
        guard let validLanguageCode = displayLanguageCode else { return }
        productPair?.deselect([validLanguageCode], of: .front)
    }
    
}
//
// MARK: - TagListViewAddImageCellDelegate functions
//
extension IdentificationTableViewController: TagListViewAddImageCellDelegate {
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
}
//
// MARK: - TagListViewSegmentedControlCellDelegate Functions
//
extension IdentificationTableViewController: TagListViewSegmentedControlCellDelegate {
    
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
        let inclusion = segmentedControl.selectedSegmentIndex == 0 ? false : true
        let currentProductSection = tableStructure[sender.tag]
        switch currentProductSection {
        case .languagesSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.languages.1 = inclusion
            tableView.reloadData()
            //tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .packagingSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.packaging.1 = inclusion
            tableView.reloadData()

            //tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .brandsSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.brands.1 = inclusion
            tableView.reloadData()
            //tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        default:
            break
        }
    }
}
//
// MARK: - TextView Delegate Functions
//
extension IdentificationTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editMode
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == TranslatableStrings.PlaceholderProductName ||
            textView.text == TranslatableStrings.PlaceholderGenericProductName ||
            textView.text == TranslatableStrings.PlaceholderProductNameSearch {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.isFirstResponder { textView.resignFirstResponder() }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {        
        switch tableStructure[textView.tag] {
        case .name:
            // productname
            if let validText = textView.text {
                if validText.isEmpty {
                    textView.text = TranslatableStrings.PlaceholderProductName
                    textView.textColor = .lightGray
                } else if let validCurrentLanguageCode = displayLanguageCode {
                    productPair?.update(name: validText, in: validCurrentLanguageCode)
                }
            }
        case .genericName:
            // generic name updated?
            if let validText = textView.text {
                if validText.isEmpty {
                    textView.text = TranslatableStrings.PlaceholderGenericProductName
                    textView.textColor = .lightGray
                } else if let validCurrentLanguageCode = displayLanguageCode {
                    productPair?.update(genericName: validText, in: validCurrentLanguageCode)
                }
            }
        case .nameSearch, .genericNameSearch:
            // name or generic name updated?
            if let validText = textView.text {
                if (textView.text == "") {
                    textView.text = TranslatableStrings.PlaceholderProductNameSearch
                    textView.textColor = .lightGray
                } else if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.text = validText
            }
            
        default:
            break
        }
    }
    
    func textViewHeightForAttributedText(text: NSAttributedString, andWidth width: CGFloat) -> CGFloat {
        let calculationView = UITextView()
        calculationView.attributedText = text
        let size = calculationView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
    
}
//
// MARK: - TagListView DataSource Functions
//
extension IdentificationTableViewController: TagListViewDataSource {
    
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
        
        let currentProductSection = tableStructure[tagListView.tag]
        
        switch currentProductSection {
        case .quantitySearch, .imageSearch, .image:
            return 1
        case .barcodeSearch, .nameSearch, .genericNameSearch:
            return count(Tags.empty)
        case .brands:
            return count(brandsToDisplay)
        case .brandsSearch:
            return count(searchBrandsToDisplay)
        case .packaging:
            return count(packagingToDisplay)
        case .packagingSearch:
            return count(searchPackagingToDisplay)
        case .languages:
            return count(languagesToDisplay)
        case .languagesSearch:
            return count(searchLanguagesToDisplay)
        default:
            return 0
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        // print("height", tagListView.frame.size.height)
        
        func title(_ tags: Tags) -> String {
            switch tags {
            case .undefined, .empty, .notSearchable:
                return tags.description()
            case .available:
                return tags.tag(at:index) ?? "IdentificationTableViewController: Tag index out of bounds"
            }
        }
        
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .quantitySearch, .imageSearch:
            return title(notSearchableToDisplay)
        case .barcodeSearch, .nameSearch, .genericNameSearch:
            return title(Tags.empty)
        case .brands:
            return title(brandsToDisplay)
        case .brandsSearch:
            return title(searchBrandsToDisplay)
        case .packaging:
            return title(packagingToDisplay)
        case .packagingSearch:
            return title(searchPackagingToDisplay)
        case .languages:
            return title(languagesToDisplay)
        case .languagesSearch:
            return title(searchLanguagesToDisplay)
        case .image:
            return searchResult
        default:
            return("IdentificationTableViewController: TagListView titleForTagAt error")
        }
    }

    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .brands:
            switch brandsToDisplay {
            case .available(var list):
                list.removeAll()
                productPair?.update(brandTags: list)
            default:
                assert(true, "IdentificationTableViewController: How can I clear a tag when there are none")
            }
        case .brandsSearch:
            switch searchBrandsToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.brands.0 = .available(list)
            default:
                assert(true, "IdentificationTableViewController: How can I clear a tag when there are none")

            }
            
        case .languagesSearch:
            switch searchLanguagesToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.languages.0 = .available(list)
            default:
                assert(true, "IdentificationTableViewController: How can I clear a tag when there are none")
            }

        case .packaging:
            switch packagingToDisplay {
            case .available(var list):
                list.removeAll()
                productPair?.update(packagingTags: list)
            default:
                assert(true, "IdentificationTableViewController: How can I delete a tag when there are none")

            }
            
        case .packagingSearch:
            switch searchBrandsToDisplay {
            case .available(var list):
                list.removeAll()
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.packaging.0 = .available(list)
            default:
                assert(true, "IdentificationTableViewController: How can I clear a tag when there are none")
            }

        default:
            break
        }
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }

}
//
// MARK: - TagListViewDelegate Functions
//
extension IdentificationTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        switch tableStructure[tagListView.tag] {
        case .languages:
            // switch the current language to the one the user tapped
            switch languagesToDisplay {
            case .available(let languages):
                let language = languages[index]
                currentLanguageCode = OFFplists.manager.languageCode(for:language)
            default:
                assert(true, "IdentificationTableViewController: How can I select a tag that is not there")
            }
        default:
            return
        }
    }

    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tableStructure[tagListView.tag] {
        case .brands:
            switch brandsToDisplay {
            case .undefined, .empty:
                productPair?.update(brandTags: [title])
            case .available(var list):
                list.append(title)
                productPair?.update(brandTags: list)
            default:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }
        case .brandsSearch:
            switch searchBrandsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.brands.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.brands.0 = .available(list)
            default:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }
        case .packaging:
            switch packagingToDisplay {
            case .undefined, .empty:
                productPair?.update(packagingTags: [title])
            case .available(var list):
                list.append(title)
                productPair?.update(packagingTags: list)
            default:
                assert(true, "IdentificationTableViewController: How can I add a packaging tag when the field is non-editable")
            }
        case .languages:
            switch languagesToDisplay {
            case .undefined, .empty, .available:
                productPair?.update(addLanguageCode: title)
            default:
                assert(true, "IdentificationTableViewController: How can I add a languages tag when the field is non-editable")
            }
        case .languagesSearch:
            switch searchLanguagesToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.languages.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.languages.0 = .available(list)
            default:
                assert(true, "IdentificationTableViewController: How can I add a search languages tag when the field is non-editable")
            }
        case .packagingSearch:
            switch searchPackagingToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.packaging.0 = Tags.init(list:[title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.packaging.0 = Tags.init(list:list)
            default:
                assert(true, "IdentificationTableViewController: How can I add a packaging tag when the field is non-editable")
            }

        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .brands:
            switch brandsToDisplay {
            case .undefined, .empty:
                assert(true, "IdentificationTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(brandTags: list)
            case .notSearchable:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }
            
        case .brandsSearch:
            switch searchBrandsToDisplay {
            case .undefined, .empty:
                assert(true, "IdentificationTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.brands.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }

        case .packaging:
            switch packagingToDisplay {
            case .undefined, .empty:
                assert(true, "IdentificationTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(packagingTags: list)
            case .notSearchable:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }
        case .packagingSearch:
            switch searchPackagingToDisplay {
            case .undefined, .empty:
                assert(true, "IdentificationTableViewController: How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.packaging.0 = Tags.init(list:list)
            case .notSearchable:
                assert(true, "IdentificationTableViewController: How can I add a tag when the field is non-editable")
            }
        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        // causes a crash
        //tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .languages:
            delegate?.search(for: productPair!.remoteProduct!.languages[index], in: .language)
        case .brands:
            // use the interpreted tags for search !!!!
            switch productPair!.remoteProduct!.brandsInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct?.brandsInterpreted.tag(at: index), in: .brand)
            default:
                break
            }
        case .packaging:
            switch productPair!.remoteProduct!.packagingInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.packagingInterpreted.tag(at: index), in: .packaging)
            default:
                break
            }

        default:
            break

        }
    }
    
}
//
// MARK: - UITextField Delegate Functions
//
extension IdentificationTableViewController: UITextFieldDelegate {

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let currentProductSection = tableStructure[textField.tag]
        switch currentProductSection {
        case .quantity:
            // quantity updated?
            if let validText = textField.text {
                productPair?.update(quantity: validText)
            }
        case .barcodeSearch:
            // barcode updated?
            if let validText = textField.text {
                query!.barcode = BarcodeType.ean8(validText, Preferences.manager.showProductType)
            }
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let currentProductSection = tableStructure[textField.tag]
        switch currentProductSection {
        case .quantity:
            return editMode
        case .barcodeSearch:
            return query!.type == .advanced ? false : editMode
        default:
            // only allow edit for the primary language code
            return currentLanguageCode == productPair!.remoteProduct!.primaryLanguageCode ? editMode : false
        }
    }
    
}
//
// MARK: - UIImagePickerControllerDelegate Functions
//
extension IdentificationTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
    }

}
//
// MARK: - UIPopoverPresentationControllerDelegate Functions
//
extension IdentificationTableViewController: UIPopoverPresentationControllerDelegate {
    
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
//
// MARK: - GKImagePickerDelegate Functions
//
extension IdentificationTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        guard let validLanguageCode = displayLanguageCode else { return }
        // print("front image", image.size)
        productPair?.update(frontImage: image, for: validLanguageCode)
        tableView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
//
// MARK: - LanguageHeaderDelegate Functions
//
extension IdentificationTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowNamesLanguages, sender: sender)
    }
}
//
// MARK: - UIDragInteractionDelegate Functions
//
@available(iOS 11.0, *)
extension IdentificationTableViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    private func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let validLanguageCode = displayLanguageCode else { return [] }
        var productImageData: ProductImageData? = nil
        // is there image data?
        if let localProduct = productPair?.localProduct {
            if !localProduct.frontImages.isEmpty {
                productImageData = localProduct.image(for:validLanguageCode, of:.front)
            } else {
                productImageData = localProduct.image(for:validLanguageCode, of:.front)
            }
        }
        // The largest image here is the display image, as the url for the original front image is not offered by OFF in an easy way
        guard productImageData != nil else { return [] }
        
        guard let validProductImageData = productImageData else { return [] }
        
        // only allow flocking of another productImageSize
        for item in session.items {
            // Note kUTTypeImage is defined in MobileCoreServices, so need to import
            // This is an image, as that is what I offer to export
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        
        switch tableStructure[indexPath.section] {
        case .image :
            // check if the selected image has not been added yet
            for item in session.items {
                guard item.localObject as! ProductImageData != validProductImageData else { return [] }
            }
            let provider = NSItemProvider(object: validProductImageData)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        default:
            break
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {

        switch tableStructure[indexPath.section] {
        case .image :
            if let cell = tableView.cellForRow(at: indexPath) as? ProductImageTableViewCell,
                let rect = cell.productImageView.imageRect {
                let parameters = UIDragPreviewParameters.init()
                parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
                return parameters
            }
        default:
            break
        }
        return nil

    }
    
}

// MARK: - UITableViewDropDelegate Functions

@available(iOS 11.0, *)
extension IdentificationTableViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        func setImage(image: UIImage) {
            let cropController = GKImageCropViewController.init()
            cropController.sourceImage = image
            cropController.view.frame = tableView.frame
            //cropController.preferredContentSize = picker.preferredContentSize
            cropController.hasResizableCropArea = true
            cropController.cropSize = CGSize.init(width: 300, height: 300)
            cropController.delegate = self
            cropController.modalPresentationStyle = .fullScreen

            present(cropController, animated: true, completion: nil)
            if let popoverPresentationController = cropController.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
            //self.pushViewController(cropController, animated: false)
        }

        //guard currentLanguageCode != nil else { return }
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            // Only one image is accepted as ingredients image for the current language
            if let validImage = (images as? [UIImage])?.first {
                setImage(image: validImage)
                //self.delegate?.updated(frontImage: validImage, languageCode:self.currentLanguageCode!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // Only accept if an image is hovered above the image section
        if let validIndexPathSection = destinationIndexPath?.section {
            
            switch tableStructure[validIndexPathSection] {
            case .image :
                return editMode ? UITableViewDropProposal(operation: .copy, intent: .unspecified) : UITableViewDropProposal(operation: .forbidden, intent: .unspecified)
            default:
                break
            }
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
        
    }
}

// MARK: - GKImageCropController Delegate Methods

extension IdentificationTableViewController: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        guard let validLanguage = displayLanguageCode,
            let validImage = croppedImage else { return }
        imageCropController.dismiss(animated: true, completion: nil)
        productPair?.update(frontImage: validImage, for: validLanguage)
        self.reloadImageSection()
        //delegate?.imagePicker(self, cropped:croppedImage!)
    }
}

