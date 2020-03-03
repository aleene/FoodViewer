//
//  ColourCodedNutritionalScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 15/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ColourCodedNutritionalScoreTableViewCell: UITableViewCell {
    
    fileprivate struct Constant {
        struct NutriScore {
            static let GreenMin = -15
            static let GreenMax = -1
            static let YellowMin = 0
            static let YellowMax = 2
            static let OrangeMin = 3
            static let OrangeMax = 10
            static let PurpleMin = 11
            static let PurpleMax = 18
            static let RedMin = 19
            static let RedMax = 40
        }
    }

    var score: Int? = nil {
        didSet {
            resetLabels()
            if let validScore = score {
                if validScore < Constant.NutriScore.YellowMin {
                    firstMiddleLabel.text = "\(validScore)"
                } else if validScore < Constant.NutriScore.OrangeMin {
                    secondMiddleLabel.text = "\(validScore)"
                } else if validScore < Constant.NutriScore.PurpleMin {
                    thirdMiddleLabel.text = "\(validScore)"
                } else if validScore < Constant.NutriScore.RedMin {
                    fourthMiddleLabel.text = "\(validScore)"
                } else {
                    fifthMiddleLabel.text = "\(validScore)"
                }
            }
        }
    }
    
    var delegate: ProductPageViewController? = nil
    
    fileprivate func resetLabels() {
        firstMiddleLabel.text = ""
        secondMiddleLabel.text = ""
        thirdMiddleLabel.text = ""
        fourthMiddleLabel.text = ""
        fifthMiddleLabel.text = ""
    }
    
    // Dark Green labels
    @IBOutlet weak var firstLeftLabel: UILabel! {
        didSet {
            firstLeftLabel.backgroundColor = UIColor.nutriScoreColor(for: .first)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 2
            firstLeftLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.GreenMin))
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForA))
            firstLeftLabel?.addGestureRecognizer(longPressGestureRecognizer)
        }
    }
    @IBOutlet weak var firstMiddleLabel: UILabel! {
        didSet {
            firstMiddleLabel.backgroundColor = .clear
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForA))
            firstMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var firstRightLabel: UILabel! {
        didSet {
            firstRightLabel.backgroundColor = .clear
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 1
            firstRightLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.GreenMax))
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForA))
            firstRightLabel?.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Yellow labels
    @IBOutlet weak var secondLeftLabel: UILabel! {
        didSet {
            secondLeftLabel.backgroundColor = UIColor.nutriScoreColor(for: .second)

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 1
            secondLeftLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.YellowMin))
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForB))
            secondLeftLabel?.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var secondMiddleLabel: UILabel! {
        didSet {
            secondMiddleLabel.backgroundColor = .clear

            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForB))
            secondMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var secondRightLabel: UILabel! {
        didSet {
            secondRightLabel.backgroundColor = .clear

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 1
            secondRightLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.YellowMax))
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForB))
            secondRightLabel?.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Orange Labels
    @IBOutlet weak var thirdLeftLabel: UILabel! {
        didSet {
            thirdLeftLabel.backgroundColor = UIColor.nutriScoreColor(for: .third)

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 1
            thirdLeftLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.OrangeMin))

            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForC))
            thirdLeftLabel?.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var thirdMiddleLabel: UILabel! {
        didSet {
            thirdMiddleLabel.backgroundColor = .clear

            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForC))
            thirdMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var thirdRightLabel: UILabel! {
        didSet {
            thirdRightLabel.backgroundColor = .clear
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 2
            thirdRightLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.OrangeMax))

            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForC))
            thirdRightLabel?.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Pink labels
    @IBOutlet weak var fourthLeftLabel: UILabel! {
        didSet {
            fourthLeftLabel.backgroundColor = UIColor.nutriScoreColor(for: .fourth)

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 2
            fourthLeftLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.PurpleMin))

            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForD))
            fourthLeftLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fourthMiddleLabel: UILabel! {
        didSet {
            fourthMiddleLabel.backgroundColor = .clear

            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForD))
            fourthMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fourthRightLabel: UILabel! {
        didSet {
            fourthRightLabel.backgroundColor = .clear

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 2
            fourthRightLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.PurpleMax))
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForD))
            fourthRightLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Red labels
    @IBOutlet weak var fifthLeftLabel: UILabel! {
        didSet {
            fifthLeftLabel.backgroundColor = UIColor.nutriScoreColor(for: .fifth)

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 2
            fifthLeftLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.RedMin))
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForE))
            fifthLeftLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fifthMiddleLabel: UILabel! {
        didSet {
            fifthMiddleLabel.backgroundColor = .clear
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForE))
            fifthMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fifthRightLabel: UILabel! {
        didSet {
            fifthRightLabel.backgroundColor = .clear
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 2
            fifthRightLabel?.text = numberFormatter.string(from:NSNumber(value: Constant.NutriScore.RedMax))
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForE))
            fifthRightLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }
    
    func willDisappear() {
        let allLabels: [UILabel] =
            [firstLeftLabel, firstMiddleLabel, firstRightLabel,
             secondLeftLabel, secondMiddleLabel, secondRightLabel,
             thirdLeftLabel, thirdMiddleLabel, thirdRightLabel,
             fourthLeftLabel, fourthMiddleLabel, fourthRightLabel,
             fifthLeftLabel, fifthMiddleLabel, fifthRightLabel]
        for label in allLabels {
            if let validGestureRecognizers = label.gestureRecognizers {
                for gesture in validGestureRecognizers {
                    if gesture is UILongPressGestureRecognizer {
                        label.removeGestureRecognizer(gesture)
                    }
                }
            }
        }
    }

    
    @objc func handleLongPressForA() {
        delegate?.search(for: NutritionalScoreLevel.a.rawValue, in: .nutritionGrade)
    }
    @objc func handleLongPressForB() {
        delegate?.search(for: NutritionalScoreLevel.b.rawValue, in: .nutritionGrade)
    }
    @objc func handleLongPressForC() {
        delegate?.search(for: NutritionalScoreLevel.c.rawValue, in: .nutritionGrade)
    }
    @objc func handleLongPressForD() {
        delegate?.search(for: NutritionalScoreLevel.d.rawValue, in: .nutritionGrade)
    }
    @objc func handleLongPressForE() {
        delegate?.search(for: NutritionalScoreLevel.e.rawValue, in: .nutritionGrade)
    }


}
