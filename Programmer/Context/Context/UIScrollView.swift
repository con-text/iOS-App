//
//  UIScrollView.swift
//  nimble
//
//  Created by Denis Ogun on 09/04/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import Foundation

extension UIScrollView {
    
    func currentPage() -> Int {
        let pageWidth = self.frame.size.width
        return Int(floor((self.contentOffset.x - pageWidth/2) / pageWidth)) + 1
    }
}
