//
//  AddNewViewController.swift
//  nimble
//
//  Created by Denis Ogun on 04/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit

class AddNewViewController: UIViewController {
    
    let accountManager = AccountManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Add new"
        
        var accountDetails = accountManager.getUserFacebookDetails()
        println("Facebook ID:\(accountDetails.0)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
