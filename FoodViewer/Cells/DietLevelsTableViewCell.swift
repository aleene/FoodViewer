//
//  DietLevelsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 22/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit
/**
 Protocol for the DietLevelsTableViewCell class.
 - functions:
    - dietLevelsTableViewCell(_:receivedTapOn:):  handles double taps that are received on the button in the cell.
 */
protocol DietLevelsTableViewCellDelegate: class {
    
    /// Function handles button taps or double taps that are received in the cell.
    /// - parameter _: The tableViewCell that inititated the call.
    /// - parameter receivedTapOn: The id of the button that received the tap. If the cell used doubleTap this will be nil
    func dietLevelsTableViewCell(_ sender: DietLevelsTableViewCell, receivedTapOn button:UIButton?)

}
/**
A tableViewCell, which shows how a product conforms to a diet.
 
 + Parameters:
    -  values: An array with values for each conformance level. The size of the array determines how many levels (circles) are shown. The value is shown inside each circle. The array is assumed to be ordered from low conformance to high conformance.
    - conclusion:The index (in the values array) with the final conformance conclusion.
    -  delegate:A delegate class, which will  handle the protocol functions.
    -  buttonNotDoubleTap:Indicates whether the button should be shown, or whether a doubleTap should be accepted instead of the button.
    -  willDisappear(): Function to call when the cell will disppear/unload. It will do some cleanup.

A diet is shown as a row with coloured circles. Each circle indicates a level of conformance.
Each circle as a number to indicate how many triggers correspond to that level.
The user can tap a button for more information.
 - Important:
The class has an optional protocol.
 */
final class DietLevelsTableViewCell: UITableViewCell {
//
// MARK: - Public variables and functions
//
    /// An array with values for each conformance level. The size of the array determines how many levels (circles)
    public var values: [Int] = []
        
    /// The index (in the values array) with the final conformance conclusion.
    public var conclusion: Int? = nil {
        didSet {
            setup()
        }
    }

    /// A delegate class, which handles the protocol functions.
    public var delegate: DietLevelsTableViewCellDelegate? = nil
    
    /// Indicates whether the button should be shown, or whether a doubleTap should be accepted instead of the button.
    public var buttonNotDoubleTap: Bool = true {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
           }
    }
    /// function to call when the cell disappears. It will nillify any gesture.
    public func willDisappear() {
        guard let validGestureRecognizers = self.gestureRecognizers else { return }
        for gesture in validGestureRecognizers {
            if let doubleTapGesture = gesture as? UITapGestureRecognizer,
                doubleTapGesture.numberOfTapsRequired == 2 {
                self.removeGestureRecognizer(gesture)
            }
        }
    }
//
// MARK: - Interface elements
//
    @IBOutlet weak var level0Label: UILabel! {
        didSet {
            level0Label?.layer.cornerRadius = cornerRadius
            level0Label?.clipsToBounds = true
            if #available(iOS 13.0, *) {
                level0Label?.textColor = .secondaryLabel
            } else {
                level0Label?.textColor = .black
            }

        }
    }
    
    @IBOutlet weak var level1Label: UILabel! {
        didSet {
            level1Label?.layer.cornerRadius = cornerRadius
            level1Label?.clipsToBounds = true
            level1Label?.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.4).cgColor
            level1Label?.layer.borderWidth = CGFloat(1.0)
            if #available(iOS 13.0, *) {
                level1Label?.textColor = .secondaryLabel
            } else {
                level1Label?.textColor = .black
            }
        }
    }
    
    @IBOutlet weak var level2Label: UILabel! {
        didSet {
            level2Label?.layer.cornerRadius = cornerRadius
            level2Label?.clipsToBounds = true
            level2Label?.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.4).cgColor
            level2Label?.layer.borderWidth = CGFloat(1.0)
            if #available(iOS 13.0, *) {
                level2Label?.textColor = .secondaryLabel
            } else {
                level2Label?.textColor = .black
            }
        }
    }
    
    @IBOutlet weak var level3Label: UILabel! {
        didSet {
            level3Label?.layer.cornerRadius = cornerRadius
            level3Label?.clipsToBounds = true
            level3Label?.layer.borderColor = UIColor.systemYellow.withAlphaComponent(0.4).cgColor
            level3Label?.layer.borderWidth = CGFloat(1.0)
            if #available(iOS 13.0, *) {
                level3Label?.textColor = .secondaryLabel
            } else {
                level3Label?.textColor = .black
            }
        }
    }
    
    @IBOutlet weak var level4Label: UILabel! {
        didSet {
            level4Label?.layer.cornerRadius = cornerRadius
            level4Label?.clipsToBounds = true
            level4Label?.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
            level4Label?.layer.borderWidth = CGFloat(1.0)
            if #available(iOS 13.0, *) {
                level4Label?.textColor = .secondaryLabel
            } else {
                level4Label?.textColor = .black
            }

        }
    }
    
    @IBOutlet weak var level5Label: UILabel! {
        didSet {
            level5Label?.layer.cornerRadius = cornerRadius
            level5Label?.clipsToBounds = true
            level5Label?.layer.borderColor = UIColor.systemTeal.withAlphaComponent(0.4).cgColor
            level5Label?.layer.borderWidth = CGFloat(1.0)
            if #available(iOS 13.0, *) {
                level5Label?.textColor = .secondaryLabel
            } else {
                level5Label?.textColor = .black
            }

        }
    }
    
    @IBOutlet weak var toggleViewModeButton: UIButton! {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
    }

    @IBOutlet weak var level6Label: UILabel! {
        didSet {
            level6Label?.layer.cornerRadius = cornerRadius
            level6Label?.clipsToBounds = true
            if #available(iOS 13.0, *) {
                level6Label?.textColor = .secondaryLabel
            } else {
                level6Label?.textColor = .black
            }

        }
    }
    
    @IBAction func toggleViewModeButtonTapped(_ sender: UIButton) {
        buttonTapped()
        state = !state
        toggleViewModeButton?.setImage(UIImage.init(named: state ? "UpToClose" : "DownToOpen"), for: .normal)
    }
//
// MARK: - Private variables
//
    private struct Constant {
        static let Divisor = 2.5
        static let Height = CGFloat(25.0)
    }
    
    private var cornerRadius: CGFloat {
        // All the level*Label's have the same size.
        CGFloat(level0Label?.bounds.size.height ?? Constant.Height) / CGFloat(1.1)
    }

    /// The state indicates, which icon will be shown as toggle.
    /// - false (closed) = down arrow
    /// - true (open) = up arrow
    private var state = false
//
// MARK: - Private functions
//
    /// Setup the numbers of the diet levels and the conclusion level.
    private func setup() {
        guard level1Label != nil else { return }
        guard level2Label != nil else { return }
        guard level3Label != nil else { return }
        guard level4Label != nil else { return }
        guard level5Label != nil else { return }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumSignificantDigits = 1
        if values.count == 7 {
            level0Label?.text = formatter.string(from: NSNumber(integerLiteral:values[0]))
            level1Label?.text = formatter.string(from: NSNumber(integerLiteral:values[1]))
            level2Label?.text = formatter.string(from: NSNumber(integerLiteral:values[2]))
            level3Label?.text = formatter.string(from: NSNumber(integerLiteral:values[3]))
            level4Label?.text = formatter.string(from: NSNumber(integerLiteral:values[4]))
            level5Label?.text = formatter.string(from: NSNumber(integerLiteral:values[5]))
            level6Label?.text = formatter.string(from: NSNumber(integerLiteral:values[6]))
        } else if values.count == 6 {
            level0Label?.text = formatter.string(from: NSNumber(integerLiteral:values[0]))
            level1Label?.text = formatter.string(from: NSNumber(integerLiteral:values[1]))
            level2Label?.text = formatter.string(from: NSNumber(integerLiteral:values[2]))
            level3Label?.text = formatter.string(from: NSNumber(integerLiteral:values[3]))
            level4Label?.text = formatter.string(from: NSNumber(integerLiteral:values[4]))
            level5Label?.text = formatter.string(from: NSNumber(integerLiteral:values[5]))
        } else if values.count == 5 {
            level1Label?.text = formatter.string(from: NSNumber(integerLiteral:values[0]))
            level2Label?.text = formatter.string(from: NSNumber(integerLiteral:values[1]))
            level3Label?.text = formatter.string(from: NSNumber(integerLiteral:values[2]))
            level4Label?.text = formatter.string(from: NSNumber(integerLiteral:values[3]))
            level5Label?.text = formatter.string(from: NSNumber(integerLiteral:values[4]))
        } else if values.count == 4 {
            level1Label?.text = formatter.string(from: NSNumber(integerLiteral:values[0]))
            level2Label?.text = formatter.string(from: NSNumber(integerLiteral:values[1]))
            level3Label?.text = formatter.string(from: NSNumber(integerLiteral:values[2]))
            level4Label?.text = formatter.string(from: NSNumber(integerLiteral:values[3]))
        } else if values.count == 3 {
            level2Label?.text = formatter.string(from: NSNumber(integerLiteral:values[0]))
            level3Label?.text = formatter.string(from: NSNumber(integerLiteral:values[1]))
            level4Label?.text = formatter.string(from: NSNumber(integerLiteral:values[2]))
        } else if values.count == 2 {
            
        } else if values.count == 1 {
            level3Label?.text = formatter.string(from: NSNumber(integerLiteral:values[0]))
        }
        resetColors()
        
        if let validConclusion = conclusion {
            switch validConclusion {
            case -3:
                level0Label?.backgroundColor = .systemPurple
                level0Label?.textColor = .white
            case -2:
                level1Label?.backgroundColor = .systemRed
                level1Label?.textColor = .white
            case -1:
                level2Label?.backgroundColor = .systemOrange
                level2Label?.textColor = .white
            case 0:
                level3Label?.backgroundColor = .systemYellow
                level3Label?.textColor = .black
            case 1:
                level4Label?.backgroundColor = .systemGreen
                level4Label?.textColor = .white
            case 2:
                level5Label?.backgroundColor = .systemTeal
                level5Label?.textColor = .white
            case 3:
                level6Label?.backgroundColor = .systemBlue
                level6Label?.textColor = .white
            default:
                break
            }
        }

    }
    
    /// Setup the colours of the level indicators
    private func resetColors() {
        level0Label?.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            level0Label?.textColor = .secondaryLabel
        } else {
            level0Label?.textColor = .black
        }

        level1Label?.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            level1Label?.textColor = .secondaryLabel
        } else {
            level1Label?.textColor = .black
        }
        
        level2Label?.backgroundColor = .none
        if #available(iOS 13.0, *) {
            level2Label?.textColor = .secondaryLabel
        } else {
            level2Label?.textColor = .black
        }
        
        level3Label?.backgroundColor = .none
        if #available(iOS 13.0, *) {
            level3Label?.textColor = .secondaryLabel
        } else {
            level3Label?.textColor = .black
        }
        
        level4Label?.backgroundColor = .none
        if #available(iOS 13.0, *) {
            level4Label?.textColor = .secondaryLabel
        } else {
            level4Label?.textColor = .black
        }
        
        level5Label?.backgroundColor = .none
        if #available(iOS 13.0, *) {
            level5Label?.textColor = .secondaryLabel
        } else {
            level5Label?.textColor = .black
        }
        
        level6Label?.backgroundColor = .none
        if #available(iOS 13.0, *) {
            level6Label?.textColor = .secondaryLabel
        } else {
            level6Label?.textColor = .black
        }
    }
    
    /// Setup function for using either a button or a doubleTap
    private func setButtonOrDoubletap(_ useButton:Bool?) {
        guard let validUseButton = useButton else { return }
        toggleViewModeButton?.isHidden = !validUseButton
        if !validUseButton {
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DietLevelsTableViewCell.buttonTapped))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
            doubleTapGestureRecognizer.cancelsTouchesInView = false
            self.addGestureRecognizer(doubleTapGestureRecognizer)
        }
    }
    
    /// Function that invokes the protocol when the button is tapped or when doubleTap is enabled.
    @objc func buttonTapped() {
        delegate?.dietLevelsTableViewCell(self, receivedTapOn: buttonNotDoubleTap ? toggleViewModeButton : nil)
    }

}
