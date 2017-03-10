//
//  NutritionalScoreFranceTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 09/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionalScoreFranceTestSuite: XCTestCase {
    
    var fr = NutritionalScoreFR()
        
    //
    // MARK: - init() test
    //
        
    // test nutritionalScoreFrance.init()
    func testInit() {
        
        XCTAssertEqual(fr.pointsA[1].nutriment, "fr-sat-fat-for-fats", "NutritionalScoreUK has successfully initialized fr-sat-fat-for-fats nutriment")
        XCTAssertEqual(fr.pointsA[1].points, 0, "NutritionalScoreFrance has successfully initialized saturated fat points")
        
        XCTAssertEqual(fr.cheese, false, "NutritionalScoreFrance has successfully initialized cheese")
        XCTAssertEqual(fr.beverage, false, "NutritionalScoreFrance has successfully initialize beverage")
    }

}
