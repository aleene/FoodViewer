//
//  LanguageHeaderView.swift
//  FoodViewer
//
//  Created by arnaud on 06/06/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

// https://stackoverflow.com/questions/36926612/swift-how-creating-custom-viewforheaderinsection-using-a-xib-file

protocol LanguageHeaderDelegate: class {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int)
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int)
}

class LanguageHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var languageLabel: UILabel! {
        didSet {
            setTitle()
        }
    }

    @IBOutlet weak var changeLanguageButton: UIButton! {
        didSet {
            setButton()
        }
    }
    
    @IBAction func changeLanguageButtonTapped(_ sender: UIButton) {
        delegate?.changeLanguageButtonTapped(changeLanguageButton, in: section)
    }
   
    @IBOutlet weak var changeViewModeButton: UIButton! {
        didSet {
            changeViewModeButton.isHidden = true
        }
    }
    
    @IBAction func changeViewModeButtonTapped(_ sender: UIButton) {
        delegate?.changeViewModeButtonTapped(changeViewModeButton, in: section)
    }
    
    weak var delegate: LanguageHeaderDelegate?
    
    var section: Int!
    
    var buttonText: String? = nil {
        didSet {
            setButton()
        }
    }
    
    var title: String? = nil {
        didSet {
            setTitle()
        }
    }

    var buttonIsEnabled = false {
        didSet {
            changeLanguageButton.isEnabled = buttonIsEnabled
            buttonIsEnabled ? changeLanguageButton.setTitleColor(.blue, for: .normal) : changeLanguageButton.setTitleColor(.darkGray, for: .normal)
        }
    }
    
    private func setTitle() {
        languageLabel?.text = title ?? "LanguageHeaderView: No header"
        languageLabel?.sizeToFit()
    }
    
    private func setButton() {
        changeLanguageButton?.setTitle(buttonText, for: .normal)
        changeLanguageButton?.sizeToFit()
    }
}
