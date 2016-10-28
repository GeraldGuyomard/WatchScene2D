//
//  W2DScene.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 11/2/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit

open class W2DScene : W2DNode
{
    open var backgroundColor : W2DColor4f? = W2DColor4f(red: 0, green: 0, blue: 0)
    {
        didSet
        {
            setNeedsRedraw(false)
        }
    }
    
    override open func selfRender(_ context: W2DContext)
    {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        if let color = self.backgroundColor
        {
            if color.alpha == 0
            {
                context.clear(rect)
            }
            else
            {
                context.fillRect(rect, withColor:color)
            }
        }
        else
        {
            context.clear(rect)
        }
    }
    
    open func present()
    {
        setIsOnScreen(true)
    }
    
    open func discard()
    {
        setIsOnScreen(false)
    }
}
