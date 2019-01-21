//
//  CreateOFFAccountViewController.swift
//  FoodViewer
//
//  Created by arnaud on 21/01/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit
import WebKit

class CreateOFFAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = TranslatableStrings.CreateOffAccount
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBOutlet weak var webView: WKWebView!
    

}
