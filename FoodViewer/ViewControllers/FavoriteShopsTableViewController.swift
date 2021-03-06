//
//  FavoriteShopsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 23/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol FavoriteShopsCoordinatorProtocol {
/**
Inform the protocol delegate that no shop has been selected.
- Parameters:
     - sender : the `FavoriteShopsTableViewController` that called the function.
     - shop : the name and address of the selected shop
*/
    func favoriteShopsTableViewController(_ sender:FavoriteShopsViewController, selected shop:(String, Address)?)
/**
Inform the protocol delegate that no shop has been selected.
- Parameters:
     - sender : the `FavoriteShopsTableViewController` that called the function.
*/
    func favoriteShopsTableViewControllerDidCancel(_ sender:FavoriteShopsViewController)

    func favoriteShopsTableViewControllerAddFavoriteShop(_ sender:FavoriteShopsViewController)
        
    }

/// An UIViewController that allows to select (and add) a shop (name + address).
final class FavoriteShopsViewController: UIViewController {
    
    var protocolCoordinator: FavoriteShopsCoordinatorProtocol? = nil
    /// The coordinator that manages the flow.
    weak var coordinator: Coordinator? = nil
    
    /// Refresh the tableView with favorite shops
    func refresh() {
        tableView.reloadData()
    }
//
// MARK : - private variables
//
    //private var shops: [(String, Address)] = []

    private var snapShot: UIView?
    
    private var sourceIndexPath: IndexPath?
    
    private var editMode = false {
        didSet {
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    private var selectedShop: (String, Address)? = nil
    
    /*
    @IBAction func unwindAddFavoriteShopForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? AddFavoriteShopTableViewController {
            // make sure the user has entered any info?
            guard (vc.shopName != nil) || (vc.shopAddress != nil) else { return }
                
            // add to the list
            FavoriteShopsDefaults.manager.addShop(newShop: (vc.shopName, vc.shopAddress))
            
            tableView.reloadData()
        }
    }
 */
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        editMode = !editMode
    }
    
    @IBAction func addShopButtonTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.favoriteShopsTableViewControllerAddFavoriteShop(self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.favoriteShopsTableViewControllerDidCancel(self)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.favoriteShopsTableViewController(self, selected:selectedShop)
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    //
// MARK: - Moving table rows by long press
//
    // https://www.raywenderlich.com/63089/cookbook-moving-table-view-cells-with-a-long-press-gesture
    
    @objc func handleTableViewLongGesture(sender: UILongPressGestureRecognizer) {
        let state = sender.state
        let location = sender.location(in: tableView)
        
        switch state {
        case .began:
            guard let indexPath = tableView.indexPathForRow(at: location) else {
                return
            }
            sourceIndexPath = indexPath
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            
            //Take a snapshot of the selected row using helper method.
            snapShot = customSnapShotFromView(inputView: cell)
            
            // Add the snapshot as subview, centered at cell's center...
            var center = CGPoint(x: cell.center.x, y: cell.center.y)
            snapShot?.center = center
            snapShot?.alpha = 0.0
            tableView.addSubview(snapShot!)
            UIView.animate(withDuration: 0.25, animations: {
                // Offset for gesture location.
                center.y = location.y
                self.snapShot?.center = center
                self.snapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.snapShot?.alpha = 0.98
                
                cell.alpha = 0.0
                }, completion: { _ in
                    cell.isHidden = true
            })
        case .changed:
            guard let targetIndexPath = tableView.indexPathForRow(at: location) else {
                return
            }
            guard let snapShot = snapShot else {
                return
            }
            guard let sourceIndexPathTmp = sourceIndexPath else {
                return
            }
            var center = snapShot.center
            center.y = location.y
            snapShot.center = center
            
            // Is destination valid and is it different from source?
            if targetIndexPath != sourceIndexPathTmp {
                //self made exchange method
                let source = FavoriteShopsDefaults.manager.list[sourceIndexPathTmp.row]
                let destination = FavoriteShopsDefaults.manager.list[targetIndexPath.row]
                FavoriteShopsDefaults.manager.list[sourceIndexPathTmp.row] = destination
                FavoriteShopsDefaults.manager.list[targetIndexPath.row] = source

                // ... move the rows.
                tableView.moveRow(at: sourceIndexPathTmp as IndexPath, to: targetIndexPath)
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = targetIndexPath
            }
            
        default:
            guard let sourceIndexPathTmp = sourceIndexPath else {
                return
            }
            guard let cell = tableView.cellForRow(at: sourceIndexPathTmp) else {
                return
            }
            cell.isHidden = false
            cell.alpha = 0.0
            
            UIView.animate(withDuration: 0.25, animations: {
                self.snapShot?.center = cell.center
                self.snapShot?.transform = CGAffineTransform.identity
                self.snapShot?.alpha = 0.0
                
                cell.alpha = 1.0
                }, completion: { _ in
                    self.sourceIndexPath = nil
                    self.snapShot?.removeFromSuperview()
                    self.snapShot = nil
            })
        }
    }

    private func customSnapShotFromView(inputView: UIView) -> UIImageView{
        // Make an image from the input view.
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }

    private func addLongGestureRecognizerForTableView() {
        let longGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(FavoriteShopsViewController.handleTableViewLongGesture(sender:)))
        
        tableView.addGestureRecognizer(longGesture)
    }
    
    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        addLongGestureRecognizerForTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }

    override func viewWillDisappear(_ animated: Bool) {
        FavoriteShopsDefaults.manager.updateFavoriteShops()
        if let gestures = tableView?.gestureRecognizers {
            for gesture in gestures {
                if gesture is UILongPressGestureRecognizer {
                    tableView?.removeGestureRecognizer(gesture)
                }
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }
}
//
// MARK: - Table view data source
//
extension FavoriteShopsViewController : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let aantal = FavoriteShopsDefaults.manager.list.count
        print(aantal)
        return aantal
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: UITableViewCell.self), for: indexPath)

        let (shop, location) = FavoriteShopsDefaults.manager.list[indexPath.row]
        cell.textLabel?.text = shop
        var textToShow = ""
        if location.street.count > 0 {
            textToShow = location.street
            if location.postalcode.count > 0 {
                textToShow = textToShow + ", " + location.postalcode
            }
            if location.city.count > 0 {
                textToShow = textToShow + ", " + location.city
            }
            if location.country.count > 0 {
                textToShow = textToShow + ", " + location.country
            }
        } else {
            if location.postalcode.count > 0 {
                textToShow = location.postalcode
                if location.city.count > 0 {
                    textToShow = textToShow + ", " + location.city
                }
                if location.country.count > 0 {
                    textToShow = textToShow + ", " + location.country
                }
            } else {
                if location.city.count > 0 {
                    textToShow = location.city
                    if location.country.count > 0 {
                        textToShow = textToShow + ", " + location.country
                    }
                } else {
                    if location.country.count > 0 {
                        textToShow = location.country
                    }
                }
            }
        }
        cell.detailTextLabel?.text = textToShow

        return cell
    }

}
//
// MARK: - Table view delegate protocol
//
extension FavoriteShopsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !editMode {
            selectedShop = FavoriteShopsDefaults.manager.list[indexPath.row]
        }
    }

    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return editMode
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            FavoriteShopsDefaults.manager.list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
