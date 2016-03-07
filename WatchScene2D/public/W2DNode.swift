//
//  W2DNode.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 11/1/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

public class W2DNode : W2DComponent
{
    private weak var fParent : W2DNode? = nil
    private var fChildren : Array<W2DNode>? = nil
    
    private var fLocalTransform = CGAffineTransformIdentity
    private var fIsLocalTransformValid = false
    
    private var fGlobalTransform = CGAffineTransformIdentity
    private var fIsGlobalTransformValid = false
    
    private var fGlobalBoundingBox = CGRectZero
    private var fIsGlobalBoundingBoxValid = false
    
    // decomposed local transform
    private var fPosition = CGPointMake(0, 0)
    private var fSize = CGSizeMake(0, 0)
    
    private weak var fDirector : W2DDirector?
    private var fIsOnScreen = false
    private var fAlpha : CGFloat = 1.0
    
    private var fActions : [W2DAction]? = nil
    
    public var hidden = false
    public var alpha : CGFloat
    {
        get { return fAlpha }
        set
        {
            var newAlpha = newValue
            if newAlpha < 0.0
            {
                newAlpha = 0.0
            }
            else if (newAlpha > 1.0)
            {
                newAlpha = 1.0
            }
            
            if newAlpha != fAlpha
            {
                fAlpha = newAlpha
                setNeedsRedraw(false)
            }
        }
    }
    
    public var isOnScreen : Bool
    {
        get
        {
            return fIsOnScreen
        }
    }
    
    public var position : CGPoint
    {
        get { return fPosition }
        
        set(newPosition)
        {
            if (fPosition != newPosition)
            {
                setNeedsRedraw(true)
                
                fPosition = newPosition
                
                invalidateTransforms()
                setNeedsRedraw(true)
            }
        }
    }
    
    public var size : CGSize
    {
        get { return fSize }
        
        set(newSize)
        {
            if (fSize != newSize)
            {
                setNeedsRedraw(true)
                
                fSize = newSize
                
                invalidateTransforms()
                setNeedsRedraw(true)
            }
        }
    }
    
    public init(director:W2DDirector)
    {
        fDirector = director
    }
    
    public var director : W2DDirector?
    {
        get { return fDirector }
    }
    
    public var parent : W2DNode?
    {
        get { return fParent }
    }
    
    public var children :Array<W2DNode>?
    {
        get { return fChildren }
    }
    
    public func removeFromParent()
    {
        if let p = fParent
        {
            assert(p.fChildren != nil)
            if let index = p.fChildren!.indexOf({(n:W2DNode) -> Bool in
                return n === self
            })
            {
                p.fChildren!.removeAtIndex(index)
                if p.fChildren!.count == 0
                {
                    p.fChildren = nil
                }
            }
            
            setIsOnScreen(false)
            
            fParent = nil
            
            removeAllActions()
        }
    }
    
    public func addChild(child:W2DNode!)
    {
        if let oldParent = child.parent
        {
            if oldParent === self
            {
                return
            }
            
            child.removeFromParent()
        }
        
        if fChildren == nil
        {
            fChildren = Array<W2DNode>()
        }
        
        fChildren!.append(child)
        child.fParent = self
        
        child.setIsOnScreen(fIsOnScreen)
    }
    
    public var localTransform : CGAffineTransform
    {
        if !fIsLocalTransformValid
        {
            fLocalTransform = CGAffineTransformIdentity
            fLocalTransform = CGAffineTransformTranslate(fLocalTransform, fPosition.x, fPosition.y)
            fIsLocalTransformValid = true
        }
        
        return fLocalTransform
    }
    
    public var globalTransform : CGAffineTransform
    {
        if !fIsGlobalTransformValid
        {
            if fParent != nil
            {
                fGlobalTransform = CGAffineTransformConcat(self.localTransform, fParent!.globalTransform)
            }
            else
            {
                fGlobalTransform = self.localTransform
            }
            
            fIsGlobalTransformValid = true
        }
        
        return fGlobalTransform
    }
    
    public var globalBoundingBox : CGRect
    {
        if !fIsGlobalBoundingBoxValid
        {
            let localBox = CGRectMake(0, 0, self.size.width, self.size.height)
            fGlobalBoundingBox = CGRectApplyAffineTransform(localBox, self.globalTransform)
            
            fIsGlobalBoundingBoxValid = true
        }
        
        return fGlobalBoundingBox
    }
    
    public func render()
    {
        if (!self.hidden)
        {
            let context = fDirector!.context
            
            context.saveState()
            context.applyTransform(self.globalTransform)
            
            var shouldRender = true
            
            if let clippingRect = context.clippingRect
            {
                let rect = self.globalBoundingBox
                shouldRender = CGRectIntersectsRect(clippingRect, rect)
            }

            if shouldRender
            {
                selfRender(context)
            }
            
            if let children = fChildren
            {
                for child in children
                {
                    child.render()
                }
            }
            
            context.restoreState()
        }
    }
    
    public func selfRender(context:W2DContext)
    {}
    
    public func setNeedsRedraw(descendantsToo:Bool)
    {
        if !self.hidden && self.isOnScreen
        {
            if let director = fDirector
            {
                if director.smartRedrawEnabled
                {
                    director.setNeedsRedraw(self.globalBoundingBox)
                    
                    if descendantsToo
                    {
                        if let children = fChildren
                        {
                            for child in children
                            {
                                child.setNeedsRedraw(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public func removeAction(action:W2DAction)
    {
        if fActions != nil
        {
            for i in 0..<fActions!.count
            {
                if fActions![i] === action
                {
                    fActions!.removeAtIndex(i)
                    if fActions!.isEmpty
                    {
                        fActions = nil
                    }
                    
                    action.stop()
                    break
                }
            }
        }
        
        if let manager = fDirector?.actionManager
        {
            manager.removeBehavior(action)
        }
    }
    
    public func removeAllActions()
    {
        if let actions = fActions
        {
            fActions = nil
            
            for action in actions
            {
                action.stop()
            }
        }
    }
    
    /*
        Internal methods
    */
    internal func setIsOnScreen(onScreen:Bool)
    {
        if fIsOnScreen != onScreen
        {
            if (onScreen)
            {
                fIsOnScreen = true
                setNeedsRedraw(false)
            }
            else
            {
                // leaving screen
                setNeedsRedraw(false)
                fIsOnScreen = false
            }
            
            if let children = fChildren
            {
                for child in children
                {
                    child.setIsOnScreen(onScreen)
                }
            }
        }
    }
    
    internal func invalidateTransforms()
    {
        fIsLocalTransformValid = false
        fIsGlobalTransformValid = false
        fIsGlobalBoundingBoxValid = false

        if let children = fChildren
        {
            for child in children
            {
                child.invalidateTransforms()
            }
        }
    }
    
    public var targetNode : W2DNode? { get { return self } }
    
    public func run(action:W2DAction)
    {
        action.fTarget = self
        action.stopCallback = {[weak self](action:W2DAction, finished:Bool) in
            if let this = self
            {
                this.removeAction(action)
            }
        }
        
        if let manager = fDirector?.actionManager
        {
            manager.addBehavior(action)
            
            if fActions == nil
            {
                fActions = [W2DAction]()
            }
            
            fActions!.append(action)
            
            action.start();
        }
    }
}