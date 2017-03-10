//
//  NutritionalScoreUKTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 09/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionalScoreUKTestSuite: XCTestCase {
    
    var uk = NutritionalScoreUK()
    
    //
    // MARK: - init() test
    //
    
    // test nutritionalScoreUK.init()
    func testInit() {
        XCTAssertEqual(uk.pointsA[1].nutriment, "saturated-fat", "NutritionalScoreUK has successfully initialized saturated fat nutriment")
    }
    
    //
    // MARK: - total test
    //
    
    // Check with three values for points A minus pointsC[2]
    func testTotalPointsASumHigherThanElevenMinusPointsCSum() {
        uk.pointsA[0].points = 4
        uk.pointsA[1].points = 3
        uk.pointsA[2].points = 4 // sum pointsA higher than or equal 11
        uk.pointsC[0].points = 1
        uk.pointsC[1].points = 2
        uk.pointsC[2].points = 2 // not taken into account for subtraction
        XCTAssertEqual(uk.total, 8, "total summed the right value (8)")
    }

}
