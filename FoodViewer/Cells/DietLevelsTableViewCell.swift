//
//  DietLevelsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 22/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

protocol DietLevelsTableViewCellDelegate: class {
    
    func dietLevelsTableViewCell(_ sender: DietLevelsTableViewCell, receivedDoubleTapOn cell:DietLevelsTableViewCell)

    //func dietLevelsTableViewCell(_ sender: DietLevelsTableViewCell, receivedTapOn button:UIButton)

}

class DietLevelsTableViewCell: UITableViewCell {
    
    private struct Constant {
        static let Divisor = 2.5
        static let Height = CGFloat(25.0)
    }
    @IBOutlet weak var level0Label: UILabel! {
        didSet {
            level0Label?.layer.cornerRadius = CGFloat(level0Label?.bounds.size.height ?? Constant.Height) / CGFloat(Constant.Divisor)
            level0Label?.clipsToBounds = true
            //level0Label?.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.4).cgColor
            //level0Label?.layer.borderWidth = CGFloat(1.0)
            if #available(iOS 13.0, *) {
                level0Label?.textColor = .secondaryLabel
            } else {
                level0Label?.textColor = .black
            }

        }
    }
    
    @IBOutlet weak var level1Label: UILabel! {
        didSet {
            level1Label?.layer.cornerRadius = CGFloat(level1Label?.bounds.size.height ?? Constant.Height) / CGFloat(Constant.Divisor)
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
            level2Label?.layer.cornerRadius = CGFloat(level2Label?.bounds.size.height ?? Constant.Height) / CGFloat(Constant.Divisor)
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
            level3Label?.layer.cornerRadius = CGFloat(level3Label?.bounds.size.height ?? Constant.Height) / CGFloat(Constant.Divisor)
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
            level4Label?.layer.cornerRadius = CGFloat(level4Label?.bounds.size.height ?? Constant.Height) / CGFloat(Constant.Divisor)
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
            level5Label?.layer.cornerRadius = CGFloat(level5Label?.bounds.size.height ?? Constant.Height) / CGFloat(Constant.Divisor)
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
            level6Label?.layer.cornerRadius = CGFloat(level6Label?.bounds.size.height ?? Constant.Height) / CGFloat(Constant.Divisor)
            level6Label?.clipsToBounds = true
            //level6Label?.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.4).cgColor
            //level6Label?.layer.borderWidth = CGFloat(1.0)
            if #available(iOS 13.0, *) {
                level6Label?.textColor = .secondaryLabel
            } else {
                level6Label?.textColor = .black
            }

        }
    }
    
    @IBAction func toggleViewModeButtonTapped(_ sender: UIButton) {
        cellTapped()
    }
    
    var values: [Int] = []
    
    var conclusion: Int? = nil {
        didSet {
            setup()
        }
    }

    var delegate: DietLevelsTableViewCellDelegate? = nil

    var buttonNotDoubleTap: Bool = true {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
    }

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
    
    private func setButtonOrDoubletap(_ useButton:Bool?) {
        guard let validUseButton = useButton else { return }
        toggleViewModeButton?.isHidden = !validUseButton
        if !validUseButton {
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DietLevelsTableViewCell.cellTapped))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            doubleTapGestureRecognizer.delaysTouchesBegan = true      //Important to add
            doubleTapGestureRecognizer.cancelsTouchesInView = false
            self.addGestureRecognizer(doubleTapGestureRecognizer)
        }
    }
    
    @objc func cellTapped() {
        delegate?.dietLevelsTableViewCell(self, receivedDoubleTapOn: self)
    }

}
