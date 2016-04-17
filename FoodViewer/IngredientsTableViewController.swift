//
//  IngredientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsTableViewController: UITableViewController {

    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private var ingredientsImage: UIImage? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    private enum SectionType {
        case Ingredients
        case Allergens
        case Traces
        case Additives
        case Labels
        case Image
    }
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                ingredientsImage = nil
                tableStructureForProduct = analyseProductForTable(product!)
                /*
                if product!.imageIngredientsUrl != nil {
                    retrieveImage(product!.imageIngredientsUrl!)
                }
                 */
                refreshProduct()
            }
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        if refreshControl!.refreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    private struct Storyboard {
        static let IngredientsCellIdentifier = "Ingredients Full Cell"
        static let AllergensCellIdentifier = "Allergens TagList Cell"
        static let TracesCellIdentifier = "Traces TagList Cell"
        static let AdditivesCellIdentifier = "Additives TagList Cell"
        static let LabelsCellIdentifier = "Labels TagList Cell"
        static let IngredientsImageCellIdentifier = "Ingredients Image Cell"
        static let NoImageCellIdentifier = "No Image Cell"
        static let ShowIdentificationSegueIdentifier = "Show Ingredients Image"
    }
    
    private struct TextConstants {
        static let ShowIdentificationTitle = NSLocalizedString("Image", comment: "Title for the ViewController with the image of the product ingredients.")
        static let ViewControllerTitle = NSLocalizedString("Ingredients", comment: "Title for the ViewController with the product ingredients.")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
        case .Ingredients:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IngredientsCellIdentifier, forIndexPath: indexPath) as? IngredientsFullTableViewCell
            cell?.ingredients = product!.ingredients
            return cell!
        case .Allergens:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.AllergensCellIdentifier, forIndexPath: indexPath) as? AllergensFullTableViewCell
            cell?.tagList = product!.allergens
            return cell!
        case .Traces:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TracesCellIdentifier, forIndexPath: indexPath) as? TracesFullTableViewCell
            cell?.tagList = product!.traces
            return cell!
        case .Additives:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.AdditivesCellIdentifier, forIndexPath: indexPath) as? AdditivesFullTableViewCell
            cell!.tagList = product!.additives
            return cell!
        case .Labels:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.LabelsCellIdentifier, forIndexPath: indexPath) as? LabelsFullTableViewCell
            cell?.tagList = product!.labelArray
            return cell!
        case .Image:
            if let data = product?.getIngredientsImageData() {
                // try large image
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IngredientsImageCellIdentifier, forIndexPath: indexPath) as? IngredientsImageTableViewCell
                cell!.ingredientsImage = UIImage(data:data)
                return cell!
            } else if product?.imageIngredientsUrl != nil {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IngredientsImageCellIdentifier, forIndexPath: indexPath) as? IngredientsImageTableViewCell
                cell!.ingredientsImage = nil
                return cell!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NoImageCellIdentifier, forIndexPath: indexPath) as? NoImageTableViewCell
                
                cell?.tagList = []
                return cell!
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    private struct TableStructure {
        static let IngredientsSectionSize = 1
        static let AllergensSectionSize = 1
        static let TracesSectionSize = 1
        static let AdditivesSectionSize = 1
        static let LabelsSectionSize = 1
        static let ImageSectionSize = 1
        static let IngredientsSectionHeader = NSLocalizedString("Ingredients", comment: "Header title for the product ingredients section.")
        static let AllergensSectionHeader = NSLocalizedString("Allergens", comment: "Header title for the product allergens section, i.e. the allergens derived from the ingredients.")
        static let TracesSectionHeader = NSLocalizedString("Traces", comment: "Header title for the product traces section, i.e. the traces are from products which are worked with in the factory and are indicated separate on the label.")
        static let AdditivesSectionHeader = NSLocalizedString("Additives", comment: "Header title for the product additives section, i.e. the additives are derived from the ingredients list.")
        static let LabelsSectionHeader = NSLocalizedString("Labels", comment: "Header title for the product labels section, i.e. images, logos, etc.")
        static let ImageSectionHeader = NSLocalizedString("Ingredients Image", comment: "Header title for the ingredients image section, i.e. the image of the package with the ingredients")
    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 0: ingredients
        sectionsAndRows.append((SectionType.Ingredients,
            TableStructure.IngredientsSectionSize,
            TableStructure.IngredientsSectionHeader))
        
        // 1:  allergens section
        sectionsAndRows.append((
            SectionType.Allergens,
            TableStructure.AllergensSectionSize,
            TableStructure.AllergensSectionHeader))
        
        // 2: traces section
        sectionsAndRows.append((
            SectionType.Traces,
            TableStructure.TracesSectionSize,
            TableStructure.TracesSectionHeader))
    
        // 3: additives section
        sectionsAndRows.append((
            SectionType.Additives,
            TableStructure.AdditivesSectionSize,
            TableStructure.AdditivesSectionHeader))
        
        // 4: labels section
        sectionsAndRows.append((
            SectionType.Labels,
            TableStructure.LabelsSectionSize,
            TableStructure.LabelsSectionHeader))
        
        
        // 5: image section
        sectionsAndRows.append((
            SectionType.Image,
            TableStructure.ImageSectionSize,
            TableStructure.ImageSectionHeader))
        
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
                            // set the received image data to the current product if valid
                            if self.product?.imageIngredientsUrl == imageURL  {
                                self.product?.ingredientsImageData = imageData
                            } // else bad luck corresponding product is no longer there
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
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowIdentificationSegueIdentifier:
                if let vc = segue.destinationViewController as? imageViewController {
                    vc.image = ingredientsImage
                    vc.imageTitle = TextConstants.ShowIdentificationTitle
                }
            default: break
            }
        }
    }

    // MARK: - Notification handler
    
    func reloadImageSection(notification: NSNotification) {
        
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 5)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func refreshProduct() {
        tableView.reloadData()
    }
    
    func removeProduct() {
        product = nil
        tableView.reloadData()
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
        title = TextConstants.ViewControllerTitle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IngredientsTableViewController.reloadImageSection(_:)), name:FoodProduct.Notification.IngredientsImageSet, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:OFFProducts.Notification.ProductUpdated, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(IngredientsTableViewController.removeProduct), name:History.Notification.HistoryHasBeenDeleted, object:nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if product != nil {
            tableView.reloadData()
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
