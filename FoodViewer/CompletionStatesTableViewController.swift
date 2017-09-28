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
    
    public var tableItem: Any? = nil {
        didSet {
            if let item = tableItem as? FoodProduct {
                self.product = item
            } else if let item = tableItem as? SearchTemplate {
                self.query = item
            }
        }
    }

    fileprivate var product: FoodProduct? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    private var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                refreshProduct()
            }
        }
    }

    var delegate: ProductPageViewController? = nil
    
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
            return product!.state.states.count
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
            cell.delegate = delegate
            let completion = product!.state.array[indexPath.row]
            cell.state = completion.value
            cell.stateTitle = completion.description()
            cell.searchString = OFF.searchKey(for: completion)
            return cell
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ContributorsCellIdentifier, for: indexPath) as? ContributorTableViewCell
            cell?.delegate = delegate
            cell?.contributor = product!.productContributors.contributors[indexPath.row]
            return cell!
            
        } else if indexPath.section == 2 {
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
    
    func creationDateLongPress() {
        // I should encode the search component
        // And the search status
        guard product?.additionDate != nil else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: product!.additionDate! as Date)
        delegate?.search(for: searchString, in: .entryDates)
    }

    func lastEditDateLongPress() {
        // I should encode the search component
        // And the search status
        guard product?.lastEditDates?[0] != nil else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: product!.lastEditDates![0] as Date)
        delegate?.search(for: searchString, in: .lastEditDate)
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


