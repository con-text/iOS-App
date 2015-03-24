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
    
    /*TODO: With the release of Xcode 6.3 change this to
        class BluetoothManager {
            static let sharedInstance = BluetoothManager()
        }
    */
    class var sharedInstance : BluetoothManager {
        struct Static {
            static let instance : BluetoothManager = BluetoothManager()
        }
        return Static.instance
    }
   
    let bluetoothManager:CBCentralManager!
    let userServiceUUID = "2220"
    let readCharacteristicUUID = "2221"
    let writeCharacteristicUUID = "2222"

    var allFoundDevices = [CBPeripheral]()
    var unregisteredDevices = [CBPeripheral]()
    
    override init() {
        super.init()
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        /* Make sure it's a Nimble device. This should really be done by looking for a nimble service UUID
           but Benji doesn't want to change his code/is a bellend */
        if (RSSI.integerValue < -35) || (RSSI.integerValue > 0) {
            return
        }
        
        println(RSSI)
        
        if advertisementData["kCBAdvDataLocalName"] as NSString? == "Nimble" {
            allFoundDevices.append(peripheral)
            let manData:NSData? = advertisementData["kCBAdvDataManufacturerData"] as NSData?
            let hexString = manData?.hexadecimalString()
            println(hexString!)
            if (hexString! == "Nimble") {
                println("Found a device that isn't setup")
                unregisteredDevices.append(peripheral);
            } else {
                println("Found a device")
            }
        }
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
