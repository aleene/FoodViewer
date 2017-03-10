//
//  NutritionalScoreUK.swift
//  FoodViewer
//
//  Created by arnaud on 09/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public class NutritionalScoreUK: NutritionalScore {
    
    // conclusion
    public override var total: Int {
        get {
            // incorporate the proteins in the calculation?
            return sumA >= 11 && pointsC[0].points != 5 ? super.total + pointsC[2].points : super.total
        }
    }
    
    
    public struct UKConstants {
        static let saturatedFatKey = "saturated-fat"
    }
    
    public override init() {
        super.init()
        pointsA[1].nutriment = UKConstants.saturatedFatKey
    }
    
}
