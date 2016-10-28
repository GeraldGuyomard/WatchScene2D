//
//  W2DBehaviorGroup.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 2/27/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DBehaviorGroup : W2DBehavior
{
    fileprivate var fBehaviors = [W2DBehavior]()
    
    open func execute(_ dT:TimeInterval, director:W2DDirector!)
    {
        for behavior in fBehaviors
        {
            behavior.execute(dT, director:director)
        }
    }
    
    fileprivate func _behaviorIndex(_ behavior:W2DBehavior) -> Array<W2DBehavior>.Index?
    {
        return
            fBehaviors.index(where: { (b:W2DBehavior) -> Bool in
                return b === behavior;
            })
    }
    
    open func addBehavior(_ behavior:W2DBehavior)
    {
        if (_behaviorIndex(behavior) == nil)
        {
            fBehaviors.append(behavior)
        }
    }
    
    open func removeBehavior(_ behavior:W2DBehavior)
    {
        if let index = _behaviorIndex(behavior)
        {
            fBehaviors.remove(at: index)
        }
    }
}
