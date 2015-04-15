//
//  FacebookProfile.swift
//  nimble
//
//  Created by Denis Ogun on 15/04/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FacebookProfile: FBSDKProfilePictureView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProfilePicture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProfilePicture()
    }
    
    func setProfilePicture() {
        if let profileID = FBSDKProfile.currentProfile() {
            self.profileID = profileID.userID
        }
        
        self.layer.cornerRadius = max(self.frame.size.width, self.frame.size.height)/2
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 3.0
        self.layer.masksToBounds = true
    }

}
