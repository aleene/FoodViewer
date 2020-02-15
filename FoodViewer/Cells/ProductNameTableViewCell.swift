//
//  ProductNameTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol ProductNameCellDelegate: class {
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedDoubleTap textView:UITextView)
    
    func productNameTableViewCell(_ sender: ProductNameTableViewCell, receivedTapOn button:UIButton)
}

class ProductNameTableViewCell: UITableViewCell {
    
    /// string to use for the product
    var name: String? = nil {
        didSet {
            setName()
        }
    }
    
    /// editMode - determines whether the button is shown and the name in editMode
    var editMode: Bool = false {
        didSet {
            setTextViewStyle()
            setTextViewClearButton()
            setName()
        }
    }
    
    var delegate: ProductNameCellDelegate? = nil {
        didSet {
            nameTextView?.delegate = delegate as? UITextViewDelegate
        }
    }
    
    var isMultilingual = false {
        didSet {
            toggleViewModeButton?.isHidden = editMode ? true : !isMultilingual
        }
    }
    
    var buttonNotDoubleTap: Bool = true {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
    }
    
    @IBOutlet weak var nameTextView: UITextView! {
        didSet {
            setTextViewStyle()
        }
    }
    
    @IBOutlet weak var clearTextViewButton: UIButton! {
        didSet {
            setTextViewClearButton()
        }
    }
    
    @IBAction func clearTextViewButtonTapped(_ sender: UIButton) {
        name = ""
    }
    
    @IBOutlet weak var toggleViewModeButton: UIButton! {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
    }

    @IBAction func toggleViewModeButtonTapped(_ sender: UIButton) {
        delegate?.productNameTableViewCell(self, receivedTapOn: toggleViewModeButton)
    }
    
    private func setTextViewStyle() {
        nameTextView.layer.borderWidth = 0.5
        nameTextView?.delegate = delegate as? UITextViewDelegate
        nameTextView?.tag = tag
        nameTextView?.isEditable = editMode
        nameTextView?.isScrollEnabled = editMode
        if #available(iOS 13.0, *) {
            nameTextView.backgroundColor = editMode ? .secondarySystemBackground : .systemBackground
            nameTextView?.layer.borderColor = editMode ? UIColor.darkGray.cgColor : UIColor.systemBackground.cgColor
            nameTextView.textColor = editMode ? .secondaryLabel : .label
        } else {
            nameTextView.backgroundColor = editMode ? .groupTableViewBackground : .white
            nameTextView?.layer.borderColor = editMode ? UIColor.darkGray.cgColor : UIColor.white.cgColor
            nameTextView.textColor = .black
        }
        
        if editMode {
            nameTextView?.layer.cornerRadius = 5
            nameTextView?.clipsToBounds = true
        } else {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
        toggleViewModeButton?.isHidden = editMode ? true : !isMultilingual

    }
    
    private func setTextViewClearButton() {
        clearTextViewButton?.isHidden = !editMode
    }
    
    private func setName() {
        nameTextView.text = (name != nil) && (name!.count > 0) ? name! :  ( editMode ? "" : TranslatableStrings.NoName )
    }
    
    override var tag: Int {
        didSet {
            nameTextView?.tag = tag
        }
    }

    @objc func nameTapped() {
        delegate?.productNameTableViewCell(self, receivedDoubleTap: nameTextView)
    }
    
    private func setButtonOrDoubletap(_ useButton:Bool?) {
        guard let validUseButton = useButton else { return }
        if validUseButton {
            toggleViewModeButton?.isHidden = editMode ? true : !isMultilingual
        } else {
            toggleViewModeButton?.isHidden = true
        }
        if !validUseButton {
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductNameTableViewCell.nameTapped))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
            doubleTapGestureRecognizer.cancelsTouchesInView = false
            nameTextView?.addGestureRecognizer(doubleTapGestureRecognizer)
        }
    }

    func willDisappear() {
        guard let validGestureRecognizers = nameTextView.gestureRecognizers else { return }
        for gesture in validGestureRecognizers {
            // remove double tap gesture
            if let tapGesture = gesture as? UITapGestureRecognizer,
                tapGesture.numberOfTouchesRequired == 2 {
                nameTextView?.removeGestureRecognizer(gesture)
            }
        }
    }

}
