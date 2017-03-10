//
//  NutritionalScoreTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionalScoreTestSuite: XCTestCase {
    
    var ns = NutritionalScore()
        
    //
    // MARK: - init() test
    //
        
    // test nutritionalScore.init()
    func testInit() {
            
        XCTAssertEqual(ns.score, 0, "NutritionalScore has successfully initialized score")
            
        XCTAssertEqual(ns.pointsA[0].nutriment, "energy", "NutritionalScore has successfully initialized energy nutriment")
        XCTAssertEqual(ns.pointsA[0].points, 0, "NutritionalScore has successfully initialized energy points")
            
        XCTAssertEqual(ns.pointsA[1].nutriment, "", "NutritionalScore has successfully initialized stub nutriment")
        XCTAssertEqual(ns.pointsA[1].points, 0, "NutritionalScore has successfully initialized saturated fat points")
            
        XCTAssertEqual(ns.pointsA[2].nutriment, "sugars", "NutritionalScore has successfully initialized sugars nutriment")
        XCTAssertEqual(ns.pointsA[2].points, 0, "NutritionalScore has successfully initialized sugars points")
            
        XCTAssertEqual(ns.pointsA[3].nutriment, "sodium", "NutritionalScore has successfully initialized sodium nutriment")
        XCTAssertEqual(ns.pointsA[3].points, 0, "NutritionalScore has successfully initialized sodium points")
            
        XCTAssertEqual(ns.pointsC[0].nutriment, "fruits-vegetables-nuts", "NutritionalScore has successfully initialized energy fruits-vegetables-nuts")
        XCTAssertEqual(ns.pointsC[0].points, 0, "NutritionalScore has successfully initialized fruits-vegetables-nuts points")
            
        XCTAssertEqual(ns.pointsC[1].nutriment, "fiber", "NutritionalScore has successfully initialized fiber nutriment")
        XCTAssertEqual(ns.pointsC[1].points, 0, "NutritionalScore has successfully initialized fiber points")
            
        XCTAssertEqual(ns.pointsC[2].nutriment, "proteins", "NutritionalScore has successfully initialized proteins nutriment")
        XCTAssertEqual(ns.pointsC[2].points, 0, "NutritionalScore has successfully initialized proteins points")
            
        switch ns.level {
        case .undefined:
            XCTAssertTrue(true, "NutritionalScore is successfully initialize level")
        default:
            XCTFail("NutritionalScoreUK did NOT successfully initialize level")
        }
    }
        
    //
    // MARK: - total test
    //
        
    // Check with a single value for pointsA
    func testTotalPointsA() {
        ns.pointsA[0].points = 10 // points A sum lower than 11
        XCTAssertEqual(ns.total, 10, "total returns the right value (10)")
    }
        
    // Check with three values for pointsA
    func testTotalPointsASum() {
        ns.pointsA[0].points = 3
        ns.pointsA[1].points = 3
        ns.pointsA[2].points = 4 // points A sum lower than 11
        XCTAssertEqual(ns.total, 10, "total summed the right value (10)")
    }
        
    // Check with three values for points A minus pointsC[2]
    func testTotalPointsASumCorrected() {
        ns.pointsA[0].points = 3
        ns.pointsA[1].points = 3
        ns.pointsA[2].points = 4 // points A sum lower than 11
        ns.pointsC[2].points = 2 // subtract proteins
        XCTAssertEqual(ns.total, 8, "total summed the right value (8)")
    }
        
    // Check with three values for points A minus pointsC sum
    func testTotalPointsASumMinusPointsCSum() {
        ns.pointsA[0].points = 3
        ns.pointsA[1].points = 3
        ns.pointsA[2].points = 4 // sum pointsA lower than 11
        ns.pointsC[0].points = 1
        ns.pointsC[1].points = 2
        ns.pointsC[2].points = 2 // subtract all pointsC
        XCTAssertEqual(ns.total, 5, "total summed the right value (5)")
    }
                
    // Check with three values for points A minus points C sum
    func testTotalPointsASumHigherThanElevenMinusPointsCSumAll() {
        ns.pointsA[0].points = 4
        ns.pointsA[1].points = 3
        ns.pointsA[2].points = 4 // sum pointsA higher than or equal 11
        ns.pointsC[0].points = 5 // nuts etc at its highest
        ns.pointsC[1].points = 2
        ns.pointsC[2].points = 2 // taken into account
        XCTAssertEqual(ns.total, 2, "total summed the right value (2)")
    }
        
}
