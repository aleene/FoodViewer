//
//  ProductViewController.swift
//  FoodViewer
//
//  Created by arnaud on 31/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {

    var product: Product? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        product = Product()
    }
}
