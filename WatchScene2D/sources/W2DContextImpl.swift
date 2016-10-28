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
        
        fCGContext = CGContext(data: fBackBuffer, width: Int(fWidth), height: Int(fHeight), bitsPerComponent: 8, bytesPerRow: Int(fWidth * 4), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        //CGContextSetInterpolationQuality(fCGContext, .None)
        fCGContext!.interpolationQuality = .low
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
    
    func clear(_ rect:CGRect)
    {
        fCGContext?.clear(rect)
    }
    
    func fillRect(_ rect:CGRect, withColor color:W2DColor4f)
    {
        if color.alpha != 0
        {
            fCGContext?.setFillColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
            fCGContext?.fill(rect)
        }
    }
    
    func image(named name:String) -> W2DImage?
    {
        return W2DImageImpl(context:fCGContext!, named: name)
    }
    
    fileprivate func createCGImage(_ backBuffer: UnsafeMutableRawPointer) -> CGImage?
    {
        let releaseCallback: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
        }
        
        let provider = CGDataProvider(dataInfo: nil, data: backBuffer, size: self.bufferSize, releaseData: releaseCallback)
        
        if let cgContext = fCGContext
        {
            let bitsPerComponent = cgContext.bitsPerComponent
            let bitsPerPixel = cgContext.bitsPerPixel
            let bytesPerRow = cgContext.bytesPerRow
            let colorSpace = cgContext.colorSpace
            
            let cgImage = CGImage(width: Int(fWidth), height: Int(fHeight),
                                  bitsPerComponent: bitsPerComponent,
                                  bitsPerPixel: bitsPerPixel,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace!,
                                  bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                  provider: provider!,
                                  decode: nil,
                                  shouldInterpolate: false,
                                  intent: .defaultIntent)
            
            return cgImage
        }
        else
        {
            return nil
        }
    }
    
    func render() -> UIImage?
    {
        if (fImage == nil)
        {
            fImage = createCGImage(fBackBuffer!)
        }
        
        return UIImage(cgImage: fImage!)
    }
    
    func render(_ dirtyRects: [CGRect]?) -> UIImage?
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
        fCGContext?.saveGState()
    }
    
    func restoreState()
    {
        fCGContext?.restoreGState()
    }
    
    func applyTransform(_ transform:CGAffineTransform)
    {
        fCGContext?.concatenate(transform)
    }
    
    func applyClipping(_ rect:CGRect)
    {
        fCGContext?.clip(to: rect)
        fClippingRect = rect
    }
    
    fileprivate var    fBackBuffer : UnsafeMutableRawPointer?;
    fileprivate var    fCGContext : CGContext?;
    fileprivate var    fWidth : UInt = 0;
    fileprivate var    fHeight : UInt = 0;
    fileprivate var    fClippingRect : CGRect? = nil
    fileprivate var    fImage : CGImage?
    
}
