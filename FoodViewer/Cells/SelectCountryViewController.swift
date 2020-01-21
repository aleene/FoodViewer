//
//  SelectCountryViewController.swift
//  FoodViewer
//
//  Created by arnaud on 17/01/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//
// This class allows the user to pick a country from a prefined list of countries.
// This predefined list of countries shows only the countries not yet listed in the product.
// The user can filter the list of presented countries through entering a text string

import UIKit

class SelectCountryViewController: UIViewController {
//
// MARK: - External properties
//
    // The current countries assigned to the product
    // The contries are encodes as keys "en:english"
    var currentCountriesInterpreted: Tags? = nil {
        didSet {
            // if set the tags are converted to class Language items
            if let validTags = currentCountriesInterpreted {
                for tag in validTags.list {
                    var country = Language()
                    country.code = tag
                    country.name = OFFplists.manager.translateCountry(tag, language: Locale.preferredLanguages[0]) ?? TranslatableStrings.NoCountryDefined
                    currentCountries.append(country)
                }
            }
            setupCountries()
        }
    }
    
    // These are countries already selected in the existing product
    var currentCountries: [Language] = []
    
    // The keys of the selected countries
    var selected: [String]? {
        //guard let validCountries = selectedCountries else { return nil }
        return selectedCountries?.map({ $0.code })
    }
//
// MARK: - Internal properties
//
// The class Language combines the key and local name of a country. The class should be renamed
    
    private var allCountries: [Language] = []
    
    // The current countries sorted on name in local language
    private var sortedCountries: [Language] = []
    
    // The sorted countries filtered on the text string
    private var filteredCountries: [Language] = []
    
    // The country the user wants to add
    // if the user did not select anything is stays nil
    // If the user removed the already existing entries, there will be an empty array
    private var selectedCountries: [Language]? = nil

    private var textFilter: String = "" {
        didSet {
            guard textFilter != oldValue else { return }
            // Filtering on upper case is disallowed
            filteredCountries = textFilter.isEmpty
                ? sortedCountries
                : sortedCountries.filter({ $0.name.lowercased().contains(textFilter) })
            tableView?.reloadData()
        }
    }
    /* are any countries (current or by user) selected?
    private var hasSelected: Bool {
        if !currentCountries.isEmpty {
            return true
        }
        if selectedCountries != nil,
            !selectedCountries!.isEmpty {
            return true
        }
        return false
    }
 */
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
    private func setupCountries() {
        sortedCountries = allCountries
        if let validSelectedCountries = selectedCountries {
            remove(validSelectedCountries)
        } else {
            remove(currentCountries)
        }
        sortedCountries = sortedCountries.sorted(by: forward)
        filteredCountries = filter()
    }
    
    private func remove(_ countries:[Language]) {
        for country in countries {
            if let index = sortedCountries.firstIndex(where: ({ $0.code == country.code }) ) {
                sortedCountries.remove(at: index)
            }
        }
    }

    private func forward(_ s1: Language, _ s2: Language) -> Bool {
        return s1.name < s2.name
    }
    
    private func filter() -> [Language] {
        return textFilter.isEmpty ? sortedCountries : sortedCountries.filter({ $0.name.lowercased().contains(textFilter) })
    }
//
// MARK: - ViewController Lifecycle
//
    override func viewDidLoad() {
        super.viewDidLoad()
        // has the country list already been setup?
        guard allCountries.isEmpty else { return }
        allCountries = OFFplists.manager.allCountries
        setupCountries()
    }
}
//
// MARK: - UISearchBarDelegate Functions
//
extension SelectCountryViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        textFilter = searchText.lowercased()
    }
}
//
// MARK: - UITableViewDataSource Functions
//
extension SelectCountryViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let validCountries = selectedCountries {
                return validCountries.isEmpty ? 1 : validCountries.count
            } else {
                return currentCountries.isEmpty ? 1 : currentCountries.count
            }
        } else {
            // this is either section 0 or section 1
            return filteredCountries.isEmpty ? 1 : filteredCountries.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Select Country Cell", for: indexPath)
        // Is there a list with selected/current countries?
        if indexPath.section == 0 {
            if let validCountries = selectedCountries {
                if validCountries.isEmpty {
                    cell.textLabel?.text =  TranslatableStrings.NoCountryDefined
                } else {
                    cell.textLabel?.text = validCountries[indexPath.row].name
                    cell.accessoryType = .checkmark
                }
            } else {
                if currentCountries.isEmpty {
                    cell.textLabel?.text = TranslatableStrings.NoCountryDefined
                } else {
                    cell.textLabel?.text = currentCountries[indexPath.row].name
                    cell.accessoryType = .checkmark
                }
            }
            
        } else {
            if filteredCountries.isEmpty {
                cell.textLabel?.text =  TranslatableStrings.NoCountryDefined
            } else {
                cell.textLabel?.text = filteredCountries[indexPath.row].name
                cell.accessoryType = .none
            }
        }
        return cell
    }
}
//
// MARK: - UITableViewDelegate Functions
//
extension SelectCountryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if indexPath.section == 0 {
            // add the selected languages
            if selectedCountries == nil {
                selectedCountries = currentCountries
            }
            // remove the selected language
            if let index = selectedCountries!.firstIndex( where: {
                ($0.code == selectedCountries![indexPath.row].code)
            }) {
                selectedCountries?.remove(at:index)
            }
            cell?.accessoryType = .none
        } else {
            // add the selected language
            if selectedCountries == nil {
                selectedCountries = currentCountries
            }
            selectedCountries?.append(filteredCountries[indexPath.row])

            cell?.accessoryType = .checkmark
        }
        if selectedCountries != nil {
            selectedCountries = selectedCountries!.sorted(by: forward)
        }
        setupCountries()
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Assigned countries"
        } else {
            return "Unassigned countries"
        }

    }
    
}

