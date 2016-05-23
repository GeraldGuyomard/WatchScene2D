//
//  W2DFadeToAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 2/27/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public class W2DFadeToAction : W2DSimpleFiniteDurationAction
{
    private var fInitialAlpha : CGFloat = 0.0
    private var fFinalAlpha : CGFloat
    
    public init(duration:NSTimeInterval, finalAlpha:CGFloat)
    {
        fFinalAlpha = finalAlpha
        
        super.init(duration: duration)
    }
    
    public override func start()
    {
        if let target = fTarget
        {
            fInitialAlpha = target.alpha
        }
        else
        {
            fInitialAlpha = 0
        }
        
        super.start()
    }
    
    public override func run(dT: NSTimeInterval, director: W2DDirector!)
    {
        if let target = self.target
        {
            let c = CGFloat(self.elapsedTime / self.duration)
            let alpha = CGFloat.lerp(fInitialAlpha, endValue: fFinalAlpha, coeff: c)
    
            target.alpha = alpha
        }
    }
}