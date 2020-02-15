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
    
    fileprivate struct Constant {
        static let TagListViewHeight = CGFloat(44.0)
        static let LabelHeight = CGFloat(20.0)
        static let VerticalSpacing = CGFloat(8.0)
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

    private var heights: [IndexPath:CGFloat] = [:]
    
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
        cell.setup(datasource: self, delegate: nil, editMode: false, width: tableView.frame.size.width, tag: indexPath.section * 10 + indexPath.row, prefixLabelText: nil, scheme: nil, text: tableData[indexPath.section].1[indexPath.row].0, text2: nil)
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? TagListViewLabelTableViewCell {
            validCell.willDisappear()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].0

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.LabelHeight + (heights[indexPath] ?? Constant.TagListViewHeight) + 3 * Constant.VerticalSpacing
    }
    
    private func setupTableData() {
        guard let validDietIndex = dietIndex else { return }
        tableData = Diets.manager.triggers(forDiet: validDietIndex, in: Locale.interfaceLanguageCode)
        if tableData.count > 0 {
            for section in 0...tableData.count - 1 {
                if tableData[section].1.count > 0 {
                    for row in 0...tableData[section].1.count - 1 {
                        heights[IndexPath(row: row, section: section)] = CGFloat(Constant.TagListViewHeight)
                    }
                }
            }
        }
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
        heights[IndexPath(row: row, section: section)] = height
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .bottom)
    }
    
    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

}
