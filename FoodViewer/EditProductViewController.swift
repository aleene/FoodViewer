//
//  EditProductViewController.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class EditProductViewController: UIViewController {

    private struct Constants {
        static let EditURL = "http://fr.openfoodfacts.org/cgi/product.pl?type=edit&code="
    }
    
    private var request: NSURLRequest? = nil
    
    var barcode: String? {
        didSet {
            if let existingBarcode = barcode {
                request = NSURLRequest(URL: NSURL(string: Constants.EditURL + existingBarcode)!)
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
        title = "Edit"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
}
