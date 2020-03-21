//
//  IngredientsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol IngredientsFullCellDelegate: class {
    
    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, receivedActionOn textView:UITextView)
    
    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, receivedTapOn button:UIButton)

    func ingredientsFullTableViewCell(_ sender: IngredientsFullTableViewCell, heightChangedTo height:CGFloat)
}


class IngredientsFullTableViewCell: UITableViewCell {

    private struct Constant {
        static let NoIngredientsText = TranslatableStrings.NoIngredients
        static let UnbalancedWarning = TranslatableStrings.UnbalancedWarning
        struct Cell {
            static let HeightChangeTrigger = CGFloat(2.0)
            static let DefaultHeight = CGFloat(44.0)
            static let Margin = CGFloat(8.0)
        }
        struct IngredientsTextView {
            static let DefaultHeight = CGFloat(37.0) // height for a single row of text
        }
    }
    
    private var oldTextViewHeight = Constant.IngredientsTextView.DefaultHeight

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.isScrollEnabled = false
            var textViewFrame = textView.frame
            textViewFrame.size.height = Constant.IngredientsTextView.DefaultHeight
            textView.frame = textViewFrame
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
    
    @IBOutlet weak var toggleViewModeButton: UIButton! {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
    }
    
    @IBAction func toggleViewModeButtonTapped(_ sender: UIButton) {
        delegate?.ingredientsFullTableViewCell(self, receivedTapOn: toggleViewModeButton)
    }
    
    @IBOutlet weak var textViewTrailingLayoutConstraint: NSLayoutConstraint! {
           didSet {
               setTrailingConstraint()
           }
       }
    
    private func setTrailingConstraint() {
        guard let toggleViewModeButtonWidth = toggleViewModeButton?.frame.size.width else { return }
        guard let clearTextViewButtonWidth = clearTextViewButton?.frame.size.width else { return }
        if isMultilingual {
            textViewTrailingLayoutConstraint?.constant = editMode ? clearTextViewButtonWidth : toggleViewModeButtonWidth
        } else {
            textViewTrailingLayoutConstraint?.constant = editMode ? clearTextViewButtonWidth : 0
        }
    }

    private func setTextViewClearButton() {
        clearTextViewButton?.isHidden = !editMode
    }

    private func setupTextView() {
        // the textView might not be initialised
        guard textView != nil else { return }

        
        textView?.layer.borderWidth = 0.5
        textView?.delegate = delegate as? UITextViewDelegate
        textView?.tag = textViewTag
        textView?.isEditable = editMode
        
        if #available(iOS 13.0, *) {
            textView.backgroundColor = editMode ? .secondarySystemBackground : .systemBackground
            textView?.layer.borderColor = editMode ? UIColor.darkGray.cgColor : UIColor.systemBackground.cgColor
            textView.textColor = editMode ? .secondaryLabel : .label
        } else {
            textView.backgroundColor = editMode ? .groupTableViewBackground : .white
            textView?.layer.borderColor = editMode ? UIColor.gray.cgColor : UIColor.white.cgColor
            textView.textColor = .black
        }
        if editMode {
            textView?.layer.cornerRadius = 5
            textView?.clipsToBounds = true
            textView?.isScrollEnabled = true
        } else {
            textView?.isScrollEnabled = false
        }
        setButtonOrDoubletap(buttonNotDoubleTap)

        if editMode {
            if unAttributedIngredients.count > 0 {
                // needed to reset the color of the text. It is not actually shown.
                textView?.attributedText = nil // NSMutableAttributedString(string: "fake text", attributes: [NSAttributedString.Key.foregroundColor : UIColor.green,  NSAttributedString.Key.font: UIFont.systemFont(ofSize: (textView.font?.pointSize)!)])
                textView?.text = unAttributedIngredients
            } else {
                textView?.text = nil
            }
        } else {
            if attributedIngredients.length > 0 {
                textView?.attributedText = attributedIngredients
            } else {
                //print("textView before",textView?.text,textView?.attributedText.description, textView.frame.height)
                textView?.attributedText = nil
                textView?.text = Constant.NoIngredientsText
                //print("textView after",textView.frame.height)
            }
        }
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        let height = newSize.height + 2 * Constant.Cell.Margin
        var newFrame = frame
        newFrame.size.height = height
        frame = newFrame
        //print("TextView height before ", oldTextViewHeight, "new height ", newSize.height)
        // self.frame.size.height = textView.frame.size.height
        //if abs(oldTextViewHeight - newSize.height) > Constant.Cell.HeightChangeTrigger {
            oldTextViewHeight = newSize.height
            delegate?.ingredientsFullTableViewCell(self, heightChangedTo: newSize.height + 2 * Constant.Cell.Margin)
        //}
    }
    
    var editMode: Bool = false {
        didSet {
            setupTextView()
            setTextViewClearButton()
            setTrailingConstraint()
        }
    }

    var delegate: IngredientsFullCellDelegate? = nil {
        didSet {
            if delegate != nil && delegate! is UITextViewDelegate {
                textView.delegate = delegate as? UITextViewDelegate
            }
        }
    }
    
    var textViewTag: Int = 0
    
    var isMultilingual = false {
        didSet {
            toggleViewModeButton?.isHidden = !isMultilingual
            setTrailingConstraint()
        }
    }
    
    var buttonNotDoubleTap: Bool = true {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
            setTrailingConstraint()
        }
    }

    var ingredients: String? = nil {
        didSet {
            if let text = ingredients {
                if !text.isEmpty {
                    // defined the attributes for allergen text
                    let fontSize = (textView.font?.pointSize)!
                    var noAttributes: [NSAttributedString.Key:Any] = [:]
                    // let currentFont = (textView.font?.fontName)!
                    // textView.font = UIFont(name: ()!, size: fontSize)!

                    let allergenAttributes = [NSAttributedString.Key.foregroundColor : UIColor.systemRed, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
                    if #available(iOS 13.0, *) {
                        noAttributes = [NSAttributedString.Key.foregroundColor : UIColor.label,  NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
                    } else {
                        noAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black,  NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
                    }
                    // create a attributable string
                    let myString = NSMutableAttributedString(string: "", attributes: noAttributes)
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
                        let attributedString = NSAttributedString(string: Constant.UnbalancedWarning, attributes: noAttributes)
                        myString.append(attributedString)
                    }
                    attributedIngredients = myString
                    unAttributedIngredients = text
                } else {
                    attributedIngredients = NSMutableAttributedString.init(string: "")
                    unAttributedIngredients = ""
                }
            } else {
                attributedIngredients = NSMutableAttributedString.init(string: "")
                unAttributedIngredients = ""
            }
            setupTextView()
        }
    }
    
    private var attributedIngredients = NSMutableAttributedString()
    
    private var unAttributedIngredients: String = ""
    
    @objc func ingredientsTapped() {
        delegate?.ingredientsFullTableViewCell(self, receivedActionOn: textView)
    }

    private func setButtonOrDoubletap(_ useButton:Bool?) {
        guard let validUseButton = useButton else { return }
        if isMultilingual && !editMode {
            toggleViewModeButton?.isHidden = !validUseButton
            if !validUseButton {
                let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IngredientsFullTableViewCell.ingredientsTapped))
                doubleTapGestureRecognizer.numberOfTapsRequired = 2
                doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
                doubleTapGestureRecognizer.cancelsTouchesInView = false
                textView?.addGestureRecognizer(doubleTapGestureRecognizer)
            }
        } else {
            toggleViewModeButton?.isHidden = true
        }
    }
    
    func willDisappear() {
        guard let validGestureRecognizers = textView?.gestureRecognizers else { return }
        for gesture in validGestureRecognizers {
            // remove double tap gesture
            if let tapGesture = gesture as? UITapGestureRecognizer,
                tapGesture.numberOfTouchesRequired == 2 {
                textView?.removeGestureRecognizer(gesture)
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
