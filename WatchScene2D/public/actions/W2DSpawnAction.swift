//
//  W2DSpawnAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 5/23/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DSpawnAction : W2DFiniteDurationAction
{
    fileprivate var fSubActions = [W2DFiniteDurationAction]()
    fileprivate var fRunningSubActions : [W2DFiniteDurationAction]? = nil
    
    public init()
    {
        super.init(duration:0)
    }
    
    open func addAction(_ action:W2DFiniteDurationAction)
    {
        fSubActions.append(action)
        if (action.duration > fDuration)
        {
            fDuration = action.duration
        }
    }
    
    open override func restart()
    {
        super.restart()
        
        fRunningSubActions = fSubActions // copy
    }
    
    open override func stop()
    {
        if let actions = fRunningSubActions
        {
            for action in actions
            {
                action.stopCallback = nil
                action.stop()
            }
            
            fRunningSubActions = nil
        }
        
        super.stop()
    }
    
    fileprivate func _onSubActionFinished(_ action:W2DAction!)
    {
        assert(fRunningSubActions != nil);
        var index = 0
        for a in fRunningSubActions!
        {
            if a === action
            {
                fRunningSubActions!.remove(at: index)
                if (fRunningSubActions!.isEmpty)
                {
                    fRunningSubActions = nil
                    onDone(true)
                }
                
                break
            }
            
            index += 1
        }
    }
    
    open override func run(_ dT: TimeInterval, director: W2DDirector!)
    {
        if let actions = fRunningSubActions
        {
            for action in actions
            {
                if !action.isRunning
                {
                    action.fTarget = self.target
                    
                    action.stopCallback = {[weak self](action:W2DAction, finished:Bool) in
                        if let this = self
                        {
                            this._onSubActionFinished(action)
                        }
                    }

                    action.start()
                }
                
                action.execute(dT, director: director)
            }
        }
    }
}
