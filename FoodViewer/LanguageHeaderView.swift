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
    
    weak var delegate: LanguageHeaderDelegate? = nil
    
    var section: Int = 0
    
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
    
    // Set the image of the button:
    // - true: the OCR-button
    // - false: the change viewmode-button
    var setButtonTypeToOCR: Bool = false {
        didSet {
            if setButtonTypeToOCR {
                changeViewModeButton.setImage(UIImage.init(named: "OCR"), for: .normal)
            } else {
                changeViewModeButton.setImage(UIImage.init(named: "TripleTap"), for: .normal)
            }
        }
    }

    var buttonNotDoubleTap: Bool? = nil {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
    }
    
    var buttonIsEnabled = false {
        didSet {
            changeLanguageButton.isEnabled = buttonIsEnabled
            buttonIsEnabled ? changeLanguageButton.setTitleColor(.systemBlue, for: .normal) : changeLanguageButton.setTitleColor(.darkGray, for: .normal)
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
    
    @objc func changeView() {
        delegate?.changeViewModeButtonTapped(changeViewModeButton, in: section)
    }
    
    private func setButtonOrDoubletap(_ button:Bool?) {
        guard let validButton = button else { return }
        if validButton {
            self.changeViewModeButton.isHidden = !validButton
        } else {
            let doubleTapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(changeView))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            doubleTapGestureRecognizer.numberOfTouchesRequired = 1
            doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
            doubleTapGestureRecognizer.cancelsTouchesInView = false
            self.addGestureRecognizer(doubleTapGestureRecognizer)
        }
    }
    
    func willDisappear() {
        if let validGestureRecognizers = self.gestureRecognizers {
            for gesture in validGestureRecognizers {
                if let doubleTapGesture = gesture as? UITapGestureRecognizer,
                    doubleTapGesture.numberOfTapsRequired == 2,
                    doubleTapGesture.numberOfTouchesRequired == 1 {
                    self.removeGestureRecognizer(gesture)
                }
            }
        }
    }

}

extension LanguageHeaderDelegate {
    
    func changeLanguageButtonTapped(_ sender: UIButton, in section: Int) {}
    
    func changeViewModeButtonTapped(_ sender: UIButton, in section: Int) {}
}
