//
//  DietCompliancyTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 22/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class DietCompliancyTableViewController: UITableViewController {

    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                refreshProduct()
            }
        }
    }

    let diets = Diets.manager

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return diets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    func refreshProduct() {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
