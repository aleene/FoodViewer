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
        static let UsernameKey = kSecAttrAccount as String
        static let PasswordKey = kSecValueData as String
    }

    // private let myKeychainWrapper = KeychainWrapper()
    private let keychain = KeychainSwift()
    var userId: String {
        get {
            if let validKeyChainValue = keychain.get(Credentials.UsernameKey) {
                if validKeyChainValue.characters.count > 0 {
                return validKeyChainValue
                }
            }
            return Credentials.FoodViewerUsername
        }
        set {
            keychain.set(newValue, forKey: Credentials.UsernameKey)
            //myKeychainWrapper.mySetObject(newValue, forKey:kSecAttrAccount)
            //myKeychainWrapper.writeToKeychain()

        }
    }
    var password: String {
        get {
            if let validKeyChainValue = keychain.get(Credentials.PasswordKey) {
                if validKeyChainValue.characters.count > 0 {
                    return validKeyChainValue
                }
            }
            // otherwise fallback on foodviewer
            return Credentials.FoodViewerPassword

        }
        set {
            keychain.set(newValue, forKey: Credentials.PasswordKey)
            // myKeychainWrapper.writeToKeychain()
        }
    }
    
    func personalExists() -> Bool {
        // has a personal account been defined?
        if let validAccount = keychain.get(Credentials.UsernameKey) {
            if validAccount.characters.count > 0 {
                return true
            }
        }
        return false
    }
    
    func removePersonal() {
        // remove the personal credentials from the keychain
        keychain.delete(Credentials.UsernameKey)
        keychain.delete(Credentials.PasswordKey)

        //myKeychainWrapper.mySetObject("", forKey:kSecValueData)
        // myKeychainWrapper.writeToKeychain()
    }
    
    func check(password: String) -> Bool {
        return password == keychain.get(Credentials.PasswordKey) ? true: false
    }
    
}
