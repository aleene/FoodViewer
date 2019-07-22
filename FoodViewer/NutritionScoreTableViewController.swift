//
//  NutritionScoreTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 08/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutritionScoreTableViewController: UITableViewController {
    
    
    // MARK: - public variables
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    
    fileprivate var showNutritionalScore: NutritionalScoreType = .france
    
    fileprivate enum NutritionalScoreType {
        case uk
        case france
    }
    
    private var editMode: Bool {
        return delegate?.editMode ?? false
    }
    
    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
    

    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let NutritionScore = "Nutrition Score Nova Cell Identifier"
            static let LeftNutrimentScore = "Left Nutriment Score Cell"
            static let RightNutrimentScore = "Right Nutriment Score Cell"
            static let BelongsToCategory = "Product Category Cell"
            static let ColourCodedNutritionalScore = "Colour Coded Nutritional Score Cell"
            static let SetNutritionScoreLevel = "Set Nutrition Score Level Cell Identifier"
        }
        
        struct Nib {
            static let LanguageHeaderView = "LanguageHeaderView"
        }
        
        struct ReusableHeaderFooterView {
            static let Language = "LanguageHeaderView"
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch showNutritionalScore {
        case .uk:
            return Row.UK.NutritionalScore + 1
        case .france:
            return Row.France.NutritionalScore + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch showNutritionalScore {
        case .uk:
            switch section {
            // section with bad nutriments
            case Row.UK.BadNutrients:
                return productPair?.remoteProduct?.nutritionalScoreUK?.pointsA.count ?? 0
            // section with good nutriments
            case Row.UK.GoodNutrients:
                return productPair?.remoteProduct?.nutritionalScoreUK?.pointsC.count ?? 0
            default:
                return 1
            }

        case .france:
            switch section {
            // section with bad nutriments
            case Row.France.BadNutrients:
                return productPair?.remoteProduct?.nutritionalScoreFR?.pointsA.count ?? 0
            // section with good nutriments
            case Row.France.GoodNutrients:
                return productPair?.remoteProduct?.nutritionalScoreFR?.pointsC.count ?? 0
            case Row.France.Exceptions:
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
                case Row.UK.ScoreSummary:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionScore, for: indexPath) as! NutritionScoreTableViewCell
                    cell.product = productPair?.remoteProduct ?? productPair?.localProduct
                    return cell
                case Row.UK.BadNutrients:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath) as? LeftNutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreUK?.pointsA {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 10, 0, .bad)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                case Row.UK.GoodNutrients:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath) as? NutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreUK?.pointsC {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 5, 0, .good)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ColourCodedNutritionalScore, for: indexPath) as! ColourCodedNutritionalScoreTableViewCell
                    cell.score = productPair?.remoteProduct?.nutritionalScoreUK?.total
                    cell.delegate = delegate
                    return cell
                }
        case .france:
            switch (indexPath as NSIndexPath).section {
            case Row.France.ScoreSummary:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionScore, for: indexPath) as? NutritionScoreTableViewCell
                    cell?.product = productPair?.remoteProduct ?? productPair?.localProduct
                    return cell!
                case Row.France.BadNutrients:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath) as? LeftNutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreFR?.pointsA {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 10, 0, .bad)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                case Row.France.GoodNutrients:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath) as? NutrimentScoreTableViewCell
                    if let score = productPair?.remoteProduct?.nutritionalScoreFR?.pointsC {
                        cell!.nutrimentScore = (score[indexPath.row].nutriment, score[indexPath.row].points, 5, 0, .good)
                    } else {
                        cell!.nutrimentScore = nil
                    }
                    return cell!
                case Row.France.Exceptions:
                    switch (indexPath as NSIndexPath).row {
                    case 0:
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BelongsToCategory, for: indexPath) as? ProductCategoryTableViewCell
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
    
    fileprivate struct Row {
        struct UK {
            static let ScoreSummary = 0
            static let BadNutrients = 1
            static let GoodNutrients = 2
            static let NutritionalScore = 3
        }
        struct France {
            static let ScoreSummary = 0
            static let BadNutrients = 1
            static let GoodNutrients = 2
            static let Exceptions = 3
            static let NutritionalScore = 4
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch showNutritionalScore {
        case .uk:
            switch section {
            case Row.UK.ScoreSummary:
                return TranslatableStrings.ScoreSummary
            case Row.UK.BadNutrients:
                return TranslatableStrings.BadNutrients
            case Row.UK.GoodNutrients:
                return TranslatableStrings.GoodNutrients
            case Row.UK.NutritionalScore:
                return TranslatableStrings.NutritionalScoreUK
            default:
                return (":Error:Row undefined")
            }
                
        case .france:
            switch section {
            case Row.France.ScoreSummary:
                return TranslatableStrings.ScoreSummary
            case Row.France.BadNutrients:
                return TranslatableStrings.BadNutrients
            case Row.France.GoodNutrients:
                return TranslatableStrings.GoodNutrients
            case Row.France.Exceptions:
                return TranslatableStrings.SpecialCategories
            default:
                return TranslatableStrings.NutritionalScoreFrance
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Storyboard.ReusableHeaderFooterView.Language) as! LanguageHeaderView
        
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = false
        headerView.buttonNotDoubleTap = buttonNotDoubleTap
        var header = ""
        switch showNutritionalScore {
        case .uk:
            switch section {
            case Row.UK.NutritionalScore:
                header = TranslatableStrings.NutritionalScoreUK
            default:
                return nil
            }
        case .france:
            switch section {
            case Row.France.NutritionalScore:
                header = TranslatableStrings.NutritionalScoreFrance
            default:
                return nil
            }
        }
        headerView.title = header
        return headerView
    }

    func refreshProduct() {
        if productPair?.remoteProduct != nil {
            tableView.reloadData()
        }
    }

    @objc func doubleTapOnTableView() {
        /////
        showNutritionalScore = showNutritionalScore == .uk ? .france : .uk
        refreshProduct()
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableStructure = setupSections()
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: Storyboard.Nib.LanguageHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: Storyboard.Nib.LanguageHeaderView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                navigationController?.setNavigationBarHidden(false, animated: false)
        
        delegate?.title = TranslatableStrings.NutritionalScore

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}


// MARK: - LanguageHeaderDelegate Functions

extension NutritionScoreTableViewController: LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {
    }
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {
        doubleTapOnTableView()
    }
}


// MARK: - TagListViewSegmentedControlCellDelegate Delegate Functions

extension NutritionScoreTableViewController: SetNutritionScoreCellDelegate {
    
    func firstSegmentedControlToggled(_ sender: UISegmentedControl) {
        /*
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
 */
    }
    
    func secondSegmentedControlToggled(_ sender: UISegmentedControl) {
        /*
        guard query != nil else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            query!.includeLevel = false
        case 1:
            query!.includeLevel = true
        default:
            break
        }
 */
    }

}
