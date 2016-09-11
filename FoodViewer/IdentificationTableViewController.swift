//
//  IdentificationTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationTableViewController: UITableViewController {

    struct TextConstants {
        static let ShowIdentificationTitle = NSLocalizedString("Image", comment: "Title for the viewcontroller with an enlarged image")
        static let ViewControllerTitle = NSLocalizedString("Identification", comment: "Title for the view controller with the product image, title, etc.")
        static let NoCommonName = NSLocalizedString("No common name available", comment: "String if no common name is available")
        static let NoName = NSLocalizedString("No name available", comment: "String if no name is available")
        static let NoQuantity = NSLocalizedString("No quantity available", comment: "String if no quantity is available")
    }
    
    private var tableStructure: [SectionType] = []
    
    
    private enum SectionType {
        case Barcode(Int, String)
        case Name(Int, String)
        case GenericName(Int, String)
        case Brands(Int, String)
        case Packaging(Int, String)
        case Quantity(Int, String)
        case Image(Int, String)
        
        func header() -> String {
            switch self {
            case .Barcode(_, let headerTitle):
                return headerTitle
            case .Name(_, let headerTitle):
                return headerTitle
            case .GenericName(_, let headerTitle):
                return headerTitle
            case .Brands(_, let headerTitle):
                return headerTitle
            case .Packaging(_, let headerTitle):
                return headerTitle
            case .Quantity(_, let headerTitle):
                return headerTitle
            case .Image(_, let headerTitle):
                return headerTitle
            }
        }
        
        func numberOfRows() -> Int {
            switch self {
            case .Barcode(let numberOfRows, _):
                return numberOfRows
            case .Name(let numberOfRows, _):
                return numberOfRows
            case .GenericName(let numberOfRows, _):
                return numberOfRows
            case .Brands(let numberOfRows, _):
                return numberOfRows
            case .Packaging(let numberOfRows, _):
                return numberOfRows
            case .Quantity(let numberOfRows, _):
                return numberOfRows
            case .Image(let numberOfRows, _):
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
    @IBAction func refresh(sender: UIRefreshControl) {
        if refreshControl!.refreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source

    private struct Storyboard {
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // should return all sections (7)
        return product == nil ? 0 : tableStructure.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currentProductSection = tableStructure[indexPath.section]
        
        switch currentProductSection {
        case .Barcode:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BarcodeCellIdentifier, forIndexPath: indexPath)as? BarcodeTableViewCell
            cell!.barcode = product?.barcode.asString()
            return cell!
        case .Name:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ProductNameCellIdentifier, forIndexPath: indexPath) as? ProductNameTableViewCell
            // does the product have valid multiple languages
            if (product!.languageCodes.count) > 0 && (currentLanguageCode != nil) {
                cell!.name = product!.nameLanguage[currentLanguageCode!]!
                cell!.language = product!.languages[currentLanguageCode!]
                cell!.numberOfLanguages = product!.languageCodes.count
            } else {
                cell!.name = nil
                cell!.language = nil
                cell!.numberOfLanguages = 0
            }

            return cell!
        case .GenericName:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ProductNameCellIdentifier, forIndexPath: indexPath) as? ProductNameTableViewCell
            // does the product have valid multiple languages
            if (product!.languageCodes.count) > 0 && (currentLanguageCode != nil) {
                cell!.name = product!.genericNameLanguage[currentLanguageCode!]!
                cell!.language = product!.languages[currentLanguageCode!]
                cell!.numberOfLanguages = product!.languageCodes.count
            } else {
                cell!.name = nil
                cell!.language = nil
                cell!.numberOfLanguages = 0
            }
            return cell!

        case .Brands:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TagListCellIdentifier, forIndexPath: indexPath) as? IdentificationTagListViewTableViewCell
            cell!.tagList = product?.brandsArray != nil ? product!.brandsArray! : nil
            return cell!
        case .Packaging:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.PackagingCellIdentifier, forIndexPath: indexPath) as? IdentificationPackagingTagListViewTableViewCell
            cell!.tagList = product?.packagingArray != nil ? product!.packagingArray! : nil
            return cell!
        case .Quantity:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = product?.quantity != nil ? product!.quantity! : TextConstants.NoQuantity
            return cell
        case .Image:
            if let result = product?.getMainImageData() {
                switch result {
                case .Success(let data):
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as? IdentificationImageTableViewCell
                    cell?.identificationImage = UIImage(data:data)
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NoIdentificationImageCellIdentifier, forIndexPath: indexPath) as? NoIdentificationImageTableViewCell
                    cell?.imageFetchStatus = result
                    return cell!
                }
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NoIdentificationImageCellIdentifier, forIndexPath: indexPath) as? NoIdentificationImageTableViewCell
                cell?.imageFetchStatus = ImageFetchResult.NoImageAvailable
                return cell!
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
        let currentProductSection = tableStructure[indexPath.section]
        
        switch currentProductSection {
        case .Name, .GenericName:
            // set the next language in the array
            if currentLanguageCode != nextLanguageCode() {
                currentLanguageCode = nextLanguageCode()
                // reload the first two rows
                let indexPaths = [NSIndexPath.init(forRow: 0, inSection: 1),
                                  NSIndexPath.init(forRow: 0, inSection: 2)]
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                tableView.deselectRowAtIndexPath(indexPaths.first!, animated: true)
                tableView.deselectRowAtIndexPath(indexPaths.last!, animated: true)
            }
        default:
            break
        }
        return
    }
    
    private func nextLanguageCode() -> String {
        let currentIndex = (product?.languageCodes.indexOf(currentLanguageCode!))!
        
        let nextIndex = currentIndex == ((product?.languageCodes.count)! - 1) ? 0 : currentIndex.successor()
        return (product?.languageCodes[nextIndex])!
    }
        
    private struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStructure[section].header()
    }

    private struct TableStructure {
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

    private func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        
        // All sections are always presented
        // 0: barcode section
        sectionsAndRows.append(.Barcode(TableStructure.BarcodeSectionSize, TableStructure.BarcodeSectionHeader))
        
        // 1:  name section
        sectionsAndRows.append(.Name(TableStructure.NameSectionSize, TableStructure.NameSectionHeader))
        
        // 2: common name section
        sectionsAndRows.append(.GenericName(TableStructure.CommonNameSectionSize, TableStructure.CommonNameSectionHeader))
        
        // 3: brands section
        sectionsAndRows.append(.Brands(TableStructure.BrandsSectionSize, TableStructure.BrandsSectionHeader))
        
        // 4: packaging section
        sectionsAndRows.append(.Packaging(TableStructure.PackagingSectionSize, TableStructure.PackagingSectionHeader))
        
        // 5: quantity section
        sectionsAndRows.append(.Quantity(TableStructure.QuantitySectionSize, TableStructure.QuantitySectionHeader))
        
        // 6: image section
        sectionsAndRows.append(.Image(TableStructure.ImageSectionSize,TableStructure.ImageSectionHeader))
        
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowIdentificationSegueIdentifier:
                if let vc = segue.destinationViewController as? imageViewController {
                    if let result = product?.mainImageData {
                        switch result {
                        case .Success(let data):
                            vc.image = UIImage(data: data)
                            vc.imageTitle = TextConstants.ShowIdentificationTitle
                        default:
                            vc.image = nil
                        }
                    }
                }
            case Storyboard.ShowNamesLanguagesSegueIdentifier:
                if let vc = segue.destinationViewController as? SelectLanguageViewController {
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
    
    private func imageSection(array: [SectionType]) -> Int? {
        for (index, sectionType) in array.enumerate() {
            switch sectionType {
            case .Image:
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
            case .Success(let firstProduct):
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if product != nil {
            refreshProduct()
        }

        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:FoodProduct.Notification.MainImageSet, object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IdentificationTableViewController.refreshProduct), name:OFFProducts.Notification.ProductUpdated, object:nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IdentificationTableViewController.removeProduct), name:History.Notification.HistoryHasBeenDeleted, object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IdentificationTableViewController.loadFirstProduct), name:OFFProducts.Notification.FirstProductLoaded, object:nil)

}
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // suggested by http://useyourloaf.com/blog/self-sizing-table-view-cells/
        if product != nil {
            refreshProduct()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
