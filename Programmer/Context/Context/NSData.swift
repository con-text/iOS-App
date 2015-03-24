//
//  NSData.swift
//  nimble
//
//  Created by Denis Ogun on 24/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import Foundation

extension NSData {
    
    func hexadecimalString() -> String {
        var string = NSMutableString(capacity: length * 2)
        var byte: Byte?

        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            if (byte != nil) {
                var tempString = NSString(data: NSData(bytes: &byte, length: 1), encoding: NSASCIIStringEncoding)
                string.appendString(tempString!)
            }
        }
        
        return string
    }
}