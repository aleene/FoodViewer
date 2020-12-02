//
//  ForestFootprintIngredientHeaderTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/12/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class ForestFootprintIngredientHeaderTableViewCell: UITableViewCell {

// MARK: - Storyboad ingredient specific line
    
    @IBOutlet weak var ingredientLabel: UILabel! {
        didSet {
            ingredientLabel?.text = TranslatableStrings.Ingredient
        }
    }

    @IBOutlet weak var percentInProductLabel: UILabel! {
        didSet {
            percentInProductLabel?.text = TranslatableStrings.ForestFootprintPercentInProduct
        }
    }
    
    /// Processing factor (% of food after processing)
    @IBOutlet weak var processingFactorLabel: UILabel! {
        didSet {
            processingFactorLabel?.text = TranslatableStrings.ForestFootprintProcessingFactor
        }
    }
    
    /// Forest footprint (m² per kg of food)
    @IBOutlet weak var forestFootprintLabel: UILabel! {
        didSet {
            forestFootprintLabel?.text = TranslatableStrings.ForestFootprintDescription
        }
    }
    
// MARK: - Soy base line
    
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel?.text = TranslatableStrings.ForestFootprintIngredientType
        }
    }
    
    /// Soy feed factor (kg of soy per kg of food)
    @IBOutlet weak var soyFeedFactorLabel: UILabel! {
        didSet {
            soyFeedFactorLabel?.text = TranslatableStrings.ForestFootprintSoyFeedFactor
        }
    }
    
    /// Soy yield (kg of soy per m²)
    @IBOutlet weak var soyYieldLabel: UILabel! {
        didSet {
            soyYieldLabel?.text = TranslatableStrings.ForestFootprintSoyYield
        }
    }
    
    /// Deforestation risk (%)
    @IBOutlet weak var deforestationRiskLabel: UILabel! {
        didSet {
            deforestationRiskLabel?.text = TranslatableStrings.ForestFootprintDeforestationRisk
        }
    }
    
}
