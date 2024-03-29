//
//  IdentificationTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
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
    
    var coordinator: IdentificationCoordinator? = nil
    
// MARK: - private variables
    
    private var editMode: Bool {
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
    public var currentLanguageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
        set {
            // This is set when a new LanguageCode is added, the interface will be updated
            // so that the user can enter data for this new languageCode
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
            // remove the currentLanguage prefix if there is one
            let cleanedTags = productPair?.remoteProduct?.packagingOriginal.prefixed(withAdded: nil, andRemoved: Locale.interfaceLanguageCode)
            return  cleanedTags ?? .undefined
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

    private var uploadProgressRatio: CGFloat? = nil
    
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
        case barcode
        case name
        case genericName
        case languages
        case brands
        case packaging
        case quantity
        case conservation
        case preparation
        case image
        case comment
        case folksonomy
    }

    private var tagListViewHeight: [Int:CGFloat] = [:]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections
        return tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableStructure[section] {
        case .folksonomy:
            if let tags = productPair?.folksonomyTags {
                return tags.count
            }
        default:
            break
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableStructure[indexPath.section] {
        case .barcode:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: BarcodeTableViewCell.self), for: indexPath) as! BarcodeTableViewCell
            cell.barcode = productPair?.barcodeType.asString
            cell.mainLanguageCode = primaryLanguageCodeToDisplay
            cell.editMode = editMode
            cell.delegate = self
            cell.tag = indexPath.section
            if editMode,
                productPair?.localProduct?.primaryLanguageCode != productPair?.remoteProduct?.primaryLanguageCode {
                cell.editMode = productVersion.isRemote ? false : true
            }
            return cell

        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ProductNameTableViewCell.self), for: indexPath) as! ProductNameTableViewCell
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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ProductNameTableViewCell.self), for: indexPath) as! ProductNameTableViewCell
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
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewButtonTableViewCell.self), for: indexPath) as! TagListViewButtonTableViewCell
                cell.setup(datasource: self,
                           delegate: self,
                           showButton: false,
                           width: tableView.frame.size.width,
                           tag: indexPath.section)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
                cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
                return cell
            }
        case .brands:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
            return cell

        case .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
            return cell
            
        case .quantity:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: QuantityTableViewCell.self), for: indexPath) as! QuantityTableViewCell
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
            
        case .preparation, .conservation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell.IdentificationTableViewController", for: indexPath)
            switch tableStructure[indexPath.section] {
            case .preparation:
                if let validLanguageCode = displayLanguageCode,
                    let valid = productPair?.remoteProduct?.preparationLanguage[validLanguageCode] {
                    cell.textLabel?.text = valid
                } else {
                    cell.textLabel?.text = "No preparation supplied for this language"
                }
            default:
                if let validLanguageCode = displayLanguageCode,
                    let valid = productPair?.remoteProduct?.conservationConditionsLanguage[validLanguageCode] {
                    cell.textLabel?.text = valid
                } else {
                    cell.textLabel?.text = "No conservation conditions supplied for this language"
                }
            }
            return cell
            
        case .image:
            if currentImage.0 != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ProductImageTableViewCell.self), for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                if editMode,
                    let localPair = localFrontImage,
                    localPair.0 != nil {
                    cell.editMode = productVersion.isRemote ? false : true
                }
                cell.productImage = currentImage.0
                cell.uploadTime = currentImage.2
                // show the up-/download ratio
                cell.progressRatio = self.uploadProgressRatio
                cell.delegate = self
                return cell
            } else {
                searchResult = currentImage.1
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewAddImageTableViewCell.self), for: indexPath) as! TagListViewAddImageTableViewCell
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, editMode: editMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: ColorSchemes.error)
                return cell
            }
            
        // This section shows a personal comment by the user.
        // It is only stored locally and NOT uploaded to OFF.
        case .comment:
            // There is a comment OR we are editing
            if productPair?.comment != nil || editMode {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: QuantityTableViewCell.self), for: indexPath) as! QuantityTableViewCell
                cell.tekst = productPair?.comment
                cell.editMode = editMode
                cell.delegate = self
                cell.tag = indexPath.section
                return cell
                // There is no comment and we are not editing
                // A status tag is shown, indicating no comment has been set
            } else {
                // If there is no comment, show a tag with the text "No Comment set"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
                return cell
            }
        case .folksonomy:
            if productPair?.folksonomyTags != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BasicDetailedTableViewCell.IdentificationTableViewController", for: indexPath)
                if let tags = productPair?.folksonomyTags,
                    !tags.isEmpty {
                    cell.textLabel?.text = tags[indexPath.row].k
                    cell.detailTextLabel?.text = tags[indexPath.row].v
                } else {
                    cell.textLabel?.text = "no tags set"
                }
                return cell

            } else {
                // If there is no folksonomy item, show a tag with the text "No folksonomy items set"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: false)
        switch tableStructure[indexPath.section] {
        case .image:
            guard let validLanguageCode = displayLanguageCode else { return }
            if let images = productPair?.localProduct?.frontImages,
                !images.isEmpty {
                coordinator?.showImage(imageTitle: TranslatableStrings.Identification, imageSize: productPair!.localProduct!.image(imageType: .front(validLanguageCode)))
            } else {
                coordinator?.showImage(imageTitle: TranslatableStrings.Identification, imageSize: productPair!.remoteProduct!.image(imageType: .front(validLanguageCode)))
            }
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? ProductNameTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? TagListViewAddImageTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? TagListViewButtonTableViewCell {
            validCell.willDisappear()
        }
        
    }

    public var currentImage: (UIImage?, String, Double?) {
        switch productVersion {
        case .new:
            return localFrontImage ?? remoteFrontImage ?? ( nil, TranslatableStrings.NoImageAvailable, nil)
        default:
            return remoteFrontImage ?? (nil, TranslatableStrings.NoImageAvailable, nil)
        }
    }
    
    private var localFrontImage: (UIImage?, String, Double?)? {
        if let frontImages = productPair?.localProduct?.frontImages,
            let validLanguageCode = displayLanguageCode,
            !frontImages.isEmpty,
            let fetchResult = frontImages[validLanguageCode]?.original?.fetch() {
            switch fetchResult {
            case .success(let image):
                return (image, "Updated Image", nil)
            default: break
            }
        }
        return nil
    }
    
    private var remoteFrontImage: (UIImage?, String, Double?)? {

        func processLanguageCode(_ languageCode: String) -> (UIImage?, String, Double?)?{
            guard let imageSet = productPair?.remoteProduct?.image(imageType: .front(languageCode)) else { return nil }
            let result = imageSet.display?.fetch()
            switch result {
            case .success(let image):
                return (image, "Current Language Image", imageSet.imageDate)
            case .loading:
                return (nil, ImageFetchResult.loading.description, imageSet.imageDate)
            case .loadingFailed(let error):
                return (nil, error.localizedDescription, imageSet.imageDate)
            case .noResponse:
                return (nil, ImageFetchResult.noResponse.description, imageSet.imageDate)
            default:
                return nil
            }
        }
        
        guard let validDisplayLanguageCode = displayLanguageCode else { return nil }
        guard let validPrimaryLanguageCode = productPair?.remoteProduct?.primaryLanguageCode else { return nil }
        
        if editMode {
            return processLanguageCode(validDisplayLanguageCode)
        } else {
            return processLanguageCode(validDisplayLanguageCode) ?? processLanguageCode(validPrimaryLanguageCode)
        }
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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentProductSection = tableStructure[section]
        
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LanguageHeaderView.identifier) as! LanguageHeaderView
        headerView.section = section
        headerView.delegate = self
        // do not add any button or double tap
        headerView.buttonNotDoubleTap = buttonNotDoubleTap
        headerView.changeViewModeButton.isHidden = true
        
        var header = ""
        switch currentProductSection {
            // The headers with a language
        case .image, .name, .genericName :
            if let validNumberOfProductLanguages = productPair?.remoteProduct?.languageCodes.count {
            // Hide the change language button if there is only one language, but not in editMode
                headerView.changeLanguageButton.isHidden = validNumberOfProductLanguages > 1 ? false : !editMode
            } else {
                headerView.changeLanguageButton.isHidden = false
            }
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
            /// Enable the mode view button only when we are NOT in editmode
            headerView.languageButtonIsEnabled = editMode ? true : ( (productPair?.product?.languageCodes.count ?? 0) > 1 ? true : false )
            headerView.changeViewModeButton.isHidden = true
            // add a space to nice separate the title from the language button
            headerView.title = header + " "
            return headerView
            
        case .barcode, .brands, .packaging, .quantity, .languages, .comment:
            headerView.changeLanguageButton.isHidden = true
            headerView.changeViewModeButton.isHidden = editMode
            
            switch currentProductSection {
            case .barcode:
                // it is not possible to edit the barcode
                header = TranslatableStrings.Barcode
                
            case .languages:
                header = TranslatableStrings.Languages
                
            case .comment:
                header = TranslatableStrings.Comment
                
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
                    header = TranslatableStrings.BrandsOriginal
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
                    header = TranslatableStrings.PackagingOriginal
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
            
        case .preparation, .conservation:
            if let validNumberOfProductLanguages = productPair?.remoteProduct?.languageCodes.count {
            // Hide the change language button if there is only one language, but not in editMode
                headerView.changeLanguageButton.isHidden = validNumberOfProductLanguages > 1 ? false : !editMode
            } else {
                headerView.changeLanguageButton.isHidden = false
            }
            switch tableStructure[section] {
            case .conservation:
                    headerView.title = "Conservation" + " "
            default:
                    headerView.title = "Preparation" + " "
            }
            headerView.buttonText = OFFplists.manager.languageName(for: displayLanguageCode)
            return headerView
        case .folksonomy:
            headerView.title = "Folksonomy tags"
            return headerView
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let validView = view as? LanguageHeaderView {
            validView.willDisappear()
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

    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        var index = 0

        sectionsAndRows.append(.barcode)
        index += 1

        sectionsAndRows.append(.name)
        index += 1

        sectionsAndRows.append(.genericName)
        index += 1

        sectionsAndRows.append(.languages)
        tagListViewHeight[index] = Constants.CellHeight.TagListViewCell
        index += 1

        sectionsAndRows.append(.brands)
        tagListViewHeight[index] = Constants.CellHeight.TagListViewCell
        index += 1

        sectionsAndRows.append(.packaging)
        tagListViewHeight[5] = Constants.CellHeight.TagListViewCell
        index += 1

        sectionsAndRows.append(.quantity)
        index += 1
        
        // conservation conditions supplied by the producer
        if let valid = productPair?.remoteProduct?.conservationConditionsLanguage,
            !valid.isEmpty {
            sectionsAndRows.append(.conservation)
            index += 1
        }
        
        // preparation supplied by the producer
        if let valid = productPair?.remoteProduct?.preparationLanguage,
            !valid.isEmpty {
            sectionsAndRows.append(.preparation)
            index += 1
        }

        sectionsAndRows.append(.image)
        index += 1
        
        sectionsAndRows.append(.comment)
        index += 1

        sectionsAndRows.append(.folksonomy)
        index += 1

        return sectionsAndRows
    }

// MARK: - Notification handlers

    @objc func imageUpdated(_ notification: Notification) {
        guard !editMode else { return }

        // only update if the image barcode corresponds to the current product
        guard let currentProductBarcode = productPair?.remoteProduct?.barcode.asString else { return }
        guard let noticifationBarcode = notification.userInfo?[ProductImageData.Notification.BarcodeKey] as? String else { return }
        guard currentProductBarcode == noticifationBarcode else { return }
        
        // We can not check the imageType,
        // as the image might be retrieved from disk
        // is it relevant to the main image?
        //guard let id = notification.userInfo?[ProductImageData.Notification.ImageTypeCategoryKey] as? String else { return }
        //guard id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) else { return }
        
        self.uploadProgressRatio = nil
        reloadImageSection()
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
        guard let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String else { return }
        guard let productBarcode = productPair!.remoteProduct?.barcode.asString else { return }
        guard barcode == productBarcode else { return }
        
        // is it relevant to the main image?
        guard let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String else { return }
        guard id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) else { return }
                            
        // reload product data
        self.productPair?.reload()
    }
    
    @objc func progress(_ notification: Notification) {
        guard !editMode else { return }
        
        // Check if this upload notification is relevant to this product
        guard let barcode = notification.userInfo?[OFFImageUploadAPI.Notification.BarcodeKey] as? String else { return }
        guard let productBarcode = productPair!.remoteProduct?.barcode.asString else { return }
        guard barcode == productBarcode else { return }
        
        // is this notification relevant to the front image?
        guard let id = notification.userInfo?[OFFImageUploadAPI.Notification.ImageTypeCategoryKey] as? String else { return }
        guard id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) else  { return }
        
        guard let progress = notification.userInfo?[OFFImageUploadAPI.Notification.ProgressKey] as? String else { return }
        guard let progressDouble = Double(progress) else { return }
        self.uploadProgressRatio = CGFloat(progressDouble)
        
        // reload the table to update the progress indicator
        self.tableView.reloadData()
    }

    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if barcode == productPair!.remoteProduct!.barcode.asString {
                // is it relevant to the main image?
                if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Ingredients) {
                        // reload product data
                        self.productPair?.reload()
                    }
                }
            }
        }
    }

    //@objc func removeProduct() {
        //TODO: why is this function?
        //productPair!.remoteProduct = nil
        //§tableView.reloadData()
    //}

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

//
// MARK: - ViewController Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinator = IdentificationCoordinator.init(with: self)

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        self.tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = true
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 36
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableStructure = setupSections()
        tableView.reloadData()

        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(IdentificationTableViewController.refreshProduct),
            name: .ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded(_:)), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.OFFProductsImageDeleteSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.progress(_:)), name:.ImageUploadProgress, object:nil)
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
extension IdentificationTableViewController:  BarcodeTableViewCellDelegate {
    
    func barcodeTableViewCell(_ sender:BarcodeTableViewCell, didTap button:UIButton) {
        coordinator?.selectMainLanguage(for: self.productPair)
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
    
    // function to let the delegate know that the button has been tapped
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedTapOn button:UIButton) {
        coordinator?.addLanguages(for: self.productPair)
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
        OFFProducts.manager.deselectImage(for: validProductPair, in: validLanguageCode, of: .front(validLanguageCode))
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
                return editMode ? 0 : 1
            case .empty:
                return editMode ? 0 : 1
            case let .available(list):
                return list.count
            case .notSearchable:
                return 1
            }
        }
        
        let currentProductSection = tableStructure[tagListView.tag]
        
        switch currentProductSection {
        case .brands:
            // do not show the robotoff labels in editMode
            guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .brand),
                let validTags = editMode
                    ? brandsToDisplay
                    : Tags.add(right: brandsToDisplay,
                                         left: Tags(list:questions.map({ $0.value ?? "No value" })))
            else {
                return count(.undefined)
            }
            return count(validTags)
        case .packaging:
            return count(packagingToDisplay)
        case .languages:
            return count(languagesToDisplay)
        case .comment, .folksonomy:
            return 1
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
            guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .brand),
                let validTags = editMode
                    ? brandsToDisplay
                    : Tags.add(right: brandsToDisplay,
                                         left: Tags(list:questions.map({ $0.value ?? "No value" }))) else { return "" }
            return title(validTags)
        case .packaging:
            return title(packagingToDisplay)
        case .languages:
            return title(languagesToDisplay)
        case .image:
            return searchResult
        case .comment:
            return TranslatableStrings.NoCommentSet
        case .folksonomy:
            return "No folksonomy"
        default:
            return("IdentificationTableViewController: TagListView titleForTagAt error")
        }
    }

    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
            
        func colorScheme(_ tags: Tags) -> ColorScheme {
            switch tags {
            case .undefined, .notSearchable:
                return ColorSchemes.error
            case .empty:
                return ColorSchemes.none
            case .available:
                return ColorSchemes.normal
            }
        }

        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
                print ("IdentificationTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
                return  nil
            }
        switch tableStructure[tagListView.tag] {
        case .brands:
            // Do I need to take into account any regular tags?
            if let validLabelsCount = brandsToDisplay.count,
                index <= validLabelsCount - 1 {
                return ColorSchemes.normal
            } else {
                if !editMode,
                    let questions = productPair?.remoteProduct?.robotoffQuestions(for: .brand), !questions.isEmpty {
                    return ColorSchemes.robotoff
                } else {
                    return ColorSchemes.none
                }
            }
        case .packaging:
            return colorScheme(packagingToDisplay)
        case .languages:
            return colorScheme(languagesToDisplay)
        case .image:
            return ColorSchemes.error
        case .comment:
            return ColorSchemes.normal
        case .folksonomy:
            return ColorSchemes.normal
        default:
            return nil
        }
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
        
    func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool {
        switch tableStructure[tagListView.tag] {
        case .brands,
             .packaging:
            return editMode
        default:
            return false
        }
    }

    public func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool {
        switch tableStructure[tagListView.tag] {
        case .brands,
             .packaging:
            return editMode
        default:
            return false
        }
    }
    
    public func tagListView(_ tagListView: TagListView, canTapTagAt index: Int) -> Bool {
        
        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return false
        }
        
        switch tableStructure[tagListView.tag] {
        case .brands:
            guard !editMode else { return false }
            // Do I need to take into account any regular tags?
            if let count = brandsToDisplay.count {
                if index <= count - 1 {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        case .languages:
            return !editMode
        default:
            return false
        }

    }

    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        
        func askQuestion(for type: RobotoffQuestionType, at index:Int) {
            guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: type) else { return }
            guard index >= 0 && index < questions.count else { return }
            var image: ProductImageSize?
            if let validID = questions[index].imageID {
                if let validImages = productPair?.remoteProduct?.images {
                    image = validImages[validID]
                }
            }
            coordinator?.showQuestion(for: productPair, question: questions[index], image: image)
        }

        switch tableStructure[tagListView.tag] {
        case .brands:
            // Do I need to take into account any regular tags?
            if let count = brandsToDisplay.count {
                if index <= count - 1 {
                    return
                } else {
                    askQuestion(for: .brand, at: index - count)
                }
            } else {
                askQuestion(for: .brand, at: index)
            }

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
    public func didDeleteAllTags(_ tagListView: TagListView) {
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
        case .comment:
            productPair?.comment = textField.text
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
        case .quantity, .comment:
            return editMode
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
        guard let primaryLanguageCode = self.productPair?.primaryLanguageCode else { return }
        guard let languageCodes = self.productPair?.languageCodes else { return }
        coordinator?.selectLanguage(primaryLanguageCode: primaryLanguageCode, currentLanguageCode: displayLanguageCode, productLanguageCodes: languageCodes, atAnchor: sender)
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
                productImageData = localProduct.image(imageType:.front(validLanguageCode))?.largest
            } else {
                productImageData = localProduct.image(imageType: .front(validLanguageCode))?.largest
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
    }
}
