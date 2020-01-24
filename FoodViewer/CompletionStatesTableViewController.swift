//
//  CompletionStatesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CompletionStatesTableViewController: UITableViewController {
    
    
// MARK: - public variables
    
    var delegate: ProductPageViewController? = nil {
        didSet {
            if delegate != oldValue {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - private variables

    private var editMode: Bool {
        return delegate?.editMode ?? false
    }

    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(productPair: productPair)
            refreshControl?.endRefreshing()
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
        guard productPair?.remoteProduct != nil else { return 0 }
        
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let validProduct = productPair?.remoteProduct else { return 0 }
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
        return 0
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let validProduct = productPair?.remoteProduct else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier + "." + CompletionStatesTableViewController.identifier, for: indexPath)
            return cell
        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: StateTableViewCell.identifier + "." + CompletionStatesTableViewController.identifier, for: indexPath) as! StateTableViewCell
            cell.delegate = delegate
            let completion = validProduct.state.array[indexPath.row]
            cell.state = completion.value
            cell.tag = indexPath.row
            cell.stateTitle = completion.description
            cell.searchString = OFF.searchKey(for: completion)
            switch completion.category {
            case .categories:
                let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.categoriesTapped))
                    tapGestureRecognizer.numberOfTouchesRequired = 1
                tapGestureRecognizer.numberOfTapsRequired = 1
                cell.addGestureRecognizer(tapGestureRecognizer)
            case .productName, .brands, .quantity, .packaging:
                let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.identificationTapped))
                tapGestureRecognizer.numberOfTouchesRequired = 1
                tapGestureRecognizer.numberOfTapsRequired = 1
                cell.addGestureRecognizer(tapGestureRecognizer)
            case .ingredients:
                let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.ingredientsTapped))
                tapGestureRecognizer.numberOfTapsRequired = 1
                tapGestureRecognizer.numberOfTouchesRequired = 1
                cell.addGestureRecognizer(tapGestureRecognizer)
            case .expirationDate:
                //print(completion)
                let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.supplyChainTapped))
                tapGestureRecognizer.numberOfTapsRequired = 1
                tapGestureRecognizer.numberOfTouchesRequired = 1
                cell.addGestureRecognizer(tapGestureRecognizer)
            case .nutritionFacts:
                let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.nutritionFactsTapped))
                    tapGestureRecognizer.numberOfTapsRequired = 1
                tapGestureRecognizer.numberOfTouchesRequired = 1
                cell.addGestureRecognizer(tapGestureRecognizer)
            case .photosUploaded, .photosValidated:
                let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.galleryTapped))
                    tapGestureRecognizer.numberOfTapsRequired = 1
                tapGestureRecognizer.numberOfTouchesRequired = 1
                cell.addGestureRecognizer(tapGestureRecognizer)
            default:
                break
            }

            return cell
                
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ContributorTableViewCell.identifier + "." + CompletionStatesTableViewController.identifier, for: indexPath) as? ContributorTableViewCell
            cell?.delegate = delegate
            if indexPath.row < validProduct.contributors.count {
                cell?.contributor = validProduct.contributors[indexPath.row]
            } else {
                print("CompletionStatesTableViewController: Contributors row index ", indexPath.row," to large for count: ", validProduct.contributors.count)
            }
            return cell!
                
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier + "." + CompletionStatesTableViewController.identifier, for: indexPath)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            // the lastEditDates array contains at least one date, if we arrive here
            let dates: [Date] = Array.init(validProduct.imageAddDates)
            cell.textLabel!.text = formatter.string(from: dates[indexPath.row])
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.lastEditDateLongPress))
            cell.addGestureRecognizer(longPressGestureRecognizer)
                
            return cell
                
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier + "." + CompletionStatesTableViewController.identifier, for: indexPath)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
                
            if let validDate = validProduct.additionDate {
                cell.textLabel!.text = formatter.string(from: validDate)
            } else {
                cell.textLabel!.text = Constants.NoCreationDateAvailable
            }
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(CompletionStatesTableViewController.creationDateLongPress))
            cell.addGestureRecognizer(longPressGestureRecognizer)
                
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let validCell = cell as? StateTableViewCell {
            if let gestureRecognizers = validCell.gestureRecognizers {
                for gesture in gestureRecognizers {
                    if let tapGesture = gesture as? UITapGestureRecognizer,
                        tapGesture.numberOfTouchesRequired == 1,
                        tapGesture.numberOfTapsRequired == 1 {
                        validCell.removeGestureRecognizer(gesture)
                    }
                }
            }
            validCell.willDisappear()
        } else {
            if let gestureRecognizers = cell.gestureRecognizers {
                for gesture in gestureRecognizers {
                    if gesture is UILongPressGestureRecognizer {
                        cell.removeGestureRecognizer(gesture)
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return Constants.CompletenessHeaderTitle
        case 1:
            if let validProduct = productPair?.remoteProduct {
                if validProduct.contributors.count != 0 {
                    return Constants.ContributorsHeaderTitle
                }
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
        delegate?.currentProductPage = .identification
    }
    
    @objc func ingredientsTapped() {
        delegate?.currentProductPage = .ingredients
    }

    @objc func categoriesTapped() {
        delegate?.currentProductPage = .categories
    }

    @objc func supplyChainTapped() {
        delegate?.currentProductPage = .supplyChain
    }

    @objc func nutritionFactsTapped() {
        delegate?.currentProductPage = .nutritionFacts
    }

    @objc func galleryTapped() {
        delegate?.currentProductPage = .gallery
    }

    // MARK: - Notification handlers
    
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0

        refreshProduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        delegate?.title = Constants.ViewControllerTitle

        NotificationCenter.default.addObserver(self, selector:#selector(CompletionStatesTableViewController.refreshProduct), name:.ProductPairRemoteStatusChanged, object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CompletionStatesTableViewController.refreshProduct), name:.ProductUpdateSucceeded, object:nil)

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
        OFFplists.manager.flush()
    }

}
