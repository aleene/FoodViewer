//
//  DailyValues.swift
//  FoodViewer
//
//  Created by arnaud on 22/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
//  This class stores the Daily Advised Values
//
//  It reads a property list file, which consists of an array of value items,
//  with each item a dictionary (key, value, unit)
//  The key is written without the language prefix (en:) and in lowercase

//  The data is taken from (Reference Daily Intake):
//  http://www.fda.gov/Food/GuidanceRegulation/GuidanceDocumentsRegulatoryInformation/LabelingNutrition/ucm064928.htm 
//  https://en.m.wikipedia.org/wiki/Reference_Daily_Intake
//  https://nl.wikipedia.org/wiki/Aanbevolen_dagelijkse_hoeveelheid
//  Suiker : http://www.nu.nl/gezondheid/3719575/who-halveert-aanbevolen-hoeveelheid-suiker.html

import Foundation

class ReferenceDailyIntakeList {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let manager = ReferenceDailyIntakeList()
    
    private struct Constants {
        static let PlistExtension = "plist"
        static let DailyValuesFileName = "ReferenceDailyIntakeValues"
        static let ValueKey = "value"
        static let UnitKey = "unit"
        static let KeyKey = "key"
    }
    
    private struct TextConstants {
        static let FileNotAvailable = "Error: file %@ not available"
    }
    
    private var list: [DailyValue] = []
    
    private struct DailyValue {
        var key: String
        var value: Double
        var unit: String
        
        init(key:String, value:Double, unit:String) {
            self.key = key
            self.value = value
            self.unit = unit
        }
        
        func normalized() -> Double {
            if unit == "mg" {
                return value / 1000.0
            } else if unit == "µg" {
                return value / 1000000.0
            } else {
                return value
            }
        }
    }

    init() {
        // read all necessary plists in the background
        list = readPlist(fileName: Constants.DailyValuesFileName)
    }
    
    private func readPlist(fileName: String) -> [DailyValue] {
        // Copy the file from the Bundle and write it to the Device:
        if let path = Bundle.main.path(forResource: fileName, ofType: Constants.PlistExtension) {
            
            let resultArray = NSArray(contentsOfFile: path)
            // print("Saved plist file is --> \(resultDictionary?.description)")
            
            if let validResultArray = resultArray {
                list = []
                for arrayEntry in validResultArray {
                    if let dailyValueDict = arrayEntry as? [String:Any] {
                        let key = dailyValueDict[Constants.KeyKey] as? String
                        let value = dailyValueDict[Constants.ValueKey] as? Double
                        let unit = dailyValueDict[Constants.UnitKey] as? String
                        let newDailyValue = DailyValue(key:key!, value:value!, unit:unit!)
                        list.append(newDailyValue)

                    }
                }
                return list
            }
        }
        return []
    }
    
    private func findKey(key:String) -> DailyValue? {
        for item in list {
            if item.key == key {
                return item
            }
        }
        return nil
    }
 
    private func valueForKey(key: String) -> Double? {
        
            if let dv = findKey(key: key) {
                return dv.normalized()
            } else {
                return nil
            }

    }

// MARK: - Convert grams per serving to Daily Value
    
    // returns the daily recommended value as fraction for a specific key
    public func dailyValue(value: Double, forKey: String) -> Double? {
        if let dv = valueForKey(key: forKey) {
            return value / dv
        } else {
            return nil
        }
    }
    
    // returns the daily recommended value as fraction for a specific key
    public func dailyValue(serving: String?, nutrient: Nutrient) -> Double? {
        guard let validServing = serving else { return nil }
        guard let validDouble = Double(validServing) else { return nil }
        
        return dailyValue(value: validDouble, forKey: nutrient.key)
    }

// MARK: - Convert Daily Value to gram
    
    // returns the daily recommended value as fraction for a specific key
    public func gram(dailyValuePercentage: Double, nutrient: Nutrient) -> Double? {
        if let dv = valueForKey(key: nutrient.key) {
            return dv * dailyValuePercentage / 100.0    
        } else {
            return nil
        }
    }

}

