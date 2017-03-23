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
        let value = siu.quantity
        XCTAssertNil(value, "SIUnit init() correctly sets up value to nil.")
        XCTAssertEqual(siu.unit, "", "SIUnit init() correctly sets up unit to \"\".")
    }

    //
    // MARK: - test func description()
    //

    func testDescription() {
        let siu = SIUnit()
        siu.quantity = 1.0
        XCTAssertEqual(siu.description(), "1.0 ", "SIUnit description() returns the right value.")
    }
    
    //
    // MARK: - test set(_:prefix:)
    //
    
    func testSetWithPrefixGiga() {
        let siu = SIUnit()
        siu.set(1.0, prefix: "G")
        if let value = siu.quantity {
            XCTAssertEqual(value, 1000000000.0, "SIUnit.set(1.0, prefix=\"G\") correctly returns the value 1000000000.0")
        } else {
            XCTFail("SIUnit.set(1.0, prefix=\"G\") did not correctly set quantity")
        }
    }

    
    func testSetWithPrefixMega() {
        let siu = SIUnit()
        siu.set(1.0, prefix: "M")
        if let value = siu.quantity {
            XCTAssertEqual(value, 1000000.0, "SIUnit.set(1.0, prefix=\"M\") correctly returns the value 1000000.0")
        } else {
            XCTFail("SIUnit.set(1.0, prefix=\"M\") did not correctly set quantity")
        }
    }

    
    func testSetWithPrefixKilo() {
        let siu = SIUnit()
        siu.set(1.0, prefix: "k")
        if let value = siu.quantity {
            XCTAssertEqual(value, 1000.0, "SIUnit.set(1.0, prefix=\"k\") correctly returns the value 1000.0")
        } else {
            XCTFail("SIUnit.set(1.0, prefix=\"k\") did not correctly set quantity")
        }
    }

    
    func testSetWithPrefixMilli() {
        let siu = SIUnit()
        siu.set(1.0, prefix: "m")
        if let value = siu.quantity {
            XCTAssertEqual(value, 0.001, "SIUnit.set(1.0, prefix=\"m\") correctly returns the value 0.001")
        } else {
            XCTFail("SIUnit.set(1.0, prefix=\"m\") did not correctly set quantity")
        }
    }

    
    func testSetWithPrefixMicro() {
        let siu = SIUnit()
        siu.set(1.0, prefix: "µ")
        if let value = siu.quantity {
            XCTAssertEqual(value, 0.000001, "SIUnit.set(1.0, prefix=\"µ\") correctly returns the value 0.000001")
        } else {
            XCTFail("SIUnit.set(1.0, prefix=\"µ\") did not correctly set quantity")
        }
    }

    
    func testSetWithPrefixNano() {
        let siu = SIUnit()
        siu.set(1.0, prefix: "n")
        if let value = siu.quantity {
            XCTAssertEqual(value, 0.000000001, "SIUnit.set(1.0, prefix=\"n\") correctly returns the value 0.000000001")
        } else {
            XCTFail("SIUnit.set(1.0, prefix=\"n\") did not correctly set quantity")
        }
    }

    //
    // MARK: - test var inGiga
    //
    
    func testInGiga() {
        let siu = SIUnit()
        siu.quantity = 1000000000.0
        let (value, unit) = siu.inGiga
        XCTAssertEqual(value, 1.0, "SIUnit inGiga correctly returns the value 1.0")
        XCTAssertTrue(unit.hasPrefix("G"), "SIUnit inGiga correctly returns the unit prefix \"G\".")
    }
    
    //
    // MARK: - test var inMega
    //
    
    func testInMega() {
        let siu = SIUnit()
        siu.quantity = 1000000.0
        let (value, unit) = siu.inMega
        XCTAssertEqual(value, 1.0, "SIUnit inMega correctly returns the value 1.0")
        XCTAssertTrue(unit.hasPrefix("M"), "SIUnit inMega correctly returns the unit prefix \"M\".")
    }

    //
    // MARK: - test var inKilo
    //
    
    func testInKilo() {
        let siu = SIUnit()
        siu.quantity = 1000.0
        let (value, unit) = siu.inKilo
        XCTAssertEqual(value, 1.0, "SIUnit inKilo correctly returns the value 1.0")
        XCTAssertTrue(unit.hasPrefix("k"), "SIUnit inKilo correctly returns the unit prefix \"k\".")
    }
    
    //
    // MARK: - test var inMilli
    //
    
    func testInMilli() {
        let siu = SIUnit()
        siu.quantity = 0.001
        let (value, unit) = siu.inMilli
        XCTAssertEqual(value, 1.0, "SIUnit inMilli correctly returns the value 1.0")
        XCTAssertTrue(unit.hasPrefix("m"), "SIUnit inMilli correctly returns the unit prefix \"m\".")
    }

    //
    // MARK: - test var inMicro
    //
    
    func testInMicro() {
        let siu = SIUnit()
        siu.quantity = 0.000001
        let (value, unit) = siu.inMicro
        XCTAssertEqual(value, 1.0, "SIUnit inMicro correctly returns the value 1.0")
        XCTAssertTrue(unit.hasPrefix("µ"), "SIUnit inMicro correctly returns the unit prefix \"µ\".")
    }
    //
    // MARK: - test var inNano
    //
    
    func testInNano() {
        let siu = SIUnit()
        siu.quantity = 0.000000001
        let (value, unit) = siu.inNano
        XCTAssertEqual(value, 1.0, "SIUnit inNano correctly returns the value 1.0")
        XCTAssertTrue(unit.hasPrefix("n"), "SIUnit inNano correctly returns the unit prefix \"n\".")
    }


}
