//
//  NutritionEntryUnitTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 09/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionEntryUnitTestSuite: XCTestCase {
    
    var unit: NutritionEntryUnit?

    override func setUp() {
        super.setUp()
        unit = NutritionEntryUnit()
    }
    
    //
    // MARK: - Test of init() function
    //
    
    func testInit() {
        XCTAssertEqual(unit!.key(),"100g","The correct key is returned")
    }

    //
    // MARK: - Test of key() function
    //
    
    func testKeyValuePerServing() {
        unit = .perServing
        XCTAssertEqual(unit!.key(),"serving","The correct key is returned")
    }
    
    func testKeyValuePerStandardUnit() {
        unit = .perStandardUnit
        XCTAssertEqual(unit!.key(),"100g","The correct key is returned")
    }

}
