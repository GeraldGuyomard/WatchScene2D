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
                if let oldScene = oldValue
                {
                    oldScene.discard()
                }
                
                if let newScene = self.currentScene
                {
                    newScene.size = CGSizeMake(CGFloat(fContext.width), CGFloat(fContext.height))
                    newScene.present()
                }
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
                        
                        fContext.restoreState()
                    }
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
        var image : UIImage?
        
        if self.showDirtyRects
        {
            image = fContext.render(fInvalidatedRects)
        }
        else
        {
            image = fContext.render()
        }
        
        fInvalidatedRects = nil
        
        fTarget.setImage(image)
    }
    
    func setNeedsRedraw(rect : CGRect)
    {
        if rect.size.width <= 0 || rect.size.height <= 0
        {
            return
        }

        let origin = CGPointMake(CGFloat(floorf(Float(rect.origin.x))), CGFloat(floorf(Float(rect.origin.y))))
        let end = CGPointMake(CGFloat(ceilf(Float(rect.origin.x + rect.size.width))), CGFloat(ceilf(Float(rect.origin.y + rect.size.height))))
        var rectI = CGRectMake(origin.x - 1.0, origin.y - 1.0, end.x - origin.x + 1.0, end.y - origin.y + 1.0)
        
        if fInvalidatedRects != nil
        {
            var shouldLoop = true
            while shouldLoop
            {
                // coalesce rectI if another rectangle overlaps it
                var i  = 0
                let c = fInvalidatedRects!.count
                var shouldAppend = true
                
                while i < c
                {
                    let r = fInvalidatedRects![i]
                    if CGRectIntersectsRect(r, rectI)
                    {
                        shouldAppend = false
                        
                        if CGRectContainsRect(r, rectI)
                        {
                            shouldLoop = false
                        }
                        else
                        {
                            fInvalidatedRects!.removeAtIndex(i)
                            rectI = CGRectUnion(rectI, r)
                        }
                        
                        break
                    }
                    else
                    {
                        ++i
                    }
                }
                
                if (shouldAppend)
                {
                    fInvalidatedRects!.append(rect)
                    shouldLoop = false
                }
            }
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