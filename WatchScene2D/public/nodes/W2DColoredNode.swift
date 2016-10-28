//
//  W2DColoredNode.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 1/26/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import WatchKit

open class W2DColoredNode : W2DNode
{
    open var color : W2DColor4f?
    {
        didSet
        {
            setNeedsRedraw(false)
        }
    }
    
    public init(color:W2DColor4f?, director:W2DDirector)
    {
        super.init(director: director)
        
        self.color = color
    }
    
    override open func selfRender(_ context: W2DContext)
    {
        if let color = self.color
        {
            let s = self.size
            let rect = CGRect(x: 0, y: 0, width: s.width, height: s.height)
            context.fillRect(rect, withColor: color)
        }
    }
}
