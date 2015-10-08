//
//  W2DContextImpl.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/7/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

@objc internal class W2DContextImpl: NSObject, W2DContext
{
    required init(size:CGSize)
    {
        super.init()
        
        fSize = size
        
        let bufferSize = NSInteger(fSize.width) * NSInteger(fSize.height) * 4
        fBackBuffer = malloc(bufferSize)
        //memset(m_BackBuffer, 0xFF, bufferSize);
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        
        fCGContext = CGBitmapContextCreate(fBackBuffer, Int(fSize.width), Int(fSize.height), 8, Int(fSize.width) * 4, rgbColorSpace, CGImageAlphaInfo.NoneSkipLast.rawValue)
    }
    
    deinit
    {
        
    }
    
    func render()
    {
        
    }
    
    private var    fBackBuffer : UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>();
    private var    fCGContext : CGContext?;
    private var    fSize = CGSizeMake(0, 0);
    
}
