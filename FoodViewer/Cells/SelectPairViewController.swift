//
//  SelectPairViewController.swift
//  FoodViewer
//
//  Created by arnaud on 17/01/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//



import UIKit
/// This class allows the user to pick a from a  list of Strings.
/// The strings asre divided in as set of assigned and unassigned.
/// The user can filter the list of strings through entering a text string
class SelectPairViewController: UIViewController {
//
// MARK: - External Input properties
//
/// Configure the class SelectPairViewController in one go. All possible input parameters are set in this function.
/// - Warning: If this function is not used the class will NOT work.
///
/// - parameter original: The currently selected strings. These tags are encodes as keys, i.e. "en:value". If no strings have been selected this is nil.
/// - parameter allPairs: All possible pairs. The user will be able to select from these pairs.
/// - parameter assignedHeader: The tableView section header for the selected strings.
/// - parameter unAssignedHeader: The tableView section header for the unselected strings.
/// - parameter undefinedText: String to show when the translation is undefined.
/// - parameter cellIdentifierExtension: String to append to the CellIdentifier to make the identifier unique. The format to use for the Identifier in the Storyboard is `UITableView.SelectPairViewController.cellIdentifierExtension`. If only one version of this class is present in the Storyboard, it can be set to nil (and remove the trailing `.` in the identifier.
/// - parameter translate: Function to translate a key to a local language string.
    func configure(original: [String]?, allPairs: [Language], assignedHeader: String, unAssignedHeader: String, undefinedText: String, cellIdentifierExtension: String?) {
        self.original = original
        self.allPairs = allPairs
        self.assignedHeader = assignedHeader
        self.unAssignedHeader = unAssignedHeader
        self.undefinedText = undefinedText
        self.cellIdentifierExtension = cellIdentifierExtension
    }

//
// MARK: - External Output properties
//
/// After the user has selected (or deleted) one or more strings, the results wil be available.
/// - parameter selected: The newly selected array with strings. These are encoded as keys (en:value).
    var selected: [String]? {
        //guard let validPairs = selectedPairs else { return nil }
        return selectedPairs?.map({ $0.code })
    }
//
// MARK: - Internal input properties
//
    // The current Pairs assigned to the product
    // The contries are encodes as keys "en:english"
    private var original: [String]? = nil
        
    private var allPairs: [Language] = []
    
    private var assignedHeader = "Assigned TableView Header"
    
    private var unAssignedHeader = "Unassigned TableView Header"
    
    private var undefinedText = "Undefined Pair"
    
    private var cellIdentifierExtension: String? = nil
    
    private var cellIdentifier: String {
         return cellIdentifier(for: UITableViewCell.self)
            + ( cellIdentifierExtension != nil ? "." + cellIdentifierExtension! : "" )
    }
    
    private var translate: ((String, String) -> String?)? = nil
//
// MARK: - Internal  properties
//
    // The class Language combines the key and local name of a pair.
    // These are Pairs already selected in the existing product
    private var currentPairs: [Language] = []
    
    // The current Pairs sorted on name in local language
    private var sortedPairs: [Language] = []
    
    // The sorted Pairs filtered on the text string
    private var filteredPairs: [Language] = []
    
    // The pair the user wants to add
    // if the user did not select anything is stays nil
    // If the user removed the already existing entries, there will be an empty array
    private var selectedPairs: [Language]? = nil

    private var textFilter: String = "" {
        didSet {
            guard textFilter != oldValue else { return }
            // Filtering on upper case is disallowed
            filteredPairs = textFilter.isEmpty
                ? sortedPairs
                : sortedPairs.filter({ $0.name.lowercased().contains(textFilter) })
            tableView?.reloadData()
        }
    }
//
//  MARK : Interface elements
//
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
            tableView?.allowsMultipleSelection = true
        }
    }
        
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar?.delegate = self
        }
    }
        
    @IBOutlet weak var navItem: UINavigationItem! {
        didSet {
            navItem.title = TranslatableStrings.Select
        }
    }
//
//  MARK : Helper functions
//
    private func setup() {
        
        // if set the tags are converted to class Language items
        if let validTags = original {
            for tag in validTags {
                var pair = Language()
                pair.code = tag
                pair.name = allPairs.last(where: ({$0.code == pair.code}) )?.name ?? undefinedText
                currentPairs.append(pair)
            }
        }
        setupPairs()
    }
    
    private func setupPairs() {
        sortedPairs = allPairs
        if let validSelectedPairs = selectedPairs {
            remove(validSelectedPairs)
        } else {
            remove(currentPairs)
        }
        sortedPairs = sortedPairs.sorted(by: forward)
        filteredPairs = filter()
    }
    
    private func remove(_ pairs:[Language]) {
        for pair in pairs {
            if let index = sortedPairs.firstIndex(where: ({ $0.code == pair.code }) ) {
                sortedPairs.remove(at: index)
            }
        }
    }

    private func forward(_ s1: Language, _ s2: Language) -> Bool {
        return s1.name < s2.name
    }
    
    private func filter() -> [Language] {
        return textFilter.isEmpty ? sortedPairs : sortedPairs.filter({ $0.name.lowercased().contains(textFilter) })
    }
//
// MARK: - ViewController Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup everything
        // This assumes that the data is available
        setup()
    }
    
}
//
// MARK: - UISearchBarDelegate Functions
//
extension SelectPairViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        textFilter = searchText.lowercased()
    }
}
//
// MARK: - UITableViewDataSource Functions
//
extension SelectPairViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let validPairs = selectedPairs {
                return validPairs.isEmpty ? 1 : validPairs.count
            } else {
                return currentPairs.isEmpty ? 1 : currentPairs.count
            }
        } else {
            // this is either section 0 or section 1
            return filteredPairs.isEmpty ? 1 : filteredPairs.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        // Is there a list with selected/current Pairs?
        if indexPath.section == 0 {
            if let validPairs = selectedPairs {
                if validPairs.isEmpty {
                    cell.textLabel?.text =  undefinedText
                } else {
                    cell.textLabel?.text = validPairs[indexPath.row].name
                    cell.accessoryType = .checkmark
                }
            } else {
                if currentPairs.isEmpty {
                    cell.textLabel?.text = undefinedText
                } else {
                    cell.textLabel?.text = currentPairs[indexPath.row].name
                    cell.accessoryType = .checkmark
                }
            }
            
        } else {
            if filteredPairs.isEmpty {
                cell.textLabel?.text = undefinedText
            } else {
                cell.textLabel?.text = filteredPairs[indexPath.row].name
                cell.accessoryType = .none
            }
        }
        return cell
    }
}
//
// MARK: - UITableViewDelegate Functions
//
extension SelectPairViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if indexPath.section == 0 {
            // add the selected languages
            if selectedPairs == nil {
                selectedPairs = currentPairs
            }
            // remove the selected language
            if let index = selectedPairs!.firstIndex( where: {
                ($0.code == selectedPairs![indexPath.row].code)
            }) {
                selectedPairs?.remove(at:index)
            }
            cell?.accessoryType = .none
        } else {
            // add the selected language
            if selectedPairs == nil {
                selectedPairs = currentPairs
            }
            selectedPairs?.append(filteredPairs[indexPath.row])

            cell?.accessoryType = .checkmark
        }
        if selectedPairs != nil {
            selectedPairs = selectedPairs!.sorted(by: forward)
        }
        setupPairs()
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0
            ? assignedHeader
            : unAssignedHeader
    }
}

