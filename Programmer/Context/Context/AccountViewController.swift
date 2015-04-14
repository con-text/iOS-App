//
//  AccountViewController.swift
//  nimble
//
//  Created by Denis Ogun on 14/04/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import CoreBluetooth

class AccountViewController: UIViewController, BluetoothManagerProtocol {
    
    let bluetoothManager = BluetoothManager.sharedInstance
    let accountManager = AccountManager()
    
    var writeChannel:CBCharacteristic?
    var disconnectChannel:CBCharacteristic?
    var currentPeripheral:CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bluetoothManager.delegate = self
        bluetoothManager.scanType = .Setup
        bluetoothManager.shouldScan = true
    }
    
    // MARK: Bluetooth delegates
    func discoveredNewDevice(peripheral: CBPeripheral!, readChannel: CBCharacteristic?, writeChannel: CBCharacteristic?, disconnectChannel: CBCharacteristic?) {
        // Grab references to the objects
        self.writeChannel = writeChannel
        self.disconnectChannel = disconnectChannel
        self.currentPeripheral = peripheral
        
        println("Found our device")
        let dataToSend:[String] = "Unlock".formatMessageForRFDuino()
        
        self.currentPeripheral!.sendData(dataToSend, writeChannel: self.writeChannel!)
    }
    
    func receivedMessageFromDevice(peripheral: CBPeripheral, message: String) {
        println("Received message " + message)
        
        // This will be the random number
        NetworkManager().encryptStageOne(accountManager.getUserID()!, plainText: message) { (result) -> () in
            println(result)
            let dataToSend = result!.formatMessageForRFDuino()
            self.currentPeripheral!.sendData(dataToSend, writeChannel: self.writeChannel!)
        }
    }
}
