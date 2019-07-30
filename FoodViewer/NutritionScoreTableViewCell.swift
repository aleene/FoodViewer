//
//  NutritionScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutritionScoreTableViewCell: UITableViewCell {

    var product: FoodProduct? = nil {
        didSet {
            self.backgroundColor = .white
            setup()
        }
    }
    
    @IBOutlet weak var novaTitleLabel: UILabel! {
        didSet {
            novaTitleLabel.text = "nova"
            setup()
        }
    }
    
    @IBOutlet weak var novaValueLabel: UILabel! {
        didSet {
            novaValueLabel.text = "?"
            setup()
        }
    }
    
    @IBOutlet weak var fatLevelLabel: UILabel! {
        didSet {
            fatLevelLabel.text = TranslatableStrings.FatLevel
            setup()
        }
    }
    
    @IBOutlet weak var saturatedFatLevelLabel: UILabel! {
        didSet {
            saturatedFatLevelLabel.text = TranslatableStrings.SaturatedFatLevel
            setup()
        }
    }

    @IBOutlet weak var sugarLevelLabel: UILabel! {
        didSet {
            sugarLevelLabel.text = TranslatableStrings.SugarLevel
            setup()
        }
    }

    @IBOutlet weak var saltLevelLabel: UILabel! {
        didSet {
            saltLevelLabel.text = TranslatableStrings.SaltLevel
            setup()
        }
    }

    @IBOutlet weak var nutriScoreView: NutriScoreView! {
        didSet {
            nutriScoreView.isHidden = !regionHasNutritionalScoreLogo()
            setup()
        }
    }
    
    private func colorForLevel(_ level: NutritionLevelQuantity) -> UIColor {
        switch level {
        case .low:
            return UIColor.green
        case .moderate:
            return UIColor.orange
        case.high:
            return UIColor.red
        default:
            return UIColor.white
        }
    }
    
    private func regionHasNutritionalScoreLogo() -> Bool {
        /* let inFrance = Locale.current.regionCode?.contains("FR")
         return inFrance ?? false */
        return true
    }
    
    private func setup() {
        guard product != nil else { return }
        guard nutriScoreView != nil else { return }
        //guard fatLevelLabel != nil else { return }
        //guard saturatedFatLevelLabel != nil else { return }
        //guard sugarLevelLabel != nil else { return }
        //guard saltLevelLabel != nil else { return }
        
        setScore()
        setNova()
        setLevels()
    }
    
    private func setScore() {
        guard product != nil else { return }
        guard nutriScoreView != nil else { return }
        guard novaValueLabel != nil else { return }

        if let score = product?.nutritionGrade {
            switch  score {
            case .a:
                self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .green
                nutriScoreView?.currentScore = NutriScoreView.Score.A
            case .b:
                self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .yellow
                nutriScoreView?.currentScore = NutriScoreView.Score.B
            case .c:
                self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .orange
                nutriScoreView?.currentScore = NutriScoreView.Score.C
            case .d:
                self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .magenta
                nutriScoreView?.currentScore = NutriScoreView.Score.D
            case .e:
                self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .red
                nutriScoreView?.currentScore = NutriScoreView.Score.E
            default:
                self.backgroundColor = nil
                nutriScoreView?.currentScore = nil
            }
        }
    }
    
    private func setNova() {
        guard product != nil else { return }
        guard novaValueLabel != nil else { return }
        
        if let nova = product?.novaGroup {
            switch nova {
            case "1":
                novaValueLabel?.text = nova
                novaValueLabel?.textColor = .white
                novaValueLabel?.backgroundColor = .green
            case "2":
                novaValueLabel?.text = nova
                novaValueLabel?.textColor = .white
                novaValueLabel?.backgroundColor = .yellow
            case "3":
                novaValueLabel?.text = nova
                novaValueLabel?.textColor = .white
                novaValueLabel?.backgroundColor = .orange
            case "4":
                novaValueLabel?.text = nova
                novaValueLabel?.textColor = .white
                novaValueLabel?.backgroundColor = .red
            default:
                novaValueLabel?.text = "?"
                novaValueLabel?.textColor = .black
                novaValueLabel?.backgroundColor = .white
            }
        }
    }

    private func setLevels() {
        guard product != nil else { return }
        guard fatLevelLabel != nil else { return }
        guard saturatedFatLevelLabel != nil else { return }
        guard sugarLevelLabel != nil else { return }
        guard saltLevelLabel != nil else { return }

        if let nutritionLevels = product?.nutritionScore {
            for level in nutritionLevels {
                switch level.0 {
                case .fat:
                    self.fatLevelLabel?.backgroundColor = colorForLevel(level.1)
                case .saturatedFat:
                    self.saturatedFatLevelLabel?.backgroundColor = colorForLevel(level.1)
                case .sugar:
                    self.sugarLevelLabel?.backgroundColor = colorForLevel(level.1)
                case .salt:
                    self.saltLevelLabel?.backgroundColor = colorForLevel(level.1)
                default:
                    break
                }
            }
        }
    }
    
}
