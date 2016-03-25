//
//  SettingsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var storedHistory = History()

    private struct Storyboard {
        static let ReturnToProductSegueIdentifier = "Settings Done"
    }

    private struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Settings", comment: "TableViewController title for the settings scene.")
    }
    
    // MARK: - Action methods
    
    @IBAction func clearProductHistoryTapped(sender: UIButton) {
        storedHistory.removeAll()
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(Storyboard.ReturnToProductSegueIdentifier, sender: self)

    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */



    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.ViewControllerTitle
    }

    
}
