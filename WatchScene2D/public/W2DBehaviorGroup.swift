//
//  W2DBehaviorGroup.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 2/27/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public class W2DBehaviorGroup : W2DBehavior
{
    private var fBehaviors = [W2DBehavior]()
    
    public func execute(dT:NSTimeInterval, director:W2DDirector!)
    {
        for behavior in fBehaviors
        {
            behavior.execute(dT, director:director)
        }
    }
    
    private func _behaviorIndex(behavior:W2DBehavior) -> Array<W2DBehavior>.Index?
    {
        return
            fBehaviors.indexOf({ (b:W2DBehavior) -> Bool in
                return b === behavior;
            })
    }
    
    public func addBehavior(behavior:W2DBehavior)
    {
        if (_behaviorIndex(behavior) == nil)
        {
            fBehaviors.append(behavior)
        }
    }
    
    public func removeBehavior(behavior:W2DBehavior)
    {
        if let index = _behaviorIndex(behavior)
        {
            fBehaviors.removeAtIndex(index)
        }
    }
}