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
    required init(width:UInt, height:UInt)
    {
        super.init()
        
        fWidth = width
        fHeight = height
        
        let bufferSize = fWidth * fHeight * 4
        fBackBuffer = malloc(Int(bufferSize))
        //memset(m_BackBuffer, 0xFF, bufferSize);
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        
        fCGContext = CGBitmapContextCreate(fBackBuffer, Int(fWidth), Int(fHeight), 8, Int(fWidth * 4), rgbColorSpace, CGImageAlphaInfo.NoneSkipLast.rawValue)
    }
    
    deinit
    {
        
    }
    
    var width : UInt { return fWidth }
    var height : UInt { return fHeight }

    func clear(r r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat)
    {
        if r == 0 && g == 0 && b == 0 && a == 0
        {
            let size = fWidth * fHeight * 4
            memset(fBackBuffer, 0, Int(size))
        }
        else
        {
            CGContextSetRGBFillColor(fCGContext, r, g, b, a)
            let rect = CGRect(x: 0, y: 0, width:CGFloat(fWidth), height:CGFloat(fHeight))
            CGContextFillRect(fCGContext, rect)
        }
    }
    
    func draw(image image:UIImage?, atPosition pos:CGPoint)
    {
        if let img = image
        {
            let cgImage = img.CGImage;
            let rect = CGRect(x:pos.x, y:pos.y, width:CGFloat(CGImageGetWidth(cgImage)), height:CGFloat(CGImageGetHeight(cgImage)))
            
            CGContextDrawImage(fCGContext, rect, cgImage)
        }
    }
    
    func draw(image image:UIImage?, inRect rect:CGRect)
    {
        if let img = image
        {
            CGContextDrawImage(fCGContext, rect, img.CGImage)
        }
    }
    
    func render() -> UIImage?
    {
        if (fImage == nil)
        {
            let bufferSize : Int = Int(fWidth * fHeight * 4)
            let provider = CGDataProviderCreateWithData(nil, fBackBuffer, bufferSize, nil)
            
            let bitsPerComponent = CGBitmapContextGetBitsPerComponent (fCGContext)
            let bitsPerPixel = CGBitmapContextGetBitsPerPixel(fCGContext)
            let bytesPerRow = CGBitmapContextGetBytesPerRow(fCGContext)
            let colorSpace = CGBitmapContextGetColorSpace(fCGContext)
            
            fImage = CGImageCreate(Int(fWidth), Int(fHeight),
                bitsPerComponent,
                bitsPerPixel,
                bytesPerRow,
                colorSpace,
                CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue),
                provider,
                nil,
                false,
                .RenderingIntentDefault)
        }
        
        return UIImage(CGImage: fImage!)
    }
    
    private var    fBackBuffer : UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>();
    private var    fCGContext : CGContext?;
    private var    fWidth : UInt = 0;
    private var    fHeight : UInt = 0;
    private var    fImage : CGImage?;
    
}
