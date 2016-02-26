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
                tableView.reloadData()
            }
        }
    }
    
    private enum SectionType {
        case NutritionFacts
        case ServingSize
        case NutritionImage
    }
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                nutritionFactsImage = nil
                tableStructureForProduct = analyseProductForTable(product!)
                if product!.nutritionFactsImageUrl != nil {
                    retrieveImage(product!.nutritionFactsImageUrl!)
                }
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    private struct Storyboard {
        static let NutritionFactCellIdentifier = "Nutrition Fact Cell"
        static let ServingSizeCellIdentifier = "Serving Size Cell"
        static let NutritionFactsImageCellIdentifier = "Nutrition Facts Image Cell"
        static let ShowNutritionFactsImageSegueIdentifier = "Show Nutrition Facts Image"
        static let ShowNutritionFactsImageTitle = "Image"
        static let ViewControllerTitle = "Nutrition Facts"
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
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactCellIdentifier, forIndexPath: indexPath) as? NutrientsTableViewCell
            cell?.nutritionFactItem = product!.nutritionFacts[indexPath.row]
            return cell!
        case .ServingSize:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ServingSizeCellIdentifier, forIndexPath: indexPath) as? ServingSizeTableViewCell
            cell?.servingSize = product!.servingSize!
            return cell!
        case .NutritionImage:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactsImageCellIdentifier, forIndexPath: indexPath) as? NutrientsImageTableViewCell
            cell!.nutritionFactsImage = nutritionFactsImage
            // print("image cell size \(cell?.bounds.size)")
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    private struct TableStructure {
        static let NutritionFactsImageSectionSize = 1
        static let ServingSizeSectionSize = 1
        static let NutritionFactItemsSectionHeader = "Nutrition Facts (100g; 100ml)"
        static let NutritionFactsImageSectionHeader = "Nutrition Facts Image"
        static let ServingSizeSectionHeader = "Serving Size"
    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 1 : nutrition facts
        sectionsAndRows.append((
            SectionType.NutritionFacts,
            product.nutritionFacts.count,
            TableStructure.NutritionFactItemsSectionHeader))
        
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
        title = Storyboard.ViewControllerTitle
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
        
    }
    
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

}
