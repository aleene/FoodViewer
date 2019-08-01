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

    @IBOutlet weak var leftView: UIView! {
        didSet {
            leftView?.backgroundColor = .green
        }
    }

    @IBOutlet weak var leftToMiddleLabel: UILabel!
    
    @IBOutlet weak var middleView: UIView! {
        didSet {
            middleView?.backgroundColor = .orange
        }
    }

    @IBOutlet weak var middleToRightLabel: UILabel!

    @IBOutlet weak var rightView: UIView! {
        didSet {
            rightView?.backgroundColor = .red
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
            leftView?.backgroundColor = .green
            middleView?.backgroundColor = .init(red: 1.0, green: 165/255, blue: 0.0, alpha: 0.2)
            rightView?.backgroundColor = .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        case .moderate:
            leftView?.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
            middleView?.backgroundColor = .orange
            rightView?.backgroundColor = .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        case.high:
            leftView?.backgroundColor = .init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
            middleView?.backgroundColor = .init(red: 1.0, green: 165/255, blue: 0.0, alpha: 0.2)
            rightView?.backgroundColor = .red
        default:
            break
        }
    }
    
    // Taken from:
    // https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/566251/FoP_Nutrition_labelling_UK_guidance.pdf
    
    private struct FSALevel {
        static let Zero = 0.0
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
        numberFormatter.maximumSignificantDigits = 1

        switch validLevel.0 {
        case .fat:

            self.levelLabel?.text = TranslatableStrings.FatLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.Fat))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.Fat))
            colorForLevel(validLevel.1)
            
        case .saturatedFat:
            self.levelLabel?.text = TranslatableStrings.SaturatedFatLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.SaturatedFat))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.SaturatedFat))
          colorForLevel(validLevel.1)
            
        case .sugar:
            self.levelLabel.text = TranslatableStrings.SugarLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.Sugar))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.Sugar))
           colorForLevel(validLevel.1)
            
        case .salt:
            self.levelLabel?.text = TranslatableStrings.SaltLevel
            self.leftLeftLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.Zero))
            self.leftToMiddleLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.GreenToOrange.Salt))
            self.middleToRightLabel?.text = numberFormatter.string(from: NSNumber(floatLiteral: FSALevel.OrangeToRed.Salt))
            colorForLevel(validLevel.1)
            
        default:
            break
        }
    }

}
