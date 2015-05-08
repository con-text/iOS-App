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
    var scanType : DeviceType? {
        didSet {
            self.bluetoothManager.stopScan()
            let currentShouldScan = self.shouldScan
            self.shouldScan = currentShouldScan
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
        
        if (scanType == .NotSetup) {
            if (RSSI.integerValue < -35) || (RSSI.integerValue > 0) {
                return
            }
        }
        
        println(advertisementData)
        
        if (scanType == .Setup) {
            let serviceUUIDs = advertisementData["kCBAdvDataServiceUUIDs"] as! NSArray
            if serviceUUIDs.count > 1 {
                println("Too many service UUIDs, ignoring")
                self.invalidateDatabase(peripheral)
                return
            }
        }
        
        println(RSSI)
        
        // If we see a device called Nimble, then it's a device that hasn't been setup
        if advertisementData["kCBAdvDataLocalName"] as! String == "Nimble" {
            let manData:NSData? = advertisementData["kCBAdvDataManufacturerData"] as! NSData?
            let hexString = manData?.hexadecimalString()
            if (hexString! == "Nimble") && scanType == .NotSetup {
                println("Found a device that isn't setup")
                currentDevice = (peripheral, .NotSetup)
                bluetoothManager.stopScan()
                bluetoothManager.connectPeripheral(peripheral, options: nil)
            }
            
            if (hexString == AccountManager().getUserID()) && scanType == .Setup {
                println("Found our device with UUID " + hexString!)
                currentDevice = (peripheral, .Setup)
                bluetoothManager.stopScan()
                bluetoothManager.connectPeripheral(peripheral, options: nil)
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
        var scanDictionary = [CBCentralManagerScanOptionAllowDuplicatesKey: true];
        if scanType == .NotSetup {
            println("Starting scan for new devices")
            bluetoothManager.scanForPeripheralsWithServices([CBUUID(string: notSetupUUID)], options:scanDictionary)
        } else if scanType == .Setup {
            println("Starting scan for locked devices")
            bluetoothManager.scanForPeripheralsWithServices([CBUUID(string: lockedUUID)], options:scanDictionary)
        }
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected to peripheral")
        peripheral.delegate = self
        if scanType == .NotSetup {
            peripheral.discoverServices([CBUUID(string: notSetupUUID)])
        } else if scanType == .Setup {
            peripheral.discoverServices([CBUUID(string: lockedUUID)])
        }
    }
    
    // MARK: CBPeripheral
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        // Get the read and write characteristic channels
        for service in peripheral.services as! [CBService] {
            if service.UUID.UUIDString == notSetupUUID {
                peripheral.discoverCharacteristics([CBUUID(string: notSetupReadCharacteristicUUID),
                                                    CBUUID(string: notSetupWriteCharacteristicUUID),
                                                    CBUUID(string: notSetupDisconnectCharacteristicUUID)], forService: service)
            } else if service.UUID.UUIDString == lockedUUID {
                peripheral.discoverCharacteristics([CBUUID(string: lockedReadCharacteristicUUID),
                                                    CBUUID(string: lockedWriteCharacteristicUUID),
                                                    CBUUID(string: lockedDisconnectCharacteristicUUID)], forService: service)
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
                
                case lockedReadCharacteristicUUID:
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    readChannel = characteristic
                    break
                
                case lockedWriteCharacteristicUUID:
                    writeChannel = characteristic
                    break
                
                case lockedDisconnectCharacteristicUUID:
                    disconnectChannel = characteristic
                    break
                
                default:
                    // Don't do anything
                    println("Unknown characteristic")
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
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Disconnected from peripheral")
        self.currentDevice = nil
    }
    
    func invalidateDatabase(peripheral: CBPeripheral!) {
        let selector = Selector("invalidateAllAttributes")
        if peripheral!.respondsToSelector(selector) {
            println("Invalidating")
            peripheral!.swift_performSelector(selector)
        }
    }
    
    func reconnectToPeripheral(peripheral: CBPeripheral!) {
        self.bluetoothManager.connectPeripheral(peripheral, options: nil)
    }
}
