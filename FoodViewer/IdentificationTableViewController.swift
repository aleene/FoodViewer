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
    }
    
    private var tableStructure: [SectionType] = []
    
    
    private enum SectionType {
        case Barcode(Int, String)
        case Name(Int, String)
        case CommonName(Int, String)
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
            case .CommonName(_, let headerTitle):
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
            case .CommonName(let numberOfRows, _):
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
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableView.reloadData()
            }
        }
    }
    

    // MARK: - Table view data source

    private struct Storyboard {
        static let BasicCellIdentifier = "Identification Basic Cell"
        static let TagListCellIdentifier = "Identification TagList Cell"
        static let PackagingCellIdentifier = "Identification Packaging Cell"
        static let ImageCellIdentifier = "Identification Image Cell"
        static let ShowIdentificationSegueIdentifier = "Show Identification Image"
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
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = product?.barcode.asString()
                return cell
            case .Name:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = product?.name != nil ? product!.name! : nil
                return cell
            case .CommonName:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = product?.commonName != nil ? product!.commonName! : nil
                return cell
            case .Brands:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TagListCellIdentifier, forIndexPath: indexPath) as? IdentificationTagListViewTableViewCell
                cell!.tagList = product?.brandsArray != nil ? product!.brandsArray! : nil
                return cell!
            case .Packaging:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TagListCellIdentifier, forIndexPath: indexPath) as? IdentificationTagListViewTableViewCell
                cell?.tagList = product?.packagingArray != nil ? product!.packagingArray! : nil
                return cell!
            case .Quantity:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
                cell.textLabel?.text = product?.quantity != nil ? product!.quantity! : ""
                return cell
            case .Image:
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as? IdentificationImageTableViewCell
                if let data = product?.mainImageData {
                    cell!.identificationImage = UIImage(data:data)
                } else {
                    cell!.identificationImage = nil
                }
                return cell!
            }
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
        sectionsAndRows.append(.CommonName(TableStructure.CommonNameSectionSize, TableStructure.CommonNameSectionHeader))
        
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
                    if let data = product?.mainImageData {
                        vc.image = UIImage(data:data)
                    }
                    vc.imageTitle = TextConstants.ShowIdentificationTitle
                }
            default: break
            }
        }
    }
    
    // MARK: - Notification handler
    
    func reloadImageSection(notification: NSNotification) {
        let userInfo = notification.userInfo
        let imageURL = userInfo!["imageURL"] as? NSURL
        // only reload the section of image if it is meant for the current product
        if imageURL == product?.mainUrl {
            if product != nil {
                if let index = imageSection(tableStructure) {
                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: index)], withRowAnimation:UITableViewRowAnimation.Fade)
                }
            }
        }
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
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableStructure = setupSections()
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0

        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection(_:)), name:FoodProduct.Notification.MainImageSet, object:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // suggested by http://useyourloaf.com/blog/self-sizing-table-view-cells/
        if product != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }

}
