//
//  NutrientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices


class NutrientsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                refreshInterface()
            }
        }
    }
    
    fileprivate var adaptedNutritionFacts: [DisplayFact] = []
    
    // setup the current display modes to app wide defaults
    fileprivate var currentNutritionQuantityDisplayMode: NutritionDisplayMode = .perStandard
    fileprivate var currentEnergyDisplayMode = Preferences.manager.showCaloriesOrJoule
    fileprivate var currentSaltDisplayMode = Preferences.manager.showSaltOrSodium
    fileprivate var currentTableStyleSetter = Preferences.manager.nutritionFactsTableStyleSetter
    fileprivate var currentNutritionFactsTableStyle: NutritionFactsLabelStyle {
        switch currentTableStyleSetter {
        case .product:
            return productPair?.product?.bestNutritionFactTableStyle ?? Preferences.manager.showNutritionFactsTableStyle
        case .user:
            return selectedNutritionFactsTableStyle ?? Preferences.manager.showNutritionFactsTableStyle
        }
    }
    fileprivate var selectedNutritionFactsTableStyle: NutritionFactsLabelStyle? = nil
    
    fileprivate var nutritionFactsTagTitle: String = ""

    private var selectedIndexPath: IndexPath? = nil
    
    fileprivate enum ProductVersion {
        //case local
        case remote
        case new
        
        var isRemote: Bool {
            switch self {
            case .remote:
                return true
            default:
                return false
            }
        }
    }
    

    // Determines which version of the product needs to be shown, the remote or local
    
    fileprivate var productVersion: ProductVersion = .new

    struct DisplayFact {
        var name: String? = nil
        var value: String? = nil
        var unit: NutritionFactUnit? = nil
        var nutrient: Nutrient = .undefined
    }

    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
    
    private var type: ProductType? {
        return productPair?.remoteProduct?.type ?? productPair?.localProduct?.type
    }
    

    private var editMode: Bool {
        return delegate?.editMode ?? false
    }

    private var currentLanguageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
        set {
            delegate?.currentLanguageCode = newValue
        }
    }
    
    // This variable defined the languageCode that must be used to display the product data
    // It first does a validity check
    private var displayLanguageCode: String? {
        get {
            return currentLanguageCode ?? productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
        }
    }
    
    // This var finds the language that must be used to display the product
    private var newCurrentLanguage: String? {
        return productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }
    
    private func adaptNutritionFacts(_ facts: [String:NutritionFactItem]) -> [DisplayFact] {
        var displayFacts: [DisplayFact] = []
        for fact in facts {
            var newFact: NutritionFactItem? = nil

            // if the validFact is sodium or salt, add either one to the list of facts, but not both
            if fact.key == NatriumChloride.salt.key {
                switch currentSaltDisplayMode {
                // do not show sodium
                case .sodium: break
                default:
                    newFact = fact.value
                }
            } else if fact.key == NatriumChloride.sodium.key {
                switch currentSaltDisplayMode {
                // do not show salt
                case .salt: break
                default:
                    newFact = fact.value
                }
            } else if fact.key == LocalizedEnergy.key {
                switch currentEnergyDisplayMode {
                // show energy as Calories (US)
                case .calories:
                    newFact = NutritionFactItem.init(
                            name: EnergyUnitUsed.calories.description(),
                                                             standard: fact.value.valueInCalories(fact.value.standardValue),
                                                             serving: fact.value.valueInCalories(fact.value.servingValue),
                                                             unit: EnergyUnitUsed.calories.unit(),
                                                             nutrient: .energy)
                // show energy as kcalorie
                case .kilocalorie:
                    newFact = NutritionFactItem.init(name: EnergyUnitUsed.kilocalorie.description(),
                                                             standard: fact.value.valueInCalories(fact.value.standardValue),
                                                             serving: fact.value.valueInCalories(fact.value.servingValue),
                                                             unit: EnergyUnitUsed.kilocalorie.unit(),
                                                             nutrient: .energy)
                case .joule:
                    // this assumes that fact is in Joule
                    newFact = fact.value
                }
            } else {
                newFact = fact.value
            }
            if let finalFact = newFact {
                let validDisplayFact = localizeFact(finalFact)
                displayFacts.append(validDisplayFact)
            }
        }
        let orderedFacts = order(displayFacts)
        return orderedFacts
    }
    
    private func order(_ facts: [DisplayFact]) -> [DisplayFact] {
        let label = currentNutritionFactsTableStyle
        var orderedFacts: [DisplayFact] = []
        for key in label.keys {
            if let index = facts.firstIndex(where: { $0.nutrient.key == key.rawValue } ) {
                orderedFacts.append(facts[index])
            }
        }
        return orderedFacts
    }
    
    // transform the nutrition fact values to values that must be displayed
    fileprivate func localizeFact(_ fact: NutritionFactItem) -> DisplayFact {
        var displayFact = DisplayFact()
        displayFact.name = fact.itemName
        switch currentNutritionQuantityDisplayMode {
        case .perStandard:
            let localizedValue = fact.localeStandardValue(editMode: editMode)
            displayFact.value = fact.standardValue != nil ? localizedValue : ""
            displayFact.unit = fact.standardValueUnit
        case .perThousandGram:
            let localizedValue = fact.localeThousandValue(editMode: editMode)
            displayFact.value = fact.standardValue != nil ? localizedValue : ""
            switch fact.nutrient {
            case .fat, .proteins, .fiber:
                displayFact.unit = .Percent
            default:
                displayFact.unit = .Gram
            }
        case .perServing:
            displayFact.value = fact.servingValue != nil ? fact.localeServingValue(editMode: editMode) : ""
            displayFact.unit = fact.servingValueUnit
        case .perDailyValue:
            displayFact.value = fact.dailyFractionPerServing != nil ? fact.localeDailyValue : ""
            displayFact.unit = NutritionFactUnit.None // The numberformatter already provides a % sign
        }
        displayFact.nutrient = fact.nutrient
        return displayFact
    }
    
    // The functions creates a mixed array of edited and unedited nutrients
    
    fileprivate func mergeNutritionFacts() {
        switch productVersion {
        case .remote:
            adaptedNutritionFacts = adaptNutritionFacts(productPair?.remoteProduct?.nutritionFactsDict ?? [:])
        //case .local:
        //    adaptedNutritionFacts = adaptNutritionFacts(productPair?.localProduct?.nutritionFactsDict ?? [:])
        case .new:
            // merge the two dictionaries, the local version wins!
            let facts = productPair?.remoteProduct?.nutritionFactsDict.merging(productPair?.localProduct?.nutritionFactsDict ?? [:]) { (_, new) in new }
            adaptedNutritionFacts = adaptNutritionFacts(facts ?? [:])
        }

    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let NutritionFact = "Nutrition Fact Cell"
            static let ServingSize = "Serving Size Cell"
            // static let NoServingSize = "No Serving Size Cell"
            static let Image = "Nutrition Facts Image Cell"
            //static let EmptyNutritionFacts = "Empty Nutrition Facts Image Cell"
            static let NoImage = "No Nutrition Image Cell"
            static let AddNutrient = "Add Nutrient Cell"
            static let PerUnit = "Per Unit Cell"
            static let NoNutrimentsAvailable = "Nutriments Available Cell"
            static let SearchNutritionFact = "Search Nutrition Fact Cell Identifier"
            static let TagListView = "Nutrition TagListView Cell"
            static let TagListViewAddImage = "Nutrition TagListView Add Image Cell"
        }
        
        struct SegueIdentifier {
            static let ShowNutritionFactsImage = "Show Nutrition Facts Image"
            static let AddNutrient = "Add Nutrient Segue"
            static let SelectNutrientUnit = "Select Nutrient Unit Segue"
            static let SelectNutrientUnitForSearch = "Select Nutrient Unit For Search Nutrition Fact Segue Identifier"
            static let ShowNutritionImageLanguages = "Show Nutrition Image Languages"
            static let SelectComparisonOperator = "Show Select Comparison Operator Segue Identifier"
            static let ShowNutritionFactsTableStyles = "Show Select Nutrition Table Style Segue Identifier"
        }
        struct Title {
            static let ShowNutritionFactsImage = TranslatableStrings.Image
            static let ViewController = TranslatableStrings.NutritionFacts
        }
        static let PortionTag = 100
    }
    
    // fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    fileprivate var tableStructure: [SectionType] = []

    // The different sections of the tableView
    fileprivate enum SectionType {
        case perUnit(Int)
        case nutritionFacts(Int)
        case addNutrient(Int)
        case servingSize(Int)
        case image(Int)
        case noNutrimentsAvailable(Int)
        
        var numberOfRows: Int {
            switch self {
            case .perUnit(let numberOfRows),
                 .nutritionFacts(let numberOfRows),
                 .addNutrient(let numberOfRows),
                 .servingSize(let numberOfRows),
                 .image(let numberOfRows),
                 .noNutrimentsAvailable(let numberOfRows):
                return numberOfRows
            }
        }

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections
        return tableStructure.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // in editMode the nutritionFacts have a button added
        switch tableStructure[section] {
        case .nutritionFacts(let numberOfRows):
            if editMode {
                return numberOfRows + 1
            }
        default:
            break
        }
        return tableStructure[section].numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var nutritionFactRow: Int {
            return  indexPath.row - ( editMode ? 1 : 0 )
        }
        
        // we assume that product exists
        switch tableStructure[indexPath.section] {
            
        case .noNutrimentsAvailable:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoNutrimentsAvailable, for: indexPath) as! NutrimentsAvailableTableViewCell
            cell.editMode = editMode
            if productPair?.localProduct?.nutrimentFactsAvailability != nil {
                cell.editMode = productVersion.isRemote ? false : true
            }

            cell.delegate = self
            switch productVersion {
            //case .local:
            //    cell.hasNutrimentFacts = productPair?.localProduct?.nutrimentFactsAvailability
            case .remote:
                cell.hasNutrimentFacts = productPair?.remoteProduct?.nutrimentFactsAvailability
            case .new:
                cell.hasNutrimentFacts = productPair?.localProduct?.nutrimentFactsAvailability ?? productPair?.remoteProduct?.nutrimentFactsAvailability
            }
            return cell
            
        case .perUnit:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.PerUnit, for: indexPath) as! PerUnitTableViewCell
            cell.displayMode = currentNutritionQuantityDisplayMode
            cell.editMode = editMode
            if productPair?.localProduct?.nutritionFactsIndicationUnit != nil {
                cell.editMode = productVersion.isRemote ? false : true
            }

            cell.delegate = self
            switch productVersion {
            //case .local:
            //    cell.nutritionFactsAvailability = productPair?.localProduct?.nutritionFactsAreAvailable
            case .remote:
                cell.nutritionFactsAvailability = productPair?.remoteProduct?.nutritionFactsAreAvailable
            case .new:
                cell.nutritionFactsAvailability = productPair?.localProduct?.nutritionFactsAreAvailable ?? productPair?.remoteProduct?.nutritionFactsAreAvailable
            }
            return cell
            
        case .nutritionFacts:
            if indexPath.row == tableStructure[indexPath.section].numberOfRows && editMode {
                // This cell should only be added when in editMode and as the last row
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.AddNutrient, for: indexPath) as! AddNutrientTableViewCell
                cell.delegate = self
                cell.buttonText = TranslatableStrings.AddNutrient
                return cell
            } else {
                if adaptedNutritionFacts.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as? TagListViewTableViewCell
                    cell?.tag = indexPath.section
                    cell?.width = tableView.frame.size.width
                    cell?.datasource = self
                    if let available = productPair?.remoteProduct?.nutritionFactsAreAvailable {
                        nutritionFactsTagTitle = available.description()
                        switch available {
                        case .perServing, .perStandardUnit, .perServingAndStandardUnit:
                            cell?.scheme = ColorSchemes.normal
                        case .notOnPackage:
                            cell?.scheme = ColorSchemes.error
                        case .notIndicated, .notAvailable:
                            cell?.scheme = ColorSchemes.error
                        }
                    } else {
                        nutritionFactsTagTitle = NutritionAvailability.notIndicated.description()
                        cell?.scheme = ColorSchemes.error
                    }
                    return cell!
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionFact, for: indexPath) as? NutrientsTableViewCell
                    // warning set FIRST the saltOrSodium
                    cell?.nutritionDisplayFactItem = adaptedNutritionFacts[indexPath.row]
                    cell?.delegate = self
                    cell?.tag = indexPath.section * 100 + indexPath.row
                    let buttonNotDoubleTap = ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault

                    // only add taps gestures when NOT in editMode
                    // and when a button is NOT required
                    if  (adaptedNutritionFacts[indexPath.row].nutrient.rawValue ==   NatriumChloride.salt.key) ||
                           (adaptedNutritionFacts[indexPath.row].nutrient.rawValue == NatriumChloride.sodium.key) {
                        if !editMode && !buttonNotDoubleTap {
                            let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:  #selector(NutrientsTableViewController.doubleTapOnSaltSodiumTableViewCell))
                            doubleTapGestureRecognizer.numberOfTapsRequired = 2
                            doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                            doubleTapGestureRecognizer.cancelsTouchesInView = false
                            doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                            cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                        }
                        cell?.toggleViewModeButton.isHidden = editMode ? true : !buttonNotDoubleTap
                    } else if  (adaptedNutritionFacts[indexPath.row].nutrient.key == LocalizedEnergy.key) ||
                        (adaptedNutritionFacts[indexPath.row].nutrient.key == LocalizedEnergy.key) {
                        if !editMode && !buttonNotDoubleTap {
                            let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnEnergyTableViewCell))
                            doubleTapGestureRecognizer.numberOfTapsRequired = 2
                            doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                            doubleTapGestureRecognizer.cancelsTouchesInView = false
                            doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                            cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                        }
                        cell?.toggleViewModeButton.isHidden = editMode ? true : !buttonNotDoubleTap
                    } else {
                        cell?.toggleViewModeButton.isHidden = true
                    }
                    cell?.editMode = editMode
                    if let facts = productPair?.localProduct?.nutritionFactsDict,
                        !facts.isEmpty {
                        cell?.editMode = productVersion.isRemote ? false : true
                    }

                    return cell!
                }
            }

        case .servingSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ServingSize, for: indexPath) as! ServingSizeTableViewCell
            cell.servingSizeTextField.delegate = self
            cell.servingSizeTextField.tag = indexPath.section
            cell.editMode = editMode
            switch productVersion {
            //case .local:
            //    cell.servingSize = productPair?.localProduct?.servingSize
            case .remote:
                cell.servingSize = productPair?.remoteProduct?.servingSize
            case .new:
                cell.servingSize = productPair?.localProduct?.servingSize ?? productPair?.remoteProduct?.servingSize
            }
            return cell

        case .image:
            if currentImage != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                cell.productImage = currentImage
                cell.delegate = self
                return cell
            } else {
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListViewAddImage, for: indexPath) as! TagListViewAddImageTableViewCell
                cell.width = tableView.frame.size.width
                cell.scheme = ColorSchemes.error
                cell.editMode = editMode
                cell.datasource = self
                cell.delegate = self
                cell.tag = indexPath.section
                cell.accessoryType = .none
                return cell
            }

        case .addNutrient:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.AddNutrient, for: indexPath) as! AddNutrientTableViewCell
            cell.buttonText = TranslatableStrings.AddNutrient
            return cell
        }
    }
    
    private var currentImage: UIImage? {
        switch productVersion {
        //case .local:
        //    return localImageToShow
        case .remote:
            return remoteImageToShow
        case .new:
            return localImageToShow ?? remoteImageToShow
        }
    }
    
    private var localImageToShow: UIImage? {
        if let images = productPair?.localProduct?.nutritionImages,
            !images.isEmpty,
            let validLanguageCode = displayLanguageCode,
            // Is there an updated image corresponding to the current language
            let fetchResult = images[validLanguageCode]?.original?.fetch() {
            switch fetchResult {
            case .success(let image):
                return image
            default:
                break
            }
        }
        return nil
    }
    
    private var remoteImageToShow: UIImage? {
        // are there any updated nutrition images?
        if  let images = productPair?.remoteProduct?.nutritionImages,
            !images.isEmpty,
            let validLanguageCode = displayLanguageCode,
            let result = images[validLanguageCode]?.display?.fetch() {
            switch result {
            case .success(let image):
                return image
            default:
                break
            }
            // fall back to the primary languagecode nutrition image
            // if we are NOT in edit mode
        } else if !editMode,
            let images = productPair?.remoteProduct?.nutritionImages,
            let primaryLanguageCode = productPair!.remoteProduct!.primaryLanguageCode,
            let result = images[primaryLanguageCode]?.display?.fetch() {
            switch result {
            case .success(let image):
                return image
            default:
                break
            }
        }
        return nil
    }

    private struct Header {
        static let FontSize = CGFloat(18.0)
        static let HorizontalOffSet = CGFloat(20.0)
        static let VerticalOffSet = CGFloat(4.0)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = ""
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }
        let currentProductSection = tableStructure[section]
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LanguageHeaderView") as! LanguageHeaderView
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        headerView.changeLanguageButton.isHidden = true
        headerView.buttonNotDoubleTap = nil

        switch currentProductSection {
        case .image :
            headerView.changeLanguageButton.isHidden = false
            switch productVersion {
            case .new:
                if localImageToShow != nil {
                    headerView.buttonNotDoubleTap = buttonNotDoubleTap
                    header = TranslatableStrings.NutritionFactsImageEdited
                } else {
                header = TranslatableStrings.NutritionFactsImage
                }
            default:
                header = TranslatableStrings.NutritionFactsImage
            }
            headerView.changeLanguageButton.tag = 0
            headerView.buttonText = OFFplists.manager.languageName(for: displayLanguageCode)
            headerView.buttonIsEnabled = editMode ? true : ( (productPair?.product?.languageCodes.count ?? 0) > 1 ? true : false )
            // add a dash to nice separate the title from the language button
            headerView.title = header + " - "
            return headerView
            
        case .nutritionFacts:
            headerView.changeLanguageButton.isHidden = false
            headerView.changeLanguageButton.tag = 1
            switch productVersion {
            case .new:
                if let facts = productPair?.localProduct?.nutritionFactsDict,
                    !facts.isEmpty {
                    headerView.buttonNotDoubleTap = buttonNotDoubleTap
                    header = TranslatableStrings.NutritionFactsEdited
                } else {
                    header = TranslatableStrings.NutritionFacts
                }
            default:
                header = TranslatableStrings.NutritionFacts
            }
            headerView.buttonText = currentNutritionFactsTableStyle.description
            headerView.buttonIsEnabled = true
            headerView.title = header + " - "
            return headerView
            
        case .servingSize:
            headerView.changeLanguageButton.isHidden = true
            switch productVersion {
            case .new:
                if productPair?.localProduct?.servingSize != nil {
                    headerView.buttonNotDoubleTap = buttonNotDoubleTap
                    header = TranslatableStrings.PortionSizeEdited
                } else {
                    header = TranslatableStrings.PortionSize
                }
            default:
                header = TranslatableStrings.PortionSize
            }
            headerView.title = header
            return headerView

        case .perUnit:
            headerView.changeLanguageButton.isHidden = true
            switch productVersion {
            case .new:
                if productPair?.localProduct?.nutritionFactsIndicationUnit != nil {
                    headerView.buttonNotDoubleTap = buttonNotDoubleTap
                    header = TranslatableStrings.PortionSizeEdited
                } else {
                    header = TranslatableStrings.PortionSize
                }
            default:
                header = TranslatableStrings.PortionSize
            }
            headerView.title = header
            return headerView

        case .noNutrimentsAvailable:
            headerView.changeLanguageButton.isHidden = true
            switch productVersion {
            case .new:
                if productPair?.localProduct?.nutrimentFactsAvailability != nil {
                    headerView.buttonNotDoubleTap = buttonNotDoubleTap
                    header = TranslatableStrings.NoNutrientsEdited
                } else {
                    header = TranslatableStrings.NoNutrients
                }
            default:
                header = TranslatableStrings.NoNutrients
            }
            headerView.title = header
            return headerView

        default:
            return nil
        }
    }
    
    private func setSupport(on view:UIView, forDoubleTap support:Bool) {
        // Add doubletapping to the TableView. Any double tap on headers is now received,
        // and used for changing the productVersion (local and remote)
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(IngredientsTableViewController.doubleTapOnTableView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
        // show the double tap possibility only if there is a local product
        doubleTapGestureRecognizer.cancelsTouchesInView = !support
        view.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section >= 0 && indexPath.section < tableStructure.count {
            switch tableStructure[indexPath.section] {
            case .image :
                return indexPath
            default:
                break
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    fileprivate struct TableSections {
        struct Size {
            static let NutritionFactsImage = 1
            static let ServingSize = 1
            static let NutritionFactsEmpty = 1
            static let AddNutrient = 1
            static let PerUnit = 1
            static let NutrimentsAvailable = 1
        }
    }
    
    @objc func doubleTapOnSaltSodiumTableViewCell() {
        currentSaltDisplayMode = currentSaltDisplayMode == .salt ? .sodium : .salt
        
        mergeNutritionFacts()
        tableView.reloadData()
    }
    
    @objc func doubleTapOnEnergyTableViewCell() {
        /////
        switch currentEnergyDisplayMode {
        case .calories:
            currentEnergyDisplayMode = .joule
        case .joule:
            currentEnergyDisplayMode = .kilocalorie
        case .kilocalorie:
            currentEnergyDisplayMode = .joule
        }
        
        mergeNutritionFacts()
        tableView.reloadData()

//        let sections = NSIndexSet.init(index: 0)
//        tableView.reloadSections(sections, withRowAnimation: .Fade)
    }
    
    fileprivate func setupTableSections() -> [SectionType] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [SectionType] = []
        
        
            // Which sections are shown depends on whether the product has nutriment data
        
            // Are there any nutriments in the product or the updatedProduct
            if !hasNutritionFacts {
                // the product has no nutriments indicated
                sectionsAndRows.append( .noNutrimentsAvailable(
                      TableSections.Size.NutrimentsAvailable )
                )
            } else {
            /*
                // how does the user want the data presented
                switch currentNutritionQuantityDisplayMode {
                case .perStandard:
                    guard let available = productPair?.product?.nutritionFactsAreAvailable else {
                        break
                    }
                    // what is possible?
                    switch available {
                    case .perStandardUnit, .perServingAndStandardUnit:
                        currentNutritionQuantityDisplayMode = .perStandard
                    case .perServing:
                        currentNutritionQuantityDisplayMode = .perServing
                    default:
                        break
                    }
                case .perServing:
                    guard let available = productPair?.product?.nutritionFactsAreAvailable else {
                        break
                    }
                    switch available {
                    // what is possible?
                    case .perStandardUnit:
                        currentNutritionQuantityDisplayMode = .perStandard
                    case .perServing, .perServingAndStandardUnit:
                        currentNutritionQuantityDisplayMode = .perServing
                    default:
                        break
                    }
                case .perDailyValue:
                    guard let available = productPair?.product?.nutritionFactsAreAvailable else {
                        break
                    }
                    switch available {
                    case .perStandardUnit:
                        // force showing perStandard as perServing is not available
                        currentNutritionQuantityDisplayMode = .perStandard
                    case .perServingAndStandardUnit:
                        currentNutritionQuantityDisplayMode = .perDailyValue
                    case .perServing:
                        currentNutritionQuantityDisplayMode = .perDailyValue
                    default:
                        break
                    }
                }
                 */
            
                // Section 0 : switch to indicate whether any nutritional data is available on the product
            
                if editMode {
                    sectionsAndRows.append( .noNutrimentsAvailable(
                          TableSections.Size.NutrimentsAvailable )
                    )
                }
            
                // Section 0 or 1 : presentation format
            
                if let validType = type {
                    switch validType {
                    case .food:
                        sectionsAndRows.append(.perUnit(
                            TableSections.Size.PerUnit )
                        )
                    default: break
                    }
                }
        
                // Section 1 or 2 : nutrition facts
            
                if adaptedNutritionFacts.isEmpty {
                    // Show a tag indicating no nutrition facts have been specified
                    sectionsAndRows.append(.nutritionFacts(
                        TableSections.Size.NutritionFactsEmpty))
                } else {
                    // show a list with nutrition facts
                    sectionsAndRows.append( .nutritionFacts(
                        adaptedNutritionFacts.count))
                }
        
                // Section 2 or 3 or 4 : serving size
            
                sectionsAndRows.append( .servingSize(
                    TableSections.Size.ServingSize))
        
                // Section 3 or 4 or 5: image section
                sectionsAndRows.append( .image(
                    TableSections.Size.NutritionFactsImage))
        
        }
        return sectionsAndRows
    }
    
    private var hasNutritionFacts: Bool {
        return productPair?.hasNutritionFacts ?? true
    }

    // MARK: - Segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.ShowNutritionImageLanguages:
                if let vc = segue.destination as? SelectLanguageViewController {
                    // The segue can only be initiated from a button within a ProductNameTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? NoNutrientsImageTableViewCell != nil ||
                            button.superview?.superview as? ProductImageTableViewCell != nil {
                            //if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                //ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                //let anchorFrame = button.convert(button.bounds, to: self.view)
                                //ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                //ppc.delegate = self
                                
                            vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                vc.currentLanguageCode = displayLanguageCode
                                vc.primaryLanguageCode = productPair?.localProduct?.primaryLanguageCode ?? productPair!.remoteProduct!.primaryLanguageCode
                                vc.languageCodes = productPair!.remoteProduct!.languageCodes
                                vc.updatedLanguageCodes = productPair?.localProduct?.languageCodes ?? []
                                vc.editMode = editMode
                                vc.productPair = productPair
                                vc.sourcePage = 2
                            //}
                            // The button should be in a view,
                            // which is in a TableHeaderFooterView,
                            // which is in a TableView
                        } else if button.superview?.superview?.superview as? UITableView != nil {
                            //if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                //ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                //let anchorFrame = button.convert(button.bounds, to: self.view)
                                //ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                //ppc.delegate = self
                                    
                            vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                vc.currentLanguageCode = displayLanguageCode
                                vc.primaryLanguageCode = productPair?.localProduct?.primaryLanguageCode ?? productPair!.remoteProduct!.primaryLanguageCode
                                vc.languageCodes = productPair!.remoteProduct!.languageCodes
                                vc.updatedLanguageCodes = productPair?.localProduct?.languageCodes ?? []
                                vc.editMode = editMode
                                vc.productPair = productPair
                                vc.sourcePage = 2
                            //}
                        }
                    }
                } else {
                    assert(true, "NutrientsTableViewController: ShowNutritionImageLanguages segue preparation wrongly configurated")
                }
            case Storyboard.SegueIdentifier.ShowNutritionFactsTableStyles:
                if let vc = segue.destination as? SelectNutritionFactsTableStyleTableViewCell {
                    // The segue can only be initiated from a button within a ProductNameTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? LanguageHeaderView != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                ppc.delegate = self
                                
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                vc.currentNutritionFactsTableStyle = self.currentNutritionFactsTableStyle
                                vc.editMode = self.editMode
                            }
                            // The button should be in a view,
                            // which is in a TableHeaderFooterView,
                            // which is in a TableView
                        }
                    }
                } else {
                    assert(true, "NutrientsTableViewController: ShowNutritionFactsTableStyles segue preparation wrongly configurated")
                }
            case Storyboard.SegueIdentifier.ShowNutritionFactsImage:
                if let vc = segue.destination as? ImageViewController,
                    let validLanguageCode = displayLanguageCode {
                    vc.imageTitle = Storyboard.Title.ShowNutritionFactsImage
                    if let images = productPair?.localProduct?.nutritionImages,
                        !images.isEmpty {
                        vc.imageData = productPair!.localProduct!.image(for:validLanguageCode, of:.nutrition)
                    } else {
                        vc.imageData = productPair!.remoteProduct!.image(for:validLanguageCode, of:.nutrition)
                    }
                } else {
                    assert(true, "NutrientsTableViewController: ShowNutritionFactsImage segue preparation wrongly configurated")
                }
            case Storyboard.SegueIdentifier.AddNutrient:
                if let vc = segue.destination as? AddNutrientViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview?.superview as? AddNutrientTableViewCell != nil {
                            //if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                //ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                //let anchorFrame = button.convert(button.bounds, to: self.view)
                                //ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                //ppc.delegate = self
                            vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                vc.existingNutrients = adaptedNutritionFacts.compactMap { $0.name }
                            //}
                        }
                    }
                } else {
                    assert(true, "NutrientsTableViewController: AddNutrient segue preparation wrongly configurated")
                }
                
            case Storyboard.SegueIdentifier.SelectNutrientUnit:
                if let vc = segue.destination as? SelectNutrientUnitViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview?.superview as? NutrientsTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                                let row = button.tag % 100
                                vc.nutrientRow = row
                                if row >= 0 && row < adaptedNutritionFacts.count {
                                    vc.currentNutritionFactKey = adaptedNutritionFacts[row].nutrient.key
                                }
                            }
                        }
                    }
                } else {
                    assert(true, "NutrientsTableViewController: SelectNutrientUnit segue preparation wrongly configurated")
                }
                /*
            case Storyboard.SegueIdentifier.SelectComparisonOperator:
                if let vc = segue.destination as? SelectCompareViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? SearchNutrientsTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                let row = button.tag % 100
                                vc.nutrientRow = row
                                if query != nil && row >= 0 && row < query!.allNutrimentsSearch.count  {
                                    vc.currentCompareOperator = query!.allNutrimentsSearch[row].searchOperator
                                }
                            }
                        }
                    }
                } else {
                    assert(true, "NutrientsTableViewController: SelectComparisonOperator segue preparation wrongly configurated")
                }
 */

            default: break
            }
        }
    }
    
    @IBAction func unwindAddNutrientForCancel(_ segue:UIStoryboardSegue) {
        // reload with first nutrient?
    }
    
    @IBAction func unwindAddNutrientForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? AddNutrientViewController {
            if let newNutrientTuple = vc.addedNutrientTuple {
                /*    var nutrimentSearch = NutrimentSearch()
                    nutrimentSearch.nutrient = newNutrientTuple.0 // key with en: prefix
                    nutrimentSearch.name = newNutrientTuple.1 // name in local language
                    nutrimentSearch.unit = newNutrientTuple.2 // default unit
                    query!.allNutrimentsSearch.append(nutrimentSearch)
                    tableView.reloadData()
                } else {*/
                    var newNutrient = NutritionFactItem()
                    newNutrient.nutrient = newNutrientTuple.0
                    newNutrient.itemName = newNutrientTuple.1
                    switch currentNutritionQuantityDisplayMode {
                    case .perServing:
                        newNutrient.servingValueUnit = newNutrientTuple.2
                    case .perStandard:
                        newNutrient.standardValueUnit = newNutrientTuple.2
                    default:
                        break
                    }
                    productPair?.update(fact: newNutrient)
                    refreshProduct()
                //}
            }
        }
    }
    
    @IBAction func unwindSetNutrientUnit(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectNutrientUnitViewController {
            // The new nutrient unit should be set to the nutrient that was edited
            if let nutrientRow = vc.nutrientRow {
                if productPair!.remoteProduct != nil {
                    // copy the existing nutrient and change the unit
                    var editedNutritionFact = NutritionFactItem()
                    editedNutritionFact.nutrient = adaptedNutritionFacts[nutrientRow].nutrient
                    editedNutritionFact.itemName = adaptedNutritionFacts[nutrientRow].name
                    // this value has been changed
                    switch currentNutritionQuantityDisplayMode {
                    case .perServing:
                        editedNutritionFact.servingValueUnit = vc.selectedNutritionUnit
                        editedNutritionFact.servingValue = adaptedNutritionFacts[nutrientRow].value
                    case .perStandard:
                        editedNutritionFact.standardValueUnit = vc.selectedNutritionUnit
                        editedNutritionFact.standardValue = adaptedNutritionFacts[nutrientRow].value
                    default:
                        break
                    }
                    productPair?.update(fact: editedNutritionFact)
                    refreshProduct()
                    /*
                } else if query != nil {
                    if let validUnit = vc.selectedNutritionUnit {
                        query!.allNutrimentsSearch[nutrientRow].unit = validUnit
                        tableView.reloadData()
                    }
*/                }
 
            }
        }
    }

    @IBAction func unwindSetNutritionFactsTableStyle(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectNutritionFactsTableStyleTableViewCell {
            // The user decided to not follow the global preferences
            currentTableStyleSetter = .user
            if let validSelectedNutritionFactsTableStyle = vc.selectedNutritionFactsTableStyle {
                selectedNutritionFactsTableStyle = validSelectedNutritionFactsTableStyle
                currentEnergyDisplayMode = validSelectedNutritionFactsTableStyle.energyUnit
                currentSaltDisplayMode = validSelectedNutritionFactsTableStyle.saltUnit
                switch validSelectedNutritionFactsTableStyle.entryUnit {
                case .perServing:
                    currentNutritionQuantityDisplayMode = .perServing
                default:
                    currentNutritionQuantityDisplayMode = .perStandard
                }
                // fill the nutritionList with the missing values
                if editMode {
                    for nutrient in validSelectedNutritionFactsTableStyle.mandatoryNutrients {
                        if !productPair!.remoteProduct!.nutritionFactsContain(nutrient) {
                            productPair?.update(fact: NutritionFactItem.init(nutrient: nutrient, unit: nutrient.unit(for:validSelectedNutritionFactsTableStyle)))
                        }
                    }
                }
                refreshProduct()
            }
        }
    }
/*
    @IBAction func unwindSetComparisonOperator(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectCompareViewController {
            // The new comparison operator should be set to the nutrient that was edited
            if let nutrientRow = vc.nutrientRow,
            let selectedOperator = vc.selectedCompareOperator {
                //query!.allNutrimentsSearch[nutrientRow].searchOperator = selectedOperator
                //tableView.reloadData()
            }
        }
    }
 */

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
    
    func takePhoto() {
        // opens the camera and allows the user to take an image and crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.delegate = self
            imagePicker.imagePickerController?.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .camera
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
    
    func selectCameraRollPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .savedPhotosAlbum
            
            
            imagePicker.delegate = self
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
//
// MARK: - Notification handlers
//
    @objc func refreshProduct() {
        guard productPair != nil else { return }
        refreshProductWithNewNutritionFacts()

    }
    
    func refreshInterface() {
        refreshProduct()
    }
    
    func newPerUnitSettings(_ notification: Notification) {
    }

    // The availability of nutriments on the product has changed
    func nutrimentsAvailabilitySet(_ notification: Notification) {
    }
    /*

    func showNutrimentSelector(_ notification: Notification) {
        if let sender = notification.userInfo?[AddNutrientTableViewCell.Notification.AddNutrientButtonTappedKey] {
            performSegue(withIdentifier: Storyboard.SegueIdentifier.AddNutrient, sender: sender)
        }
    }
    func showNutrimentUnitSelector(_ notification: Notification) {
        if let sender = notification.userInfo?[SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientUnitButtonTappedKey] {
            performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectNutrientUnit, sender: sender)
        }
    }
 */
    
    @objc func reloadImageSection() { // (_ notification: Notification) {
        //if let valid = imageSectionIndex {
            tableView.reloadData()
            //tableView.reloadSections([valid], with: .fade)
        //}
    }

    fileprivate var imageSectionIndex: Int? {
        for (index, sectionType) in tableStructure.enumerated() {
            switch sectionType {
            case .image:
                return index
            default:
                continue
            }
        }
        return nil
    }

    func refreshProductWithNewNutritionFacts() {
        guard productPair != nil else { return }
        // recalculate the nutritionfacts that must be shown
        mergeNutritionFacts()
        tableStructure = setupTableSections()
        tableView.reloadData()
    }
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        picker.imagePickerController!.modalPresentationStyle = .formSheet
        picker.sourceType = .savedPhotosAlbum
        // picker.mediaTypes = [kUTTypeImage as String] <
        return picker
    }()

    fileprivate func newImageSelected(info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        if image != nil,
            let validLanguageCode = displayLanguageCode {
            productPair?.update(nutritionImage: image!, for: validLanguageCode)
            tableView.reloadData()
        }
    }

    @objc func imageUpdated(_ notification: Notification) {
        guard !editMode else { return }
        let userInfo = (notification as NSNotification).userInfo
        guard userInfo != nil && imageSectionIndex != nil else { return }
        // only update if the image barcode corresponds to the current product
        if productPair!.barcodeType.asString == userInfo![ProductImageData.Notification.BarcodeKey] as? String {
            if userInfo!.count == 1 {
                reloadImageSection()
                return
            }
            
            // We are only interested in medium-sized front images
            if let otherValue = userInfo![ProductImageData.Notification.ImageTypeCategoryKey] as? Int,
                let imageTypeCategory = ImageTypeCategory(rawValue: otherValue),
                imageTypeCategory == .nutrition {
                reloadImageSection()
            }
        }
    }

    @objc func imageUploaded(_ notification: Notification) {
        guard !editMode else { return }
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String,
            let validProductPair = productPair,
            barcode == validProductPair.barcodeType.asString,
            let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String,
            id.contains(OFFHttpPost.AddParameter.ImageField.Value.Nutrition) {
                validProductPair.reload()
        }
    }
    
    
    @objc func imageDeleted(_ notification: Notification) {
        // Check if this image was relevant to this product
        if let barcode = notification.userInfo?[ProductPair.Notification.BarcodeKey] as? String {
            if barcode == productPair!.barcodeType.asString {
                // is it relevant to the nutrition image?
                if let id = notification.userInfo?[ProductPair.Notification.ImageTypeCategoryKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Nutrition) {
                        self.productPair?.reload()
                    }
                }
            }
        }
    }
    
    @objc func doubleTapOnTableView() {
        switch productVersion {
        case .remote:
            //productVersion = .local
            //delegate?.title = TranslatableStrings.NutritionFacts + " (Local)"
        //case .local:
            productVersion = .new
            //delegate?.title = TranslatableStrings.NutritionFacts + " (New)"
        case .new:
            productVersion = .remote
            //delegate?.title = TranslatableStrings.NutritionFacts + " (OFF)"
        }
        tableView.reloadData()
    }

//
// MARK: - ViewController Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableStructure = setupTableSections()
        if productPair != nil {
            mergeNutritionFacts()
            if let validType = type {
                switch validType {
                case .petFood:
                    currentNutritionQuantityDisplayMode = .perThousandGram
                default: break
                }
            }
        }
        refreshProduct()

        NotificationCenter.default.addObserver(
            self,
            selector:#selector(NutrientsTableViewController.refreshProduct),
            name: .ProductPairRemoteStatusChanged, object:nil
        )
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)

        // NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.removeProduct), name: .HistoryHasBeenDeleted, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)

        // delegate?.title = TranslatableStrings.NutritionFacts

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
        OFFplists.manager.flush()
    }

}

extension NutrientsTableViewController: NutrientsCellDelegate {

    func nutrientsTableViewCell(_ sender: NutrientsTableViewCell, receivedTapOn button:UIButton) {
        // depending on the cell, a button might be present
        // and an other action will invoked
        let row = button.tag % 100
        // only add taps gestures when NOT in editMode
        if !editMode {
            if  (adaptedNutritionFacts[row].nutrient.rawValue ==   NatriumChloride.salt.key) ||
                (adaptedNutritionFacts[row].nutrient.rawValue == NatriumChloride.sodium.key) {
                doubleTapOnSaltSodiumTableViewCell()
            } else if  (adaptedNutritionFacts[row].nutrient.key == LocalizedEnergy.key) ||
                (adaptedNutritionFacts[row].nutrient.key == LocalizedEnergy.key) {
               doubleTapOnEnergyTableViewCell()
            }
        }

    }

}
//
// MARK: - AddNutrientCellDelegate functions
//
extension NutrientsTableViewController:  AddNutrientCellDelegate {
    
    // function to let the delegate know that the switch changed
    func addEUNutrientSetTableViewCell(_ sender: AddNutrientTableViewCell, receivedTapOn button:UIButton) {
        
        // Energy
        if !productPair!.remoteProduct!.nutritionFactsContain(.energy) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .energy, unit: .Joule))
        }
        // Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.fat) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .fat, unit: .Gram))
        }
        // Saturated Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.saturatedFat) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .saturatedFat, unit: .Gram))
        }
        // Carbohydrates
        if !productPair!.remoteProduct!.nutritionFactsContain(.carbohydrates) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .carbohydrates, unit: .Gram))
        }
        // Sugars
        if !productPair!.remoteProduct!.nutritionFactsContain(.sugars) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .sugars, unit: .Gram))
        }
        // Fibers
        if !productPair!.remoteProduct!.nutritionFactsContain(.fiber) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .fiber, unit: .Gram))
        }
        // Proteins
        if !productPair!.remoteProduct!.nutritionFactsContain(.proteins) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .proteins, unit: .Gram))
        }
        // Salt
        if !productPair!.remoteProduct!.nutritionFactsContain(.salt) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .salt, unit: .Gram))
        }
        refreshProduct()
    }
    
    // function to let the delegate know that the switch changed
    func addUSNutrientSetTableViewCell(_ sender: AddNutrientTableViewCell, receivedTapOn button:UIButton) {
        
        // US data must be perServing
        currentNutritionQuantityDisplayMode = .perServing
        currentEnergyDisplayMode = .calories
        currentSaltDisplayMode = .sodium
        
        // Energy
        if !productPair!.remoteProduct!.nutritionFactsContain(.energy) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .energy, unit: .Calories))
        }
        // Energy from Fat Old Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.energyFromFat) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .energyFromFat, unit: .Calories))
        }

        // Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.fat) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .fat, unit: .Gram))
        }
        // Saturated Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.saturatedFat) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .saturatedFat, unit: .Gram))
        }
        // Trans Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.transFat) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .transFat, unit: .Gram))
        }

        // Cholesterol
        if !productPair!.remoteProduct!.nutritionFactsContain(.cholesterol) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .cholesterol, unit: .Milligram))
        }
        // Sodium
        if !productPair!.remoteProduct!.nutritionFactsContain(.sodium) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .sodium, unit: .Gram))
        }
        // Total Carbohydrates
        if !productPair!.remoteProduct!.nutritionFactsContain(.carbohydrates) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .carbohydrates, unit: .Gram))
        }
        // Dietary Fiber
        if !productPair!.remoteProduct!.nutritionFactsContain(.fiber) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .fiber, unit: .Gram))
        }

        // Sugars
        if !productPair!.remoteProduct!.nutritionFactsContain(.sugars) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .sugars, unit: .Gram))
        }
        // Added Sugars New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.addedSugars) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .addedSugars, unit: .Gram))
        }

        // Proteins
        if !productPair!.remoteProduct!.nutritionFactsContain(.proteins) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .proteins, unit: .Gram))
        }
        // Vitamin A New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.vitaminA) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .vitaminA, unit: .Percent))
        }
        // Vitamin C Old Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.vitaminC) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .vitaminC, unit: .Percent))
        }
        // Vitamin D New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.vitaminD) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .vitaminD, unit: .Percent))
        }

        // Calcium
        if !productPair!.remoteProduct!.nutritionFactsContain(.calcium) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .calcium, unit: .Percent))
        }
        // Iron Old Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.iron) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .iron, unit: .Percent))
        }
        // Potassium New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.potassium) {
            productPair?.update(fact: NutritionFactItem.init(nutrient: .potassium, unit: .Percent))
        }

        mergeNutritionFacts()
        tableStructure = setupTableSections()
        tableView.reloadData()
    }
}


// MARK: - NutrimentsAvailableCellDelegate functions

extension NutrientsTableViewController: NutrimentsAvailableCellDelegate {
    
    // function to let the delegate know that the switch changed
    func nutrimentsAvailableTableViewCell(_ sender: NutrimentsAvailableTableViewCell, receivedActionOn mySwitch:UISwitch) {
        guard productPair?.remoteProduct != nil else { return }
        // change the updated product
        productPair?.update(availability: mySwitch.isOn)
        refreshProduct()
    }
}


// MARK: - PerUnitCellDelegate functions

extension NutrientsTableViewController: PerUnitCellDelegate {
    
    // function to let the delegate know that the switch changed
    func perUnitTableViewCell(_ sender: PerUnitTableViewCell, receivedActionOn segmentedControl:UISegmentedControl) {
        guard productPair?.remoteProduct != nil else { return }
        currentNutritionQuantityDisplayMode = NutritionDisplayMode.init(segmentedControl.selectedSegmentIndex)
        mergeNutritionFacts()
        tableView.reloadData()
    }
}


// MARK: - ProductImageCellDelegate functions

extension NutrientsTableViewController:  ProductImageCellDelegate {
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton) {
        guard let validLanguageCode = displayLanguageCode,
            let validProductPair = productPair else { return }
        OFFProducts.manager.deselectImage(for: validProductPair, in: validLanguageCode, of: .nutrition)
    }
    
}

// MARK: - TagListViewAddImageCellDelegate functions

extension NutrientsTableViewController: TagListViewAddImageCellDelegate {
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCamera button:UIButton) {
        takePhoto()
    }
    
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCameraRoll button:UIButton) {
        selectCameraRollPhoto()
    }
    
}


// MARK: - SearchNutrientsCellDelegate functions

extension NutrientsTableViewController: SearchNutrientsCellDelegate {
    
    func searchNutrientsTableViewCell(_ sender: SearchNutrientsTableViewCell, receivedActionOnUnit button:UIButton) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectNutrientUnit, sender: button)
    }
}

// MARK: - TextFieldDelegate functions

extension NutrientsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var section = textField.tag
        // is this the nutrients section?
        if section >= 100 {
            // the tag is a combination of the section and the row
            // section*100 + row
            section = (section - section % 100) / 100
        }
        
        switch tableStructure[section] {
        case .servingSize:
            if let validText = textField.text {
                productPair?.update(portion: validText)
            }
        case .nutritionFacts:
            // decode the actual row from the tag by subtracting the section*100
            let row = textField.tag % 100
            // print(textField.tag, row)
            if row >= 0 && row < adaptedNutritionFacts.count {
                // The new nutrient unit should be set to the nutrient that was edited
                // copy the existing nutrient and change the unit
                var editedNutritionFact = NutritionFactItem()
                editedNutritionFact.nutrient = adaptedNutritionFacts[row].nutrient
                editedNutritionFact.itemName = adaptedNutritionFacts[row].name
                if currentNutritionQuantityDisplayMode == .perStandard {
                    editedNutritionFact.standardValueUnit = adaptedNutritionFacts[row].unit

                    // this value has been changed
                    if let text = textField.text {
                        editedNutritionFact.standardValue = String(text.map {
                            $0 == "," ? "." : $0
                        })
                    }
                } else if currentNutritionQuantityDisplayMode == .perServing {
                    editedNutritionFact.servingValueUnit = adaptedNutritionFacts[row].unit

                    // this value has been changed
                    if let text = textField.text {
                        editedNutritionFact.servingValue = String(text.map {
                            $0 == "," ? "." : $0
                        })
                    }
                } else if currentNutritionQuantityDisplayMode == .perThousandGram {
                    editedNutritionFact.standardValueUnit = adaptedNutritionFacts[row].unit
                    
                    // this value has been changed
                    if let validText = textField.text {
                        editedNutritionFact.standardValue = String(validText.map {
                            $0 == "," ? "." : $0
                        })
                        if let validType = type,
                            let validValue = editedNutritionFact.standardValue {
                            switch validType {
                            case .petFood:
                                if let floatValue = Float(validValue) {
                                    // floatValue = floatValue / 10.0
                                    let numberFormatter = NumberFormatter()
                                    numberFormatter.numberStyle = .decimal
                                    editedNutritionFact.standardValue = numberFormatter.string(from: NSNumber(value: floatValue))
                                }
                            default: break
                            }
                        }
                    }
                }
                productPair?.update(fact: editedNutritionFact)
                mergeNutritionFacts()
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editMode
    }
    

}

// MARK: - TagListView DataSource Functions

extension NutrientsTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        if tagListView.tag >= 0 && tagListView.tag < tableStructure.count {
            switch tableStructure[tagListView.tag] {
            case .image, .nutritionFacts:
                return 1
            default:
                break
            }
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        
        switch tableStructure[tagListView.tag] {
        case .nutritionFacts:
            return nutritionFactsTagTitle
        case .image:
            return ImageFetchResult.noImageAvailable.description

        default:
            break
        }
        return("tagListView error")
    }
}

// MARK: - UIImagePickerControllerDelegate Functions

extension NutrientsTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
        // notify the delegate
    }
    
}


extension NutrientsTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        guard displayLanguageCode != nil else { return }
        // print("nutrients image", image.size)
        productPair?.update(nutritionImage: image, for: displayLanguageCode!)
        tableView.reloadData()
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LanguageHeaderDelegate Functions

extension NutrientsTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        switch sender.tag {
        case 0:
            performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowNutritionImageLanguages, sender: sender)
        case 1:
            performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowNutritionFactsTableStyles, sender: sender)
        default:
            break
        }
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        doubleTapOnTableView()
    }
}


// MARK: - UIDragInteractionDelegate Functions

@available(iOS 11.0, *)
extension NutrientsTableViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(for: session, at: indexPath)
    }
    
    private func dragItems(for session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard displayLanguageCode != nil else { return [] }
        var productImageData: ProductImageData? = nil
        // is there image data?
        if let images = productPair?.localProduct?.nutritionImages,
            !images.isEmpty {
            productImageData = productPair!.localProduct!.image(for:displayLanguageCode!, of:.nutrition)
        } else {
            productImageData = productPair!.remoteProduct!.image(for:displayLanguageCode!, of:.nutrition)
        }
        // The largest image here is the display image, as the url for the original front image is not offered by OFF in an easy way
        guard productImageData != nil else { return [] }
        
        guard let validProductImageData = productImageData else { return [] }
        
        // only allow flocking of another productImageSize
        for item in session.items {
            // Note kUTTypeImage is defined in MobileCoreServices, so need to import
            // This is an image, as that is what I offer to export
            guard item.itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) else { return [] }
        }
        
        switch tableStructure[indexPath.section] {
        case .image :
            // check if the selected image has not been added yet
            for item in session.items {
                guard item.localObject as! ProductImageData != validProductImageData else { return [] }
            }
            let provider = NSItemProvider(object: validProductImageData)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        default:
            break
        }
        return []
    }

    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        switch tableStructure[indexPath.section] {
        case .image :
            if let cell = tableView.cellForRow(at: indexPath) as? ProductImageTableViewCell,
                let rect = cell.productImageView.imageRect {
                let parameters = UIDragPreviewParameters.init()
                parameters.visiblePath = UIBezierPath(roundedRect: rect, cornerRadius: 15)
                return parameters
            }
        default:
            break
        }
        return nil
    }
    
}

// MARK: - UITableViewDropDelegate Functions

@available(iOS 11.0, *)
extension NutrientsTableViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        func setImage(image: UIImage) {
            let cropController = GKImageCropViewController.init()
            cropController.sourceImage = image
            cropController.view.frame = tableView.frame
            //cropController.preferredContentSize = picker.preferredContentSize
            cropController.hasResizableCropArea = true
            cropController.cropSize = CGSize.init(width: 300, height: 300)
            cropController.delegate = self
            cropController.modalPresentationStyle = .fullScreen
            
            present(cropController, animated: true, completion: nil)
            if let popoverPresentationController = cropController.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
            //self.pushViewController(cropController, animated: false)
        }
        
        coordinator.session.loadObjects(ofClass: UIImage.self) { (images) in
            // Only one image is accepted as ingredients image for the current language
            if let validImage = (images as? [UIImage])?.first {
                setImage(image: validImage)
                //self.delegate?.updated(frontImage: images[0] as! UIImage, languageCode:self.currentLanguageCode!)
                //self.reloadImageSection()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // Only accept if an image is hovered above the image section
        if let validIndexPathSection = destinationIndexPath?.section {
            switch tableStructure[validIndexPathSection] {
            case .image:
                return editMode ? UITableViewDropProposal(operation: .copy, intent: .unspecified) : UITableViewDropProposal(operation: .forbidden, intent: .unspecified)
            default:
                break
            }
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
        
    }
}

// MARK: - GKImageCropController Delegate Methods

extension NutrientsTableViewController: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        guard let validLanguage = displayLanguageCode,
            let validImage = croppedImage else { return }
        imageCropController.dismiss(animated: true, completion: nil)
        productPair?.update(nutritionImage: validImage, for: validLanguage)
        self.reloadImageSection()
    }
}
