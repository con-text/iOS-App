//: Playground - noun: a place where people can play

import Cocoa

var str = "DE54495425C75FA5682B5F12D79A818518C2CAE58AD2F4F52E4BD3DAC4A48E03"

extension String {
    
    func formatMessageForRFDuino() -> [String] {
        let uppercase = self.uppercaseString
        var messages:[String] = []
        let numberOfMessagesToSend = Int(ceil(Double(count(uppercase))/19.0))
        
        // Send the first packet
        var currentSubMessage = "1"
        currentSubMessage += uppercase[0..<19]
        
        messages.append(currentSubMessage)
        
        // Create the data packets
        for i in 1..<numberOfMessagesToSend {
            currentSubMessage = "2"
            currentSubMessage += uppercase[i*19..<(i*19)+19]
            println(currentSubMessage)
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
        if (integerRange.endIndex > count(self)) {
            rangeEnd = count(self)
        }
        
        let start = advance(startIndex, integerRange.startIndex)
        let end = advance(startIndex, rangeEnd ?? integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
}

str.formatMessageForRFDuino()
