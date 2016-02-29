//
//  W2DScene.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 11/2/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit

public class W2DScene : W2DNode
{
    public var backgroundColor = W2DColor4f(red: 0, green: 0, blue: 0)
    {
        didSet
        {
            setNeedsRedraw(false)
        }
    }
    
    override public func selfRender(context: W2DContext)
    {
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        
        let c = self.backgroundColor
        if c.alpha != 1
        {
            context.clear(rect)
        }
        
        if c.alpha != 0
        {
            context.fillRect(rect, withColor: c)
        }
    }
    
    public func present()
    {
        setIsOnScreen(true)
    }
    
    public func discard()
    {
        setIsOnScreen(false)
    }
}
