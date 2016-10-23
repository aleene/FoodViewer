//
//  OFFAccount.swift
//  FoodViewer
//
//  Created by arnaud on 17/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct OFFAccount {

    fileprivate struct Credentials {
        static let FoodViewerUsername = "foodviewer"
        static let FoodViewerPassword = "42DYJhL69fxK"
    }

    private let myKeychainWrapper = KeychainWrapper()

    var userId: String {
        get {
            if let validKeyChainValue = myKeychainWrapper.myObject(forKey: kSecAttrAccount) as? String {
                if validKeyChainValue.characters.count > 0 {
                return validKeyChainValue
                }
            }
            return Credentials.FoodViewerUsername
        }
        set {
            myKeychainWrapper.mySetObject(newValue, forKey:kSecAttrAccount)
            myKeychainWrapper.writeToKeychain()

        }
    }
    var password: String {
        get {
            if let validKeyChainValue = myKeychainWrapper.myObject(forKey: kSecValueData) as? String {
                if validKeyChainValue.characters.count > 0 {
                    return validKeyChainValue
                }
            }
            // otherwise fallback on foodviewer
            return Credentials.FoodViewerPassword

        }
        set {
            myKeychainWrapper.mySetObject(newValue, forKey:kSecValueData)
            myKeychainWrapper.writeToKeychain()
        }
    }
    
    func personalExists() -> Bool {
        // has a personal account been defined?
        if let validAccount = myKeychainWrapper.myObject(forKey: kSecAttrAccount) as? String {
            if validAccount.characters.count > 0 {
                return true
            }
        }
        return false
    }
    
    func removePersonal() {
        // remove the personal credentials from the keychain
        myKeychainWrapper.mySetObject("", forKey:kSecAttrAccount)
        myKeychainWrapper.mySetObject("", forKey:kSecValueData)
        myKeychainWrapper.writeToKeychain()
    }
    
    func check(password: String) -> Bool {
        return password == (myKeychainWrapper.myObject(forKey: kSecValueData) as? String) ? true: false
    }
    
}
