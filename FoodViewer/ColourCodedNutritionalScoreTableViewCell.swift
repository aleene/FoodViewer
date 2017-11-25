//
//  ColourCodedNutritionalScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 15/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ColourCodedNutritionalScoreTableViewCell: UITableViewCell {
    
    var score: Int? = nil {
        didSet {
            resetLabels()
            if let validScore = score {
                if validScore < 0 {
                    firstMiddleLabel.text = "\(validScore)"
                } else if validScore < 3 {
                    secondMiddleLabel.text = "\(validScore)"
                } else if validScore < 11 {
                    thirdMiddleLabel.text = "\(validScore)"
                } else if validScore < 19 {
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
    
    // Green labels
    @IBOutlet weak var firstLeftLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForA))
            firstLeftLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }
    @IBOutlet weak var firstMiddleLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForA))
            firstMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var firstRightLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForA))
            firstRightLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Yellow labels
    @IBOutlet weak var secondLeftLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForB))
            secondLeftLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var secondMiddleLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForB))
            secondMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var secondRightLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForB))
            secondRightLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Orange Labels
    @IBOutlet weak var thirdLeftLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForC))
            thirdLeftLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var thirdMiddleLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForC))
            thirdMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var thirdRightLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForC))
            thirdRightLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Pink labels
    @IBOutlet weak var fourthLeftLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForD))
            fourthLeftLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fourthMiddleLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForD))
            fourthMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fourthRightLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForD))
            fourthRightLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    
    // Red labels
    @IBOutlet weak var fifthLeftLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForE))
            fifthLeftLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fifthMiddleLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForE))
            fifthMiddleLabel.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    @IBOutlet weak var fifthRightLabel: UILabel! {
        didSet {
            // Long press allows to start a search
            let longPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(ColourCodedNutritionalScoreTableViewCell.handleLongPressForE))
            fifthRightLabel.addGestureRecognizer(longPressGestureRecognizer)
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
