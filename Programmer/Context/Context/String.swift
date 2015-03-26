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
        currentSubMessage += self[0...19]
        
        messages.append(currentSubMessage)
        
        // Create the data packets
        for i in 0..<numberOfMessagesToSend {
            currentSubMessage = "2"
            currentSubMessage += self[i*19...(i*19)+19]
            messages.append(currentSubMessage)
        }
        
        // Send EOM
        currentSubMessage = "3"
        messages.append(currentSubMessage)
        
        return messages
    }
    
    subscript(integerIndex: Int) -> Character {
        let index = advance(startIndex, integerIndex)
        return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        var rangeEnd:Int? = nil
        if (integerRange.endIndex > self.utf16Count) {
            rangeEnd = self.utf16Count
        }
        
        let start = advance(startIndex, integerRange.startIndex)
        let end = advance(startIndex, rangeEnd ?? integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
}
