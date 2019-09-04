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

    @IBAction func toggleViewModeButtonTapped(_ sender: UIButton) {
        cellTapped()
    }
    
    var one: String? = nil {
        didSet {
            setup()
        }
    }

    var two: String? = nil {
        didSet {
            setup()
        }
    }

    var three: String? = nil {
        didSet {
            setup()
        }
    }

    var four: String? = nil {
        didSet {
            setup()
        }
    }

    var five: String? = nil {
        didSet {
            setup()
        }
    }
    
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
        
        level1Label?.text = one
        level2Label?.text = two
        level3Label?.text = three
        level4Label?.text = four
        level5Label?.text = five
        resetColors()
        
        if let validConclusion = conclusion {
            switch validConclusion {
            case 0:
                level1Label?.backgroundColor = .red
            case 1:
                level2Label?.backgroundColor = .orange
            case 2:
                level3Label?.backgroundColor = .yellow
            case 3:
                level4Label?.backgroundColor = .green
            case 4:
                level5Label?.backgroundColor = .blue
            default: break
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
