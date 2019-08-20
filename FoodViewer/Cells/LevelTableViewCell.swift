//
//  LevelTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 30/07/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class LevelTableViewCell: UITableViewCell {

    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var leftLeftLabel: UILabel! {
        didSet {
            leftLeftLabel?.text = "0.0"
        }
    }

    @IBOutlet weak var leftLabel: UILabel! {
        didSet {
            leftLabel?.backgroundColor = .green
        }
    }

    @IBOutlet weak var leftToMiddleLabel: UILabel!
    
    @IBOutlet weak var middleLabel: UILabel! {
        didSet {
            middleLabel?.backgroundColor = .orange
        }
    }

    @IBOutlet weak var middleToRightLabel: UILabel!

    @IBOutlet weak var rightLabel: UILabel! {
        didSet {
            rightLabel?.backgroundColor = .red
        }
    }

    //
    // MARK: public variables
    //
    
    var nutritionLevel: (NutritionItem, NutritionLevelQuantity)? = nil {
        didSet {
            setLevels()
        }
    }

    private func colorForLevel(_ level: NutritionLevelQuantity) {
        switch level {
        case .low:
            leftLabel?.backgroundColor = .green
            middleLabel?.backgroundColor = .init(red: 1.0, green: 165/255, blue: 0.0, alpha: 0.2)
            rightLabel?.backgroundColor = .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        case .moderate:
            leftLabel?.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
            middleLabel?.backgroundColor = .orange
            rightLabel?.backgroundColor = .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        case.high:
            leftLabel?.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
            middleLabel?.backgroundColor = .init(red: 1.0, green: 165/255, blue: 0.0, alpha: 0.2)
            rightLabel?.backgroundColor = .red
        default:
            break
        }
    }
    
    // Taken from:
    // https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/566251/FoP_Nutrition_labelling_UK_guidance.pdf
    
    private struct FSALevel {
        static let Zero: Double = 0.0
        struct GreenToOrange {
            static let Fat = 3.0
            static let SaturatedFat = 1.5
            static let Sugar = 5.0
            static let Salt = 0.3
        }
        struct OrangeToRed {
            static let Fat = 17.5
            static let SaturatedFat = 5.0
            static let Sugar = 22.5
            static let Salt = 1.5
        }
    }

    private func setLevels() {
        guard let validLevel = nutritionLevel else { return }
        guard self.levelLabel != nil else { return }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumSignificantDigits = 2

        switch validLevel.0 {
        case .fat:
            setLabels(with: fatValue, between: FSALevel.GreenToOrange.Fat, and: FSALevel.OrangeToRed.Fat)
            self.levelLabel?.text = TranslatableStrings.FatLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.Fat))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.Fat))
            colorForLevel(validLevel.1)
            
        case .saturatedFat:
            setLabels(with: saturatedFatValue, between: FSALevel.GreenToOrange.SaturatedFat, and: FSALevel.OrangeToRed.SaturatedFat)
            self.levelLabel?.text = TranslatableStrings.SaturatedFatLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.SaturatedFat))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.SaturatedFat))
          colorForLevel(validLevel.1)
            
        case .sugar:
            setLabels(with: sugarValue, between: FSALevel.GreenToOrange.Sugar, and: FSALevel.OrangeToRed.Sugar)
            self.levelLabel.text = TranslatableStrings.SugarLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.Sugar))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.Sugar))
           colorForLevel(validLevel.1)
            
        case .salt:
            setLabels(with: saltValue, between: FSALevel.GreenToOrange.Salt, and: FSALevel.OrangeToRed.Salt)
            self.levelLabel?.text = TranslatableStrings.SaltLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.Salt))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.Salt))
            colorForLevel(validLevel.1)
            
        default:
            break
        }
    }
    
    private func setLabels(with value:Double?, between low:Double, and high:Double) {
        if let validValue = value {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumSignificantDigits = 2
            let str = numberFormatter.string(from: NSNumber(floatLiteral: Double(validValue)))
            if validValue <= low {
                self.leftLabel?.text = str
                self.middleLabel?.text = nil
                self.rightLabel?.text = nil
            } else if validValue > high {
                self.leftLabel?.text = nil
                self.middleLabel?.text = nil
                self.rightLabel?.text = str
            } else {
                self.leftLabel?.text = nil
                self.middleLabel?.text = str
                self.rightLabel?.text = nil
            }
        }

    }
    
    var saltValue: Double? = nil {
        didSet {
            setLevels()
        }
    }
    
    var sugarValue: Double? = nil {
        didSet {
            setLevels()
        }
    }
    
    var fatValue: Double? = nil {
        didSet {
            setLevels()
        }
    }
    
    var saturatedFatValue: Double? = nil {
        didSet {
            setLevels()
        }
    }

}
