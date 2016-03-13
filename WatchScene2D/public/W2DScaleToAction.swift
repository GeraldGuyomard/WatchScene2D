//
//  W2DScaleToAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 3/13/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public class W2DScaleToAction : W2DFiniteDurationAction
{
    private var fInitialScale = CGPointMake(0, 0)
    private var fFinalScale : CGPoint
    
    public init(duration:NSTimeInterval, finalScale:CGFloat)
    {
        fFinalScale = CGPointMake(finalScale, finalScale)
        
        super.init(duration: duration)
    }

    public init(duration:NSTimeInterval, finalScale:CGPoint)
    {
        fFinalScale = finalScale
        
        super.init(duration: duration)
    }
    
    public override func start()
    {
        if let target = fTarget
        {
            fInitialScale = target.scaleXY
        }
        
        super.start()
    }
    
    public override func run(director: W2DDirector!)
    {
        if let target = self.target
        {
            let c = CGFloat(self.elapsedTime / self.duration)
            
            let x = fInitialScale.x * (1.0 - c) + (fFinalScale.x * c)
            let y = fInitialScale.y * (1.0 - c) + (fFinalScale.y * c)
            
            target.scaleXY = CGPointMake(x, y)
        }
    }
}