//
//  IdentificationTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationTableViewController: UITableViewController {

    
    fileprivate struct TextConstants {
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
    
    // MARK: - public variables
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableView.reloadData()
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
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.brands {
                case .available, .empty:
                    return delegate!.updatedProduct!.brands
                default:
                    break
                }
            }
            return product!.brands
        }
    }
    
    fileprivate var packagingToDisplay: Tags {
        get {
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.packagingArray {
                case .available, .empty:
                    return delegate!.updatedProduct!.packagingArray
                default:
                    break
                }
            }
            return product!.packagingArray
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
        static let TextFieldCellIdentifier = "Identification Basic Cell"
        static let ProductNameCellIdentifier = "Product Name Cell"
        static let BarcodeCellIdentifier = "Barcode Cell"
        static let QuantityCellIdentifier = "Quantity Cell"
        static let TagListCellIdentifier = "Identification TagList Cell"
        static let PackagingCellIdentifier = "Identification Packaging Cell"
        static let ImageCellIdentifier = "Identification Image Cell"
        static let NoIdentificationImageCellIdentifier = "No Image Cell"
        static let ShowIdentificationSegueIdentifier = "Show Identification Image"
        static let ShowNamesLanguagesSegueIdentifier = "Show Names Languages"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections (7)
        return product == nil ? 0 : tableStructure.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[(indexPath as NSIndexPath).section]
        
        switch currentProductSection {
        case .barcode:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BarcodeCellIdentifier, for: indexPath)as? BarcodeTableViewCell
            cell!.barcode = product?.barcode.asString()
            return cell!
            
        case .name:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ProductNameCellIdentifier, for: indexPath) as? ProductNameTableViewCell
            cell!.numberOfLanguages = product!.languageCodes.count
            cell!.delegate = self
            cell!.tag = 0
            cell!.editMode = currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if let validCurrentLanguageCode = currentLanguageCode {
                cell!.languageCode = validCurrentLanguageCode
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ProductNameCellIdentifier, for: indexPath) as? ProductNameTableViewCell
            cell!.numberOfLanguages = product!.languageCodes.count
            cell!.delegate = self
            cell!.tag = 1
            cell!.editMode = currentLanguageCode == product!.primaryLanguageCode ? editMode : false
            if let validCurrentLanguageCode = currentLanguageCode {
                cell!.languageCode = validCurrentLanguageCode
                if let validName = delegate?.updatedProduct?.genericNameLanguage[validCurrentLanguageCode] {
                    cell!.name = validName
                } else if let validName = product!.genericNameLanguage[validCurrentLanguageCode] {
                        cell!.name = validName
                } else {
                    cell!.name = nil
                }
            }
            return cell!

        case .brands:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TagListCellIdentifier, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = 0
            return cell
            
        case .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.PackagingCellIdentifier, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = 1
            return cell
            
        case .quantity:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.QuantityCellIdentifier, for: indexPath) as! QuantityTableViewCell
            if let validQuantity = delegate?.updatedProduct?.quantity {
                cell.tekst = validQuantity
            } else if let validQuantity = product?.quantity {
                cell.tekst = validQuantity
            } else {
                cell.tekst = nil
            }
            cell.editMode = editMode
            cell.delegate = self
            cell.tag = 2
            return cell
            
        case .image:
            if let result = product?.getMainImageData() {
                switch result {
                case .success(let data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ImageCellIdentifier, for: indexPath) as? IdentificationImageTableViewCell
                    cell?.identificationImage = UIImage(data:data)
                    return cell!
                default:
                    searchResult = result.description()
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoIdentificationImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell //
                    cell?.tag = 3
                    cell?.width = tableView.frame.size.width
                    cell?.datasource = self
                    cell?.scheme = ColorSchemes.error
                    return cell!
                }
            } else {
                searchResult = ImageFetchResult.noImageAvailable.description()
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoIdentificationImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell //
                cell?.tag = 4
                cell?.width = tableView.frame.size.width
                cell?.datasource = self
                cell?.scheme = ColorSchemes.error
                return cell!
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let currentProductSection = tableStructure[(indexPath as NSIndexPath).section]
        
        switch currentProductSection {
        case .name, .genericName:
            changeLanguage()
        default:
            break
        }
        return
    }
    
    func changeLanguage() {
        // set the next language in the array
        if currentLanguageCode != nextLanguageCode() {
            currentLanguageCode = nextLanguageCode()
            // reload the first two rows
            let indexPaths = [IndexPath.init(row: 0, section: 1),
                              IndexPath.init(row: 0, section: 2)]
            tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.fade)
            tableView.deselectRow(at: indexPaths.first!, animated: true)
            tableView.deselectRow(at: indexPaths.last!, animated: true)
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
        return tableStructure[section].header()
    }

    fileprivate struct TableStructure {
        static let BarcodeSectionSize = 1
        static let NameSectionSize = 1
        static let CommonNameSectionSize = 1
        static let BrandsSectionSize = 1
        static let PackagingSectionSize = 1
        static let QuantitySectionSize = 1
        static let ImageSectionSize = 1
        static let BarcodeSectionHeader = NSLocalizedString("Barcode", comment: "Tableview sectionheader for Barcode")
        static let NameSectionHeader = NSLocalizedString("Name", comment: "Tableview sectionheader for product name")
        static let CommonNameSectionHeader = NSLocalizedString("Common Name", comment: "Tableview sectionheader for long product name")
        static let BrandsSectionHeader = NSLocalizedString("Brands", comment: "Tableview sectionheader for brands.")
        static let PackagingSectionHeader = NSLocalizedString("Packaging", comment: "Tableview sectionheader for packaging.")
        static let QuantitySectionHeader = NSLocalizedString("Quantity", comment: "Tableview sectionheader for size of package.")
        static let ImageSectionHeader = NSLocalizedString("Main Image", comment: "Tableview sectionheader for main image of package.")
    }

    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        
        // All sections are always presented
        // 0: barcode section
        sectionsAndRows.append(.barcode(TableStructure.BarcodeSectionSize, TableStructure.BarcodeSectionHeader))
        
        // 1:  name section
        sectionsAndRows.append(.name(TableStructure.NameSectionSize, TableStructure.NameSectionHeader))
        
        // 2: common name section
        sectionsAndRows.append(.genericName(TableStructure.CommonNameSectionSize, TableStructure.CommonNameSectionHeader))
        
        // 3: brands section
        sectionsAndRows.append(.brands(TableStructure.BrandsSectionSize, TableStructure.BrandsSectionHeader))
        
        // 4: packaging section
        sectionsAndRows.append(.packaging(TableStructure.PackagingSectionSize, TableStructure.PackagingSectionHeader))
        
        // 5: quantity section
        sectionsAndRows.append(.quantity(TableStructure.QuantitySectionSize, TableStructure.QuantitySectionHeader))
        
        // 6: image section
        sectionsAndRows.append(.image(TableStructure.ImageSectionSize,TableStructure.ImageSectionHeader))
        
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }

    // MARK: - Segue stuff

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowIdentificationSegueIdentifier:
                if let vc = segue.destination as? imageViewController {
                    if let result = product?.mainImageData {
                        switch result {
                        case .success(let data):
                            vc.image = UIImage(data: data)
                            vc.imageTitle = TextConstants.ShowIdentificationTitle
                        default:
                            vc.image = nil
                        }
                    }
                }
            case Storyboard.ShowNamesLanguagesSegueIdentifier:
                if let vc = segue.destination as? SelectLanguageViewController {
                    vc.currentLanguageCode = currentLanguageCode
                    if let updatedPrimaryLanguageCode = delegate?.updatedProduct?.primaryLanguageCode {
                        vc.primaryLanguageCode = updatedPrimaryLanguageCode
                    } else {
                        vc.primaryLanguageCode = product?.primaryLanguageCode
                    }
                    vc.languageCodes = product!.languageCodes
                    vc.updatedLanguageCodes = delegate?.updatedProduct != nil ? delegate!.updatedProduct!.languageCodes : []
                    vc.editMode = editMode
                    vc.delegate = delegate
                    vc.sourcePage = 0
                }
            default: break
            }
        }
    }
    
    // MARK: - Notification handler
    
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
        tableView.reloadData()
    }
    
    func loadFirstProduct() {
        let products = OFFProducts.manager
        if let validProductFetchResult = products.fetchResultList[0] {
            switch validProductFetchResult {
            case .success(let firstProduct):
                product = firstProduct
                tableView.reloadData()
            default: break
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
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:.MainImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.changeLanguage), name:.NameTextFieldTapped, object:nil)
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
        switch textView.tag {
        case 0:
            // productname
            if let validText = textView.text {
                delegate?.updated(name: validText, languageCode: currentLanguageCode!)
            }
        case 1:
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
        
        switch tagListView.tag {
        case 0:
            return count(brandsToDisplay)
        case 1:
            return count(packagingToDisplay)
        case 3:
            return 1
        case 4:
            return 1
        default:
            break
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        // print("height", tagListView.frame.size.height)
        func title(_ tags: Tags) -> String {
            switch tags {
            case .undefined, .empty:
                return tags.description()
            case let .available(list):
                if index >= 0 && index < list.count {
                    let tagParts = list[index].characters.split{ $0 == ":" }.map(String.init)
                    if tagParts.isEmpty {
                        // I guess this should not happen
                        return "No tags"
                    } else if tagParts.count == 1 {
                        // Can this happen?
                        return tagParts[0]
                    }
                    let preferredLanguage = Locale.preferredLanguages[0]
                    let currentLanguage = preferredLanguage.characters.split{ $0 == "-" }.map(String.init)
                    if tagParts[0] == currentLanguage[0] {
                        // strip the language part
                        return tagParts[1]
                    }
                    // just use the entire string
                    return list[index]
                } else {
                    assert(true, "Tags array - index out of bounds")
                }
            }
            return "Tags array - index out of bounds"
        }
        
        switch tagListView.tag {
        case 0:
            return title(brandsToDisplay)
        case 1:
            return title(packagingToDisplay)
        case 3,4:
            return searchResult
        default: break
        }
        return("error")
    }

    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        switch tagListView.tag {
        case 0:
            switch brandsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I clear a tag when there are none")
            case var .available(list):
                list.removeAll()
                delegate?.update(brandTags: list)
            }
        case 1:
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
        tableView.reloadData()
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }

}

// MARK: - TagListView Delegate Functions

extension IdentificationTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tagListView.tag {
        case 0:
            switch brandsToDisplay {
            case .undefined, .empty:
                delegate?.update(brandTags: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(brandTags: list)
            }
        case 1:
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
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        switch tagListView.tag {
        case 0:
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
            tableView.reloadData()
        case 1:
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
            tableView.reloadData()
        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.setNeedsLayout()
    }
    
}

// MARK: - UITextField Delegate Functions

extension IdentificationTableViewController: UITextFieldDelegate {

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 2:
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
        switch textField.tag {
        case 2:
            return editMode
        default:
            return currentLanguageCode == product!.primaryLanguageCode ? editMode : false
        }
    }
    
}
