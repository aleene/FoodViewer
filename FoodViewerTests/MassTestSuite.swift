//
//  MassTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 14/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class MassTestSuite: XCTestCase {
    
    //
    // MARK: - test init()
    
    func testInit() {
        let mass = Mass()
        let (value,unit) = mass.quantity
        XCTAssertNil(value, "Mass init() correctly sets up value to nil.")
        XCTAssertEqual(unit, "kg", "Mass init() correctly sets up unit to \"kg\".")
    }
    
}
