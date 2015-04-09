//
//  NetworkManager.swift
//  nimble
//
//  Created by Denis Ogun on 26/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    let baseURLString = "http://contexte.herokuapp.com"
    
    func createUser(facebookID: String, completionHandler: (userID: String?) -> ()) {
        // Create the request body
        let parameters = [
            "fbId" : facebookID
        ]
        
        // Send the request
        Alamofire.request(.POST, baseURLString + "/users", parameters: parameters, encoding: .JSON)
        .responseString(completionHandler: {
           (_, _, string, _) -> Void in
                completionHandler(userID: string)
        })
    }
    
    func linkDevice(deviceID: String, userID: String, completionHandler: (result: String?) -> ()) {
        // Create the request body
        let parameters = [
            "deviceId" : deviceID,
            "userId" : userID
        ]
        
        // Send the request
        Alamofire.request(.POST, baseURLString + "/devices/associate", parameters: parameters, encoding: .JSON)
        .responseString( completionHandler: {
            (_, _, string, _) -> Void in
                completionHandler(result: string)
        })
    }
}

