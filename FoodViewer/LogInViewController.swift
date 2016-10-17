//
//  LogInViewController.swift
//  FoodViewer
//
//  Created by arnaud on 15/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let usernameKey = "batman"
    let passwordKey = "Hello Bruce!"
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Action for checking username/password
    @IBAction func loginAction(_ sender: AnyObject) {
        
        if (checkLogin(username: self.usernameTextField.text!, password: self.passwordTextField.text!)) {
            self.performSegue(withIdentifier: "dismissLogin", sender: self)
        }
        
    }
    
    func checkLogin(username: String, password: String ) -> Bool {
        
        return ((username == usernameKey) && (password == passwordKey)) ? true : false
    }
    
    
}
