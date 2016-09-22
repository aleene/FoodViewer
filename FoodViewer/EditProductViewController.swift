//
//  EditProductViewController.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class EditProductViewController: UIViewController {

    fileprivate struct Constants {
        static let EditURL = "http://fr.openfoodfacts.org/cgi/product.pl?type=edit&code="
    }
    
    fileprivate var request: URLRequest? = nil
    
    var barcode: String? {
        didSet {
            if let existingBarcode = barcode {
                request = URLRequest(url: URL(string: Constants.EditURL + existingBarcode)!)
                refresh()
            }
        }
    }
    
    func refresh() {
        if let existingRequest = request {
            webView?.loadRequest(existingRequest)
        }
    }
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Edit", comment: "Title of viewcontroller which allows editing of the product in a webview.") 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
}
