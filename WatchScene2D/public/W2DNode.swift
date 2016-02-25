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
    
    public var hidden = false
    
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
    
    internal func setIsOnScreen(onScreen:Bool)
    {
        if fIsOnScreen != onScreen
        {
            fIsOnScreen = onScreen
            
            setNeedsRedraw(false)
            
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
}