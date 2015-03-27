//
//  SetupViewController.swift
//  nimble
//
//  Created by Denis Ogun on 24/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import CoreBluetooth

class SetupViewController: UIViewController, BluetoothManagerProtocol, CBPeripheralDelegate {
    
    let bluetoothManager = BluetoothManager.sharedInstance
    
    var writeChannel:CBCharacteristic?
    var disconnectChannel:CBCharacteristic?
    var currentPeripheral:CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bluetoothManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func discoveredNewDevice(peripheral: CBPeripheral!, readChannel: CBCharacteristic?, writeChannel: CBCharacteristic?, disconnectChannel: CBCharacteristic?) {
        // Grab references to the objects
        self.writeChannel = writeChannel
        self.disconnectChannel = disconnectChannel
        self.currentPeripheral = peripheral
        
        println("Connected to a new device")
        let dataToSend:[String] = "Setup".formatMessageForRFDuino()
        
        sendData(dataToSend)
    }
    
    func receivedMessageFromDevice(peripheral: CBPeripheral, message: String) {
        println("Received message " + message)
        if (message == "OK") {
            let userID = AccountManager().getUserID()
            let dataToSend = userID!.formatMessageForRFDuino()
            sendData(dataToSend)
        } else {
            // This will be the serial number from the device
            NetworkManager().linkDevice(message, userID: AccountManager().getUserID()!, completionHandler: { (result) -> () in
                println(result)
                if (result == "Success") {
                    self.sendData("OK".formatMessageForRFDuino())
                }
            })
        }
    }
    
    func sendData(dataToSend:[String]) {
        for data in dataToSend {
            println("Sending " + data)
            currentPeripheral?.writeValue(data.dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: self.writeChannel, type:.WithoutResponse)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
