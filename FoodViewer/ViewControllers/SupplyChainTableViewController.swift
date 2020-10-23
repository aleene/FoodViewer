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

    var coordinator: SupplyChainCoordinator? = nil

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
                if var list = productPair?.localProduct?.countriesTranslated.list {
                    if list.isEmpty,
                        let oldList = productPair?.remoteProduct?.countriesTranslated.list {
                        list = oldList
                    }
                    list = list.sorted(by: { $0 < $1 })
                    return Tags.init(list:list)
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
    
    fileprivate struct Constants {
        static let ViewControllerTitle = TranslatableStrings.SupplyChain
        static let NoExpirationDate = TranslatableStrings.NoExpirationDate
        struct CellHeight {
            static let TagListViewCell = CGFloat(27.0)
        }
        struct CellMargin {
            static let ContentView = CGFloat(11.0)
        }
    }

    // MARK: - Interface Functions
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
        
    fileprivate var tableStructure: [SectionType] = []

    fileprivate struct TableStructure {
        struct SectionHeader {
            static let Producer = TranslatableStrings.Producer
            static let ProducerCode = TranslatableStrings.ProductCodes
            static let IngredientOrigin = TranslatableStrings.IngredientOrigins
            static let Location = TranslatableStrings.PurchaseAddress
            static let Countries = TranslatableStrings.SalesCountries
            static let Stores = TranslatableStrings.Stores
            static let Map = TranslatableStrings.Map
            static let ExpirationDate = TranslatableStrings.ExpirationDate
            static let Sites = TranslatableStrings.ProductWebSites
            static let PAO = TranslatableStrings.PeriodAfterOpening
        }
        struct SectionSize {
            static let Producer = 1
            static let ProducerCode = 1
            static let IngredientOrigin = 1
            static let Location = 1
            static let Countries = 1
            static let Stores = 1
            static let MapSectionSize = 1
            static let ExpirationDate = 1
            static let Sites = 1
            static let PAO = 1
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    fileprivate enum SectionType {
        case ingredientOrigin(Int)
        case producer(Int)
        case producerCode(Int)
        case location(Int)
        case store(Int)
        case country(Int)
        case map(Int)
        case expirationDate(Int)
        case sites(Int)
        case periodAfterOpening(Int)
        
        var numberOfRows: Int {
            switch self {
            case .ingredientOrigin(let numberOfRows),
                 .producer(let numberOfRows),
                 .producerCode(let numberOfRows),
                 .location(let numberOfRows),
                 .store(let numberOfRows),
                 .country(let numberOfRows),
                 .map(let numberOfRows),
                 .expirationDate(let numberOfRows),
                 .sites(let numberOfRows),
                 .periodAfterOpening(let numberOfRows):
                return numberOfRows
            }
        }

    }
    
    private var tagListViewHeight: [Int:CGFloat] = [:]

    fileprivate func setupTableSections() -> [SectionType] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        var sectionsAndRows: [SectionType] = []
        
        switch currentProductType {
        case .beauty:
            sectionsAndRows.append(.periodAfterOpening(TableStructure.SectionSize.PAO))
        default:
            sectionsAndRows.append(.expirationDate(TableStructure.SectionSize.ExpirationDate))
        }
        // ingredient origin section
        sectionsAndRows.append(.ingredientOrigin(TableStructure.SectionSize.IngredientOrigin))
        tagListViewHeight[1] = Constants.CellHeight.TagListViewCell
        // producer section
        sectionsAndRows.append(.producer(TableStructure.SectionSize.Producer))
        tagListViewHeight[2] = Constants.CellHeight.TagListViewCell
        // producer codes section
        sectionsAndRows.append(.producerCode(TableStructure.SectionSize.ProducerCode))
        tagListViewHeight[3] = Constants.CellHeight.TagListViewCell
        // producer sites
        sectionsAndRows.append(.sites(TableStructure.SectionSize.Sites))
        tagListViewHeight[4] = Constants.CellHeight.TagListViewCell
        // stores section
        sectionsAndRows.append(.store(TableStructure.SectionSize.Stores))
        tagListViewHeight[5] = Constants.CellHeight.TagListViewCell
        // purchase Location section
        sectionsAndRows.append(.location(TableStructure.SectionSize.Location))
        tagListViewHeight[6] = Constants.CellHeight.TagListViewCell
        // countries section
        sectionsAndRows.append(.country(TableStructure.SectionSize.Countries))
        tagListViewHeight[7] = Constants.CellHeight.TagListViewCell
        //sectionsAndRows.append((
        //    SectionType.map,
        //    TableStructure.MapSectionSize,
        //    TableStructure.MapSectionHeader))
        return sectionsAndRows
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        // we assume that product exists
        switch tableStructure[indexPath.section] {
        case .producer, .producerCode, .sites, .ingredientOrigin:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
            return cell
            
        case .country:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Countries." + cellIdentifier(for: TagListViewButtonTableViewCell.self), for: indexPath) as! TagListViewButtonTableViewCell
            cell.setup(datasource: self, delegate: self, showButton: !editMode, width: tableView.frame.size.width, tag: indexPath.section)
            return cell

        case .store,
             .location:
            // The cell type has a button image and action specific for purchase place favorites
            let cell = tableView.dequeueReusableCell(withIdentifier: "PurchasePlaces." + cellIdentifier(for: TagListViewButtonTableViewCell.self), for: indexPath) as! TagListViewButtonTableViewCell
            cell.setup(datasource: self, delegate: self, showButton: !editMode, width: tableView.frame.size.width, tag: indexPath.section)
            return cell

        case .map:
            // This is just have some harmless code here
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.setup(datasource: self, delegate: self, width: tableView.frame.size.width, tag: indexPath.section)
            return cell
            
        case .expirationDate:
            if productPair != nil,
                productPair!.barcodeType.productType == .beauty {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:UITableViewCell.self), for: indexPath)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:ExpirationDateTableViewCell.self), for: indexPath) as! ExpirationDateTableViewCell
                var date: Date?
                switch productVersion {
                case .new:
                    date = productPair?.localProduct?.expirationDate ?? productPair?.remoteProduct?.expirationDate
                default:
                    date = productPair?.remoteProduct?.expirationDate
                }
                cell.setup(date: date,
                    delegate: self,
                    showButton: editMode,
                    width: self.tableView.frame.size.width,
                    tag: indexPath.section)
                return cell
            }
        case .periodAfterOpening:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:PeriodAfterOpeningTableViewCell.self), for: indexPath) as! PeriodAfterOpeningTableViewCell
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
        var header = ""
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LanguageHeaderView.identifier) as! LanguageHeaderView
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        headerView.changeLanguageButton.isHidden = true
        headerView.buttonNotDoubleTap = buttonNotDoubleTap

        switch tableStructure[section] {
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
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let validView = view as? LanguageHeaderView {
            validView.willDisappear()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        default:
            let height = tagListViewHeight[indexPath.section] ?? Constants.CellHeight.TagListViewCell
            return height + 2 * Constants.CellMargin.ContentView
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewButtonTableViewCell {
            validCell.willDisappear()
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
        coordinator = SupplyChainCoordinator.init(with: self)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableStructure = setupTableSections()
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name: .ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SupplyChainTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(SupplyChainTableViewController.refreshProduct),
            name: .ProductPairLocalStatusChanged, object:nil)
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
// MARK: - TagListViewButtonTableViewCellDelegate Functions
//
extension SupplyChainTableViewController : TagListViewButtonCellDelegate {
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedTapOn button:UIButton) {
        switch tableStructure[sender.tag] {
        case .store,
             .location:
            coordinator?.selectFavoriteShop(for: self.productPair)
        case .country:
            coordinator?.selectCountry(for: self.productPair)
        default:
            break
        }
    }

}
extension SupplyChainTableViewController :  ExpirationDateTableViewDelegate {
    
    func expirationDateTableViewCell(_ sender: ExpirationDateTableViewCell, receivedTapOn button:UIButton) {
        coordinator?.selectExpirationDate(for: self.productPair, anchoredOn:button)
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
// MARK: - UIPopoverPresentationControllerDelegate Functions
//
extension SupplyChainTableViewController: UIPopoverPresentationControllerDelegate {
        
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
//
// MARK: - TagListView DataSource Functions
//
extension SupplyChainTableViewController: TagListViewDataSource {
        
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ inputTags: [String]?) -> Int {
            if let tags = inputTags {
                if tags.isEmpty {
                    return editMode ? 0 : 1
                } else {
                    return tags.count
                }
            } else {
                return editMode ? 0 : 1
            }
        }
        
        func countTags(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                return editMode ? 0 : 1
            case .empty:
                return editMode ? 0 : 1
            case let .available(list):
                return list.count
            case .notSearchable:
                return 1
            }
        }

        switch tableStructure[tagListView.tag] {
            case .producer:
                return countTags(producerTagsToDisplay)
            case .producerCode:
                guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .packagerCode),
                    let validTags = editMode
                    ? producerCodeTagsToDisplay
                    : Tags.add(right: producerCodeTagsToDisplay,
                                             left: Tags(list:questions.map({ $0.value ?? "No value" })))
                else {
                    return countTags(.undefined)
                }
                return countTags(validTags)

            case .ingredientOrigin:
                return countTags(ingredientOriginLocationTagsToDisplay)
            case .store:
                guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .store),
                    let validTags = editMode
                    ? storeTagsToDisplay
                    : Tags.add(right: storeTagsToDisplay,
                                             left: Tags(list:questions.map({ $0.value ?? "No value" })))
                else {
                    return countTags(.undefined)
                }
                return countTags(validTags)

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
        
        switch tableStructure[tagListView.tag] {
            case .producer:
                return producerTagsToDisplay.tag(at:index)!
            case .producerCode:
                guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .packagerCode),
                    let validTags = editMode
                    ? producerCodeTagsToDisplay
                    : Tags.add(right: producerCodeTagsToDisplay,
                                             left: Tags(list:questions.map({ $0.value ?? "No value" }))) else { return "" }
                return validTags.tag(at:index)!

            case .ingredientOrigin:
                return ingredientOriginLocationTagsToDisplay.tag(at:index)!
            case .store:
                guard let questions = productPair?.remoteProduct?.robotoffQuestions(for: .store),
                    let validTags = editMode
                    ? storeTagsToDisplay
                    : Tags.add(right: storeTagsToDisplay,
                                             left: Tags(list:questions.map({ $0.value ?? "No value" }))) else { return "" }
                return validTags.tag(at:index)!

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
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        
        func colorScheme(_ tags: Tags) -> ColorScheme {
            switch tags {
            case .undefined, .notSearchable:
                return ColorSchemes.error
            case .empty:
                return ColorSchemes.none
            case let .available(list):
                if list[index].contains(":") {
                    return ColorScheme(text: .white, background: .systemOrange, border: .systemOrange)
                } else {
                    return ColorSchemes.normal
                }
            }
        }
        
        switch tableStructure[tagListView.tag] {
        case .producerCode:
            // Do I need to take into account any regular tags?
            if let count = producerCodeTagsToDisplay.count,
            index <= count - 1 {
                return colorScheme(producerCodeTagsToDisplay)
            } else {
                if !editMode,
                    let questions = productPair?.remoteProduct?.robotoffQuestions(for: .packagerCode), !questions.isEmpty {
                    return ColorSchemes.robotoff
                } else {
                    return colorScheme(producerCodeTagsToDisplay)
                }
            }
            
        case .store:
            // Do I need to take into account any regular tags?
            if let count = storeTagsToDisplay.count,
            index <= count - 1 {
                return colorScheme(storeTagsToDisplay)
            } else {
                if !editMode,
                    let questions = productPair?.remoteProduct?.robotoffQuestions(for: .store), !questions.isEmpty {
                    return ColorSchemes.robotoff
                } else {
                    return colorScheme(storeTagsToDisplay)
                }
            }
        case .country:
            return colorScheme(countriesToDisplay)
        case .ingredientOrigin:
            return colorScheme(ingredientOriginLocationTagsToDisplay)
        case .producer:
            return colorScheme(producerTagsToDisplay)
        case .location:
            return colorScheme(purchaseLocationTagsToDisplay)
        case .sites:
            return colorScheme(linksToDisplay)
        default:
            return nil
        }
    }

    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        if let cellHeight = tagListViewHeight[tagListView.tag],
            abs(cellHeight - height) > CGFloat(3.0) {
            tagListViewHeight[tagListView.tag] = height
            tableView.setNeedsLayout()
        }
    }
}

// MARK: - TagListView Delegate Functions

extension SupplyChainTableViewController: TagListViewDelegate {    
    
    func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool {
        return editMode
    }
    
    func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool {
        switch tableStructure[tagListView.tag] {
        case .producer,
             .producerCode,
             .ingredientOrigin,
             .store,
             .location,
             .sites:
            return editMode
        // .country can not be added by hand
        default:
            break
        }
        return false
    }
        
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
        switch tableStructure[tagListView.tag] {
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
        switch tableStructure[tagListView.tag] {
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
    
    public func tagListView(_ tagListView: TagListView, canTapTagAt index: Int) -> Bool {
        
        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("SupplychainTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return false
        }
        guard !editMode else { return false }

        switch tableStructure[tagListView.tag] {
        case .producerCode:
            // Do I need to take into account any regular tags?
            if let count = producerCodeTagsToDisplay.count {
                if index <= count - 1 {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        case .store:
            // Do I need to take into account any regular tags?
            if let count = storeTagsToDisplay.count {
                if index <= count - 1 {
                    return false
                } else {
                    return true
                }
            } else {
                return true
            }
        default:
            return false
        }

    }

    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
        
        func askQuestion(for type: RobotoffQuestionType, at index:Int) {
            guard let question = productPair?.remoteProduct?.robotoffQuestions(for: type)[index] else { return }
            var image: ProductImageSize?
            if let validID = question.imageID {
                if let validImages = productPair?.remoteProduct?.images {
                    image = validImages[validID]
                }
            }
            coordinator?.showQuestion(for: productPair, question: question, image: image)
        }

        guard tagListView.tag >= 0 && tagListView.tag < tableStructure.count else {
            print ("IngredientsTableViewController: tag index out of bounds", tagListView.tag, tableStructure.count - 1)
            return
        }
        guard !editMode else { return }

        switch tableStructure[tagListView.tag] {
        case .producerCode:
            // Do I need to take into account any regular tags?
            if let count = producerCodeTagsToDisplay.count {
                if index <= count - 1 {
                    return
                } else {
                    askQuestion(for: .category, at: index - count)
                }
            } else {
                askQuestion(for: .category, at: index)
            }
        case .store:
            // Do I need to take into account any regular tags?
            if let count = storeTagsToDisplay.count {
                if index <= count - 1 {
                    return
                } else {
                    askQuestion(for: .category, at: index - count)
                }
            } else {
                askQuestion(for: .category, at: index)
            }
        default:
            return
        }
    }

    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
        
        switch tableStructure[tagListView.tag] {
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
    public func didDeleteAllTags(_ tagListView: TagListView) {
        switch tableStructure[tagListView.tag] {
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
        switch tableStructure[textField.tag] {
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

