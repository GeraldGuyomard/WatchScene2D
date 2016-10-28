//
//  W2DAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 2/27/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

open class W2DAction : W2DBehavior
{
    open var name : NSString? // for debug
    
    internal var fTarget : W2DNode?
    
    fileprivate var fElapsedTime : TimeInterval = 0.0
    internal var fIsRunning = false
    
    public init()
    {
    }
    
    open var target: W2DNode?
    {
        get { return fTarget }
    }
    
    open var isRunning : Bool
    {
        get { return fIsRunning }
    }
    
    open var stopCallback : ((W2DAction, Bool) -> Void)? = nil
    
    open var elapsedTime : TimeInterval
    {
        get { return fElapsedTime }
    }
    
    open func start()
    {
        if (!fIsRunning)
        {
            restart()
        }
    }
    
    open func restart()
    {
        fElapsedTime = 0
        fIsRunning = true
    }
    
    open func stop()
    {
        onDone(false)
    }
    
    open func execute(_ dT: TimeInterval, director: W2DDirector!)
    {
        assert(fIsRunning)
        
        fElapsedTime += dT
        
        run(dT, director:director)
    }
    
    open func run(_ dT: TimeInterval, director: W2DDirector!)
    {
        assert(false) // to override, thx Swift for not allowing declarations of abstract methods
    }
    
    internal func onDone(_ finished:Bool)
    {
        fTarget = nil
        
        if (fIsRunning)
        {
            fIsRunning = false
            
            if let cb = stopCallback
            {
                stopCallback = nil
                cb(self, finished)
            }
        }
    }
}

open class W2DFiniteDurationAction : W2DAction
{
    internal var fDuration : TimeInterval
    
    open var duration : TimeInterval
    {
        get { return fDuration }
    }
    
    public init(duration:TimeInterval)
    {
        fDuration = duration
        super.init()
    }
}

open class W2DSimpleFiniteDurationAction : W2DFiniteDurationAction
{
    override open func execute(_ dT: TimeInterval, director: W2DDirector!)
    {
        super.execute(dT, director: director)
        
        if fIsRunning && fElapsedTime >= fDuration
        {
            onDone(true)
        }
    }
}

