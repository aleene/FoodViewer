//
//  Preferences.swift
//  
//
//  Created by arnaud on 12/04/16.
//
//

import Foundation

class Preferences {
    
    // This class is implemented as a singleton
    // The Preferences are now used by the SettingsVC and the NutritionsTableVC
    // Unfortunately moving to another VC deletes the products, so it must be stored somewhere more permanently.
    // A singleton limits however the number of file loads
    
    static let manager = Preferences()
    
    var showSaltSodiumOrBoth = NatriumChloride.Both
}