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
    private var fSubActionsToRun : [W2DFiniteDurationAction]? = nil
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
    
    private func _startNextSubAction(dT: NSTimeInterval, director: W2DDirector!)
    {
        assert(fRunningSubAction == nil)
        
        fRunningSubAction = (fSubActionsToRun != nil) && !fSubActionsToRun!.isEmpty ? fSubActionsToRun!.removeFirst() : nil
        if let action = fRunningSubAction
        {
            action.fTarget = self.target
            
            action.stopCallback = {[weak self](action:W2DAction, finished:Bool) in
                if let this = self
                {
                    assert(this.fRunningSubAction === action)
                    this.fRunningSubAction = nil
                    
                    this._startNextSubAction(dT, director: director)
                }
            }
            
            action.start()
            action.execute(dT, director: director)
        }
        else
        {
            fSubActionsToRun = nil
            onDone(true)
        }
        
    }
    
    public override func restart()
    {
        fSubActionsToRun = fSubActions // copy
        
        super.restart()
    }
    
    public override func stop()
    {
        if let action = fRunningSubAction
        {
            action.stopCallback = nil
            fRunningSubAction = nil
            fSubActionsToRun = nil
            action.stop()
        }
        
        super.stop()
    }
    
    public override func run(dT: NSTimeInterval, director: W2DDirector!)
    {
        if let action = fRunningSubAction
        {
            action.execute(dT, director: director)
        }
        else
        {
            _startNextSubAction(dT, director: director)
        }
    }
}