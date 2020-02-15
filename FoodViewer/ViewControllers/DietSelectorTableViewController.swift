//
//  DietSelectorTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 04/09/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class DietSelectorTableViewController: UITableViewController {

    // MARK: - Table view data source
    
    private var selectedDietIndex: Int? = nil {
        didSet {
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let aantal = Diets.manager.count ?? 0
        return aantal
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: SetWarningTableViewCell.self), for: indexPath) as! SetWarningTableViewCell
        let (dietKey, dietName) = Diets.manager.keyAndName(for: indexPath.row, in: Locale.interfaceLanguageCode) ?? ("", "DietSelectorTableViewController:No diet for this index")
        cell.state = SelectedDietsDefaults.manager.selected.contains(dietKey)
        cell.stateTitle = dietName
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDietIndex = indexPath.row
        performSegue(withIdentifier: segueIdentifier(to: ShowDietTriggersTableViewController.self), sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdentifier(to: ShowDietTriggersTableViewController.self):
                if let vc = segue.destination as? ShowDietTriggersTableViewController,
                    selectedDietIndex != nil {
                    vc.dietIndex = selectedDietIndex
                }
            default:
                break
            }
        }
    }
    // MARK: - ViewController Lifecycle
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        title = TranslatableStrings.DietSelector
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AllergenWarningDefaults.manager.update()
        super.viewDidDisappear(animated)
    }

}


//
// MARK: - SetWarningTableViewCellDelegate Function
//
extension DietSelectorTableViewController: SetWarningTableViewCellDelegate {
    func setWarningTableViewCell(_ sender: SetWarningTableViewCell, receivedActionOn stateSwitch: UISwitch) {
        if let (dietKey, _) = Diets.manager.keyAndName(for: sender.tag, in: Locale.interfaceLanguageCode) {
            if stateSwitch.isOn {
                SelectedDietsDefaults.manager.addDiet(with:dietKey)
            } else {
                SelectedDietsDefaults.manager.removeDiet(with:dietKey)
            }
            tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .fade)
        }
    }
    
}
