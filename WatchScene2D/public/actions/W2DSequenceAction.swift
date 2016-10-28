//
//  W2DSequenceAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 3/6/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DSequenceAction : W2DFiniteDurationAction
{
    fileprivate var fSubActions = [W2DFiniteDurationAction]()
    fileprivate var fSubActionsToRun : [W2DFiniteDurationAction]? = nil
    fileprivate var fRunningSubAction: W2DFiniteDurationAction? = nil
    
    public init()
    {
        super.init(duration:0)
    }
    
    open func addAction(_ action:W2DFiniteDurationAction)
    {
        fSubActions.append(action)
        fDuration += action.duration
    }
    
    fileprivate func _startNextSubAction(_ dT: TimeInterval, director: W2DDirector!)
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
    
    open override func restart()
    {
        fSubActionsToRun = fSubActions // copy
        
        super.restart()
    }
    
    open override func stop()
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
    
    open override func run(_ dT: TimeInterval, director: W2DDirector!)
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
