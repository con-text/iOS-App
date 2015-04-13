//
//  BluetoothManager.swift
//  Context
//
//  Created by Denis Ogun on 26/02/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol BluetoothManagerProtocol {
    optional func discoveredNewDevice(peripheral: CBPeripheral!,
                        readChannel: CBCharacteristic?,
                       writeChannel: CBCharacteristic?,
                  disconnectChannel: CBCharacteristic?)
    
    optional func receivedMessageFromDevice(peripheral: CBPeripheral, message: String)
}

enum DeviceType {
    case Setup
    case NotSetup
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
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
   
    var bluetoothManager:CBCentralManager!
    var shouldScan: Bool {
        didSet {
            if shouldScan == true && self.bluetoothManager.state == .PoweredOn {
                startScan()
            }
        }
    }
    
    // Not setup UUIDs
    let notSetupUUID = "4E1F1FB0-95C9-4C54-88CB-6B9F3192CDD1"
    let notSetupReadCharacteristicUUID = "4E1F1FB1-95C9-4C54-88CB-6B9F3192CDD1"
    let notSetupWriteCharacteristicUUID = "4E1F1FB2-95C9-4C54-88CB-6B9F3192CDD1"
    let notSetupDisconnectCharacteristicUUID = "4E1F1FB3-95C9-4C54-88CB-6B9F3192CDD1"
    
    // Locked UUIDs
    let lockedUUID = "79E7C777-15B4-406A-84C2-DEB389EA85E1"
    let lockedReadCharacteristicUUID = "79E7C778-15B4-406A-84C2-DEB389EA85E1"
    let lockedWriteCharacteristicUUID = "79E7C779-15B4-406A-84C2-DEB389EA85E1"
    let lockedDisconnectCharacteristicUUID = "79E7C77A-15B4-406A-84C2-DEB389EA85E1"

    var currentDevice:(CBPeripheral, DeviceType)?
    var delegate:BluetoothManagerProtocol! = nil
    
    var readString:String = ""

    override init() {
        shouldScan = false
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
        
        // If we see a device called Nimble that hasn't been setup
        if advertisementData["kCBAdvDataLocalName"] as! String == "Nimble" {
            let manData:NSData? = advertisementData["kCBAdvDataManufacturerData"] as! NSData?
            let hexString = manData?.hexadecimalString()
            if (hexString! == "Nimble") {
                NSLog("Found a device that isn't setup")
                currentDevice = (peripheral, .NotSetup)
                bluetoothManager.stopScan()
                bluetoothManager.connectPeripheral(peripheral, options: nil)
            } else {
                NSLog("Found a device")
            }
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
            case .PoweredOn:
                if (shouldScan) {
                    startScan()
                }
            case .Unsupported, .PoweredOff, .Resetting, .Unauthorized:
                println("Error with bluetooth")
            default:
                println("Unhandled bluetooth status")
        }
    }
    
    func startScan() {
        println("Starting scan")
        var scanDictionary = [CBCentralManagerScanOptionAllowDuplicatesKey: true];
        bluetoothManager.scanForPeripheralsWithServices([CBUUID(string: notSetupUUID)], options:scanDictionary)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected to peripheral")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: notSetupUUID)])
    }
    
    // MARK: CBPeripheral
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        // Get the read and write characteristic channels
        for service in peripheral.services as! [CBService] {
            if service.UUID.UUIDString == notSetupUUID {
                peripheral.discoverCharacteristics([CBUUID(string: notSetupReadCharacteristicUUID),
                                                    CBUUID(string: notSetupWriteCharacteristicUUID),
                                                    CBUUID(string: notSetupDisconnectCharacteristicUUID)], forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        // Communication channels
        var readChannel:CBCharacteristic?
        var writeChannel:CBCharacteristic?
        var disconnectChannel:CBCharacteristic?
        
        
        for characteristic in service.characteristics as! [CBCharacteristic] {
            switch characteristic.UUID.UUIDString
            {
                case notSetupReadCharacteristicUUID:
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    readChannel = characteristic
                    break
                
                case notSetupWriteCharacteristicUUID:
                    writeChannel = characteristic
                    break
                
                case notSetupDisconnectCharacteristicUUID:
                    disconnectChannel = characteristic
                    break
                
                default:
                    // Don't do anything
                    break
            }
        }
        
        delegate?.discoveredNewDevice?(peripheral, readChannel: readChannel!, writeChannel: writeChannel!, disconnectChannel: disconnectChannel!)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        let dataString = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)
        let messageType = dataString!.substringToIndex(1)
        
        if (messageType == "1") {
            readString = ""
            readString += dataString!.substringFromIndex(1)
        } else if (messageType == "2"){
            readString += dataString!.substringFromIndex(1)
        } else if (messageType == "3" && (readString.isEmpty == false)) {
            delegate?.receivedMessageFromDevice?(peripheral, message: readString)
        }
    }
}
