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
}

class ProductNameTableViewCell: UITableViewCell {
    
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
    
    private func setTextViewStyle() {
        nameTextView.layer.borderWidth = 0.5
        nameTextView?.delegate = delegate as? UITextViewDelegate
        nameTextView?.tag = tag
        nameTextView?.isEditable = editMode
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductNameTableViewCell.nameTapped))
        tapGestureRecognizer.numberOfTapsRequired = 2
        nameTextView?.addGestureRecognizer(tapGestureRecognizer)
        nameTextView?.isScrollEnabled = editMode
        nameTextView.backgroundColor = editMode ? UIColor.groupTableViewBackground : UIColor.white
        
        if editMode {
            nameTextView?.backgroundColor = UIColor.groupTableViewBackground
            nameTextView?.layer.cornerRadius = 5
            nameTextView?.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            nameTextView?.clipsToBounds = true
            // nameTextField.removeGestureRecognizer(tapGestureRecognizer)
        } else {
            nameTextView?.layer.borderColor = UIColor.white.cgColor
        }
        print ("setTextView", self.frame)
        //if nameTextView?.text != nil && !nameTextView!.text!.isEmpty {
        //    nameTextView?.sizeToFit()
        //}

    }
    
    var name: String? = nil {
        didSet {
            setName()
        }
    }
    
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
}
