//
//  ProductionTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SupplyChainTableViewController: UITableViewController {
    
    var product: FoodProduct? {
        didSet {
            refresh()
        }
    }
    
    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private enum SectionType {
        case IngredientOrigin
        case Producer
        case ProducerCode
        case Location
        case Store
        case Country
    }
    
    private struct Constants {
        static let DefaultHeader = "No Header"
        static let ViewControllerTitle = "Supply Chain"
    }
    
    private struct Storyboard {
        static let CellIdentifier = "TagListView Cell"
        static let CountriesCellIdentifier = "Countries TagListView Cell"
    }
    
    func refresh() {
        if product != nil {
            tableStructureForProduct = analyseProductForTable(product!)
            tableView.reloadData()
        }        
    }
    
    private struct TableStructure {
        static let ProducerSectionHeader = "Producers"
        static let ProducerCodeSectionHeader = "Producer Codes"
        static let IngredientOriginSectionHeader = "Origin ingredient"
        static let LocationSectionHeader = "Purchase Locations"
        static let CountriesSectionHeader = "Sales Countries"
        static let StoresSectionHeader = "Sale Stores"
        static let ProducerSectionSize = 1
        static let ProducerCodeSectionSize = 1
        static let IngredientOriginSectionSize = 1
        static let LocationSectionSize = 1
        static let CountriesSectionSize = 1
        static let StoresSectionSize = 1

    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // ingredient origin section
        sectionsAndRows.append((
            SectionType.IngredientOrigin,
            TableStructure.IngredientOriginSectionSize,
            TableStructure.IngredientOriginSectionHeader))
        // producer section
        sectionsAndRows.append((
            SectionType.Producer,
            TableStructure.ProducerSectionSize,
            TableStructure.ProducerSectionHeader))
        // producer codes section
        sectionsAndRows.append((
            SectionType.ProducerCode,
            TableStructure.ProducerCodeSectionSize,
            TableStructure.ProducerCodeSectionHeader))
        // countries section
        sectionsAndRows.append((
            SectionType.Country,
            TableStructure.CountriesSectionSize,
            TableStructure.CountriesSectionHeader))
        // purchase Location section
        sectionsAndRows.append((
            SectionType.Location,
            TableStructure.LocationSectionSize,
            TableStructure.LocationSectionHeader))
        // stores section
        sectionsAndRows.append((
            SectionType.Store,
            TableStructure.StoresSectionSize,
            TableStructure.StoresSectionHeader))
        return sectionsAndRows
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
        
        // we assume that product exists
        switch currentProductSection {
        case .Producer:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.producer
            return cell
        case .ProducerCode:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.producerCode
            return cell
        case .IngredientOrigin:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.ingredientsOrigin
            return cell
        case .Store:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.stores
            return cell
        case .Location:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.purchaseLocation
            return cell
        case .Country:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CountriesCellIdentifier, forIndexPath: indexPath) as! CountriesTagListViewTableViewCell
            cell.tagList = product!.countries
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80.0

        refresh()
        title = Constants.ViewControllerTitle
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        tableView.reloadData()
//    }
    
    
}
