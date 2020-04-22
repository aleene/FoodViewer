//
//  UserStatsSelectorTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/03/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class UserStatsSelectorTableViewController: UITableViewController {

    private struct Storyboard {
        struct CellIdentifier {
            static let Summary = "Summary CellIdentifier"
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Summary, for: indexPath)

        cell.textLabel?.text = "Summary"
        cell.detailTextLabel?.text = "See a summary of what you have been up to."
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User Stats"
    }
}
