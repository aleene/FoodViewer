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
//
// MARK: - public variables
//
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    var editMode: Bool {
        return delegate?.editMode ?? false
    }

//
// MARK: - Fileprivate Functions/variables
//
    fileprivate enum ProductVersion {
        case remoteUser // data as entered by the user
        //case remoteTags // data interpreted by off
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
    // Default is the edited product version and then the translated version
    fileprivate var productVersion: ProductVersion = .new

    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }

    // The languageCode as defined by the user (double tapping/selecting)
    // The user can set for which language he wants to see the name/genericName and front image
    fileprivate var currentLanguageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
        set {
            delegate?.currentLanguageCode = newValue
        }
    }
    
    // This variable defined the languageCode that must be used to display the product data
    // This is either the languageCode selected by the user or the best match for the current product
    private var displayLanguageCode: String? {
        return currentLanguageCode ?? productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }
    
    fileprivate var nameToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteUser:
                // always show the remote product name
                guard let validLanguageCode = displayLanguageCode else { return .empty }
                guard let text = productPair?.remoteProduct?.nameLanguage[validLanguageCode] else { return .empty }
                guard let validText = text else { return .empty }
                return Tags.init(text: validText)
            case .new:
                // show the local product name if available
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
            case .remoteUser:
            // always show the remote product name
                guard let validLanguageCode = displayLanguageCode else { return .empty }
                guard let text = productPair?.remoteProduct?.genericNameLanguage[validLanguageCode] else { return .empty }
                guard let validText = text else { return .empty }
                return Tags.init(text: validText)
            case .new:
                // show the local product name if available
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
            case .remoteUser:
                // show the remote language
                return productPair?.remoteProduct?.primaryLanguageCode ?? productPair?.localProduct?.primaryLanguageCode ?? TranslatableStrings.QuestionMark
            case .new:
                // show the local language if available
                return productPair?.localProduct?.primaryLanguageCode ?? productPair?.remoteProduct?.primaryLanguageCode ?? TranslatableStrings.QuestionMark
            }
        }
    }

    fileprivate var quantityToDisplay: Tags {
        get {
            switch productVersion {
            case .remoteUser:
                // show the remote quantity
                guard let text = productPair?.remoteProduct?.quantity else { return .empty }
                return Tags.init(text: text)
            case .new:
                // show the local quantity if available
                guard let text = productPair?.localProduct?.quantity ??
                productPair?.remoteProduct?.quantity else { return .empty }
                return Tags.init(text: text)
            }
        }
    }

    fileprivate var packagingToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.packagingOriginal) {
                    return checked
                }
                // no taxonomy in use
            //case .remoteTags:
            //    productPair?.remoteProduct?.packagingInterpreted ?? .undefined
            default: break
            }
            return productPair?.remoteProduct?.packagingOriginal ?? .undefined
        }
    }
    
    fileprivate var brandsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.brandsOriginal) {
                    return checked
                }
                // no taxonomy in use
            //case .remoteTags:
            //    return productPair?.remoteProduct?.brandsInterpreted ?? .undefined
            default: break
            }
            return productPair?.remoteProduct?.brandsOriginal ?? .undefined
        }
    }

    fileprivate var languagesToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.languageTags) {
                    return checked
                }
            default: break
            }
            return productPair?.remoteProduct?.languageTags ?? .undefined
        }
    }
    
    fileprivate func checkedTags(_ tags:Tags?) -> Tags? {
        if let validTags = tags,
            validTags.isAvailable {
            return validTags
        }
        return nil
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
    
    // MARK: - Tableview methods

    fileprivate var tableStructure: [SectionType] = []
    
    fileprivate enum SectionType {
        case barcode(Int, String)
        case name(Int, String)
        case genericName(Int, String)
        case languages(Int, String)
        case brands(Int, String)
        case packaging(Int, String)
        case quantity(Int, String)
        case image(Int, String)
        
        var header: String {
            switch self {
            case .barcode(_, let headerTitle),
                 .name(_, let headerTitle),
                 .genericName(_, let headerTitle),
                 .languages(_, let headerTitle),
                 .brands(_, let headerTitle),
                 .packaging(_, let headerTitle),
                 .quantity(_, let headerTitle),
                 .image(_, let headerTitle):
                return headerTitle
            }
        }
        
        var numberOfRows: Int {
            switch self {
            case .barcode(let numberOfRows, _),
                 .name(let numberOfRows, _),
                 .genericName(let numberOfRows, _),
                 .languages(let numberOfRows, _),
                 .brands(let numberOfRows, _),
                 .packaging(let numberOfRows, _),
                 .quantity(let numberOfRows, _),
                 .image(let numberOfRows, _):
                return numberOfRows
            }
        }
    }

    private var tagListViewHeight: [Int:CGFloat] = [:]
    
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
        
        switch tableStructure[indexPath.section] {
        case .barcode:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Barcode, for: indexPath) as! BarcodeTableViewCell
            cell.barcode = productPair?.barcodeType.asString
            cell.mainLanguageCode = primaryLanguageCodeToDisplay
            cell.editMode = editMode
            if editMode,
                productPair?.localProduct?.primaryLanguageCode != productPair?.remoteProduct?.primaryLanguageCode {
                cell.editMode = productVersion.isRemote ? false : true
            }
            return cell

        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ProductName, for: indexPath) as! ProductNameTableViewCell
            cell.delegate = self
            cell.tag = indexPath.section
            cell.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if editMode,
                let validLanguageCode = displayLanguageCode {
                if productPair?.localProduct?.nameLanguage[validLanguageCode] != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }
            }

            cell.name = editMode ? TranslatableStrings.PlaceholderProductName : nil
            //cell.nameTextView.textColor = .gray
            if let validNumberOfProductLanguages = productPair?.remoteProduct?.languageCodes.count {
                cell.isMultilingual = validNumberOfProductLanguages > 1 ? true : false
            }
            cell.buttonNotDoubleTap = ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
            switch nameToDisplay {
            case .available(let array):
                if !array.isEmpty && !array.first!.isEmpty {
                    cell.name = array.first
                    //cell.nameTextView.textColor = .black
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
            if editMode,
                let validLanguageCode = displayLanguageCode {
                if productPair?.localProduct?.genericNameLanguage[validLanguageCode] != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }
            }
            cell.name = editMode ? TranslatableStrings.PlaceholderGenericProductName : nil
            //cell.nameTextView.textColor = .gray
            switch genericNameToDisplay {
            case .available(let array):
                if !array.isEmpty && !array.first!.isEmpty {
                    cell.name = array.first
                    //cell.nameTextView.textColor = .black
                }
            default:
                break
            }
            if let validNumberOfProductLanguages = productPair?.remoteProduct?.languageCodes.count {
                cell.isMultilingual = validNumberOfProductLanguages > 1 ? true : false
            }
            cell.buttonNotDoubleTap = ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
            return cell

        case .languages:
            if editMode {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewButton, for: indexPath) as! TagListViewButtonTableViewCell
                cell.setup(datasource: self, delegate: self, editMode: editMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: nil)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                cell.setup(datasource: self, delegate: self, editMode: editMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: nil)
                return cell
            }
        case .brands:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            var tagListViewEditMode = editMode
            if editMode,
                let newTags = productPair?.localProduct?.brandsOriginal {
                switch newTags {
                case .available:
                    tagListViewEditMode = productVersion.isRemote ? false : true
                default:
                    break
                }
            }
            cell.setup(datasource: self, delegate: self, editMode: tagListViewEditMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: nil)
            return cell

        case .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            var tagListViewEditMode = editMode
            if editMode,
                let newTags = productPair?.localProduct?.packagingOriginal {
                switch newTags {
                case .available:
                    tagListViewEditMode = productVersion.isRemote ? false : true
                default:
                    break
                }
            }
            cell.setup(datasource: self, delegate: self, editMode: tagListViewEditMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: nil)
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
            if editMode,
                productPair?.localProduct?.quantity == nil {
                cell.editMode = productVersion.isRemote ? false : true
            }
            cell.delegate = self
            cell.tag = indexPath.section
            return cell
            
        case .image:
            if currentImage.0 != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                if editMode,
                    let localPair = localFrontImage,
                    localPair.0 != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }
                cell.productImage = currentImage.0
                cell.delegate = self
                return cell
            } else {
                searchResult = currentImage.1
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewAddImage, for: indexPath) as! TagListViewAddImageTableViewCell
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, editMode: editMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: ColorSchemes.error)
                return cell
            }
        }
    }
    
    public var currentImage: (UIImage?, String) {
        switch productVersion {
        case .new:
            return localFrontImage ?? remoteFrontImage ?? ( nil,TranslatableStrings.NoImageAvailable)
        default:
            return remoteFrontImage ?? (nil, TranslatableStrings.NoImageAvailable)
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
            let nextCode = nextLanguageCode()
            if availableLanguages.count > 1 && currentLanguageCode != nextCode {
                currentLanguageCode = nextCode
            }
        }
    }
    
    fileprivate func nextLanguageCode() -> String {
        if let product = productPair?.remoteProduct {
            if let validLanguageCode = currentLanguageCode,
                let currentIndex = product.languageCodes.firstIndex(of: validLanguageCode) {
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
        struct CellHeight {
            static let TagListViewCell = CGFloat(27.0)
            // This is the cell with two buttons on the right, which allow the user to add an image.
            static let TagListViewAddImageCell = CGFloat(25.0) + CGFloat(8.0) + CGFloat(25.0)
        }
        struct CellMargin {
            static let ContentView = CGFloat(11.0)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentProductSection = tableStructure[section]
        switch currentProductSection {
        case .barcode, .brands, .image, .name, .genericName, .packaging, .quantity :
            return nil
        default:
            break
        }
        return tableStructure[section].header
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentProductSection = tableStructure[section]
        
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LanguageHeaderView") as! LanguageHeaderView
        headerView.section = section
        headerView.delegate = self
        // do not add any button or double tap
        headerView.buttonNotDoubleTap = buttonNotDoubleTap

        headerView.changeViewModeButton.isHidden = true
        var header = tableStructure[section].header
        // The headers with a language
        switch currentProductSection {
            
        case .image, .name, .genericName :
            headerView.changeLanguageButton.isHidden = false
            switch currentProductSection {
            case .image:
                switch productVersion {
                case .new:
                    if let localPair = localFrontImage,
                        localPair.0 != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.FrontImageEdited
                    } else {
                        header = TranslatableStrings.FrontImage
                    }
                default:
                        // the local version has been requested and is available
                    header = TranslatableStrings.FrontImageOriginal
                }

            case .name:
                switch productVersion {
                case .new:
                    if let validLanguageCode = displayLanguageCode,
                        productPair?.localProduct?.nameLanguage[validLanguageCode] != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.NameEdited
                    } else {
                        header = TranslatableStrings.Name
                    }
                default:
                    header = TranslatableStrings.NameOriginal
                }
                
            case .genericName :
                switch productVersion {
                case .new:
                    if let validLanguageCode = displayLanguageCode,
                        productPair?.localProduct?.genericNameLanguage[validLanguageCode] != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.GenericNameEdited
                    } else {
                        header = TranslatableStrings.GenericName
                    }
                default:
                    header = TranslatableStrings.GenericNameOriginal
                }

            default:
                break
            }
            headerView.buttonText = OFFplists.manager.languageName(for: displayLanguageCode)
            headerView.buttonIsEnabled = editMode ? true : ( (productPair?.product?.languageCodes.count ?? 0) > 1 ? true : false )
            // add a dash to nice separate the title from the language button
            headerView.title = header + " - "
            return headerView
            
        case .barcode, .brands, .packaging, .quantity:
            headerView.changeLanguageButton.isHidden = true

            switch currentProductSection {
            case .barcode:
                // it is not possible to edit the barcode
                header = TranslatableStrings.Barcode
            case .brands:
                switch productVersion {
                case .new:
                    if let newTags = productPair?.localProduct?.brandsOriginal {
                        switch newTags {
                        case .available:
                            // the local version has been requested and is available
                            header = TranslatableStrings.BrandsEdited
                        default:
                            header = TranslatableStrings.Brands
                        }
                    } else {
                        header = TranslatableStrings.Brands
                    }
                default:
                //case .remoteUser:
                    header = TranslatableStrings.BrandsOriginal
                //case .remoteTags:
                //    header = TranslatableStrings.BrandsInterpreted
                }
                
            case .packaging:
                switch productVersion {
                case .new:
                    if let newTags = productPair?.localProduct?.packagingOriginal {
                        switch newTags {
                        case .available:
                            // the local version has been requested and is available
                            header = TranslatableStrings.PackagingEdited
                        default:
                            header = TranslatableStrings.Packaging
                        }
                    } else {
                        header = TranslatableStrings.Packaging
                    }
                default:
                //case .remoteUser:
                    header = TranslatableStrings.PackagingOriginal
                //case .remoteTags:
                //    header = TranslatableStrings.PackagingInterpreted
                }
                
            case .quantity:
                switch productVersion {
                case .new:
                    if productPair?.localProduct?.quantity != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.QuantityEdited
                    } else {
                        header = TranslatableStrings.Quantity
                    }
                default:
                    // the remote version has been requested OR
                    // there is no local version
                    header = TranslatableStrings.QuantityOriginal
                }

            default:
                break
            }
            headerView.title = header
            return headerView
            
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentProductSection = tableStructure[indexPath.section]
        switch currentProductSection {
        case .brands, .packaging, .languages:
            let height = tagListViewHeight[indexPath.section] ?? Constants.CellHeight.TagListViewCell
            return height + 2 * Constants.CellMargin.ContentView
        case .image:
            if currentImage.0 != nil {
                // The height is determined by the image
                return UITableView.automaticDimension
            } else {
                // the height is determnined by the buttons
                let height = Constants.CellHeight.TagListViewAddImageCell
                return height + 2 * Constants.CellMargin.ContentView
            }
        default:
            return UITableView.automaticDimension
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
            static let CommonName = TranslatableStrings.GenericName
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
        sectionsAndRows.append(.barcode(TableSection.Size.Barcode, TableSection.Header.Barcode))
        sectionsAndRows.append(.name(TableSection.Size.Name, TableSection.Header.Name))
        sectionsAndRows.append(.genericName(TableSection.Size.CommonName, TableSection.Header.CommonName))
        tagListViewHeight[3] = Constants.CellHeight.TagListViewCell
        sectionsAndRows.append(.languages(TableSection.Size.Languages, TableSection.Header.Languages))
        tagListViewHeight[4] = Constants.CellHeight.TagListViewCell
        sectionsAndRows.append(.brands(TableSection.Size.Brands, TableSection.Header.Brands))
        tagListViewHeight[5] = Constants.CellHeight.TagListViewCell
        sectionsAndRows.append(.packaging(TableSection.Size.Packaging, TableSection.Header.Packaging))
        sectionsAndRows.append(.quantity(TableSection.Size.Quantity, TableSection.Header.Quantity))
        sectionsAndRows.append(.image(TableSection.Size.Image,TableSection.Header.Image))
        
        return sectionsAndRows
    }

    // MARK: - Segue stuff

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowIdentificationImage:
                if let vc = segue.destination as? ImageViewController,
                    let validLanguageCode = displayLanguageCode {
                    vc.imageTitle = TranslatableStrings.Identification
                    if let images = productPair?.localProduct?.frontImages,
                        !images.isEmpty {
                        vc.imageData = productPair!.localProduct!.image(for:validLanguageCode, of:.front)
                    } else {
                        vc.imageData = productPair!.remoteProduct!.image(for:validLanguageCode, of:.front)
                    }
                }
            case Storyboard.SegueIdentifier.ShowNamesLanguages:
                if let vc = segue.destination as? SelectLanguageViewController {
                    // The segue can only be initiated from a button within a ProductNameTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview?.superview as? UITableView != nil {
                            //if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                //ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                //let anchorFrame = button.convert(button.bounds, to: self.view)
                                //ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                //ppc.delegate = self
                                
                                //vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentLanguageCode = displayLanguageCode
                                vc.primaryLanguageCode = productPair?.localProduct?.primaryLanguageCode != nil ? productPair!.localProduct!.primaryLanguageCode : productPair!.remoteProduct!.primaryLanguageCode
                                vc.languageCodes = productPair!.remoteProduct!.languageCodes
                                vc.updatedLanguageCodes = productPair?.localProduct?.languageCodes ?? []
                                vc.editMode = editMode
                                vc.productPair = productPair
                                vc.sourcePage = 0
                            //}
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowSelectMainLanguage:
                if let vc = segue.destination as? MainLanguageViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? BarcodeTableViewCell != nil {
                            //if let ppc = vc. {
                                // set the main language button as the anchor of the popOver
                            //    ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                           //     let anchorFrame = button.convert(button.bounds, to: self.view)
                           //     ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                           //     ppc.delegate = self
                           //     vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                            vc.currentLanguageCodes = [productPair?.primaryLanguageCode ?? "en"]
                          //  }
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
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                vc.delegate = self
                            }
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowAddLanguage:
                if let vc = segue.destination as? MainLanguageViewController { if
                    let languageCodes = productPair?.languageCodes { if
                    let button = sender as? UIButton { if
                    button.superview?.superview as? TagListViewButtonTableViewCell != nil {
                        // if let ppc = vc.popoverPresentationController {
                        // set the main language button as the anchor of the popOver
                     //   ppc.permittedArrowDirections = .any
                        // I need the button coordinates in the coordinates of the current controller view
                      //  let anchorFrame = button.convert(button.bounds, to: self.view)
                      //  ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                     //   ppc.delegate = self
                    vc.currentLanguageCodes = languageCodes
                    vc.sourcePage = 0
                    //vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                        //}
                        
                    }
                    
                    }
                    
                }
                
            }
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
        productVersion = .new
        tableView.reloadData()
        
    }
    
    func refreshInterface() {
        tableView.reloadData()
    }
    
    /*
    @objc func loadFirstProduct() {
        let products = OFFProducts.manager
        if let validProduct = products.productPair(at: 0)?.remoteProduct {
            self.productPair = ProductPair(product: validProduct)
            tableView.reloadData()
        }
    }
 */
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()
    
    fileprivate func newImageSelected(info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
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
        // double tapping implies cycling through the product possibilities
        switch productVersion {
        case .new:
            productVersion = .remoteUser
        case .remoteUser:
            productVersion = .new
        }
        tableView.reloadData()
    }

    @objc func infoClicked() {
        //TODO: why is this function?
        //productPair!.remoteProduct = nil
        //tableView.reloadData()
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
        
        self.tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = true
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableStructure = setupSections()
        tableView.reloadData()

        /*
        //Initialize the toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.default
        
        //Set the toolbar to fit the width of the app.
        toolbar.sizeToFit()
        
        //Caclulate the height of the toolbar
        let toolbarHeight = toolbar.frame.size.height
        
        //Get the bounds of the parent view
        let rootViewBounds = self.navigationController?.view.bounds
        
        //Get the height of the parent view.
        let rootViewHeight = rootViewBounds?.height
        
        //Get the width of the parent view,
        let rootViewWidth = rootViewBounds?.width
        
        //Create a rectangle for the toolbar
        let rectArea = CGRect(x: 0, y: rootViewHeight! - toolbarHeight - 50, width: rootViewWidth!, height: toolbarHeight)
        
        //Reposition and resize the receiver
        toolbar.frame = rectArea
        
        //Create a button
        let infoButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(infoClicked))
        
        toolbar.items = [infoButton]
        
        //Add the toolbar as a subview to the navigation controller.
        // self.navigationController?.view.addSubview(toolbar)
         */
        navigationController?.setNavigationBarHidden(false, animated: false)
        

        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        //NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.SearchTypeChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded(_:)), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)
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
// MARK: - QuantityTableViewCellDelegate Function
//
extension IdentificationTableViewController: QuantityTableViewCellDelegate {
    
    // function to let the delegate know that a tag was single tapped
    func quantityTableViewCell(_ sender: QuantityTableViewCell, receivedTapOn button: UIButton) {
        switch quantityToDisplay {
        case .available(let array):
            productPair?.update(quantity: array[0] + " ℮")
        default:
            productPair?.update(quantity: " ℮")
        }
        self.tableView.reloadData()
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
// MARK: - BarcodeEditCellDelegate Functions
//
extension IdentificationTableViewController: BarcodeEditCellDelegate {
    
    // function to let the delegate know that the switch changed
    func barcodeEditTableViewCell(_ sender: BarcodeEditTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
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
    }
}

//
// MARK: - ProductNameCellDelegate Functions
//
extension IdentificationTableViewController: ProductNameCellDelegate {
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedDoubleTap textView:UITextView) {
        textView.endEditing(true)
        changeLanguage()
    }
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedTapOn button:UIButton) {
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
        guard let validLanguageCode = displayLanguageCode,
        let validProductPair = productPair else { return }
        OFFProducts.manager.deselectImage(for: validProductPair, in: validLanguageCode, of: .front)
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
//extension IdentificationTableViewController: TagListViewSegmentedControlCellDelegate {
//
//    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
//    }
//}
//
// MARK: - TextView Delegate Functions
//
extension IdentificationTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editMode
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == TranslatableStrings.PlaceholderProductName ||
            textView.text == TranslatableStrings.PlaceholderGenericProductName {
            textView.text = ""
        }
        if #available(iOS 13.0, *) {
            textView.textColor = .label
        } else {
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
                    if #available(iOS 13.0, *) {
                        textView.textColor = .secondaryLabel
                    } else {
                        textView.textColor = .gray
                    }
                } else if let validCurrentLanguageCode = displayLanguageCode {
                    productPair?.update(name: validText, in: validCurrentLanguageCode)
                }
            }
        case .genericName:
            // generic name updated?
            if let validText = textView.text {
                if validText.isEmpty {
                    textView.text = TranslatableStrings.PlaceholderGenericProductName
                    if #available(iOS 13.0, *) {
                        textView.textColor = .secondaryLabel
                    } else {
                        textView.textColor = .gray
                    }
                } else if let validCurrentLanguageCode = displayLanguageCode {
                    productPair?.update(genericName: validText, in: validCurrentLanguageCode)
                }
            }
        default:
            break
        }
        tableView.reloadData()
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
        case .brands:
            return count(brandsToDisplay)
        case .packaging:
            return count(packagingToDisplay)
        case .languages:
            return count(languagesToDisplay)
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
        case .brands:
            return title(brandsToDisplay)
        case .packaging:
            return title(packagingToDisplay)
        case .languages:
            return title(languagesToDisplay)
        case .image:
            return searchResult
        default:
            return("IdentificationTableViewController: TagListView titleForTagAt error")
        }
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        if let cellHeight = tagListViewHeight[tagListView.tag],
            abs(cellHeight - height) > CGFloat(3.0) {
            tagListViewHeight[tagListView.tag] = height
            tableView.setNeedsLayout()
        }
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
                delegate?.currentLanguageCode = OFFplists.manager.languageCode(for:language)
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
        default:
            return
        }
        tableView.reloadData()
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
        default:
            return
        }
        tableView.reloadData()
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
        case .packaging:
            switch packagingToDisplay {
            case .available(var list):
                list.removeAll()
                productPair?.update(packagingTags: list)
            default:
                assert(true, "IdentificationTableViewController: How can I delete a tag when there are none")
                
            }
        default:
            return
        }
        tableView.reloadData()
    }

}
//
// MARK: - UITextField Delegate Functions
//
extension IdentificationTableViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if #available(iOS 13.0, *) {
            textField.textColor = .label
        } else {
            textField.textColor = .black
        }
    }
    
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
        default:
            return
        }
        if #available(iOS 13.0, *) {
            textField.textColor = .secondaryLabel
        } else {
            textField.textColor = .black
        }

        tableView.reloadData()
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
            /*
        case .barcodeSearch:
            return query!.type == .advanced ? false : editMode
 */
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        doubleTapOnTableView()
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
