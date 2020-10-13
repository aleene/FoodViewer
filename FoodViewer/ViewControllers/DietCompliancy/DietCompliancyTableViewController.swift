//
//  DietCompliancyTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 22/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

/// Class that shows the
class DietCompliancyTableViewController: UITableViewController {

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
    

    // matches has the results for each diet.
    // per diet a list of levels identified per order
    // per order an array with tag matches
    
    private var matchesPerDietPerLevel: [[(Int,[String])]] = []
    
    private func setupTableView() {
        matchesPerDietPerLevel = diets.matches(productPair?.remoteProduct, in: Locale.interfaceLanguageCode)
    }
    
//MARK: - Table view data source

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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: DietLevelsTableViewCell.self), for: indexPath) as! DietLevelsTableViewCell
            cell.values = values(forDietAt: indexPath.section)
            if productPair?.remoteProduct != nil {
                cell.conclusion = diets.conclusion(productPair!.remoteProduct!, withSortedDietAt: indexPath.section, in: Locale.interfaceLanguageCode)
            }
            cell.delegate = self
            cell.dietName = diets.title(atSorted: indexPath.section, in: Locale.interfaceLanguageCode)
            cell.dietDescription = diets.extendedDescription(atSorted: indexPath.section, in: Locale.interfaceLanguageCode)
            cell.buttonNotDoubleTap = ViewToggleModeDefaults.manager.buttonNotDoubleTap ?? ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault
            cell.tag = indexPath.section
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: TagListViewLabelTableViewCell.self), for: indexPath) as! TagListViewLabelTableViewCell
            cell.accessoryType = .none
            cell.setup(datasource: self, delegate: nil, editMode: false, width: tableView.frame.size.width, tag: indexPath.section * 10 + indexPath.row, prefixLabelText: nil, scheme: nil, text: diets.levelName(for: indexPath.section, and: matchesPerDietPerLevel[indexPath.section][indexPath.row - 1].0, in: Locale.interfaceLanguageCode) ?? "level name not set", text2: nil)
            return cell
            
        }
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewLabelTableViewCell {
            validCell.willDisappear()
        } else if let validCell = cell as? DietLevelsTableViewCell {
            validCell.willDisappear()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return diets.title(atSorted: section, in: Locale.interfaceLanguageCode)
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
            
            return numberOfTags > 0 ? matchesPerDietPerLevel[diet][levelIndex].1[index] : TranslatableStrings.NoMatchesForThisLevel
        }
        return "DietCompliancyTableViewController:Tag issue"
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        tableView.setNeedsLayout()
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        let levelIndex = tagListView.tag % 10 - 1
        let diet = (tagListView.tag - levelIndex) / 10
        if levelIndex >= 0 {
            let numberOfTags = matchesPerDietPerLevel[diet][levelIndex].1.count
            
            return numberOfTags > 0 ? ColorSchemes.normal : ColorSchemes.none
        }
        return ColorSchemes.none
    }

}

//
// MARK: - DietLevelsTableViewCellDelegate Function
//
extension DietCompliancyTableViewController: DietLevelsTableViewCellDelegate {
    func dietLevelsTableViewCellQuestionmarkButtonTapped(name: String?, extendedDescription: String?) {
        guard let validName = name  else { return }
        guard let validExtendedDescription = extendedDescription else { return }
        let alert = UIAlertController(
            title: validName,
            message: validExtendedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) -> Void in
            // the user cancels to add image
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // function to let the delegate know that a tag was double tapped
    func dietLevelsTableViewCell(_ sender: DietLevelsTableViewCell, receivedTapOn: UIButton?) {
        if let validExpandSection = expandSection {
            if validExpandSection == sender.tag {
                expandSection = nil
                tableView.reloadData()
                return
            }
        }
        expandSection = sender.tag
        tableView.reloadData()
    }
}
