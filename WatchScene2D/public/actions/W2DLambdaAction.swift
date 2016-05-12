//
//  W2DLambdaAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 5/12/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

import Foundation

public class W2DLambdaAction : W2DFiniteDurationAction
{
    private let fLambda : (coeff:CGFloat)->Void
    
    // lambda used for interpolation
    public init(duration:NSTimeInterval, lambda:(coeff:CGFloat)->Void)
    {
        fLambda = lambda

        super.init(duration: duration)
    }

    // one-call lambda
    public init(lambda:(coeff:CGFloat)->Void)
    {
        fLambda = lambda
        
        super.init(duration:0.0)
    }
    
    public override func run(director: W2DDirector!)
    {
        if self.duration <= 0.0
        {
            fLambda(coeff: 0.0)
        }
        else
        {
            let c = CGFloat(self.elapsedTime / self.duration)
            fLambda(coeff: c)
        }
    }
}