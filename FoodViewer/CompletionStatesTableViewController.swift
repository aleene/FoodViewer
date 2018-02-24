//
//  CompletionStatesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CompletionStatesTableViewController: UITableViewController {
    
    public var editMode: Bool = false {
        didSet {
            // vc changed from/to editMode, need to repaint
            if editMode != oldValue {
                tableView.reloadData()
            }
        }
    }

    public var tableItem: ProductPair? = nil {
        didSet {
            if let item = tableItem?.barcodeType {
                switch item {
                case .search(let template, _):
                    self.query = template
                default:
                    self.productPair = tableItem

                }
            }
        }
    }

    fileprivate var productPair: ProductPair? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    fileprivate var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                refreshProduct()
            }
        }
    }

    var delegate: ProductPageViewController? = nil
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
        }
    }
    
    fileprivate struct Storyboard {
        struct CellIdentifier {
            static let CompletionState = "Completion State Cell"
            static let Contributors = "Contributor Cell"
            static let LastEditDate = "Edit Date Cell"
            static let SetCompletionState = "Set Completion State Cell Identifier"
            static let TagListView = "Completion State TagListView Cell Identifier"
            static let SetContributorRole = "TextField With Button Cell Identifier"
            static let SetCreationDate = "Set Creation Date"
            static let SetLastEditDate = "Set Last Edit Date Cell Identifier"
        }
        struct SegueIdentifier {
            static let SelectCompletionState = "Show Select Completion State Segue Identifier"
            static let SelectContributorRole = "Show Select Contributor Role Segue Identifier"
            static let SetCreationDate = "Set Creation Date Segue Identifier"
            static let SetLstEditDate = "Set Last Edit Date Segue Identifier"
        }
    }
    
    private struct Constants {
        static let ContributorsHeaderTitle = TranslatableStrings.Contributors
        static let CompletenessHeaderTitle = TranslatableStrings.Completeness
        static let LastEditDateHeaderTitle = TranslatableStrings.ImageDates
        static let CreationDateHeaderTitle = TranslatableStrings.CreationDate
        static let ViewControllerTitle = TranslatableStrings.CommunityEffort
        static let NoCreationDateAvailable = TranslatableStrings.NoCreationDateAvailable
        static let NoEditDateAvailable = TranslatableStrings.NoEditDateAvailable
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if productPair != nil {
            return 4
        } else if query != nil {
            return 4
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let validProduct = productPair?.remoteProduct {
            switch section {
            case 0:
                return validProduct.state.states.count
            case 1:
                return validProduct.contributors.count
            case 2:
                return validProduct.imageAddDates.count
            case 3:
                return validProduct.additionDate != nil ? 1 : 0
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
                if query?.completion != nil || editMode {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.SetCompletionState, for: indexPath) as! ButtonWithSegmentedControlTableViewCell
                    cell.delegate = self
                    cell.editMode = editMode
                    cell.isCompleted = query?.completion?.value ?? true
                    cell.buttonText = query?.completion?.cleanedState
                    cell.firstSegmentedControlTitle = query?.completion?.notReady
                    cell.secondSegmentedControlTitle = query?.completion?.ready
                    return cell
                }
                
            case 1:
                if query!.contributors.count > 0 || editMode {
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.SetContributorRole, for: indexPath) as! TextFieldWithButtonTableViewCell
                    cell.delegate = self
                    cell.tag = indexPath.row // At the moment only 1 row is supported
                    cell.editMode = editMode
                    cell.username = query!.contributors.count > 0 ? query!.contributors[indexPath.row].name : nil
                    cell.buttonText = query!.contributors.count > 0 ? query!.contributors[indexPath.row].roles[0].description : nil
                    return cell
                }
                
            case 2:
                if query!.type != .advanced {
                    if query!.lastEditDate != nil || editMode {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.SetLastEditDate, for: indexPath) as! LastEditDateTableViewCell
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .none
                        // the lastEditDates array contains at least one date, if we arrive here
                        cell.editMode = editMode
                        cell.title = query!.lastEditDate != nil ? formatter.string(from: query!.lastEditDate!) : nil
                        return cell
                    }
                }
            case 3:
                if query!.type != .advanced {
                    if query!.creationDate != nil || editMode {
                        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.SetCreationDate, for: indexPath) as! ButtonTableViewCell
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .none
                        // the lastEditDates array contains at least one date, if we arrive here
                        cell.editMode = editMode
                        cell.title = query!.creationDate != nil ? formatter.string(from: query!.creationDate!) : ( editMode ? TranslatableStrings.EnterDate : TranslatableStrings.NotSet )
                        return cell
                    }
                }
            default:
                break
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.TagListView, for: indexPath) as! TagListViewTableViewCell
            cell.width = tableView.frame.size.width
            cell.datasource = self
            cell.editMode = editMode
            cell.tag = indexPath.section
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.CompletionState, for: indexPath) as! StateTableViewCell
                cell.delegate = delegate
                let completion = productPair!.remoteProduct!.state.array[indexPath.row]
                cell.state = completion.value
                cell.tag = indexPath.row
                cell.stateTitle = completion.description
                cell.searchString = OFF.searchKey(for: completion)
                switch completion.category {
                case .categories:
                    let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.categoriesTapped))
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    cell.addGestureRecognizer(tapGestureRecognizer)
                case .productName, .brands, .quantity, .packaging:
                    let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.identificationTapped))
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    cell.addGestureRecognizer(tapGestureRecognizer)
                case .ingredients:
                    let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.ingredientsTapped))
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    cell.addGestureRecognizer(tapGestureRecognizer)
                case .expirationDate:
                    let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.supplyChainTapped))
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    cell.addGestureRecognizer(tapGestureRecognizer)
                case .nutritionFacts:
                    let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.nutritionFactsTapped))
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    cell.addGestureRecognizer(tapGestureRecognizer)
                case .photosUploaded, .photosValidated:
                    let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.galleryTapped))
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                    cell.addGestureRecognizer(tapGestureRecognizer)
                default:
                    break
                }

                return cell
                
            } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Contributors, for: indexPath) as? ContributorTableViewCell
                cell?.delegate = delegate
                cell?.contributor = productPair!.remoteProduct!.contributors[indexPath.row]
                return cell!
                
            } else if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LastEditDate, for: indexPath)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                // the lastEditDates array contains at least one date, if we arrive here
                let dates: [Date] = Array.init(productPair!.remoteProduct!.imageAddDates)
                cell.textLabel!.text = formatter.string(from: dates[indexPath.row])
                let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.lastEditDateLongPress))
                cell.addGestureRecognizer(longPressGestureRecognizer)
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.LastEditDate, for: indexPath)
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                if let validDate = productPair?.remoteProduct?.additionDate {
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
            if let validProduct = productPair?.remoteProduct {
                if section < validProduct.contributors.count {
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
    
    @objc func creationDateLongPress() {
        // I should encode the search component
        // And the search status
        guard let validDate = productPair?.remoteProduct?.additionDate else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: validDate)
        delegate?.search(for: searchString, in: .entryDates)
    }

    @objc func lastEditDateLongPress() {
        // I should encode the search component
        // And the search status
        guard let validEditDate = productPair?.remoteProduct?.lastEditDates?[0] else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let searchString = formatter.string(from: validEditDate)
        delegate?.search(for: searchString, in: .lastEditDate)
    }
    
    @objc func identificationTapped() {
        delegate?.pageIndex = .identification
    }
    
    @objc func ingredientsTapped() {
        delegate?.pageIndex = .ingredients
    }

    @objc func categoriesTapped() {
        delegate?.pageIndex = .categories
    }

    @objc func supplyChainTapped() {
        delegate?.pageIndex = .supplyChain
    }

    @objc func nutritionFactsTapped() {
        delegate?.pageIndex = .nutritionFacts
    }

    @objc func galleryTapped() {
        delegate?.pageIndex = .gallery
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
                        if button.superview?.superview as? ButtonWithSegmentedControlTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
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
            case Storyboard.SegueIdentifier.SelectContributorRole:
                if  let vc = segue.destination as? SelectContributorRoleViewController {
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? TextFieldWithButtonTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .right
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                if query!.contributors.count > 0 {
                                    vc.currentContributor = query!.contributors[0]
                                } else {
                                    vc.currentContributor = nil
                                }
                            }
                        }
                    }
                }
            case Storyboard.SegueIdentifier.SetCreationDate:
                if  let vc = segue.destination as? SetCreationDateViewController {
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? ButtonTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentDate = query!.creationDate
                            }
                        }
                    }
                }
            case Storyboard.SegueIdentifier.SetLstEditDate:
                if  let vc = segue.destination as? SetLastEditDateViewController {
                    if let button = sender as? UIButton {
                        if button.superview?.superview as? LastEditDateTableViewCell != nil {
                            if let ppc = vc.popoverPresentationController {
                                // set the main language button as the anchor of the popOver
                                ppc.permittedArrowDirections = .any
                                // I need the button coordinates in the coordinates of the current controller view
                                let anchorFrame = button.convert(button.bounds, to: self.view)
                                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
                                ppc.delegate = self
                                vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                                vc.currentDate = query!.lastEditDate
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

    @IBAction func unwindSetContributorRoleForDone(_ segue:UIStoryboardSegue) {
        guard query != nil else { return }
        if let vc = segue.source as? SelectContributorRoleViewController,
            let validContributor = vc.updatedContributor {
            query!.contributors[0] = validContributor
            tableView.reloadData()
        }
    }

    @IBAction func unwindSetCreationDateForDone(_ segue:UIStoryboardSegue) {
        guard query != nil else { return }
        if let vc = segue.source as? SetCreationDateViewController,
            let validDate = vc.selectedDate {
                query!.creationDate = validDate
            tableView.reloadData()
        }
    }

    @IBAction func unwindSetLastEditDateForDone(_ segue:UIStoryboardSegue) {
        guard query != nil else { return }
        if let vc = segue.source as? SetLastEditDateViewController,
            let validDate = vc.selectedDate {
            query!.lastEditDate = validDate
            tableView.reloadData()
        }
    }
    // MARK: - Notification handler
    
    
    @objc func refreshProduct() {
        tableView.reloadData()
    }

    @objc func removeProduct() {
        productPair?.remoteProduct = nil
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
        
        NotificationCenter.default.addObserver(self, selector:#selector(CompletionStatesTableViewController.refreshProduct), name:.RemoteStatusChanged, object:nil)
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

}


// MARK: - ButtonCellDelegate Functions


extension CompletionStatesTableViewController:  ButtonCellDelegate {
    
    // function to let the delegate know that a button was tapped
    func buttonTableViewCell(_ sender: ButtonTableViewCell, receivedTapOn button:UIButton) {
        // not needed as the button is hooked up by segue in the storyboard
    }
}

// MARK: - ButtonWithSegmentedControlCellDelegate Functions

extension CompletionStatesTableViewController: ButtonWithSegmentedControlCellDelegate {
    
    func buttonTapped(_ sender: ButtonWithSegmentedControlTableViewCell, button: UIButton) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectCompletionState, sender: button)
    }
    
    func segmentedControlToggled(_ sender: ButtonWithSegmentedControlTableViewCell, segmentedControl: UISegmentedControl) {
        query?.completion?.value = segmentedControl.selectedSegmentIndex == 1 ? true : false
    }
}

// MARK: - TextFieldWithButtonCellDelegate Functions

extension CompletionStatesTableViewController: TextFieldWithButtonCellDelegate {
    
    func textFieldWithButtonTableViewCell(_ sender: TextFieldWithButtonTableViewCell, receivedActionOn button:UIButton) {
        performSegue(withIdentifier: Storyboard.SegueIdentifier.SelectContributorRole, sender: button)
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
        
        return count(Tags.empty)
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return Tags.empty.description()
    }
    
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
        // Assume that the tag value corresponds to the section
        tableView.reloadSections(IndexSet.init(integer: tagListView.tag), with: .automatic)
    }
    
}


// MARK: - TextField delegate functions

extension CompletionStatesTableViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let validText = textField.text {
            // does this contributor exist already?
            if query!.contributors.index(where: { $0.name == validText } ) == nil {
                query!.contributors.append(Contributor.init(validText, role: .creator))
            }
            tableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editMode
    }
    
    
}



