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
    
    private var     fInterfacePicker : WKInterfacePicker?
    private var     fSensitivity = Float(0.0)
    private var     fLastNormalizedInput = Float(0.0)
    
    private var     fInvalidatedRects : [CGRect]?
    
    init(target:WKInterfaceImage, context:W2DContext)
    {
        fTarget = target
        fContext = context
    }
    
    var context : W2DContext
    {
        get { return fContext }
    }
    
    var dT : NSTimeInterval { return fdT }
    
    var currentScene : W2DScene?
    {
        didSet
        {
            if self.smartRedrawEnabled
            {
                
            }
        }
    }
    
    var smartRedrawEnabled : Bool = false
    {
        didSet
        {
            if !self.smartRedrawEnabled
            {
                fInvalidatedRects = nil
            }
        }
    }
    
    var showDirtyRects : Bool = false
    
    func setupDigitalCrownInput(picker picker:WKInterfacePicker, sensitivity:UInt)
    {
        fInterfacePicker = picker
        fSensitivity = Float(sensitivity) - 1
        
        if let picker = fInterfacePicker
        {
            var items = [WKPickerItem]();
            
            let item = WKPickerItem()
            item.title = " ";
            
            for _ in 1...sensitivity
            {
                items.append(item)
            }
            
            picker.setItems(items)
        }
    }
    
    func setDigitalCrownValue(value:Float)
    {
        assert(fInterfacePicker != nil)
        
        if let picker = fInterfacePicker
        {
            let index = Int(value * fSensitivity)
            picker.setSelectedItemIndex(index)
        }
    }
    
    func processDigitalCrownInput(input:NSInteger, handler:(Float) -> Void)
    {
        fLastNormalizedInput = (fSensitivity != 0) ? (Float(input) / fSensitivity) : 0
        
        handler(fLastNormalizedInput)
    }
    
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
            behavior.execute(fdT, director:self)
        }
    }
    
    private func render()
    {
        if let scene = self.currentScene
        {
            if (self.smartRedrawEnabled)
            {
                if let rects = fInvalidatedRects
                {
                    for r in rects
                    {
                        fContext.saveState();
                        fContext.applyClipping(r)
                        
                        scene.render()
                        
                        if self.showDirtyRects
                        {
                            fContext.fillRect(r, withColor: W2DColor4f(red: 1, green: 0, blue: 0, alpha: 0.25))
                        }
                        
                        fContext.restoreState()
                    }
                    
                    fInvalidatedRects = nil
                }
            }
            else
            {
                scene.render()
            }
        }
    }
    
    private func presentRender()
    {
        let image = fContext.render()
        fTarget.setImage(image)
    }
    
    private static func addDirtyRect(rect: CGRect, var dirtyRects rects:[CGRect])
    {
        // coalesce rectI if another rectangle overlaps it
        var i  = 0
        let c = rects.count
        
        while i < c
        {
            let r = rects[i]
            if CGRectIntersectsRect(rect, r)
            {
                rects.removeAtIndex(i)
                let newRect = CGRectUnion(rect, r)
                addDirtyRect(newRect, dirtyRects:rects)
                return
            }
            else
            {
                ++i
            }
        }
        
        rects.append(rect)
    }
    
    func setNeedsRedraw(rect : CGRect)
    {
        let rectI = CGRectMake( CGFloat(floorf(Float(rect.origin.x))), CGFloat(floorf(Float(rect.origin.y))),
                                CGFloat(ceilf(Float(rect.size.width))), CGFloat(ceilf(Float(rect.size.height))))
        
        if let rects = fInvalidatedRects
        {
            W2DDirectorImpl.addDirtyRect(rectI, dirtyRects:rects)
        }
        else
        {
            fInvalidatedRects = [CGRect]()
            fInvalidatedRects!.append(rectI)
        }
    }
    
    func setNeedsFullRedraw()
    {
        setNeedsRedraw(CGRectMake(0, 0, CGFloat(fContext.width), CGFloat(fContext.height)))
    }
}