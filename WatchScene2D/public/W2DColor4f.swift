//
//  W2DColor4f.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 11/2/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

public struct W2DColor4f
{
    public var red = CGFloat(0.0)
    public var green = CGFloat(0.0)
    public var blue = CGFloat(0.0)
    public var alpha = CGFloat(0.0)
    
    public init()
    {}

    public init(red r:CGFloat, green g:CGFloat, blue b:CGFloat)
    {
        self.init(red:r, green:g, blue:b, alpha:1)
    }
    
    public init(red r:CGFloat, green g:CGFloat, blue b:CGFloat, alpha a:CGFloat)
    {
        self.red = r
        self.blue = b
        self.green = g
        self.alpha = a
    }
}