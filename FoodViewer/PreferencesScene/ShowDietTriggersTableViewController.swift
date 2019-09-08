//
//  ShowDietTriggersTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 04/09/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class ShowDietTriggersTableViewController: UITableViewController {

    // MARK: - Table view data source
    
    fileprivate struct Storyboard {
        static let DietTriggers = "Diet Trigger Tags Cell"
    }
    
    var dietIndex: Int? = nil {
        didSet {
            if dietIndex != nil {
                if oldValue == nil {
                    setTitle()
                    setupTableData()
                    refresh()
                } else if oldValue! != dietIndex! {
                    setTitle()
                    setupTableData()
                    refresh()
                }
            }
        }
    }
    
    // tableData is defined as an array of tuples (level name and level info)
    // the level info is an array of tuples (taxonomy name and array of triggers
    private var tableData: [(String,[(String,[String])])] = []

    var key: String? {
        if let validDietIndex = dietIndex {
            return Diets.manager.key(for:validDietIndex, in:Locale.interfaceLanguageCode)
        } else {
            return nil
        }
    }
    
    // Each section shows a level
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    // each row shows a taxonomy
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableData.count >= 0 && section < tableData.count else { return 0 }
        
        return tableData[section].1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.DietTriggers, for: indexPath) as! TagListViewLabelTableViewCell
        cell.width = tableView.frame.size.width
        cell.tag = indexPath.section * 10 + indexPath.row
        cell.datasource = self
        cell.labelText = tableData[indexPath.section].1[indexPath.row].0
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].0

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? TagListViewLabelTableViewCell {
            return cell.newLabel.frame.height + cell.tagListView.frame.height + CGFloat (3 * 8.0)
        }
        return UITableView.automaticDimension
    }
    
    private func setupTableData() {
        guard let validDietIndex = dietIndex else { return }
        tableData = Diets.manager.triggers(forDiet: validDietIndex, in: Locale.interfaceLanguageCode)
    }
    
    private func setTitle() {
        if let validIndex = dietIndex {
            title = Diets.manager.name(for: validIndex, in: Locale.interfaceLanguageCode)
        } else {
            title = TranslatableStrings.NoDietSelected
        }
    }
    
    private func refresh() {
        tableView.reloadData()
    }
    
    // MARK: - ViewController Lifecycle
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle()
    }
    
    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
        OFFplists.manager.flush()
    }

}
//
// MARK: - TagListView DataSource Functions
//
extension ShowDietTriggersTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        let row = tagListView.tag % 10
        let section = tagListView.tag / 10
        let count = tableData[section].1[row].1.count
        return count == 0 ? 1 : count
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        // print("height", tagListView.frame.size.height)
        
        let row = tagListView.tag % 10
        let section = (tagListView.tag - row) / 10
        let count = tableData[section].1[row].1.count
        return count == 0 ? "No diet triggers defined" : tableData[section].1[row].1[index]
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        let row = tagListView.tag % 10
        let section = (tagListView.tag - row) / 10
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .bottom)
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

}
