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
    
    fileprivate struct Constant {
        static let Multiplier = 100
    }
    
    fileprivate var tableStructure: [SectionType] = []
    fileprivate var nutriScoreSectionStructure: [RowType] = []
    
    fileprivate enum RowType {
        case summary(Int?)
        case pointsA(String, NutritionalScore.NutrimentScore?)
        case pointsC(String, NutritionalScore.NutrimentScore?)
        case categories(Bool, String)
        case error(String)
    }

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
        
        func addRowsFR(for nutritionalScore: NutritionalScoreFR) {
            nutriScoreSectionStructure.append(.summary(nutritionalScore.total))
            for (key,value) in nutritionalScore.sortedPointsA {
                nutriScoreSectionStructure.append(.pointsA(key, value))
            }
            for (key,value) in nutritionalScore.sortedPointsC {
                nutriScoreSectionStructure.append(.pointsC(key, value))
            }
            nutriScoreSectionStructure.append(.categories(nutritionalScore.isBeverage, TranslatableStrings.BeveragesCategory))
            nutriScoreSectionStructure.append(.categories(nutritionalScore.isCheese, TranslatableStrings.CheesesCategory))
            nutriScoreSectionStructure.append(.categories(nutritionalScore.isFat, TranslatableStrings.FatCategory))
        }

        func addRowsUK(for nutritionalScore: NutritionalScore) {
            nutriScoreSectionStructure = []
            nutriScoreSectionStructure.append(.summary(nutritionalScore.total))
            for (key,value) in nutritionalScore.sortedPointsA {
                nutriScoreSectionStructure.append(.pointsA(key, value))
            }
            for (key,value) in nutritionalScore.sortedPointsC {
                nutriScoreSectionStructure.append(.pointsC(key, value))
            }
        }

        // The returnValue is an array with sections
        // And each element is a  section type with the number of rows and the section title
        //
        //  The order of each element determines the order in the presentation
        var sectionsAndRows: [SectionType] = []
        nutriScoreSectionStructure = []
        sectionsAndRows.append(.summary(TableSection.Size.Summary, TableSection.Header.Summary))
        switch showNutritionalScore {
        case .franceDecoded:
            if let nutritionalScore = productPair?.remoteProduct?.nutritionalScoreFRDecoded, nutritionalScore.isAvailable {
                addRowsFR(for:nutritionalScore)
            } else {
                if productPair?.remoteProduct == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.ProductNotAvailable))
                } else if productPair?.remoteProduct?.nutritionalScoreFRDecoded == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.NutriscoreNotCalculable))
                } else if !productPair!.remoteProduct!.nutritionalScoreFRDecoded!.isAvailable {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.NutriscoreNotApplicable))
                } else {
                    nutriScoreSectionStructure.append(.error("NutritionScoreTableViewController: Product should show NutriScore"))
                }
            }
            sectionsAndRows.append(.score(nutriScoreSectionStructure.count, TableSection.Header.Score))
        case .franceCalculated:
            if let nutritionalScore = productPair?.remoteProduct?.nutritionalScoreFRCalculated, nutritionalScore.isAvailable {
                addRowsFR(for:nutritionalScore)
            } else {
                if productPair?.remoteProduct == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.ProductNotAvailable))
                } else if productPair?.remoteProduct?.nutritionalScoreFRCalculated == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.NutriscoreNotCalculable))
                } else if !productPair!.remoteProduct!.nutritionalScoreFRCalculated!.isAvailable {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.NutriscoreNotApplicable))
                } else {
                    nutriScoreSectionStructure.append(.error("NutritionScoreTableViewController: Product should show NutriScore"))
                }
            }
            sectionsAndRows.append(.score(nutriScoreSectionStructure.count, TableSection.Header.Score))
        case .ukDecoded:
            if let nutritionalScore = productPair?.remoteProduct?.nutritionalScoreUKDecoded {
                addRowsUK(for:nutritionalScore)
            } else {
                if productPair?.remoteProduct == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.ProductNotAvailable))
                } else if productPair?.remoteProduct?.nutritionalScoreUKDecoded == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.NutriscoreNotCalculable))
                } else {
                    nutriScoreSectionStructure.append(.error("NutritionScoreTableViewController: Product should show NutriScore"))
                }
            }
            sectionsAndRows.append(.score(nutriScoreSectionStructure.count, TableSection.Header.Score))
        case .ukCalculated:
            if let nutritionalScore = productPair?.remoteProduct?.nutritionalScoreUKCalculated {
                addRowsUK(for:nutritionalScore)
            } else {
                if productPair?.remoteProduct == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.ProductNotAvailable))
                } else if productPair?.remoteProduct?.nutritionalScoreUKCalculated == nil {
                    nutriScoreSectionStructure.append(.error(TranslatableStrings.NutriscoreNotCalculable))
                } else {
                    nutriScoreSectionStructure.append(.error("NutritionScoreTableViewController: Product should show NutriScore"))
                }
            }
            sectionsAndRows.append(.score(nutriScoreSectionStructure.count, TableSection.Header.Score))
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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:NutritionScoreTableViewCell.self), for: indexPath) as! NutritionScoreTableViewCell
            cell.product = productPair?.remoteProduct ?? productPair?.localProduct
            return cell
        case .score:
            switch nutriScoreSectionStructure[indexPath.row] {
            case .summary(let value):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:ColourCodedNutritionalScoreTableViewCell.self), for: indexPath) as! ColourCodedNutritionalScoreTableViewCell
                cell.score = value
                cell.delegate = delegate
                return cell
            case .pointsA(let key, let value):
                if let validValue = value {
                    return nutrimentScoreTableViewCell(for:key, with:validValue, towards:false, at:indexPath, and: cellIdentifier(for: NutrimentScoreTableViewCell.self))
                } else {
                    setNutrientTag(for: key)
                    return tagCell(at:indexPath, with:ColorSchemes.none)
                }
            case .pointsC(let key, let value):
                if let validValue = value {
                    return nutrimentScoreTableViewCell(for:key, with:validValue, towards:true, at:indexPath, and:cellIdentifier(for: NutrimentScoreTableViewCell.self))
                } else {
                    setNutrientTag(for: key)
                    return tagCell(at:indexPath, with:ColorSchemes.none)
                }

            case .categories(let value, let string):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ProductCategoryTableViewCell.self), for: indexPath)as? ProductCategoryTableViewCell
                cell!.belongsToCategory = value
                cell?.belongsToCategoryTitle = string
                return cell!
                
            case .error(let string):
                scoreTags = .available([string])
                return tagCell(at:indexPath, with:ColorSchemes.error)
            }
            
        case .levels:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: LevelTableViewCell.self), for: indexPath) as! LevelTableViewCell
            cell.nutritionLevel = productPair?.remoteProduct?.nutritionScore?[indexPath.row]
            if let validNutrient = productPair?.remoteProduct?.nutritionFactsDict[Nutrient.salt.key] {
                cell.saltValue = validNutrient.standardGramValue
            }
            if let validNutrient = productPair?.remoteProduct?.nutritionFactsDict[Nutrient.sugars.key] {
                cell.sugarValue = validNutrient.standardGramValue
            }
            if let validNutrient = productPair?.remoteProduct?.nutritionFactsDict[Nutrient.fat.key] {
                cell.fatValue = validNutrient.standardGramValue
            }
            if let validNutrient = productPair?.remoteProduct?.nutritionFactsDict[Nutrient.saturatedFat.key] {
                cell.saturatedFatValue = validNutrient.standardGramValue

            }
            return cell
            
        case .nova:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
            cell.tagListView?.alignment = .left
            cell.setup(datasource: self, delegate: nil, width: tableView.frame.size.width, tag: encode(indexPath))
            return cell
        }
    }
    
    private func tagCell(at indexPath:IndexPath, with colour:ColorScheme) -> TagListViewTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewTableViewCell.self), for: indexPath) as! TagListViewTableViewCell
        cell.setup(datasource: self, delegate: nil, width: tableView.frame.size.width, tag: encode(indexPath))
        return cell
    }
    
    fileprivate func encode(_ indexPath:IndexPath) -> Int {
        return indexPath.section * Constant.Multiplier + indexPath.row
    }
    
    fileprivate func decode(_ tag:Int) -> IndexPath {
        let row = tag % Constant.Multiplier
        let section = (tag - row) / Constant.Multiplier
        return IndexPath(row: row, section: section)

    }
    private func nutrimentScoreTableViewCell(for key:String, with score: NutritionalScore.NutrimentScore, towards reverse:Bool, at indexPath:IndexPath, and identifier:String) -> NutrimentScoreTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NutrimentScoreTableViewCell
        cell.nutrimentScore = score
        cell.numBars = reverse ? 5 : 10
        cell.reverse = reverse
        cell.normalBarColor = reverse ? .systemGreen : .systemRed
        cell.title = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode)
        return cell
    }
    
    private func setNutrientTag(for key: String) {
        if let nutrientString = OFFplists.manager.translateNutrient(key, language:Locale.preferredLanguageCode) {
            let tagString = String(format: TranslatableStrings.NutrientDataXUnavailable, nutrientString)
            nutrientTags = .available([tagString])
        } else {
            nutrientTags = .available([TranslatableStrings.NutrientDataUnavailable])
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? ColourCodedNutritionalScoreTableViewCell {
            validCell.willDisappear()
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentProductSection = tableStructure[section]
        
        var buttonNotDoubleTap: Bool {
            return ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
        }

        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LanguageHeaderView.identifier) as! LanguageHeaderView
        
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
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if let validView = view as? LanguageHeaderView {
            validView.willDisappear()
        }
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
        
        tableView.register(UINib(nibName: LanguageHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: LanguageHeaderView.identifier)

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
        OFFplists.manager.flush()
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
            case .undefined, .empty:
                return editMode ? 0 : 1
            case let .available(list):
                return list.count
            case .notSearchable:
                return 1
            }
        }
        switch decode(tagListView.tag).section {
        case 1:
            if decode(tagListView.tag).row == 0 {
                return count(scoreTags)
            } else {
                return count(nutrientTags)
            }
        default:
            guard let tags = productPair?.remoteProduct?.novaEvaluation[decode(tagListView.tag).row] else { return 1 }
            return count(tags)
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        func title(_ tags: Tags) -> String {
            switch tags {
            case .undefined, .empty, .notSearchable:
                return tags.description()
            case .available:
                return tags.tag(at:index) ?? "NutritionScoreTableViewController: Tag index out of bounds"
            }
        }
        switch decode(tagListView.tag).section {
        case 1:
            if decode(tagListView.tag).row == 0 {
                return title(scoreTags) }
            else {
                return title(nutrientTags)
            }
        default:
            if let tags = productPair?.remoteProduct?.novaEvaluationTranslated[decode(tagListView.tag).row] {
                return title(tags)
            } else {
                return "NutritionScoreTableViewController: Product nil"
                
            }
        }
    }
    
    func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        func count(_ tags: Tags) -> ColorScheme {
            switch tags {
            case .undefined, .empty:
                return ColorScheme(text: .white, background: .systemOrange, border: .systemOrange)
            case .available:
                return ColorScheme(text: .white, background: .systemGreen, border: .systemGreen)
            case .notSearchable:
                return ColorScheme(text: .white, background: .systemRed, border: .systemRed)
            }
        }
        switch decode(tagListView.tag).section {
        case 1:
            if decode(tagListView.tag).row == 0 {
                return count(scoreTags)
            } else {
                return count(nutrientTags)
            }
        default:
            guard let tags = productPair?.remoteProduct?.novaEvaluation[decode(tagListView.tag).row] else { return ColorScheme(text: .white, background: .systemRed, border: .systemRed) }
            return count(tags)
        }
    }

    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.setNeedsLayout()
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
