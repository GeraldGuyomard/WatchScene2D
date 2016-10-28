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
    fileprivate var fCGContext : CGContext!
    fileprivate var fUIImage : UIImage?
    
    var size : CGSize
    {
        var s = fUIImage!.size
        let scale = fUIImage!.scale
        
        s.width *= scale
        s.height *= scale
        
        return s
    }
    
    init?(context:CGContext, named:String)
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
    
    func draw(_ pos:CGPoint)
    {
        if let img = fUIImage
        {
            let cgImage = img.cgImage;
            let rect = CGRect(x:pos.x, y:pos.y, width:CGFloat((cgImage?.width)!), height:CGFloat((cgImage?.height)!))
            
            fCGContext.draw(cgImage!, in: rect)
        }
    }

    func draw(_ pos:CGPoint, alpha:CGFloat)
    {
        if (alpha == 1.0)
        {
            draw(pos)
        }
        else if (alpha != 0.0)
        {
            if let img = fUIImage
            {
                let cgImage = img.cgImage;
                let rect = CGRect(x:pos.x, y:pos.y, width:CGFloat((cgImage?.width)!), height:CGFloat((cgImage?.height)!))
                
                fCGContext.saveGState()
                fCGContext.setAlpha(alpha)
                fCGContext.draw(cgImage!, in: rect)
                fCGContext.restoreGState()
            }
        }
    }
    
    func draw(_ rect:CGRect)
    {
        if let img = fUIImage
        {
            fCGContext.draw(img.cgImage!, in: rect)
        }
    }
    
    func draw(_ rect:CGRect, alpha:CGFloat)
    {
        if (alpha == 1.0)
        {
            draw(rect)
        }
        else if (alpha != 0.0)
        {
            if let img = fUIImage
            {
                fCGContext.saveGState()
                fCGContext.setAlpha(alpha)
                fCGContext.draw(img.cgImage!, in: rect)
                fCGContext.restoreGState()
            }
        }
    }
}
