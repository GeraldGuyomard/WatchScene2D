//
//  W2DComponent.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 12/6/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

public class W2DComponent
{
    public init()
    {
    }
    
    // Linked list
    private weak var fPrevious: W2DComponent? = nil
    private var fNext : W2DComponent? = nil
    
    public func addComponent(component:W2DComponent!)
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
    }
    
    public func removeComponent()
    {
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
    }
    
    public func component<T>() -> T?
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
}