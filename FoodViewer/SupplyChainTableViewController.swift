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
            if product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                refreshProduct()
            }
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
        case Map
        case ExpirationDate
    }
    
    private struct Constants {
        // static let DefaultHeader = "No Header"
        static let ViewControllerTitle = NSLocalizedString("Supply Chain", comment: "Title for the view controller with information about the Supply Chain (origin ingredients, producer, shop, locations).")
        static let NoExpirationDate = NSLocalizedString("No expiration date", comment: "Title of cell when no expiration date is avalable")
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        if refreshControl!.refreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    
    private struct Storyboard {
        static let CellIdentifier = "TagListView Cell"
        static let CountriesCellIdentifier = "Countries TagListView Cell"
        static let ExpirationDateCellIdentifier = "Expiration Date Cell"
        static let MapCellIdentifier = "Map Cell"
    }
    

    private struct TableStructure {
        static let ProducerSectionHeader = NSLocalizedString("Producers", comment: "Header for section of tableView with information of the producer (name, geographic location).")
        static let ProducerCodeSectionHeader = NSLocalizedString("Producer Codes", comment: "Header for section of tableView with codes for the producer (EMB 123456 or FR.666.666).")
        static let IngredientOriginSectionHeader = NSLocalizedString("Origin ingredient", comment: "Header for section of tableView with location(s) of ingredients.")
        static let LocationSectionHeader = NSLocalizedString("Purchase Locations", comment: "Header for section of tableView with Locations where the product was bought.")
        static let CountriesSectionHeader = NSLocalizedString("Sales Countries", comment: "Header for section of tableView with Countries where the product is sold.")
        static let StoresSectionHeader = NSLocalizedString("Sale Stores", comment: "Header for section of tableView with names of the stores where the product is sold.")
        static let MapSectionHeader = NSLocalizedString("Map", comment: "Header for section of tableView with a map of producer, origin and shop locations.")
        static let ExpirationDateSectionHeader = NSLocalizedString("Expiration Date", comment: "Header title of the tableview section, indicating the most recent expiration date.")
        static let ProducerSectionSize = 1
        static let ProducerCodeSectionSize = 1
        static let IngredientOriginSectionSize = 1
        static let LocationSectionSize = 1
        static let CountriesSectionSize = 1
        static let StoresSectionSize = 1
        static let MapSectionSize = 1
        static let ExpirationDateSectionSize = 1
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
        // purchase Location section
        sectionsAndRows.append((
            SectionType.Location,
            TableStructure.LocationSectionSize,
            TableStructure.LocationSectionHeader))
        sectionsAndRows.append((
            SectionType.ExpirationDate,
            TableStructure.ExpirationDateSectionSize,
            TableStructure.ExpirationDateSectionHeader))
        // countries section
        sectionsAndRows.append((
            SectionType.Country,
            TableStructure.CountriesSectionSize,
            TableStructure.CountriesSectionHeader))
        // stores section
        sectionsAndRows.append((
            SectionType.Store,
            TableStructure.StoresSectionSize,
            TableStructure.StoresSectionHeader))
        sectionsAndRows.append((
            SectionType.Map,
            TableStructure.MapSectionSize,
            TableStructure.MapSectionHeader))

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
            cell.tagList = product!.producer?.elements
            return cell
        case .ProducerCode:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.producerCode
            return cell
        case .IngredientOrigin:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.ingredientsOrigin?.elements
            return cell
        case .Store:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.stores
            return cell
        case .Location:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
            cell.tagList = product!.purchaseLocation?.elements
            return cell
        case .Country:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CountriesCellIdentifier, forIndexPath: indexPath) as! CountriesTagListViewTableViewCell
            cell.tagList = product!.countries
            return cell
        case .Map:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MapCellIdentifier, forIndexPath: indexPath) as! MapTableViewCell
            cell.product = product!
            return cell
        case .ExpirationDate:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ExpirationDateCellIdentifier, forIndexPath: indexPath)
            if let date = product!.expirationDate {
                let formatter = NSDateFormatter()
                formatter.dateStyle = .MediumStyle
                formatter.timeStyle = .NoStyle
                cell.textLabel!.text = formatter.stringFromDate(date)
            } else {
                cell.textLabel!.text = Constants.NoExpirationDate
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 7:
            return 300
        default:
            return 88
        }
    }
    
    // MARK: - Notification handler
    
    func reloadMapSection(notification: NSNotification) {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 6)], withRowAnimation: UITableViewRowAnimation.Fade)
    }

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
        // self.tableView.estimatedRowHeight = 80.0
        // tableView.translatesAutoresizingMaskIntoConstraints = false;
        // refreshProduct()
        
        title = Constants.ViewControllerTitle
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name:OFFProducts.Notification.ProductUpdated, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SupplyChainTableViewController.removeProduct), name:History.Notification.HistoryHasBeenDeleted, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SupplyChainTableViewController.reloadMapSection), name:Address.Notification.CoordinateHasBeenSet, object:nil)
        
        // refreshProduct()
    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
