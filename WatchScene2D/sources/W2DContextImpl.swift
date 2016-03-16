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
        
        let size = self.bufferSize
        fBackBuffer = malloc(size)
        memset(fBackBuffer, 0, size)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        
        fCGContext = CGBitmapContextCreate(fBackBuffer, Int(fWidth), Int(fHeight), 8, Int(fWidth * 4), rgbColorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        //CGContextSetInterpolationQuality(fCGContext, .None)
        CGContextSetInterpolationQuality(fCGContext, .Low)
    }
    
    deinit
    {
        free(fBackBuffer)
    }
    
    var width : UInt { return fWidth }
    var height : UInt { return fHeight }
    var clippingRect : CGRect?
    {
        return fClippingRect
    }
    
    var bufferSize : Int
    {
        get { return Int(fWidth * fHeight * 4) }
    }
    
    func clear(rect:CGRect)
    {
        CGContextClearRect(fCGContext, rect)
    }
    
    func fillRect(rect:CGRect, withColor color:W2DColor4f)
    {
        if color.alpha != 0
        {
            CGContextSetRGBFillColor(fCGContext, color.red, color.green, color.blue, color.alpha)
            CGContextFillRect(fCGContext, rect)
        }
    }
    
    func image(named name:String) -> W2DImage?
    {
        return W2DImageImpl(context:fCGContext!, named: name)
    }
    
    private func createCGImage(backBuffer: UnsafeMutablePointer<Void>) -> CGImage?
    {
        let provider = CGDataProviderCreateWithData(nil, backBuffer, self.bufferSize, nil)
        
        let bitsPerComponent = CGBitmapContextGetBitsPerComponent (fCGContext)
        let bitsPerPixel = CGBitmapContextGetBitsPerPixel(fCGContext)
        let bytesPerRow = CGBitmapContextGetBytesPerRow(fCGContext)
        let colorSpace = CGBitmapContextGetColorSpace(fCGContext)
        
        let cgImage = CGImageCreate(Int(fWidth), Int(fHeight),
            bitsPerComponent,
            bitsPerPixel,
            bytesPerRow,
            colorSpace,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue),
            provider,
            nil,
            false,
            .RenderingIntentDefault)
        
        return cgImage
    }
    
    func render() -> UIImage?
    {
        if (fImage == nil)
        {
            fImage = createCGImage(fBackBuffer)
        }
        
        return UIImage(CGImage: fImage!)
    }
    
    func render(dirtyRects: [CGRect]?) -> UIImage?
    {
        if let rects = dirtyRects
        {
            let newContext = W2DContextImpl(width: fWidth, height: fHeight)
            memcpy(newContext.fBackBuffer, fBackBuffer, self.bufferSize)
            
            let color = W2DColor4f(red: 1, green: 0, blue: 0, alpha: 0.5)
            for r in rects
            {
                newContext.fillRect(r, withColor: color)
            }
            
            return newContext.render()
        }
        else
        {
            return self.render()
        }
    }
    
    func saveState()
    {
        CGContextSaveGState(fCGContext)
    }
    
    func restoreState()
    {
        CGContextRestoreGState(fCGContext)
    }
    
    func applyTransform(transform:CGAffineTransform)
    {
        CGContextConcatCTM(fCGContext, transform)
    }
    
    func applyClipping(rect:CGRect)
    {
        CGContextClipToRect(fCGContext, rect)
        fClippingRect = rect
    }
    
    private var    fBackBuffer : UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>();
    private var    fCGContext : CGContext?;
    private var    fWidth : UInt = 0;
    private var    fHeight : UInt = 0;
    private var    fClippingRect : CGRect? = nil
    private var    fImage : CGImage?
    
}
