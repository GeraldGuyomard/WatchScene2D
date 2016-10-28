//
//  CGFloat+MathematicOperations.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 3/15/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public extension CGFloat
{
    public static func lerp(_ startValue:CGFloat, endValue:CGFloat, coeff:CGFloat) -> CGFloat
    {
        return startValue * (1.0 - coeff) + (endValue * coeff)
    }
    
    public func isNear(_ other:CGFloat) -> Bool
    {
        return abs(self - other) < 1e-3
    }
}
