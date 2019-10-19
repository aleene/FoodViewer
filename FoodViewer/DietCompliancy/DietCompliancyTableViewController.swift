//
//  DietCompliancyTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 22/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class DietCompliancyTableViewController: UITableViewController {

    private struct Storyboard {
        struct CellIdentifier {
            static let TagListView = "Diet TagListView Cell Identifier"
        }
    }
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                refreshProduct()
            }
        }
    }

    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }

    private let diets = Diets.manager

    private var expandSection: Int? = nil
    
    // MARK: - Table view data source

    // matches has the results for each diet.
    // per diet a list of levels identified per order
    // per order an array with tag matches
    
    private var matchesPerDietPerLevel: [[(Int,[String])]] = []
    
    private func setupTableView() {
        matchesPerDietPerLevel = diets.matches(productPair?.remoteProduct, in: Locale.interfaceLanguageCode)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard productPair?.remoteProduct != nil else { return 0 }
        return diets.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let validSection = expandSection,
            section == validSection {
            return matchesPerDietPerLevel[section].count + 1
        }
        return 1
    }

    private func values(forDietAt index:Int) -> [Int] {
        var vals: [Int] = []
        for level in matchesPerDietPerLevel[index] {
            vals.append(level.1.count)
        }
        return vals
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Diet Levels Cell Identifier", for: indexPath) as! DietLevelsTableViewCell
            cell.values = values(forDietAt: indexPath.section)
            if productPair?.remoteProduct != nil {
                cell.conclusion = diets.conclusion(productPair!.remoteProduct!, withDietAt: indexPath.section, in: Locale.interfaceLanguageCode)
            }
            cell.delegate = self
            cell.buttonNotDoubleTap = ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
            cell.tag = indexPath.section
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewLabelTableViewCell
            cell.width = tableView.frame.size.width
            //cell.scheme = ColorSchemes.error
            cell.tag = indexPath.section * 10 + indexPath.row
            cell.datasource = self
            cell.labelText = diets.levelName(for: indexPath.section, and: matchesPerDietPerLevel[indexPath.section][indexPath.row - 1].0, in: Locale.interfaceLanguageCode) ?? "level name not set"
            //cell.delegate = self
            cell.accessoryType = .none
            return cell
            
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return diets.name(for: section, in: Locale.interfaceLanguageCode)
    }
    
    func refreshProduct() {
        guard productPair?.remoteProduct != nil else { return }
        setupTableView()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
//
// MARK: - TagListView DataSource Functions
//
extension DietCompliancyTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        let levelIndex = tagListView.tag % 10 - 1
        let diet = (tagListView.tag - levelIndex) / 10
        if levelIndex >= 0 {
            let numberOfTags = matchesPerDietPerLevel[diet][levelIndex].1.count
            
            return numberOfTags > 0 ? numberOfTags : 1
        }
        return 0
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        // print("height", tagListView.frame.size.height)
        
        let levelIndex = tagListView.tag % 10 - 1
        let diet = (tagListView.tag - levelIndex) / 10
        if levelIndex >= 0 {
            let numberOfTags = matchesPerDietPerLevel[diet][levelIndex].1.count
            
            return numberOfTags > 0 ? matchesPerDietPerLevel[diet][levelIndex].1[index] : "No matches for this level detected"
        }
        return "DietCompliancyTableViewController:Tag issue"
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.reloadData()
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

}

//
// MARK: - QuantityTableViewCellDelegate Function
//
extension DietCompliancyTableViewController: DietLevelsTableViewCellDelegate {
    
    // function to let the delegate know that a tag was single tapped
    func dietLevelsTableViewCell(_ sender: DietLevelsTableViewCell, receivedDoubleTapOn cell:DietLevelsTableViewCell) {
        if let validExpandSection = expandSection {
            if validExpandSection == cell.tag {
                expandSection = nil
                tableView.reloadData()
                return
            }
        }
        expandSection = cell.tag
        tableView.reloadData()
    }
}
