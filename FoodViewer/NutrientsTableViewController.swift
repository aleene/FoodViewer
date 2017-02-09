//
//  NutrientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    fileprivate var adaptedNutritionFacts: [DisplayFact] = []
    
    // set to app wide default
    fileprivate var showNutrientsAs: NutritionDisplayMode = Preferences.manager.showNutritionDataPerServingOrPerStandard
    
    fileprivate var searchResult: String = ""
    
    fileprivate var nutritionFactsTagTitle: String = ""

    private var selectedIndexPath: IndexPath? = nil
    
    struct DisplayFact {
        var name: String? = nil
        var value: String? = nil
        var unit: NutritionFactUnit? = nil
        var key: String? = nil
    }
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                mergeNutritionFacts()
                tableStructureForProduct = analyseProductForTable(product!)
                tableView.reloadData()
            }
        }
    }
    
    var editMode = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue && product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                tableView.reloadData()
            }
        }
    }

    var delegate: ProductPageViewController? = nil

    var currentLanguageCode: String? = nil {
        didSet {
            if currentLanguageCode != oldValue {
                tableView.reloadData()
            }
        }
    }

    private func adaptNutritionFacts(_ facts: [NutritionFactItem?]?) -> [DisplayFact] {
        var displayFacts: [DisplayFact] = []
        if let validFacts = facts {
            for fact in validFacts {
                if let validFact = fact {
                    var newFact: NutritionFactItem? = nil
                    // if the validFact is sodium or salt, add either one to the list of facts, but not both
                    if (validFact.key == NatriumChloride.salt.key()) {
                        switch Preferences.manager.showSaltOrSodium {
                        // do not show sodium
                        case .sodium: break
                        default:
                            newFact = validFact
                        }
                    } else if (validFact.key == NatriumChloride.sodium.key()) {
                        switch Preferences.manager.showSaltOrSodium {
                        // do not show salt
                        case .salt: break
                        default:
                            newFact = validFact
                        }
                    } else if !editMode && ( validFact.key == Energy.key ) {
                        switch Preferences.manager.showCaloriesOrJoule {
                        // show energy as calories
                        case .calories:
                            newFact = NutritionFactItem.init(name: Energy.calories.description(),
                                                             standard: validFact.valueInCalories(validFact.standardValue),
                                                             serving: validFact.valueInCalories(validFact.servingValue),
                                                             unit: Energy.calories.unit(),
                                                             key: validFact.key)
                        case .joule:
                            // this assumes that fact is in Joule
                            newFact = validFact
                        }
                    } else {
                        newFact = validFact
                    }
                    if let finalFact = newFact {
                        let validDisplayFact = localizeFact(finalFact)
                        displayFacts.append(validDisplayFact)
                    }

                }
            }
        }
        return displayFacts
    }
    
    // transform the nutrition fact values to values that must be displayed
    fileprivate func localizeFact(_ fact: NutritionFactItem) -> DisplayFact {
        var displayFact = DisplayFact()
        displayFact.name = fact.itemName
        switch showNutrientsAs {
        case .perStandard:
            let localizedValue = fact.localeStandardValue()
            displayFact.value = fact.standardValue != nil ? localizedValue : ""
            displayFact.unit = fact.standardValueUnit
        case .perServing:
            displayFact.value = fact.servingValue != nil ? fact.localeServingValue() : ""
            displayFact.unit = fact.servingValueUnit
        case .perDailyValue:
            displayFact.value = fact.dailyFractionPerServing != nil ? fact.localeDailyValue() : ""
            displayFact.unit = NutritionFactUnit.None // The numberformatter already provides a % sign
        }
        displayFact.key = fact.key
        return displayFact
    }
    
    // The functions creates a mixed array of edited and unedited nutrients
    
    fileprivate func mergeNutritionFacts() {
        var newNutritionFacts: [NutritionFactItem?] = []
        // Are there any nutritionFacts defined?
        if let validNutritionFacts = product?.nutritionFacts {
            // Is there an edited version of the nutritionFacts?
            if let updatedNutritionFacts = delegate?.updatedProduct?.nutritionFacts {
                // create a mixed array of unedited and edited items
                for index in 0 ..< validNutritionFacts.count {
                    // has this nutritionFact been updated?
                    if updatedNutritionFacts[index] == nil {
                        newNutritionFacts.append(validNutritionFacts[index]!)
                    } else {
                        var newFact = NutritionFactItem()
                        newFact.key = updatedNutritionFacts[index]?.key
                        newFact.itemName = updatedNutritionFacts[index]?.itemName
                        // check out whether an update occured
                        newFact.standardValue = updatedNutritionFacts[index]?.standardValue ?? validNutritionFacts[index]?.standardValue
                        newFact.standardValueUnit = updatedNutritionFacts[index]?.standardValueUnit ?? validNutritionFacts[index]?.standardValueUnit
                        newFact.servingValue = updatedNutritionFacts[index]?.servingValue ?? validNutritionFacts[index]?.servingValue
                        newFact.servingValueUnit = updatedNutritionFacts[index]?.servingValueUnit ?? validNutritionFacts[index]?.servingValueUnit
                        newNutritionFacts.append(newFact)
                    }
                }
                adaptedNutritionFacts = adaptNutritionFacts(newNutritionFacts)
            } else {
                // just use the original facts
                adaptedNutritionFacts = adaptNutritionFacts(validNutritionFacts)
            }
        }
    }

    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    fileprivate struct Storyboard {
        static let NutritionFactCellIdentifier = "Nutrition Fact Cell"
        static let ServingSizeCellIdentifier = "Serving Size Cell"
        static let NoServingSizeCellIdentifier = "No Serving Size Cell"
        static let NutritionFactsImageCellIdentifier = "Nutrition Facts Image Cell"
        static let EmptyNutritionFactsImageCellIdentifier = "Empty Nutrition Facts Image Cell"
        static let NoNutrientsImageCellIdentifier = "No Nutrition Image Cell"
        static let AddNutrientCellIdentifier = "Add Nutrient Cell"
        static let PerUnitCellIdentifier = "Per Unit Cell"
        static let NoNutrimentsAvailableCellIdentifier = "Nutriments Available Cell"
        static let ShowNutritionFactsImageSegueIdentifier = "Show Nutrition Facts Image"
        static let AddNutrientSegue = "Add Nutrient Segue"
        static let SelectNutrientUnitSegue = "Select Nutrient Unit Segue"
        static let ShowNutritionFactsImageTitle = NSLocalizedString("Image", comment: "Title of the ViewController with package image of the nutritional values")
        static let ViewControllerTitle = NSLocalizedString("Nutrition Facts", comment: "Title of the ViewController with the nutritional values")
        static let PortionTag = 100
    }
    
    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    // The different sections of the tableView
    fileprivate enum SectionType {
        case perUnit
        case nutritionFacts
        case addNutrient
        case servingSize
        case nutritionImage
        case noNutrimentsAvailable
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections (7)
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
        case .noNutrimentsAvailable:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrimentsAvailableCellIdentifier, for: indexPath) as! NutrimentsAvailableTableViewCell
            cell.editMode = editMode
            cell.hasNutrimentFacts = delegate?.updatedProduct?.hasNutritionFacts != nil ? delegate!.updatedProduct!.nutrimentFactsAvailability : product!.nutrimentFactsAvailability
            return cell
        case .perUnit:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.PerUnitCellIdentifier, for: indexPath) as! PerUnitTableViewCell
            cell.displayMode = showNutrientsAs
            cell.editMode = editMode
            cell.nutritionFactsAvailability = product!.nutritionFactsAreAvailable
            // print(showNutrientsAs, product!.nutritionFactsAreAvailable)
            return cell
        case .nutritionFacts:
            if adaptedNutritionFacts.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell
                cell?.tag = indexPath.section
                cell?.width = tableView.frame.size.width
                cell?.datasource = self
                // cell?.delegate = self // no manipulations on tags possible
                // cell?.editMode = editMode // cell is not editable
                if let available = product?.nutritionFactsAreAvailable {
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
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactCellIdentifier, for: indexPath) as? NutrientsTableViewCell
                // warning set FIRST the saltOrSodium
                cell?.nutritionDisplayFactItem = adaptedNutritionFacts[(indexPath as NSIndexPath).row]
                cell?.delegate = self
                cell?.tag = indexPath.section * 100 + indexPath.row
                // only add taps gestures when NOT in editMode
                if !editMode {
                    if  (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == NatriumChloride.salt.key()) ||
                        (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == NatriumChloride.sodium.key()) {
                        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnSaltSodiumTableViewCell))
                        doubleTapGestureRecognizer.numberOfTapsRequired = 2
                        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                        doubleTapGestureRecognizer.cancelsTouchesInView = false
                        doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                        cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                    } else if  (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == Energy.key) ||
                        (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == Energy.key) {
                        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnEnergyTableViewCell))
                        doubleTapGestureRecognizer.numberOfTapsRequired = 2
                        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                        doubleTapGestureRecognizer.cancelsTouchesInView = false
                        doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                        cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                    }
                }
                cell?.editMode = editMode
                return cell!
            }
        case .servingSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ServingSizeCellIdentifier, for: indexPath) as? ServingSizeTableViewCell
            cell!.servingSizeTextField.delegate = self
            cell!.servingSizeTextField.tag = indexPath.section
            cell!.editMode = editMode

            // has the product been edited?
            if let validName = delegate?.updatedProduct?.servingSize {
                cell!.servingSize = validName
            } else if let validName = product?.servingSize {
                cell!.servingSize = validName
            } else {
                cell!.servingSize = nil
            }
            return cell!

        case .nutritionImage:
            // are any nutrition images in the product
            if product!.nutritionImages != nil && product!.nutritionImages!.display.count > 0 {
                // is the data for the current language available?
                // then fetch the image
                if delegate?.updatedProduct?.nutritionImages?.display != nil && delegate!.updatedProduct!.nutritionImages!.display.count > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactsImageCellIdentifier, for: indexPath) as? NutrientsImageTableViewCell
                    if let image = delegate!.updatedProduct!.nutritionImages!.display[currentLanguageCode!]?.image {
                        cell?.nutritionFactsImage = image
                    } else if let image = delegate!.updatedProduct!.nutritionImages!.display[delegate!.updatedProduct!.primaryLanguageCode!]?.image {
                        cell?.nutritionFactsImage = image
                    }
                    return cell!
                } else if let result = product!.nutritionImages!.display[currentLanguageCode!]?.fetch() {
                    switch result {
                    case .success:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactsImageCellIdentifier, for: indexPath) as? NutrientsImageTableViewCell
                        cell?.nutritionFactsImage = product!.nutritionImages!.display[currentLanguageCode!]?.image
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                    // try to use the primary image
                } else if let result = product!.nutritionImages!.display[product!.primaryLanguageCode!]?.fetch() {
                    switch result {
                    case .success:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactsImageCellIdentifier, for: indexPath) as? NutrientsImageTableViewCell
                        cell?.nutritionFactsImage = product!.nutritionImages!.display[product!.primaryLanguageCode!]?.image
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        return cell!
                    }
                } else {
                    // image could not be found (yet)
                    searchResult = ImageFetchResult.noImageAvailable.description()
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell //
                    cell?.datasource = self
                    cell?.tag = indexPath.section
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.error
                    return cell!
                }
            }
            searchResult = ImageFetchResult.noImageAvailable.description()
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell //
            cell?.datasource = self
            cell?.tag = indexPath.section
            cell?.width = tableView.frame.size.width
            cell?.scheme = ColorSchemes.error
            return cell!

            /*
            if let result = product?.getNutritionImageData() {
                switch result {
                case .success(let data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactsImageCellIdentifier, for: indexPath) as? NutrientsImageTableViewCell
                    cell?.nutritionFactsImage = UIImage(data:data)
                    return cell!
                default:
                    searchResult = result.description()
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell
                    cell?.tag = indexPath.section
                    // cell?.delegate = self
                    cell?.width = tableView.frame.size.width
                    cell?.datasource = self
                    // cell?.editMode = editMode // cell is not editable
                    cell?.scheme = ColorSchemes.error
                    return cell!
                }
            } else {
                searchResult = ImageFetchResult.noImageAvailable.description()
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? TagListViewTableViewCell
                cell?.tag = indexPath.section
                // cell?.delegate = self
                cell?.width = tableView.frame.size.width
                cell?.datasource = self
                // cell?.editMode = editMode // cell is not editable
                cell?.scheme = ColorSchemes.error
                return cell!
            }
 */
        case .addNutrient:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.AddNutrientCellIdentifier, for: indexPath) as! AddNutrientTableViewCell
            cell.buttonText = NSLocalizedString("Add Nutrient", comment: "Title of a button in normal state allowing the user to add a nutrient")
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        tempView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        let label = UILabel.init(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 20))
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        // label.textColor = UIColor.whiteColor()
        switch section {
        case 0:
            label.text = showNutrientsAs.description()
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnNutrimentsHeader))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            doubleTapGestureRecognizer.numberOfTouchesRequired = 1
            doubleTapGestureRecognizer.cancelsTouchesInView = false
            doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
            
            tempView.addGestureRecognizer(doubleTapGestureRecognizer)

        default:
            let (_, _, header) = tableStructureForProduct[section]
            label.text = header
        }
        
        tempView.addSubview(label)
        tempView.tag = section;
        return tempView;
    }
 */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    fileprivate struct TableSections {
        struct Size {
            static let NutritionFactsImage = 1
            static let ServingSize = 1
            static let NutritionFactsEmpyt = 1
            static let AddNutrient = 1
            static let PerUnit = 1
            static let NutrimentsAvailable = 1
        }
        struct Header {
            static let NutritionFactItems = NSLocalizedString("Nutrition Facts", comment: "Tableview header section for the list of nutritional facts")
            static let NutritionFactsImage = NSLocalizedString("Nutrition Facts Image", comment: "Tableview header section for the image of the nutritional facts")
            static let ServingSize = NSLocalizedString("Serving Size", comment: "Tableview header for the section with the serving size, i.e. the amount one will usually take of the product.")
            static let AddNutrient = "No Add Nutrient Header"
            static let PerUnit = NSLocalizedString("Presentation format", comment: "Tableview header for the section per unit shown, i.e. whether the nutrients are shown per 100 mg/ml or per portion.")
            static let NutrimentsAvailable = NSLocalizedString("Nutriments Availability", comment: "Tableview header for the section with nutriments availability, i.e. whether the nutrients are on the package.")
        }
    }
    
    func doubleTapOnSaltSodiumTableViewCell(_ recognizer: UITapGestureRecognizer) {
        /////
        Preferences.manager.showSaltOrSodium = Preferences.manager.showSaltOrSodium == .salt ? .sodium : .salt
        
        mergeNutritionFacts()
        tableView.reloadData()
    }
    
    func doubleTapOnEnergyTableViewCell(_ recognizer: UITapGestureRecognizer) {
        /////
        switch Preferences.manager.showCaloriesOrJoule {
        case .calories:
            Preferences.manager.showCaloriesOrJoule = .joule
        case .joule:
            Preferences.manager.showCaloriesOrJoule = .calories
        }
        
        mergeNutritionFacts()
        tableView.reloadData()

//        let sections = NSIndexSet.init(index: 0)
//        tableView.reloadSections(sections, withRowAnimation: .Fade)
    }
    
    /*
    func doubleTapOnNutrimentsHeader(_ recognizer: UITapGestureRecognizer) {
        ///// Cycle through display modes
        switch showNutrientsAs {
        case .perStandard:
            showNutrientsAs = .perServing
        case .perServing:
            showNutrientsAs = .perDailyValue
        case .perDailyValue:
            showNutrientsAs = .perStandard
        }
        
        mergeNutritionFacts()
        tableView.reloadData()
    }
 */
    
    fileprivate func analyseProductForTable(_ product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // how does the user want the data presented
        switch Preferences.manager.showNutritionDataPerServingOrPerStandard {
        case .perStandard:
            // what is possible?
            switch product.nutritionFactsAreAvailable {
            case .perStandardUnit, .perServingAndStandardUnit:
                showNutrientsAs = .perStandard
            case .perServing:
                showNutrientsAs = .perServing
            default:
                break
            }
        case .perServing:
            switch product.nutritionFactsAreAvailable {
                // what is possible?
            case .perStandardUnit:
                showNutrientsAs = .perStandard
            case .perServing, .perServingAndStandardUnit:
                showNutrientsAs = .perServing
            default:
                break
            }
        case .perDailyValue:
            switch product.nutritionFactsAreAvailable {
            case .perStandardUnit:
                // force showing perStandard as perServing is not available
                showNutrientsAs = .perStandard
            case .perServingAndStandardUnit:
                showNutrientsAs = .perDailyValue
            case .perServing:
                showNutrientsAs = .perDailyValue
            default:
                break
            }
        }
        
        // Which sections are shown depends on whether the product has nutriment data
        if ( !editMode && product.hasNutritionFacts != nil && !product.hasNutritionFacts! ) {
            // the product has no nutriments indicated
            sectionsAndRows.append(
                ( SectionType.noNutrimentsAvailable,
                  TableSections.Size.NutrimentsAvailable,
                  TableSections.Header.NutrimentsAvailable )
            )
        } else {
            
            if editMode {
                sectionsAndRows.append(
                    ( SectionType.noNutrimentsAvailable,
                      TableSections.Size.NutrimentsAvailable,
                      TableSections.Header.NutrimentsAvailable )
                )
            }
            
            // the product has nutriments indicated
            // 0 : how the nutrients are shown section
            sectionsAndRows.append(
                ( SectionType.perUnit,
                  TableSections.Size.PerUnit,
                  TableSections.Header.PerUnit )
            )
        
            // 0 : nutrition facts
            if product.nutritionFacts == nil || product.nutritionFacts!.isEmpty {
                sectionsAndRows.append((
                    SectionType.nutritionFacts,
                    TableSections.Size.NutritionFactsEmpyt,
                    TableSections.Header.NutritionFactItems))
            } else {
                sectionsAndRows.append((
                    SectionType.nutritionFacts,
                    adaptedNutritionFacts.count,
                    TableSections.Header.NutritionFactItems))
            }
        
        // 1: Add nutrient Button only in editMode
        
        if editMode {
            sectionsAndRows.append((
            SectionType.addNutrient,
            TableSections.Size.AddNutrient,
            TableSections.Header.AddNutrient))
        }
    
        // 1 or 2:  serving size
        sectionsAndRows.append((
            SectionType.servingSize,
            TableSections.Size.ServingSize,
            TableSections.Header.ServingSize))
        
        // 2 or 3: image section
            sectionsAndRows.append((
                SectionType.nutritionImage,
                TableSections.Size.NutritionFactsImage,
                TableSections.Header.NutritionFactsImage))
        
        }
        return sectionsAndRows
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        switch currentProductSection {
        case .nutritionImage :
            return indexPath
        default:
            break
        }
        return nil
    }

    // MARK: - Segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowNutritionFactsImageSegueIdentifier:
                if let vc = segue.destination as? imageViewController {
                    if delegate?.updatedProduct?.nutritionImages?.display != nil && delegate!.updatedProduct!.nutritionImages!.display.count > 0 {
                        if let image = delegate!.updatedProduct!.nutritionImages!.display[currentLanguageCode!]?.image {
                            vc.image = image
                        } else if let image = delegate!.updatedProduct!.nutritionImages!.display[delegate!.updatedProduct!.primaryLanguageCode!]?.image {
                            vc.image = image
                        }
                        vc.imageTitle = Storyboard.ShowNutritionFactsImageTitle
                    } else if product?.nutritionImages != nil && product!.nutritionImages!.display.count > 0 {
                        // is the data for the current language available?
                        // then fetch the image
                        if let result = product!.nutritionImages!.display[currentLanguageCode!]?.fetch() {
                            switch result {
                            case .success:
                                vc.image = product!.nutritionImages!.display[currentLanguageCode!]?.image
                                vc.imageTitle = Storyboard.ShowNutritionFactsImageTitle
                            default:
                                vc.image = nil
                            }
                            // try to use the primary image
                        } else if let result = product!.nutritionImages!.display[product!.primaryLanguageCode!]?.fetch() {
                            switch result {
                            case .success:
                                vc.image = product!.nutritionImages!.display[product!.primaryLanguageCode!]?.image
                                vc.imageTitle = Storyboard.ShowNutritionFactsImageTitle
                            default:
                                vc.image = nil
                            }
                        } else {
                            vc.image = nil
                        }
                    }
                }
            case Storyboard.AddNutrientSegue:
                if let vc = segue.destination as? AddNutrientViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? AddNutrientTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .up
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.existingNutrients = adaptedNutritionFacts.flatMap { $0.name }
                            }
                        }
                    }
                }
            case Storyboard.SelectNutrientUnitSegue:
                if let vc = segue.destination as? SelectNutrientUnitViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? NutrientsTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                let row = button.tag % 100
                                vc.nutrientRow = row
                                if row >= 0 && row < adaptedNutritionFacts.count {
                                    vc.currentNutritionFactKey = adaptedNutritionFacts[row].key
                                }
                            }
                        }
                    }
                }
/*
            case Storyboard.SelectNutrientUnitSegue:
                if let vc = segue.destination as? SelectNutrientUnitViewController {
                    if let button = sender as? UIButton {
                        if selectedIndexPath != nil {
                            if let currentCell = tableView.cellForRow(at: selectedIndexPath!) as? NutrientsTableViewCell {
                                // are we in a popovercontroller?
                                // define the anchor point
                                if let ppc = vc.popoverPresentationController {
                                    // set the main language button as the anchor of the popOver
                                    ppc.permittedArrowDirections = .any
                                    ppc.sourceRect = currentCell.unitButton.frame
                                    ppc.delegate = self
                                    vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                }
                            }
                            // the current nutrient is found by the button tag
                            // it has to be passed on, so that it can be updated later
                            vc.nutrientRow = button.tag
                            vc.currentNutritionFactKey = adaptedNutritionFacts[button.tag].key
                        }
                        // Corresponds this to the cell with the language button?
                    }

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
                var newNutrient = NutritionFactItem()
                newNutrient.key = newNutrientTuple.0
                newNutrient.itemName = newNutrientTuple.1
                newNutrient.servingValueUnit = newNutrientTuple.2
                newNutrient.standardValueUnit = newNutrientTuple.2
                delegate?.updated(fact: newNutrient)
                refreshProductWithNewNutritionFacts()
            }
        }
    }
    
    @IBAction func unwindSetNutrientUnit(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectNutrientUnitViewController {
            // The new nutrient unit should be set to the nutrient that was edited
            if let nutrientRow = vc.nutrientRow {
                // copy the existing nutrient and change the unit
                var editedNutritionFact = NutritionFactItem()
                editedNutritionFact.key = adaptedNutritionFacts[nutrientRow].key
                editedNutritionFact.itemName = adaptedNutritionFacts[nutrientRow].name
                // this value has been changed
                editedNutritionFact.standardValueUnit = vc.selectedNutritionUnit
                editedNutritionFact.standardValue = adaptedNutritionFacts[nutrientRow].value
                delegate?.updated(fact: editedNutritionFact)
                refreshProductWithNewNutritionFacts()
            }
        }
    }
    
    // MARK: - Popover delegation functions
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
    
    // MARK: - Notification handler functions
    
    func refreshProduct() {
        guard product != nil else { return }
        tableView.reloadData()
    }
    
    func newPerUnitSettings(_ notification: Notification) {
        guard product != nil else { return }
        if let index = notification.userInfo?[PerUnitTableViewCell.Notification.PerUnitHasBeenSetKey] as? Int {
            showNutrientsAs = NutritionDisplayMode.init(index)
            mergeNutritionFacts()
            tableView.reloadData()
        }
    }

    // The availability of nutriments on the product has changed
    func nutrimentsAvailabilitySet(_ notification: Notification) {
        guard product != nil else { return }
        if let availability = notification.userInfo?[NutrimentsAvailableTableViewCell.Notification.NutrimentsAvailability] as? Bool {
            // change the updated product
            delegate?.updated(availability: availability)
            refreshProductWithNewNutritionFacts()
        }
    }
    
    func showNutrimentSelector(_ notification: Notification) {
        if let sender = notification.userInfo?[AddNutrientTableViewCell.Notification.AddNutrientButtonTappedKey] {
            performSegue(withIdentifier: Storyboard.AddNutrientSegue, sender: sender)
        }
    }

    func showNutrimentUnitSelector(_ notification: Notification) {
        if let sender = notification.userInfo?[NutrientsTableViewCell.Notification.ChangeNutrientUnitButtonTappedKey] {
            performSegue(withIdentifier: Storyboard.SelectNutrientUnitSegue, sender: sender)
        }
    }


    func reloadImageSection() { // (_ notification: Notification) {
        tableView.reloadData()
    }

    func refreshProductWithNewNutritionFacts() {
        guard product != nil else { return }
        // recalculate the nutritionfacts that must be shown
        tableStructureForProduct = analyseProductForTable(product!)
        mergeNutritionFacts()
        tableView.reloadData()
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }


    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Storyboard.ViewControllerTitle
        
        refreshProductWithNewNutritionFacts()

        NotificationCenter.default.addObserver(
            self,
            selector:#selector(NutrientsTableViewController.refreshProduct),
            name: .ProductUpdated,
            object:nil
        )
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.removeProduct), name: .HistoryHasBeenDeleted, object:nil)
        // NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.reloadImageSection(_:)), name: .NutritionImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.newPerUnitSettings(_:)), name: .PerUnitChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.nutrimentsAvailabilitySet(_:)), name: .NutrimentsAvailabilityTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.showNutrimentSelector(_:)), name: .AddNutrientButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.showNutrimentUnitSelector(_:)), name: .ChangeNutrientUnitButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.reloadImageSection), name:.ImageSet, object:nil)
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

// MARK: - TextField delegate functions

extension NutrientsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var section = textField.tag
        if section != 4 {
            // the tag is a combination of the section and the row
            // section*100 + row
            section = (section - section % 100) / 100
        }
        let (currentProductSection, _, _) = tableStructureForProduct[section]
        
        switch currentProductSection {
        case .servingSize:
            if let validText = textField.text {
                delegate?.updated(portion: validText)
            }
        default:
            // decode the actual row from the tag by subtracting the section*100
            let row = textField.tag % 100
            print(textField.tag, row)
            if row >= 0 && row < adaptedNutritionFacts.count {
                // The new nutrient unit should be set to the nutrient that was edited
                // copy the existing nutrient and change the unit
                var editedNutritionFact = NutritionFactItem()
                editedNutritionFact.key = adaptedNutritionFacts[row].key
                editedNutritionFact.itemName = adaptedNutritionFacts[row].name
                if showNutrientsAs == .perStandard {
                    editedNutritionFact.standardValueUnit = adaptedNutritionFacts[row].unit

                    // this value has been changed
                    if let text = textField.text {
                        editedNutritionFact.standardValue = String(text.characters.map {
                            $0 == "," ? "." : $0
                        })
                    }
                } else if showNutrientsAs == .perServing {
                    editedNutritionFact.servingValueUnit = adaptedNutritionFacts[row].unit

                    // this value has been changed
                    if let text = textField.text {
                        editedNutritionFact.servingValue = String(text.characters.map {
                            $0 == "," ? "." : $0
                        })
                    }
                }
                delegate?.updated(fact: editedNutritionFact)
                mergeNutritionFacts()
                tableView.reloadData()
            }
        }
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
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch currentProductSection {
        case .nutritionImage, .nutritionFacts:
            return 1
        default:
            return 0
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch currentProductSection {
        case .nutritionImage:
            return searchResult
        case .nutritionFacts:
            return nutritionFactsTagTitle
        default:
            return("tagListView error")
        }
    }
}

