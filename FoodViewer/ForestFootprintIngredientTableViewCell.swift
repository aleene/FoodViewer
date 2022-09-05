//
//  ForestFootprintIngredientTableViewCell.swift
//  
//
//  Created by arnaud on 30/11/2020.
//

import UIKit

class ForestFootprintIngredientTableViewCell: UITableViewCell {

// MARK: - Storyboad ingredient specific line
    
    @IBOutlet weak var ingredientLabel: UILabel!

    @IBOutlet weak var percentInProductLabel: UILabel!
    
    /// Processing factor (% of food after processing)
    @IBOutlet weak var processingFactorLabel: UILabel!
    
    /// Forest footprint (m² per kg of food)
    @IBOutlet weak var forestFootprintLabel: UILabel!
    
// MARK: - Soy base line
    
    @IBOutlet weak var typeLabel: UILabel!
    
    /// Soy feed factor (kg of soy per kg of food)
    @IBOutlet weak var soyFeedFactorLabel: UILabel!
    
    /// Soy yield (kg of soy per m²)
    @IBOutlet weak var soyYieldLabel: UILabel!
    
    /// Deforestation risk (%)
    @IBOutlet weak var deforestationRiskLabel: UILabel!
    
    
    func setup(ingredient: ForestFootprintIngredient) {
        ingredientLabel?.text = ingredient.tagID
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumSignificantDigits = 1
        if let validValue = ingredient.percent {
            percentInProductLabel?.text = numberFormatter.string(from: NSNumber(value: validValue))
        }
        if let validValue = ingredient.processingFactor {
            processingFactorLabel?.text = numberFormatter.string(from: NSNumber(value: validValue))
        } else {
            processingFactorLabel?.text = "No valid processing factor"
        }
                                                             
        if let validValue = ingredient.footprintPerKg {
            forestFootprintLabel?.text = numberFormatter.string(from: NSNumber(value: validValue))
        }
        
        typeLabel?.text = ingredient.type?.name
        soyFeedFactorLabel?.text = ingredient.type?.soyFeedFactor
        soyYieldLabel?.text = ingredient.type?.soyYield
        deforestationRiskLabel?.text = ingredient.type?.deforestationRisk
    }
}
