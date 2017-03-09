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
    
    var uk: MockNutritionalScoreUK?
    
    override func setUp() {
        super.setUp()
        uk = MockNutritionalScoreUK()
    }
    
    //
    // MARK: - init() test
    //
    
    // test nutritionalScoreUK.init()
    func testInit() {
        
        XCTAssertEqual(uk!.score, 0, "NutritionalScoreUK has successfully initialized score")

        XCTAssertEqual(uk!.pointsA[0].nutriment, "energy", "NutritionalScoreUK has successfully initialized energy nutriment")
        XCTAssertEqual(uk!.pointsA[0].points, 0, "NutritionalScoreUK has successfully initialized energy points")
        
        XCTAssertEqual(uk!.pointsA[1].nutriment, "saturated-fat", "NutritionalScoreUK has successfully initialized saturated fat nutriment")
        XCTAssertEqual(uk!.pointsA[1].points, 0, "NutritionalScoreUK has successfully initialized saturated fat points")
        
        XCTAssertEqual(uk!.pointsA[2].nutriment, "sugars", "NutritionalScoreUK has successfully initialized sugars nutriment")
        XCTAssertEqual(uk!.pointsA[2].points, 0, "NutritionalScoreUK has successfully initialized sugars points")
        
        XCTAssertEqual(uk!.pointsA[3].nutriment, "sodium", "NutritionalScoreUK has successfully initialized sodium nutriment")
        XCTAssertEqual(uk!.pointsA[3].points, 0, "NutritionalScoreUK has successfully initialized sodium points")
        
        XCTAssertEqual(uk!.pointsC[0].nutriment, "fruits-vegetables-nuts", "NutritionalScoreUK has successfully initialized energy fruits-vegetables-nuts")
        XCTAssertEqual(uk!.pointsC[0].points, 0, "NutritionalScoreUK has successfully initialized fruits-vegetables-nuts points")
        
        XCTAssertEqual(uk!.pointsC[1].nutriment, "fiber", "NutritionalScoreUK has successfully initialized fiber nutriment")
        XCTAssertEqual(uk!.pointsC[1].points, 0, "NutritionalScoreUK has successfully initialized fiber points")
        
        XCTAssertEqual(uk!.pointsC[2].nutriment, "proteins", "NutritionalScoreUK has successfully initialized proteins nutriment")
        XCTAssertEqual(uk!.pointsC[2].points, 0, "NutritionalScoreUK has successfully initialized proteins points")

        switch uk!.level {
        case .undefined:
            XCTAssertTrue(true, "NutritionalScoreUK is successfully initialize level")
        default:
            XCTFail("NutritionalScoreUK did NOT successfully initialize level")
        }
    }
    
    //
    // MARK: - total test
    //
    
    // Check with a single value for pointsA
    func testTotalPointsA() {
        uk!.pointsA[0].points = 10 // points A sum lower than 11
        XCTAssertEqual(uk!.total, 10, "total returns the right value (10)")
    }
    
    // Check with three values for pointsA
    func testTotalPointsASum() {
        uk!.pointsA[0].points = 3
        uk!.pointsA[1].points = 3
        uk!.pointsA[2].points = 4 // points A sum lower than 11
        XCTAssertEqual(uk!.total, 10, "total summed the right value (10)")
    }

    // Check with three values for points A minus pointsC[2]
    func testTotalPointsASumCorrected() {
        uk!.pointsA[0].points = 3
        uk!.pointsA[1].points = 3
        uk!.pointsA[2].points = 4 // points A sum lower than 11
        uk!.pointsC[2].points = 2 // subtract proteins
        XCTAssertEqual(uk!.total, 8, "total summed the right value (8)")
    }

    // Check with three values for points A minus pointsC sum
    func testTotalPointsASumMinusPointsCSum() {
        uk!.pointsA[0].points = 3
        uk!.pointsA[1].points = 3
        uk!.pointsA[2].points = 4 // sum pointsA lower than 11
        uk!.pointsC[0].points = 1
        uk!.pointsC[1].points = 2
        uk!.pointsC[2].points = 2 // subtract all pointsC
        XCTAssertEqual(uk!.total, 5, "total summed the right value (5)")
    }

    // Check with three values for points A minus pointsC[2]
    func testTotalPointsASumHigherThanElevenMinusPointsCSum() {
        uk!.pointsA[0].points = 4
        uk!.pointsA[1].points = 3
        uk!.pointsA[2].points = 4 // sum pointsA higher than or equal 11
        uk!.pointsC[0].points = 1
        uk!.pointsC[1].points = 2
        uk!.pointsC[2].points = 2 // not taken into account for subtraction
        XCTAssertEqual(uk!.total, 8, "total summed the right value (7)")
    }

    // Check with three values for points A minus pointsC[2]
    func testTotalPointsASumHigherThanElevenMinusPointsCSumPlus() {
        uk!.pointsA[0].points = 4
        uk!.pointsA[1].points = 3
        uk!.pointsA[2].points = 4 // sum pointsA higher than or equal 11
        uk!.pointsC[0].points = 5 // nuts etc at its highest
        uk!.pointsC[1].points = 2
        uk!.pointsC[2].points = 2 // taken into account
        XCTAssertEqual(uk!.total, 2, "total summed the right value (7)")
    }

}
