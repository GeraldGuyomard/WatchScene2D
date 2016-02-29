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
    private var     fFrameRate : UInt = 25
    private var     fdT : NSTimeInterval = 0.0
    private var     fContext : W2DContext
    private var     fBehaviors = W2DBehaviorGroup()
    private var     fActions = W2DBehaviorGroup()
    
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
    
    var frameRate : UInt
    {
        get { return fFrameRate }
        set
        {
            if fFrameRate != newValue
            {
                assert(newValue != 0)
                fFrameRate = newValue
                if fRenderTimer != nil
                {
                    stop()
                    start()
                }
            }
        }
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
    
    var actionManager : W2DActionManager
    {
        get { return fActions }
    }
    
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
            let t : NSTimeInterval = 1.0 / NSTimeInterval(fFrameRate)
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
    
    func addBehavior(behavior:W2DBehavior)
    {
        fBehaviors.addBehavior(behavior)
    }
    
    func removeBehavior(behavior:W2DBehavior)
    {
        fBehaviors.removeBehavior(behavior)
    }
    
    func startAction(action:W2DAction)
    {
        fActions.addBehavior(action)
        action.start()
    }
    
    func stopAction(action:W2DAction)
    {
        action.stop()
        fActions.removeBehavior(action)
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
        
        fBehaviors.execute(fdT, director: self)
        fActions.execute(fdT, director: self)
        
        self.render()
        self.presentRender()
        
        let  endT = NSDate()
        let duration = endT.timeIntervalSinceDate(startT);
        
        print("frame:\(duration * 1000.0) ms")
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
        var rectI = CGRectIntegral(rect)
        
        if rectI.size.width <= 0 || rectI.size.height <= 0
        {
            return
        }
        
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
                    fInvalidatedRects!.append(rectI)
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