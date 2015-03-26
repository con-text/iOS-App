//
//  ViewController.swift
//  Context
//
//  Created by Denis Ogun on 25/02/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit

import FacebookSDK

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var loginButton : FBLoginView!
    
    let accountManager = AccountManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loginButton.delegate = self;
        self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: Facebook delegates
    
    func loginView(loginView: FBLoginView!, handleError: NSError!) {
        println("Error: \(handleError.localizedDescription)")
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println("Got user data")
        println("User name: \(user.name)")
        println("User ID: \(user.objectID)")
        // Send the request to the server
        NetworkManager().CreateUser(user.objectID) { [unowned self] userID in
            println("Server user ID " + userID!)
            self.accountManager.setUserDetails(user.objectID, facebookName: user.name, userID: userID!)
            self.performSegueWithIdentifier("setupScreen", sender: self)
        }
        
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("User logged in")
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("User logged out")
    }
}

