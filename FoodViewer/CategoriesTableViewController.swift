//
//  CategoriesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                refreshProduct()
            }
        }
    }

    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private enum SectionType {
        case Categories
    }

    struct Constants {
        // static let DefaultHeader = "No Header"
        static let ViewControllerTitle = NSLocalizedString("Categories", comment: "Title of ViewController with the categories the product belongs to.")
    }
    
    
    @IBAction func refresh(sender: UIRefreshControl) {
        if refreshControl!.refreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    private struct Storyboard {
        static let CellIdentifier = "Categories Cell Identifier"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableStructureForProduct.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! CategoriesExtendedTableViewCell
        cell.tagList = product!.categories
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }

    struct TableStructure {
        static let CategoriesSectionHeader = NSLocalizedString("Categories", comment: "Header title for table section with product Categories") 
        static let CategoriesSectionSize = 1
    }

    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        // nutritionFacts section
        sectionsAndRows.append((
            SectionType.Categories,
            TableStructure.CategoriesSectionSize,
            TableStructure.CategoriesSectionHeader))
        return sectionsAndRows
    }
   
    // MARK: - Notification handler
        
    func refreshProduct() {
        tableView.reloadData()
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0

        refreshProduct()
        title = Constants.ViewControllerTitle
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name:OFFProducts.Notification.ProductUpdated, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CategoriesTableViewController.removeProduct), name:History.Notification.HistoryHasBeenDeleted, object:nil)

    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
