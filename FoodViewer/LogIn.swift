//
//  LogIn.swift
//  FoodViewer
//
//  Created by arnaud on 17/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct LogIn {
    
    
    public var personalOFFAcountAvailable: Bool? = nil {
        didSet {
            updatePersonalOFFAccount()
        }
    }
    public var useFoodViewerOFFAccount: Bool? = nil {
        didSet {
            updateUseFoodViewer()
        }
    }

    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let UseFoodViewerKey = "UseFoodViewerKey"
        static let PersonalAccountAvailableKey = "PersonalAccountAvailableKey"
    }
    
    init() {
        defaults = UserDefaults.standard
        if defaults.object(forKey: Constants.UseFoodViewerKey) != nil {
            useFoodViewerOFFAccount = defaults.bool(forKey: Constants.UseFoodViewerKey) 
        }
        if defaults.object(forKey: Constants.PersonalAccountAvailableKey) != nil {
            personalOFFAcountAvailable = defaults.bool(forKey: Constants.PersonalAccountAvailableKey)
        }
    }
    
    mutating func updatePersonalOFFAccount() {
        if personalOFFAcountAvailable != nil {
            // is this query new?
            defaults.set(personalOFFAcountAvailable, forKey: Constants.PersonalAccountAvailableKey)
        }
    }
    
    mutating func updateUseFoodViewer() {
        if useFoodViewerOFFAccount != nil {
            defaults.set(useFoodViewerOFFAccount, forKey: Constants.UseFoodViewerKey)
        }
    }

    mutating func resetCredentials() {
        defaults.removeObject(forKey: Constants.UseFoodViewerKey)
        defaults.removeObject(forKey: Constants.PersonalAccountAvailableKey)
    }
}
