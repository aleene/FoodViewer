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
 
            if let score = product?.nutritionGrade {
                switch  score {
                case .a:
                    self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .green
                    nutriScoreView.currentScore = NutriScoreView.Score.A
                case .b:
                    self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .yellow
                    nutriScoreView.currentScore = NutriScoreView.Score.B
                case .c:
                    self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .orange
                    nutriScoreView.currentScore = NutriScoreView.Score.C
                case .d:
                    self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .magenta
                    nutriScoreView.currentScore = NutriScoreView.Score.D
                case .e:
                    self.backgroundColor = regionHasNutritionalScoreLogo() ? .white : .red
                    nutriScoreView.currentScore = NutriScoreView.Score.E
                default:
                    self.backgroundColor = nil
                    nutriScoreView.currentScore = nil
                }
            }
            
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
            if let nutritionLevels = product?.nutritionScore {
                for level in nutritionLevels {
                    switch level.0 {
                    case .fat:
                        switch level.1 {
                        case .low:
                            self.fatLevelLabel?.backgroundColor = .green
                        case .moderate:
                            self.fatLevelLabel?.backgroundColor = .orange
                        case .high:
                            self.fatLevelLabel?.backgroundColor = .red
                        default:
                            break
                        }
                    case .saturatedFat:
                        switch level.1 {
                        case .low:
                            self.saturatedFatLevelLabel?.backgroundColor = .green
                        case .moderate:
                            self.saturatedFatLevelLabel?.backgroundColor = .orange
                        case .high:
                            self.saturatedFatLevelLabel?.backgroundColor = .red
                        default:
                            break
                        }
                    case .sugar:
                        switch level.1 {
                        case .low:
                            self.sugarLevelLabel?.backgroundColor = .green
                        case .moderate:
                            self.sugarLevelLabel?.backgroundColor = .orange
                        case .high:
                            self.sugarLevelLabel?.backgroundColor = .red
                        default:
                            break
                        }
                    case .salt:
                        switch level.1 {
                        case .low:
                            self.saltLevelLabel?.backgroundColor = .green
                        case .moderate:
                            self.saltLevelLabel?.backgroundColor = .orange
                        case .high:
                            self.saltLevelLabel?.backgroundColor = .red
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var novaTitleLabel: UILabel! {
        didSet {
            novaTitleLabel.text = "nova"
        }
    }
    
    @IBOutlet weak var novaValueLabel: UILabel! {
        didSet {
            novaValueLabel.text = "?"
        }
    }
    
    @IBOutlet weak var fatLevelLabel: UILabel! {
        didSet {
            fatLevelLabel.text = TranslatableStrings.FatLevel
        }
    }
    
    @IBOutlet weak var saturatedFatLevelLabel: UILabel! {
        didSet {
            saturatedFatLevelLabel.text = TranslatableStrings.SaturatedFatLevel
        }
    }

    @IBOutlet weak var sugarLevelLabel: UILabel! {
        didSet {
            sugarLevelLabel.text = TranslatableStrings.SugarLevel
        }
    }

    @IBOutlet weak var saltLevelLabel: UILabel! {
        didSet {
            saltLevelLabel.text = TranslatableStrings.SaltLevel
        }
    }

    @IBOutlet weak var nutriScoreView: NutriScoreView! {
        didSet {
            nutriScoreView.isHidden = !regionHasNutritionalScoreLogo()
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
    
    func regionHasNutritionalScoreLogo() -> Bool {
        /* let inFrance = Locale.current.regionCode?.contains("FR")
         return inFrance ?? false */
        return true
    }

}
