//
//  ContributorsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 13/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ContributorsTableViewController: UITableViewController {

    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableView.reloadData()
            }
        }
    }

    private struct Constants {
        static let ContributorsCellIdentifier = "Contributor Cell"
        static let DefaultHeader = "Contributors"
        static let ViewControllerTitle = "Contributors"
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        // return product?.contributorsArray.count != nil ? (product?.contributorsArray.count)! : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        if product?.contributorsArray[section] != nil {
            let (_, currentArray) = (product?.contributorsArray[section])!
            return currentArray != nil ? currentArray!.count  : 0
        } else {
            return 0
        }
*/
        return (product?.productContributors.contributors.count)!
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ContributorsCellIdentifier, forIndexPath: indexPath) as? ContributorTableViewCell

        cell?.contributor = product!.productContributors.contributors[indexPath.row]
        
        return cell!
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        /*
        if product?.contributorsArray[section] != nil {
            let (currentKey, _) = (product?.contributorsArray[section])!
            return currentKey
        } else {
            return Constants.DefaultHeader
        }
*/
        return nil
    }
    
    // MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        title = Constants.ViewControllerTitle
    }

}