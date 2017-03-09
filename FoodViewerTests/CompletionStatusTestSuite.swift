//
//  CompletionStatusTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 07/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import FoodViewer
import XCTest

class CompletionStatusTestSuite: XCTestCase {
    
    var status: CompletionStatus = CompletionStatus()

    override func setUp() {
        super.setUp()
        status.value = true
        status.text = "Test text"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValue() {
        // status.text = "Test"
        XCTAssertTrue(status.value, "The status.value value is correct")
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testText() {
        XCTAssertEqual(status.text,"Test text","The status.text value is correct")
    }
    
    func testDescription() {
        XCTAssertEqual(status.description,"Test text","The status.text value is correct")
    }
    
}
