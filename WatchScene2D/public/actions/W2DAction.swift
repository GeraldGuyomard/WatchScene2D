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
    public var name : NSString? // for debug
    
    internal var fTarget : W2DNode?
    
    private var fElapsedTime : NSTimeInterval = 0.0
    internal var fIsRunning = false
    
    public init()
    {
    }
    
    public var target: W2DNode?
    {
        get { return fTarget }
    }
    
    public var stopCallback : ((W2DAction, Bool) -> Void)? = nil
    
    public var elapsedTime : NSTimeInterval
    {
        get { return fElapsedTime }
    }
    
    public func start()
    {
        if (!fIsRunning)
        {
            fElapsedTime = 0
            fIsRunning = true
        }
    }
    
    public func stop()
    {
        onDone(false)
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
    
    internal func onDone(finished:Bool)
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

public class W2DFiniteDurationAction : W2DAction
{
    internal var fDuration : NSTimeInterval
    
    public var duration : NSTimeInterval
    {
        get { return fDuration }
    }
    
    public init(duration:NSTimeInterval)
    {
        fDuration = duration
        super.init()
    }
    
    override public func execute(dT: NSTimeInterval, director: W2DDirector!)
    {
        super.execute(dT, director: director)
        
        if (fElapsedTime >= fDuration)
        {
            onDone(true)
        }
    }
}
