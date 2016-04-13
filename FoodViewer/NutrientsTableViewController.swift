//
//  NutrientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsTableViewController: UITableViewController {

    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private var nutritionFactsImage: UIImage? = nil {
        didSet {
            if nutritionFactsImage != nil {
                refreshProduct()
            }
        }
    }
    
    private enum SectionType {
        case NutritionFacts
        case ServingSize
        case NutritionImage
    }
    
    private var adaptedNutritionFacts: [NutritionFactItem] = []
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                nutritionFactsImage = nil
                tableStructureForProduct = analyseProductForTable(product!)
                /*
                if product!.nutritionFactsImageUrl != nil {
                    retrieveImage(product!.nutritionFactsImageUrl!)
                }
 */
                tableView.reloadData()
            }
        }
    }
    
    func adaptNutritionFacts(facts: [NutritionFactItem]) -> [NutritionFactItem] {
        var newFacts: [NutritionFactItem] = []
        for fact in facts {
            if (fact.itemName == NatriumChloride.Salt.description()) {
                switch Preferences.manager.showSaltSodiumOrBoth {
                    // do not show sodium
                case .Sodium: break
                default: newFacts.append(fact)
                }
            } else if (fact.itemName == NatriumChloride.Sodium.description()) {
                switch Preferences.manager.showSaltSodiumOrBoth {
                    // do not show salt
                case .Salt: break
                default: newFacts.append(fact)
                }
            } else {
                newFacts.append(fact)
            }
        }
        return newFacts
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        if refreshControl!.refreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    private struct Storyboard {
        static let NutritionFactCellIdentifier = "Nutrition Fact Cell"
        static let ServingSizeCellIdentifier = "Serving Size Cell"
        static let NutritionFactsImageCellIdentifier = "Nutrition Facts Image Cell"
        static let EmptyNutritionFactsImageCellIdentifier = "Empty Nutrition Facts Image Cell"
        static let ShowNutritionFactsImageSegueIdentifier = "Show Nutrition Facts Image"
        static let ShowNutritionFactsImageTitle = NSLocalizedString("Image", comment: "Title of the ViewController with package image of the nutritional values")
        static let ViewControllerTitle = NSLocalizedString("Nutrition Facts", comment: "Title of the ViewController with the nutritional values")
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
        case .NutritionFacts:
            if adaptedNutritionFacts.isEmpty {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.EmptyNutritionFactsImageCellIdentifier, forIndexPath: indexPath) as? EmptyNutrientsTableViewCell

                cell?.tagList = []
                return cell!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactCellIdentifier, forIndexPath: indexPath) as? NutrientsTableViewCell
                // warning set FIRST the saltOrSodium
                cell?.nutritionFactItem = adaptedNutritionFacts[indexPath.row]
                return cell!
            }
        case .ServingSize:
            if product!.servingSize == nil {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.EmptyNutritionFactsImageCellIdentifier, forIndexPath: indexPath) as? EmptyNutrientsTableViewCell
                
                cell?.tagList = []
                return cell!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ServingSizeCellIdentifier, forIndexPath: indexPath) as? ServingSizeTableViewCell
                cell?.servingSize = product!.servingSize!
                return cell!
            }

        case .NutritionImage:
            if let data = product?.nutritionImageData {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactsImageCellIdentifier, forIndexPath: indexPath) as? NutrientsImageTableViewCell
                cell!.nutritionFactsImage = UIImage(data: data)
                return cell!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.EmptyNutritionFactsImageCellIdentifier, forIndexPath: indexPath) as? EmptyNutrientsTableViewCell
                
                cell!.tagList = []
                return cell!
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    private struct TableStructure {
        static let NutritionFactsImageSectionSize = 1
        static let ServingSizeSectionSize = 1
        static let NutritionFactsEmpytSectionSize = 1
        static let NutritionFactItemsSectionHeader = NSLocalizedString("Nutrition Facts (100g; 100ml)", comment: "Tableview header section for the list of nutritional facts")
        static let NutritionFactsImageSectionHeader = NSLocalizedString("Nutrition Facts Image", comment: "Tableview header section for the image of the nutritional facts")
        static let ServingSizeSectionHeader = NSLocalizedString("Serving Size", comment: "Tableview header for the section with the serving size, i.e. the amount one will usually take of the product.") 
    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        adaptedNutritionFacts = adaptNutritionFacts(product.nutritionFacts)

        // 1 : nutrition facts
        if product.nutritionFacts.isEmpty {
            sectionsAndRows.append((
                SectionType.NutritionFacts,
                TableStructure.NutritionFactsEmpytSectionSize,
                TableStructure.NutritionFactItemsSectionHeader))
        } else {
            sectionsAndRows.append((
                SectionType.NutritionFacts,
                adaptedNutritionFacts.count,
                TableStructure.NutritionFactItemsSectionHeader))
        }
    
        // 2:  serving size
        sectionsAndRows.append((
            SectionType.ServingSize,
            TableStructure.ServingSizeSectionSize,
            TableStructure.ServingSizeSectionHeader))
        
        // 3: image section
            sectionsAndRows.append((
                SectionType.NutritionImage,
                TableStructure.NutritionFactsImageSectionSize,
                TableStructure.NutritionFactsImageSectionHeader))
        
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
                            self.nutritionFactsImage = UIImage(data: imageData)
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
            case Storyboard.ShowNutritionFactsImageSegueIdentifier:
                if let vc = segue.destinationViewController as? imageViewController {
                    vc.image = nutritionFactsImage
                    vc.imageTitle = Storyboard.ShowNutritionFactsImageTitle
                }
            default: break
            }
        }
    }
    
    // MARK: - Notification handler
    
    func refreshProduct() {
        if product != nil {
            tableView.reloadData()
        }
    }
    
    func refreshProductWithNewNutritionFacts() {
        // recalculate the nutritionfacts that must be shown
        if product != nil {
            tableStructureForProduct = analyseProductForTable(product!)
            tableView.reloadData()
        }
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
        title = Storyboard.ViewControllerTitle
        
        refreshProductWithNewNutritionFacts()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:#selector(NutrientsTableViewController.refreshProduct),
            name:OFFProducts.Notification.ProductUpdated,
            object:nil
        )
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(NutrientsTableViewController.removeProduct), name:History.Notification.HistoryHasBeenDeleted, object:nil)
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

}
