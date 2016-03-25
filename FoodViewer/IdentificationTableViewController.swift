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
    
    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    /*
    private var identificationImage: UIImage? = nil {
        didSet {
            tableView.reloadData()
        }
    }
*/
    
    private enum SectionType {
        case Barcode
        case Name
        case CommonName
        case Brands
        case Packaging
        case Quantity
        case Image
    }
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                // identificationImage = nil
                tableStructureForProduct = analyseProductForTable(product!)

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
        return tableStructureForProduct.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.section]
        
        // we assume that product exists
        switch currentProductSection {
        case .Barcode:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = product!.barcode.asString()
            return cell
        case .Name:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = product!.name!
            return cell
        case .CommonName:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = product!.commonName!
            return cell
        case .Brands:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TagListCellIdentifier, forIndexPath: indexPath) as? IdentificationTagListViewTableViewCell
            cell!.tagList = product!.brandsArray
            return cell!
        case .Packaging:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TagListCellIdentifier, forIndexPath: indexPath) as? IdentificationTagListViewTableViewCell
            cell?.tagList = product!.packagingArray
            cell?.layoutIfNeeded()
            return cell!
        case .Quantity:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.BasicCellIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = product!.quantity!
            return cell
        case .Image:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellIdentifier, forIndexPath: indexPath) as? IdentificationImageTableViewCell
            if let data = product?.mainImageData {
                cell!.identificationImage = UIImage(data:data)
            }
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
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

    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 0: barcode section always exists
        sectionsAndRows.append((SectionType.Barcode, TableStructure.BarcodeSectionSize, TableStructure.BarcodeSectionHeader))
        
        // 1:  name section
        if product.name != nil {
            sectionsAndRows.append((
                SectionType.Name,
                TableStructure.NameSectionSize,
                TableStructure.NameSectionHeader))
        }
        
        // 2: common name section
        if product.commonName != nil {
            sectionsAndRows.append((
                SectionType.CommonName,
                TableStructure.CommonNameSectionSize,
                TableStructure.CommonNameSectionHeader))
        }
        
        // 3: brands section
        if product.nutritionScore != nil {
            sectionsAndRows.append((
                SectionType.Brands,
                TableStructure.BrandsSectionSize,
                TableStructure.BrandsSectionHeader))
        }
        
        // 4: packaging section
        if product.categories != nil {
            sectionsAndRows.append((
                SectionType.Packaging,
                TableStructure.PackagingSectionSize,
                TableStructure.PackagingSectionHeader))
        }
        
        // 5: quantity section
        if product.countries != nil {
            sectionsAndRows.append((
                SectionType.Quantity,
                TableStructure.QuantitySectionSize,
                TableStructure.QuantitySectionHeader))
        }
        
        // 6: image section
        if product.mainUrl != nil {
            sectionsAndRows.append((
                SectionType.Image,
                TableStructure.ImageSectionSize,
                TableStructure.ImageSectionHeader))
        }
                
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }
    /*
    private func retrieveImage(url: NSURL?) {
        if let imageURL = url {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image
                            self.identificationImage = UIImage(data: imageData)
                            // print("image bounds \(self.productImageView.image?.size)")
                        })
                    }
                }
                catch {
                    print(error)
                }
            })
        }
    }
    */
    
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
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 6)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadImageSection:", name:FoodProduct.Notification.MainImageSet, object: nil)
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
