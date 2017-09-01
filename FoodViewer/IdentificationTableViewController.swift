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
        static let ShowIdentificationTitle = NSLocalizedString("Image", comment: "Title for the viewcontroller with an enlarged image")
        static let ViewControllerTitle = NSLocalizedString("Identification", comment: "Title for the view controller with the product image, title, etc.")
        static let NoCommonName = NSLocalizedString("No common name available", comment: "String if no common name is available")
        static let NoName = NSLocalizedString("No name available", comment: "String if no name is available")
        static let NoQuantity = NSLocalizedString("No quantity available", comment: "String if no quantity is available")
    }
    
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
        
        func header() -> String {
            switch self {
            case .barcode(_, let headerTitle):
                return headerTitle
            case .name(_, let headerTitle):
                return headerTitle
            case .genericName(_, let headerTitle):
                return headerTitle
            case .languages(_, let headerTitle):
                return headerTitle
            case .brands(_, let headerTitle):
                return headerTitle
            case .packaging(_, let headerTitle):
                return headerTitle
            case .quantity(_, let headerTitle):
                return headerTitle
            case .image(_, let headerTitle):
                return headerTitle
            }
        }
        
        func numberOfRows() -> Int {
            switch self {
            case .barcode(let numberOfRows, _):
                return numberOfRows
            case .name(let numberOfRows, _):
                return numberOfRows
            case .genericName(let numberOfRows, _):
                return numberOfRows
            case .languages(let numberOfRows, _):
                return numberOfRows
            case .brands(let numberOfRows, _):
                return numberOfRows
            case .packaging(let numberOfRows, _):
                return numberOfRows
            case .quantity(let numberOfRows, _):
                return numberOfRows
            case .image(let numberOfRows, _):
                return numberOfRows
            }
        }
    }
    
    private var selectedSection: Int? = nil
    
    // MARK: - public variables
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableView.reloadData()
                // check if the currentLanguage needs to be updated
                setCurrentLanguage()
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
            let preferredLanguage = languageLocale.characters.split{$0 == "-"}.map(String.init)[0]
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
                    break
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
    
    private struct TagsTypeDefault {
        static let Brands: TagsType = .original
        static let Packaging: TagsType = .prefixed
    }
    
    private var showPackagingTagsType: TagsType = TagsTypeDefault.Packaging
    
    private var showBrandTagsType: TagsType = TagsTypeDefault.Brands
    
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
                    break
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
                    showPackagingTagsType = .edited
                    return delegate!.updatedProduct!.languageTags
                default:
                    break
                }
            }
            return product!.languageTags
        }
    }

    fileprivate var searchResult: String = ""

    // MARK: - Action methods
    
    // should redownload the current product and reload it in this scene
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let TextField = "Identification Basic Cell"
            static let ProductName = "Product Name Cell"
            static let Barcode = "Barcode Cell"
            static let Quantity = "Quantity Cell"
            static let TagList = "Identification TagList Cell"
            static let Packaging = "Identification Packaging Cell"
            static let Image = "Identification Image Cell"
            static let NoIdentificationImage = "No Image Cell"
        }
        struct SegueIdentifier {
            static let ShowIdentificationImage = "Show Identification Image"
            static let ShowNamesLanguages = "Show Names Languages"
            static let ShowSelectMainLanguage = "Show Select Main Language Segue"
            static let ShowImageSourceSelector = "Show Select Image Source Segue"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections (7)
        return product == nil ? 0 : tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.section]
        
        switch currentProductSection {
        case .barcode:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Barcode, for: indexPath) as? BarcodeTableViewCell
            cell!.barcode = product?.barcode.asString()
            cell!.mainLanguageCode = delegate?.updatedProduct?.primaryLanguageCode != nil ? delegate!.updatedProduct!.primaryLanguageCode : product!.primaryLanguageCode
            cell!.editMode = editMode
            return cell!
            
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.tag = indexPath.section
            return cell

        case .brands:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            return cell
            
        case .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Packaging, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
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
            // are there updated images available?
            if delegate?.updatedProduct?.frontImages != nil && !delegate!.updatedProduct!.frontImages.isEmpty {
                // is the image available for the current language?
                if let image = delegate!.updatedProduct!.frontImages[currentLanguageCode!]?.display?.image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IdentificationImageTableViewCell
                    cell?.editMode = editMode
                    cell?.identificationImage = image
                    return cell!
                // in non-editMode show the primary language image
                } else if !editMode, let primaryLanguageCode = delegate!.updatedProduct!.primaryLanguageCode, let image = delegate!.updatedProduct!.frontImages[primaryLanguageCode]?.display?.image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IdentificationImageTableViewCell
                    cell?.editMode = editMode
                    cell?.identificationImage = image
                    return cell!
                // no image in the two languageCodes is available
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoIdentificationImage, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = indexPath.section
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.error
                    searchResult = "No image in the right language"
                    return cell!
                }
            // in all the front images find the display images
            } else if !product!.frontImages.isEmpty {
                    // is the data for the current language available?
                    // then fetch the image
                if let result = product!.frontImages[currentLanguageCode!]?.display?.fetch() {
                    switch result {
                    case .available:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IdentificationImageTableViewCell
                        cell?.identificationImage = product!.frontImages[currentLanguageCode!]?.display?.image
                        cell?.editMode = editMode
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoIdentificationImage, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                // try to use the image corresponding to the primary language
                } else if !editMode, let primaryLanguageCode = product?.primaryLanguageCode, let result = product!.frontImages[primaryLanguageCode]?.display?.fetch() {
                    switch result {
                    case .available:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IdentificationImageTableViewCell
                        cell?.identificationImage = product!.frontImages[primaryLanguageCode]?.display?.image
                        cell?.editMode = editMode
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoIdentificationImage, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                // no image is available in the currentLanguage or the primary language
                } else {
                    if editMode {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IdentificationImageTableViewCell
                        cell?.identificationImage = nil
                        cell?.editMode = editMode
                        return cell!
                    } else {
                        // image could not be found (yet)
                        searchResult = ImageFetchResult.noImageAvailable.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoIdentificationImage, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                }
            } else {
                if editMode {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? IdentificationImageTableViewCell
                    cell?.identificationImage = nil
                    cell?.editMode = editMode
                    return cell!
                } else {
                    searchResult = ImageFetchResult.noImageAvailable.description()
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoIdentificationImage, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = indexPath.section
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.error
                    return cell!
                }
            }
        }
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
            static let Barcode = NSLocalizedString("Barcode", comment: "Tableview sectionheader for Barcode")
            static let Name = NSLocalizedString("Name", comment: "Tableview sectionheader for product name")
            static let CommonName = NSLocalizedString("Common Name", comment: "Tableview sectionheader for long product name")
            static let Languages = NSLocalizedString("Languages", comment: "Tableview sectionheader for languages on product")
            static let Brands = NSLocalizedString("Brands", comment: "Tableview sectionheader for brands.")
            static let Packaging = NSLocalizedString("Packaging", comment: "Tableview sectionheader for packaging.")
            static let Quantity = NSLocalizedString("Quantity", comment: "Tableview sectionheader for size of package.")
            static let Image = NSLocalizedString("Main Image", comment: "Tableview sectionheader for main image of package.")
        }
    }

    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        
        // All sections are always presented
        // 0: barcode section
        sectionsAndRows.append(.barcode(TableSection.Size.Barcode, TableSection.Header.Barcode))
        
        // 1:  name section
        sectionsAndRows.append(.name(TableSection.Size.Name, TableSection.Header.Name))
        
        // 2: common name section
        sectionsAndRows.append(.genericName(TableSection.Size.CommonName, TableSection.Header.CommonName))
        
        // 3: language tags section
        sectionsAndRows.append(.languages(TableSection.Size.Languages, TableSection.Header.Languages))

        // 4: brands section
        sectionsAndRows.append(.brands(TableSection.Size.Brands, TableSection.Header.Brands))
        
        // 5: packaging section
        sectionsAndRows.append(.packaging(TableSection.Size.Packaging, TableSection.Header.Packaging))
        
        // 6: quantity section
        sectionsAndRows.append(.quantity(TableSection.Size.Quantity, TableSection.Header.Quantity))
        
        // 7: image section
        sectionsAndRows.append(.image(TableSection.Size.Image,TableSection.Header.Image))
        
        // print("\(sectionsAndRows)")
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
                        vc.imageData = delegate!.updatedProduct!.frontImages[currentLanguageCode!]?.display
                    } else if !product!.frontImages.isEmpty {
                        // is the data for the current language available?
                            // then fetch the image
                        vc.imageData = product!.frontImages[currentLanguageCode!]?.largest()
                                // try to use the primary image
                    } else if let imageData = product!.frontImages[product!.primaryLanguageCode!]?.largest() {
                        vc.imageData = imageData
                    } else {
                        vc.imageData = nil
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
                        if button.superview?.superview as? IdentificationImageTableViewCell != nil {
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

    // MARK: - Notification handler
    
    func changeTagsTypeShown(_ notification: Notification) {
        if let tag = notification.userInfo?[TagListViewTableViewCell.Notification.TagKey] as? Int {
            let currentProductSection = tableStructure[tag]
            switch currentProductSection {
            case .packaging:
                showPackagingTagsType.cycle()
                tableView.reloadSections(IndexSet.init(integer: tag), with: .fade)
            case .brands:
                showBrandTagsType.cycle()
                tableView.reloadSections(IndexSet.init(integer: tag), with: .fade)
            default:
                break
            }
        }
    }
    
    func reloadImageSection() {
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
    
    func refreshProduct() {
        delegate?.updateCurrentLanguage()
        showPackagingTagsType = TagsTypeDefault.Packaging
        showBrandTagsType = TagsTypeDefault.Brands
        tableView.reloadData()
    }
    
    func loadFirstProduct() {
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

    func showMainLanguageSelector(_ notification: Notification) {
        if let sender = notification.userInfo?[BarcodeTableViewCell.Notification.MainLanguageButtonTappedKey] {
            performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowSelectMainLanguage, sender: sender)
        }
    }
    
    func takePhotoButtonTapped() {
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
                popoverPresentationController.permittedArrowDirections = .any

            }
        }
    }
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()

    func useCameraRollButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen

            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.permittedArrowDirections = .any
            }
        }
    }

    
    fileprivate func newImageSelected(info: [String : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
    }
    
    func imageUploaded(_ notification: Notification) {
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessBarcodeKey] as? String {
            if barcode == product!.barcode.asString() {
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


    func removeProduct() {
        product = nil
        tableView.reloadData()
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableStructure = setupSections()
        
        self.tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")

}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:.MainImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.changeLanguage), name:.NameTextFieldTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.showMainLanguageSelector), name:.MainLanguageTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.takePhotoButtonTapped), name:.FrontTakePhotoButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.useCameraRollButtonTapped), name:.FrontSelectFromCameraRollButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded), name:.OFFUpdateImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.changeTagsTypeShown), name:.TagListViewTapped, object:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
                delegate?.updated(name: validText, languageCode: currentLanguageCode!)
            }
        case .genericName:
            // generic name updated?
            if let validText = textView.text {
                delegate?.updated(genericName: validText, languageCode: currentLanguageCode!)
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
            case .undefined, .empty:
                return tags.description()
            case .available:
                return tags.tag(at:index) ?? "Tag index out of bounds"
            }
        }
        
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .brands:
            // no language adjustments need to be done
            return title(brandsToDisplay)
        case .packaging:
            return title(packagingToDisplay)
        case .languages:
            return title(languagesToDisplay)
        case .image:
            return searchResult
        default:
            return("TagListView titleForTagAt error")
        }
    }

    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        let currentProductSection = tableStructure[tagListView.tag]
        switch currentProductSection {
        case .brands:
            switch brandsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I clear a tag when there are none")
            case var .available(list):
                list.removeAll()
                delegate?.update(brandTags: list)
            }
        case .packaging:
            switch packagingToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                list.removeAll()
                delegate?.update(packagingTags: list)
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
            case var .available(list):
                list.append(title)
                delegate?.update(brandTags: list)
            }
        case .packaging:
            switch packagingToDisplay {
            case .undefined, .empty:
                delegate?.update(packagingTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(packagingTags: list)
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
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(brandTags: list)
            }
        case .packaging:
            switch packagingToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(packagingTags: list)
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


