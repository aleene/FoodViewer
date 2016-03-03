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
    }
    
    struct Constants {
        static let NameCompletionCellTitle = "Productname complete?"
        static let BrandsCompletionCellTitle = "Brand(s) complete?"
        static let QuantityCompletionCellTitle = "Quantity complete?"
        static let PackagingCompletionCellTitle = "Packaging complete?"
        static let IngredientsCompletionCellTitle = "Ingredients complete?"
        static let CategoriesCompletionCellTitle = "Categories complete?"
        static let ExpirationDateCompletionCellTitle = "Expiration date complete?"
        static let NutritionFactsCompletionCellTitle = "Nutrition facts complete?"
        static let PhotosUploadedCompletionCellTitle = "Photos uploaded complete?"
        static let PhotosValidatedCompletionCellTitle = "Photos validated complete?"
        static let ContributorsHeaderTitle = "Contributors"
        static let CompletenessHeaderTitle = "Completeness"
        static let ViewControllerTitle = "Effort"
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return product != nil ? 2 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return product != nil ? 10 : 0
        case 1:
            return product?.productContributors.contributors != nil ? product!.productContributors.contributors.count : 0
        default:
            return 0
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CompletionStateCellIdentifier, forIndexPath: indexPath) as! StateTableViewCell
            switch indexPath.row {
            case 0:
                cell.state = product!.state.productNameComplete
                cell.stateTitle = Constants.NameCompletionCellTitle
                return cell
            case 1:
                cell.state = product!.state.brandsComplete
                cell.stateTitle = Constants.BrandsCompletionCellTitle
                return cell
            case 2:
                cell.state = product!.state.quantityComplete
                cell.stateTitle = Constants.QuantityCompletionCellTitle
                return cell
            case 3:
                cell.state = product!.state.packagingComplete
            cell.stateTitle = Constants.PackagingCompletionCellTitle
            return cell
            case 4:
                cell.state = product!.state.ingredientsComplete
                cell.stateTitle = Constants.IngredientsCompletionCellTitle
                return cell
            case 5:
                cell.state = product!.state.categoriesComplete
                cell.stateTitle = Constants.CategoriesCompletionCellTitle
                return cell
            case 6:
                cell.state = product!.state.expirationDateComplete
                cell.stateTitle = Constants.ExpirationDateCompletionCellTitle
                return cell
            case 7:
                cell.state = product!.state.nutritionFactsComplete
                cell.stateTitle = Constants.NutritionFactsCompletionCellTitle
                return cell
            case 8:
                cell.state = product!.state.photosUploadedComplete
                cell.stateTitle = Constants.PhotosUploadedCompletionCellTitle
                return cell
            default:
                cell.state = product!.state.photosValidatedComplete
                cell.stateTitle = Constants.PhotosValidatedCompletionCellTitle
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ContributorsCellIdentifier, forIndexPath: indexPath) as? ContributorTableViewCell
                
            cell?.contributor = product!.productContributors.contributors[indexPath.row]
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return Constants.CompletenessHeaderTitle
        case 1:
            return product?.contributorsArray[section] != nil ? Constants.ContributorsHeaderTitle : nil
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
