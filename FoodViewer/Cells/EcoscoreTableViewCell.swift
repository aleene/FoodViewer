//
//  EcoscoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 11/12/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class EcoscoreTableViewCell: UITableViewCell {

// MARK: - constants
    
    fileprivate struct Constant {
        struct Ecoscore {
            static let DarkGreenMin = 100.0
            static let DarkToLightGreen = 80.0
            static let LightGreenToYellow = 60.0
            static let YellowToOrange = 40.0
            static let OrangeToRed = 20.0
            static let RedMax = 0.0
        }
    }

    @IBOutlet weak var gradeALabel: UILabel! {
        didSet {
            gradeALabel?.text = "A"
        }
    }
    
    @IBOutlet weak var gradeBLabel: UILabel! {
           didSet {
               gradeBLabel?.text = "B"
           }
       }
    
    @IBOutlet weak var gradeCLabel: UILabel! {
           didSet {
               gradeCLabel?.text = "C"
           }
       }
    
    @IBOutlet weak var gradeDLabel: UILabel! {
           didSet {
               gradeDLabel?.text = "D"
           }
       }
    
    @IBOutlet weak var gradeELabel: UILabel! {
           didSet {
               gradeELabel?.text = "E"
           }
       }
    
    @IBOutlet weak var ecoscore100Label: UILabel! {
        didSet {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumSignificantDigits = 3
        ecoscore100Label?.text = numberFormatter.string(from: NSNumber(value:Constant.Ecoscore.DarkGreenMin))
        }
    }
    
    @IBOutlet weak var ecoscore80Label: UILabel! {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 3
            ecoscore80Label?.text = numberFormatter.string(from: NSNumber(value: Constant.Ecoscore.DarkToLightGreen))
        }
    }
    @IBOutlet weak var ecoscore60Label: UILabel! {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 3
            ecoscore60Label?.text = numberFormatter.string(from: NSNumber(value: Constant.Ecoscore.LightGreenToYellow))
        }
    }
    
    @IBOutlet weak var ecoscore40Label: UILabel! {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 3
            ecoscore40Label?.text = numberFormatter.string(from: NSNumber(value: Constant.Ecoscore.YellowToOrange))
        }
    }
    
    @IBOutlet weak var ecoscore20Label: UILabel! {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 3
            ecoscore20Label?.text = numberFormatter.string(from: NSNumber(value: Constant.Ecoscore.OrangeToRed))
        }
    }
    
    @IBOutlet weak var ecoscore0Label: UILabel! {
        didSet {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 3
            ecoscore0Label?.text = numberFormatter.string(from: NSNumber(value: Constant.Ecoscore.RedMax))
        }
    }
    
// MARK: - public variables
    
    // the ecoscore (0 - 100)
    public var ecoscore: Double? = nil {
        didSet {
            if let validScore = ecoscore {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumSignificantDigits = 2
                // note that the scale is reversed
                if validScore < Constant.Ecoscore.OrangeToRed {
                    gradeALabel.text = "A"
                    gradeBLabel.text = "B"
                    gradeCLabel.text = "C"
                    gradeDLabel.text = "D"
                    gradeELabel.text = numberFormatter.string(from: NSNumber(value: validScore))
                } else if validScore < Constant.Ecoscore.YellowToOrange {
                    gradeALabel.text = "A"
                    gradeBLabel.text = "B"
                    gradeCLabel.text = "C"
                    gradeDLabel.text = numberFormatter.string(from: NSNumber(value: validScore))
                    gradeELabel.text = "E"
                } else if validScore < Constant.Ecoscore.LightGreenToYellow {
                    gradeALabel.text = "A"
                    gradeBLabel.text = "B"
                    gradeCLabel.text = numberFormatter.string(from: NSNumber(value: validScore))
                    gradeDLabel.text = "D"
                    gradeELabel.text = "E"
                } else if validScore < Constant.Ecoscore.DarkToLightGreen {
                    gradeALabel.text = "A"
                    gradeBLabel.text = numberFormatter.string(from: NSNumber(value: validScore))
                    gradeCLabel.text = "C"
                    gradeDLabel.text = "D"
                    gradeELabel.text = "E"
                } else {
                    gradeALabel.text = numberFormatter.string(from: NSNumber(value: validScore))
                    gradeBLabel.text = "B"
                    gradeCLabel.text = "C"
                    gradeDLabel.text = "D"
                    gradeELabel.text = "E"
                }
            }
        }
    }
        
// MARK: - private functions
    
    fileprivate func resetLabels() {
        gradeALabel.text = ""
        gradeBLabel.text = ""
        gradeCLabel.text = ""
        gradeDLabel.text = ""
        gradeELabel.text = ""
    }

}
