//
//  NutritionFactUnitTest.swift
//  FoodViewer
//
//  Created by arnaud on 11/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class NutritionFactUnitTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    //
    // MARK: - init(text:) tests
    //
    
    func testInitTextWithValuekJ() {
        let nfu = NutritionFactUnit.init("kJ")
        switch nfu {
        case .Joule:
            XCTAssertTrue(true, "NutritionFactUnit.init(\"kJ\") correctly initialized")
        default:
            XCTFail("NutritionFactUnit.init(\"kJ\") did NOT correctly initialize")
        }
    }
    
    func testInitTextWithValuekcal() {
        let nfu = NutritionFactUnit.init("kcal")
        switch nfu {
        case .Calories:
            XCTAssertTrue(true, "NutritionFactUnit.init(\"kcal\") correctly initialized")
        default:
            XCTFail("NutritionFactUnit.init(\"kcal\") did NOT correctly initialize")
        }
    }

    func testInitTextWithValueg() {
        let nfu = NutritionFactUnit.init("g")
        switch nfu {
        case .Gram:
            XCTAssertTrue(true, "NutritionFactUnit.init(\"g\") correctly initialized")
        default:
            XCTFail("NutritionFactUnit.init(\"g\") did NOT correctly initialize")
        }
    }

    func testInitTextWithValuemg() {
        let nfu = NutritionFactUnit.init("mg")
        switch nfu {
        case .Milligram:
            XCTAssertTrue(true, "NutritionFactUnit.init(\"mg\") correctly initialized")
        default:
            XCTFail("NutritionFactUnit.init(\"mg\") did NOT correctly initialize")
        }
    }
    
    func testInitTextWithValuemicrog() {
        let nfu = NutritionFactUnit.init("µg")
        switch nfu {
        case .Microgram:
            XCTAssertTrue(true, "NutritionFactUnit.init(\"µg\") correctly initialized")
        default:
            XCTFail("NutritionFactUnit.init(\"%g\") did NOT correctly initialize")
        }
    }
    func testInitTextWithValuePercent() {
        let nfu = NutritionFactUnit.init("%")
        switch nfu {
        case .Percent:
            XCTAssertTrue(true, "NutritionFactUnit.init(\"%\") correctly initialized")
        default:
            XCTFail("NutritionFactUnit.init(\"%\") did NOT correctly initialize")
        }
    }
    func testInitTextWithValueNone() {
        let nfu = NutritionFactUnit.init("")
        switch nfu {
        case .None:
            XCTAssertTrue(true, "NutritionFactUnit.init(\"\") correctly initialized")
        default:
            XCTFail("NutritionFactUnit.init(\"\") did NOT correctly initialize")
        }
    }

    //
    // MARK: - caseCount() test
    //

    func testNFUCaseCount() {
        XCTAssertEqual(NutritionFactUnit.caseCount, 7, "NutritionFactUnit.CaseCount() correctly returns 7")
    }
    
    //
    // MARK: - value(key:) tests
    //
    
    func testCaseCountValueEnergy() {
        XCTAssertEqual(NutritionFactUnit.caseCount(key:"en:energy"), 4, "NutritionFactUnit.CaseCount(key:\"en:energy\") correctly returns 4")
    }
    
    func testCaseCountValueSomething() {
        XCTAssertEqual(NutritionFactUnit.caseCount(key:"something"), 5, "NutritionFactUnit.CaseCount(key:\"something\" correctly returns 5")
    }

    //
    // MARK: - value(for:and:) test
    //
    
    func testValueFor2AndEnergy() {
        XCTAssertEqual(NutritionFactUnit.value(for:2, and:"en:energy"), 5, "NutritionFactUnit.Value(for:2, and:\"en:energy\") correctly returns 5")
    }
    
    func testValueFor3AndEnergy() {
        XCTAssertEqual(NutritionFactUnit.value(for:3, and:"en:energy"), 6, "NutritionFactUnit.Value(for:3, and:\"en:energy\") correctly returns 6")
    }

    func testValueFor2AndNotEnergy() {
        XCTAssertEqual(NutritionFactUnit.value(for:2, and:"something"), 2, "NutritionFactUnit.Value(for:2, and:\"something\") correctly returns 7")
    }
    
    func testValueFor3AndNotEnergy() {
        XCTAssertEqual(NutritionFactUnit.value(for:3, and:"something"), 5, "NutritionFactUnit.Value(for:3, and:\"something\") correctly returns 5")
    }

    //
    // MARK: - description()
    //
    
    // not tested as these return localized strings.
    
    //
    // MARK: - short()
    //
    
    
    func testShortJoule() {
        let nfu = NutritionFactUnit.init("kJ")
        XCTAssertEqual(nfu.short(), "kJ", "NutritionFactUnit.short() for .Joule correctly returns \"kJ\" ")
    }
    
    func testShortCalories() {
        let nfu = NutritionFactUnit.init("kcal")
        XCTAssertEqual(nfu.short(), "kcal", "NutritionFactUnit.short() for .Calories correctly returns \"kcal\" ")
    }
    
    func testShortGram() {
        let nfu = NutritionFactUnit.init("g")
        XCTAssertEqual(nfu.short(), "g", "NutritionFactUnit.short() for .Gram correctly returns \"g\" ")
    }
    
    func testShortMilliGram() {
        let nfu = NutritionFactUnit.init("mg")
        XCTAssertEqual(nfu.short(), "mg", "NutritionFactUnit.short() for .Milligram correctly returns \"mg\" ")
    }
    
    func testShortMicroGram() {
        let nfu = NutritionFactUnit.init("µg")
        XCTAssertEqual(nfu.short(), "µg", "NutritionFactUnit.short() for .Microgram correctly returns \"µg\" ")
    }
    func testShortPercent() {
        let nfu = NutritionFactUnit.init("%")
        XCTAssertEqual(nfu.short(), "%", "NutritionFactUnit.short() for .Percent correctly returns \"%\" ")
    }
    func testShortNone() {
        let nfu = NutritionFactUnit.init("")
        XCTAssertEqual(nfu.short(), "", "NutritionFactUnit.short() for .None correctly returns \"\" ")
    }

    //
    // MARK: - short(key:)
    //
    

    func testShortKeyEnergyJoule() {
        let nfu = NutritionFactUnit("kJ")
        XCTAssertEqual(nfu.short(key:"en:energy"), "kJ", "NutritionFactUnit.short(key:\"en:energy\") for .Joule correctly returns \"kJ\" ")
    }
    
    func testShortKeyEnergyCalories() {
        let nfu = NutritionFactUnit.init("kcal")
        XCTAssertEqual(nfu.short(key:"en:energy"), "kcal", "NutritionFactUnit.short(key:\"en:energy\") for .Calories correctly returns \"kcal\" ")
    }
    
    func testShortKeyEnergyPercent() {
        let nfu = NutritionFactUnit.init("%")
        XCTAssertEqual(nfu.short(key:"en:energy"), "%", "NutritionFactUnit.short(key:\"en:energy\") for .Percent correctly returns \"%\" ")
    }

    func testShortKeyEnergyDefault() {
        let nfu = NutritionFactUnit.init("g")
        XCTAssertEqual(nfu.short(key:"en:energy"), "", "NutritionFactUnit.short(key:\"en:energy\") for .Gram correctly returns \"\" ")
    }

    func testShortKeyNotEnergyGram() {
        let nfu = NutritionFactUnit.init("g")
        XCTAssertEqual(nfu.short(key:"something"), "g", "NutritionFactUnit.short(key:\"something\") for .Gram correctly returns \"g\" ")
    }
    
    func testShortNotEnergyMilliGram() {
        let nfu = NutritionFactUnit.init("mg")
        XCTAssertEqual(nfu.short(key:"something"), "mg", "NutritionFactUnit.short(key:\"something\") for .Milligram correctly returns \"mg\" ")
    }
    
    func testShortNotEnergyMicroGram() {
        let nfu = NutritionFactUnit.init("µg")
        XCTAssertEqual(nfu.short(key:"something"), "µg", "NutritionFactUnit.short(key:\"something\") for .Microgram correctly returns \"µg\" ")
    }
    func testShortNotEnergyPercent() {
        let nfu = NutritionFactUnit.init("%")
        XCTAssertEqual(nfu.short(key:"something"), "%", "NutritionFactUnit.short(key:\"something\") for .Percent correctly returns \"%\" ")
    }
    func testShortNotEnergyDefault() {
        let nfu = NutritionFactUnit.init("kJ")
        XCTAssertEqual(nfu.short(key:"something"), "", "NutritionFactUnit.short(key:\"something\") for .Gram correctly returns \"\" ")
    }

}
