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
            tableView.reloadData()
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
                if product!.mainUrl != nil {
                    retrieveImage(product!.imageIngredientsUrl!)
                }
                tableView.reloadData()
            }
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
        static let ShowIdentificationSegueIdentifier = "Show Ingredients Image"
    }
    
    private struct TextConstants {
        static let ShowIdentificationTitle = "Image"
        static let ViewControllerTitle = "Ingredients"
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
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.IngredientsImageCellIdentifier, forIndexPath: indexPath) as? IngredientsImageTableViewCell
            cell!.ingredientsImage = ingredientsImage
            return cell!
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
        static let IngredientsSectionHeader = "Ingredients"
        static let AllergensSectionHeader = "Allergens"
        static let TracesSectionHeader = "Traces"
        static let AdditivesSectionHeader = "Additives"
        static let LabelsSectionHeader = "Labels"
        static let ImageSectionHeader = "Ingredients Image"
    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 1: ingredients
        sectionsAndRows.append((SectionType.Ingredients,
            TableStructure.IngredientsSectionSize,
            TableStructure.IngredientsSectionHeader))
        
        // 2:  allergens section
        sectionsAndRows.append((
            SectionType.Allergens,
            TableStructure.AllergensSectionSize,
            TableStructure.AllergensSectionHeader))
        
        // 3: traces section
        sectionsAndRows.append((
            SectionType.Traces,
            TableStructure.TracesSectionSize,
            TableStructure.TracesSectionHeader))
    
        // 4: additives section
        sectionsAndRows.append((
            SectionType.Additives,
            TableStructure.AdditivesSectionSize,
            TableStructure.AdditivesSectionHeader))
        
        // 5: labels section
        sectionsAndRows.append((
            SectionType.Labels,
            TableStructure.LabelsSectionSize,
            TableStructure.LabelsSectionHeader))
        
        
        // 6: image section
        sectionsAndRows.append((
            SectionType.Image,
            TableStructure.ImageSectionSize,
            TableStructure.ImageSectionHeader))
        
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
                            self.ingredientsImage = UIImage(data: imageData)
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
        
    }
    
    

}
