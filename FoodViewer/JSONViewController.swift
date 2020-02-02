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
    private struct JsonEntry {
        var level: Int = 0
        var key: String? = nil
        var value: String? = nil
        var isShown: Bool = true
    }
    
    private var pairs: [JsonEntry] = []
    
    private func setupPairs() {
        guard let validData = productPair?.remoteProduct?.json else {
            print ("JSONViewController: no valid json.")
            return
        }
        let currentLevel = 0
        decodeData(validData, for: currentLevel)
    }
    
    private func decodeData(_ data: JSON, for level:Int) {
        switch data {
        case .Dictionary(let dictData):
            for (key, value) in dictData {
                if let dict = value as? [String:AnyObject] {
                    pairs.append(JsonEntry(level: 0, key: key, value: "dictionary", isShown: true))
                    decodeData(JSON.Dictionary(dict), for: level + 1)
                } else if let array = value as? [AnyObject] {
                    pairs.append(JsonEntry(level: 0, key: key, value: "array", isShown: true))
                    decodeData(JSON.Array(array), for: level + 1)
                } else {
                    pairs.append(JsonEntry(level: 0, key: key, value: decode(value), isShown: true))
                }
            }
        case .Array(let arrayData):
            for value in arrayData {
                if let dict = value as? [String:AnyObject] {
                    pairs.append(JsonEntry(level: 0, key: nil, value: "dict", isShown: true))
                    decodeData(JSON.Dictionary(dict), for: level + 1)
                } else if let array = value as? [AnyObject] {
                    pairs.append(JsonEntry(level: 0, key: nil, value: "array", isShown: true))
                    decodeData(JSON.Array(array), for: level + 1)
                } else {
                    pairs.append(JsonEntry(level: 0, key: nil, value: decode(value), isShown: true))
                }
            }
        }
    }
    
    private func decode(_ value: Any) -> String {
        if let validValue = value as? String {
            return validValue
        } else if let validValue = value as? Int {
            return "\(validValue)"
        } else if let validValue = value as? Double {
            return "\(validValue)"
        }
        return "undecoded"
    }
    
    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }
//
// MARK: = ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension JSONViewController: UITableViewDelegate {
    
}

extension JSONViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableView.JSONViewController", for: indexPath)
        cell.textLabel?.text = pairs[indexPath.row].key
        cell.detailTextLabel?.text = pairs[indexPath.row].value
        return cell
    }
    
}
