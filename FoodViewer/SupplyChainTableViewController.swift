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
    
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                tableView.reloadData()
            }
        }
    }


// MARK: Private Functions/Variables
    
    
    private var editMode: Bool {
        return delegate?.editMode ?? false
    }

    fileprivate enum ProductVersion {
        case remoteUser // data as entered by the user
        case remoteTags // data interpreted by off
        case remoteTagsTranslated // tags with parents?
        case new // new data as entered by the user locally
        
        var isRemote: Bool {
            switch self {
            case .new:
                return false
            default:
                return true
            }
        }
    }

    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
    
    // Determines which version of the product needs to be shown, the remote or local

    fileprivate var productVersion: ProductVersion = .new
    
    fileprivate var producerTagsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.manufacturingPlacesOriginal) {
                    return checked
                }
            // There is no taxonomy
            default: break
            }
            return productPair?.remoteProduct?.manufacturingPlacesOriginal ?? .undefined
        }
    }
    
    
    fileprivate var producerCodeTagsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.embCodesOriginal) {
                    return checked
                }
            case .remoteTags, .remoteTagsTranslated:
                return productPair?.remoteProduct?.embCodesInterpreted ?? .undefined
            default: break
            }
            return productPair?.remoteProduct?.embCodesOriginal ?? .undefined
        }
    }
    
    
    fileprivate var ingredientOriginLocationTagsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.originsOriginal) {
                    return checked
                }
            // There is no taxonomy
            default: break
            }
            return productPair?.remoteProduct?.originsOriginal ?? .undefined
        }
    }
    
    fileprivate var purchaseLocationTagsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.purchasePlacesOriginal) {
                    return checked
                }
            // There is no taxonomy
            default: break
            }
            return productPair?.remoteProduct?.purchasePlacesOriginal ?? .undefined
        }
    }
    
    fileprivate var storeTagsToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.storesOriginal) {
                    return checked
                }
            // There is no taxonomy
            //case .remoteTags, .remoteTagsTranslated:
            //    return productPair?.remoteProduct?.storesInterpreted ?? .undefined
            default: break
            }
            return productPair?.remoteProduct?.storesOriginal ?? .undefined

        }
    }
    
    fileprivate var countriesToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let checked = checkedTags(productPair?.localProduct?.countriesOriginal) {
                    return checked
                }
            case .remoteTags:
                return productPair?.remoteProduct?.countriesInterpreted ?? .undefined
            case .remoteUser:
                return productPair?.remoteProduct?.countriesOriginal ?? .undefined
            default: break
            }
            // translated countries is default
            if var list = productPair?.remoteProduct?.countriesTranslated.list {
                list = list.sorted(by: { $0 < $1 })
                return Tags.init(list:list)
            } else {
                return .undefined
            }
        }
    }
    
    fileprivate var periodAfterOpeningToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let pAOS = productPair?.localProduct?.periodAfterOpeningString ??
                    productPair?.remoteProduct?.periodAfterOpeningString {
                    return Tags.init(text: pAOS )
                } else {
                    return .undefined
                }
            case .remoteTags, .remoteTagsTranslated, .remoteUser:
                if let pAOS = productPair?.remoteProduct?.periodAfterOpeningString {
                    return Tags.init(text: pAOS )
                } else {
                    return .undefined
                }
            }
        }
    }
    

    fileprivate var linksToDisplay: Tags {
        get {
            switch productVersion {
            case .new:
                if let validTags = productPair?.localProduct?.links {
                    return Tags.init(list:validTags.map( { $0.absoluteString } ))
                } else if let validTags = productPair?.remoteProduct?.links {
                    return Tags.init(list:validTags.map( { $0.absoluteString } ))
                }
            case .remoteTags, .remoteTagsTranslated, .remoteUser:
                if let validTags = productPair?.remoteProduct?.links {
                    return Tags.init(list:validTags.map( { $0.absoluteString } ))
                }
            }
            return .undefined
        }
    }
    
    fileprivate func checkedTags(_ tags:Tags?) -> Tags? {
        if let validTags = tags,
            validTags.isAvailable {
            return validTags
        }
        return nil
    }

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
        case periodAfterOpening
    }
    
    fileprivate struct Constants {
        static let ViewControllerTitle = TranslatableStrings.SupplyChain
        static let NoExpirationDate = TranslatableStrings.NoExpirationDate
    }

    // MARK: - Interface Functions
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
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
        static let ProducerSectionHeader = TranslatableStrings.Producer
        static let ProducerCodeSectionHeader = TranslatableStrings.ProductCodes
        static let IngredientOriginSectionHeader = TranslatableStrings.IngredientOrigins
        static let LocationSectionHeader = TranslatableStrings.PurchaseAddress
        static let CountriesSectionHeader = TranslatableStrings.SalesCountries
        static let StoresSectionHeader = TranslatableStrings.Stores
        static let MapSectionHeader = TranslatableStrings.Map
        static let ExpirationDateSectionHeader = TranslatableStrings.ExpirationDate
        static let SitesSectionHeader = TranslatableStrings.ProductWebSites
        static let PAOSectionHeader = TranslatableStrings.PeriodAfterOpening
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
            if editMode {
                switch currentProductSection {
                case .producer:
                    if let oldTags = productPair?.localProduct?.manufacturingPlacesOriginal {
                        switch oldTags {
                        case .available:
                            cell.editMode = !productVersion.isRemote
                        default:
                            break
                        }
                    }
                case .producerCode:
                    if let oldTags = productPair?.localProduct?.embCodesOriginal {
                        switch oldTags {
                        case .available:
                            cell.editMode = !productVersion.isRemote
                        default:
                            break
                        }
                    }
                case .sites:
                    if productPair?.localProduct?.links != nil {
                        cell.editMode = !productVersion.isRemote
                    }
                case .ingredientOrigin:
                    if let oldTags = productPair?.localProduct?.originsOriginal {
                        switch oldTags {
                        case .available:
                            cell.editMode = !productVersion.isRemote
                        default:
                            break
                        }
                    }
                case .country:
                if let oldTags = productPair?.localProduct?.countriesOriginal {
                    switch oldTags {
                    case .available:
                        cell.editMode = !productVersion.isRemote
                    default:
                        break
                    }
                }
                default:
                    break
                }
            }
            return cell
            
        case .store:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithButton, for: indexPath) as! PurchacePlaceTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            if editMode,
                let oldTags = productPair?.localProduct?.storesOriginal {
                switch oldTags {
                case .available:
                    cell.editMode = !productVersion.isRemote
                default:
                    break
                }
            }
            return cell

        case .location:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewWithButton, for: indexPath) as! PurchacePlaceTableViewCell
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.section
            cell.delegate = self
            cell.datasource = self
            cell.editMode = editMode
            if editMode,
                let oldTags = productPair?.localProduct?.purchasePlacesOriginal {
                switch oldTags {
                case .available:
                    cell.editMode = !productVersion.isRemote
                default:
                    break
                }
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
            if productPair!.barcodeType.productType == .beauty {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.PeriodAfterOpening, for: indexPath)
                cell.frame.size.width = tableView.frame.size.width
                switch productVersion {
                case .new:
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .full
                    formatter.allowedUnits = .month
                    if let validPeriod = productPair?.localProduct?.periodAfterReferenceDate {
                        let periodInSeconds = validPeriod.timeIntervalSinceReferenceDate
                        let formattedTimeLeft = formatter.string(from: periodInSeconds)
                        cell.textLabel?.text = formattedTimeLeft
                    } else if let validPeriod = productPair?.remoteProduct?.periodAfterReferenceDate {
                        let periodInSeconds = validPeriod.timeIntervalSinceReferenceDate
                        let formattedTimeLeft = formatter.string(from: periodInSeconds)
                        cell.textLabel?.text = formattedTimeLeft
                    }

                default:
                    if let validPeriod = productPair?.remoteProduct?.periodAfterReferenceDate {
                        let periodInSeconds = validPeriod.timeIntervalSinceReferenceDate
                        let formatter = DateComponentsFormatter()
                        formatter.unitsStyle = .full
                        formatter.allowedUnits = .month
                        let formattedTimeLeft = formatter.string(from: periodInSeconds)
                        cell.textLabel?.text = formattedTimeLeft
                    }
                }
                cell.tag = indexPath.section
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ExpirationDate, for: indexPath) as! ExpirationDateTableViewCell
                // print (productPair?.remoteProduct?.expirationDate, productPair?.remoteProduct?.state)
                switch productVersion {
                case .new:
                    cell.date = productPair?.localProduct?.expirationDate ?? productPair?.remoteProduct?.expirationDate
                default:
                    cell.date = productPair?.remoteProduct?.expirationDate
                }
                cell.editMode = editMode
                cell.delegate = self
                cell.tag = indexPath.section
                return cell
            }
        case .periodAfterOpening:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.PeriodAfterOpening, for: indexPath) as! PeriodAfterOpeningTableViewCell
            switch periodAfterOpeningToDisplay {
            case .available(let array):
                cell.tekst = array[0]
            default:
                cell.tekst = nil
            }
            cell.editMode = editMode
            cell.delegate = self
            cell.tag = indexPath.section
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var (_, _, header) = tableStructureForProduct[section]
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }
        let (currentProductSection, _, _) = tableStructureForProduct[section]
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LanguageHeaderView") as! LanguageHeaderView
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        headerView.changeLanguageButton.isHidden = true
        headerView.buttonNotDoubleTap = buttonNotDoubleTap

        switch currentProductSection {
        case .ingredientOrigin:
            switch productVersion {
            case .new:
                if let newTags = productPair?.localProduct?.originsOriginal {
                    switch newTags {
                    case .available:
                        header = TranslatableStrings.IngredientOriginsEdited
                    default:
                    // if no edits have been made show simple headers
                        header = TranslatableStrings.IngredientOrigins
                    }
                } else {
                    header = TranslatableStrings.IngredientOrigins
                }
            default:
                header = TranslatableStrings.IngredientOriginsOriginal
            }

        case .producer:
            switch productVersion {
            case .new:
                if let newTags = productPair?.localProduct?.manufacturingPlacesOriginal {
                    switch newTags {
                    case .available:
                        // the local version has been requested and is available
                        header = TranslatableStrings.ProducerEdited
                    default:
                        header = TranslatableStrings.Producer
                    }
                } else {
                    header = TranslatableStrings.Producer
                }
            default:
                header = TranslatableStrings.ProducerOriginal
            }

        case .store:
            switch productVersion {
            case .new:
                if let newTags = productPair?.localProduct?.storesOriginal {
                    switch newTags {
                    case .available:
                        // the local version has been requested and is available
                        header = TranslatableStrings.StoresEdited
                    default:
                        header = TranslatableStrings.Stores
                    }
                } else {
                    header = TranslatableStrings.Stores
                }
            default:
                header = TranslatableStrings.StoresOriginal
            }

        case .location:
            switch productVersion {
            case .new:
                if let newTags = productPair?.localProduct?.purchasePlacesOriginal {
                    switch newTags {
                    case .available:
                        // the local version has been requested and is available
                        header = TranslatableStrings.PurchaseAddressEdited
                    default:
                        header = TranslatableStrings.PurchaseAddress
                    }
                } else {
                    header = TranslatableStrings.PurchaseAddress
                }
            default:
                header = TranslatableStrings.PurchaseAddressOriginal
            }

        case .country:
            switch productVersion {
            case .new:
                if let newTags = productPair?.localProduct?.countriesOriginal {
                    switch newTags {
                    case .available:
                        // the local version has been requested and is available
                        header = TranslatableStrings.CountriesEdited
                    default:
                        header = TranslatableStrings.Countries
                    }
                } else {
                    header = TranslatableStrings.Countries
                }
            case .remoteTagsTranslated:
                header = TranslatableStrings.CountriesTranslated
            case .remoteTags:
                header = TranslatableStrings.CountriesNormalized
            case .remoteUser:
                header = TranslatableStrings.CountriesOriginal
            }
            
        case .producerCode:
            switch productVersion {
            case .new:
                if let newTags = productPair?.localProduct?.embCodesOriginal {
                switch newTags {
                    case .available:
                        // the local version has been requested and is available
                        header = TranslatableStrings.ProductCodesEdited
                    default:
                        header = TranslatableStrings.ProductCodes
                    }
                } else {
                    header = TranslatableStrings.ProductCodes
                }
            default:
                header = TranslatableStrings.ProductCodesOriginal
            }

        case .sites:
            switch productVersion {
            case .new:
                if productPair?.localProduct != nil {
                    if productPair?.localProduct?.expirationDate != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.ProductWebSitesEdited
                    } else {
                        header = TranslatableStrings.ProductWebSites
                    }
                } else {
                    header = TranslatableStrings.ProductWebSites
                }
            default:
                header = TranslatableStrings.ProductWebSitesOriginal
            }
        case .map:
            header = TranslatableStrings.Map

        case .expirationDate:
            switch productVersion {
            case .new:
                if productPair?.localProduct != nil {
                    if productPair?.localProduct?.expirationDate != nil {
                        // the local version has been requested and is available
                        header = TranslatableStrings.ExpirationDateEdited
                    } else {
                        header = TranslatableStrings.ExpirationDate
                    }
                } else {
                    header = TranslatableStrings.ExpirationDate
                }
            default:
                header = TranslatableStrings.ExpirationDateOriginal
            }

        case .periodAfterOpening:
            switch productVersion {
            case .new:
                if productPair?.localProduct != nil {
                    if productPair?.localProduct?.expirationDate != nil {
                    // the local version has been requested and is available
                        header = TranslatableStrings.PeriodAfterOpeningEdited
                    } else {
                        header = TranslatableStrings.PeriodAfterOpening
                    }
                } else {
                    header = TranslatableStrings.PeriodAfterOpening
                }
            default:
                header = TranslatableStrings.PeriodAfterOpeningOriginal
            }
        }
        headerView.title = header
        return headerView
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
//
// MARK: - Notification handlers
//
    func reloadMapSection(_ notification: Notification) {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 8)], with: UITableView.RowAnimation.fade)
    }
    
    func refreshInterface() {
        tableView.reloadData()
    }

    @objc func refreshProduct() {
        productVersion = .new
        tableView.reloadData()
    }

    @objc func removeProduct() {
        productPair!.remoteProduct = nil
        tableView.reloadData()
    }
//
// MARK: - Navigation
//
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
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                if let validName = productPair?.localProduct?.expirationDate {
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    formatter.timeStyle = .none
                                    vc.currentDate = validName
                                } else if let validName = productPair!.remoteProduct!.expirationDate {
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
                productPair?.update(expirationDate: newDate)
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
            productPair?.update(shop: vc.selectedShop)
            tableView.reloadData()
        }
    }
    
    @IBAction func unwindSetFavoriteShopForCancel(_ segue:UIStoryboardSegue) {
    }
    
    @objc func doubleTapOnTableView() {
        switch productVersion {
        case .new:
            productVersion = .remoteTags
        case .remoteTags:
            productVersion = .remoteTagsTranslated
        case .remoteTagsTranslated:
            productVersion = .remoteUser
        case .remoteUser:
            productVersion = productPair?.localProduct != nil ? .new : .remoteTags
        }
        tableView.reloadData()
    }

//
// MARK: - Controller Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableStructureForProduct = setupTableSections()
        tableView.reloadData()

        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name: .ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)

        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.removeProduct), name: .HistoryHasBeenDeleted, object:nil)
        // Has been disabled for the moment
        // NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.reloadMapSection), name: .CoordinateHasBeenSet, object:nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
        OFFplists.manager.flush()
    }

}
//
// MARK: - LanguageHeaderDelegate Functions
//
extension SupplyChainTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        // not needed
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        doubleTapOnTableView()
    }
}

//
// MARK: - TagListViewCellDelegate Functions
//
extension SupplyChainTableViewController: TagListViewCellDelegate {
    
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }
}
//
// MARK: - PurchacePlaceCellDelegate Functions
//
extension SupplyChainTableViewController: PurchacePlaceCellDelegate {
    
    // function to let the delegate know that the tagListView has been doubletapped
    func purchacePlaceTableViewCell(_ sender: PurchacePlaceTableViewCell, receivedDoubleTapOn tagListView: TagListView) {
    }
}
//
// MARK: - TagListViewSegmentedControlCellDelegate Functions
//
extension SupplyChainTableViewController: TagListViewSegmentedControlCellDelegate {
    
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl: UISegmentedControl) {
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
        //static let Undefined = NSLocalizedString("undefined", comment: "tag of cell when no date was in off")
        //static let None = NSLocalizedString("none", comment: "tag of cell when no tags are available")
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
                return countTags(linksToDisplay)
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
                return linksToDisplay.tag(at:index)!
            default: break
        }
        return("error")
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
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
                productPair?.update(producer: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(producer: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .producerCode:
            switch producerCodeTagsToDisplay {
            case .undefined, .empty:
                productPair?.update(producerCode: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(producerCode: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .ingredientOrigin:
            switch ingredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                productPair?.update(ingredientsOrigin: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(ingredientsOrigin: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .store:
            switch storeTagsToDisplay {
            case .undefined, .empty:
                productPair?.update(stores: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(stores: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .location:
            switch purchaseLocationTagsToDisplay {
            case .undefined, .empty:
                productPair?.update(purchaseLocation: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(purchaseLocation: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .country:
            switch countriesToDisplay {
            case .undefined, .empty:
                productPair?.update(countries: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(countries: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        case .sites:
            switch linksToDisplay {
            case .undefined, .empty:
                productPair?.update(links: [title])
            case var .available(list):
                list.append(title)
                productPair?.update(links: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
        default:
            break
        }
        tableView.reloadData()
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
                productPair?.update(producer: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadData()
            
        case .producerCode:
            switch producerCodeTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(producerCode: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadData()
            
        case .ingredientOrigin:
            switch ingredientOriginLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(ingredientsOrigin: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadData()

        case .store:
            switch storeTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(stores: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadData()
            
        case .location:
            switch purchaseLocationTagsToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(purchaseLocation: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadData()
            
        case .country:
            switch countriesToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(countries: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadData()
            
        case .sites:
            switch linksToDisplay {
            case .undefined, .empty:
                assert(true, "How can I delete a tag when there are none")
            case var .available(list):
                guard index >= 0 && index < list.count else {
                    break
                }
                list.remove(at: index)
                productPair?.update(links: list)
            case .notSearchable:
                assert(true, "How can I add a tag when the field is non-editable")
            }
            tableView.reloadData()
        default:
            break
        }
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .country:
            switch productPair!.remoteProduct!.countriesInterpreted {
            case .available(let countries):
                delegate?.search(for: countries[index], in: .country)
            default:
                break
            }
            
        case .producerCode:
            switch productPair!.remoteProduct!.embCodesInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.embCodesInterpreted.tag(at:index), in: .producerCode)
            default:
                break
            }
            
        case .ingredientOrigin:
            switch productPair!.remoteProduct!.originsOriginal {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.originsOriginal.tag(at:index), in: .origin)
            default:
                break
            }

        case .location:
            switch productPair!.remoteProduct!.purchasePlacesOriginal {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.purchasePlacesOriginal.tag(at:index), in: .purchasePlace)
            default:
                break
            }
            
        case .producer:
            switch productPair!.remoteProduct!.manufacturingPlacesOriginal {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.manufacturingPlacesOriginal.tag(at:index), in: .manufacturingPlaces)
            default:
                break
            }
            
        case .store:
            switch productPair!.remoteProduct!.storesInterpreted {
            case .available:
                delegate?.search(for: productPair!.remoteProduct!.storesInterpreted.tag(at:index), in: .store)
            default:
                break
            }
        default:
            break
        }
    }
    
    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        switch currentProductSection {
        case .producer:
            switch producerTagsToDisplay {
            case .available:
                productPair?.update(producer: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .producerCode:
            switch producerCodeTagsToDisplay {
            case .available:
                productPair?.update(producerCode: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .ingredientOrigin:
            switch ingredientOriginLocationTagsToDisplay {
            case .available:
                productPair?.update(ingredientsOrigin: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .store:
            switch storeTagsToDisplay {
            case .available:
                productPair?.update(stores: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .location:
            switch purchaseLocationTagsToDisplay {
            case .available:
                productPair?.update(purchaseLocation: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .country:
            switch countriesToDisplay {
            case .available:
                productPair?.update(countries: [])
            default:
                assert(true, "How can I clear a tag when there are none")
            }
        case .sites:
            productPair?.update(links: [])
        default:
            break
        }
        tableView.reloadData()
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
        case .periodAfterOpening:
            // period after opening
            if let validText = textField.text {
                productPair?.update(periodAfterOpeningString: validText + " M")
                tableView.reloadData()
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
