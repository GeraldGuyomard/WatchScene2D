//
//  W2DNode.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 11/1/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

open class W2DNode : W2DComponent
{
    fileprivate weak var fParent : W2DNode? = nil
    fileprivate var fChildren : Array<W2DNode>? = nil
    
    // transforms
    fileprivate var fLocalTransform = CGAffineTransform.identity
    fileprivate var fIsLocalTransformValid = false
    
    fileprivate var fGlobalTransform = CGAffineTransform.identity
    fileprivate var fIsGlobalTransformValid = false
    
    // Bounding box
    fileprivate var fGlobalBoundingBox = CGRect.zero
    fileprivate var fIsGlobalBoundingBoxValid = false
    
    // decomposed local transform
    fileprivate var fPosition = CGPoint(x: 0, y: 0)
    fileprivate var fAnchorPoint = CGPoint(x: 0, y: 0)
    fileprivate var fSize = CGSize(width: 0, height: 0)
    fileprivate var fScaleXY = CGPoint(x: 1, y: 1)
    fileprivate var fRotation : CGFloat = 0.0
    
    fileprivate weak var fDirector : W2DDirector?
    fileprivate var fIsOnScreen = false
    fileprivate var fIsHidden = false
    fileprivate var fAlpha : CGFloat = 1.0
    
    fileprivate var fActions : [W2DAction]? = nil
    
    open var hidden : Bool
    {
        get { return fIsHidden }
        set
        {
            if newValue != fIsHidden
            {
                if (fIsHidden)
                {
                    fIsHidden = false
                    setNeedsRedraw(false)
                }
                else
                {
                    setNeedsRedraw(false)
                    fIsHidden = true
                }
            }
        }
    }
    
    open var alpha : CGFloat
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
    
    open var isOnScreen : Bool
    {
        get
        {
            return fIsOnScreen
        }
    }
    
    open var position : CGPoint
    {
        get { return fPosition }
        
        set(newPosition)
        {
            if fPosition != newPosition
            {
                setNeedsRedraw(true)
                
                fPosition = newPosition
                
                invalidateTransforms()
                setNeedsRedraw(true)
            }
        }
    }

    open var anchorPoint : CGPoint
    {
        get { return fAnchorPoint }
        
        set(newAnchorPoint)
        {
            if fAnchorPoint != newAnchorPoint
            {
                setNeedsRedraw(true)
                
                fAnchorPoint = newAnchorPoint
                
                invalidateTransforms()
                setNeedsRedraw(true)
            }
        }
    }
    
    open var scaleXY : CGPoint
    {
        get { return fScaleXY }
        
        set(newScaleXY)
        {
            if fScaleXY != newScaleXY
            {
                setNeedsRedraw(true)
                
                fScaleXY = newScaleXY
                
                invalidateTransforms()
                setNeedsRedraw(true)
            }
        }
    }

    open var scale : CGFloat
    {
        get
        {
            assert(fScaleXY.x == fScaleXY.y, "scale should be uniform when calling property scale")
            return fScaleXY.x
        }

        set(newScale)
        {
            if (fScaleXY.x != newScale) || (fScaleXY.y != newScale)
            {
                setNeedsRedraw(true)
                
                fScaleXY.x = newScale
                fScaleXY.y = newScale
                
                invalidateTransforms()
                setNeedsRedraw(true)
            }
        }
    }
    
    open var rotation : CGFloat
        {
        get { return fRotation }
        
        set(newRotation)
        {
            if fRotation != newRotation
            {
                setNeedsRedraw(true)
                
                fRotation = newRotation
                
                invalidateTransforms()
                setNeedsRedraw(true)
            }
        }
    }
    
    open var size : CGSize
    {
        get { return fSize }
        
        set(newSize)
        {
            if fSize != newSize
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
    
    open var director : W2DDirector?
    {
        get { return fDirector }
    }
    
    open var parent : W2DNode?
    {
        get { return fParent }
    }
    
    open var children :Array<W2DNode>?
    {
        get { return fChildren }
    }
    
    open func removeFromParent()
    {
        if let p = fParent
        {
            assert(p.fChildren != nil)
            if let index = p.fChildren!.index(where: {(n:W2DNode) -> Bool in
                return n === self
            })
            {
                p.fChildren!.remove(at: index)
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
    
    open func addChild(_ child:W2DNode!)
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
    
    open var localTransform : CGAffineTransform
    {
        if !fIsLocalTransformValid
        {
            if fAnchorPoint.x != 0 || fAnchorPoint.y != 0
            {
                let aPoint = CGPoint(x: -fSize.width * fAnchorPoint.x, y: -fSize.height * fAnchorPoint.y)
                fLocalTransform = CGAffineTransform(translationX: aPoint.x, y: aPoint.y)
            }
            else
            {
                fLocalTransform = CGAffineTransform.identity
            }
            
            if fScaleXY.x != 1 || fScaleXY.y != 1
            {
                fLocalTransform.a *= fScaleXY.x
                fLocalTransform.b *= fScaleXY.y
                fLocalTransform.c *= fScaleXY.x
                fLocalTransform.d *= fScaleXY.y
                fLocalTransform.tx *= fScaleXY.x
                fLocalTransform.ty *= fScaleXY.y
            }
            
            if fRotation != 0
            {
                fLocalTransform = fLocalTransform.rotated(by: fRotation)
            }
            
            fLocalTransform.tx += fPosition.x
            fLocalTransform.ty += fPosition.y
            
            fIsLocalTransformValid = true
        }
        
        return fLocalTransform
    }
    
    open var globalTransform : CGAffineTransform
    {
        if !fIsGlobalTransformValid
        {
            if fParent != nil
            {
                fGlobalTransform = self.localTransform.concatenating(fParent!.globalTransform)
            }
            else
            {
                fGlobalTransform = self.localTransform
            }
            
            fIsGlobalTransformValid = true
        }
        
        return fGlobalTransform
    }
    
    open var globalBoundingBox : CGRect
    {
        if !fIsGlobalBoundingBoxValid
        {
            let localBox = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            fGlobalBoundingBox = localBox.applying(self.globalTransform)
            
            fIsGlobalBoundingBoxValid = true
        }
        
        return fGlobalBoundingBox
    }
    
    open var globalBoundingVertices : [CGPoint]
    {
        get
        {
            if fRotation == 0
            {
                let box = self.globalBoundingBox
                
                let A = box.origin
                let B = CGPoint(x: box.origin.x, y: box.origin.y + box.size.height)
                let C = CGPoint(x: box.origin.x + box.size.width, y: box.origin.y + box.size.height)
                let D = CGPoint(x: box.origin.x + box.size.width, y: box.origin.y)
                
                return [A, B, C, D]
            }
            else
            {
                let t = self.globalTransform
                
                let A = CGPoint(x: 0, y: 0).applying(t)
                let B = CGPoint(x: 0, y: fSize.height).applying(t)
                let C = CGPoint(x: fSize.width, y: fSize.height).applying(t)
                let D = CGPoint(x: fSize.width, y: 0).applying(t)
                
                return [A, B, C, D]
            }
        }
    }
    
    open func render()
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
                shouldRender = clippingRect.intersects(rect)
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
    
    open func selfRender(_ context:W2DContext)
    {}
    
    open func setNeedsRedraw(_ descendantsToo:Bool)
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
    
    
    open func removeAction(_ action:W2DAction)
    {
        if fActions != nil
        {
            for i in 0..<fActions!.count
            {
                if fActions![i] === action
                {
                    fActions!.remove(at: i)
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
    
    open func removeAllActions()
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
    internal func setIsOnScreen(_ onScreen:Bool)
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
    
    open var targetNode : W2DNode? { get { return self } }
    
    open func run(_ action:W2DAction)
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
