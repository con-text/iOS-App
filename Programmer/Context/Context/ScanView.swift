//
//  ScanView.swift
//  nimble
//
//  Created by Denis Ogun on 20/03/2015.
//  Copyright (c) 2015 Denis Ogun. All rights reserved.
//

import UIKit

class ScanView: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()

        CGContextSaveGState(context)
        
        // Set the line width
        CGContextSetLineWidth(context, 4)
        // Set the colour
        var color : Color = UIColor(netHex: 0xaaa9aa).getRGB()
        CGContextSetRGBStrokeColor(context, color.red, color.green, color.blue, 1.0)
        
        // Draw the bluetooth logo
        var bluetoothImage = UIImage(named: "Bluetooth")
        let centerPoint = CGPoint(x: CGRectGetMidX(bounds) - bluetoothImage!.size.width/2.0, y: CGRectGetMidY(bounds) - bluetoothImage!.size.height/2.0)
        bluetoothImage?.drawAtPoint(centerPoint)
        
        // Draw the circle
        CGContextAddArc(context, CGRectGetMidX(bounds), CGRectGetMidY(bounds), 50.0, 0, CGFloat(M_PI*2), 1)
        CGContextStrokePath(context)
        CGContextAddArc(context, CGRectGetMidX(bounds), CGRectGetMidY(bounds), 80.0, 0, CGFloat(M_PI*2), 1)
        CGContextStrokePath(context)
        color = UIColor(netHex: 0x9e9e9f).getRGB()
        CGContextSetRGBStrokeColor(context, color.red, color.green, color.blue, 1.0)
        CGContextAddArc(context, CGRectGetMidX(bounds), CGRectGetMidY(bounds), 65.0, 0, CGFloat(M_PI*2), 1)
        CGContextStrokePath(context)
    }
}
