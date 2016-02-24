//
//  W2DColoredNode.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 1/26/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import WatchKit

public class W2DColoredNode : W2DNode
{
    public var color : W2DColor4f?
    
    public init(color:W2DColor4f?, director:W2DDirector)
    {
        super.init(director: director)
        
        self.color = color
    }
    
    override public func selfRender(context: W2DContext)
    {
        if let color = self.color
        {
            let s = self.size
            let rect = CGRectMake(0, 0, s.width, s.height)
            context.fillRect(rect, withColor: color)
        }
    }
}