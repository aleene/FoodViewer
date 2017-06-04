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
            if let score = product?.nutritionScore {
                for (item, level) in score {
                    switch item {
                    case .fat:
                        fatLabel.backgroundColor = colorForLevel(level)
                    case .saturatedFat:
                        saturatedFatLabel.backgroundColor = colorForLevel(level)
                    case .sugar:
                        sugarLabel.backgroundColor = colorForLevel(level)
                    case .salt:
                        saltLabel.backgroundColor = colorForLevel(level)
                    case .undefined:
                        fatLabel.backgroundColor = UIColor.white
                        saturatedFatLabel.backgroundColor = UIColor.white
                        sugarLabel.backgroundColor = UIColor.white
                        saltLabel.backgroundColor = UIColor.white
                    }
                }
            }
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
        }
    }
    
    @IBOutlet weak var fatLabel: UILabel! {
        didSet {
            fatLabel.isHidden = regionHasNutritionalScoreLogo()
        }
    }
    @IBOutlet weak var saturatedFatLabel: UILabel! {
        didSet {
            saturatedFatLabel.isHidden = regionHasNutritionalScoreLogo()
        }
    }

    @IBOutlet weak var sugarLabel: UILabel! {
        didSet {
            sugarLabel.isHidden = regionHasNutritionalScoreLogo()
        }
    }

    @IBOutlet weak var saltLabel: UILabel! {
        didSet {
            saltLabel.isHidden = regionHasNutritionalScoreLogo()
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
        let inFrance = Locale.current.regionCode?.contains("FR")
        return inFrance ?? false
    }

}
