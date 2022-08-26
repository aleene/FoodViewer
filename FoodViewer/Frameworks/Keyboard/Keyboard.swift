//
//  Keyboard.swift
//  Numbers Keyboard
//
//  Created by Dan Livingston  on 3/30/16.
//  Copyright © 2016 Zombie Koala. All rights reserved.
//

import UIKit

// The view controller will adopt this protocol (delegate)
// and thus must contain the keyWasTapped method
protocol KeyboardDelegate: AnyObject
{
    func keyWasTapped(_ character: String)
    func backspace()
    func enter()
}


class Keyboard: UIView {

    // This variable will be set as the view controller so that
    // the keyboard can send messages to the view controller.
    weak var delegate: KeyboardDelegate?
    
    // MARK:- keyboard initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let xibFileName = "Keyboard" // xib extension not included
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    // MARK:- Button actions from .xib file
    
    @IBAction func keyTapped(_ sender: UIButton) {
        // When a button is tapped, send that information to the
        // delegate (ie, the view controller)
        self.delegate?.keyWasTapped(sender.titleLabel!.text!) // could alternatively send a tag value
    }

    @IBAction func backspace(_ sender: UIButton) {
        self.delegate?.backspace()
    }

    @IBAction func enter(_ sender: UIButton) {
        self.delegate?.enter()

    }
}
