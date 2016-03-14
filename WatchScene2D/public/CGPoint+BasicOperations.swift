//
//  CGPoint+BasicOperations.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/17/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

public extension CGPoint
{
    func norm() -> CGFloat
    {
        if x == 0
        {
            return abs(y)
        }
        else if y == 0
        {
            return abs(x)
        }
        else
        {
            return CGFloat(sqrtf(Float((x * x) + (y * y))));
        }
    }
    
    func squareNorm() -> CGFloat
    {
        return (x * x) + (y * y);
    }
    
    func opposite() -> CGPoint
    {
        return CGPointMake(-x, -y)
    }
    
    func normalizedVector() -> CGPoint
    {
        let l = norm();
        if l == 0
        {
            return CGPointMake(0, 0);
        }
        
        return CGPointMake(x / l, y / l);
    }
    
    func add(other: CGPoint) -> CGPoint
    {
        return CGPointMake(x + other.x, y + other.y)
    }

    func sub(other: CGPoint) -> CGPoint
    {
        return CGPointMake(x - other.x, y - other.y)
    }
    
    func mul(f : CGFloat) -> CGPoint
    {
        return CGPointMake(x * f, y * f);
    }
    
    func dot(other:CGPoint) -> CGFloat
    {
        return (x * other.x) + (y * other.y)
    }
}
