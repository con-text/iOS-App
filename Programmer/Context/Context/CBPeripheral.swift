//
//  CBPeripheral.swift
//  nimble
//
//  Created by Denis Ogun on 14/04/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheral {
    
    func sendData(dataToSend:[String], writeChannel: CBCharacteristic) {
        for data in dataToSend {
            println("Sending " + data)
            self.writeValue(data.dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: writeChannel, type:.WithoutResponse)
        }
    }
}
