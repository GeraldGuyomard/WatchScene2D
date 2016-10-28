//
//  W2DComponent.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 12/6/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DComponent
{
    open var debugName : String? = nil
    
    public init()
    {
    }
    
    // Linked list
    fileprivate weak var fPrevious: W2DComponent? = nil
    fileprivate var fNext : W2DComponent? = nil
    
    open var head : W2DComponent
    {
        get
        {
            if let previous = fPrevious
            {
                var prev = previous
                while prev.fPrevious != nil
                {
                    prev = prev.fPrevious!
                }
                
                return prev
            }
            else
            {
                return self
            }
        }
    }
    
    open func addComponent(_ component:W2DComponent!)
    {
        assert(component.fPrevious == nil, "component should be detached")
        assert(component.fNext == nil, "component should be detached")
        
        // add at the end of list
        var c = self
        while let next = c.fNext
        {
            c = next
        }
        
        c.fNext = component
        component.fPrevious = c
        
        // notify all components
        var compToNotify : W2DComponent? = self
        while let comp  = compToNotify
        {
            comp.onComponentAdded(component)
            compToNotify = comp.fNext
        }
    }
    
    open func removeComponent()
    {
        let head = self.head
        
        if let prev = fPrevious
        {
            prev.fNext = fNext
        }
        
        if let next = fNext
        {
            next.fPrevious = fPrevious
        }
        
        fPrevious = nil
        fNext = nil
        
        // notify all components
        var compToNotify : W2DComponent? = head
        while let comp  = compToNotify
        {
            comp.onComponentRemoved(head, oldComponent: self)
            compToNotify = comp.fNext
        }
    }
    
    open func component<T>() -> T?
    {
        var comp :W2DComponent? = self
        
        // try forward
        while let c = comp
        {
            if let t = c as? T
            {
                return t
            }
            
            comp = c.fNext
        }
        
        // try backward
        comp = self.fPrevious
        while let c = comp
        {
            if let t = c as? T
            {
                return t
            }
            
            comp = c.fPrevious
        }
        
        return nil
    }
    
    // To be overridden
    open func onComponentAdded(_ newComponent:W2DComponent)
    {}
    
    open func onComponentRemoved(_ oldHead:W2DComponent, oldComponent:W2DComponent)
    {}
}
