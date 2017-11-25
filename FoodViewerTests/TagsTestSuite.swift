//
//  TagsTestSuite.swift
//  FoodViewer
//
//  Created by arnaud on 07/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import XCTest
import FoodViewer

class TagsTestSuite: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    //
    // MARK: - test the default init()
    //
    func testInit() {
        let tags = Tags()
        switch tags {
        case .undefined:
            XCTAssertTrue(true,"Default init() successfull")
        default:
            XCTFail("Init does NOT give default value .undefined")
        }
    }
    
    //
    // MARK: - test the value .empty
    //
    
    func testEmptyValue() {
        var tags = Tags()
        tags = .empty
        switch tags {
        case .empty:
            XCTAssertTrue(true,"Value .empty successfully set")
        default:
            XCTFail("Value does not give .empty")
        }
    }
    
    //
    // MARK: - test the value .undefined
    //
    
    func testUndefinedValue() {
        var tags = Tags()
        tags = .undefined
        switch tags {
        case .undefined:
            XCTAssertTrue(true,"Value .undefined successfully set")
        default:
            XCTFail("Value does not give .undefined")
        }
    }
    
    //
    // MARK: - test init with a list of strings
    //

    // test with a correct list
    
    func testInitWithList() {
        let list = ["1","2"]
        let tags = Tags.init(list)
        switch tags {
        case .available(let newList):
            XCTAssertTrue(true,"init(list:) successfull")
            XCTAssertEqual(newList[0], "1", "init(list:) first value correct")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }
    
    // test with a list that contains an empty item
    
    func testInitWithListWithEmptyItem() {
        let list = ["1", "", "2"]
        let tags = Tags.init(list)
        switch tags {
        case .available(let newList):
            XCTAssertTrue(true,"init(list:) successfull")
            XCTAssertEqual(newList[0], "1", "init(list:) first value correct")
            XCTAssertEqual(newList[1], "2", "init(list:) second value correct")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }

    // test with a list that is nil
    
    func testInitWithListThatIsNil() {
        let list: [String]? = nil
        let tags = Tags.init(list)
        switch tags {
        case .available:
            XCTFail("Init(list:nil) does NOT give the correct value")
        case .undefined:
            XCTAssertTrue(true,"Value .undefined successfully set, when initialising with a nil list")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }
    
    //
    // MARK: - test init(string:) with a comma delimited string
    //
    
    // test with a correct string
    
    func testInitWithCommaDelimitedString() {
        let string = "1,2,3"
        let tags = Tags.init(string)
        switch tags {
        case .available(let newList):
            XCTAssertTrue(true,"init(string:) successfull")
            XCTAssertEqual(newList[0], "1", "init(string) first value correct")
        default:
            XCTFail("Init(string:) does NOT give the correct value")
        }
    }
    
    // test with a string that has two sequential commas

    func testInitWithCommaDelimitedStringWithTwoCommas() {
        let string = "1,,3"
        let tags = Tags.init(string)
        switch tags {
        case .available(let newList):
            XCTAssertTrue(true,"init(string:) successfull")
            XCTAssertEqual(newList[0], "1", "init(string) first value correct")
            XCTAssertEqual(newList[1], "3", "init(string) second value correct")
        default:
            XCTFail("Init(string:) does NOT give the correct value")
        }
    }

    // test with a nil object
    
    func testInitWithStringThatIsNil() {
        let string: String? = nil
        let tags = Tags.init(string)
        switch tags {
        case .available:
            XCTFail("Init(list:nil) does NOT give the correct value")
        case .undefined:
            XCTAssertTrue(true,"Value .undefined successfully set, when initialising with a nil list")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }

    func testInitWithListAndLanguageCode() {
        let list = ["fr:1","2","3"]
        let lc = "en"
        let tags = Tags.init(list:list)
        tags = tags.addPrefix(lc)
        switch tags {
        case .available(let newList):
            XCTAssertTrue(true,"init(string:) successfull")
            XCTAssertEqual(newList[0], "fr:1", "init(list:languageCode) first value correct")
            XCTAssertEqual(newList[1], "en:2", "init(list:languageCode) 2nd value correct")
        default:
            XCTFail("Init(string:) does NOT give the correct value")
        }
    }

    func testInitWithListThatIsNilAndLanguageCode() {
        let list: [String]? = nil
        let lc = "en"
        let tags = Tags.init(list:list)
        tags = tags.addPrefix(lc)
        switch tags {
        case .undefined:
            XCTAssertTrue(true,"Value .undefined successfully set, when initialising with a nil list")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }

    func testInitWithListThatHasNoElementsAndLanguageCode() {
        let list: [String]? = []
        let lc = "en"
        let tags = Tags.init(list:list)
        tags = tags.addPrefix(lc)
        switch tags {
        case .empty:
            XCTAssertTrue(true,"Value .undefined successfully set, when initialising with a nil list")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }

    func testInitWithCommaDelimitedStringAndLanguageCode() {
        let string = "1,fr:2,3"
        let lc = "en"
        let tags = Tags.init(string:string)
        tags = tags.addPrefix(lc)
        switch tags {
        case .available(let newList):
            XCTAssertTrue(true,"init(string:) successfull")
            XCTAssertEqual(newList[0], "en:1", "init(string:with:) first value correct")
            XCTAssertEqual(newList[1], "fr:2", "init(string:with) second value correct")
        default:
            XCTFail("Init(string:) does NOT give the correct value")
        }
    }
    
    func testInitWithStringThatIsNilAndLanguageCode() {
        let string: String? = nil
        let lc = "en"
        let tags = Tags.init(string:string)
        tags = tags.addPrefix(lc)
        switch tags {
        case .undefined:
            XCTAssertTrue(true,"Value .undefined successfully set, when initialising with a nil list")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }

    func testInitWithStringThatIsEmptyAndLanguageCode() {
        let string: String? = ""
        let lc = "en"
        let tags = Tags.init(string:string)
        tags = tags.addPrefix(lc)
        switch tags {
        case .empty:
            XCTAssertTrue(true,"Value .empty successfully set, when initialising with an empty string")
        default:
            XCTFail("Init(list:) does NOT give the correct value")
        }
    }
    
    //
    // MARK: - tag(_:)
    //

    // Test to see if the right item from the list is returned
    
    func testTagWithValidIndex() {
        let list = ["1","2","3"]
        let tags = Tags(list)
        XCTAssertEqual(tags.tag(at: 1),  "2", "Value of second tag, with index 1")
    }

    func testTagWithInvalidIndex() {
        let list = ["1","2","3"]
        let tags = Tags.init(list)
        let string = tags.tag(at: 6)
        XCTAssertNil(string, "tag with out of bounds returns nil")
    }

    func testTagWithIndexThatIsUndefined() {
        let tags = Tags()
        let string = tags.tag(at: 6)
        XCTAssertEqual(string, "unknown", "tag with out of bounds returns nil")
    }
    
    //
    // MARK: - tagWithoutPrefix(_:locale:)
    //
    
    // test to see whether a tag at an index with a prefix is removed if it matches a give locale
    /*
    func testRemoveLanguagePrefix() {
        let list = ["en:1","fr:2","nl:3"]
        let tags = Tags(list)
        let newTag = tags.tag(at:1, locale: "fr-BE")
        XCTAssertEqual(newTag, "2", "The tag at index 1 has the prefix removed.")
    }
    
    // test to see whether a tag at an index with a prefix is removed if it does not match a given locale

    func testRemoveInexistentLanguagePrefix() {
        let list = ["en:1","fr:2","nl:3"]
        let tags = Tags(list)
        let newTag = tags.tagWithoutPrefix(1, locale: "nl-BE")
        XCTAssertEqual(newTag, "fr:2", "The tag at index 1 has the prefix not removed.")
    }

    func testRemoveLanguagePrefixForOutOfBoundsIndex() {
        let list = ["en:1","fr:2","nl:3"]
        let tags = Tags(list)
        let newTag = tags.tagWithoutPrefix(4, locale: "fr-BE")
        XCTAssertNil(newTag, "The tag at index 4 does not exist.")
    }
     */
    //
    // MARK: - remove(_:)
    //

    // Test to see if an item with a valid index (within bounds) is removed
    
    func testRemoveItemAtAValidIndex() {
        let list = ["1","2","3"]
        var tags = Tags(list)
        tags.remove(0)
        switch tags {
        case .available(let newList):
            XCTAssertEqual(newList[0], "2", "The tag at index 0 is removed.")
        default:
            XCTFail("Failed to initialise correctly")
        }
    }
    
    // Test to see if an item with a invalid index (within bounds) unchanges the list

    func testRemoveItemAtAnInvalidIndex() {
        let list = ["1","2","3"]
        var tags = Tags(list)
        tags.remove(4)
        switch tags {
        case .available(let newList):
            XCTAssertEqual(newList[0], "1", "The tag at index 0 is still there")
            XCTAssertEqual(newList[1], "2", "The tag at index 1 is still there")
            XCTAssertEqual(newList[2], "3", "The tag at index 2 is still there")
        default:
            XCTFail("Failed to initialise correctly")
        }
    }

    //
    // MARK: - prefixedList(_:)
    //

    // Test to see whether a prefix is actually added to an element of the list
    /*
    func testPrefixedListWithItemWithoutPrefix() {
        let list = ["1","2","3"]
        let tags = Tags(list)
        let prefixedList = tags.addPrefix("en")
        XCTAssertEqual(prefixedList[0], "en:1", "A prefix will be added to a tag")
    }
    
    // Test to see whether a prefix is not added to an element of the list, if there is already one
    
    func testPrefixedListWithItemWithPrefix() {
        let list = ["fr:1","2","3"]
        let tags = Tags(list)
        let prefixedList = tags.addPrefix("en")
        XCTAssertEqual(prefixedList[0], "fr:1", "A prefix will not be added to a tag when there is already one")
    }
     */
}
