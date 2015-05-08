//
//  AccountManager.swift
//  nimble
//
//  Created by Denis Ogun on 04/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import SSKeychain

class AccountManager: NSObject {
    
    let service = "com.nimble.keychain"
    let accountID = "facebookID"
    let accountName = "facebookName"
    let accountUserID = "userID"
    let accountSetup = "isSetup"
    
    override init() {
        super.init()
        SSKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlocked)
    }
    
    func getUserFacebookDetails() -> (facebookID: String, facebookName: String)? {
        var err: NSError?
        
        var facebookID = SSKeychain.passwordForService(service, account: accountID, error: &err)
        var facebookName = SSKeychain.passwordForService(service, account: accountName, error: &err)
        
        if let actualError = err {
            return nil
        } else {
            return (facebookID, facebookName)
        }
    }
    
    func setUserDetails(facebookID: String, facebookName: String, userID: String) {
        SSKeychain.setPassword(facebookID, forService: service, account: accountID)
        SSKeychain.setPassword(facebookName, forService: service, account: accountName)
        SSKeychain.setPassword(userID, forService:service, account: accountUserID)
    }
    
    func getUserID() -> String? {
        var err: NSError?
        
        var userID = SSKeychain.passwordForService(service, account: accountUserID, error: &err)
        
        if let actualError = err {
            return nil
        } else {
            return userID
        }
    }
    
    func isSetup() -> Bool {
                
        let setup : String? = SSKeychain.passwordForService(service, account: accountSetup, error: nil)
        
        if setup == "1" {
            return true
        }
        
        return false
    }
    
    func becomeSetup() {
        SSKeychain.setPassword("1", forService: service, account: accountSetup)
    }
    
    func reset() {
        SSKeychain.deletePasswordForService(service, account: accountSetup)
        SSKeychain.deletePasswordForService(service, account: accountName)
        SSKeychain.deletePasswordForService(service, account: accountID)
        SSKeychain.deletePasswordForService(service, account: accountUserID)
    }
    
}
