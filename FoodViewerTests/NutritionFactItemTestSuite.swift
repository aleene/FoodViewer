//
//  NutritionFactItemTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 13/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionFactItemTestSuite: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    //
    // MARK: - init() test//
    //
    
    func testInit() {
        let nfi = NutritionFactItem()
        XCTAssertNil(nfi.itemName,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.standardValue,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.standardValueUnit,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.servingValue,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.servingValueUnit,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.dailyFractionPerServing,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.key,"Init() correctly initailzed itemName")
    }
    
    //
    // MARK: - init(name:standard:serving:unit:key:)
    //
    
    func testInitNameStandardServingUnitKey() {
        let nfi = NutritionFactItem(name:"testName", standard:"testStandard", serving:"testServing", unit:"kJ", key:"testKey" )
        XCTAssertNil(nfi.itemName,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.standardValue,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.standardValueUnit,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.servingValue,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.servingValueUnit,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.dailyFractionPerServing,"Init() correctly initailzed itemName")
        XCTAssertNil(nfi.key,"Init() correctly initailzed itemName")
    }

}
