//
//  AccountManager.swift
//  nimble
//
//  Created by Denis Ogun on 04/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

class AccountManager: NSObject {
    
    let service = "com.nimble.keychain"
    let accountID = "facebookID"
    let accountName = "facebookName"
    
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
    
    func setUserFacebookDetails(facebookID: String, facebookName: String) {
        SSKeychain.setPassword(facebookID, forService: service, account: accountID)
        SSKeychain.setPassword(facebookName, forService: service, account: accountName)
    }
}
