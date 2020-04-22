//
//  UserStatsSummaryViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/03/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class UserStatsSummaryViewController: UIViewController {

    private struct Constant {
        struct Storyboard {
            struct CellIdentifier {
                static let Summary = "Stats Summary Cell"
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    private var roles: [(ContributorRole, Search?)] = [(.creator, nil),
                                                                (.checker, nil),
                                                                (.informer, nil)]
    
    @objc func searchStarted(_ notification: Notification) {
        tableView.reloadData()
    }

    @objc func searchLoaded(_ notification: Notification) {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, role) in roles.enumerated() {
            let search = Search.init()
            let contributor = Contributor.init(OFFAccount().userId, role: role.0)
            search.query?.contributors.append(contributor)
            search.startSearch()
            roles[index] = (role.0, search)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Stats"

        NotificationCenter.default.addObserver(self, selector:#selector(SearchResultsTableViewController.searchLoaded(_:)), name:.SearchLoaded, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SearchResultsTableViewController.searchStarted(_:)), name:.SearchStarted, object:nil)
    }

}


extension UserStatsSummaryViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Storyboard.CellIdentifier.Summary, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Number of products as Creator"
        case 1:
            cell.textLabel?.text = "Number of products as Checker"
        default:
            cell.textLabel?.text = "Number of products as Informer"
        }
        
        if let size = roles[indexPath.row].1?.searchResultSize {
            cell.detailTextLabel?.text = "\(size)"
        } else {
            cell.detailTextLabel?.text = "No size"
        }
        return cell
    }
    
}
