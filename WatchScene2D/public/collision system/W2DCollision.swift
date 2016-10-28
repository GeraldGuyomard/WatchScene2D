//
//  Collision.swift
//  WatchPong
//
//  Created by Gérald Guyomard on 1/17/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public struct W2DCollision
{
    public var hitNode : W2DNode!
    public var hitPoint : CGPoint
    
    public var movingNode: W2DNode!
    
    public var bounceDirection : CGPoint
    public var bounceSpeedFactor: CGFloat
    
    public var edgeIndex : UInt
    public var distanceToEdge : CGFloat
    public var edgeNormal: CGPoint
    
    public func closerThan(_ collision:W2DCollision?) -> Bool
    {
        if let c = collision
        {
            return distanceToEdge < c.distanceToEdge
        }
        else
        {
            return true
        }
    }
}
