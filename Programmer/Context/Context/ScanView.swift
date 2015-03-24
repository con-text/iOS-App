//
//  ScanView.swift
//  nimble
//
//  Created by Denis Ogun on 20/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit

class ScanView: UIView {

    let π = M_PI
    var currentArc = 0
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        // Draw in gray
        UIColor.lightGrayColor().setStroke()
        
        // Draw arcs
        var arcOne = UIBezierPath(arcCenter: CGPointMake(bounds.width/2, bounds.height/2), radius: 2*bounds.height/10, startAngle: CGFloat(5*π/4), endAngle: CGFloat(7*π/4), clockwise: true)
        arcOne.lineWidth = 4.0
        arcOne.stroke()
        
        var arcThree = UIBezierPath(arcCenter: CGPointMake(bounds.width/2, bounds.height/2), radius: 3*bounds.height/10, startAngle: CGFloat(5*π/4), endAngle: CGFloat(7*π/4), clockwise: true)
        arcThree.lineWidth = 4.0
        arcThree.stroke()
        
        UIColor.darkGrayColor().setStroke()
        
        var arcTwo = UIBezierPath(arcCenter: CGPointMake(bounds.width/2, bounds.height/2), radius: 4*bounds.height/10, startAngle: CGFloat(5*π/4), endAngle: CGFloat(7*π/4), clockwise: true)
        arcTwo.lineWidth = 4.0
        arcTwo.stroke()
    }
}
