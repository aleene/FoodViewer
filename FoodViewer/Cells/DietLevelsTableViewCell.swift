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
    
    @IBOutlet weak var level0Label: UILabel! {
        didSet {
            level0Label?.layer.cornerRadius = CGFloat(level0Label?.bounds.size.height ?? 25) / CGFloat(2.0)
            level0Label?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var level1Label: UILabel! {
        didSet {
            level1Label?.layer.cornerRadius = CGFloat(level1Label?.bounds.size.height ?? 25) / CGFloat(2.0)
            level1Label?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var level2Label: UILabel! {
        didSet {
            level2Label?.layer.cornerRadius = CGFloat(level2Label?.bounds.size.height ?? 25) / CGFloat(2.0)
            level2Label?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var level3Label: UILabel! {
        didSet {
            level3Label?.layer.cornerRadius = CGFloat(level3Label?.bounds.size.height ?? 25) / CGFloat(2.0)
            level3Label?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var level4Label: UILabel! {
        didSet {
            level4Label?.layer.cornerRadius = CGFloat(level4Label?.bounds.size.height ?? 25) / CGFloat(2.0)
            level4Label?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var level5Label: UILabel! {
        didSet {
            level5Label?.layer.cornerRadius = CGFloat(level5Label?.bounds.size.height ?? 25) / CGFloat(2.0)
            level5Label?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var toggleViewModeButton: UIButton! {
        didSet {
            setButtonOrDoubletap(buttonNotDoubleTap)
        }
    }

    @IBOutlet weak var level6Label: UILabel! {
        didSet {
            level6Label?.layer.cornerRadius = CGFloat(level6Label?.bounds.size.height ?? 25) / CGFloat(2.0)
            level6Label?.clipsToBounds = true
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
                level0Label?.backgroundColor = .purple
            case -2:
                level1Label?.backgroundColor = .red
            case -1:
                level2Label?.backgroundColor = .orange
            case 0:
                level3Label?.backgroundColor = .yellow
            case 1:
                level4Label?.backgroundColor = .green
            case 2:
                level5Label?.backgroundColor = .blue
            case 3:
                level6Label?.backgroundColor = .black
            default:
                break
            }
        }

    }
    
    private func resetColors() {
        level1Label?.backgroundColor = .none
        level2Label?.backgroundColor = .none
        level3Label?.backgroundColor = .none
        level4Label?.backgroundColor = .none
        level5Label?.backgroundColor = .none
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
