//
//  CompletionStatesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CompletionStatesTableViewController: UITableViewController {

    
    var product: FoodProduct? = nil {
        didSet {
            refresh()
        }
    }
    
    func refresh() {
        if product != nil {
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct Storyboard {
        static let CompletionStateCellIdentifier = "Completion State Cell"
        static let ContributorsCellIdentifier = "Contributor Cell"
        static let LastEditDateCellIdentifier = "Edit Date Cell"
        static let ExpirationDateCellIdentifier = "Expiration Date Cell"
    }
    
    struct Constants {
        // static let NameCompletionCellTitle = NSLocalizedString("Productname complete?", comment: "Title of tableview cell, indicateding whether the productname has been completed.")
        // static let BrandsCompletionCellTitle = NSLocalizedString("Brand(s) complete?", comment: "Title of tableview cell, indicateding whether the product brand field has been filled in.")
        // static let QuantityCompletionCellTitle = NSLocalizedString("Quantity complete?", comment: "Title of tableview cell, indicating whether the product quantity field has been filled in.")
        // static let PackagingCompletionCellTitle = NSLocalizedString("Packaging complete?", comment: "Title of tableview cell, indicating whether the product packaging field has been filled in.")
        // static let IngredientsCompletionCellTitle = NSLocalizedString("Ingredients complete?", comment: "Title of tableview cell, indicating whether the product ingredients field have been filled in")
        // static let CategoriesCompletionCellTitle = NSLocalizedString("Categories complete?", comment: "Title of tableview cell, indicating whether the product categories have been filled in.")
        // static let ExpirationDateCompletionCellTitle = NSLocalizedString("Expiration date complete?", comment: "Title of tableview cell, indicating whether the product expiration date has been filled in.")
        // static let NutritionFactsCompletionCellTitle = NSLocalizedString("Nutrition facts complete?", comment: "Title of tableview cell, indicating whether nutritional facts have been filled in.")
        // static let PhotosUploadedCompletionCellTitle = NSLocalizedString("Photos uploaded complete?", comment: "Title of tableview cell, indicating whether prduct photos have been uploaded.")
        // static let PhotosValidatedCompletionCellTitle = NSLocalizedString("Photos validated complete?", comment: "Title of tableview cell, indicating whether the photos have been validated, i.e. photos have been selected for main product, ingredients and nutritional info.")
        static let ContributorsHeaderTitle = NSLocalizedString("Contributors", comment: "Header title of the tableview section, indicating whether which users did contribute.")
        static let CompletenessHeaderTitle = NSLocalizedString("Completeness", comment: "Header title of the tableview section, indicating whether the productdata is complete.")
        static let LastEditDateHeaderTitle = NSLocalizedString("Edit Dates", comment: "Header title of the tableview section, indicating when the product data was edited.")
        static let ExpirationDateHeaderTitle = NSLocalizedString("Expiration Date", comment: "Header title of the tableview section, indicating the most recent expiration date.")
        static let ViewControllerTitle = NSLocalizedString("Community Effort", comment: "Title of view controller, with information on the community that has contributed to the product data.")
        static let NoExpirationDate = NSLocalizedString("No expiration date", comment: "Title of cell when no expiration date is avalable")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return product != nil ? 4 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 10
        case 1:
            return product?.productContributors.contributors != nil ? product!.productContributors.contributors.count : 0
        case 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CompletionStateCellIdentifier, forIndexPath: indexPath) as! StateTableViewCell
            switch indexPath.row {
            case 0:
                cell.state = product!.state.productNameComplete.value
                cell.stateTitle = product!.state.productNameComplete.text
                return cell
            case 1:
                cell.state = product!.state.brandsComplete.value
                cell.stateTitle = product!.state.brandsComplete.text
                return cell
            case 2:
                cell.state = product!.state.quantityComplete.value
                cell.stateTitle = product!.state.quantityComplete.text
                return cell
            case 3:
                cell.state = product!.state.packagingComplete.value
                cell.stateTitle = product!.state.packagingComplete.text
                return cell
            case 4:
                cell.state = product!.state.ingredientsComplete.value
                cell.stateTitle = product!.state.ingredientsComplete.text
                return cell
            case 5:
                cell.state = product!.state.categoriesComplete.value
                cell.stateTitle = product!.state.categoriesComplete.text
                return cell
            case 6:
                cell.state = product!.state.expirationDateComplete.value
                cell.stateTitle = product!.state.expirationDateComplete.text
                return cell
            case 7:
                cell.state = product!.state.nutritionFactsComplete.value
                cell.stateTitle = product!.state.nutritionFactsComplete.text
                return cell
            case 8:
                cell.state = product!.state.photosUploadedComplete.value
                cell.stateTitle = product!.state.photosUploadedComplete.text
                return cell
            default:
                cell.state = product!.state.photosValidatedComplete.value
                cell.stateTitle = product!.state.photosValidatedComplete.text
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ContributorsCellIdentifier, forIndexPath: indexPath) as? ContributorTableViewCell
            
            cell?.contributor = product!.productContributors.contributors[indexPath.row]
            return cell!
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ExpirationDateCellIdentifier, forIndexPath: indexPath)
            if let date = product!.expirationDate {
                let formatter = NSDateFormatter()
                formatter.dateStyle = .MediumStyle
                formatter.timeStyle = .NoStyle
                cell.textLabel!.text = formatter.stringFromDate(date)
            } else {
                cell.textLabel!.text = Constants.NoExpirationDate
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.LastEditDateCellIdentifier, forIndexPath: indexPath)
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .NoStyle
            cell.textLabel!.text = formatter.stringFromDate(product!.lastEditDates![indexPath.row])
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return Constants.CompletenessHeaderTitle
        case 1:
            if section <= product?.contributorsArray.count {
                return product?.contributorsArray[section] != nil ? Constants.ContributorsHeaderTitle : nil
            } else {
                return nil
            }
        case 2:
            return Constants.ExpirationDateHeaderTitle
        case 3:
            return Constants.LastEditDateHeaderTitle
        default:
            return nil
        }
    }
    
    // MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.ViewControllerTitle
        refresh()
    }
}
