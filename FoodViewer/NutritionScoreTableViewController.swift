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
    
    public var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }

    public var tableItem: ProductPair? = nil {
        didSet {
            if let item = tableItem?.barcodeType {
                switch item {
                case .search(let template, _ ):
                    self.query = template
                default:
                    self.productPair = tableItem
                }
            }
        }
    }
    
    var delegate: ProductPageViewController? = nil

    fileprivate var productPair: ProductPair? {
        didSet {
            refreshProduct()
        }
    }
    
    
    fileprivate var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                refreshProduct()
            }
        }
    }

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let LeftNutrimentScore = "Left Nutriment Score Cell"
            static let RightNutrimentScore = "Right Nutriment Score Cell"
            static let BelongsToCategory = "Product Category Cell"
            static let ColourCodedNutritionalScore = "Colour Coded Nutritional Score Cell"
            static let SetNutritionScoreLevel = "Set Nutrition Score Level Cell Identifier"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if query != nil {
            return 1
        } else {
            switch showNutritionalScore {
            case .uk:
                return 3
            case .france:
                return 4
        }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if query != nil {
            // In the case of a query, only the level can be specified
            return section == 0 ? 1 : 0
        } else {
            switch showNutritionalScore {
            case .uk:
                switch section {
                // section with bad nutriments
                case 0:
                    return productPair?.remoteProduct?.nutritionalScoreUK?.pointsA.count ?? 0
                // section with good nutriments
                case 1:
                    return productPair?.remoteProduct?.nutritionalScoreUK!.pointsC.count ?? 0
                default:
                    return 1
                }

            case .france:
                switch section {
                // section with bad nutriments
                case 0:
                    return productPair?.remoteProduct?.nutritionalScoreFR?.pointsA.count ?? 0
                // section with good nutriments
                case 1:
                    return productPair?.remoteProduct?.nutritionalScoreFR!.pointsC.count ?? 0
                case 2:
                    return 2
                default:
                    return 1
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if query != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.SetNutritionScoreLevel, for: indexPath) as! SetNutritionScoreTableViewCell
            cell.delegate = self
            cell.editMode = editMode
            cell.level = query!.level ?? .undefined
            cell.shouldInclude = query!.includeLevel 
            return cell

        } else {
            switch showNutritionalScore {
            case .uk:
                switch (indexPath as NSIndexPath).section {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath) as? LeftNutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreUK?.pointsA {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 10, 0, .bad)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath)as? NutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreUK?.pointsC {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 5, 0, .good)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ColourCodedNutritionalScore, for: indexPath)as! ColourCodedNutritionalScoreTableViewCell
                    cell.score = productPair?.remoteProduct?.nutritionalScoreUK?.total
                    cell.delegate = delegate
                    return cell
                }
            case .france:
                switch (indexPath as NSIndexPath).section {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath)as? LeftNutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreFR?.pointsA {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 10, 0, .bad)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath)as? NutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreFR?.pointsC {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 5, 0, .good)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                case 2:
                    switch (indexPath as NSIndexPath).row {
                    case 0:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BelongsToCategory, for: indexPath)as? ProductCategoryTableViewCell
                        cell!.belongsToCategory = productPair?.remoteProduct?.nutritionalScoreFR?.cheese
                        cell!.belongsToCategoryTitle = TranslatableStrings.CheesesCategory
                        return cell!
                    default:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BelongsToCategory, for: indexPath)as? ProductCategoryTableViewCell
                        cell!.belongsToCategory = productPair?.remoteProduct?.nutritionalScoreFR?.beverage
                        cell?.belongsToCategoryTitle = TranslatableStrings.BeveragesCategory
                        return cell!
                    }
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ColourCodedNutritionalScore, for: indexPath)as! ColourCodedNutritionalScoreTableViewCell
                    cell.score = productPair?.remoteProduct?.nutritionalScoreFR?.total
                    cell.delegate = delegate
                    return cell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if query != nil {
            return TranslatableStrings.NutritionalScore
        } else {
            switch showNutritionalScore {
            case .uk:
                switch section {
                case 0:
                    return TranslatableStrings.BadNutrients
                case 1:
                    return TranslatableStrings.GoodNutrients
                default:
                    return TranslatableStrings.NutritionalScoreUK
                }
                
            case .france:
                switch section {
                case 0:
                    return TranslatableStrings.BadNutrients
                case 1:
                    return TranslatableStrings.GoodNutrients
                case 2:
                    return TranslatableStrings.SpecialCategories
                default:
                    return TranslatableStrings.NutritionalScoreFrance
                }
            }
        }
    }
    
    func refreshProduct() {
        if productPair?.remoteProduct != nil {
            tableView.reloadData()
        }
    }

    @objc func doubleTapOnTableView(_ recognizer: UITapGestureRecognizer) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}

// MARK: - TagListViewSegmentedControlCellDelegate Delegate Functions

extension NutritionScoreTableViewController: SetNutritionScoreCellDelegate {
    
    func firstSegmentedControlToggled(_ sender: UISegmentedControl) {
        guard query != nil else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            query!.level = .a
        case 1:
            query!.level = .b
        case 2:
            query!.level = .c
        case 3:
            query!.level = .d
        case 4:
            query!.level = .e
        case 5:
            query!.level = .undefined
        default:
            break
        }
    }
    
    func secondSegmentedControlToggled(_ sender: UISegmentedControl) {
        guard query != nil else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            query!.includeLevel = false
        case 1:
            query!.includeLevel = true
        default:
            break
        }
    }

}


