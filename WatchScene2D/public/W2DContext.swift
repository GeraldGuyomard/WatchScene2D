//
//  W2DContext.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/7/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import WatchKit

public protocol W2DContext
{
    var width : UInt { get }
    var height : UInt { get }
    var clippingRect : CGRect? { get }
    
    func clear(color:W2DColor4f)
    func fillRect(rect:CGRect, withColor color:W2DColor4f)
    
    func image(named name:String) -> W2DImage?
    
    func render() -> UIImage?
    func render(dirtyRects: [CGRect]?) -> UIImage?
    
    func saveState()
    func restoreState()
    
    func applyTransform(transform:CGAffineTransform)
    func applyClipping(rect:CGRect)
}

public func createW2DContext(width width:UInt, height:UInt) -> W2DContext
{
    return W2DContextImpl(width: width, height: height)
}
