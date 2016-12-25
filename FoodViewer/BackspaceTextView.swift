//
//  BackspaceTextView.swift
//  TagListView
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

/// Delegate object for the BackspaceTextView type that inherits from class and gives access to a call when the textView hits backspace.
internal protocol BackspaceTextFieldDelegate: class {
    func textFieldDidEnterBackspace(_ textField: BackspaceTextField)
}

/// UITextView subclass that gives access to when the text view calls backspace on empty text.
internal class BackspaceTextField: UITextField {

    /// The backspace delegate for the BackspaceTextView
    internal weak var backspaceDelegate: BackspaceTextFieldDelegate?
    
    internal func keyboardInputShouldDelete(_ textField: UITextField) -> Bool {
        if text?.characters.count == 0 {
            backspaceDelegate?.textFieldDidEnterBackspace(self)
        }
        return true
    }
}
