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
    
    public override func execute(dT: NSTimeInterval, director: W2DDirector!)
    {
        super.execute(dT, director: director)
        
        if let action = fRunningSubAction
        {
            action.execute(dT, director: director)
        }
        else
        {
            fRunningSubAction = !fSubActions.isEmpty ? fSubActions.removeFirst() : nil
            if let action = fRunningSubAction
            {
                action.fTarget = self.target
                
                action.stopCallback = {[weak self](action:W2DAction, finished:Bool) in
                    if let this = self
                    {
                        this.fRunningSubAction = !this.fSubActions.isEmpty ? this.fSubActions.removeFirst() : nil
                        if this.fRunningSubAction == nil
                        {
                            this.onDone(true)
                        }
                    }
                }
                
                action.start()
                action.execute(dT, director: director)
            }
            else
            {
                onDone(true)
            }
        }

    }
    
    public override func stop()
    {
        if let action = fRunningSubAction
        {
            action.stopCallback = nil
            fRunningSubAction = nil
            action.stop()
        }
        
        super.stop()
    }
    
    public override func run(director: W2DDirector!)
    {
    }
}