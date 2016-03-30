//
//  IngredientsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsFullTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    struct Constants {
        static let NoIngredientsText = NSLocalizedString("no ingredients specified", comment: "Text in a TagListView, when no ingredients are available in the product data.")
        static let UnbalancedWarning = NSLocalizedString(" (WARNING: check brackets, they are unbalanced)", comment: "a warning to check the brackets used, they are unbalanced")
    }
    
    var ingredients: String? = nil {
        didSet {
            if let text = ingredients {
                if !text.isEmpty {
                    // defined the attributes for allergen text
                    let allergenAttributes = [NSForegroundColorAttributeName : UIColor.redColor()]
                    let noAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
                    // create a attributable string
                    let myString = NSMutableAttributedString(string: "", attributes: allergenAttributes)
                    let components = text.componentsSeparatedByString("_")
                    for (index, component) in components.enumerate() {
                        // if the text starts with a "_", then there will be an empty string component
                        let (_, fraction) = modf(Double(index)/2.0)
                        if (fraction) > 0 {
                            let attributedString = NSAttributedString(string: component, attributes: allergenAttributes)
                            myString.appendAttributedString(attributedString)
                        } else {
                            let attributedString = NSAttributedString(string: component, attributes: noAttributes)
                            myString.appendAttributedString(attributedString)
                        }
                    }
                    if  (text.unbalancedDelimiters()) ||
                        (text.oddNumberOfString("_")) {
                        let attributedString = NSAttributedString(string: Constants.UnbalancedWarning, attributes: noAttributes)
                        myString.appendAttributedString(attributedString)
                    }
                    ingredientsLabel.attributedText = myString
                } else {
                    ingredientsLabel.text = Constants.NoIngredientsText
                }
            }
        }
    }
    

}

extension String {
    
    func unbalancedDelimiters() -> Bool {
        return (self.unbalanced("(", endDelimiter: ")")) ||
            (self.unbalanced("{", endDelimiter: "}")) ||
            (self.unbalanced("[", endDelimiter: "]"))
    }
    
    func unbalanced(startDelimiter: String, endDelimiter: String) -> Bool {
        return (self.difference(startDelimiter, endDelimiter: endDelimiter) != 0)
    }

    func difference(startDelimiter: String, endDelimiter: String) -> Int {
        return self.componentsSeparatedByString(startDelimiter).count - self.componentsSeparatedByString(endDelimiter).count
    }
    
    func oddNumberOfString(testString: String) -> Bool {
        let (_, fraction) = modf(Double(self.componentsSeparatedByString(testString).count-1)/2.0)
        return (fraction > 0)
    }

}