//
//  SetupViewController.swift
//  nimble
//
//  Created by Denis Ogun on 24/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import CoreBluetooth

class SetupViewController: UIViewController, BluetoothManagerProtocol {
    
    let bluetoothManager  = BluetoothManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func discoveredNewDevice(device: CBPeripheral!, readChannel: CBCharacteristic?, writeChannel: CBCharacteristic?, disconnectChannel: CBCharacteristic?) {
        println("Connected to new device")
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
