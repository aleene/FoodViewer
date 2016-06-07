//
//  AllergenWarningsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 26/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AllergenWarningsTableViewController: UITableViewController {

    private struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Allergen warnings", comment: "TableViewController title for the allergen warnings setting scene.")
    }
    
    // MARK: - Table view data source
    
    private struct Storyboard {
        static let AllergenWarningCellIdentifier = "Set Allergen Warning Cell"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let aantal = AllergenWarningDefaults.manager.list.count
        return aantal
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.AllergenWarningCellIdentifier, forIndexPath: indexPath) as! SetWarningTableViewCell
        let (allergen, setWarning) = AllergenWarningDefaults.manager.list[indexPath.row]
        cell.state = setWarning
        cell.stateTitle = allergen
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let (allergenName, setWarning) = AllergenWarningDefaults.manager.list[indexPath.row]
        AllergenWarningDefaults.manager.list[indexPath.row] = (allergenName, !setWarning)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = AllergenWarningDefaults.init()
        tableView.reloadData()
        title = Constants.ViewControllerTitle
    }
    
    override func viewDidDisappear(animated: Bool) {
        AllergenWarningDefaults.manager.updateAllergenWarnings()
        super.viewDidDisappear(animated)
    }

}
