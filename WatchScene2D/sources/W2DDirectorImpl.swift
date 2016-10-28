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
    fileprivate var     fTarget : WKInterfaceObject
    fileprivate var     fRenderTimer : Timer?
    fileprivate var     fPreviousRenderTime: Date?
    fileprivate var     fFrameRate : UInt = 25
    fileprivate var     fdT : TimeInterval = 0.0
    fileprivate var     fContext : W2DContext
    fileprivate var     fBehaviors = W2DBehaviorGroup()
    fileprivate var     fActions = W2DBehaviorGroup()
    
    fileprivate var     fInterfacePicker : WKInterfacePicker?
    fileprivate var     fSensitivity = Float(0.0)
    fileprivate var     fLastNormalizedInput = Float(0.0)
    
    fileprivate var     fInvalidatedRects : [CGRect]?
    
    init(target:WKInterfaceObject, context:W2DContext)
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
    
    var dT : TimeInterval { return fdT }
    
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
                    newScene.size = CGSize(width: CGFloat(fContext.width), height: CGFloat(fContext.height))
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
    
    func setupDigitalCrownInput(picker:WKInterfacePicker, sensitivity:UInt)
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
    
    func setDigitalCrownValue(_ value:Float)
    {
        assert(fInterfacePicker != nil)
        
        if let picker = fInterfacePicker
        {
            let index = Int(value * fSensitivity)
            picker.setSelectedItemIndex(index)
        }
    }
    
    func processDigitalCrownInput(_ input:NSInteger, handler:(Float) -> Void)
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
            let t : TimeInterval = 1.0 / TimeInterval(fFrameRate)
            fRenderTimer = Timer.scheduledTimer(timeInterval: t, target:self, selector:#selector(W2DDirectorImpl.onRenderTimer(_:)), userInfo:nil, repeats:true)
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
    
    func addBehavior(_ behavior:W2DBehavior)
    {
        fBehaviors.addBehavior(behavior)
    }
    
    func removeBehavior(_ behavior:W2DBehavior)
    {
        fBehaviors.removeBehavior(behavior)
    }
    
    func onRenderTimer(_ timer:Timer)
    {
        let startT = Date()
        if let previousTime = fPreviousRenderTime
        {
            let timerT = startT.timeIntervalSince(previousTime)
            //print("timer interval=\(timerT * 1000.0) ms")
            
            fdT = startT.timeIntervalSince(previousTime)
        }
        
        fPreviousRenderTime = startT;
        
        fBehaviors.execute(fdT, director: self)
        fActions.execute(fdT, director: self)
        
        self.render()
        self.presentRender()
        
        let  endT = Date()
        let duration = endT.timeIntervalSince(startT);
        
        //print("frame:\(duration * 1000.0) ms")
    }
    
    fileprivate func render()
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
    
    fileprivate func presentRender()
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
        
        if let img = fTarget as? WKInterfaceImage
        {
            img.setImage(image)
        }
        else if let button = fTarget as? WKInterfaceButton
        {
            button.setBackgroundImage(image)
        }
    }
    
    func setNeedsRedraw(_ rect : CGRect)
    {
        var rectI = rect.integral
        
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
                    if r.intersects(rectI)
                    {
                        shouldAppend = false
                        
                        if r.contains(rectI)
                        {
                            shouldLoop = false
                        }
                        else
                        {
                            fInvalidatedRects!.remove(at: i)
                            rectI = rectI.union(r)
                        }
                        
                        break
                    }
                    else
                    {
                        i += 1
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
        setNeedsRedraw(CGRect(x: 0, y: 0, width: CGFloat(fContext.width), height: CGFloat(fContext.height)))
    }
}
