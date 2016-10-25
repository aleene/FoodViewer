//
//  IdentificationTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationTableViewController: UITableViewController, UITextFieldDelegate {

    fileprivate struct TextConstants {
        static let ShowIdentificationTitle = NSLocalizedString("Image", comment: "Title for the viewcontroller with an enlarged image")
        static let ViewControllerTitle = NSLocalizedString("Identification", comment: "Title for the view controller with the product image, title, etc.")
        static let NoCommonName = NSLocalizedString("No common name available", comment: "String if no common name is available")
        static let NoName = NSLocalizedString("No name available", comment: "String if no name is available")
        static let NoQuantity = NSLocalizedString("No quantity available", comment: "String if no quantity is available")
    }
    
    fileprivate var tableStructure: [SectionType] = []

    var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            tableView.reloadData()
        }
    }
    
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
                refreshProduct()
            }
        }
    }
    
    var currentLanguageCode: String? = nil
    
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
        static let BasicCellIdentifier = "Identification Basic Cell"
        static let ProductNameCellIdentifier = "Product Name Cell"
        static let BarcodeCellIdentifier = "Barcode Cell"
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
            // does the product have valid multiple languages
            if (product!.languageCodes.count) > 0 && (currentLanguageCode != nil) {
                cell!.name = product!.nameLanguage[currentLanguageCode!]!
                cell!.language = product!.languages[currentLanguageCode!]
                cell!.numberOfLanguages = product!.languageCodes.count
                cell!.editMode = editMode
                cell!.nameTextField.delegate = self
                cell!.nameTextField.tag = 0
            } else {
                cell!.name = nil
                cell!.language = nil
                cell!.numberOfLanguages = 0
            }

            return cell!
        case .genericName:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ProductNameCellIdentifier, for: indexPath) as? ProductNameTableViewCell
            // does the product have valid multiple languages
            if (product!.languageCodes.count) > 0 && (currentLanguageCode != nil) {
                cell!.name = product!.genericNameLanguage[currentLanguageCode!]!
                cell!.language = product!.languages[currentLanguageCode!]
                cell!.numberOfLanguages = product!.languageCodes.count
                cell!.editMode = editMode
                cell!.nameTextField.delegate = self
                cell!.nameTextField.tag = 1
            } else {
                cell!.name = nil
                cell!.language = nil
                cell!.numberOfLanguages = 0
            }
            return cell!

        case .brands:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TagListCellIdentifier, for: indexPath) as? IdentificationTagListViewTableViewCell
            cell!.tagList = product?.brandsArray != nil ? product!.brandsArray! : nil
            return cell!
        case .packaging:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.PackagingCellIdentifier, for: indexPath) as? IdentificationPackagingTagListViewTableViewCell
            cell!.tagList = product?.packagingArray != nil ? product!.packagingArray! : nil
            return cell!
        case .quantity:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BasicCellIdentifier, for: indexPath)
            cell.textLabel?.text = product?.quantity != nil ? product!.quantity! : TextConstants.NoQuantity
            return cell
        case .image:
            if let result = product?.getMainImageData() {
                switch result {
                case .success(let data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ImageCellIdentifier, for: indexPath) as? IdentificationImageTableViewCell
                    cell?.identificationImage = UIImage(data:data)
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoIdentificationImageCellIdentifier, for: indexPath) as? NoIdentificationImageTableViewCell
                    cell?.imageFetchStatus = result
                    return cell!
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoIdentificationImageCellIdentifier, for: indexPath) as? NoIdentificationImageTableViewCell
                cell?.imageFetchStatus = ImageFetchResult.noImageAvailable
                return cell!
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let currentProductSection = tableStructure[(indexPath as NSIndexPath).section]
        
        switch currentProductSection {
        case .name, .genericName:
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
        default:
            break
        }
        return
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
    
    // MARK: - TextField stuff
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            // productname
            if let validText = textField.text {
                product!.name = validText
            }
        case 1:
            // generic name
            if let validText = textField.text {
                product!.genericName = validText
            }
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editMode
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
                    vc.languageCodes = product?.languageCodes
                    vc.primaryLanguageCode = product?.primaryLanguageCode
                    if let validLanguages = product?.languages {
                        vc.languages = validLanguages
                    }
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
        self.tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableViewAutomaticDimension

}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if product != nil {
            refreshProduct()
        }

        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:.MainImageSet, object:nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:.ProductUpdated, object:nil)

        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.loadFirstProduct), name:.FirstProductLoaded, object:nil)

}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // suggested by http://useyourloaf.com/blog/self-sizing-table-view-cells/
        if product != nil {
            refreshProduct()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
