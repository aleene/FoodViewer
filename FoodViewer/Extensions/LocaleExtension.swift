//
//  LocaleExtension.swift
//  FoodViewer
//
//  Created by arnaud on 27/12/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

extension Locale {
    
    static func interfaceLanguageCode() -> String {
        return Locale.preferredLanguages[0].split(separator:"-").map(String.init)[0]
    }
    
}
