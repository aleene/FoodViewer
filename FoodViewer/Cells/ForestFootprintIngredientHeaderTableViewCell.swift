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
            ingredientLabel?.text = "Ingredient"
        }
    }

    @IBOutlet weak var percentInProductLabel: UILabel! {
        didSet {
            percentInProductLabel?.text = "% in product"
        }
    }
    
    /// Processing factor (% of food after processing)
    @IBOutlet weak var processingFactorLabel: UILabel! {
        didSet {
            processingFactorLabel?.text = "Processing factor\n(% of food after processing)"
        }
    }
    
    /// Forest footprint (m² per kg of food)
    @IBOutlet weak var forestFootprintLabel: UILabel! {
        didSet {
            forestFootprintLabel?.text = "Forest footprint\n(m² per kg of food)"
        }
    }
    
// MARK: - Soy base line
    
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel?.text = "Type"
        }
    }
    
    /// Soy feed factor (kg of soy per kg of food)
    @IBOutlet weak var soyFeedFactorLabel: UILabel! {
        didSet {
            soyFeedFactorLabel?.text = "Soy feed factor\n(kg of soy per kg of food)"
        }
    }
    
    /// Soy yield (kg of soy per m²)
    @IBOutlet weak var soyYieldLabel: UILabel! {
        didSet {
            soyYieldLabel?.text = "Soy yield\n(kg of soy per m²)"
        }
    }
    
    /// Deforestation risk (%)
    @IBOutlet weak var deforestationRiskLabel: UILabel! {
        didSet {
            deforestationRiskLabel?.text = "Deforestation risk\n(%)"
        }
    }
    
}
