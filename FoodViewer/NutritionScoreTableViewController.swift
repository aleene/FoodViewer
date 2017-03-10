//
//  NutritionScoreTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 08/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutritionScoreTableViewController: UITableViewController {
    
    fileprivate var showNutritionalScore: NutritionalScoreType = .uk
    
    fileprivate enum NutritionalScoreType {
        case uk
        case france
    }
    var product: FoodProduct? {
        didSet {
            refreshProduct()
        }
    }
    
    fileprivate struct Constants {
        static let TitleForSectionWithBadNutrients = NSLocalizedString("Bad nutrients", comment: "Header for a table section showing the appreciations of the bad nutrients")
        static let TitleForSectionWithGoodNutrients = NSLocalizedString("Good nutrients", comment: "Header for a table section showing the appreciations of the good nutrients")
        static let TitleForSectionWithExceptionCategory = NSLocalizedString("Special categories", comment: "Header for a table section showing the special categories")
        static let TitleForSectionWithResultUK = NSLocalizedString("Nutritional Score UK", comment: "Header for a table section showing the total results UK")
        static let TitleForSectionWithResultFrance = NSLocalizedString("Nutritional Score France", comment: "Header for a table section showing the total results France")
        static let CheesesCategory = NSLocalizedString("Cheeses category", comment: "Cell title indicating the product belongs to the cheeses category")
        static let BeveragesCategory = NSLocalizedString("Beverages category", comment: "Cell title indicating the product belongs to the beverages category")
    }

    fileprivate struct Storyboard {
        static let NutrimentScoreCellIdentifier = "Nutriment Score Cell"
        static let BelongsToCategoryCellIdentifier = "Product Category Cell"
        static let ColourCodedNutritionalScoreCellIdentifier = "Colour Coded Nutritional Score Cell"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch showNutritionalScore {
        case .uk:
            return 3
        case .france:
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch showNutritionalScore {
        case .uk:
            switch section {
            // section with bad nutriments
            case 0:
                return product != nil ? product!.nutritionalScoreUK.pointsA.count : 0
            // section with good nutriments
            case 1:
                return product != nil ? product!.nutritionalScoreUK.pointsC.count : 0
            default:
                return 1
            } 

        case .france:
            switch section {
            // section with bad nutriments
            case 0:
                return product != nil ? product!.nutritionalScoreFR.pointsA.count : 0
            // section with good nutriments
            case 1:
                return product != nil ? product!.nutritionalScoreFR.pointsC.count : 0
            case 2:
                return 2
            default:
                return 1
            } 

        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch showNutritionalScore {
        case .uk:
            switch (indexPath as NSIndexPath).section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutrimentScoreCellIdentifier, for: indexPath)as? NutrimentScoreTableViewCell
                cell!.nutrimentScore = (product!.nutritionalScoreUK.pointsA[(indexPath as NSIndexPath).row].nutriment, product!.nutritionalScoreUK.pointsA[(indexPath as NSIndexPath).row].points, 10, 0, .bad)
                return cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutrimentScoreCellIdentifier, for: indexPath)as? NutrimentScoreTableViewCell
                cell!.nutrimentScore = (product!.nutritionalScoreUK.pointsC[(indexPath as NSIndexPath).row].nutriment, product!.nutritionalScoreUK.pointsC[(indexPath as NSIndexPath).row].points, 5, 0, .good)
                return cell!
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ColourCodedNutritionalScoreCellIdentifier, for: indexPath)as? ColourCodedNutritionalScoreTableViewCell
                cell!.score = product?.nutritionalScoreUK.total
                return cell!
            }
        case .france:
            switch (indexPath as NSIndexPath).section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutrimentScoreCellIdentifier, for: indexPath)as? NutrimentScoreTableViewCell
                cell!.nutrimentScore = (product!.nutritionalScoreFR.pointsA[(indexPath as NSIndexPath).row].nutriment, product!.nutritionalScoreFR.pointsA[(indexPath as NSIndexPath).row].points, 10, 0, .bad)
                return cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NutrimentScoreCellIdentifier, for: indexPath)as? NutrimentScoreTableViewCell
                cell!.nutrimentScore = (product!.nutritionalScoreFR.pointsC[(indexPath as NSIndexPath).row].nutriment, product!.nutritionalScoreFR.pointsC[(indexPath as NSIndexPath).row].points, 5, 0, .good)
                return cell!
            case 2:
                switch (indexPath as NSIndexPath).row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BelongsToCategoryCellIdentifier, for: indexPath)as? ProductCategoryTableViewCell
                    cell!.belongsToCategory = product!.nutritionalScoreFR.cheese
                    cell!.belongsToCategoryTitle = Constants.CheesesCategory
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BelongsToCategoryCellIdentifier, for: indexPath)as? ProductCategoryTableViewCell
                    cell!.belongsToCategory = product!.nutritionalScoreFR.beverage
                    cell?.belongsToCategoryTitle = Constants.BeveragesCategory
                    return cell!
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ColourCodedNutritionalScoreCellIdentifier, for: indexPath)as? ColourCodedNutritionalScoreTableViewCell
                cell!.score = product?.nutritionalScoreFR.total
                return cell!
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch showNutritionalScore {
        case .uk:
            switch section {
            case 0:
                return Constants.TitleForSectionWithBadNutrients
            case 1:
                return Constants.TitleForSectionWithGoodNutrients
            default:
                return Constants.TitleForSectionWithResultUK
            }

        case .france:
            switch section {
            case 0:
                return Constants.TitleForSectionWithBadNutrients
            case 1:
                return Constants.TitleForSectionWithGoodNutrients
            case 2:
                return Constants.TitleForSectionWithExceptionCategory
            default:
                return Constants.TitleForSectionWithResultFrance
            }

        }
    }
    
    func refreshProduct() {
        if product != nil {
            tableView.reloadData()
        }
    }

    func doubleTapOnTableView(_ recognizer: UITapGestureRecognizer) {
        /////
        showNutritionalScore = showNutritionalScore == .uk ? .france : .uk
        refreshProduct()
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableStructure = setupSections()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false

        showNutritionalScore = .uk
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(NutritionScoreTableViewController.doubleTapOnTableView))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.numberOfTouchesRequired = 1
        doubleTapGestureRecognizer.cancelsTouchesInView = false
        doubleTapGestureRecognizer.delaysTouchesBegan = true;      //Important to add
        tableView.addGestureRecognizer(doubleTapGestureRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }
    

}
