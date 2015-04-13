//
//  ViewController.swift
//  Context
//
//  Created by Denis Ogun on 25/02/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import CoreBluetooth
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UIScrollViewDelegate, BluetoothManagerProtocol, CBPeripheralDelegate  {
    
    @IBOutlet var loginButton : FBSDKLoginButton!
    @IBOutlet var scanView : ScanView!
    @IBOutlet var scanningText: UILabel!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var pageControl : UIPageControl!
    
    let bluetoothManager = BluetoothManager.sharedInstance
    
    var writeChannel:CBCharacteristic?
    var disconnectChannel:CBCharacteristic?
    var currentPeripheral:CBPeripheral?
    
    let accountManager = AccountManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       // self.loginButton.delegate = self;
       // self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        bluetoothManager.delegate = self
        
        loginButton.readPermissions = ["public_profile"]
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onProfileUpdated:", name:FBSDKProfileDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: Facebook delegates
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error != nil) {
            println(error.localizedDescription)
        } else if result.isCancelled {
            println("cancelled")
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("Logged out")
    }
    
    func onProfileUpdated(notification : NSNotification) {
        println("Got user data")
        let userName = FBSDKProfile.currentProfile().name
        let userID = FBSDKProfile.currentProfile().userID
        println("User's name: \(FBSDKProfile.currentProfile().name)")
        println("User ID: \(FBSDKProfile.currentProfile().userID)")
        
        NetworkManager().createUser(userID) { [unowned self] nimbleID in
            println("Server user ID " + nimbleID!)
            self.accountManager.setUserDetails(userID, facebookName: userName, userID: nimbleID!)
            self.scrollToPage(1, animated:true)
        }
    }
    
    // MARK: Scrollview
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = scrollView.currentPage()
    }
    
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        self.scrollView.scrollRectToVisible(frame, animated: animated)
    }
    
    // MARK: Bluetooth delegates
    func discoveredNewDevice(peripheral: CBPeripheral!, readChannel: CBCharacteristic?, writeChannel: CBCharacteristic?, disconnectChannel: CBCharacteristic?) {
        // Change the text
        self.scanningText.text = "Setting up device..."
        self.scanView.scanning = false
        self.scanView.setNeedsDisplay()
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
            println(userID)
            sendData(dataToSend)
        } else {
            // This will be the serial number from the device
            NetworkManager().linkDevice(message, userID: AccountManager().getUserID()!, completionHandler: { (result) -> () in
                println(result)
                if (result == "Success") {
                    self.sendData("OK".formatMessageForRFDuino())
                    self.scrollToPage(2, animated: true)
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
}

