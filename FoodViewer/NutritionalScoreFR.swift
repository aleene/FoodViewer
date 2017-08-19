//
//  NutritionalScoreFR.swift
//  FoodViewer
//
//  Created by arnaud on 11/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public class NutritionalScoreFR: NutritionalScore {

    // special french stuff
    public var cheese = false
    public var beverage = false
    
    public struct FRConstants {
        static let saturatedFatRatioKey = "fr-sat-fat-for-fats"
    }
    
    public override init() {
        super.init()
        pointsA[1].nutriment = FRConstants.saturatedFatRatioKey
    }
}
