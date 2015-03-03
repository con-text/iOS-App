//
//  ViewController.swift
//  Context
//
//  Created by Denis Ogun on 25/02/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var loginButton : FBLoginView!

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
        var userEmail = user.objectForKey("email") as String
        println("User email: \(userEmail)")
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("User logged in")
        self.performSegueWithIdentifier(<#identifier: String?#>, sender: <#AnyObject?#>)
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("User logged out")
    }
}

