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
    func isNear(_ other:CGPoint) -> Bool
    {
        return x.isNear(other.x) && y.isNear(other.y)
    }
    
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
        return CGPoint(x: -x, y: -y)
    }
    
    func normalizedVector() -> CGPoint
    {
        let l = norm();
        if l == 0
        {
            return CGPoint(x: 0, y: 0);
        }
        
        return CGPoint(x: x / l, y: y / l);
    }
    
    func add(_ other: CGPoint) -> CGPoint
    {
        return CGPoint(x: x + other.x, y: y + other.y)
    }

    func sub(_ other: CGPoint) -> CGPoint
    {
        return CGPoint(x: x - other.x, y: y - other.y)
    }
    
    func mul(_ f : CGFloat) -> CGPoint
    {
        return CGPoint(x: x * f, y: y * f);
    }
    
    func dot(_ other:CGPoint) -> CGFloat
    {
        return (x * other.x) + (y * other.y)
    }
    
    static func lerp(_ startValue:CGPoint, endValue:CGPoint, coeff:CGFloat) -> CGPoint
    {
        return CGPoint(x: CGFloat.lerp(startValue.x, endValue:endValue.x, coeff:coeff), y: CGFloat.lerp(startValue.y, endValue:endValue.y, coeff:coeff))
    }
    
    static func symmetry(_ axis:CGPoint, point:CGPoint) -> CGPoint
    {
        let normalizedAxis = axis.normalizedVector()
        
        let m00 = (normalizedAxis.x * normalizedAxis.x) - (normalizedAxis.y * normalizedAxis.y)
        let m10 = 2 * normalizedAxis.x * normalizedAxis.y
        let m01 = m10
        let m11 = -m00
        
        let symX = (m00 * point.x) + (m01 * point.y)
        let symY = (m10 * point.x) + (m11 * point.y)
        
        return CGPoint(x: symX, y: symY)
    }
}
