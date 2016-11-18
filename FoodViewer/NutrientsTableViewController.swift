//
//  NutrientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsTableViewController: UITableViewController, UITextFieldDelegate {

    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate enum SectionType {
        case nutritionFacts
        case servingSize
        case nutritionImage
    }
    
    fileprivate var adaptedNutritionFacts: [DisplayFact] = []
    
    // set to app wide default
    fileprivate var showNutrientsAs: NutritionDisplayMode = Preferences.manager.showNutritionDataPerServingOrPerStandard
    
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
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }

    var delegate: ProductPageViewController? = nil

    private func adaptNutritionFacts(_ facts: [NutritionFactItem?]?) -> [DisplayFact] {
        var displayFacts: [DisplayFact] = []
        if let validFacts = facts {
            for fact in validFacts {
                if let validFact = fact {
                    var newFact: NutritionFactItem? = nil
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
                    } else if (validFact.key == Energy.joule.key()) {
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
        static let ShowNutritionFactsImageSegueIdentifier = "Show Nutrition Facts Image"
        static let EditNutrientsViewControllerSegue = "Show Edit Nutrients ViewController Segue"
        static let ShowNutritionFactsImageTitle = NSLocalizedString("Image", comment: "Title of the ViewController with package image of the nutritional values")
        static let ViewControllerTitle = NSLocalizedString("Nutrition Facts", comment: "Title of the ViewController with the nutritional values")
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
        case .nutritionFacts:
            if adaptedNutritionFacts.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.EmptyNutritionFactsImageCellIdentifier, for: indexPath) as? EmptyNutrientsTableViewCell
                if let available = product?.nutritionFactsAreAvailable {
                    cell?.availability = available
                } else {
                    cell?.availability = NutritionAvailability.notIndicated
                }
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactCellIdentifier, for: indexPath) as? NutrientsTableViewCell
                // warning set FIRST the saltOrSodium
                cell?.nutritionDisplayFactItem = adaptedNutritionFacts[(indexPath as NSIndexPath).row]
                if  (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == NatriumChloride.salt.key()) ||
                    (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == NatriumChloride.sodium.key()) {
                    let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnSaltSodiumTableViewCell))
                    doubleTapGestureRecognizer.numberOfTapsRequired = 2
                    doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                    doubleTapGestureRecognizer.cancelsTouchesInView = false
                    doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                    
                    cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                } else if  (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == Energy.calories.key()) ||
                    (adaptedNutritionFacts[(indexPath as NSIndexPath).row].key == Energy.joule.key()) {
                    let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnEnergyTableViewCell))
                    doubleTapGestureRecognizer.numberOfTapsRequired = 2
                    doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                    doubleTapGestureRecognizer.cancelsTouchesInView = false
                    doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                    
                    cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                }

                return cell!
            }
        case .servingSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ServingSizeCellIdentifier, for: indexPath) as? ServingSizeTableViewCell
            cell!.servingSizeTextField.delegate = self
            cell!.servingSizeTextField.tag = 0
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
            if let result = product?.getNutritionImageData() {
                switch result {
                case .success(let data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutritionFactsImageCellIdentifier, for: indexPath) as? NutrientsImageTableViewCell
                    cell?.nutritionFactsImage = UIImage(data:data)
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? NoNutrientsImageTableViewCell
                    cell?.imageFetchStatus = result
                    return cell!
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoNutrientsImageCellIdentifier, for: indexPath) as? NoNutrientsImageTableViewCell
                cell?.imageFetchStatus = ImageFetchResult.noImageAvailable
                return cell!
            }
        }
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if editMode {
        switch indexPath.section {
            case 0:
                performSegue(withIdentifier: Storyboard.EditNutrientsViewControllerSegue, sender: self)
            default:
                break
            }
        }
    }
    
    fileprivate struct TableStructure {
        static let NutritionFactsImageSectionSize = 1
        static let ServingSizeSectionSize = 1
        static let NutritionFactsEmpytSectionSize = 1
        static let NutritionFactItemsSectionHeader = NSLocalizedString("Nutrition Facts (100g; 100ml)", comment: "Tableview header section for the list of nutritional facts")
        static let NutritionFactsImageSectionHeader = NSLocalizedString("Nutrition Facts Image", comment: "Tableview header section for the image of the nutritional facts")
        static let ServingSizeSectionHeader = NSLocalizedString("Serving Size", comment: "Tableview header for the section with the serving size, i.e. the amount one will usually take of the product.") 
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
        
        // 0 : nutrition facts
        if product.nutritionFacts == nil || product.nutritionFacts!.isEmpty {
            sectionsAndRows.append((
                SectionType.nutritionFacts,
                TableStructure.NutritionFactsEmpytSectionSize,
                TableStructure.NutritionFactItemsSectionHeader))
        } else {
            sectionsAndRows.append((
                SectionType.nutritionFacts,
                adaptedNutritionFacts.count,
                TableStructure.NutritionFactItemsSectionHeader))
        }
    
        // 1:  serving size
        sectionsAndRows.append((
            SectionType.servingSize,
            TableStructure.ServingSizeSectionSize,
            TableStructure.ServingSizeSectionHeader))
        
        // 2: image section
            sectionsAndRows.append((
                SectionType.nutritionImage,
                TableStructure.NutritionFactsImageSectionSize,
                TableStructure.NutritionFactsImageSectionHeader))
        
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }
    
    // MARK: - TextField stuff
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            // productname
            if let validText = textField.text {
                delegate?.updated(portion: validText)
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

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowNutritionFactsImageSegueIdentifier:
                if  let vc = segue.destination as? imageViewController,
                    let result = product?.nutritionImageData {
                    switch result {
                    case .success(let data):
                        vc.image = UIImage(data: data)
                        vc.imageTitle = Storyboard.ShowNutritionFactsImageTitle
                    default:
                        vc.image = nil
                    }
                }
            case Storyboard.EditNutrientsViewControllerSegue:
                if let vc = segue.destination as? EditNutrientsViewController {
                    vc.originalNutritionFacts = product?.nutritionFacts
                    // also pass the edited version, so one can continue editing
                    vc.editedNutritionFacts = delegate?.updatedProduct?.nutritionFacts
                }
            default: break
            }
        }
    }
    
    @IBAction func unwindEditNutrientsForCancel(_ segue:UIStoryboardSegue) {
        // reload with first nutrient?
    }
    
    @IBAction func unwindEditNutrientsForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? EditNutrientsViewController {
            vc.nutrientValue.resignFirstResponder()

            // have any edits been created?
            if vc.editedNutritionFacts != nil {
                // does an updated product already exist?
                delegate?.updated(facts: vc.editedNutritionFacts!)
            }
        }
    }

    private func mergeNutritionFacts() {
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
                        newNutritionFacts.append(delegate?.updatedProduct?.nutritionFacts?[index])
                    }
                }
                adaptedNutritionFacts = adaptNutritionFacts(newNutritionFacts)
            } else {
                // just use the original facts
                adaptedNutritionFacts = adaptNutritionFacts(validNutritionFacts)
            }
        }
    }
    // MARK: - Notification handler
    
    func refreshProduct() {
        if product != nil {
            tableView.reloadData()
        }
    }
    
    func reloadImageSection(_ notification: Notification) {
        tableView.reloadData()
    }

    func refreshProductWithNewNutritionFacts() {
        // recalculate the nutritionfacts that must be shown
        if product != nil {
            mergeNutritionFacts()
            tableStructureForProduct = analyseProductForTable(product!)
            tableView.reloadData()
        }
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }


    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
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
        NotificationCenter.default.addObserver(self, selector:#selector(NutrientsTableViewController.reloadImageSection(_:)), name: .NutritionImageSet, object:nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
