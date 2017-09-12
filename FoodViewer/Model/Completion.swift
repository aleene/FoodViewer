//
//  Completion.swift
//  FoodViewer
//
//  Created by arnaud on 11/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

// The strings are used in the URL's of the search query, so we look for the right thing
public struct Completion: Hashable {
    
    
    var category: CompletionCategory = .productName
    
    func description() -> String {
        return OFFplists.manager.translateStates(OFF.JSONkey(for: self), language:Locale.preferredLanguages[0])
    }
    
    public var hashValue: Int {
        return category.rawValue
    }
    
    public static func ==(lhs: Completion, rhs: Completion) -> Bool {
        return lhs.category.rawValue == rhs.category.rawValue
    }
    
    public var value: Bool = false

    init(_ category: CompletionCategory, isCompleted value:Bool) {
        self.category = category
        self.value = value
    }
}
