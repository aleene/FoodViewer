//
//  IngredientsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsFullTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView! {
        didSet {
            setupTextView()
        }
    }
    
    @IBOutlet weak var clearTextViewButton: UIButton! {
        didSet {
            setTextViewClearButton()
        }
    }
    
    @IBAction func clearTextViewButtonTapped(_ sender: UIButton) {
        ingredients = ""
    }
    
    private func setTextViewClearButton() {
        clearTextViewButton?.isHidden = !editMode
    }

    private func setupTextView() {
        // the textView might not be initialised
        guard textView != nil else { return }

        // Double tapping allows to change the language of the ingredients
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IngredientsFullTableViewCell.ingredientsTapped))
        tapGestureRecognizer.numberOfTapsRequired = 2
        textView?.addGestureRecognizer(tapGestureRecognizer)
        
        textView?.layer.borderWidth = 0.5
        textView?.delegate = textViewDelegate
        textView?.tag = textViewTag

        if editMode {
            textView?.backgroundColor = UIColor.groupTableViewBackground
            textView?.layer.cornerRadius = 5
            textView?.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            textView?.clipsToBounds = true
            textView.isScrollEnabled = true
        } else {
            textView?.backgroundColor = UIColor.white
            textView?.layer.borderColor = UIColor.white.cgColor
            textView.isScrollEnabled = false
        }
        
        if editMode {
            if unAttributedIngredients.characters.count > 0 {
                textView?.text = unAttributedIngredients
            } else {
                textView?.text = Constants.NoIngredientsText
            }
            // textView?.removeGestureRecognizer(tapGestureRecognizer)
        } else {
            if attributedIngredients.length > 0 {
                textView?.attributedText = attributedIngredients
            } else {
                textView?.text = Constants.NoIngredientsText
            }
        }
        textView?.sizeToFit()
        // print(textView.frame.size)
        // self.frame.size.height = textView.frame.size.height
    }
    
    var editMode: Bool = false {
        didSet {
            setupTextView()
            setTextViewClearButton()
        }
    }

    var textViewDelegate: IngredientsTableViewController? = nil
    
    var textViewTag: Int = 0
    
    @IBOutlet weak var changeLanguageButton: UIButton!
    
    @IBAction func ChangeLanguageButtonTapped(_ sender: UIButton) {
    }
    
    private struct Constants {
        static let NoIngredientsText = NSLocalizedString("no ingredients specified", comment: "Text in a TagListView, when no ingredients are available in the product data.")
        static let UnbalancedWarning = NSLocalizedString(" (WARNING: check brackets, they are unbalanced)", comment: "a warning to check the brackets used, they are unbalanced")
        static let NoLanguageText = NSLocalizedString("none defined", comment: "the ingredients text has no associated language defined")
    }
    
    var ingredients: String? = nil {
        didSet {
            if let text = ingredients {
                if !text.isEmpty {
                    // defined the attributes for allergen text
                    let fontSize = (textView.font?.pointSize)!
                    // let currentFont = (textView.font?.fontName)!
                    // textView.font = UIFont(name: ()!, size: fontSize)!

                    let allergenAttributes = [NSForegroundColorAttributeName : UIColor.red, NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
                    let noAttributes = [NSForegroundColorAttributeName : UIColor.black,  NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)]
                    // create a attributable string
                    let myString = NSMutableAttributedString(string: "", attributes: allergenAttributes)
                    let components = text.components(separatedBy: "_")
                    for (index, component) in components.enumerated() {
                        // if the text starts with a "_", then there will be an empty string component
                        let (_, fraction) = modf(Double(index)/2.0)
                        if (fraction) > 0 {
                            let attributedString = NSAttributedString(string: component, attributes: allergenAttributes)
                            myString.append(attributedString)
                        } else {
                            let attributedString = NSAttributedString(string: component, attributes: noAttributes)
                            myString.append(attributedString)
                        }
                    }
                    if  (text.unbalancedDelimiters()) ||
                        (text.oddNumberOfString("_")) {
                        let attributedString = NSAttributedString(string: Constants.UnbalancedWarning, attributes: noAttributes)
                        myString.append(attributedString)
                    }
                    attributedIngredients = myString
                    unAttributedIngredients = text
                }
            }
            setupTextView()
        }
    }
    
    private var attributedIngredients = NSMutableAttributedString()
    
    private var unAttributedIngredients: String = ""
    
    var languageCode: String? = nil {
        didSet {
            changeLanguageButton.setTitle(languageCode != nil ? OFFplists.manager.translateLanguage(languageCode!, language:Locale.preferredLanguages[0])  : Constants.NoLanguageText, for: UIControlState())
        }
    }

    var numberOfLanguages: Int = 0 {
        didSet {
            if editMode {
                changeLanguageButton.isEnabled = false
            } else {
                if numberOfLanguages > 1 {
                    changeLanguageButton?.isEnabled = true
                } else {
                    changeLanguageButton?.isEnabled = false
                }
            }
        }
    }

    func ingredientsTapped() {
        NotificationCenter.default.post(name: .IngredientsTextViewTapped, object: nil)
    }

}

extension String {
    
    func unbalancedDelimiters() -> Bool {
        return (self.unbalanced("(", endDelimiter: ")")) ||
            (self.unbalanced("{", endDelimiter: "}")) ||
            (self.unbalanced("[", endDelimiter: "]"))
    }
    
    func unbalanced(_ startDelimiter: String, endDelimiter: String) -> Bool {
        return (self.difference(startDelimiter, endDelimiter: endDelimiter) != 0)
    }

    func difference(_ startDelimiter: String, endDelimiter: String) -> Int {
        return self.components(separatedBy: startDelimiter).count - self.components(separatedBy: endDelimiter).count
    }
    
    func oddNumberOfString(_ testString: String) -> Bool {
        let (_, fraction) = modf(Double(self.components(separatedBy: testString).count-1)/2.0)
        return (fraction > 0)
    }
}

// Definition:
extension Notification.Name {
    static let IngredientsTextViewTapped = Notification.Name("IngredientsFullTableViewCell.Notification.IngredientsTextViewTapped")
}

