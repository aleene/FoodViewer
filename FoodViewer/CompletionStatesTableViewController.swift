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
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return product != nil ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product != nil ? 10 : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CompletionStateCellIdentifier, forIndexPath: indexPath) as! StateTableViewCell

        switch indexPath.row {
        case 0:
            cell.state = product!.state.productNameComplete
            cell.stateTitle = Storyboard.NameCompletionCellTitle
            return cell
        case 1:
            cell.state = product!.state.brandsComplete
            cell.stateTitle = Storyboard.BrandsCompletionCellTitle
            return cell
        case 2:
            cell.state = product!.state.quantityComplete
            cell.stateTitle = Storyboard.QuantityCompletionCellTitle
            return cell
        case 3:
            cell.state = product!.state.packagingComplete
            cell.stateTitle = Storyboard.PackagingCompletionCellTitle
            return cell
        case 4:
            cell.state = product!.state.ingredientsComplete
            cell.stateTitle = Storyboard.IngredientsCompletionCellTitle
            return cell
        case 5:
            cell.state = product!.state.categoriesComplete
            cell.stateTitle = Storyboard.CategoriesCompletionCellTitle
            return cell
        case 6:
            cell.state = product!.state.expirationDateComplete
            cell.stateTitle = Storyboard.ExpirationDateCompletionCellTitle
            return cell
        case 7:
            cell.state = product!.state.nutritionFactsComplete
            cell.stateTitle = Storyboard.NutritionFactsCompletionCellTitle
            return cell
        case 8:
            cell.state = product!.state.photosUploadedComplete
            cell.stateTitle = Storyboard.PhotosUploadedCompletionCellTitle
            return cell
        default:
            cell.state = product!.state.photosValidatedComplete
            cell.stateTitle = Storyboard.PhotosValidatedCompletionCellTitle
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
}
