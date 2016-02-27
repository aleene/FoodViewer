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
            refresh()
        }
    }

    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private enum SectionType {
        case Categories
    }

    struct Constants {
        static let DefaultHeader = "No Header"
        static let ViewControllerTitle = "Categories"
    }
    
    private struct Storyboard {
        static let CellIdentifier = "Categories Cell Identifier"
    }

    func refresh() {
        if product != nil {
            tableStructureForProduct = analyseProductForTable(product!)
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

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
        static let CategoriesSectionHeader = "Categories"
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
   
    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        title = Constants.ViewControllerTitle
    }


}
