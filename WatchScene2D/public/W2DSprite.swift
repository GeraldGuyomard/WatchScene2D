//
//  W2DSprite.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 11/2/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit

public class W2DSprite : W2DNode
{
    private var fImage : W2DImage?
    
    public init(image:W2DImage?)
    {
        super.init()
        
        self.image = image
    }
    
    public init(named name:String, inContext context: W2DContext)
    {
        super.init()
        
        let img = context.image(named:name)
        self.image = img
    }
    
    public var image : W2DImage?
    {
        get { return fImage }
        
        set(newImage)
        {
            fImage = newImage
            
            if let img = fImage
            {
                self.size = img.size
            }
            else
            {
                self.size = CGSizeMake(0, 0)
            }
        }
    }
    
    override public func selfRender(context: W2DContext)
    {
        if let img = self.image
        {
            let s = self.size
            let rect = CGRectMake(0, 0, s.width, s.height)
            img.draw(rect)
        }
    }
}