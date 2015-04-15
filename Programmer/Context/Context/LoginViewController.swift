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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if accountManager.isSetup() == true || 1 == 1 {
            println("Performing segue")
            self.performSegueWithIdentifier("showAccount", sender: self)
            return
        }
        
        // Do any additional setup after loading the view, typically from a nib
        bluetoothManager.scanType = .NotSetup
        bluetoothManager.delegate = self
        
        loginButton.readPermissions = ["public_profile"]
        if FBSDKAccessToken.currentAccessToken() != nil {
            onProfileUpdated(nil)
        }
        
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
    
    func onProfileUpdated(notification : NSNotification?) {
        let userName = FBSDKProfile.currentProfile().name
        let userID = FBSDKProfile.currentProfile().userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        println("Got user data")
        println("User's name: \(userName)")
        println("User ID: \(userID)")
        println("Token: \(accessToken)")
        
        NetworkManager().createUser(userID, accessToken: accessToken) { [unowned self] nimbleID in
            println("Server user ID " + nimbleID!)
            self.accountManager.setUserDetails(userID, facebookName: userName, userID: nimbleID!)
            self.scrollToPage(1, animated:true)
            self.bluetoothManager.shouldScan = true
        }
    }
    
    // MARK: Scrollview
    
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        self.scrollView.scrollRectToVisible(frame, animated: animated)
        pageControl.currentPage = page
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
        
        self.currentPeripheral!.sendData(dataToSend, writeChannel: self.writeChannel!)
    }
    
    func receivedMessageFromDevice(peripheral: CBPeripheral, message: String) {
        println("Received message " + message)
        if (message == "OK") {
            let userID = accountManager.getUserID()
            let dataToSend = userID!.formatMessageForRFDuino()
            println(userID)
            self.currentPeripheral!.sendData(dataToSend, writeChannel: self.writeChannel!)
        } else {
            // This will be the serial number from the device
            NetworkManager().linkDevice(message, userID: accountManager.getUserID()!, completionHandler: { (result) -> () in
                println(result)
                if (result == "Success") {
                    self.currentPeripheral!.sendData("OK".formatMessageForRFDuino(), writeChannel: self.writeChannel!)
                    self.scrollToPage(2, animated: true)
                    self.accountManager.becomeSetup()
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("showAccount", sender: self)
                    }
                }
            })
        }
    }
}

