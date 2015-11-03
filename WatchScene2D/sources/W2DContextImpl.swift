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

    func clear(color:W2DColor4f)
    {
        if color.red == 0 && color.green == 0 && color.blue == 0 && color.alpha == 0
        {
            let size = fWidth * fHeight * 4
            memset(fBackBuffer, 0, Int(size))
        }
        else
        {
            CGContextSetRGBFillColor(fCGContext, color.red, color.green, color.blue, color.alpha)
            let rect = CGRect(x: 0, y: 0, width:CGFloat(fWidth), height:CGFloat(fHeight))
            CGContextFillRect(fCGContext, rect)
        }
    }
    
    func image(named name:String) -> W2DImage?
    {
        return W2DImageImpl(context:fCGContext!, named: name)
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
    
    func saveTranform()
    {
        CGContextSaveGState(fCGContext)
    }
    
    func restoreTransform()
    {
        CGContextRestoreGState(fCGContext)
    }
    
    func applyTransform(transform:CGAffineTransform)
    {
        CGContextConcatCTM(fCGContext, transform)
    }
    
    private var    fBackBuffer : UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>();
    private var    fCGContext : CGContext?;
    private var    fWidth : UInt = 0;
    private var    fHeight : UInt = 0;
    private var    fImage : CGImage?;
    
}
