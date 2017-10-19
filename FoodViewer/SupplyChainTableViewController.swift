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

    public var tableItem: Any? = nil {
        didSet {
            if let item = tableItem as? FoodProduct {
                self.product = item
            } else if let item = tableItem as? SearchTemplate {
                self.query = item
            }
        }
    }

    fileprivate var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructureForProduct = setupTableSections()
                refreshProduct()
            }
        }
    }
    
    private var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                tableStructureForProduct = setupTableSections()
                refreshProduct()
            }
        }
    }

// MARK: Private Functions/Variables
    
    fileprivate var producerTagsToDisplay: Tags {
        get {
            if delegate?.updatedProduct != nil {
                switch delegate!.updatedProduct!.manufacturingPlacesOriginal {
                case .available, .empty:
                    showProducerTagsType = .edited
                    return delegate!.updatedProduct!.manufacturingPlacesOriginal
                default:
                    break
                }
            }
            switch showProducerTagsType {
            case .interpreted:
                return product!.manufacturingPlacesInterpreted
            case .original:
                return product!.manufacturingPlacesOriginal
            case .prefixed:
                return product!.manufacturingPlacesOriginal.prefixed(withAdded:product!.primaryLanguageCode, andRemoved:Locale.interfaceLanguageCode())
            default:
                return .undefined
            }
        }
    }
    
    fileprivate var producerCodeTagsToDisplay: Tags {
        get {
            if delegate?.updatedProduct != nil {
                switch delegate!.updatedProduct!.embCodesOriginal {
                case .available, .empty:
                    showProducerCodeTagsType = .edited
                    return delegate!.updatedProduct!.embCodesOriginal
                default:
                    break
                }
            }
            switch showProducerCodeTagsType {
            case .interpreted:
                return product!.embCodesInterpreted
            case .original:
                return product!.embCodesOriginal
            case .prefixed:
                return product!.embCodesOriginal.prefixed(withAdded:product!.primaryLanguageCode, andRemoved:Locale.interfaceLanguageCode())
            default:
                return .undefined
            }
        }
    }
    
    fileprivate var ingredientOriginLocationTagsToDisplay: Tags {
        get {
            if delegate?.updatedProduct != nil {
                switch delegate!.updatedProduct!.originsOriginal {
                case .available, .empty:
                    showIngredientOriginTagsType = .edited
                    return delegate!.updatedProduct!.originsOriginal
                default:
                    break
                }
            }
            switch showIngredientOriginTagsType {
            case .interpreted:
                return product!.originsInterpreted
            case .original:
                return product!.originsOriginal
            case .prefixed:
                return product!.originsOriginal.prefixed(withAdded:product!.primaryLanguageCode, andRemoved:Locale.interfaceLanguageCode())
            default:
                return .undefined
            }
        }
    }
    
    fileprivate var purchaseLocationTagsToDisplay: Tags {
        get {
            if delegate?.updatedProduct != nil {
                switch delegate!.updatedProduct!.purchasePlacesOriginal {
                case .available, .empty:
                    showPurchaseLocationTagsType = .edited
                    return delegate!.updatedProduct!.purchasePlacesOriginal
                default:
                    break
                }
            }
            switch showPurchaseLocationTagsType {
            case .interpreted:
                return product!.purchasePlacesInterpreted
            case .original:
                return product!.purchasePlacesOriginal
            case .prefixed:
                return product!.purchasePlacesOriginal.prefixed(withAdded:product!.primaryLanguageCode, andRemoved:Locale.interfaceLanguageCode())
            default:
                return .undefined
            }
        }
    }
    
    fileprivate var storeTagsToDisplay: Tags {
        get {
            if delegate?.updatedProduct != nil {
                switch delegate!.updatedProduct!.storesOriginal {
                case .available, .empty:
                    showStoresTagsType = .edited
                    return delegate!.updatedProduct!.storesOriginal
                default:
                    break
                }
            }
            switch showStoresTagsType {
            case .interpreted:
                return product!.storesInterpreted
            case .original:
                return product!.storesOriginal
            case .prefixed:
                return product!.storesOriginal.prefixed(withAdded:product!.primaryLanguageCode, andRemoved:Locale.interfaceLanguageCode())
            default:
                return .undefined
            }
        }
    }
    
    fileprivate var countriesToDisplay: Tags {
        get {
            if delegate?.updatedProduct != nil {
                switch delegate!.updatedProduct!.countriesOriginal {
                case .available, .empty:
                    showCountriesTagsType = .edited
                    return delegate!.updatedProduct!.countriesOriginal
                default:
                    break
                }
            }
            switch showCountriesTagsType {
            case .interpreted:
                return product!.countriesInterpreted
            case .translated:
                return product!.countriesTranslated
            case .original:
                return product!.countriesOriginal
            case .prefixed:
                return product!.countriesTranslated.prefixed(withAdded:product!.primaryLanguageCode, andRemoved:Locale.interfaceLanguageCode())
            default:
                return .undefined
            }
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
    
    private struct TagsTypeDefault {
        static let Countries: TagsType = .translated
        static let Stores: TagsType = .original
        static let PurchaseLocation: TagsType = .original
        static let IngredientOrigin: TagsType = .original
        static let ProducerCode: TagsType = .original
        static let Producer: TagsType = .original
    }
    
    private var showCountriesTagsType: TagsType = TagsTypeDefault.Countries
    fileprivate var showStoresTagsType: TagsType = TagsTypeDefault.Stores
    fileprivate var showPurchaseLocationTagsType: TagsType = TagsTypeDefault.PurchaseLocation
    private var showIngredientOriginTagsType: TagsType = TagsTypeDefault.IngredientOrigin
    private var showProducerCodeTagsType: TagsType = TagsTypeDefault.ProducerCode
    private var showProducerTagsType: TagsType = TagsTypeDefault.Producer

    fileprivate var notSearchableToDisplay: Tags {
        get {
            return .notSearchable
        }
    }

    fileprivate var searchProducerTagsToDisplay: Tags {
        get {
            if let (tags, _) = query?.manufacturing_places {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchProducerCodeTagsToDisplay: Tags {
        get {
            if let (tags, _) = query?.emb_codes {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchIngredientOriginLocationTagsToDisplay: Tags {
        get {
            if let (tags, _) = query?.origins {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchPurchaseLocationTagsToDisplay: Tags {
        get {
            if let (tags, _) = query?.purchase_places {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchStoreTagsToDisplay: Tags {
        get {
            if let (tags, _) = query?.stores {
                return tags
            }
            return .undefined
        }
    }
    
    fileprivate var searchCountriesToDisplay: Tags {
        get {
            if let (tags, _) = query?.countries {
                return tags
            }
            return .undefined
        }
    }

    fileprivate enum SectionType {
        case ingredientOrigin
        case ingredientOriginSearch
        case producer
        case producerSearch
        case producerCode
        case producerCodeSearch
        case location
        case locationSearch
        case store
        case storeSearch
        case country
        case countrySearch
        case map
        case expirationDate
        case expirationDateSearch
        case sites
        case sitesSearch
        case periodAfterOpening
        case periodAfterOpeningSearch
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
    
    private struct Storyboard {
        struct CellIdentifier {
            static let IngredientOrigin = "Ingredients Origin TagListView Cell"
            static let TagListView = "TagListView Cell Identifier"
            static let TagListViewWithSegmentedControl = "TagListView With SegmentedControl Cell Identifier"
            static let TagListViewWithButton = "TagListView With Button Cell Identifier"
            static let ExpirationDate = "Expiration Date Cell"
            static let PeriodAfterOpening = "Period After Opening Cell"
            static let Sites = "Sites TagListView Cell"
            static let Map = "Map Cell"
        }
        struct SegueIdentifier {
            static let ShowExpirationDateViewController = "Show ExpirationDate ViewController"
            static let ShowFavoriteShops = "Show Favorite Shops Segue"
        }
    }
    
    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []

    fileprivate struct TableStructure {
        static let ProducerSectionHeader = NSLocalizedString("Producers", comment: "Header for section of tableView with information of the producer (name, geographic location).")
        static let ProducerCodeSectionHeader = NSLocalizedString("Producer Codes", comment: "Header for section of tableView with codes for the producer (EMB 123456 or FR.666.666).")
        static let IngredientOriginSectionHeader = NSLocalizedString("Origin ingredient", comment: "Header for section of tableView with location(s) of ingredients.")
        static let LocationSectionHeader = NSLocalizedString("Purchase Locations", comment: "Header for section of tableView with Locations where the product was bought.")
        static let CountriesSectionHeader = NSLocalizedString("Sales Countries", comment: "Header for section of tableView with Countries where the product is sold.")
        static let StoresSectionHeader = NSLocalizedString("Sale Stores", comment: "Header for section of tableView with names of the stores where the product is sold.")
        static let MapSectionHeader = NSLocalizedString("Map", comment: "Header for section of tableView with a map of producer, origin and shop locations.")
        static let ExpirationDateSectionHeader = NSLocalizedString("Expiration Date", comment: "Header title of the tableview section, indicating the most recent expiration date.")
        static let SitesSectionHeader = NSLocalizedString("Product Websites", comment: "Header title of tableview section, indicating the websites for the product")
        static let PAOSectionHeader = NSLocalizedString("Period After Opening", comment: "Header title of tableview section, indicating period after opening for beauty products")
        static let ProducerSectionSize = 1
        static let ProducerCodeSectionSize = 1
        static let IngredientOriginSectionSize = 1
        static let LocationSectionSize = 1
        static let CountriesSectionSize = 1
        static let StoresSectionSize = 1
        static let MapSectionSize = 1
        static let ExpirationDateSectionSize = 1
        static let SitesSectionSize = 1
        static let PAOSectionSize = 1
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    fileprivate func setupTableSections() -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        if query != nil {
            switch currentProductType {
            case .beauty:
                sectionsAndRows.append((
                    SectionType.periodAfterOpeningSearch,
                    TableStructure.PAOSectionSize,
                    TableStructure.PAOSectionHeader))
            default:
                sectionsAndRows.append((
                    SectionType.expirationDateSearch,
                    TableStructure.ExpirationDateSectionSize,
                    TableStructure.ExpirationDateSectionHeader))
            }
            // ingredient origin section
            sectionsAndRows.append((
                SectionType.ingredientOriginSearch,
                TableStructure.IngredientOriginSectionSize,
                TableStructure.IngredientOriginSectionHeader))
            // producer section
            sectionsAndRows.append((
                SectionType.producerSearch,
                TableStructure.ProducerSectionSize,
                TableStructure.ProducerSectionHeader))
            // producer codes section
            sectionsAndRows.append((
                SectionType.producerCodeSearch,
                TableStructure.ProducerCodeSectionSize,
                TableStructure.ProducerCodeSectionHeader))
            // producer sites
            sectionsAndRows.append((
                SectionType.sitesSearch,
                TableStructure.SitesSectionSize,
                TableStructure.SitesSectionHeader))
            // stores section
            sectionsAndRows.append((
                SectionType.storeSearch,
                TableStructure.StoresSectionSize,
                TableStructure.StoresSectionHeader))
            // purchase Location section
            sectionsAndRows.append((
                SectionType.locationSearch,
                TableStructure.LocationSectionSize,
                TableStructure.LocationSectionHeader))
            // countries section
            sectionsAndRows.append((
                SectionType.countrySearch,
                TableStructure.CountriesSectionSize,
                TableStructure.CountriesSectionHeader))
        } else {
            switch currentProductType {
            case .beauty:
                sectionsAndRows.append((
                    SectionType.periodAfterOpening,
                    TableStructure.PAOSectionSize,
                    TableStructure.PAOSectionHeader))
            default:
                sectionsAndRows.append((
                    SectionType.expirationDate,
                    TableStructure.ExpirationDateSectionSize,
                    TableStructure.ExpirationDateSectionHeader))
            }
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
        //sectionsAndRows.append((
        //    SectionType.map,
        //    TableStructure.MapSectionSize,
        //    TableStructure.MapSectionHeader))
        }
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
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.section]
        
        // we assume that product exists
        switch currentProductSection {
        case .producer, .producerCode, .sites, .ingredientOrigin, .country:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .store:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithButton, for: indexPath) as! PurchacePlaceTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell
            
        case .location:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithButton, for: indexPath) as! PurchacePlaceTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            return cell

        case .producerSearch, .producerCodeSearch, .ingredientOriginSearch, .storeSearch, .locationSearch, .countrySearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithSegmentedControl, for: indexPath) as! TagListViewSegmentedControlTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            switch currentProductSection {
            case .producerSearch:
                cell.inclusion = OFFProducts.manager.searchQuery?.manufacturing_places.1 ?? true
            case .producerCodeSearch:
                cell.inclusion = OFFProducts.manager.searchQuery?.emb_codes.1 ?? true
            case .ingredientOriginSearch:
                cell.inclusion = OFFProducts.manager.searchQuery?.origins.1 ?? true
            case .storeSearch:
                cell.inclusion = OFFProducts.manager.searchQuery?.stores.1 ?? true
            case .locationSearch:
                cell.inclusion = OFFProducts.manager.searchQuery?.purchase_places.1 ?? true
            case .countrySearch:
                cell.inclusion = OFFProducts.manager.searchQuery?.countries.1 ?? true
            default:
                break
            }
            return cell

        case .map:
            // This is just have some harmless code here
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode

            
            //let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.MapCellIdentifier, for: indexPath) as! MapTableViewCell
            //cell.product = product!
            return cell
            
        case .expirationDate:
            if product!.type == .beauty {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.PeriodAfterOpening, for: indexPath)
                
                // has the product been edited?
                if let validPeriod = delegate?.updatedProduct?.periodAfterReferenceDate {
                    let periodInSeconds = validPeriod.timeIntervalSinceReferenceDate
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .full
                    formatter.allowedUnits = .month
                    let formattedTimeLeft = formatter.string(from: periodInSeconds)
                    cell.textLabel?.text = formattedTimeLeft
                } else if let validPeriod = product!.periodAfterReferenceDate {
                    let periodInSeconds = validPeriod.timeIntervalSinceReferenceDate
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .full
                    formatter.allowedUnits = .month
                    let formattedTimeLeft = formatter.string(from: periodInSeconds)
                    cell.textLabel?.text = formattedTimeLeft
                }
                cell.tag = indexPath.section
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ExpirationDate, for: indexPath) as! ExpirationDateTableViewCell
            
                // has the product been edited?
                if let validDate = delegate?.updatedProduct?.expirationDate {
                    cell.date = validDate
                } else if let validDate = product!.expirationDate {
                    cell.date = validDate
                }
                cell.editMode = editMode
                cell.delegate = self
                cell.tag = indexPath.section
                return cell
            }
        case .periodAfterOpening:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.PeriodAfterOpening, for: indexPath) as! PeriodAfterOpeningTableViewCell

            if let validPeriodAfterOpening = delegate?.updatedProduct?.periodAfterOpeningString {
                cell.tekst = validPeriodAfterOpening
            } else if let validPeriodAfterOpening = product?.periodAfterOpeningString {
                cell.tekst = validPeriodAfterOpening
            }
            cell.editMode = editMode
            cell.delegate = self
            cell.tag = indexPath.section
            return cell
        case .expirationDateSearch, .sitesSearch, .periodAfterOpeningSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.editMode = false
            cell.tag = indexPath.section
            cell.tagListView.normalColorScheme = ColorSchemes.error
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        let (currentProductSection, _, _) = tableStructureForProduct[section]
        guard header != nil else { return "No header" }

        switch currentProductSection {
        case .ingredientOrigin:
            switch showIngredientOriginTagsType {
            case TagsTypeDefault.IngredientOrigin:
                return header
            default:
                return header! +
                    " " +
                    "(" +
                    showIngredientOriginTagsType.description() +
                ")"
            }
            
        case .producer:
            switch showProducerTagsType {
            case TagsTypeDefault.Producer:
                return header
            default:
                return header! +
                    " " +
                    "(" +
                    showProducerTagsType.description() +
                ")"
            }
        case .store:
            switch showStoresTagsType {
            case TagsTypeDefault.Stores:
                return header
            default:
                return header! +
                    " " +
                    "(" +
                    showStoresTagsType.description() +
                ")"
            }
        case .location:
            switch showPurchaseLocationTagsType {
            case TagsTypeDefault.PurchaseLocation:
                return header
            default:
                return header! +
                    " " +
                    "(" +
                    showPurchaseLocationTagsType.description() +
                ")"
            }
        case .country:
            switch showCountriesTagsType {
            case TagsTypeDefault.Countries:
                return header
            default:
                return header! +
                    " " +
                    "(" +
                    showCountriesTagsType.description() +
                ")"
            }
        case .producerCode:
            switch showProducerCodeTagsType {
            case TagsTypeDefault.ProducerCode:
                return header
            default:
                return header! +
                    " " +
                    "(" +
                    showProducerCodeTagsType.description() +
                ")"
            }
        default:
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]

        if editMode {
            switch currentProductSection {
            case .expirationDate:
                performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowExpirationDateViewController, sender: self)
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
        showCountriesTagsType = TagsTypeDefault.Countries
        showStoresTagsType = TagsTypeDefault.Stores
        showPurchaseLocationTagsType = TagsTypeDefault.PurchaseLocation
        showIngredientOriginTagsType = TagsTypeDefault.IngredientOrigin
        showProducerCodeTagsType = TagsTypeDefault.ProducerCode
        showProducerTagsType = TagsTypeDefault.Producer
        
        tableView.reloadData()
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }
    
    func changeTagsTypeToShow(_ notification: Notification) {
        if let tag = notification.userInfo?[TagListViewTableViewCell.Notification.TagKey] as? Int {
            let (currentProductSection, _, _) = tableStructureForProduct[tag]
            switch currentProductSection {
            case .producer:
                showProducerTagsType.cycle()
                tableView.reloadSections(IndexSet.init(integer: tag), with: .fade)
            case .producerCode:
                showProducerCodeTagsType.cycle()
                tableView.reloadSections(IndexSet.init(integer: tag), with: .fade)
            case .country:
                showCountriesTagsType.cycle()
                tableView.reloadSections(IndexSet.init(integer: tag), with: .fade)
            case .ingredientOrigin:
                showIngredientOriginTagsType.cycle()
                tableView.reloadSections(IndexSet.init(integer: tag), with: .fade)
            default:
                break
            }
        }
    }
    
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowExpirationDateViewController:
                if  let vc = segue.destination as? SelectExpirationDateViewController {
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? ExpirationDateTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
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
                        }
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

        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name: .ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.removeProduct), name: .HistoryHasBeenDeleted, object:nil)
        // Has been disabled for the moment
        // NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.reloadMapSection), name: .CoordinateHasBeenSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.changeTagsTypeToShow), name:.TagListViewTapped, object:nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - PurchacePlaceCellDelegate Functions

extension SupplyChainTableViewController: PurchacePlaceCellDelegate {
    
    // function to let the delegate know that the tagListView has been doubletapped
    func purchacePlaceTableViewCell(_ sender: PurchacePlaceTableViewCell, receivedDoubleTapOn tagListView: TagListView) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .location:
            showPurchaseLocationTagsType.cycle()
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        case .store:
            showStoresTagsType.cycle()
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
        default:
            break
        }
    }
}

// MARK: - TagListViewSegmentedControlCellDelegate Functions

extension SupplyChainTableViewController: TagListViewSegmentedControlCellDelegate {
    
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl: UISegmentedControl) {
        let inclusion = segmentedControl.selectedSegmentIndex == 0 ? false : true
        let (currentProductSection, _, _) = tableStructureForProduct[segmentedControl.tag]
        
        switch currentProductSection {
        case .ingredientOriginSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.origins.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .producerSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.manufacturing_places.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .producerCodeSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.emb_codes.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .storeSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.stores.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .locationSearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.purchase_places.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        case .countrySearch:
            if OFFProducts.manager.searchQuery == nil {
                OFFProducts.manager.searchQuery = SearchTemplate.init()
            }
            OFFProducts.manager.searchQuery!.countries.1 = inclusion
            tableView.reloadSections(IndexSet.init(integer: segmentedControl.tag), with: .fade)
        default:
            break
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate Functions

extension SupplyChainTableViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - Popover delegation functions
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
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
        
        func countTags(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            case .notSearchable:
                return 1
            }
        }

        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
            case .producer:
                return countTags(producerTagsToDisplay)
            case .producerCode:
                return countTags(producerCodeTagsToDisplay)
            case .ingredientOrigin:
                return countTags(ingredientOriginLocationTagsToDisplay)
            case .store:
                return countTags(storeTagsToDisplay)
            case .location:
                return countTags(purchaseLocationTagsToDisplay)
            case .country:
                return countTags(countriesToDisplay)
            case .sites:
                return count(linksToDisplay ?? [])
            case .producerSearch:
                return countTags(searchProducerTagsToDisplay)
            case .producerCodeSearch:
                return countTags(searchProducerCodeTagsToDisplay)
            case .ingredientOriginSearch:
                return countTags(searchIngredientOriginLocationTagsToDisplay)
            case .storeSearch:
                return countTags(searchStoreTagsToDisplay)
            case .locationSearch:
                return countTags(searchPurchaseLocationTagsToDisplay)
            case .countrySearch:
                return countTags(searchCountriesToDisplay)
            case .sitesSearch, .periodAfterOpeningSearch, .expirationDateSearch:
                return 1
            default: break
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
            case .producer:
                return producerTagsToDisplay.tag(at:index)!
            case .producerCode:
                return producerCodeTagsToDisplay.tag(at:index)!
            case .ingredientOrigin:
                return ingredientOriginLocationTagsToDisplay.tag(at:index)!
            case .store:
                return storeTagsToDisplay.tag(at:index)!
            case .location:
                return purchaseLocationTagsToDisplay.tag(at:index)!
            case .country:
                return countriesToDisplay.tag(at:index)!
            case .sites:
                if linksToDisplay != nil && index < linksToDisplay!.count {
                    return  linksToDisplay![index]
                } else {
                    return "No tag set"
                }
            case .producerSearch:
                return searchProducerTagsToDisplay.tag(at:index)!
            case .producerCodeSearch:
                return searchProducerCodeTagsToDisplay.tag(at:index)!
            case .ingredientOriginSearch:
                return searchIngredientOriginLocationTagsToDisplay.tag(at:index)!
            case .storeSearch:
                return searchStoreTagsToDisplay.tag(at:index)!
            case .locationSearch:
                return searchPurchaseLocationTagsToDisplay.tag(at:index)!
            case .countrySearch:
                return searchCountriesToDisplay.tag(at:index)!
            case .sitesSearch, .periodAfterOpeningSearch, .expirationDateSearch:
                return notSearchableToDisplay.tag(at:index)!
            default: break
        }
        return("error")
    }
    
    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .producer:
            switch producerTagsToDisplay {
            case .available:
                delegate?.update(producer: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .producerCode:
            switch producerCodeTagsToDisplay {
            case .available:
                delegate?.update(producerCode: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .ingredientOrigin:
            switch ingredientOriginLocationTagsToDisplay {
            case .available:
                delegate?.update(ingredientsOrigin: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .store:
            switch storeTagsToDisplay {
            case .available:
                delegate?.update(stores: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .location:
            switch purchaseLocationTagsToDisplay {
            case .available:
                delegate?.update(purchaseLocation: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .country:
            switch countriesToDisplay {
            case .available:
                delegate?.update(countries: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .sites:
            delegate?.update(links: [])

        case .producerSearch:
            switch searchProducerTagsToDisplay {
            case .available:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.manufacturing_places.0 = .available([])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .producerCodeSearch:
            switch searchProducerCodeTagsToDisplay {
            case .available:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.emb_codes.0 = .available([])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .ingredientOriginSearch:
            switch searchIngredientOriginLocationTagsToDisplay {
            case .available:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.origins.0 = .available([])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .storeSearch:
            switch searchStoreTagsToDisplay {
            case .available:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.stores.0 = .available([])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .locationSearch:
            switch searchPurchaseLocationTagsToDisplay {
            case .available:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.purchase_places.0 = .available([])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .countrySearch:
            switch countriesToDisplay {
            case .available:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.countries.0 = .available([])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        default:
            break
        }
    }

}

// MARK: - TagListView Delegate Functions

extension SupplyChainTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .producer:
            switch producerTagsToDisplay {
            case .undefined, .empty:
                delegate?.update(producer: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(producer: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .producerCode:
            switch producerCodeTagsToDisplay {
            case .undefined, .empty:
                delegate?.update(producerCode: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(producerCode: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .ingredientOrigin:
            switch ingredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                delegate?.update(ingredientsOrigin: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(ingredientsOrigin: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .store:
            switch storeTagsToDisplay {
            case .undefined, .empty:
                delegate?.update(stores: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(stores: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .location:
            switch purchaseLocationTagsToDisplay {
            case .undefined, .empty:
                delegate?.update(purchaseLocation: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(purchaseLocation: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .country:
            switch countriesToDisplay {
            case .undefined, .empty:
                delegate?.update(countries: [title])
            case var .available(list):
                list.append(title)
                delegate?.update(countries: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .sites:
            if var tags = linksToDisplay {
                tags.append(title)
                delegate?.update(links: tags)
            } else {
                delegate?.update(links: [title])
            }
            
        case .producerSearch:
            switch searchProducerTagsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.manufacturing_places.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.manufacturing_places.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .producerCodeSearch:
            switch searchProducerCodeTagsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.emb_codes.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.emb_codes.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .ingredientOriginSearch:
            switch searchIngredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.origins.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.origins.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .storeSearch:
            switch searchStoreTagsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.stores.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.stores.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .locationSearch:
            switch searchPurchaseLocationTagsToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.purchase_places.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.purchase_places.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .countrySearch:
            switch searchCountriesToDisplay {
            case .undefined, .empty:
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.countries.0 = .available([title])
            case .available(var list):
                list.append(title)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.countries.0 = .available(list)
            default:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .producer:
            switch producerTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(producer: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
            
        case .producerCode:
            switch producerCodeTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(producerCode: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
            
        case .ingredientOrigin:
            switch ingredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(ingredientsOrigin: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)

        case .store:
            switch storeTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(stores: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
            
        case .location:
            switch purchaseLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(purchaseLocation: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
            
        case .country:
            switch countriesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                delegate?.update(countries: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
            
        case .sites:
            if var validTags = linksToDisplay {
                guard index >= 0 && index < validTags.count else {
                    break
                }
                validTags.remove(at: index)
                delegate?.update(links: validTags)
            }
        case .producerSearch:
            switch searchProducerTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.manufacturing_places.0 = Tags.init(list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .producerCodeSearch:
            switch searchProducerCodeTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.emb_codes.0 = Tags.init(list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .ingredientOriginSearch:
            switch searchIngredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.origins.0 = Tags.init(list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .storeSearch:
            switch searchStoreTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.stores.0 = Tags.init(list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .locationSearch:
            switch searchPurchaseLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.purchase_places.0 = Tags.init(list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .countrySearch:
            switch countriesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case .available(var list):
                list.remove(at: index)
                if OFFProducts.manager.searchQuery == nil {
                    OFFProducts.manager.searchQuery = SearchTemplate.init()
                }
                OFFProducts.manager.searchQuery!.countries.0 = Tags.init(list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }

        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        // print("reloading section", tagListView.tag)
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .fade)
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .country:
            switch product!.countriesInterpreted {
            case .available(let countries):
                delegate?.search(for: countries[index], in: .country)
            default:
                break
            }
            
        case .producerCode:
            switch product!.embCodesInterpreted {
            case .available:
                delegate?.search(for: product!.embCodesInterpreted.tag(at:index), in: .producerCode)
            default:
                break
            }
            
        case .location:
            switch product!.purchasePlacesOriginal {
            case .available:
                delegate?.search(for: product!.purchasePlacesOriginal.tag(at:index), in: .purchasePlace)
            default:
                break
            }
            
        case .producer:
            switch product!.manufacturingPlacesOriginal {
            case .available:
                delegate?.search(for: product!.manufacturingPlacesOriginal.tag(at:index), in: .manufacturingPlaces)
            default:
                break
            }
            
        case .store:
            switch product!.storesInterpreted {
            case .available:
                delegate?.search(for: product!.storesInterpreted.tag(at:index), in: .store)
            default:
                break
            }
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
        let (currentProductSection, _, _) = tableStructureForProduct[textField.tag]
        switch currentProductSection {
        case .expirationDate:
            // expiration date
            if let validText = textField.text {
                delegate?.updated(expirationDateString: validText)
            }
        case .periodAfterOpening:
            // period after opening
            if let validText = textField.text {
                delegate?.update(periodAfterOpeningString: validText + " M")
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
