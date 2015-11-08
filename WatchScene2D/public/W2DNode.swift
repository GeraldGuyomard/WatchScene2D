//
//  W2DNode.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 11/1/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

public class W2DNode
{
    private weak var fParent : W2DNode? = nil
    private var fChildren : Array<W2DNode>? = nil
    
    private var fLocalTransform = CGAffineTransformIdentity
    private var fIsLocalTransformValid = false
    
    private var fGlobalTransform = CGAffineTransformIdentity
    private var fIsGlobalTransformValid = false
    
    // decomposed local transform
    private var fPosition = CGPointMake(0, 0)
    private var fSize = CGSizeMake(0, 0)
    
    public var hidden = false
    
    public var position : CGPoint
    {
        get { return fPosition }
        
        set(newPosition)
        {
            if (fPosition != newPosition)
            {
                fPosition = newPosition
                invalidateTransforms()
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
                fSize = newSize
                invalidateTransforms()
            }
        }
    }
    
    public init()
    {
    }
    
    public var parent : W2DNode?
    {
        get { return fParent }
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
    
    public func render(context:W2DContext)
    {
        if (!self.hidden)
        {
            context.saveTranform()
            context.applyTransform(self.globalTransform)
            
            selfRender(context)
            
            if let children = fChildren
            {
                for child in children
                {
                    child.render(context)
                }
            }
            
            context.restoreTransform()
        }
    }
    
    public func selfRender(context:W2DContext)
    {}
    
    internal func invalidateTransforms()
    {
        fIsLocalTransformValid = false
        fIsGlobalTransformValid = false

        if let children = fChildren
        {
            for child in children
            {
                child.invalidateTransforms()
            }
        }
    }
}