//
//  W2DSequenceAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 3/6/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public class W2DSequenceAction : W2DFiniteDurationAction
{
    private var fSubActions = [W2DFiniteDurationAction]()
    private var fRunningSubAction: W2DFiniteDurationAction? = nil
    
    public init()
    {
        super.init(duration:0)
    }
    
    public func addAction(action:W2DFiniteDurationAction)
    {
        fSubActions.append(action)
        fDuration += action.duration
    }
    
    public override func run(director: W2DDirector!)
    {
        if fRunningSubAction == nil
        {
            fRunningSubAction = fSubActions.first
            if let action = fRunningSubAction
            {
                //action.
            }
        }
    }
}