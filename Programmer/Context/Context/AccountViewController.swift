//
//  AccountViewController.swift
//  nimble
//
//  Created by Denis Ogun on 14/04/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import CoreBluetooth
import FBSDKCoreKit
import MapKit

class AccountViewController: UIViewController, BluetoothManagerProtocol {
    
    let bluetoothManager = BluetoothManager.sharedInstance
    let accountManager = AccountManager()
    
    var writeChannel:CBCharacteristic?
    var disconnectChannel:CBCharacteristic?
    var currentPeripheral:CBPeripheral?
    
    @IBOutlet var profilePic : FacebookProfile!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet var timeLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bluetoothManager.delegate = self
        bluetoothManager.scanType = .Setup
        bluetoothManager.shouldScan = true
        
        setName()
        updateLastLocation()
        
        self.map.layer.borderWidth = 2.0
        self.map.layer.borderColor = UIColor.darkGrayColor().CGColor
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        
        if (message == "OK") {
            // Disconnect
            var flag : NSInteger  = 1
            let data = NSData(bytes: &flag, length: sizeofValue(flag))
            self.currentPeripheral?.writeValue(data, forCharacteristic: disconnectChannel, type: .WithoutResponse)
            // This will remove all the cached attributes...
            self.bluetoothManager.invalidateDatabase(self.currentPeripheral)
            self.currentPeripheral = nil
            // And restart scanning
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.restartScan()
            }
        } else {
            // This will be the random number
            NetworkManager().encryptStageOne(accountManager.getUserID()!, plainText: message) { (result) -> () in
                println(result)
                let dataToSend = result!.formatMessageForRFDuino()
                self.currentPeripheral!.sendData(dataToSend, writeChannel: self.writeChannel!)
            }
        }
    }
    
    func restartScan() {
        bluetoothManager.startScan()
    }
    
    func setName() {
        
        let currentTime = getCurrentTime()
        var name = "Person"
        
        if let profileID = FBSDKProfile.currentProfile() {
            name = profileID.firstName
        }
        
        nameLabel.text = currentTime! + name
    }
    
    func getCurrentTime() -> String? {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour, fromDate:  NSDate())
        let currentHour = components.hour // You can play around with the ""components""
        
        switch (currentHour) {
            case 0..<12:
                return "Good Morning "
            
            case 12..<18:
                return "Good Afternoon "
            
            case 18..<24:
                return "Good Evening "
            
            default:
                println("Error: Unknown time")
                return ""
        }
    }
    
    func updateLastLocation() {
        NetworkManager().getLastLocation(accountManager.getUserID()!, completionHandler: { (lat, lon, lastTime) -> () in
            
            let location = CLLocationCoordinate2DMake(lat!, lon!)
            let span =  MKCoordinateSpanMake(0.005,0.005)
            let region = MKCoordinateRegion(center: location, span: span)
            
            self.map.setRegion(region, animated: true)
            
            let date = NSDate(timeIntervalSince1970: lastTime!)
            self.timeLabel.text = date.timeAgo
        })
    }
}
