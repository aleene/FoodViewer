//
//  JSONViewController.swift
//
//  Created by cem.olcay on 18/09/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit

class JSONViewController: UIViewController {
//
// MARK: - public variables
//
    var delegate: ProductPageViewController? = nil
//
// MARK: - public functions
//
    /// Refresh the json view
    func refreshProduct() {
        setupPairs()

        tableView?.reloadData()
    }
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    
//
// MARK: - Fileprivate Functions/variables
//
    // The json entries are defined as a class, so I can find them by reference.
    private class JsonEntry {
        var level: Int = 0
        var key: String? = nil
        var value: String? = nil
        var isShown: Bool = true
        
        init(level:Int, key:String?, value: String?, isShown:Bool) {
            self.level = level
            self.key = key
            self.value = value
            self.isShown = isShown
        }
    }
    
    private var pairs: [JsonEntry] = []
    
    private func setupPairs() {
        guard let validData = productPair?.remoteProduct?.json else {
            print ("JSONViewController: no valid json.")
            return
        }
        let currentLevel = 0
        pairs = []
        decodeData(validData, for: currentLevel)
    }
    
    private var shownPairs: [JsonEntry] {
        pairs.filter( {($0.isShown)})
    }
    
    private func decodeData(_ data: JSON, for level:Int) {
        switch data {
        case .Dictionary(let dictData):
            for (key, value) in dictData {
                if let dict = value as? [String:AnyObject] {
                    pairs.append(JsonEntry(level: level, key: key, value: nil, isShown: true))
                    decodeData(JSON.Dictionary(dict), for: level + 1)
                } else if let array = value as? [AnyObject] {
                    pairs.append(JsonEntry(level: level, key: key, value: nil, isShown: true))
                    decodeData(JSON.Array(array), for: level + 1)
                } else {
                    pairs.append(JsonEntry(level: level, key: key, value: decode(value), isShown: true))
                }
            }
        case .Array(let arrayData):
            if arrayData.isEmpty {
                pairs.append(JsonEntry(level: level, key: nil, value: "(empty array)", isShown: true))
            } else {
            for value in arrayData {
                if let dict = value as? [String:AnyObject] {
                    pairs.append(JsonEntry(level: level, key: nil, value: nil, isShown: true))
                    decodeData(JSON.Dictionary(dict), for: level + 1)
                } else if let array = value as? [AnyObject] {
                    pairs.append(JsonEntry(level: level, key: nil, value: nil, isShown: true))
                    decodeData(JSON.Array(array), for: level + 1)
                } else {
                    pairs.append(JsonEntry(level: level, key: nil, value: decode(value), isShown: true))
                }
            }
            }
        }
    }
    
    private func decode(_ value: Any) -> String {
        if let validValue = value as? String {
            return validValue.isEmpty ? "(empty string)" : validValue
        } else if let validValue = value as? Int {
            return "\(validValue)"
        } else if let validValue = value as? Double {
            return "\(validValue)"
        }
        return "(undecoded - NULL?)"
    }
    
    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
    
}

extension JSONViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = pairs.firstIndex(where: {($0 === shownPairs[indexPath.row])}) {
            let currentLevel = pairs[index].level
            var itemOffset = 1
            while pairs[index + itemOffset].level > currentLevel {
                pairs[index + itemOffset].isShown = !pairs[index + itemOffset].isShown
                itemOffset += 1
            }
        }
        tableView.reloadData()
    }
}

extension JSONViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shownPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for:UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = shownPairs[indexPath.row].key
        cell.detailTextLabel?.text = shownPairs[indexPath.row].value
        cell.indentationLevel = shownPairs[indexPath.row].level
        cell.accessoryType = shownPairs[indexPath.row].value == nil ? .disclosureIndicator : .none
        switch shownPairs[indexPath.row].level % 6 {
        case 0:
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .white
            } else {
                cell.backgroundColor = .white
            }
        case 1:
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .systemGray6
            } else {
                cell.backgroundColor = .lightGray
            }
        case 2:
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .systemGray5
            } else {
                cell.backgroundColor = .darkGray
            }
        case 3:
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .systemGray4
            } else {
                cell.backgroundColor = .green
            }
        case 4:
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .systemGray3
            } else {
                cell.backgroundColor = .red
            }
        case 5:
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .systemGray2
            } else {
                cell.backgroundColor = .blue
            }
        default:
            cell.backgroundColor = .white
        }
        return cell
    }
    
}
