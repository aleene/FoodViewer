//
//  SelectContributorRoleViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//
/*
import UIKit

class SelectContributorRoleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
        
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.showsSelectionIndicator = true
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    // at the moment the search supports only two roles
    var validRoles: [ContributorRole] = [.creator, .editor]
    
    var roles: [String] {
        return validRoles.map( { $0.description } ).sorted()
    }
    
    var currentContributor: Contributor? = nil
    
    var updatedContributor: Contributor? = nil
    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return validRoles.count + 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return TranslatableStrings.SelectRole
        } else {
            return validRoles[row - 1].description
        }
    }
    
    func pic
 kerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            if let validContributor = currentContributor {
                updatedContributor = Contributor.init(validContributor.name, role: validRoles[row - 1])
                performSegue(withIdentifier: StoryboardString.SegueIdentifier.SelectContributorRoleVC.Unwind, sender: self)
            }
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }

}
*/
