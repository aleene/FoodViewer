//
//  CompletionStatesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class CompletionStatesTableViewController: UITableViewController {

    
    var product: FoodProduct? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    struct Storyboard {
        static let CompletionStateCellIdentifier = "Completion State Cell"
        static let ContributorsCellIdentifier = "Contributor Cell"
        static let LastEditDateCellIdentifier = "Edit Date Cell"
    }
    
    struct Constants {
        static let ContributorsHeaderTitle = NSLocalizedString("Contributors", comment: "Header title of the tableview section, indicating whether which users did contribute.")
        static let CompletenessHeaderTitle = NSLocalizedString("Completeness", comment: "Header title of the tableview section, indicating whether the productdata is complete.")
        static let LastEditDateHeaderTitle = NSLocalizedString("Last edit Date", comment: "Header title of the tableview section, indicating when the product data was last edited.")
        static let CreationDateHeaderTitle = NSLocalizedString("Creation Date", comment: "Header title of the tableview section, indicating when the product data was created.")
        static let ViewControllerTitle = NSLocalizedString("Community Effort", comment: "Title of view controller, with information on the community that has contributed to the product data.")
        static let NoCreationDateAvailable = NSLocalizedString("no creation date available", comment: "Value of the creation date field, if no valid date is available.")
        static let NoEditDateAvailable = NSLocalizedString("no edit date available", comment: "Value of the edit date field, if no valid date is available.")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return product != nil ? 4 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return product!.type == .beauty ? 9 : 10
        case 1:
            return product?.productContributors.contributors != nil ? product!.productContributors.contributors.count : 0
        case 2:
            return product?.lastEditDates?.count != nil ? product!.lastEditDates!.count : 0
        case 3:
            return product?.additionDate != nil ? 1 : 0
        default:
            return 0
        }
        
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CompletionStateCellIdentifier, for: indexPath) as! StateTableViewCell
            switch (indexPath as NSIndexPath).row {
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
                if currentProductType == .beauty {
                    cell.state = product!.state.photosUploadedComplete.value
                    cell.stateTitle = product!.state.photosUploadedComplete.text
                } else {
                    cell.state = product!.state.nutritionFactsComplete.value
                    cell.stateTitle = product!.state.nutritionFactsComplete.text
                }
                return cell
            case 8:
                if currentProductType == .beauty {
                    cell.state = product!.state.photosValidatedComplete.value
                    cell.stateTitle = product!.state.photosValidatedComplete.text
                } else {
                    cell.state = product!.state.photosUploadedComplete.value
                    cell.stateTitle = product!.state.photosUploadedComplete.text
                }
                return cell
            default:
                cell.state = product!.state.photosValidatedComplete.value
                cell.stateTitle = product!.state.photosValidatedComplete.text
                return cell
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ContributorsCellIdentifier, for: indexPath) as? ContributorTableViewCell
            
            cell?.contributor = product!.productContributors.contributors[(indexPath as NSIndexPath).row]
            return cell!
        } else if (indexPath as NSIndexPath).section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LastEditDateCellIdentifier, for: indexPath)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            // the lastEditDates array contains at least one date, if we arrive here
            
            cell.textLabel!.text = formatter.string(from: product!.lastEditDates![(indexPath as NSIndexPath).row] as Date)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LastEditDateCellIdentifier, for: indexPath)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            if let validDate = product?.additionDate {
                cell.textLabel!.text = formatter.string(from: validDate as Date)
            } else {
                cell.textLabel!.text = Constants.NoCreationDateAvailable
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
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
            return Constants.LastEditDateHeaderTitle
        case 3:
            return Constants.CreationDateHeaderTitle
        default:
            return nil
        }
    }
    
    // MARK: - Notification handler
    
    
    func refreshProduct() {
        tableView.reloadData()
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    // MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false

        title = Constants.ViewControllerTitle
        refreshProduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector:#selector(CompletionStatesTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CompletionStatesTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
