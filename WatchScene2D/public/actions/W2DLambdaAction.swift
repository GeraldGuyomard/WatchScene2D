//
//  W2DLambdaAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 5/12/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DLambdaAction : W2DSimpleFiniteDurationAction
{
    public typealias Lambda=(_ target:W2DNode?, _ coeff:CGFloat)->Void
    
    fileprivate let fLambda : Lambda
    
    // lambda used for interpolation
    public init(duration:TimeInterval, lambda:@escaping Lambda)
    {
        fLambda = lambda

        super.init(duration: duration)
    }

    // one-call lambda
    public init(lambda:@escaping Lambda)
    {
        fLambda = lambda
        
        super.init(duration:0.0)
    }
    
    open override func run(_ dT: TimeInterval, director: W2DDirector!)
    {
        if self.duration <= 0.0
        {
            fLambda(fTarget, 0.0)
        }
        else
        {
            let c = CGFloat(self.elapsedTime / self.duration)
            fLambda(fTarget, c)
        }
    }
}
