//
//  W2DDirectorImpl.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/18/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

internal class W2DDirectorImpl : NSObject, W2DDirector
{
    private var     fTarget : WKInterfaceImage
    private var     fRenderTimer : NSTimer?
    private var     fPreviousRenderTime: NSDate?
    private var     fdT : NSTimeInterval = 0.0
    private var     fContext : W2DContext
    private var     fBehaviors = [W2DBehavior]()
    
    init(target:WKInterfaceImage, context:W2DContext)
    {
        fTarget = target
        fContext = context
    }
    
    var dT : NSTimeInterval { return fdT }
    
    func start()
    {
        fPreviousRenderTime = nil
        fdT = 0
        
        if fRenderTimer == nil
        {
            let t : NSTimeInterval = 1.0 / 20.0
            fRenderTimer = NSTimer.scheduledTimerWithTimeInterval(t, target:self, selector:Selector("onRenderTimer:"), userInfo:nil, repeats:true)
        }
    }
    
    func stop()
    {
        if let timer = fRenderTimer
        {
            timer.invalidate()
            fRenderTimer = nil
        }
    }
    
    private func _behaviorIndex(behavior:W2DBehavior) -> Array<W2DBehavior>.Index?
    {
        return
            fBehaviors.indexOf({ (b:W2DBehavior) -> Bool in
            return b === behavior;
        })
    }
    
    func addBehavior(behavior:W2DBehavior)
    {
        if (_behaviorIndex(behavior) == nil)
        {
            fBehaviors.append(behavior)
        }
    }
    
    func removeBehavior(behavior:W2DBehavior)
    {
        if let index = _behaviorIndex(behavior)
        {
            fBehaviors.removeAtIndex(index)
        }
    }
    
    func onRenderTimer(timer:NSTimer)
    {
        let startT = NSDate()
        if let previousTime = fPreviousRenderTime
        {
            let timerT = startT.timeIntervalSinceDate(previousTime)
            print("timer interval=\(timerT * 1000.0) ms")
            
            fdT = startT.timeIntervalSinceDate(previousTime)
        }
        
        fPreviousRenderTime = startT;
        
        self.processBehaviors()
        self.render()
        self.presentRender()
        
        let  endT = NSDate()
        let duration = endT.timeIntervalSinceDate(startT);
        
        print("frame:\(duration * 1000.0) ms")
    }
    
    private func processBehaviors()
    {
        for behavior in fBehaviors
        {
            behavior.execute(fdT)
        }
    }
    
    private func render()
    {
        // Here the scene graph
    }
    
    private func presentRender()
    {
        let image = fContext.render()
        fTarget.setImage(image)
    }
    
}