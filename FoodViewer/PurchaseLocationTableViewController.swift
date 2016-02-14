//
//  PurchaseLocationTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class PurchaseLocationTableViewController: UITableViewController {

    var product: FoodProduct? {
        didSet {
            refresh()
        }
    }

    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private enum SectionType {
        case Location
        case Store
        case Country
    }

    struct Constants {
        static let DefaultHeader = "No Header"
        static let ViewControllerTitle = "Purchase"
    }
    
    private struct Storyboard {
        static let CellIdentifier = "Purchase Location Cell Identifier"
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
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.section]
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! PurchaseLocationTableViewCell

        // we assume that product exists
        switch currentProductSection {
        case .Store:
            cell.tagList = product!.stores!
            return cell
        case .Location:
            cell.tagList = product!.purchaseLocation!
            return cell
        case .Country:
            cell.tagList = product!.countries!
            return cell
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }

    struct TableStructure {
        static let LocationSectionHeader = "Locations"
        static let CountriesSectionHeader = "Countries"
        static let StoresSectionHeader = "Stores"
    }

    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        // nutritionFacts section
        if product.purchaseLocation != nil {
            sectionsAndRows.append((
                SectionType.Location,
                product.purchaseLocation!.count,
                TableStructure.LocationSectionHeader))
        }
        // stores section
        if product.stores != nil {
            sectionsAndRows.append((
                SectionType.Store,
                product.stores!.count,
                TableStructure.StoresSectionHeader))
        }
        // countries section
        if product.countries != nil {
            sectionsAndRows.append((
                SectionType.Country,
                product.countries!.count,
                TableStructure.CountriesSectionHeader))
        }
        return sectionsAndRows
    }
   
    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        title = Constants.ViewControllerTitle
    }


}
