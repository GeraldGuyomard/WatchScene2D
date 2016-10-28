//
//  W2DFadeToAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 2/27/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DFadeToAction : W2DSimpleFiniteDurationAction
{
    fileprivate var fInitialAlpha : CGFloat = 0.0
    fileprivate var fFinalAlpha : CGFloat
    
    public init(duration:TimeInterval, finalAlpha:CGFloat)
    {
        fFinalAlpha = finalAlpha
        
        super.init(duration: duration)
    }
    
    open override func start()
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
    
    open override func run(_ dT: TimeInterval, director: W2DDirector!)
    {
        if let target = self.target
        {
            let c = CGFloat(self.elapsedTime / self.duration)
            let alpha = CGFloat.lerp(fInitialAlpha, endValue: fFinalAlpha, coeff: c)
    
            target.alpha = alpha
        }
    }
}
