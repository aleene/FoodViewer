//
//  NutritionalScoreLevel.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public enum NutritionalScoreLevel: String {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
    case undefined
    
    init(_ string: String) {
        if string == NutritionalScoreLevel.a.rawValue {
            self = NutritionalScoreLevel.a
        } else if string == NutritionalScoreLevel.b.rawValue {
            self = NutritionalScoreLevel.b
        } else if string == NutritionalScoreLevel.c.rawValue {
            self = NutritionalScoreLevel.c
        } else if string == NutritionalScoreLevel.d.rawValue {
            self = NutritionalScoreLevel.d
        } else if string == NutritionalScoreLevel.e.rawValue {
            self = NutritionalScoreLevel.e
        } else {
            self = .undefined
        }
    }
    
    public mutating func int(_ value: Int?) {
        if let existingValue = value {
            if existingValue <= -1 {
                self = .a
            } else if existingValue <= 2 {
                self = .b
            } else if existingValue <= 10 {
                self = .c
            } else if existingValue <= 18 {
                self = .d
            } else if existingValue > 18 {
                self = .e
            }
        } else {
            self = .undefined
        }
    }
    
    public mutating func string(_ value: String?) {
        if let existingValue = value {
            if existingValue == "a" {
                self = .a
            } else if existingValue == "b" {
                self = .b
            } else if existingValue == "c" {
                self = .c
            } else if existingValue == "d" {
                self = .d
            } else if existingValue == "e" {
                self = .e
            } else {
                self = .undefined
            }
        } else {
            self = .undefined
        }
    }
    
    public init() {
        self = .undefined
    }
}
