//
//  ForestFootprintViewController.swift
//  FoodViewer
//
//  Created by arnaud on 29/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

protocol ForestFootprintCoordinatorProtocol {
    /**
    Inform the protocol delegate that the done button has been tapped.
    - Parameters:
         - sender : the `ForestFootprintViewController` that called the function.
    */
    func forestFootprintViewControllerDidTapDone(_ sender: ForestFootprintViewController)
}

class ForestFootprintViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.forestFootprintViewControllerDidTapDone(self)
    }
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    
        
// MARK: - External properties

    var protocolCoordinator: ForestFootprintCoordinatorProtocol? = nil
        
    /// The manager of this viewController and its protocol delegate
    weak var coordinator: Coordinator? = nil

// MARK: - External functions

/**
Configures the viewController with the forest footprint basic data.
- parameters:
    -  forestFootprint: the forest footprint;
*/
    public func configure(forestFootprint: ForestFootprint) {
        self.forestFootprint = forestFootprint
    }
    
    private var forestFootprint: ForestFootprint? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarTitle?.title = TranslatableStrings.ForestFootprint
        ingredientsTableView?.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ingredientsTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }

}

extension ForestFootprintViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let validCount = forestFootprint?.ingredients.count {
            return validCount + 3
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let validCount = forestFootprint?.ingredients.count ?? 0
        // first tableView row
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForestFootprintExplanation.ForestFootprintViewController", for: indexPath)
            cell.textLabel?.text = TranslatableStrings.ForestFootprintExplanation
            return cell
            
        // second tableView row
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ForestFootprintIngredientHeaderTableViewCell.self), for: indexPath) as! ForestFootprintIngredientHeaderTableViewCell
            return cell
            
        // last tableView row
        } else if indexPath.row == validCount + 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForestFootprintConclusionTableViewCell.ForestFootprintViewController", for: indexPath)
            cell.textLabel?.text = TranslatableStrings.ForestFootprintConclusion
            if let validValue = forestFootprint?.footprintPerKg {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumSignificantDigits = 2
                cell.detailTextLabel?.text = formatter.string(from: NSNumber(value: validValue))
            } else {
                cell.detailTextLabel?.text = ""
            }
            return cell
        }
        
        // ingredient rows
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: ForestFootprintIngredientTableViewCell.self), for: indexPath) as! ForestFootprintIngredientTableViewCell
        cell.setup(ingredient: forestFootprint!.ingredients[indexPath.row - 2])
        return cell

    }
    
    //func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> //String? {
        //return "Ingredients requiring soy"
   // }
}
