//
//  ProductionTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SupplyChainTableViewController: UITableViewController {
    
// MARK: - Public Functions/Variables
    
    var editMode = false {
        didSet {
            if editMode != oldValue {
                // vc changed from/to editMode, need to repaint
                tableView.reloadData()
            }
        }
    }
    
    var delegate: ProductPageViewController? = nil

    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                refreshProduct()
            }
        }
    }
    
// MARK: Private Functions/Variables
    
    fileprivate var producerTagsToDisplay: [String]? {
        get {
            if let validTags = delegate?.updatedProduct?.producer?.rawArray {
                return validTags
            } else if let validTags = product?.producer?.rawArray {
                return validTags
            }
            return nil
        }
    }
    
    fileprivate var producerCodeTagsToDisplay: [String]? {
        get {
            if let tags = delegate?.updatedProduct?.producerCodeArray {
                return tags
            } else if let validAddresses = product?.producerCode {
                var tags: [String] = []
                for address in validAddresses {
                    tags.append(address.raw)
                }
                return tags
            }
            return nil
        }
    }
    
    fileprivate var ingredientOriginLocationTagsToDisplay: [String]? {
        get {
            if let validTags = delegate?.updatedProduct?.ingredientsOrigin?.rawArray {
                return validTags
            } else if let validTags = product?.ingredientsOrigin?.rawArray {
                return validTags
            }
            return nil
        }
    }
    
    fileprivate var purchaseLocationTagsToDisplay: [String]? {
        get {
            if let validTags = delegate?.updatedProduct?.purchaseLocation?.rawArray {
                return validTags
            } else if let validTags = product?.purchaseLocation?.rawArray {
                return validTags
            }
            return nil
        }
    }
    
    fileprivate var storeTagsToDisplay: [String]? {
        get {
            if let validTags = delegate?.updatedProduct?.stores {
                return validTags
            } else if let validTags = product?.stores {
                return validTags
            }
            return nil
        }
    }
    
    fileprivate var countriesToDisplay: [String]? {
        get {
            if let validAddresses = delegate?.updatedProduct?.countries {
                var tags: [String] = []
                for address in validAddresses {
                    tags += address.elements
                }
                return tags
            } else if let validAddresses = product?.countries {
                var tags: [String] = []
                for address in validAddresses {
                    tags += address.elements
                }
                return tags
            }
            return nil
        }
    }

    fileprivate var linksToDisplay: [String]? {
        get {
            if let validTags = delegate?.updatedProduct?.links {
                return validTags.map( { $0.absoluteString } )
            } else if let validTags = product?.links {
                return validTags.map( { $0.absoluteString } )
            }
            return nil
        }
    }
    
    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate enum SectionType {
        case ingredientOrigin
        case producer
        case producerCode
        case location
        case store
        case country
        case map
        case expirationDate
        case sites
    }
    
    fileprivate struct Constants {
        // static let DefaultHeader = "No Header"
        static let ViewControllerTitle = NSLocalizedString("Supply Chain", comment: "Title for the view controller with information about the Supply Chain (origin ingredients, producer, shop, locations).")
        static let NoExpirationDate = NSLocalizedString("No expiration date", comment: "Title of cell when no expiration date is avalable")
    }

    // MARK: - Interface Functions
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    fileprivate struct Storyboard {
        static let IngredientOriginCellIdentifier = "Ingredients Origin TagListView Cell"
        static let ProducerTagListViewCell = "Producer TagListView Cell"
        static let CountriesCellIdentifier = "Countries TagListView Cell"
        static let ProducerCodeCellIdentifier = "ProducerCodes TagListView Cell"
        static let ExpirationDateCellIdentifier = "Expiration Date Cell"
        static let SitesCellIdentifier = "Sites TagListView Cell"
        static let MapCellIdentifier = "Map Cell"
        static let PurchasPlaceCellIdentifier = "Purchase Place Cell"
        static let StoreCellIdentifier = "Store Place Cell"
        static let ShowExpirationDateViewControllerSegue = "Show ExpirationDate ViewController"
        static let ShowFavoriteShopsSegue = "Show Favorite Shops Segue"
    }
    

    fileprivate struct TableStructure {
        static let ProducerSectionHeader = NSLocalizedString("Producers", comment: "Header for section of tableView with information of the producer (name, geographic location).")
        static let ProducerCodeSectionHeader = NSLocalizedString("Producer Codes", comment: "Header for section of tableView with codes for the producer (EMB 123456 or FR.666.666).")
        static let IngredientOriginSectionHeader = NSLocalizedString("Origin ingredient", comment: "Header for section of tableView with location(s) of ingredients.")
        static let LocationSectionHeader = NSLocalizedString("Purchase Locations", comment: "Header for section of tableView with Locations where the product was bought.")
        static let CountriesSectionHeader = NSLocalizedString("Sales Countries", comment: "Header for section of tableView with Countries where the product is sold.")
        static let StoresSectionHeader = NSLocalizedString("Sale Stores", comment: "Header for section of tableView with names of the stores where the product is sold.")
        static let MapSectionHeader = NSLocalizedString("Map", comment: "Header for section of tableView with a map of producer, origin and shop locations.")
        static let ExpirationDateSectionHeader = NSLocalizedString("Expiration Date", comment: "Header title of the tableview section, indicating the most recent expiration date.")
        static let SitesSectionHeader = NSLocalizedString("Producer Sites", comment: "Header title of tableview section, indicating the sites for the product")
        static let ProducerSectionSize = 1
        static let ProducerCodeSectionSize = 1
        static let IngredientOriginSectionSize = 1
        static let LocationSectionSize = 1
        static let CountriesSectionSize = 1
        static let StoresSectionSize = 1
        static let MapSectionSize = 1
        static let ExpirationDateSectionSize = 1
        static let SitesSectionSize = 1
    }
    
    fileprivate func analyseProductForTable(_ product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        sectionsAndRows.append((
            SectionType.expirationDate,
            TableStructure.ExpirationDateSectionSize,
            TableStructure.ExpirationDateSectionHeader))
        // ingredient origin section
        sectionsAndRows.append((
            SectionType.ingredientOrigin,
            TableStructure.IngredientOriginSectionSize,
            TableStructure.IngredientOriginSectionHeader))
        // producer section
        sectionsAndRows.append((
            SectionType.producer,
            TableStructure.ProducerSectionSize,
            TableStructure.ProducerSectionHeader))
        // producer codes section
        sectionsAndRows.append((
            SectionType.producerCode,
            TableStructure.ProducerCodeSectionSize,
            TableStructure.ProducerCodeSectionHeader))
        // producer sites
        sectionsAndRows.append((
            SectionType.sites,
            TableStructure.SitesSectionSize,
            TableStructure.SitesSectionHeader))
        // stores section
        sectionsAndRows.append((
            SectionType.store,
            TableStructure.StoresSectionSize,
            TableStructure.StoresSectionHeader))
        // purchase Location section
        sectionsAndRows.append((
            SectionType.location,
            TableStructure.LocationSectionSize,
            TableStructure.LocationSectionHeader))
        // countries section
        sectionsAndRows.append((
            SectionType.country,
            TableStructure.CountriesSectionSize,
            TableStructure.CountriesSectionHeader))
        sectionsAndRows.append((
            SectionType.map,
            TableStructure.MapSectionSize,
            TableStructure.MapSectionHeader))

        return sectionsAndRows
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructureForProduct.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        // we assume that product exists
        switch currentProductSection {
        case .producer:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ProducerTagListViewCell, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = 0
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .producerCode:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ProducerCodeCellIdentifier, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = 1
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .sites:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.SitesCellIdentifier, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = 6
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            // print ("sites 2", cell.frame.size)
            return cell
            
        case .ingredientOrigin:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.IngredientOriginCellIdentifier, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = 2
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .store:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.StoreCellIdentifier, for: indexPath) as! PurchacePlaceTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = 3
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .location:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.PurchasPlaceCellIdentifier, for: indexPath) as! PurchacePlaceTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = 4
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .country:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CountriesCellIdentifier, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = 5
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .map:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MapCellIdentifier, for: indexPath) as! MapTableViewCell
            cell.product = product!
            return cell
            
        case .expirationDate:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ExpirationDateCellIdentifier, for: indexPath) as! ExpirationDateTableViewCell
            
            // has the product been edited?
            if let validDate = delegate?.updatedProduct?.expirationDate {
                cell.date = validDate
            } else if let validDate = product!.expirationDate {
                cell.date = validDate
            }
            cell.editMode = editMode
            cell.delegate = self
            cell.tag = 6
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]

        if editMode {
            switch currentProductSection {
            case .expirationDate:
                performSegue(withIdentifier: Storyboard.ShowExpirationDateViewControllerSegue, sender: self)
            default:
                break
            }
        }
    }

    // MARK: - Notification handler
    
    func reloadMapSection(_ notification: Notification) {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 8)], with: UITableViewRowAnimation.fade)
    }

    func refreshProduct() {
        tableView.reloadData()
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowExpirationDateViewControllerSegue:
                if  let vc = segue.destination as? SelectExpirationDateViewController {
                    if let validName = delegate?.updatedProduct?.expirationDate {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .none
                        vc.currentDate = validName
                    } else if let validName = product!.expirationDate {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .none
                        vc.currentDate = validName
                    } else {
                        vc.currentDate = nil
                    }

                }
            default: break
            }
        }
    }

    @IBAction func unwindSetExpirationDateForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectExpirationDateViewController {
            if let newDate = vc.selectedDate {
                delegate?.updated(expirationDate: newDate)
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func unwindSetExpirationDateForCancel(_ segue:UIStoryboardSegue) {
        if let _ = segue.source as? SelectExpirationDateViewController {
        }
    }

    @IBAction func unwindSetFavoriteShopForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? FavoriteShopsTableViewController {
            delegate?.update(shop: vc.selectedShop)
            tableView.reloadData()
        }
    }
    
    @IBAction func unwindSetFavoriteShopForCancel(_ segue:UIStoryboardSegue) {
    }

    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false

        title = Constants.ViewControllerTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // tableView.reloadData()
        // print ("viewWillAppear", tableView.frame)

        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name: .ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.removeProduct), name: .HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.reloadMapSection), name: .CoordinateHasBeenSet, object:nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // tableView.reloadData()
        // print ("viewDidAppear", tableView.frame)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - TagListView DataSource Functions

extension SupplyChainTableViewController: TagListViewDataSource {
    
    fileprivate struct TagConstants {
        static let Undefined = NSLocalizedString("undefined", comment: "tag of cell when no date was in off")
        static let None = NSLocalizedString("none", comment: "tag of cell when no tags are available")
    }
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ inputTags: [String]?) -> Int {
            tagListView.normalColorScheme = ColorSchemes.normal
            if let tags = inputTags {
                if tags.isEmpty {
                    if !editMode { tagListView.normalColorScheme = ColorSchemes.none }
                    return editMode ? 0 : 1
                } else {
                    return tags.count
                }
            } else {
                if !editMode { tagListView.normalColorScheme = ColorSchemes.error }
                return editMode ? 0 : 1
            }
        }
        
        switch tagListView.tag {
        case 0:
            return count(producerTagsToDisplay)
        case 1:
            return count(producerCodeTagsToDisplay)
        case 2:
            return count(ingredientOriginLocationTagsToDisplay)
        case 3:
            return count(storeTagsToDisplay)
        case 4:
            return count(purchaseLocationTagsToDisplay)
        case 5:
            return count(countriesToDisplay)
        case 6:
            return count(linksToDisplay)
        default: break
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        
        func title(_ inputTags: [String]?) -> String {
            if let tags = inputTags {
                return tags.isEmpty ? TagConstants.None : tags[index]
            }
            return TagConstants.Undefined
        }
        
        switch tagListView.tag {
        case 0:
            return title(producerTagsToDisplay)
        case 1:
            return title(producerCodeTagsToDisplay)
        case 2:
            return title(ingredientOriginLocationTagsToDisplay)
        case 3:
            return title(storeTagsToDisplay)
        case 4:
            return title(purchaseLocationTagsToDisplay)
        case 5:
            return title(countriesToDisplay)
        case 6:
            return title(linksToDisplay)
        default: break
        }
        return("error")
    }
}

// MARK: - TagListView Delegate Functions

extension SupplyChainTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tagListView.tag {
        case 0:
            if var tags = producerTagsToDisplay {
                tags.append(title)
                delegate?.update(producer: tags)
            } else {
                delegate?.update(producer: [title])
            }
        case 1:
            if var tags = producerCodeTagsToDisplay {
                tags.append(title)
                delegate?.update(producerCode: tags)
            } else {
                delegate?.update(producerCode: [title])
            }
        case 2:
            if var tags = ingredientOriginLocationTagsToDisplay {
                tags.append(title)
                delegate?.update(ingredientsOrigin: tags)
            } else {
                delegate?.update(ingredientsOrigin: [title])
            }
        case 3:
            if var tags = storeTagsToDisplay {
                tags.append(title)
                delegate?.update(stores: tags)
            } else {
                delegate?.update(stores: [title])
            }
        case 4:
            if var tags = purchaseLocationTagsToDisplay {
                tags.append(title)
                delegate?.update(purchaseLocation: tags)
            } else {
                delegate?.update(purchaseLocation: [title])
            }
        case 5:
            if var tags = countriesToDisplay {
                tags.append(title)
                delegate?.update(countries: tags)
            } else {
                delegate?.update(countries: [title])
            }
        case 6:
            if var tags = linksToDisplay {
                tags.append(title)
                delegate?.update(links: tags)
            } else {
                delegate?.update(links: [title])
            }
        default:
            break
        }
        // tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        switch tagListView.tag {
        case 0:
            if var validTags = producerTagsToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(producer: validTags)
            }
        case 1:
            if var validTags = producerCodeTagsToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(producerCode: validTags)
            }
        case 2:
            if var validTags = ingredientOriginLocationTagsToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(ingredientsOrigin: validTags)
            }
        case 3:
            if var validTags = storeTagsToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(stores: validTags)
            }
        case 4:
            if var validTags = purchaseLocationTagsToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(purchaseLocation: validTags)
            }
        case 5:
            if var validTags = countriesToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(countries: validTags)
            }
        case 6:
            if var validTags = linksToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(links: validTags)
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    
    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        switch tagListView.tag {
        case 0:
            delegate?.update(producer: [])
        case 1:
            delegate?.update(producerCode: [])
        case 2:
            delegate?.update(ingredientsOrigin: [])
        case 3:
            delegate?.update(stores: [])
        case 4:
            delegate?.update(purchaseLocation: [])
        case 5:
            delegate?.update(countries: [])
        case 6:
            delegate?.update(links: [])
        default:
            break
        }
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
            switch tagListView.tag {
            case 0:
                tableView.reloadSections(IndexSet.init(integer: 1), with: .automatic)
            case 1:
                tableView.reloadSections(IndexSet.init(integer: 2), with: .automatic)
            case 2:
                tableView.reloadSections(IndexSet.init(integer: 3), with: .automatic)
            case 3:
                tableView.reloadSections(IndexSet.init(integer: 4), with: .automatic)
            case 4:
                tableView.reloadSections(IndexSet.init(integer: 5), with: .automatic)
            case 5:
                tableView.reloadSections(IndexSet.init(integer: 6), with: .automatic)
            case 6:
                tableView.reloadSections(IndexSet.init(integer: 7), with: .automatic)
            default:
                break
            }
        }
}

// MARK: - UITextFieldDelegate Functions

extension SupplyChainTableViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 6:
            // expiration date
            if let validText = textField.text {
                delegate?.updated(expirationDateString: validText)
            }
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editMode
    }

}
