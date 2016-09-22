//
//  NutritionalScoreLevel.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionalScoreLevel {
    case a
    case b
    case c
    case d
    case e
    case undefined
    
    mutating func int(_ value: Int?) {
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
    
    mutating func string(_ value: String?) {
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
    
    init() {
        self = .undefined
    }
}
