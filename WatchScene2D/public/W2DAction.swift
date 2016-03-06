//
//  W2DAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 2/27/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

public class W2DAction : W2DBehavior
{
    private weak var fActionManager : W2DBehaviorGroup?
    internal weak var fTarget : W2DNode?
    
    private var fElapsedTime : NSTimeInterval = 0.0
    internal var fIsRunning = false
    
    public init(actionManager:W2DActionManager)
    {
        fActionManager = actionManager
    }
    
    public init(target:W2DNode)
    {
        fTarget = target
        target.addAction(self)
        fActionManager = target.director?.actionManager
    }
    
    public var target : W2DNode?
    {
        get { return fTarget }
    }
    
    public var elapsedTime : NSTimeInterval
    {
        get { return fElapsedTime }
    }
    
    public func start()
    {
        if let manager = fActionManager
        {
            if (!fIsRunning)
            {
                fElapsedTime = 0
                fIsRunning = true
                
                manager.addBehavior(self)
            }
        }
    }
    
    public func stop()
    {
        if (fIsRunning)
        {
            fIsRunning = false
            
            if let manager = fActionManager
            {
                manager.removeBehavior(self)
            }
            
            if let target = fTarget
            {
                target.removeAction(self)
            }
        }
    }
    
    public func execute(dT: NSTimeInterval, director: W2DDirector!)
    {
        assert(fIsRunning)
        
        fElapsedTime += dT
        
        run(director)
    }
    
    public func run(director: W2DDirector!)
    {
        assert(false) // to override, thx Swift for not allowing declarations of abstract methods
    }
}

public class W2DFiniteDurationAction : W2DAction
{
    private var fDuration : NSTimeInterval
    
    public var duration : NSTimeInterval
    {
        get { return fDuration }
    }
    
    public init(actionManager:W2DActionManager, duration:NSTimeInterval)
    {
        fDuration = duration
        super.init(actionManager: actionManager)
    }

    public init(target:W2DNode, duration:NSTimeInterval)
    {
        fDuration = duration
        super.init(target: target)
    }
    
    override public func execute(dT: NSTimeInterval, director: W2DDirector!)
    {
        super.execute(dT, director: director)
        
        if (fElapsedTime >= fDuration)
        {
            // done
            stop()
        }
    }
}
