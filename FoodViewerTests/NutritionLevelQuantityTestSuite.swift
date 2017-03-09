//
//  NutritionalLevelQuantityTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 09/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionLevelQuantityTestSuite: XCTestCase {
    
    var quantity: NutritionLevelQuantity?
    
    override func setUp() {
        super.setUp()
        quantity = NutritionLevelQuantity()
    }
    
    // MARK: - init() test
    //
    
    // test nutritionLevelQuantity.init()
    func testInit() {
        switch quantity! {
        case .undefined:
            XCTAssertTrue(true,"NutritionLevelQuantity is successfully initialized")
        default:
            XCTFail("NutritionLevelQuantity is incorrectly initialized")
        }
    }
    
    //
    //  MARK: - string(_:) tests of edge values
    //
    
    // test nutritionLevelQuantity.string(nil)
    func testStringForValueNil() {
        quantity?.string(nil)
        switch quantity! {
        case .undefined:
            XCTAssertTrue(true,"NutritionLevelQuantity correctly set to .undefined")
        default:
            XCTFail("NutritionLevelQuantity incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("high")
    func testStringForValueHigh() {
        quantity?.string("high")
        switch quantity! {
        case .high:
            XCTAssertTrue(true,"NutritionLevelQuantity correctly set to .high")
        default:
            XCTFail("NutritionLevelQuantity incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("moderate")
    func testStringForValueModerate() {
        quantity?.string("moderate")
        switch quantity! {
        case .moderate:
            XCTAssertTrue(true,"NutritionLevelQuantity correctly set to .moderate")
        default:
            XCTFail("NutritionLevelQuantity incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("low")
    func testStringForValueLow() {
        quantity?.string("low")
        switch quantity! {
        case .low:
            XCTAssertTrue(true,"NutritionLevelQuantity correctly set to .low")
        default:
            XCTFail("NutritionLevelQuantity incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("any")
    func testStringForValueAny() {
        quantity?.string("any")
        switch quantity! {
        case .undefined:
            XCTAssertTrue(true,"NutritionLevelQuantity correctly set to .undefined")
        default:
            XCTFail("NutritionLevelQuantity incorrectly set")
        }
    }
    

}
