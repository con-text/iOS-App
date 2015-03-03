//
//  BluetoothManager.swift
//  Context
//
//  Created by Denis Ogun on 26/02/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate {
   
    let bluetoothManager:CBCentralManager!
    let userServiceUUID = "2220"
    let readCharacteristicUUID = "2221"
    let writeCharacteristicUUID = "2222"

    var foundDevices = [CBPeripheral]()
    
    override init() {
        super.init()
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        foundDevices.append(peripheral)
        println(advertisementData)
        println(RSSI)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
            case .PoweredOn:
                var scanDictionary = [CBCentralManagerScanOptionAllowDuplicatesKey: true];
                bluetoothManager.scanForPeripheralsWithServices([CBUUID(string: userServiceUUID)], options:scanDictionary)
            case .Unsupported, .PoweredOff, .Resetting, .Unauthorized:
                println("Error with bluetooth")
            default:
                println("Unhandled bluetooth status")
        }
    }
}
