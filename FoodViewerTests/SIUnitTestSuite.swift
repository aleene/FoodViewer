//
//  SIUnitTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 14/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class SIUnitTestSuite: XCTestCase {
    
    //
    // MARK: - test init()
    //
    
    func testInit() {
        let siu = SIUnit()
        let (value,unit) = siu.quantity
        XCTAssertNil(value, "SIUnit init() correctly sets up value to nil.")
        XCTAssertEqual(unit, "", "SIUnit init() correctly sets up unit to \"\".")
    }
    
    //
    // MARK: - test init()
    //
    
    func testInitWithValues() {
        let siu = SIUnit(1.0, unit:"NN")
        let (value, unit) = siu.quantity
        XCTAssertEqual(value, 1.0, "SIUnit init(1.0, unit:\"NN\") correctly sets up value to 1.0")
        XCTAssertEqual(unit, "NN", "SIUnit init(1.0, unit:\"NN\") correctly sets up unit to \"NN\".")
    }
    

    //
    // MARK: - test description()
    //

    func testDescription() {
        let siu = SIUnit()
        siu.quantity = (1, "NN")
        XCTAssertEqual(siu.description(), "1.0 NN", "SIUnit init() correctly sets up unit to \"\".")
    }

}
