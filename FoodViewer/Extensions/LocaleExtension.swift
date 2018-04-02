//
//  LocaleExtension.swift
//  FoodViewer
//
//  Created by arnaud on 27/12/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

extension Locale {
    
    static var interfaceLanguageCode: String {
        return Locale.preferredLanguages[0].split(separator:"-").map(String.init)[0]
    }
    
    static var countryCode: String {
        return Locale.current.identifier.split(separator:"_").map(String.init)[1]
    }
    
    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages[0].split(separator:"-").map(String.init)
    }
    
    static var preferredLanguageCode: String {
        return Locale.preferredLanguageCodes[0]
    }
    
}
