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
        
        func header() -> String {
            switch self {
            case .barcode(_, let headerTitle):
                return headerTitle
            case .barcodeSearch(_, let headerTitle):
                return headerTitle
            case .name(_, let headerTitle):
                return headerTitle
            case .nameSearch(_, let headerTitle):
                return headerTitle
            case .genericName(_, let headerTitle):
                return headerTitle
            case .genericNameSearch(_, let headerTitle):
                return headerTitle
            case .languages(_, let headerTitle):
                return headerTitle
            case .languagesSearch(_, let headerTitle):
                return headerTitle
            case .brands(_, let headerTitle):
                return headerTitle
            case .brandsSearch(_, let headerTitle):
                return headerTitle
            case .packaging(_, let headerTitle):
                return headerTitle
            case .packagingSearch(_, let headerTitle):
                return headerTitle
            case .quantity(_, let headerTitle):
                return headerTitle
            case .quantitySearch(_, let headerTitle):
                return headerTitle
            case .image(_, let headerTitle):
                return headerTitle
            case .imageSearch(_, let headerTitle):
                return headerTitle
            }
        }
        
        func numberOfRows() -> Int {
            switch self {
            case .barcode(let numberOfRows, _):
                return numberOfRows
            case .barcodeSearch(let numberOfRows, _):
                return numberOfRows
            case .name(let numberOfRows, _):
                return numberOfRows
            case .nameSearch(let numberOfRows, _):
                return numberOfRows
            case .genericName(let numberOfRows, _):
                return numberOfRows
            case .genericNameSearch(let numberOfRows, _):
                return numberOfRows
            case .languages(let numberOfRows, _):
                return numberOfRows
            case .languagesSearch(let numberOfRows, _):
                return numberOfRows
            case .brands(let numberOfRows, _):
                return numberOfRows
            case .brandsSearch(let numberOfRows, _):
                return numberOfRows
            case .packaging(let numberOfRows, _):
                return numberOfRows
            case .packagingSearch(let numberOfRows, _):
                return numberOfRows
            case .quantity(let numberOfRows, _):
                return numberOfRows
            case .quantitySearch(let numberOfRows, _):
                return numberOfRows
            case .image(let numberOfRows, _):
                return numberOfRows
            case .imageSearch(let numberOfRows, _):
                return numberOfRows
            }
        }
    }
    
    private var selectedSection: Int? = nil
    
    // MARK: - public variables
    
    public var tableItem: Any? = nil {
        didSet {
            if let item = tableItem as? FoodProduct {
                self.product = item
            } else if let item = tableItem as? SearchTemplate {
                self.query = item
            }
        }
    }
    
    fileprivate var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructure = setupSections()
                // check if the currentLanguage needs to be updated
                setCurrentLanguage()
                tableView.reloadData()
            }
        }
    }
    
    fileprivate var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                tableStructure = setupSections()
                // check if the currentLanguage needs to be updated
                setCurrentLanguage()
                tableView.reloadData()
            }
        }
    }
    
    // This function finds the language that must be used to display the product
    private func setCurrentLanguage() {
        // is there already a current language?
        guard currentLanguageCode == nil else { return }
        // find the first preferred language that can be used
        for languageLocale in Locale.preferredLanguages {
            // split language and locale
            let preferredLanguage = languageLocale.split(separator:"-").map(String.init)[0]
            if let languageCodes = product?.languageCodes {
                if languageCodes.contains(preferredLanguage) {
                    currentLanguageCode = preferredLanguage
                    // found a valid code
                    return
                }
            }
        }
        // there is no match between preferred languages and product languages
        if currentLanguageCode == nil {
            currentLanguageCode = product?.primaryLanguageCode
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

    var currentLanguageCode: String? = nil {
        didSet {
            if currentLanguageCode != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Fileprivate Functions/variables
    
    fileprivate var brandsToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct?.brandsOriginal != nil  {
                // does it have brands redefined?
                switch delegate!.updatedProduct!.brandsOriginal {
                case .available, .empty:
                    showBrandTagsType = .edited
                    return delegate!.updatedProduct!.brandsOriginal
                default:
                    showBrandTagsType = TagsTypeDefault.Brands
                }
            }
            switch showBrandTagsType {
            case .interpreted:
                return product!.brandsInterpreted
            case .original:
                return product!.brandsOriginal
            default:
                    break
            }
            return .undefined
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
    }
    
    fileprivate var showPackagingTagsType: TagsType = TagsTypeDefault.Packaging
    
    fileprivate var showBrandTagsType: TagsType = TagsTypeDefault.Brands

    private var showLanguagesTagsType: TagsType = TagsTypeDefault.Languages

    fileprivate var packagingToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have edited packaging tags defined?
                switch delegate!.updatedProduct!.packagingOriginal {
                case .available, .empty:
                    showPackagingTagsType = .edited
                    return delegate!.updatedProduct!.packagingOriginal
                default:
                    showPackagingTagsType = TagsTypeDefault.Packaging
                }
            }
            switch showPackagingTagsType {
            case .interpreted:
                    return product!.packagingInterpreted
            case .original:
                    return product!.packagingOriginal
            case .hierarchy:
                    return product!.packagingHierarchy
            case .prefixed:
                return product!.packagingOriginal.prefixed(withAdded:product!.primaryLanguageCode, andRemoved:Locale.interfaceLanguageCode())
            case .translated, .edited:
                return .undefined
            }
        }
    }
    
    fileprivate var languagesToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have edited packaging tags defined?
                switch delegate!.updatedProduct!.languageTags {
                case .available, .empty:
                    showLanguagesTagsType = .edited
                    return delegate!.updatedProduct!.languageTags
                default:
                    break
                }
            } else {
                showLanguagesTagsType = TagsTypeDefault.Languages
            }
            switch showLanguagesTagsType {
            case .translated:
                // show the languageCodes in a localized language
                return product!.languageTags
            default:
                return .undefined
            }
        }
    }

    fileprivate var searchResult: String = ""

    // MARK: - Action methods
    
    // should redownload the current product and reload it in this scene
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            if let validProduct = product {
                OFFProducts.manager.reload(validProduct)
            }
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
        }
        struct SegueIdentifier {
            static let ShowIdentificationImage = "Show Identification Image"
            static let ShowNamesLanguages = "Show Names Languages"
            static let ShowSelectMainLanguage = "Show Select Main Language Segue"
            static let ShowImageSourceSelector = "Show Select Image Source Segue"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections
        return tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.section]
        
        switch currentProductSection {
        case .barcode:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Barcode, for: indexPath) as! BarcodeTableViewCell
            cell.barcode = product?.barcode.asString()
            cell.mainLanguageCode = delegate?.updatedProduct?.primaryLanguageCode != nil ? delegate!.updatedProduct!.primaryLanguageCode : product!.primaryLanguageCode
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
                //cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.editMode = false
                cell.tag = indexPath.section
                return cell
            }
            
        case .quantitySearch, .imageSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            //cell.width = tableView.frame.size.width
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
                    cell.name =  editMode ? nil : TranslatableStrings.SearchInNameEtc
                }
                cell.tag = indexPath.section
                cell.editMode = query!.type == .simple ? false : editMode
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
                //cell.width = tableView.frame.size.width
                cell.datasource = self
                cell.editMode = false
                cell.tag = indexPath.section
                return cell
            }
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ProductName, for: indexPath) as? ProductNameTableViewCell
            cell!.delegate = self
            cell!.tag = indexPath.section
            cell!.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if let validCurrentLanguageCode = currentLanguageCode {
                // has the product name been edited?
                if let validName = delegate?.updatedProduct?.nameLanguage[validCurrentLanguageCode]  {
                    cell!.name = validName
                } else if let validName = product?.nameLanguage[validCurrentLanguageCode] {
                    cell!.name = validName
                } else {
                    cell!.name = nil
                }
            }
            return cell!
            
        case .genericName:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ProductName, for: indexPath) as! ProductNameTableViewCell
            cell.delegate = self
            cell.tag = indexPath.section
            cell.editMode = editMode // currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if let validCurrentLanguageCode = currentLanguageCode {
                if let validName = delegate?.updatedProduct?.genericNameLanguage[validCurrentLanguageCode] {
                    cell.name = validName
                } else if let validName = product!.genericNameLanguage[validCurrentLanguageCode] {
                        cell.name = validName
                } else {
                    cell.name = nil
                }
            }
            return cell

        case .languages:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            //cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            print("id tableView", tableView.frame.size.width, "id cell", cell.frame.size.width)
            cell.editMode = query != nil ? editMode : false
            cell.tag = indexPath.section
            print("id tagListView", cell.tagListView.frame.size.width)

            return cell

        case .brands, .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            //cell.width = tableView.frame.size.width
            //print("Cell", cell.frame)

            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            return cell
            
        case .brandsSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            //cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.allowInclusionEdit = query!.type != .simple
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.brands.1 ?? true
            return cell
            
        case  .languagesSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            //cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.allowInclusionEdit = query!.type != .simple
            cell.inclusion = OFFProducts.manager.searchQuery?.languages.1 ?? true
            return cell

        case .packagingSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            //cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            cell.inclusion = OFFProducts.manager.searchQuery?.packaging.1 ?? true
            cell.allowInclusionEdit = query!.type != .simple
            return cell
            
        case .quantity:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Quantity, for: indexPath) as! QuantityTableViewCell
            if let validQuantity = delegate?.updatedProduct?.quantity {
                cell.tekst = validQuantity
            } else if let validQuantity = product?.quantity {
                cell.tekst = validQuantity
            } else {
                cell.tekst = nil
            }
            cell.editMode = editMode
            cell.delegate = self
            cell.tag = indexPath.section
            return cell
            
        case .image:
            if currentImage != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                cell.productImage = currentImage
                cell.delegate = self
                return cell
            } else {
                searchResult = ImageFetchResult.noImageAvailable.description
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
    
    
    public var currentImage: UIImage? {
        // are there any updated front images?
        if delegate?.updatedProduct?.frontImages != nil && !delegate!.updatedProduct!.frontImages.isEmpty  {
            // Is there an updated image corresponding to the current language
            if let image = delegate!.updatedProduct!.frontImages[currentLanguageCode!]!.original?.image {
                return image
            }
            
            // try the regular front images
        } else if !product!.frontImages.isEmpty {
            // is the data for the current language available?
            if let result = product!.frontImages[currentLanguageCode!]?.display?.fetch() {
                switch result {
                case .available:
                    return product!.frontImages[currentLanguageCode!]?.display?.image
                default:
                    break
                }
                // fall back to the primary languagecode nutrition image
                // if we are NOT in edit mode
            } else if !editMode,
                let primaryLanguageCode = product!.primaryLanguageCode,
                let result = product!.frontImages[primaryLanguageCode]?.display?.fetch() {
                switch result {
                case .available:
                    return product!.frontImages[primaryLanguageCode]?.display?.image
                default:
                    break
                }
            }
        }
        // No relevant image is available
        return nil
    }

    func changeLanguage() {
        // set the next language in the array
        if let availableLanguages = product?.languageCodes {
            if availableLanguages.count > 1 && currentLanguageCode != nextLanguageCode() {
                currentLanguageCode = nextLanguageCode()
                // reload the first two rows
                let indexPaths = [IndexPath.init(row: 0, section: 1),
                                  IndexPath.init(row: 0, section: 2)]
                tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.fade)
                tableView.deselectRow(at: indexPaths.first!, animated: true)
                tableView.deselectRow(at: indexPaths.last!, animated: true)
            }
        }
    }
    
    fileprivate func nextLanguageCode() -> String {
        let currentIndex = (product?.languageCodes.index(of: currentLanguageCode!))!
        
        let nextIndex = currentIndex == ((product?.languageCodes.count)! - 1) ? 0 : (currentIndex + 1)
        return (product?.languageCodes[nextIndex])!
    }
        
    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentProductSection = tableStructure[section]
        switch currentProductSection {
        case .image, .name, .genericName :
            return nil
            
        case .brands:
            switch showBrandTagsType {
            case TagsTypeDefault.Brands:
                return tableStructure[section].header()
            default:
                return tableStructure[section].header() +
                    " " +
                    "(" +
                    showBrandTagsType.description() +
                    ")"
            }
            
        case .packaging:
            switch showPackagingTagsType {
            case TagsTypeDefault.Packaging:
                return tableStructure[section].header()
            default:
                return tableStructure[section].header() +
                    " " +
                    "(" +
                    showPackagingTagsType.description() +
                    ")"
            }

        default:
            return tableStructure[section].header()
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentProductSection = tableStructure[section]
        
        switch currentProductSection {
        case .image, .name, .genericName :
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LanguageHeaderView") as! LanguageHeaderView
            headerView.section = section
            headerView.delegate = self
            headerView.title = tableStructure[section].header()
            headerView.languageCode = currentLanguageCode
            headerView.buttonIsEnabled = editMode ? true : ( product!.languageCodes.count > 1 ? true : false )
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
                if let vc = segue.destination as? ImageViewController {
                    vc.imageTitle = TextConstants.ShowIdentificationTitle
                    // is there an updated image?
                    if delegate?.updatedProduct?.frontImages != nil && !delegate!.updatedProduct!.frontImages.isEmpty {
                        vc.imageData = delegate!.updatedProduct!.image(for:currentLanguageCode!, of:.front)
                    } else {
                        vc.imageData = product!.image(for:currentLanguageCode!, of:.front)
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
                                vc.currentLanguageCode = currentLanguageCode
                                vc.primaryLanguageCode = delegate?.updatedProduct?.primaryLanguageCode != nil ? delegate!.updatedProduct!.primaryLanguageCode : product!.primaryLanguageCode
                                vc.languageCodes = product!.languageCodes
                                vc.updatedLanguageCodes = delegate?.updatedProduct != nil ? delegate!.updatedProduct!.languageCodes : []
                                vc.editMode = editMode
                                vc.delegate = delegate
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
                                vc.currentLanguageCode = delegate?.updatedProduct?.primaryLanguageCode != nil ? delegate!.updatedProduct!.primaryLanguageCode : product!.primaryLanguageCode
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
                delegate?.updated(primaryLanguageCode: newLanguageCode)
                currentLanguageCode = newLanguageCode
                tableView.reloadData()
            }
        }
    }

// MARK: - Notification handlers
    

    @objc func reloadImageSection() {
        tableView.reloadData()
    }
    
    fileprivate func imageSection(_ array: [SectionType]) -> Int? {
        for (index, sectionType) in array.enumerated() {
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
        tableView.reloadData()
    }
    
    @objc func loadFirstProduct() {
        let products = OFFProducts.manager
        if !products.fetchResultList.isEmpty {
            switch products.fetchResultList[0] {
            case .success(let firstProduct):
                product = firstProduct
                tableView.reloadData()
            default: break
            }
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
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessBarcodeKey] as? String {
            if let productBarcode = product?.barcode.asString() {
                if barcode == productBarcode {
                    // is it relevant to the main image?
                    if let id = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessImagetypeKey] as? String {
                        if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) {
                            // reload product data
                            OFFProducts.manager.reload(self.product!)
                        }
                    }
                }
            }
        }
    }
    
    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageDeleteSuccessBarcodeKey] as? String {
            if barcode == product!.barcode.asString() {
                // is it relevant to the main image?
                if let id = notification.userInfo?[OFFUpdate.Notification.ImageDeleteSuccessImagetypeKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) {
                        // reload product data
                        OFFProducts.manager.reload(self.product!)
                    }
                }
            }
        }
    }

    @objc func removeProduct() {
        product = nil
        tableView.reloadData()
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        self.tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")
        // print("viewDidLoad", self.view.frame, self.parent?.view.frame)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("id viewWillAppear frame", self.view.frame.size.width, "parent", self.parent?.view.frame.size.width, "tableView", self.tableView.frame.size.width)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:.MainImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.SearchTypeChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded(_:)), name:.OFFUpdateImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.OFFUpdateImageDeleteSuccess, object:nil)
        // NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.changeTagsTypeShown), name:.TagListViewTapped, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("id viewDidAppear frame", self.view.frame.size.width, "parent", self.parent?.view.frame.size.width, "tableView", self.tableView.frame.size.width)
        // suggested by http://useyourloaf.com/blog/self-sizing-table-view-cells/
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - TagListViewCellDelegate Functions

extension IdentificationTableViewController: BarcodeEditCellDelegate {
    
    // function to let the delegate know that the switch changed
    func barcodeEditTableViewCell(_ sender: BarcodeEditTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
        if let validCode = query!.barcode?.asString(),
            let validProductType = query!.barcode?.productType() {
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

// MARK: - TagListViewCellDelegate Functions

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
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        case .brands:
            showBrandTagsType.cycle()
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        default:
            break
        }
    }
}

// MARK: - ProductNameCellDelegate Functions

extension IdentificationTableViewController: ProductNameCellDelegate {
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedDoubleTap textView:UITextView) {
        changeLanguage()
    }
}

// MARK: - IdentificationImageCellDelegate Functions

extension IdentificationTableViewController: ProductImageCellDelegate {
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
        }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton) {
        guard currentLanguageCode != nil else { return }
        guard product != nil else { return }
        let update = OFFUpdate()
        update.deselect([currentLanguageCode!], of: .front, for: product!)
    }
    
}

// MARK: - TagListViewAddImageCellDelegate functions

extension IdentificationTableViewController: TagListViewAddImageCellDelegate {
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
}

// MARK: - TagListViewSegmentedControlCellDelegate Functions

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
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .packagingSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.packaging.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .brandsSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.brands.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        default:
            break
        }
    }
}

// MARK: - TextView Delegate Functions

extension IdentificationTableViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editMode
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.isFirstResponder { textView.resignFirstResponder() }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let currentProductSection = tableStructure[textView.tag]
        
        switch currentProductSection {
        case .name:
            // productname
            if let validText = textView.text {
                if let validCurrentLanguageCode = currentLanguageCode {
                    delegate?.updated(name: validText, languageCode: validCurrentLanguageCode)
                }
            }
        case .genericName:
            // generic name updated?
            if let validText = textView.text,
                let validCurrentLanguageCode = currentLanguageCode {
                    delegate?.updated(genericName: validText, languageCode: validCurrentLanguageCode)
            }
        case .nameSearch, .genericNameSearch:
            // name or generic name updated?
            if let validText = textView.text {
                if OFFProducts.manager.searchQuery == nil {
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

// MARK: - TagListView DataSource Functions

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
        case .quantitySearch, .imageSearch:
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
            // no language adjustments need to be done
            return title(brandsToDisplay)
        case .brandsSearch:
            return title(searchBrandsToDisplay)
        case .packaging:
            return title(packagingToDisplay)
        case .packagingSearch:
            return title(searchPackagingToDisplay)
        case .languages:
            // print("\(languagesToDisplay)")
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
                delegate?.update(brandTags: list)
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
                delegate?.update(packagingTags: list)
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

// MARK: - TagListView Delegate Functions

extension IdentificationTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .brands:
            switch brandsToDisplay {
            case .undefined, .empty:
                delegate?.update(brandTags: [title])
            case .available(var list):
                list.append(title)
                delegate?.update(brandTags: list)
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
                delegate?.update(packagingTags: [title])
            case .available(var list):
                list.append(title)
                delegate?.update(packagingTags: list)
            default:
                assert(true, "IdentificationTableViewController: How can I add a packaging tag when the field is non-editable")
            }
        case .languages:
            switch languagesToDisplay {
            case .undefined, .empty, .available:
                delegate?.update(addLanguageCode: title)
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
                delegate?.update(brandTags: list)
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
                delegate?.update(packagingTags: list)
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
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .languages:
            delegate?.search(for: product!.languages[index], in: .language)
        case .brands:
            // use the interpreted tags for search !!!!
            switch product!.brandsInterpreted {
            case .available:
                delegate?.search(for: product?.brandsInterpreted.tag(at: index), in: .brand)
            default:
                break
            }
        case .packaging:
            switch product!.packagingInterpreted {
            case .available:
                delegate?.search(for: product!.packagingInterpreted.tag(at: index), in: .packaging)
            default:
                break
            }

        default:
            break

        }
    }
    
}

// MARK: - UITextField Delegate Functions

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
                delegate?.update(quantity: validText)
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
            return currentLanguageCode == product!.primaryLanguageCode ? editMode : false
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate Functions

extension IdentificationTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
    }

}

// MARK: - UIPopoverPresentationControllerDelegate Functions

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

extension IdentificationTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        
        // print("front image", image.size)
        delegate?.updated(frontImage: image, languageCode: currentLanguageCode!)
        tableView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - LanguageHeaderDelegate Functions

extension IdentificationTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowNamesLanguages, sender: sender)
    }
}

// MARK: - UIDragInteractionDelegate Functions

@available(iOS 11.0, *)
extension IdentificationTableViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    private func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let image = currentImage else { return [] }
        
        // only allow flocking of another image
        for item in session.items {
            // Note kUTTypeImage needs an import of MobileCoreServices
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.section]
        switch currentProductSection {
        case .nutritionImage :
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
        
        guard currentLanguageCode != nil else { return }
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            // Only one image is accepted as ingredients image for the current language
            if images.count > 0 && images.count <= 1 {
                self.delegate?.updated(frontImage: images[0] as! UIImage, languageCode:self.currentLanguageCode!)
                self.reloadImageSection()
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



