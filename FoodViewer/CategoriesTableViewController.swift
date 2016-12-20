//
//  CategoriesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController, TagListViewDataSource, TagListViewDelegate {

    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                refreshProduct()
            }
        }
    }

    var editMode = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    var delegate: ProductPageViewController? = nil


    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate enum SectionType {
        case categories
    }

    fileprivate struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Categories", comment: "Title of ViewController with the categories the product belongs to.")
    }
    
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    fileprivate struct Storyboard {
        static let CellIdentifier = "Categories Cell Identifier"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructureForProduct.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier, for: indexPath) as! CategoriesExtendedTableViewCell
        // cell.tagList = product!.categories
        cell.tag = 0
        cell.editMode = editMode
        cell.delegate = self
        cell.datasource = self
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }

    struct TableStructure {
        static let CategoriesSectionHeader = NSLocalizedString("Categories", comment: "Header title for table section with product Categories") 
        static let CategoriesSectionSize = 1
    }

    fileprivate func analyseProductForTable(_ product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        // nutritionFacts section
        sectionsAndRows.append((
            SectionType.categories,
            TableStructure.CategoriesSectionSize,
            TableStructure.CategoriesSectionHeader))
        return sectionsAndRows
    }
   
    
    // TagListView Datasource functions
    
    func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        switch tagListView.tag {
        case 0:
            var categories = product!.categories
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.categories {
                case .available:
                    categories = delegate!.updatedProduct!.categories
                default:
                    break
                }
            }
            switch categories {
            case .undefined, .empty:
                return 1
            case let .available(list):
                return list.count
            }
        default: break
        }
        return 0
    }
    
    func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        switch tagListView.tag {
        case 0:
            var categories = product!.categories
            // is an updated product available?
            if delegate?.updatedProduct != nil {
                // does it have brands defined?
                switch delegate!.updatedProduct!.categories {
                case .available:
                    categories = delegate!.updatedProduct!.categories
                default:
                    break
                }
            }
            switch categories {
            case .undefined, .empty:
                tagListView.tagBackgroundColor = .orange
                return categories.description()
            case let .available(list):
                if index >= 0 && index < list.count {
                    return list[index]
                } else {
                    assert(true, "traces array - index out of bounds")
                }
            }
        default: break
        }
        return("error")
    }
    
    // TagListView Delegate functions
    
    func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tagListView.tag {
        case 0:
            var categories = Tags()
            // has it been edited already?
            if delegate?.updatedProduct?.categories == nil {
                // initialise with the existing data
                categories = product!.categories
            } else {
                categories = delegate!.updatedProduct!.categories
            }
            switch categories {
            case .undefined, .empty:
                delegate?.update(categories: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(categories: list)
            }
            tableView.reloadData()
        default:
            break
        }
    }
    
    func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        switch tagListView.tag {
        case 0:
            var categories = Tags()
            // has it been edited already?
            if delegate?.updatedProduct?.categories == nil {
                // initialise with the existing array
                categories = product!.categories
            } else {
                categories = delegate!.updatedProduct!.categories
            }
            switch categories {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(categories: list)
            }
            tableView.reloadData()
        default:
            break
        }
        
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.fade)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.refreshProduct), name: .ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CategoriesTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)

    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
