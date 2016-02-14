//
//  ProductionTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductionTableViewController: UITableViewController {
    
    var product: FoodProduct? {
        didSet {
            refresh()
        }
    }
    
    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private enum SectionType {
        case Producer
        case ProducerCode
        case IngredientOrigin
    }
    
    private struct Constants {
        static let DefaultHeader = "No Header"
        static let ViewControllerTitle = "Production"
    }
    
    private struct Storyboard {
        static let CellIdentifier = "TagListView Cell"
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
        static let IngredientOriginSectionHeader = "Ingredients Origins"
    }
    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // producer section
        if product.producer != nil {
            sectionsAndRows.append((
                SectionType.Producer,
                product.producer!.count,
                TableStructure.ProducerSectionHeader))
        }
        // producer codes section
        if product.producerCode != nil {
            sectionsAndRows.append((
                SectionType.ProducerCode,
                product.producerCode!.count,
                TableStructure.ProducerCodeSectionHeader))
        }
        // ingredient origin section
        if product.ingredientsOrigin != nil {
            sectionsAndRows.append((
                SectionType.IngredientOrigin,
                product.ingredientsOrigin!.count,
                TableStructure.IngredientOriginSectionHeader))
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! TagListViewTableViewCell
        
        // we assume that product exists
        switch currentProductSection {
        case .Producer:
            cell.tagList = product!.producer!
            return cell
        case .ProducerCode:
            cell.tagList = product!.producerCode!
            return cell
        case .IngredientOrigin:
            cell.tagList = product!.ingredientsOrigin!
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
        refresh()
        title = Constants.ViewControllerTitle
    }
    
    
}
