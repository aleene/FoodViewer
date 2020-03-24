//
//  AllergenWarningsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 26/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AllergenWarningsTableViewController: UITableViewController {
    
    // The coordinator is owned by AllergenWarningsCoordinator
    weak var coordinator: Coordinator? = nil

    // MARK: - Table view data source
    
    fileprivate struct Storyboard {
        static let AllergenWarningCellIdentifier = "Set Allergen Warning Cell"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let aantal = AllergenWarningDefaults.manager.list.count
        return aantal
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.AllergenWarningCellIdentifier, for: indexPath) as! SetWarningTableViewCell
        let (_, allergen, setWarning) = AllergenWarningDefaults.manager.list[(indexPath as NSIndexPath).row]
        cell.state = setWarning
        cell.stateTitle = allergen
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (allergenKey, allergenName, setWarning) = AllergenWarningDefaults.manager.list[(indexPath as NSIndexPath).row]
        AllergenWarningDefaults.manager.list[(indexPath as NSIndexPath).row] = (allergenKey, allergenName, !setWarning)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = AllergenWarningDefaults.init()
        tableView.reloadData()
        title = TranslatableStrings.AllergenWarnings
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AllergenWarningDefaults.manager.update()
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }

}
