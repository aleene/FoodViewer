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
                mergeNutritionFacts()
                query = nil
                tableStructureForProduct = setupTableSections()
                tableView.reloadData()
            }
        }
    }
    
    
    fileprivate var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                tableStructureForProduct = setupTableSections()
                product = nil
                tableView.reloadData()
            }
        }
    }
    

    var editMode = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableStructureForProduct = setupTableSections()
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

    fileprivate var notSearchableToDisplay: Tags {
        get {
            return .notSearchable
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
                    } else if !editMode && ( validFact.key == LocalizedEnergy.key ) {
                        switch Preferences.manager.showCaloriesOrJoule {
                        // show energy as calories
                        case .calories:
                            newFact = NutritionFactItem.init(name: EnergyUnitUsed.calories.description(),
                                                             standard: validFact.valueInCalories(validFact.standardValue),
                                                             serving: validFact.valueInCalories(validFact.servingValue),
                                                             unit: EnergyUnitUsed.calories.unit(),
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
            let localizedValue = fact.localeStandardValue() // editMode ? fact.standardValue : fact.localeStandardValue()
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
        struct CellIdentifier {
            static let NutritionFact = "Nutrition Fact Cell"
            static let ServingSize = "Serving Size Cell"
            static let NoServingSize = "No Serving Size Cell"
            static let Image = "Nutrition Facts Image Cell"
            static let EmptyNutritionFacts = "Empty Nutrition Facts Image Cell"
            static let NoImage = "No Nutrition Image Cell"
            static let AddNutrient = "Add Nutrient Cell"
            static let PerUnit = "Per Unit Cell"
            static let NoNutrimentsAvailable = "Nutriments Available Cell"
            static let SearchNutritionFact = "Search Nutrition Fact Cell Identifier"
        }
        
        struct SegueIdentifier {
            static let ShowNutritionFactsImage = "Show Nutrition Facts Image"
            static let AddNutrient = "Add Nutrient Segue"
            static let SelectNutrientUnit = "Select Nutrient Unit Segue"
            static let SelectNutrientUnitForSearch = "Select Nutrient Unit For Search Nutrition Fact Segue Identifier"
            static let ShowNutritionImageLanguages = "Show Nutrition Image Languages"
            static let SelectComparisonOperator = "Show Select Comparison Operator Segue Identifier"
        }
        struct Title {
            static let ShowNutritionFactsImage = NSLocalizedString("Image", comment: "Title of the ViewController with package image of the nutritional values")
            static let ViewController = NSLocalizedString("Nutrition Facts", comment: "Title of the ViewController with the nutritional values")
        }
        static let PortionTag = 100
    }
    
    fileprivate struct Constants {
        static let NoLanguage = NSLocalizedString("no language defined", comment: "Text for language of product, when there is no language defined.")
    }
    
    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    // The different sections of the tableView
    fileprivate enum SectionType {
        case perUnit
        case perUnitSearch
        case nutritionFacts
        case nutritionFactsSearch
        case addNutrient
        case servingSize
        case servingSizeSearch
        case nutritionImage
        case imageSearch
        case noNutrimentsAvailable
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // should return all sections
        return tableStructureForProduct.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (currentProductSection, numberOfRows, _) = tableStructureForProduct[section]
        // in editMode the nutritionFacts have a button added
        let noRows = (currentProductSection  == .nutritionFacts || currentProductSection  == .nutritionFactsSearch ) && editMode ? numberOfRows + 1 : numberOfRows
        return noRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        // we assume that product exists
        switch currentProductSection {
        case .perUnitSearch, .servingSizeSearch, .imageSearch:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.EmptyNutritionFacts, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.editMode = false
            cell.tag = indexPath.section
            cell.tagListView.normalColorScheme = ColorSchemes.error
            return cell
            
        case .noNutrimentsAvailable:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoNutrimentsAvailable, for: indexPath) as! NutrimentsAvailableTableViewCell
            cell.editMode = editMode
            cell.hasNutrimentFacts = delegate?.updatedProduct?.hasNutritionFacts != nil ? delegate!.updatedProduct!.nutrimentFactsAvailability : product!.nutrimentFactsAvailability
            return cell
            
        case .perUnit:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.PerUnit, for: indexPath) as! PerUnitTableViewCell
            cell.displayMode = showNutrientsAs
            cell.editMode = editMode
            cell.nutritionFactsAvailability = product!.nutritionFactsAreAvailable
            // print(showNutrientsAs, product!.nutritionFactsAreAvailable)
            return cell
            
        case .nutritionFacts:
            let (_, numberOfRows, _) = tableStructureForProduct[indexPath.section]
            if indexPath.row == numberOfRows && editMode {
                // This cell should only be added when in editMode and as the last row
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.AddNutrient, for: indexPath) as! AddNutrientTableViewCell
                cell.buttonText = NSLocalizedString("Add Nutrient", comment: "Title of a button in normal state allowing the user to add a nutrient")
                return cell
            } else {
                if adaptedNutritionFacts.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.EmptyNutritionFacts, for: indexPath) as? TagListViewTableViewCell
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionFact, for: indexPath) as? NutrientsTableViewCell
                    // warning set FIRST the saltOrSodium
                    cell?.nutritionDisplayFactItem = adaptedNutritionFacts[(indexPath as NSIndexPath).row]
                    cell?.delegate = self
                    cell?.tag = indexPath.section * 100 + indexPath.row
                    // only add taps gestures when NOT in editMode
                    if !editMode {
                        if  (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key ==   NatriumChloride.salt.key()) ||
                            (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == NatriumChloride.sodium.key()) {
                            let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:  #selector(NutrientsTableViewController.doubleTapOnSaltSodiumTableViewCell))
                            doubleTapGestureRecognizer.numberOfTapsRequired = 2
                            doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                            doubleTapGestureRecognizer.cancelsTouchesInView = false
                            doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                            cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                        } else if  (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == LocalizedEnergy.key) ||
                            (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == LocalizedEnergy.key) {
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
            }
        case .nutritionFactsSearch:
            let (_, numberOfRows, _) = tableStructureForProduct[indexPath.section]
            if indexPath.row == numberOfRows && editMode {
                // This cell should only be added when in editMode and as the last row
                // and allows the user to add a nutrient
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.AddNutrient, for: indexPath) as! AddNutrientTableViewCell
                cell.buttonText = NSLocalizedString("Add Nutrient", comment: "Title of a button in normal state allowing the user to add a nutrient")
                return cell
            } else {
                if query!.allNutrimentsSearch.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.EmptyNutritionFacts, for: indexPath) as? TagListViewTableViewCell
                    cell?.tag = indexPath.section
                    cell?.width = tableView.frame.size.width
                    cell?.datasource = self
                    return cell!
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.SearchNutritionFact, for: indexPath) as! SearchNutrientsTableViewCell
                    cell.searchNutrition = query!.allNutrimentsSearch[indexPath.row]
                    cell.delegate = self
                    cell.tag = indexPath.section * 100 + indexPath.row
                    cell.editMode = editMode
                    return cell
                }
            }

        case .servingSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ServingSize, for: indexPath) as? ServingSizeTableViewCell
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
            
            // first try the updated product images
            if delegate?.updatedProduct?.nutritionImages != nil && !delegate!.updatedProduct!.nutritionImages.isEmpty  {
                // try the updated image corresponding to the current language
                if let image = delegate!.updatedProduct!.nutritionImages[currentLanguageCode!]!.display?.image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? NutrientsImageTableViewCell
                    cell?.editMode = editMode
                    cell?.nutritionFactsImage = image
                    return cell!
                // in non-editMode try to fall back to the updated primary language image
                } else if !editMode,
                    let primaryLanguageCode = delegate!.updatedProduct!.primaryLanguageCode,
                    let image = delegate!.updatedProduct!.nutritionImages[primaryLanguageCode]?.display?.image {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? NutrientsImageTableViewCell
                        cell?.editMode = editMode
                        cell?.nutritionFactsImage = image
                        return cell!
                // show an error
                } else {
                    searchResult = ImageFetchResult.noImageAvailable.description()
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? NoNutrientsImageTableViewCell //
                    cell?.width = tableView.frame.size.width
                    cell?.scheme = ColorSchemes.error
                    cell?.editMode = editMode
                    cell?.datasource = self
                    cell?.tag = indexPath.section
                    return cell!
                    
                }
            // try the regular nutrition images
            } else if !product!.nutritionImages.isEmpty {
                // is the data for the current language available?
                // then fetch the image
                if let result = product!.nutritionImages[currentLanguageCode!]?.display?.fetch() {
                    switch result {
                    case .available:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? NutrientsImageTableViewCell
                        cell?.nutritionFactsImage = product!.nutritionImages[currentLanguageCode!]?.display?.image
                        cell?.editMode = editMode
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? NoNutrientsImageTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        cell?.editMode = editMode
                        return cell!
                    }
                // try the nutrition image corresponding to the primary languagecode in non-editMode
                } else if !editMode, let primaryLanguageCode = product!.primaryLanguageCode, let result = product!.nutritionImages[primaryLanguageCode]?.display?.fetch() {
                    switch result {
                    case .available:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? NutrientsImageTableViewCell
                        cell?.nutritionFactsImage = product!.nutritionImages[primaryLanguageCode]?.display?.image
                        cell?.editMode = editMode
                        return cell!
                    default:
                        searchResult = result.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? NoNutrientsImageTableViewCell //
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        cell?.editMode = editMode
                        return cell!
                    }

                // no image is available in either the current language or the primary language
                } else {
                    if editMode {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as? NutrientsImageTableViewCell
                        cell?.nutritionFactsImage = nil
                        cell?.editMode = editMode
                        cell?.tag = indexPath.section
                        return cell!
                    } else {
                        searchResult = ImageFetchResult.noImageAvailable.description()
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as? NoNutrientsImageTableViewCell //
                        cell?.width = tableView.frame.size.width
                        cell?.scheme = ColorSchemes.error
                        cell?.editMode = editMode
                        cell?.datasource = self
                        cell?.tag = indexPath.section
                        return cell!
                    }
                }
            // No image is available at all
            } else {
                if editMode {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Image, for: indexPath) as! NutrientsImageTableViewCell
                    cell.nutritionFactsImage = nil
                    cell.editMode = editMode
                    cell.tag = indexPath.section
                    return cell
                } else {
                    searchResult = ImageFetchResult.noImageAvailable.description()
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NoImage, for: indexPath) as! NoNutrientsImageTableViewCell
                    cell.width = tableView.frame.size.width
                    cell.scheme = ColorSchemes.error
                    cell.editMode = editMode
                    cell.datasource = self
                    cell.tag = indexPath.section
                    return cell
                }
            }

        case .addNutrient:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.AddNutrient, for: indexPath) as! AddNutrientTableViewCell
            cell.buttonText = NSLocalizedString("Add Nutrient", comment: "Title of a button in normal state allowing the user to add a nutrient")
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        let (currentProductSection, _, _) = tableStructureForProduct[section]
        switch currentProductSection {
        case .nutritionImage :
            return nil
        default:
            return header

        }
    }
    
    private struct Header {
        static let FontSize = CGFloat(18.0)
        static let HorizontalOffSet = CGFloat(20.0)
        static let VerticalOffSet = CGFloat(4.0)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (currentProductSection, _, _) = tableStructureForProduct[section]
        
        switch currentProductSection {
        case .nutritionImage :
            let (_, _, header) = tableStructureForProduct[section]

            /*
            let frame: CGRect = tableView.frame
            
            let headerLabel = UILabel.init(frame: CGRect.init(x: Header.HorizontalOffSet, y: Header.VerticalOffSet, width: 100.0, height: tableView.sectionHeaderHeight))
            headerLabel.text = (header != nil ? header! : "No header") + " - "
            headerLabel.font = UIFont.boldSystemFont(ofSize: Header.FontSize)
            headerLabel.sizeToFit()
            
            let changeCurrentLanguageButton = UIButton(frame: CGRect.init(x: Header.HorizontalOffSet + headerLabel.frame.size.width, y: -1.0, width: 50.0, height: tableView.sectionHeaderHeight)) //
            changeCurrentLanguageButton.setTitle(OFFplists.manager.languageName(for:currentLanguageCode), for: .normal)
            changeCurrentLanguageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: Header.FontSize - 2.0)
            changeCurrentLanguageButton.addTarget(self, action: #selector(NutrientsTableViewController.changeLanguageButtonTapped(sender:)), for: .touchUpInside)
            changeCurrentLanguageButton.sizeToFit()
            changeCurrentLanguageButton.isEnabled = editMode ? true : ( product!.languageCodes.count > 1 ? true : false )
            changeCurrentLanguageButton.isEnabled ? changeCurrentLanguageButton.setTitleColor(.blue, for: .normal) : changeCurrentLanguageButton.setTitleColor(.darkGray, for: .normal)
            */
            
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "LanguageHeaderView") as! LanguageHeaderView
            
            // headerView.customLabel.text = content[section].name  // set this however is appropriate for your app's model
            headerView.section = section
            headerView.delegate = self

            /*
            let headerView: LanguageHeaderView = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: tableView.frame.size.height)) as! LanguageHeaderView
            */
            headerView.title = header
            headerView.languageCode = currentLanguageCode
            headerView.buttonIsEnabled = editMode ? true : ( product!.languageCodes.count > 1 ? true : false )

            return headerView
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section >= 0 && indexPath.section < tableStructureForProduct.count {
            let (currentProductSection, _, _) = tableStructureForProduct[indexPath.section]
            
            switch currentProductSection {
            case .nutritionImage :
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
    
    fileprivate func setupTableSections() -> [(SectionType, Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType, Int, String?)] = []
        
        if query != nil {
            
            sectionsAndRows.append(
                ( SectionType.perUnitSearch,
                  TableSections.Size.PerUnit,
                  TableSections.Header.PerUnit ))
            
            if query!.allNutrimentsSearch.isEmpty {
                // Show a tag indicating no nutrition facts search has been specified
                sectionsAndRows.append((
                    SectionType.nutritionFactsSearch,
                    TableSections.Size.NutritionFactsEmpty,
                    TableSections.Header.NutritionFactItems))
            } else {
                // show a list with defined nutrition facts search
                sectionsAndRows.append((
                    SectionType.nutritionFactsSearch,
                    query!.allNutrimentsSearch.count,
                    TableSections.Header.NutritionFactItems))
            }
            
            sectionsAndRows.append((
                SectionType.servingSizeSearch,
                TableSections.Size.ServingSize,
                TableSections.Header.ServingSize))
            
            // Section 3 or 4 or 5: image section
            sectionsAndRows.append((
                SectionType.imageSearch,
                TableSections.Size.NutritionFactsImage,
                TableSections.Header.NutritionFactsImage))


        } else {

            guard product != nil else { return [] }
        // how does the user want the data presented
        switch Preferences.manager.showNutritionDataPerServingOrPerStandard {
        case .perStandard:
            // what is possible?
            switch product!.nutritionFactsAreAvailable {
            case .perStandardUnit, .perServingAndStandardUnit:
                showNutrientsAs = .perStandard
            case .perServing:
                showNutrientsAs = .perServing
            default:
                break
            }
        case .perServing:
            switch product!.nutritionFactsAreAvailable {
                // what is possible?
            case .perStandardUnit:
                showNutrientsAs = .perStandard
            case .perServing, .perServingAndStandardUnit:
                showNutrientsAs = .perServing
            default:
                break
            }
        case .perDailyValue:
            switch product!.nutritionFactsAreAvailable {
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
        
        // Are there any nutriments
        if ( !editMode && product!.hasNutritionFacts != nil && !product!.hasNutritionFacts! ) {
            // the product has no nutriments indicated
            sectionsAndRows.append(
                ( SectionType.noNutrimentsAvailable,
                  TableSections.Size.NutrimentsAvailable,
                  TableSections.Header.NutrimentsAvailable )
            )
        } else {
            
            // Section 0 : switch to indicate whether any nutritional data is available on the product
            
            if editMode {
                sectionsAndRows.append(
                    ( SectionType.noNutrimentsAvailable,
                      TableSections.Size.NutrimentsAvailable,
                      TableSections.Header.NutrimentsAvailable )
                )
            }
            
            // Section 0 or 1 : presentation format
            
            sectionsAndRows.append(
                ( SectionType.perUnit,
                  TableSections.Size.PerUnit,
                  TableSections.Header.PerUnit )
            )
        
            // Section 1 or 2 : nutrition facts
            
            if product!.nutritionFacts == nil || product!.nutritionFacts!.isEmpty {
                // Show a tag indicating no nutrition facts have been specified
                sectionsAndRows.append((
                    SectionType.nutritionFacts,
                    TableSections.Size.NutritionFactsEmpty,
                    TableSections.Header.NutritionFactItems))
            } else {
                // show a list with nutrition facts
                sectionsAndRows.append((
                    SectionType.nutritionFacts,
                    adaptedNutritionFacts.count,
                    TableSections.Header.NutritionFactItems))
            }
        
            // Section 2 or 3 or 4 : serving size
            
            sectionsAndRows.append((
                SectionType.servingSize,
                TableSections.Size.ServingSize,
                TableSections.Header.ServingSize))
        
            // Section 3 or 4 or 5: image section
            sectionsAndRows.append((
                SectionType.nutritionImage,
                TableSections.Size.NutritionFactsImage,
                TableSections.Header.NutritionFactsImage))
        
        }
        }
        return sectionsAndRows
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
                            button.superview?.superview as? NutrientsImageTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                ppc.delegate = self
                                
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentLanguageCode = currentLanguageCode
                                vc.primaryLanguageCode = delegate?.updatedProduct?.primaryLanguageCode != nil ? delegate!.updatedProduct!.primaryLanguageCode : product!.primaryLanguageCode
                                vc.languageCodes = product!.languageCodes
                                vc.updatedLanguageCodes = delegate?.updatedProduct != nil ? delegate!.updatedProduct!.languageCodes : []
                                vc.editMode = editMode
                                vc.delegate = delegate
                                vc.sourcePage = 2
                            }
                            // The button should be in a view,
                            // which is in a TableHeaderFooterView,
                            // which is in a TableView
                        } else if button.superview?.superview?.superview as? UITableView != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // leftMiddle(anchorFrame)
                                ppc.delegate = self
                                    
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentLanguageCode = currentLanguageCode
                                vc.primaryLanguageCode = delegate?.updatedProduct?.primaryLanguageCode != nil ? delegate!.updatedProduct!.primaryLanguageCode : product!.primaryLanguageCode
                                vc.languageCodes = product!.languageCodes
                                vc.updatedLanguageCodes = delegate?.updatedProduct != nil ? delegate!.updatedProduct!.languageCodes : []
                                vc.editMode = editMode
                                vc.delegate = delegate
                                vc.sourcePage = 2
                            }
                        }
                    }
                }
            case Storyboard.SegueIdentifier.ShowNutritionFactsImage:
                if let vc = segue.destination as? ImageViewController {
                    if delegate?.updatedProduct?.nutritionImages != nil && !delegate!.updatedProduct!.nutritionImages.isEmpty {
                        if let imageData = delegate!.updatedProduct!.nutritionImages[currentLanguageCode!]?.display {
                            vc.imageData = imageData
                        } else if let imageData = delegate!.updatedProduct!.nutritionImages[delegate!.updatedProduct!.primaryLanguageCode!]?.display {
                            vc.imageData = imageData
                        }
                        vc.imageTitle = Storyboard.Title.ShowNutritionFactsImage
                    } else if !product!.nutritionImages.isEmpty {
                        // is the data for the current language available?
                        // then fetch the image
                        if let imageData = product!.nutritionImages[currentLanguageCode!]?.largest() {
                            vc.imageData = imageData
                            vc.imageTitle = Storyboard.Title.ShowNutritionFactsImage
                            // try to use the primary image
                        } else if let imageData = product!.nutritionImages[product!.primaryLanguageCode!]?.largest() {
                            vc.imageData = imageData
                            vc.imageTitle = Storyboard.Title.ShowNutritionFactsImage
                        } else {
                            vc.imageData = nil
                        }
                    } else {
                        vc.imageData = nil
                    }
                }
            case Storyboard.SegueIdentifier.AddNutrient:
                if let vc = segue.destination as? AddNutrientViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? AddNutrientTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
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
                
            case Storyboard.SegueIdentifier.SelectNutrientUnit:
                if let vc = segue.destination as? SelectNutrientUnitViewController {
                    // The segue can only be initiated from a button within a BarcodeTableViewCell
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? NutrientsTableViewCell != nil {
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
                                if row >= 0 && row < adaptedNutritionFacts.count {
                                    vc.currentNutritionFactKey = adaptedNutritionFacts[row].key
                                }
                            }
                        } else if button.superview?.superview as? SearchNutrientsTableViewCell != nil {
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
                                if row >= 0 && row < query!.allNutrimentsSearch.count  {
                                    vc.currentNutritionUnit = query!.allNutrimentsSearch[row].unit
                                }
                            }
                        }
                    }
                }
                
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
                }

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
                if query != nil {
                    var nutrimentSearch = NutrimentSearch()
                    nutrimentSearch.key = newNutrientTuple.0 // key with en: prefix
                    nutrimentSearch.name = newNutrientTuple.1 // name in local language
                    nutrimentSearch.unit = newNutrientTuple.2 // default unit
                    query!.allNutrimentsSearch.append(nutrimentSearch)
                    tableView.reloadData()
                } else {
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
    }
    
    @IBAction func unwindSetNutrientUnit(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectNutrientUnitViewController {
            // The new nutrient unit should be set to the nutrient that was edited
            if let nutrientRow = vc.nutrientRow {
                if product != nil {
                    // copy the existing nutrient and change the unit
                    var editedNutritionFact = NutritionFactItem()
                    editedNutritionFact.key = adaptedNutritionFacts[nutrientRow].key
                    editedNutritionFact.itemName = adaptedNutritionFacts[nutrientRow].name
                    // this value has been changed
                    editedNutritionFact.standardValueUnit = vc.selectedNutritionUnit
                    editedNutritionFact.standardValue = adaptedNutritionFacts[nutrientRow].value
                    delegate?.updated(fact: editedNutritionFact)
                    refreshProductWithNewNutritionFacts()
                } else if query != nil {
                    if let validUnit = vc.selectedNutritionUnit {
                        query!.allNutrimentsSearch[nutrientRow].unit = validUnit
                        tableView.reloadData()
                    }
                }
            }
        }
    }

    
    @IBAction func unwindSetComparisonOperator(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? SelectCompareViewController {
            // The new comparison operator should be set to the nutrient that was edited
            if let nutrientRow = vc.nutrientRow,
            let selectedOperator = vc.selectedCompareOperator {
                query!.allNutrimentsSearch[nutrientRow].searchOperator = selectedOperator
                tableView.reloadData()
            }
        }
    }

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
            performSegue(withIdentifier: Storyboard.SegueIdentifier.AddNutrient, sender: sender)
        }
    }

    func showNutrimentUnitSelector(_ notification: Notification) {
        if let sender = notification.userInfo?[NutrientsTableViewCell.Notification.ChangeNutrientUnitButtonTappedKey] {
            performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectNutrientUnit, sender: sender)
        } else if let sender = notification.userInfo?[SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientUnitButtonTappedKey] {
            performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectNutrientUnit, sender: sender)
        }
    }
    
    func reloadImageSection() { // (_ notification: Notification) {
        tableView.reloadData()
    }

    func refreshProductWithNewNutritionFacts() {
        if product != nil {
        // recalculate the nutritionfacts that must be shown
        mergeNutritionFacts()
        tableStructureForProduct = setupTableSections()
        tableView.reloadData()
        } else if query != nil {
            tableStructureForProduct = setupTableSections()
            tableView.reloadData()
        }
    }

    func takePhotoButtonTapped() {
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
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        picker.imagePickerController!.modalPresentationStyle = .formSheet
        picker.sourceType = .savedPhotosAlbum
        // picker.mediaTypes = [kUTTypeImage as String] <
        return picker
    }()

    func useCameraRollButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen
            imagePicker.delegate = self
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = tableView.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
    
    fileprivate func newImageSelected(info: [String : Any]) {
        var image: UIImage? = nil
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        if image != nil {
            delegate?.updated(nutritionImage: image!, languageCode: currentLanguageCode!)
            tableView.reloadData()
        }
    }
    

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    func imageUploaded(_ notification: Notification) {
        // Check if this image is relevant to this product
        if let barcode = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessBarcodeKey] as? String {
            if product != nil && barcode == product!.barcode.asString() {
                // is it relevant to the main image?
                if let id = notification.userInfo?[OFFUpdate.Notification.ImageUploadSuccessImagetypeKey] as? String {
                    if id.contains(OFFHttpPost.AddParameter.ImageField.Value.Nutrition) {
                        // reload product data
                        OFFProducts.manager.reload(self.product!)
                    }
                }
            }
        }
    }
    
    

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        
        tableView.register(UINib(nibName: "LanguageHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LanguageHeaderView")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Storyboard.Title.ViewController
        
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
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.showNutrimentUnitSelector(_:)), name: .ChangeSearchNutrientUnitButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.reloadImageSection), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.takePhotoButtonTapped), name:.NutritionTakePhotoButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.useCameraRollButtonTapped), name:.NutritionSelectFromCameraRollButtonTapped, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IdentificationTableViewController.imageUploaded), name:.OFFUpdateImageUploadSuccess, object:nil)

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
        // is this the nutrients section?
        if section > 100 {
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
        case .nutritionFacts:
            // decode the actual row from the tag by subtracting the section*100
            let row = textField.tag % 100
            // print(textField.tag, row)
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
        default:
            break
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
        if tagListView.tag >= 0 && tagListView.tag < tableStructureForProduct.count {
            let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
            switch currentProductSection {
            case .nutritionImage, .nutritionFacts:
                return 1
            case .servingSizeSearch, .nutritionFactsSearch, .imageSearch, .perUnitSearch:
                return 1
            default:
                break
            }
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        let (currentProductSection, _, _) = tableStructureForProduct[tagListView.tag]
        
        switch currentProductSection {
        case .nutritionImage:
            return searchResult
        case .nutritionFacts:
            return nutritionFactsTagTitle
        case .nutritionFactsSearch:
            if query != nil {
                if query!.allNutrimentsSearch.isEmpty {
                    return "none"
                } else {
                    if tagListView.tag >= 0 && tagListView.tag < query!.allNutrimentsSearch.count {
                        return query!.allNutrimentsSearch[tagListView.tag].key
                    }
                }
            }
        case .servingSizeSearch, .imageSearch, .perUnitSearch:
            return notSearchableToDisplay.tag(at: index)!
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
        // notify the delegate
    }
    
}


extension NutrientsTableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        
        print("nutrients image", image.size)
        delegate?.updated(nutritionImage: image, languageCode: currentLanguageCode!)
        tableView.reloadData()
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LanguageHeaderDelegate Functions

extension NutrientsTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.ShowNutritionImageLanguages, sender: sender)
    }
}


