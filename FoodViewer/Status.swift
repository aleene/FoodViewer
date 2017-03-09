//
//  Status.swift
//  FoodViewer
//
//  Created by arnaud on 03/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct CompletionStatus: CustomStringConvertible {
    public var value = false
    public var text = "Missing state"
    
    public var description: String {
        get {
            return text
        }
    }

    public init() { }
}
