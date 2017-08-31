//
//  CompletionStatesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l <= r
//  default:
//    return !(rhs < lhs)
//  }
//}


class CompletionStatesTableViewController: UITableViewController {

    internal struct Notification {
        static let SearchLastEditDateKey = "StateTableViewCell.Notification.SearchLastEditDate.Key"
        static let SearchCreationDateKey = "StateTableViewCell.Notification.SearchCreationDate.Key"
    }

    
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
    
    private struct Storyboard {
        static let CompletionStateCellIdentifier = "Completion State Cell"
        static let ContributorsCellIdentifier = "Contributor Cell"
        static let LastEditDateCellIdentifier = "Edit Date Cell"
    }
    
    private struct Constants {
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

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CompletionStateCellIdentifier, for: indexPath) as! StateTableViewCell
            switch indexPath.row {
            case 0:
                cell.state = product!.state.productNameComplete.value
                cell.stateTitle = product!.state.productNameComplete.text
                cell.searchString = product!.state.productNameComplete.value ?
                    OFF.SearchStatus.productNameCompleted.rawValue :
                    OFF.SearchStatus.productNameNotCompleted.rawValue
                return cell
            case 1:
                cell.state = product!.state.brandsComplete.value
                cell.stateTitle = product!.state.brandsComplete.text
                cell.searchString = product!.state.brandsComplete.value ?
                    OFF.SearchStatus.brandsCompleted.rawValue :
                    OFF.SearchStatus.brandsNotCompleted.rawValue
                return cell
            case 2:
                cell.state = product!.state.quantityComplete.value
                cell.stateTitle = product!.state.quantityComplete.text
                cell.searchString = product!.state.quantityComplete.value ?
                    OFF.SearchStatus.quantityCompleted.rawValue :
                    OFF.SearchStatus.quantityNotCompleted.rawValue
                return cell
            case 3:
                cell.state = product!.state.packagingComplete.value
                cell.stateTitle = product!.state.packagingComplete.text
                cell.searchString = product!.state.packagingComplete.value ?
                    OFF.SearchStatus.packagingCompleted.rawValue :
                    OFF.SearchStatus.packagingNotCompleted.rawValue
                return cell
            case 4:
                cell.state = product!.state.ingredientsComplete.value
                cell.stateTitle = product!.state.ingredientsComplete.text
                cell.searchString = product!.state.ingredientsComplete.value ?
                    OFF.SearchStatus.ingredientsCompleted.rawValue :
                    OFF.SearchStatus.ingredientsNotCompleted.rawValue
                return cell
            case 5:
                cell.state = product!.state.categoriesComplete.value
                cell.stateTitle = product!.state.categoriesComplete.text
                cell.searchString = product!.state.categoriesComplete.value ?
                    OFF.SearchStatus.categoriesCompleted.rawValue :
                    OFF.SearchStatus.categoriesNotCompleted.rawValue
                return cell
            case 6:
                cell.state = product!.state.expirationDateComplete.value
                cell.stateTitle = product!.state.expirationDateComplete.text
                cell.searchString = product!.state.expirationDateComplete.value ?
                    OFF.SearchStatus.expirationDateCompleted.rawValue :
                    OFF.SearchStatus.expirationDateNotCompleted.rawValue
                return cell
            case 7:
                if currentProductType == .beauty {
                    cell.state = product!.state.photosUploadedComplete.value
                    cell.stateTitle = product!.state.photosUploadedComplete.text
                    cell.searchString = product!.state.photosUploadedComplete.value ?
                        OFF.SearchStatus.photosUploadedCompleted.rawValue :
                        OFF.SearchStatus.photosUploadedNotCompleted.rawValue
                } else {
                    cell.state = product!.state.nutritionFactsComplete.value
                    cell.stateTitle = product!.state.nutritionFactsComplete.text
                    cell.searchString = product!.state.nutritionFactsComplete.value ?
                        OFF.SearchStatus.nutritionFactsCompleted.rawValue :
                        OFF.SearchStatus.nutritionFactsNotCompleted.rawValue
                }
                return cell
            case 8:
                if currentProductType == .beauty {
                    cell.state = product!.state.photosValidatedComplete.value
                    cell.stateTitle = product!.state.photosValidatedComplete.text
                    cell.searchString = product!.state.photosValidatedComplete.value ?
                        OFF.SearchStatus.photosValidatedCompleted.rawValue :
                        OFF.SearchStatus.photosValidatedNotCompleted.rawValue
                } else {
                    cell.state = product!.state.photosUploadedComplete.value
                    cell.stateTitle = product!.state.photosUploadedComplete.text
                    cell.searchString = product!.state.photosUploadedComplete.value ?
                        OFF.SearchStatus.photosUploadedCompleted.rawValue :
                        OFF.SearchStatus.photosUploadedNotCompleted.rawValue
                }
                return cell
            default:
                cell.state = product!.state.photosValidatedComplete.value
                cell.stateTitle = product!.state.photosValidatedComplete.text
                return cell
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ContributorsCellIdentifier, for: indexPath) as? ContributorTableViewCell
            
            cell?.contributor = product!.productContributors.contributors[indexPath.row]
            return cell!
        } else if (indexPath as NSIndexPath).section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LastEditDateCellIdentifier, for: indexPath)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            // the lastEditDates array contains at least one date, if we arrive here
            
            cell.textLabel!.text = formatter.string(from: product!.lastEditDates![(indexPath as NSIndexPath).row] as Date)
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.lastEditDateLongPress))
            cell.addGestureRecognizer(longPressGestureRecognizer)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LastEditDateCellIdentifier, for: indexPath)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            if let validDate = product?.additionDate {
                cell.textLabel!.text = formatter.string(from: validDate)
            } else {
                cell.textLabel!.text = Constants.NoCreationDateAvailable
            }
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.creationDateLongPress))
            cell.addGestureRecognizer(longPressGestureRecognizer)

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return Constants.CompletenessHeaderTitle
        case 1:
            guard product?.contributorsArray != nil else { return nil }
            if section < product!.contributorsArray.count {
                return Constants.ContributorsHeaderTitle
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
    
    /*

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                // product name
                if product!.state.productNameComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.productNameCompleted.rawValue, in: .state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.productNameNotCompleted.rawValue, in:.state)
                }
            case 1:
                // brands
                if product!.state.brandsComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.brandsCompleted.rawValue, in:.state) }
                else {
                    askUserToSearch(for: OFF.SearchStatus.brandsNotCompleted.rawValue, in:.state)
                }
            case 2:
                // quantity
                if product!.state.quantityComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.quantityCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.quantityNotCompleted.rawValue, in:.state)
                }
            case 3:
                // packaging
                if product!.state.packagingComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.packagingCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.packagingNotCompleted.rawValue, in:.state)
                }

            case 4:
                // ingredients
                if product!.state.ingredientsComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.ingredientsCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.ingredientsNotCompleted.rawValue, in:.state)
                }

            case 5:
                // categories
                if product!.state.categoriesComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.categoriesCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.categoriesNotCompleted.rawValue, in:.state)
                }

            case 6:
                // expiration date
                if product!.state.expirationDateComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.expirationDateCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.expirationDateNotCompleted.rawValue, in:.state)
                }

            case 7:
                // nutrition facts
                if product!.state.nutritionFactsComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.nutritionFactsCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.nutritionFactsNotCompleted.rawValue, in:.state)
                }

            case 8:
                // photos uploaded
                if product!.state.photosUploadedComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.photosUploadedCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.photosUploadedNotCompleted.rawValue, in:.state)
                }

            default:
                // photos validated
                if product!.state.photosValidatedComplete.value {
                    askUserToSearch(for: OFF.SearchStatus.photosValidatedCompleted.rawValue, in:.state)
                } else {
                    askUserToSearch(for: OFF.SearchStatus.photosValidatedNotCompleted.rawValue, in:.state)
                }

            }
        } else if indexPath.section == 1 {
            askUserToSearch(for: product!.productContributors.contributors[indexPath.row].name, in:.contributor)
        } else if indexPath.section == 2 {
            let formatter = DateFormatter()
            // format should be YYYY-MM-DD
            formatter.dateFormat = "yyyy-MM-dd"
            askUserToSearch(for: formatter.string(from: product!.lastEditDates![indexPath.row] as Date), in:.lastEditDate)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            // is now only creation date
            askUserToSearch(for: formatter.string(from: product!.lastEditDates![indexPath.row] as Date), in:.entryDates)
        }
    }
    
    func askUserToSearch(for string: String, in component: OFF.SearchComponent) {
        let searchMessage = NSLocalizedString("for %@ in %@",
                                              comment: "Explanatory text in AlertViewController, which shows the intended search")
        
        let alertController = UIAlertController(title: NSLocalizedString("Start Search?",
                                                                         comment: "Title in AlertViewController, which lets the user decide if he wants to start a search."),
                                                message: String(format: searchMessage, string, OFF.description(for: component)),
                                                preferredStyle:.alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK",
                                                                   comment: "String in button, to let the user indicate he wants to start the search."),
                                          style: .default)
        { action -> Void in
            self.startSearch(for: string, in: component)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "String in button, to let the user indicate he does NOT want to search."), style: .default)
        { action -> Void in

        }
        
        alertController.addAction(cancel)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func startSearch(for string: String, in component: OFF.SearchComponent) {
        OFFProducts.manager.search(string, in:component)
    }
    */
    
    func creationDateLongPress() {
        // I should encode the search component
        // And the search status
        guard product?.additionDate != nil else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: product!.additionDate! as Date)

        let userInfo = [Notification.SearchCreationDateKey: searchString]
        NotificationCenter.default.post(name: .LongPressInCreationDateCell, object: nil, userInfo: userInfo)
    }

    func lastEditDateLongPress() {
        // I should encode the search component
        // And the search status
        guard product?.lastEditDates?[0] != nil else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: product!.lastEditDates![0] as Date)
        let userInfo = [Notification.SearchLastEditDateKey: searchString]
        NotificationCenter.default.post(name: .LongPressInLastEditDateCell, object: nil, userInfo: userInfo)
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0

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

// Definition:
extension Notification.Name {
    static let LongPressInCreationDateCell = Notification.Name("StateTableViewCell.Notification.LongPressInCreationDateCell")
    static let LongPressInLastEditDateCell = Notification.Name("StateTableViewCell.Notification.LongPressInLastEditDateCell")
}

