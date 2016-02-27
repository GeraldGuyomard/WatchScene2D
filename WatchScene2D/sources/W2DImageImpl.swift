//
//  W2DImageImpl.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/18/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

internal class W2DImageImpl : W2DImage
{
    private var fCGContext : CGContextRef!
    private var fUIImage : UIImage?
    
    var size : CGSize
    {
        var s = fUIImage!.size
        let scale = fUIImage!.scale
        
        s.width *= scale
        s.height *= scale
        
        return s
    }
    
    init?(context:CGContextRef, named:String)
    {
        fCGContext = context
        
        if let img = UIImage(named: named)
        {
            fUIImage = img
        }
        else
        {
            return nil
        }
    }
    
    func draw(pos:CGPoint)
    {
        if let img = fUIImage
        {
            let cgImage = img.CGImage;
            let rect = CGRect(x:pos.x, y:pos.y, width:CGFloat(CGImageGetWidth(cgImage)), height:CGFloat(CGImageGetHeight(cgImage)))
            
            CGContextDrawImage(fCGContext, rect, cgImage)
        }
    }

    func draw(pos:CGPoint, alpha:CGFloat)
    {
        if (alpha == 1.0)
        {
            draw(pos)
        }
        else if (alpha != 0.0)
        {
            if let img = fUIImage
            {
                let cgImage = img.CGImage;
                let rect = CGRect(x:pos.x, y:pos.y, width:CGFloat(CGImageGetWidth(cgImage)), height:CGFloat(CGImageGetHeight(cgImage)))
                
                CGContextSaveGState(fCGContext)
                CGContextSetAlpha(fCGContext, alpha)
                CGContextDrawImage(fCGContext, rect, cgImage)
                CGContextRestoreGState(fCGContext)
            }
        }
    }
    
    func draw(rect:CGRect)
    {
        if let img = fUIImage
        {
            CGContextDrawImage(fCGContext, rect, img.CGImage)
        }
    }
    
    func draw(rect:CGRect, alpha:CGFloat)
    {
        if (alpha == 1.0)
        {
            draw(rect)
        }
        else if (alpha != 0.0)
        {
            if let img = fUIImage
            {
                CGContextSaveGState(fCGContext)
                CGContextSetAlpha(fCGContext, alpha)
                CGContextDrawImage(fCGContext, rect, img.CGImage)
                CGContextRestoreGState(fCGContext)
            }
        }
    }
}