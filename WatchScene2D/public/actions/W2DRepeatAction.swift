//
//  W2DRepeatAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 5/13/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DRepeatAction : W2DFiniteDurationAction
{
    internal var fSubAction: W2DFiniteDurationAction!
    internal var fNbRepeatLeft : Int // <0 means infinite loop
    
    required public init(action:W2DFiniteDurationAction!, count:Int)
    {
        fSubAction = action
        let d: TimeInterval = (count >= 0) ? TimeInterval(count) * action.duration : TimeInterval.infinity
        
        fNbRepeatLeft = count
        
        super.init(duration:d)
    }
    
    fileprivate func _onSubActionEnded(_ finished:Bool)
    {
        if fNbRepeatLeft > 0
        {
            fNbRepeatLeft -= 1
        }

        if fNbRepeatLeft == 0
        {
            onDone(finished)
        }
        else
        {
            // > 0, finite repeat time but not over yet
            // < 0, repeat forever
            fSubAction.restart()
        }
    }
    
    open override func run(_ dT: TimeInterval, director: W2DDirector!)
    {
        if fNbRepeatLeft != 0
        {
            if !fSubAction.isRunning
            {
                fSubAction.fTarget = self.target
                
                fSubAction.stopCallback = {[weak self](action:W2DAction, finished:Bool) in
                    if let this = self
                    {
                        assert(this.fSubAction === action)
                        
                        this._onSubActionEnded(finished)
                    }
                }
                
                fSubAction.start()
            }
            
            fSubAction.execute(dT, director: director)
        }
    }
    
    open override func stop()
    {
        if fSubAction.isRunning
        {
            fSubAction.stopCallback = nil
            fSubAction.stop()
        }
        
        super.stop()
    }

}
