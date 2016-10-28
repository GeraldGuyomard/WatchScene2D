//
//  W2DScaleToAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 3/13/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DScaleToAction : W2DSimpleFiniteDurationAction
{
    fileprivate var fInitialScale = CGPoint(x: 0, y: 0)
    fileprivate var fFinalScale : CGPoint
    
    public init(duration:TimeInterval, finalScale:CGFloat)
    {
        fFinalScale = CGPoint(x: finalScale, y: finalScale)
        
        super.init(duration: duration)
    }

    public init(duration:TimeInterval, finalScale:CGPoint)
    {
        fFinalScale = finalScale
        
        super.init(duration: duration)
    }
    
    open override func start()
    {
        if let target = fTarget
        {
            fInitialScale = target.scaleXY
        }
        
        super.start()
    }
    
    open override func run(_ dT: TimeInterval, director: W2DDirector!)
    {
        if let target = self.target
        {
            let c = CGFloat(self.elapsedTime / self.duration)
            
            target.scaleXY = CGPoint.lerp(fInitialScale, endValue:fFinalScale, coeff:c)
        }
    }
}
