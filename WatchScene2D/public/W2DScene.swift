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
    public var backgroundColor = W2DColor4f()
    
    override public func selfRender(context: W2DContext)
    {
        context.clear(self.backgroundColor)
    }
}
