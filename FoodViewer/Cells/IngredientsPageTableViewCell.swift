//
//  IngredientsPageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 20/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsPageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    @IBOutlet weak var allergensLabel: UILabel!

    @IBOutlet weak var tracesLabel: UILabel!
    
    @IBOutlet weak var ingredientsBadge: UIView!
    
    @IBOutlet weak var ingredientsBadgeLabel: UILabel!
    
    @IBOutlet weak var allergensBadge: UIView!
    
    @IBOutlet weak var allergensBadgeLabel: UILabel!

    @IBOutlet weak var tracesBadge: UIView!
    
    @IBOutlet weak var tracesBadgeLabel: UILabel!

    public var ingredientsText: String = "" {
        didSet {
            ingredientsLabel.text = ingredientsText
        }
    }
    
    public var ingredientsBadgeText: String = "" {
        didSet {
            ingredientsBadgeLabel.text = ingredientsBadgeText
        }
    }

    public var allergensText: String = "" {
        didSet {
            allergensLabel.text = allergensText
        }
    }

    public var allergensBadgeText: String = "" {
        didSet {
            allergensBadgeLabel.text = allergensBadgeText
        }
    }

    public var tracesText: String = "" {
        didSet {
            tracesLabel.text = tracesText
        }
    }

    public var tracesBadgeText: String = "" {
        didSet {
            tracesBadgeLabel.text = tracesBadgeText
        }
    }

}
