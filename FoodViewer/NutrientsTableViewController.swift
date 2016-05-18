//
//  NutrientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsTableViewController: UITableViewController {

    private var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    private enum SectionType {
        case NutritionFacts
        case ServingSize
        case NutritionImage
    }
    
    private var adaptedNutritionFacts: [DisplayFact] = []
    
    private var showNutrientsAs: NutritionDataPerStandardOrServing = NutritionDataPerStandardOrServing.PerStandard
    
    struct DisplayFact {
        var name: String? = nil
        var value: String? = nil
        var unit: String? = nil
        var key: String? = nil
    }
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                tableStructureForProduct = analyseProductForTable(product!)
                tableView.reloadData()
            }
        }
    }
    
    func adaptNutritionFacts(facts: [NutritionFactItem]) -> [DisplayFact] {
        var displayFacts: [DisplayFact] = []
        for fact in facts {
            var newFact: NutritionFactItem? = nil
            if (fact.key == NatriumChloride.Salt.key()) {
                switch Preferences.manager.showSaltOrSodium {
                    // do not show sodium
                case .Sodium: break
                default:
                    newFact = fact
                }
            } else if (fact.key == NatriumChloride.Sodium.key()) {
                switch Preferences.manager.showSaltOrSodium {
                // do not show salt
                case .Salt: break
                default:
                    newFact = fact
                }
            } else if (fact.key == Energy.Joule.key()) {
                switch Preferences.manager.showCaloriesOrJoule {
                // show energy as calories
                case .Calories:
                    newFact = NutritionFactItem.init(name: Energy.Calories.description(),
                                                     standard: fact.valueInCalories(fact.standardValue),
                                                     serving: fact.valueInCalories(fact.servingValue),
                                                     unit: Energy.Calories.unit(),
                                                     key: fact.key)
                case .Joule:
                    // this assumes that fact is in Joule
                    newFact = fact
                }
            } else {
                newFact = fact
            }
            if let validFact = newFact {
                let validDisplayFact = localizeFact(validFact)
                displayFacts.append(validDisplayFact)
            }
        }
        return displayFacts
    }
    
    private func localizeFact(fact: NutritionFactItem) -> DisplayFact {
        var displayFact = DisplayFact()
        displayFact.unit = fact.standardValueUnit
        displayFact.name = fact.itemName
        switch showNutrientsAs {
        case .PerStandard:
            let localizedValue = fact.localeStandardValue()
            displayFact.value = fact.standardValue != nil ? localizedValue : ""
        case .PerServing:
            displayFact.value = fact.servingValue != nil ? fact.localeServingValue() : ""
        }
        displayFact.key = fact.key
        return displayFact
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        if refreshControl!.refreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    private struct Storyboard {
        static let NutritionFactCellIdentifier = "Nutrition Fact Cell"
        static let ServingSizeCellIdentifier = "Serving Size Cell"
        static let NoServingSizeCellIdentifier = "No Serving Size Cell"
        static let NutritionFactsImageCellIdentifier = "Nutrition Facts Image Cell"
        static let EmptyNutritionFactsImageCellIdentifier = "Empty Nutrition Facts Image Cell"
        static let NoNutrientsImageCellIdentifier = "No Nutrition Image Cell"
        static let ShowNutritionFactsImageSegueIdentifier = "Show Nutrition Facts Image"
        static let ShowNutritionFactsImageTitle = NSLocalizedString("Image", comment: "Title of the ViewController with package image of the nutritional values")
        static let ViewControllerTitle = NSLocalizedString("Nutrition Facts", comment: "Title of the ViewController with the nutritional values")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // should return all sections (7)
        return tableStructureForProduct.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[indexPath.section]
        
        // we assume that product exists
        switch currentProductSection {
        case .NutritionFacts:
            if adaptedNutritionFacts.isEmpty {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.EmptyNutritionFactsImageCellIdentifier, forIndexPath: indexPath) as? EmptyNutrientsTableViewCell
                if let available = product?.nutritionFactsAreAvailable {
                    cell?.availability = available
                } else {
                    cell?.availability = NutritionAvailability.NotIndicated
                }
                return cell!
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactCellIdentifier, forIndexPath: indexPath) as? NutrientsTableViewCell
                // warning set FIRST the saltOrSodium
                cell?.nutritionFactItem = adaptedNutritionFacts[indexPath.row]
                if  (adaptedNutritionFacts[indexPath.row].key == NatriumChloride.Salt.key()) ||
                    (adaptedNutritionFacts[indexPath.row].key == NatriumChloride.Sodium.key()) {
                    let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnSaltSodiumTableViewCell))
                    doubleTapGestureRecognizer.numberOfTapsRequired = 2
                    doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                    doubleTapGestureRecognizer.cancelsTouchesInView = false
                    doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                    
                    cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                } else if  (adaptedNutritionFacts[indexPath.row].key == Energy.Calories.key()) ||
                    (adaptedNutritionFacts[indexPath.row].key == Energy.Joule.key()) {
                    let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutrientsTableViewController.doubleTapOnEnergyTableViewCell))
                    doubleTapGestureRecognizer.numberOfTapsRequired = 2
                    doubleTapGestureRecognizer.numberOfTouchesRequired = 1
                    doubleTapGestureRecognizer.cancelsTouchesInView = false
                    doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
                    
                    cell?.addGestureRecognizer(doubleTapGestureRecognizer)
                }

                
                return cell!
            }
        case .ServingSize:
            if let servingSize = product?.servingSize {
                if !servingSize.isEmpty {
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ServingSizeCellIdentifier, forIndexPath: indexPath) as? ServingSizeTableViewCell
                    cell?.servingSize = servingSize
                    return cell!
                }
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NoServingSizeCellIdentifier, forIndexPath: indexPath) as? NoServingSizeTableViewCell
            cell?.tagList = []
            return cell!

        case .NutritionImage:
            if let result = product?.getNutritionImageData() {
                switch result {
                case .Success(let data):
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NutritionFactsImageCellIdentifier, forIndexPath: indexPath) as? NutrientsImageTableViewCell
                    cell?.nutritionFactsImage = UIImage(data:data)
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NoNutrientsImageCellIdentifier, forIndexPath: indexPath) as? NoNutrientsImageTableViewCell
                    cell?.imageFetchStatus = result
                    return cell!
                }
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.NoNutrientsImageCellIdentifier, forIndexPath: indexPath) as? NoNutrientsImageTableViewCell
                cell?.imageFetchStatus = ImageFetchResult.NoImageAvailable
                return cell!
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let tempView = UIView.init(frame: CGRectMake(0, 0, tableView.frame.size.width, 25))
        tempView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        let label = UILabel.init(frame: CGRectMake(10, 5, tableView.frame.size.width, 20))
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
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
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return Preferences.manager.showNutritionDataPerServingOrPerStandard.description()
        default:
            let (_, _, header) = tableStructureForProduct[section]
            return header
        }
    }
 */
    
    private struct TableStructure {
        static let NutritionFactsImageSectionSize = 1
        static let ServingSizeSectionSize = 1
        static let NutritionFactsEmpytSectionSize = 1
        static let NutritionFactItemsSectionHeader = NSLocalizedString("Nutrition Facts (100g; 100ml)", comment: "Tableview header section for the list of nutritional facts")
        static let NutritionFactsImageSectionHeader = NSLocalizedString("Nutrition Facts Image", comment: "Tableview header section for the image of the nutritional facts")
        static let ServingSizeSectionHeader = NSLocalizedString("Serving Size", comment: "Tableview header for the section with the serving size, i.e. the amount one will usually take of the product.") 
    }
    
    func doubleTapOnSaltSodiumTableViewCell(recognizer: UITapGestureRecognizer) {
        /////
        Preferences.manager.showSaltOrSodium = Preferences.manager.showSaltOrSodium == .Salt ? .Sodium : .Salt
        
        adaptedNutritionFacts = adaptNutritionFacts(product!.nutritionFacts)
        tableView.reloadData()
    }
    
    func doubleTapOnEnergyTableViewCell(recognizer: UITapGestureRecognizer) {
        /////
        switch Preferences.manager.showCaloriesOrJoule {
        case .Calories:
            Preferences.manager.showCaloriesOrJoule = .Joule
        case .Joule:
            Preferences.manager.showCaloriesOrJoule = .Calories
        }
        
        adaptedNutritionFacts = adaptNutritionFacts(product!.nutritionFacts)
        tableView.reloadData()

//        let sections = NSIndexSet.init(index: 0)
//        tableView.reloadSections(sections, withRowAnimation: .Fade)
    }
    
    func doubleTapOnNutrimentsHeader(recognizer: UITapGestureRecognizer) {
        /////
        showNutrientsAs = showNutrientsAs == .PerServing ? .PerStandard : .PerServing
        
        adaptedNutritionFacts = adaptNutritionFacts(product!.nutritionFacts)
        tableView.reloadData()
    }


    
    private func analyseProductForTable(product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        adaptedNutritionFacts = adaptNutritionFacts(product.nutritionFacts)
        
        // how does the user want the data presented
        switch Preferences.manager.showNutritionDataPerServingOrPerStandard {
        case .PerStandard:
            // what is possible?
            switch product.nutritionFactsAreAvailable {
            case .PerStandardUnit, .PerServingAndStandardUnit:
                showNutrientsAs = .PerStandard
            case .PerServing:
                showNutrientsAs = .PerServing
            default:
                break
            }
        case .PerServing:
            switch product.nutritionFactsAreAvailable {
                // what is possible?
            case .PerStandardUnit:
                showNutrientsAs = .PerStandard
            case .PerServing, .PerServingAndStandardUnit:
                showNutrientsAs = .PerServing
            default:
                break
            }
        }
        
        // 0 : nutrition facts
        if product.nutritionFacts.isEmpty {
            sectionsAndRows.append((
                SectionType.NutritionFacts,
                TableStructure.NutritionFactsEmpytSectionSize,
                TableStructure.NutritionFactItemsSectionHeader))
        } else {
            sectionsAndRows.append((
                SectionType.NutritionFacts,
                adaptedNutritionFacts.count,
                TableStructure.NutritionFactItemsSectionHeader))
        }
    
        // 1:  serving size
        sectionsAndRows.append((
            SectionType.ServingSize,
            TableStructure.ServingSizeSectionSize,
            TableStructure.ServingSizeSectionHeader))
        
        // 2: image section
            sectionsAndRows.append((
                SectionType.NutritionImage,
                TableStructure.NutritionFactsImageSectionSize,
                TableStructure.NutritionFactsImageSectionHeader))
        
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }
        
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowNutritionFactsImageSegueIdentifier:
                if  let vc = segue.destinationViewController as? imageViewController,
                    let result = product?.nutritionImageData {
                    switch result {
                    case .Success(let data):
                        vc.image = UIImage(data: data)
                        vc.imageTitle = Storyboard.ShowNutritionFactsImageTitle
                    default:
                        vc.image = nil
                    }
                }
            default: break
            }
        }
    }
    
    // MARK: - Notification handler
    
    func refreshProduct() {
        if product != nil {
            tableView.reloadData()
        }
    }
    
    func reloadImageSection(notification: NSNotification) {
        tableView.reloadData()
    }

    func refreshProductWithNewNutritionFacts() {
        // recalculate the nutritionfacts that must be shown
        if product != nil {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        title = Storyboard.ViewControllerTitle
        
        refreshProductWithNewNutritionFacts()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector:#selector(NutrientsTableViewController.refreshProduct),
            name:OFFProducts.Notification.ProductUpdated,
            object:nil
        )
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(NutrientsTableViewController.removeProduct), name:History.Notification.HistoryHasBeenDeleted, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(NutrientsTableViewController.reloadImageSection(_:)), name:FoodProduct.Notification.NutritionImageSet, object:nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
