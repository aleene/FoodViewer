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
    
    fileprivate var showNutritionalScore: NutritionalScoreType = .franceDecoded
    
    fileprivate enum NutritionalScoreType {
        case ukDecoded
        case franceDecoded
        case ukCalculated
        case franceCalculated
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
            static let Level = "Level Cell Identifier"
            static let TagList = "TagListView Cell Identifier"
        }
        
        struct Nib {
            static let LanguageHeaderView = "LanguageHeaderView"
        }
        
        struct ReusableHeaderFooterView {
            static let Language = "LanguageHeaderView"
        }
    }
    
    fileprivate var tableStructure: [SectionType] = []

    fileprivate enum SectionType {
        case summary(Int, String)
        case score(Int, String)
        case levels(Int, String)
        case nova(Int, String)
        
        var header: String {
            switch self {
            case .summary(_, let headerTitle),
                 .score(_, let headerTitle),
                 .levels(_, let headerTitle),
                 .nova(_, let headerTitle):
                return headerTitle
            }
        }
        
        var numberOfRows: Int {
            switch self {
            case .summary(let numberOfRows, _),
                 .score(let numberOfRows, _),
                 .levels(let numberOfRows, _),
                 .nova(let numberOfRows, _):
                return numberOfRows
            }
        }
    }

    fileprivate struct TableSection {
        struct Size {
            static let Summary = 1
            static let ScoreUK = 8
            static let ScoreFrance = 11
            static let Nova = 4
        }
        struct Header {
            static let Summary = TranslatableStrings.ScoreSummary
            static let Score = TranslatableStrings.NutritionalScore
            static let Levels = TranslatableStrings.Level
            static let Nova = TranslatableStrings.NovaEvaluationTriggers
        }
    }
    
    fileprivate var scoreTags: Tags = .undefined
    fileprivate var nutrientTags: Tags = .undefined

    fileprivate func setupSections() -> [SectionType] {
        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        sectionsAndRows.append(.summary(TableSection.Size.Summary, TableSection.Header.Summary))
        if let nutritionalScore = productPair?.remoteProduct?.nutritionalScoreFRDecoded, nutritionalScore.isAvailable {
            switch showNutritionalScore {
            case .franceDecoded, .franceCalculated:
                sectionsAndRows.append(.score(TableSection.Size.ScoreFrance, TableSection.Header.Score))
            case .ukDecoded, .ukCalculated:
                sectionsAndRows.append(.score(TableSection.Size.ScoreUK, TableSection.Header.Score))
            }
        } else {
            sectionsAndRows.append(.score(1, TableSection.Header.Score))
        }
        
        if let numberOfLevels = productPair?.remoteProduct?.nutritionScore?.count {
            if numberOfLevels > 0 {
                sectionsAndRows.append(.levels(numberOfLevels, TableSection.Header.Levels))
            }
        }
        sectionsAndRows.append(.nova(TableSection.Size.Nova, TableSection.Header.Nova))
        
        return sectionsAndRows
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructure.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStructure[section].numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableStructure[indexPath.section] {
        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.NutritionScore, for: indexPath) as! NutritionScoreTableViewCell
            cell.product = productPair?.remoteProduct ?? productPair?.localProduct
            return cell
        case .score:
            switch indexPath.row {
            case 1...4:
                var key = ""
                switch indexPath.row - 1 {
                case 0:
                    key = Nutrient.energy.key
                case 1:
                    key = Nutrient.saturatedFat.key
                case 2:
                    key = Nutrient.sugars.key
                default:
                    key = Nutrient.sodium.key
                }
                switch showNutritionalScore {
                case .franceDecoded:
                    if let score = productPair?.remoteProduct?.nutritionalScoreFRDecoded?.pointsA[key],
                        score != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                        cell.nutrimentScore = score
                        cell.numBars = 10
                        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                        return cell
                    } else {
                        setNutrientTag(for: key)
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                        cell.width = tableView.frame.size.width
                        cell.datasource = self
                        cell.delegate = self
                        cell.tagListView?.alignment = .center
                        cell.tag = indexPath.section * 10 + indexPath.row
                        return cell
                    }
                case .franceCalculated:
                    if let score = productPair?.remoteProduct?.nutritionalScoreFRCalculated?.pointsA[key],
                        score != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                        cell.nutrimentScore = score
                        cell.numBars = 10
                        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                        return cell
                    } else {
                        setNutrientTag(for: key)
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                        cell.width = tableView.frame.size.width
                        cell.datasource = self
                        cell.delegate = self
                        cell.tagListView?.alignment = .center
                        cell.tag = indexPath.section * 10 + indexPath.row
                        return cell
                    }

                case .ukDecoded:
                    if let score = productPair?.remoteProduct?.nutritionalScoreUKDecoded?.pointsA[key],
                        score != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                        cell.nutrimentScore = score
                        cell.numBars = 10
                        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                        return cell
                   } else {
                        setNutrientTag(for: key)
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                        cell.width = tableView.frame.size.width
                        cell.datasource = self
                        cell.delegate = self
                        cell.tagListView?.alignment = .center
                        cell.tag = indexPath.section * 10 + indexPath.row
                        return cell
                    }
                case .ukCalculated:
                    if let score = productPair?.remoteProduct?.nutritionalScoreUKCalculated?.pointsA[key],
                        score != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LeftNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                        cell.nutrimentScore = score
                        cell.numBars = 10
                        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                        return cell
                    } else {
                        setNutrientTag(for: key)
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                        cell.width = tableView.frame.size.width
                        cell.datasource = self
                        cell.delegate = self
                        cell.tagListView?.alignment = .center
                        cell.tag = indexPath.section * 10 + indexPath.row
                        return cell
                    }

                }
            case 5...7:
                var key = ""
                switch indexPath.row - 5 {
                case 0:
                    key = Nutrient.fiber.key
                case 1:
                    key = Nutrient.proteins.key
                default:
                    key = Nutrient.fruitsVegetablesNuts.key
                }

                switch showNutritionalScore {
                case .franceDecoded:
                    if let score = productPair?.remoteProduct?.nutritionalScoreFRDecoded?.pointsC[key],
                        score != nil {
                            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                            cell.nutrimentScore = score
                            cell.numBars = 5
                            cell.reverse = true
                            cell.normalBarColor = .green
                            cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                            return cell
                        } else {
                            setNutrientTag(for: key)
                            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                            cell.width = tableView.frame.size.width
                            cell.datasource = self
                            cell.delegate = self
                            cell.tagListView?.alignment = .center
                            cell.tag = indexPath.section * 10 + indexPath.row
                            return cell
                        }
                case .franceCalculated:
                    if let score = productPair?.remoteProduct?.nutritionalScoreFRCalculated?.pointsC[key],
                        score != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                        cell.nutrimentScore = score
                        cell.numBars = 5
                        cell.reverse = true
                        cell.normalBarColor = .green
                        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                        return cell
                    } else {
                        setNutrientTag(for: key)
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                        cell.width = tableView.frame.size.width
                        cell.datasource = self
                        cell.delegate = self
                        cell.tagListView?.alignment = .center
                        cell.tag = indexPath.section * 10 + indexPath.row
                        return cell
                    }

                case .ukDecoded:
                    if let score = productPair?.remoteProduct?.nutritionalScoreUKDecoded?.pointsC[key],
                        score != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                        cell.nutrimentScore = score
                        cell.numBars = 5
                        cell.reverse = true
                        cell.normalBarColor = .green
                        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                        return cell
                    } else {
                        setNutrientTag(for: key)
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                        cell.width = tableView.frame.size.width
                        cell.datasource = self
                        cell.delegate = self
                        cell.tagListView?.alignment = .center
                        cell.tag = indexPath.section * 10 + indexPath.row
                        return cell
                    }
                case .ukCalculated:
                    if let score = productPair?.remoteProduct?.nutritionalScoreUKCalculated?.pointsC[key],
                        score != nil {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.RightNutrimentScore, for: indexPath) as! NutrimentScoreTableViewCell
                        cell.nutrimentScore = score
                        cell.numBars = 5
                        cell.reverse = true
                        cell.normalBarColor = .green
                        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
                        return cell
                    } else {
                        setNutrientTag(for: key)
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                        cell.width = tableView.frame.size.width
                        cell.datasource = self
                        cell.delegate = self
                        cell.tagListView?.alignment = .center
                        cell.tag = indexPath.section * 10 + indexPath.row
                        return cell
                    }
                }
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BelongsToCategory, for: indexPath) as? ProductCategoryTableViewCell
                cell!.belongsToCategory = productPair?.remoteProduct?.nutritionalScoreFRDecoded?.isCheese
                cell!.belongsToCategoryTitle = TranslatableStrings.CheesesCategory
                return cell!
            case 9:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BelongsToCategory, for: indexPath)as? ProductCategoryTableViewCell
                cell!.belongsToCategory = productPair?.remoteProduct?.nutritionalScoreFRDecoded?.isBeverage
                cell?.belongsToCategoryTitle = TranslatableStrings.BeveragesCategory
                return cell!
            case 10:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.BelongsToCategory, for: indexPath)as? ProductCategoryTableViewCell
                cell!.belongsToCategory = productPair?.remoteProduct?.nutritionalScoreFRDecoded?.isFat
                cell?.belongsToCategoryTitle = TranslatableStrings.FatCategory
                return cell!
            default:
                if let nutritionalScore = productPair?.remoteProduct?.nutritionalScoreFRDecoded, nutritionalScore.isAvailable {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.ColourCodedNutritionalScore, for: indexPath)as! ColourCodedNutritionalScoreTableViewCell
                    switch showNutritionalScore {
                    case .franceDecoded:
                        cell.score = productPair?.remoteProduct?.nutritionalScoreFRDecoded?.total
                    case .ukDecoded:
                        cell.score = productPair?.remoteProduct?.nutritionalScoreUKDecoded?.total
                    case .ukCalculated:
                        cell.score = productPair?.remoteProduct?.nutritionalScoreUKCalculated?.total
                    case .franceCalculated:
                        cell.score = productPair?.remoteProduct?.nutritionalScoreFRCalculated?.total
                    }
                    cell.delegate = delegate
                    return cell
                } else {
                    // the score can not be shown:
                    // - the product is not available
                    // - the data is not available
                    // - the product is not covered
                    switch showNutritionalScore {
                    case .franceDecoded:
                        if productPair?.remoteProduct == nil {
                            scoreTags = .available([TranslatableStrings.ProductNotAvailable])
                        } else if productPair?.remoteProduct?.nutritionalScoreFRDecoded == nil {
                            scoreTags = .available([TranslatableStrings.NutriscoreNotCalculable])
                        } else if !productPair!.remoteProduct!.nutritionalScoreFRDecoded!.isAvailable {
                            scoreTags = .available([TranslatableStrings.NutriscoreNotApplicable])
                        } else {
                            scoreTags = .available(["NutritionScoreTableViewController: Product should show NutriScore"])
                        }
                    default:
                        scoreTags = .available(["NutritionScoreTableViewController: Why is this shown?"])
                    }

                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
                    cell.width = tableView.frame.size.width
                    cell.datasource = self
                    cell.delegate = self
                    cell.tagListView?.alignment = .center
                    cell.tag = indexPath.section * 10 + indexPath.row
                    return cell
                }
            }
            
        case .levels:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Level, for: indexPath) as! LevelTableViewCell
            cell.nutritionLevel = productPair?.remoteProduct?.nutritionScore?[indexPath.row]
            return cell
        case .nova:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagList, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.delegate = self
            cell.tagListView?.alignment = .left
            cell.tag = indexPath.section * 10 + indexPath.row
            return cell
        }
    }
    
    private func setNutrientTag(for key: String) {
        if let nutrientString = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode) {
            let tagString = String(format: TranslatableStrings.NutrientDataXUnavailable, nutrientString)
            nutrientTags = .available([tagString])
        } else {
            nutrientTags = .available([TranslatableStrings.NutrientDataUnavailable])
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentProductSection = tableStructure[section]
        
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Storyboard.ReusableHeaderFooterView.Language) as! LanguageHeaderView
        
        headerView.section = section
        headerView.delegate = self
        headerView.changeViewModeButton.isHidden = true
        switch currentProductSection {
        case .score :
            headerView.buttonNotDoubleTap = buttonNotDoubleTap
            var header = ""
            switch showNutritionalScore {
            case .ukDecoded:
                header = TranslatableStrings.NutritionalScoreUKDecoded
            case .franceDecoded:
                header = TranslatableStrings.NutritionalScoreFranceDecoded
            case .ukCalculated:
                header = TranslatableStrings.NutritionalScoreUKCalculated
            case .franceCalculated:
                header = TranslatableStrings.NutritionalScoreFranceCalculated
            }
            headerView.title = header
        default:
            headerView.title = tableStructure[section].header
        }
        return headerView
    }

    func refreshProduct() {
        if productPair?.remoteProduct != nil {
            tableStructure = setupSections()
            tableView.reloadData()
        }
    }

    @objc func doubleTapOnTableView() {
        /////
        switch showNutritionalScore {
        case .ukDecoded:
            showNutritionalScore = .ukCalculated
        case .ukCalculated:
            showNutritionalScore = .franceDecoded
        case .franceDecoded:
            showNutritionalScore = .franceCalculated
        case .franceCalculated:
            showNutritionalScore = .ukDecoded
        }
        refreshProduct()
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableStructure = setupSections()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: Storyboard.Nib.LanguageHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: Storyboard.Nib.LanguageHeaderView)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                navigationController?.setNavigationBarHidden(false, animated: false)
        refreshProduct()
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
    }
    
    func secondSegmentedControlToggled(_ sender: UISegmentedControl) {
    }

}

//
// MARK: - TagListView DataSource Functions
//
extension NutritionScoreTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            case .notSearchable:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            }
        }
        let section = tagListView.tag % 10
        let row = tagListView.tag / 10
        switch section {
        case 2:
            if row == 0 {
                return count(scoreTags)
            } else {
                return count(nutrientTags)
            }
        default:
            guard let tags = productPair?.remoteProduct?.novaEvaluation[row] else { return 1 }
            return count(tags)
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        // print("height", tagListView.frame.size.height)
        
        func title(_ tags: Tags) -> String {
            switch tags {
            case .undefined, .empty, .notSearchable:
                return tags.description()
            case .available:
                return tags.tag(at:index) ?? "NutritionScoreTableViewController: Tag index out of bounds"
            }
        }
        let row = tagListView.tag % 10
        let section = (tagListView.tag - row) / 10
        switch section {
        case 1:
            if row == 0 {
                return title(scoreTags) }
            else {
                return title(nutrientTags)
            }
        default:
            if let tags = productPair?.remoteProduct?.novaEvaluation[row] {
                return title(tags)
            } else {
                return "NutritionScoreTableViewController: Product nil"
                
            }
        }

    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
    }

}

//
// MARK: - TagListViewDelegate Functions
//

extension NutritionScoreTableViewController: TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
    }
    
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
    }
    
}

//
// MARK: - TagListViewCellDelegate Functions
//

extension NutritionScoreTableViewController: TagListViewCellDelegate {
    
    // function to let the delegate know that a tag has been single
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) {
    }
    
    // function to let the delegate know that a tag has been double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) {
    }

}
