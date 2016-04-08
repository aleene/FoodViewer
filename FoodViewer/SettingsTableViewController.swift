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

    var showSaltOrSodium = NatriumChloride.Both
    
    private struct Storyboard {
        static let ReturnToProductSegueIdentifier = "Settings Done"
    }

    private struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Settings", comment: "TableViewController title for the settings scene.")
    }
    
    @IBOutlet weak var saltOrSodiumOutlet: UISegmentedControl! {
        didSet {
            saltOrSodiumOutlet.setTitle(NSLocalizedString("Salt", comment: "Title of first segment in switch, which lets the user select between salt or sodium"), forSegmentAtIndex: 0)
            saltOrSodiumOutlet.setTitle(NSLocalizedString("Both", comment: "Title of first segment in switch, which lets the user select between salt or sodium"), forSegmentAtIndex: 1)
            saltOrSodiumOutlet.setTitle(NSLocalizedString("Sodium", comment: "Title of first segment in switch, which lets the user select between salt or sodium"), forSegmentAtIndex: 2)
        }
    }
    // MARK: - Action methods
    
    @IBAction func clearProductHistoryTapped(sender: UIButton) {
        storedHistory.removeAll()
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(Storyboard.ReturnToProductSegueIdentifier, sender: self)

    }
    
    @IBAction func saltOrSodiumSwitchTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showSaltOrSodium = .Salt
        case 1:
            showSaltOrSodium = .Both
        case 2:
            showSaltOrSodium = .Sodium
        default:
            break
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
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
