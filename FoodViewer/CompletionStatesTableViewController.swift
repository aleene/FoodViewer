//
//  CompletionStatesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l <= r
//  default:
//    return !(rhs < lhs)
//  }
//}


class CompletionStatesTableViewController: UITableViewController {
    
    public var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }

    public var tableItem: Any? = nil {
        didSet {
            if let item = tableItem as? FoodProduct {
                self.product = item
            } else if let item = tableItem as? SearchTemplate {
                self.query = item
            }
        }
    }

    fileprivate var product: FoodProduct? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    private var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                refreshProduct()
            }
        }
    }

    var delegate: ProductPageViewController? = nil
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    private struct Storyboard {
        struct CellIdentifier {
            static let CompletionState = "Completion State Cell"
            static let Contributors = "Contributor Cell"
            static let LastEditDate = "Edit Date Cell"
            static let SetCompletionState = "Set Completion State Cell Identifier"
            static let TagListView = "Completion State TagListView Cell Identifier"
        }
        struct SegueIdentifier {
            static let SelectCompletionState = "Show Select Completion State Segue Identifier"
        }
    }
    
    private struct Constants {
        static let ContributorsHeaderTitle = NSLocalizedString("Contributors", comment: "Header title of the tableview section, indicating whether which users did contribute.")
        static let CompletenessHeaderTitle = NSLocalizedString("Completeness", comment: "Header title of the tableview section, indicating whether the productdata is complete.")
        static let LastEditDateHeaderTitle = NSLocalizedString("Last edit Date", comment: "Header title of the tableview section, indicating when the product data was last edited.")
        static let CreationDateHeaderTitle = NSLocalizedString("Creation Date", comment: "Header title of the tableview section, indicating when the product data was created.")
        static let ViewControllerTitle = NSLocalizedString("Community Effort", comment: "Title of view controller, with information on the community that has contributed to the product data.")
        static let NoCreationDateAvailable = NSLocalizedString("no creation date available", comment: "Value of the creation date field, if no valid date is available.")
        static let NoEditDateAvailable = NSLocalizedString("no edit date available", comment: "Value of the edit date field, if no valid date is available.")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if product != nil {
            return 4
        } else if query != nil {
            return 4
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if product != nil {
            switch section {
            case 0:
                return product!.state.states.count
            case 1:
                return product?.productContributors.contributors != nil ? product!.productContributors.contributors.count : 0
            case 2:
                return product?.lastEditDates?.count != nil ? product!.lastEditDates!.count : 0
            case 3:
                return product?.additionDate != nil ? 1 : 0
            default:
                break
            }
        } else if query != nil {
            return 1
        }
        return 0
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if query != nil {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.SetCompletionState, for: indexPath) as! ButtonWithSwitchTableViewCell
                cell.delegate = self
                cell.editMode = editMode
                cell.isCompleted = query?.completion?.value ?? true
                cell.buttonText = query?.completion?.description()
                return cell
            default:
                break
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.datasource = self
            cell.width = tableView.frame.size.width
            cell.tag = indexPath.row
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.CompletionState, for: indexPath) as! StateTableViewCell
                cell.delegate = delegate
                let completion = product!.state.array[indexPath.row]
                cell.state = completion.value
                cell.stateTitle = completion.description()
                cell.searchString = OFF.searchKey(for: completion)
                return cell
                
            } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Contributors, for: indexPath) as? ContributorTableViewCell
                cell?.delegate = delegate
                cell?.contributor = product!.productContributors.contributors[indexPath.row]
                return cell!
                
            } else if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LastEditDate, for: indexPath)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                // the lastEditDates array contains at least one date, if we arrive here
                
                cell.textLabel!.text = formatter.string(from: product!.lastEditDates![(indexPath as NSIndexPath).row] as Date)
                let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.lastEditDateLongPress))
                cell.addGestureRecognizer(longPressGestureRecognizer)
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LastEditDate, for: indexPath)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                if let validDate = product?.additionDate {
                    cell.textLabel!.text = formatter.string(from: validDate)
                } else {
                    cell.textLabel!.text = Constants.NoCreationDateAvailable
                }
                let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.creationDateLongPress))
                cell.addGestureRecognizer(longPressGestureRecognizer)
                
                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return Constants.CompletenessHeaderTitle
        case 1:
            if product != nil {
                if section < product!.contributorsArray.count {
                    return Constants.ContributorsHeaderTitle
                }
            } else if query != nil {
                return Constants.ContributorsHeaderTitle
            }
        case 2:
            return Constants.LastEditDateHeaderTitle
        case 3:
            return Constants.CreationDateHeaderTitle
        default:
            break
        }
        return nil
    }
    
    func creationDateLongPress() {
        // I should encode the search component
        // And the search status
        guard product?.additionDate != nil else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: product!.additionDate! as Date)
        delegate?.search(for: searchString, in: .entryDates)
    }

    func lastEditDateLongPress() {
        // I should encode the search component
        // And the search status
        guard product?.lastEditDates?[0] != nil else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: product!.lastEditDates![0] as Date)
        delegate?.search(for: searchString, in: .lastEditDate)
    }
//
// MARK: - Navigation
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.SegueIdentifier.SelectCompletionState:
                if  let vc = segue.destination as? SelectCompletionStateViewController {
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? ButtonWithSwitchTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentCompletion = query!.completion
                            }
                        }
                    }
                }
                
            default: break
            }
        }
    }

    @IBAction func unwindSetCompletionStateForDone(_ segue:UIStoryboardSegue) {
        guard query != nil else { return }
        if let vc = segue.source as? SelectCompletionStateViewController {
            query!.completion = vc.selectedCompletion
            tableView.reloadData()
        }
    }

    // MARK: - Notification handler
    
    
    func refreshProduct() {
        tableView.reloadData()
    }

    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    // MARK: - Viewcontroller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0

        title = Constants.ViewControllerTitle
        refreshProduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector:#selector(CompletionStatesTableViewController.refreshProduct), name:.ProductUpdated, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CompletionStatesTableViewController.removeProduct), name:.HistoryHasBeenDeleted, object:nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

    // Can I change this to a protocol?
    
    public func setCompletion() {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectCompletionState, sender: self)
    }
    
    func setInclusion(_ value: Bool) {
        query?.completion?.value = value
    }
    
    func setRole(_ value: String) {
        // query?.
    }
    

}

// MARK: - UIPopoverPresentationControllerDelegate Functions

extension CompletionStatesTableViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - Popover delegation functions
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }
    
}


// MARK: - TagListView Datasource Functions

extension CompletionStatesTableViewController: TagListViewDataSource {
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        
        func count(_ tags: Tags) -> Int {
            switch tags {
            case .undefined:
                tagListView.normalColorScheme = ColorSchemes.error
                return editMode ? 0 : 1
            case .empty:
                tagListView.normalColorScheme = ColorSchemes.none
                return editMode ? 0 : 1
            case let .available(list):
                tagListView.normalColorScheme = ColorSchemes.normal
                return list.count
            case .notSearchable:
                tagListView.normalColorScheme = ColorSchemes.error
                return 1
            }
        }
        return count(Tags.notSearchable)
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return Tags.notSearchable.description()
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        // Assume that the tag value corresponds to the section
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
}



