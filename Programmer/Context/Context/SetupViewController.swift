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
    
    let bluetoothManager  = BluetoothManager.sharedInstance

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
        peripheral.delegate = self
        println("Connected to new device")
        
        var dataToSend:[String] = "Setup".formatMessageForRFDuino()
        
        let userID = AccountManager().getUserID()
        dataToSend += userID!.formatMessageForRFDuino()
        
        for data in dataToSend {
            println("Sending " + data)
            peripheral.writeValue(data.dataUsingEncoding(NSUTF8StringEncoding), forCharacteristic: writeChannel, type: .WithoutResponse)
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
