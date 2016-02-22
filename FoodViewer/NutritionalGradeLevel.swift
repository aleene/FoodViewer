//
//  NutritionalGradeLevel.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionalGradeLevel {
    case A
    case B
    case C
    case D
    case E
    case Undefined
    
    mutating func int(value: Int?) {
        if let existingValue = value {
            if existingValue <= -1 {
                self = .A
            } else if existingValue <= 2 {
                self = .B
            } else if existingValue <= 10 {
                self = .C
            } else if existingValue <= 18 {
                self = .D
            } else if existingValue > 18 {
                self = .E
            }
        } else {
            self = .Undefined
        }
    }
    
    mutating func string(value: String?) {
        if let existingValue = value {
            if existingValue == "a" {
                self = .A
            } else if existingValue == "b" {
                self = .B
            } else if existingValue == "c" {
                self = .C
            } else if existingValue == "d" {
                self = .D
            } else if existingValue == "e" {
                self = .E
            } else {
                self = .Undefined
            }
        } else {
            self = .Undefined
        }
    }
}