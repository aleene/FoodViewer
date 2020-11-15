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
    
// MARK: - public variables
    
    public var coordinator: NutrientsCoordinator? = nil

    public var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                refreshInterface()
            }
        }
    }
    
    public var currentLanguageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
        set {
            delegate?.currentLanguageCode = newValue
        }
    }
// MARK: - private variables
    
    private var adaptedNutritionFacts: [DisplayFact] = []

// MARK: - fileprivate variables
    
    
    // setup the current display modes to app wide defaults
    fileprivate var currentNutritionQuantityDisplayMode: NutritionDisplayMode = .perStandard

    private var validNutritionQuantityDisplayMode: NutritionDisplayMode {
        // It must be checked whether the current quantity display mode is valid for the current product
            // set the selected segment at start up
            // this depends however on the availablity
        switch currentNutritionQuantityDisplayMode {
        case .perStandard:
            if let validAvailability = productPair?.remoteProduct?.nutritionFactsAreAvailable {
                switch validAvailability {
                case .perServing:
                    // standard is not available for this product
                    return .perServing
                default:
                    return .perStandard
                }
            }
        case .perThousandGram:
            if let validAvailability = productPair?.remoteProduct?.nutritionFactsAreAvailable {
                switch validAvailability {
                case .perServing:
                    // standard is not available for this product
                    return .perServing
                default:
                    return .perThousandGram
                }
            }
        case .perServing:
            if let validAvailability = productPair?.remoteProduct?.nutritionFactsAreAvailable {
                switch validAvailability {
                case .perStandardUnit:
                    return .perStandard
                default:
                    return .perServing
                }
            }
        case .perDailyValue:
            if let validAvailability = productPair?.remoteProduct?.nutritionFactsAreAvailable {
                switch validAvailability {
                case .perStandardUnit:
                    return .perStandard
                default:
                    return .perDailyValue
                }
            }
        }
        return .perStandard
    }
    
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
    private var uploadProgressRatio: CGFloat? = nil

    
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
            // In Europe energy data on the package is available in kJ and kcal
            // Due to regulation conversion between the two is not possible
            // SO, both fields need to be entered/available.
                
            // Has the data been entered in kJ?
            } else if fact.key == Nutrient.energy.rawValue  {
                let useEnergyDisplayMode = editMode ? .joule : currentEnergyDisplayMode
                switch useEnergyDisplayMode {
                    // show energy as Calories (US)
                case .calories:
                    newFact = NutritionFactItem.init(
                            name: OFFplists.manager.translateNutrient(nutrient: .energy, language:Locale.preferredLanguages[0]),
                            standard: fact.value.valueInCalories(fact.value.standard),
                            standardUnit: EnergyUnitUsed.calories.unit(),
                            value: fact.value.valueInCalories(fact.value.value),
                            valueUnit: fact.value.valueUnit?.short,
                            serving: fact.value.valueInCalories(fact.value.serving),
                            valueEdited: fact.value.valueInCalories(fact.value.valueEdited),
                            valueUnitEdited: fact.value.valueUnitEdited?.short,
                            nutrient: .energy)
                    // show energy as kcalorie
                case .kilocalorie:
                    newFact = NutritionFactItem.init(
                        name: OFFplists.manager.translateNutrient(nutrient: .energy, language:Locale.preferredLanguages[0]),
                        standard: fact.value.valueInCalories(fact.value.standard),
                        standardUnit: EnergyUnitUsed.kilocalorie.unit(),
                        value: fact.value.valueInCalories(fact.value.value),
                        valueUnit: fact.value.valueUnit?.short,
                        serving: fact.value.valueInCalories(fact.value.serving),
                        valueEdited: fact.value.valueInCalories(fact.value.valueEdited),
                        valueUnitEdited: fact.value.valueUnitEdited?.short,
                        nutrient: .energy)
                default:
                    // no conversion necessary
                    newFact = fact.value
                }
                
            // Has the data been entered in kcal?
            } else if fact.key == Nutrient.energyKcal.rawValue {
                let useEnergyDisplayMode = editMode ? .kilocalorie : currentEnergyDisplayMode
                switch useEnergyDisplayMode {
                    // show energy as Calories (US)
                case .calories:
                    newFact = NutritionFactItem.init(
                            name: OFFplists.manager.translateNutrient(nutrient: .energyKcal, language:Locale.preferredLanguages[0]),
                            standard: fact.value.standard,
                            standardUnit: EnergyUnitUsed.calories.unit(),
                            value: fact.value.value,
                            valueUnit: fact.value.valueUnit?.short,
                            serving: fact.value.serving,
                            valueEdited: fact.value.valueEdited,
                            valueUnitEdited: fact.value.valueUnitEdited?.short,
                            nutrient: .energyKcal)
                // show energy as kcalorie
                case .kilocalorie:
                    newFact = NutritionFactItem.init(
                        name: OFFplists.manager.translateNutrient(nutrient: .energyKcal, language:Locale.preferredLanguages[0]),
                        standard: fact.value.standard,
                        standardUnit: EnergyUnitUsed.kilocalorie.unit(),
                        value: fact.value.value,
                        valueUnit: fact.value.valueUnit?.short,
                        serving: fact.value.serving,
                        valueEdited: fact.value.valueEdited,
                        valueUnitEdited: fact.value.valueUnitEdited?.short,
                        nutrient: .energyKcal)
                default:
                    newFact = NutritionFactItem.init(
                        name: OFFplists.manager.translateNutrient(nutrient: .energyKcal, language:Locale.preferredLanguages[0]),
                        standard: fact.value.valueInJoule(fact.value.standard),
                        standardUnit: EnergyUnitUsed.joule.unit(),
                        value: nil,
                        valueUnit: fact.value.valueUnit?.short,
                        serving: fact.value.valueInJoule(fact.value.serving),
                        valueEdited: fact.value.valueEdited,
                        valueUnitEdited: fact.value.valueUnitEdited?.short,
                        nutrient: .energyKcal)

                    newFact?.standardUnit = .joule
                }
            } else if fact.key == Nutrient.energyFromFat.rawValue {
                let useEnergyDisplayMode = editMode ? .kilocalorie : currentEnergyDisplayMode
                switch useEnergyDisplayMode {
                    // show energy as Calories (US)
                case .calories:
                    //  The interpreted data from OFF is always in kJ !!!!!
                    newFact = NutritionFactItem.init(
                        name: OFFplists.manager.translateNutrient(
                            nutrient: .energyFromFat,
                            language:Locale.preferredLanguages[0]),
                        standard: fact.value.valueInCalories(fact.value.standard),
                        standardUnit: EnergyUnitUsed.calories.unit(),
                        value: fact.value.value,
                        valueUnit: fact.value.valueUnit?.short ?? EnergyUnitUsed.calories.unit(),
                        serving: fact.value.valueInCalories(fact.value.serving),
                        valueEdited: fact.value.valueEdited,
                        valueUnitEdited: fact.value.valueUnitEdited?.short ?? EnergyUnitUsed.calories.unit(),
                        nutrient: .energyFromFat)
                // show energy as kcalorie
                case .kilocalorie:
                    newFact = NutritionFactItem.init(
                        name: OFFplists.manager.translateNutrient(
                            nutrient: .energyFromFat,
                            language:Locale.preferredLanguages[0]),
                        standard: fact.value.valueInCalories(fact.value.standard),
                        standardUnit: EnergyUnitUsed.kilocalorie.unit(),
                        value: fact.value.value,
                        valueUnit: fact.value.valueUnit?.short ?? EnergyUnitUsed.kilocalorie.unit(),
                        serving: fact.value.valueInCalories(fact.value.serving),
                        valueEdited: fact.value.valueEdited,
                        valueUnitEdited: fact.value.valueUnitEdited?.short ?? EnergyUnitUsed.kilocalorie.unit(),
                        nutrient: .energyFromFat)
                default:
                    newFact = NutritionFactItem.init(
                        name: OFFplists.manager.translateNutrient(
                            nutrient: .energyFromFat,
                            language:Locale.preferredLanguages[0]),
                        standard: fact.value.standard,
                        standardUnit: EnergyUnitUsed.joule.unit(),
                        value: nil,
                        valueUnit: fact.value.valueUnit?.short ?? EnergyUnitUsed.joule.unit(),
                        serving: fact.value.serving,
                        valueEdited: fact.value.valueEdited,
                        valueUnitEdited: fact.value.valueUnitEdited?.short ?? EnergyUnitUsed.joule.unit(),
                        nutrient: .energyFromFat)

                    newFact?.standardUnit = .joule
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
        // The values as processed by OFF are used
        switch validNutritionQuantityDisplayMode {
        case .perStandard:
            // Show in editMode the edited value if there is one,
            // Otherwise show the standard value
            if productPair?.localProduct != nil,
                let validValue = fact.valueEdited {
                displayFact.value = validValue
                displayFact.unit = fact.valueUnitEdited
            // Show the values as derived by OFF
            } else if let validValue = fact.standard,
                !validValue.isEmpty {
                displayFact.value = validValue
                displayFact.unit = fact.standardUnit
            } else {
                // Show the values entered by the user as provided by OFF
                (displayFact.value, displayFact.unit) = fact.localeStandardValue(editMode: editMode)
            }
        case .perThousandGram:
            // if there is a local product
            // and this fact has been edited
            // show the edited value in the edited unit ?????
            if productPair?.localProduct != nil,
                let validValue = fact.valueEdited {
                displayFact.value = validValue
                displayFact.unit = fact.valueUnitEdited
            // Show the values as derived by OFF
            } else if let validValue = fact.standard,
                !validValue.isEmpty {
                // multiply the standard values by 10
                (displayFact.value, displayFact.unit) = fact.localeThousandValue(editMode: false)
            } else {
                // Show the values entered by the user as provided by OFF
                // Does this ever happen?
                (displayFact.value, displayFact.unit) = fact.localeStandardValue(editMode: editMode)
            }
        case .perServing:
            if productPair?.localProduct != nil,
                let validValue = fact.valueEdited {
                displayFact.value = validValue
                displayFact.unit = fact.valueUnitEdited
                // Show the values as derived by OFF
            } else if let validValue = fact.serving {
                displayFact.value =  validValue
                displayFact.unit = fact.standardUnit
            } else {
                // Show the values entered by the user as provided by OFF
                (displayFact.value, displayFact.unit) = fact.localeStandardValue(editMode: editMode)
            }
        case .perDailyValue:
            if productPair?.localProduct != nil,
                let validValue = fact.valueEdited {
                displayFact.value = validValue
                displayFact.unit = fact.valueUnitEdited
                // Show the values as derived by OFF
            } else if fact.serving != nil {
                (displayFact.value, displayFact.unit) =  fact.dailyValuePercentage
            } else {
                // Show the values entered by the user as provided by OFF
                (displayFact.value, displayFact.unit)  = fact.localeStandardValue(editMode: editMode)
            }
        }
        // convert values to easier readable units
        switch displayFact.unit {
        case .gram:
            let (value, unit) = NutritionFactUnit.normalize(displayFact.value)
            displayFact.value = value
            displayFact.unit = unit
        default: break
        }
        displayFact.nutrient = fact.nutrient
        return displayFact
    }
    
    // The functions creates a mixed array of edited and unedited nutrients
    
    fileprivate func mergeNutritionFacts() {
        switch productVersion {
        case .remote:
            adaptedNutritionFacts = adaptNutritionFacts(productPair?.remoteProduct?.nutritionFactsDict ?? [:])
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
            let cell = tableView.dequeueReusableCell(withIdentifier: NutrimentsAvailableTableViewCell.identifier + "." + NutrientsTableViewController.identifier, for: indexPath) as! NutrimentsAvailableTableViewCell
            cell.editMode = editMode
            if productPair?.localProduct?.nutrimentFactsAvailability != nil {
                cell.editMode = productVersion.isRemote ? false : true
            }

            cell.delegate = self
            switch productVersion {
            case .remote:
                cell.hasNutrimentFacts = productPair?.remoteProduct?.nutrimentFactsAvailability
            case .new:
                cell.hasNutrimentFacts = productPair?.localProduct?.nutrimentFactsAvailability ?? productPair?.remoteProduct?.nutrimentFactsAvailability
            }
            return cell
            
        case .perUnit:
            let cell = tableView.dequeueReusableCell(withIdentifier: PerUnitTableViewCell.identifier + "." + NutrientsTableViewController.identifier, for: indexPath) as! PerUnitTableViewCell
            
            cell.setup(nutritionFactsAvailability: productPair?.localProduct?.nutritionFactsAreAvailable
                                                    ?? productPair?.remoteProduct?.nutritionFactsAreAvailable,
                  displayMode: validNutritionQuantityDisplayMode,
                  editMode: productPair?.localProduct?.nutritionFactsIndicationUnit != nil ? productVersion.isRemote ? false : true : editMode,
                  delegate: self)
            return cell
            
        case .nutritionFacts:
            if indexPath.row == tableStructure[indexPath.section].numberOfRows && editMode {
                // This cell should only be added when in editMode and as the last row
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: AddNutrientTableViewCell.self), for: indexPath) as! AddNutrientTableViewCell
                cell.delegate = self
                cell.buttonText = TranslatableStrings.AddNutrient
                return cell
            } else {
                if adaptedNutritionFacts.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:TagListViewTableViewCell.self), for: indexPath) as? TagListViewTableViewCell
                    cell?.setup(datasource: self, delegate: nil, width: tableView.frame.size.width, tag: indexPath.section)
                    return cell!
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:NutrientsTableViewCell.self), for: indexPath) as? NutrientsTableViewCell
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
                        cell?.unitButtonIsEnabled = editMode ? true : false
                        cell?.toggleViewModeButton.isHidden = editMode ? true : !buttonNotDoubleTap
                    } else if  adaptedNutritionFacts[indexPath.row].nutrient.key == LocalizedEnergy.key
                        || adaptedNutritionFacts[indexPath.row].nutrient.key == LocalizedEnergyKcal.key
                        || adaptedNutritionFacts[indexPath.row].nutrient.key == LocalizedEnergyFromFat.key {
                        if !editMode && !buttonNotDoubleTap {
                            let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnEnergyTableViewCell))
                            doubleTapGestureRecognizer.numberOfTapsRequired = 2
                            doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                            doubleTapGestureRecognizer.cancelsTouchesInView = false
                            doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                            cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                        }
                        // In editMode the user may not change the units. They are fixed to kJ and kcal.
                        cell?.unitButtonIsEnabled = false
                        cell?.toggleViewModeButton.isHidden = editMode ? true : !buttonNotDoubleTap
                    } else {
                        cell?.unitButtonIsEnabled = editMode ? true : false
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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ServingSizeTableViewCell.self), for: indexPath) as! ServingSizeTableViewCell
            cell.servingSizeTextField.delegate = self
            cell.servingSizeTextField.tag = indexPath.section
            cell.editMode = editMode
            switch productVersion {
            case .remote:
                cell.servingSize = productPair?.remoteProduct?.servingSize
            case .new:
                cell.servingSize = productPair?.localProduct?.servingSize ?? productPair?.remoteProduct?.servingSize
            }
            return cell

        case .image:
            if currentImage != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:  ProductImageTableViewCell.self), for: indexPath) as! ProductImageTableViewCell
                cell.editMode = editMode
                cell.productImage = currentImage
                cell.uploadTime = imageUploadDate
                // show the up-/download ratio
                cell.progressRatio = self.uploadProgressRatio
                cell.delegate = self
                return cell
            } else {
                // Show a tag with the option to set an image
                let cell = tableView.dequeueReusableCell(withIdentifier: TagListViewAddImageTableViewCell.identifier + "." + NutrientsTableViewController.identifier, for: indexPath) as! TagListViewAddImageTableViewCell
                cell.accessoryType = .none
                cell.setup(datasource: self, delegate: self, editMode: editMode, width: tableView.frame.size.width, tag: indexPath.section, prefixLabelText: nil, scheme: ColorSchemes.error)
                return cell
            }

        case .addNutrient:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: AddNutrientTableViewCell.self), for: indexPath) as! AddNutrientTableViewCell
            cell.buttonText = TranslatableStrings.AddNutrient
            cell.delegate = self
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
    
    private var errorMessage: String?
    private var imageUploadDate: Double?
    
    private var remoteImageToShow: UIImage? {
        func processLanguageCode(_ languageCode: String) -> UIImage? {
            guard let imageSet = productPair?.remoteProduct?.image(for: languageCode, of: .nutrition) else { return nil }
            let result = imageSet.original?.fetch()
            switch result {
            case .success(let image):
                imageUploadDate = imageSet.imageDate
                return image
            case .loading, .noResponse:
                errorMessage = result?.description
                imageUploadDate = imageSet.imageDate
                return nil
            case .loadingFailed(let error):
                errorMessage = error.localizedDescription
                imageUploadDate = imageSet.imageDate
                return nil
            default:
                return nil
            }
        }
        
        guard let validDisplayLanguageCode = displayLanguageCode else { return nil }
        guard let validPrimaryLanguageCode = productPair?.remoteProduct?.primaryLanguageCode else { return nil }
        
        if editMode {
            return processLanguageCode(validDisplayLanguageCode)
        } else {
            return processLanguageCode(validDisplayLanguageCode) ?? processLanguageCode(validPrimaryLanguageCode)
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? TagListViewAddImageTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? NoNutrientsImageTableViewCell {
            validCell.willDisappear()
        }   else if let validCell = cell as? NutrientsTableViewCell {
            if let gestures = validCell.gestureRecognizers {
                for gesture in gestures {
                    if let doubleTapGesture = gesture as? UITapGestureRecognizer,
                    doubleTapGesture.numberOfTapsRequired == 2,
                        doubleTapGesture.numberOfTouchesRequired == 1 {
                        validCell.removeGestureRecognizer(gesture)
                    }
                }
            }
            validCell.willDisappear()
        }
        

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
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LanguageHeaderView.identifier) as! LanguageHeaderView
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        headerView.changeLanguageButton.isHidden = true
        headerView.buttonNotDoubleTap = nil

        switch currentProductSection {
        case .image :
            
            if let validNumberOfProductLanguages = productPair?.remoteProduct?.languageCodes.count {
            // Hide the change language button if there is only one language, but not in editMode
                headerView.changeLanguageButton.isHidden = validNumberOfProductLanguages > 1 ? false : !editMode
            } else {
                headerView.changeLanguageButton.isHidden = false
            }
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
            headerView.title = header + " "
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
            headerView.title = header + " "
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
                    header = TranslatableStrings.DisplayUnitEdited
                } else {
                    header = TranslatableStrings.DisplayUnit
                }
            default:
                header = TranslatableStrings.DisplayUnit
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
    
    fileprivate struct Constants {
        struct CellHeight {
            //static let TagListViewCell = CGFloat(27.0)
            static let TagListViewAddImageCell = 2 * CGFloat(25.0) + CGFloat(8.0)
        }
        struct CellMargin {
            static let ContentView = CGFloat(11.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let validView = view as? LanguageHeaderView {
            validView.willDisappear()
        }
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableStructure[indexPath.section] {
        case .image:
            if currentImage != nil {
                // The height is determined by the image
                return UITableView.automaticDimension
            } else {
                // the height is determined by the buttons
                let height = Constants.CellHeight.TagListViewAddImageCell
                return height + 2 * Constants.CellMargin.ContentView
            }
        default:
            return UITableView.automaticDimension
        }

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
        switch tableStructure[indexPath.section] {
        case .image:
            if let validLanguageCode = displayLanguageCode {
                if let images = productPair?.localProduct?.nutritionImages,
                    !images.isEmpty {
                    coordinator?.showImage(imageTitle: TranslatableStrings.NutritionFactsImage,
                                           imageSize: productPair!.localProduct!.image(for:validLanguageCode, of:.nutrition))
                } else {
                    coordinator?.showImage(imageTitle: TranslatableStrings.NutritionFactsImage,
                                           imageSize: productPair!.remoteProduct!.image(for:validLanguageCode, of:.nutrition))
                }
            }
        default:
            break
        }

        
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

    public func setNutritionFactUnit(for row: Int?, with nutritionFactUnit:NutritionFactUnit?) {
        if let nutrientRow = row {
            productPair?.update(nutrient: adaptedNutritionFacts[nutrientRow].nutrient, unit: nutritionFactUnit, perUnit: validNutritionQuantityDisplayMode.nutritionEntryUnit)
            refreshProduct()
        }
    }
    
    public func setNutritionFactsTableStyle(to nutritionFactsTableStyle: NutritionFactsLabelStyle?) {
        // The user decided to not follow the global preferences
        currentTableStyleSetter = .user
        if let validSelectedNutritionFactsTableStyle = nutritionFactsTableStyle {
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
                        productPair?.add(fact: NutritionFactItem.init(nutrient: nutrient, unit: nutrient.unit(for:validSelectedNutritionFactsTableStyle)))
                    }
                }
            }
            refreshProduct()
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

        // only update if the image barcode corresponds to the current product
        guard let currentProductBarcode = productPair?.remoteProduct?.barcode.asString else { return }
        guard let noticifationBarcode = notification.userInfo?[ProductImageData.Notification.BarcodeKey] as? String else { return }
        guard currentProductBarcode == noticifationBarcode else { return }
        
        // We can not check the imageType,
        // as the image might be retrieved from disk
        // is it relevant to the main image?
        //guard let id = notification.userInfo?[ProductImageData.Notification.ImageTypeCategoryKey] as? String else { return }
        //guard id.contains(OFFHttpPost.AddParameter.ImageField.Value.Front) else { return }
        
        self.uploadProgressRatio = nil
        reloadImageSection()
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
    
    /// Function that handles image upload progress notifications
    @objc func progress(_ notification: Notification) {
        guard !editMode else { return }
        // Check if this upload progress is relevant to this product
        guard let barcode = notification.userInfo?[OFFImageUploadAPI.Notification.BarcodeKey] as? String else { return }
        guard let productBarcode = productPair!.remoteProduct?.barcode.asString else { return }
        guard barcode == productBarcode else { return }
                    // is it relevant to the main image?
        guard let id = notification.userInfo?[OFFImageUploadAPI.Notification.ImageTypeCategoryKey] as? String else { return }
        guard id.contains(OFFHttpPost.AddParameter.ImageField.Value.Nutrition) else  { return }
        guard let progress = notification.userInfo?[OFFImageUploadAPI.Notification.ProgressKey] as? String else { return }
        guard let progressDouble = Double(progress) else { return }
        self.uploadProgressRatio = CGFloat(progressDouble)
        // reload the tabel to update the progress indicator
        self.tableView.reloadData()
    }

//
// MARK: - ViewController Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinator = NutrientsCoordinator.init(with: self)

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 70
        
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)

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
            name: .ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(
            self,
            selector:#selector(NutrientsTableViewController.refreshProduct),
            name: .ProductPairRemoteStatusChanged, object:nil
        )
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.refreshProduct), name:.ProductPairLocalStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.imageUpdated(_:)), name:.ImageSet, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.imageUploaded), name:.ProductPairImageUploadSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.imageDeleted(_:)), name:.ProductPairImageDeleteSuccess, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.progress(_:)), name:.ImageUploadProgress, object:nil)

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

// MARK: - NutrientsCellDelegate functions

extension NutrientsTableViewController: NutrientsCellDelegate {

    func nutrientsTableViewCell(_ sender: NutrientsTableViewCell, receivedTapOn button:UIButton) {
        // depending on the cell, a button might be present
        // and an other action will invoked
        let row = button.tag % 100
        // only add taps gestures when NOT in editMode
        if !editMode {
            if  adaptedNutritionFacts[row].nutrient.rawValue ==   NatriumChloride.salt.key
                || adaptedNutritionFacts[row].nutrient.rawValue == NatriumChloride.sodium.key {
                doubleTapOnSaltSodiumTableViewCell()
            } else if  adaptedNutritionFacts[row].nutrient.key == LocalizedEnergy.key
                || adaptedNutritionFacts[row].nutrient.key == LocalizedEnergyKcal.key
                || adaptedNutritionFacts[row].nutrient.key == LocalizedEnergyFromFat.key {
               doubleTapOnEnergyTableViewCell()
            }
        }

    }
    /// The NutrientsTableViewCell unit button has been tapped. The coordinator should handle this event.
    func nutrientsTableViewCellUnit(_ sender: NutrientsTableViewCell, nutrient: Nutrient?, unit: NutritionFactUnit?, receivedTapOn button: UIButton) {
        coordinator?.showNutrientUnitSelector(for: self.productPair, nutrient: nutrient, unit: unit, perUnit: validNutritionQuantityDisplayMode.nutritionEntryUnit, anchoredOn: button)
    }

}
//
// MARK: - AddNutrientCellDelegate functions
//
extension NutrientsTableViewController:  AddNutrientCellDelegate {
    
    func addNutrientTableViewCell(_ sender: AddNutrientTableViewCell, tappedOn button: UIButton) {
        coordinator?.showAddNutrientSelector(for: self.productPair, current: adaptedNutritionFacts.compactMap { $0.name }, anchoredOn: button)
    }
    
    
    // function to let the delegate know that the switch changed
    func addEUNutrientSetTableViewCell(_ sender: AddNutrientTableViewCell, receivedTapOn button:UIButton) {
        
        // Energy
        if !productPair!.remoteProduct!.nutritionFactsContain(.energy) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .energy, unit: .joule))
        }
        // Energy kcal
        if !productPair!.remoteProduct!.nutritionFactsContain(.energyKcal) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .energyKcal, unit: .kiloCalories))
        }
        // Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.fat) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .fat, unit: .gram))
        }
        // Saturated Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.saturatedFat) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .saturatedFat, unit: .gram))
        }
        // Carbohydrates
        if !productPair!.remoteProduct!.nutritionFactsContain(.carbohydrates) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .carbohydrates, unit: .gram))
        }
        // Sugars
        if !productPair!.remoteProduct!.nutritionFactsContain(.sugars) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .sugars, unit: .gram))
        }
        // Fibers
        if !productPair!.remoteProduct!.nutritionFactsContain(.fiber) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .fiber, unit: .gram))
        }
        // Proteins
        if !productPair!.remoteProduct!.nutritionFactsContain(.proteins) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .proteins, unit: .gram))
        }
        // Salt
        if !productPair!.remoteProduct!.nutritionFactsContain(.salt) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .salt, unit: .gram))
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
        if !productPair!.remoteProduct!.nutritionFactsContain(.energyKcal) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .energyKcal, unit: .calories))
        }
        // Energy from Fat Old Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.energyFromFat) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .energyFromFat, unit: .calories))
        }

        // Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.fat) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .fat, unit: .gram))
        }
        // Saturated Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.saturatedFat) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .saturatedFat, unit: .gram))
        }
        // Trans Fat
        if !productPair!.remoteProduct!.nutritionFactsContain(.transFat) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .transFat, unit: .gram))
        }

        // Cholesterol
        if !productPair!.remoteProduct!.nutritionFactsContain(.cholesterol) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .cholesterol, unit: .milligram))
        }
        // Sodium
        if !productPair!.remoteProduct!.nutritionFactsContain(.sodium) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .sodium, unit: .gram))
        }
        // Total Carbohydrates
        if !productPair!.remoteProduct!.nutritionFactsContain(.carbohydrates) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .carbohydrates, unit: .gram))
        }
        // Dietary Fiber
        if !productPair!.remoteProduct!.nutritionFactsContain(.fiber) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .fiber, unit: .gram))
        }

        // Sugars
        if !productPair!.remoteProduct!.nutritionFactsContain(.sugars) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .sugars, unit: .gram))
        }
        // Added Sugars New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.addedSugars) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .addedSugars, unit: .gram))
        }

        // Proteins
        if !productPair!.remoteProduct!.nutritionFactsContain(.proteins) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .proteins, unit: .gram))
        }
        // Vitamin A New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.vitaminA) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .vitaminA, unit: .percent))
        }
        // Vitamin C Old Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.vitaminC) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .vitaminC, unit: .milligram))
        }
        // Vitamin D New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.vitaminD) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .vitaminD, unit: .milligram))
        }

        // Calcium
        if !productPair!.remoteProduct!.nutritionFactsContain(.calcium) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .calcium, unit: .milligram))
        }
        // Iron Old Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.iron) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .iron, unit: .milligram))
        }
        // Potassium New Label
        if !productPair!.remoteProduct!.nutritionFactsContain(.potassium) {
            productPair?.add(fact: NutritionFactItem.init(nutrient: .potassium, unit: .milligram))
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
//
// MARK: - TextFieldDelegate functions
//
extension NutrientsTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if #available(iOS 13.0, *) {
            textField.textColor = .label
        } else {
            textField.textColor = .darkGray
        }
    }
    
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
                // Any new values will be in the current per setting
                // And will be written as NutritionFactValue
                if validNutritionQuantityDisplayMode == .perStandard {
                    editedNutritionFact.valueUnitEdited = adaptedNutritionFacts[row].unit

                    // this value has been changed
                    if let text = textField.text {
                        editedNutritionFact.valueEdited = String(text.map {
                            $0 == "," ? "." : $0
                        })
                        
                    }
                } else if validNutritionQuantityDisplayMode == .perServing {
                    editedNutritionFact.valueUnitEdited = adaptedNutritionFacts[row].unit

                    // this value has been changed
                    if let text = textField.text {
                        editedNutritionFact.valueEdited = String(text.map {
                            $0 == "," ? "." : $0
                        })
                    }
                } else if validNutritionQuantityDisplayMode == .perDailyValue {
                    editedNutritionFact.valueUnitEdited = adaptedNutritionFacts[row].unit

                    // this value has been changed
                    if let text = textField.text {
                        editedNutritionFact.valueEdited = String(text.map {
                            $0 == "," ? "." : $0
                        })
                    }
                } else if validNutritionQuantityDisplayMode == .perThousandGram {
                    editedNutritionFact.valueUnitEdited = adaptedNutritionFacts[row].unit
                    
                    // this value has been changed
                    if let validText = textField.text {
                        editedNutritionFact.valueEdited = String(validText.map {
                            $0 == "," ? "." : $0
                        })
                        if let validType = type,
                            let validValue = editedNutritionFact.value {
                            switch validType {
                            case .petFood:
                                if let floatValue = Float(validValue) {
                                    // floatValue = floatValue / 10.0
                                    let numberFormatter = NumberFormatter()
                                    numberFormatter.numberStyle = .decimal
                                    editedNutritionFact.valueEdited = numberFormatter.string(from: NSNumber(value: floatValue))
                                }
                            default: break
                            }
                        }
                    }
                }
                // Warning, this might change the settings for all values
                productPair?.update(fact: editedNutritionFact, perUnit: validNutritionQuantityDisplayMode.nutritionEntryUnit)
                mergeNutritionFacts()
            }
        default:
            break
        }
        if #available(iOS 13.0, *) {
            textField.textColor = .secondaryLabel
        } else {
            textField.textColor = .black
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
            // Will only be shown when there are no nutrients specified
            return TranslatableStrings.NoNutritionDataIndicated
        case .image:
            return ImageFetchResult.noImageAvailable.description

        default:
            break
        }
        return("tagListView error")
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
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
            guard let primaryLanguageCode = self.productPair?.primaryLanguageCode else { return }
            guard let languageCodes = self.productPair?.languageCodes else { return }
            coordinator?.selectLanguage(primaryLanguageCode: primaryLanguageCode, currentLanguageCode: displayLanguageCode, productLanguageCodes: languageCodes, atAnchor: sender)
        case 1:
            coordinator?.showNutritionFactsTableStyleSelector(for: self.productPair, selected: selectedNutritionFactsTableStyle, anchoredOn: sender)
            //performSegue(withIdentifier: segueIdentifier(to: SelectNutritionFactsTableStyleTableViewCell.self), sender: sender)
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
            productImageData = productPair!.localProduct!.image(for:displayLanguageCode!, of: .nutrition)?.largest
        } else {
            productImageData = productPair!.remoteProduct!.image(for:displayLanguageCode!, of:.nutrition)?.largest
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
