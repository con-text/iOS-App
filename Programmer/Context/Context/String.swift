//
//  String.swift
//  nimble
//
//  Created by Denis Ogun on 26/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import Foundation

extension String {
    
    func formatMessageForRFDuino() -> [String] {
        let uppercase = self.uppercaseString
        var messages:[String] = []
        let numberOfMessagesToSend = Int(ceil(Double(uppercase.utf16Count/19)))
        
        // Send the first packet
        var currentSubMessage = "1"
        currentSubMessage += self.substringWithRange(Range<String.Index>(start: uppercase.startIndex, end: advance(uppercase.startIndex, 19)))
        
        messages.append(currentSubMessage)
        
        // Create the data packets
        for i in 1...numberOfMessagesToSend {
            currentSubMessage = "2"
            currentSubMessage += self.substringWithRange(Range<String.Index>(start: advance(uppercase.startIndex, i*19), end: advance(uppercase.startIndex, (i*19)+19)))
            messages.append(currentSubMessage)
        }
        
        // Send EOM
        currentSubMessage = "3"
        messages.append(currentSubMessage)
        
        return messages
    }
    
}
