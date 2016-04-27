//
//  SettingsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    private struct Storyboard {
        static let ReturnToProductSegueIdentifier = "Settings Done"
    }
    
    private struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Settings", comment: "TableViewController title for the settings scene.")
    }

    var storedHistory = History() {
        didSet {
            enableClearHistoryButton()
        }
    }

    var mostRecentProduct = MostRecentProduct()

    private func enableClearHistoryButton() {
        if clearHistoryButton != nil {
            if storedHistory.barcodes.isEmpty {
                clearHistoryButton.enabled = false
            } else {
                clearHistoryButton.enabled = true
            }
        }
    }
    
    var historyHasBeenRemoved = false
    
    func refreshSaltOrSodiumSwitch() {
        if saltOrSodiumOutlet != nil {
            switch Preferences.manager.showSaltOrSodium {
            case .Salt:
                saltOrSodiumOutlet!.selectedSegmentIndex = 0
            case .Sodium:
                saltOrSodiumOutlet!.selectedSegmentIndex = 1
            }
        }

    }
    
    func refreshJouleOrCaloriesSwitch() {
        if jouleOrCaloriesOutlet != nil {
            switch Preferences.manager.showCaloriesOrJoule {
            case .Joule:
                jouleOrCaloriesOutlet!.selectedSegmentIndex = 0
            case .Calories:
                jouleOrCaloriesOutlet!.selectedSegmentIndex = 1
            }
        }
        
    }

    
    // MARK: - Outlet methods

    @IBOutlet weak var clearHistoryButton: UIButton! {
        didSet {
            enableClearHistoryButton()
        }
    }
    
    @IBOutlet weak var saltOrSodiumOutlet: UISegmentedControl! {
        didSet {
            saltOrSodiumOutlet.setTitle(NSLocalizedString("Salt", comment: "Title of first segment in switch, which lets the user select between salt or sodium"), forSegmentAtIndex: 0)
            saltOrSodiumOutlet.setTitle(NSLocalizedString("Sodium", comment: "Title of third segment in switch, which lets the user select between salt or sodium"), forSegmentAtIndex: 1)
        }
    }
    
    @IBOutlet weak var jouleOrCaloriesOutlet: UISegmentedControl! {
        didSet {
            jouleOrCaloriesOutlet.setTitle(NSLocalizedString("Joule", comment: "Title of first segment in switch, which lets the user select between joule or calories"), forSegmentAtIndex: 0)
            jouleOrCaloriesOutlet.setTitle(NSLocalizedString("Calories", comment: "Title of second segment in switch, which lets the user select between joule or calories"), forSegmentAtIndex: 1)
        }
    }
    
    // MARK: - Action methods
    
    @IBAction func jouleOrCaloriesSwitchTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showCaloriesOrJoule = .Joule
        case 1:
            Preferences.manager.showCaloriesOrJoule = .Calories
        default:
            break
        }
    }

    @IBAction func clearProductHistoryTapped(sender: UIButton) {
        storedHistory.removeAll()
        mostRecentProduct.remove()
        historyHasBeenRemoved = true
        enableClearHistoryButton()
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(Storyboard.ReturnToProductSegueIdentifier, sender: self)

    }
    
    @IBAction func saltOrSodiumSwitchTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showSaltOrSodium = .Salt
        case 1:
            Preferences.manager.showSaltOrSodium = .Sodium
        default:
            break
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 2
        default:
            return 1
        }
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
        
        refreshSaltOrSodiumSwitch()
        refreshJouleOrCaloriesSwitch()

        title = Constants.ViewControllerTitle
    }

    
}
