//
//  NutritionalScoreLevelTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 09/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionalScoreLevelTestSuite: XCTestCase {
    
    var level: NutritionalScoreLevel?
    
    override func setUp() {
        super.setUp()
        level = NutritionalScoreLevel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //
    // MARK: - init() test
    //
    
    // test nutritionalScoreLevel.init()
    func testInit() {
        switch level! {
        case .undefined:
            XCTAssertTrue(true,"NutrionalScoreLevel is successfully initialized")
        default:
            XCTFail("NutrionalScoreLevel is incorrectly initialized")
        }
    }
    
    //
    // MARK: - int(_:) tests of edge values
    //
    
    // test nutritionalScoreLevel.int(nil)
    func testIntForValueNil() {
        level?.int(nil)
        switch level! {
        case .undefined:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .undefined")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }

    // test nutritionalScoreLevel.int(-1)
    func testIntForValueMinusOne() {
        level?.int(-1)
        switch level! {
        case .a:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .a")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.int(2)
    func testIntForValueTwo() {
        level?.int(2)
        switch level! {
        case .b:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .b")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }

    // test nutritionalScoreLevel.int(10)
    func testIntForValueTen() {
        level?.int(10)
        switch level! {
        case .c:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .c")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.int(18)
    func testIntForValueEighteen() {
        level?.int(18)
        switch level! {
        case .d:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .d")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }

    // test nutritionalScoreLevel.int(19)
    func testIntForValueNineteen() {
        level?.int(19)
        switch level! {
        case .e:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .e")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }

    //
    // MARK: - string(_:) tests of edge values
    //
    
    // test nutritionalScoreLevel.string(nil)
    func testStringForValueNil() {
        level?.string(nil)
        switch level! {
        case .undefined:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .undefined")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("a")
    func testStringForValueA() {
        level?.string("a")
        switch level! {
        case .a:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .a")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("b")
    func testStringForValueB() {
        level?.string("b")
        switch level! {
        case .b:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .b")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("c")
    func testStringForValueC() {
        level?.string("c")
        switch level! {
        case .c:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .c")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("d")
    func testStringForValueD() {
        level?.string("d")
        switch level! {
        case .d:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .d")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }
    
    // test nutritionalScoreLevel.string("e")
    func testStringForValueE() {
        level?.string("e")
        switch level! {
        case .e:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .e")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }

    // test nutritionalScoreLevel.string("any")
    func testStringForValueAny() {
        level?.string("any")
        switch level! {
        case .undefined:
            XCTAssertTrue(true,"NutrionalScoreLevel correctly set to .undefined")
        default:
            XCTFail("NutrionalScoreLevel incorrectly set")
        }
    }

}
