//
//  W2DFadeToAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 2/27/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public class W2DFadeToAction : W2DFiniteDurationAction
{
    private var fFinalAlpha : CGFloat
    
    public init(target:W2DNode, duration:NSTimeInterval, finalAlpha:CGFloat)
    {
        fFinalAlpha = finalAlpha
        
        super.init(target:target, duration: duration)
    }
    
    public override func run(director: W2DDirector!)
    {
        if let target = self.target
        {
            let c = self.elapsedTime / self.duration
            let alpha = fFinalAlpha * CGFloat(c)
    
            target.alpha = alpha
        }
    }
}