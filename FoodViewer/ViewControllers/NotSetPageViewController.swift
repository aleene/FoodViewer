//
//  NotSetPageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 12/03/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class NotSetPageViewController: UIViewController {

    @IBOutlet weak var label: UILabel! {
        didSet {
            label?.text = TranslatableStrings.SelectProduct
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    } 

}
