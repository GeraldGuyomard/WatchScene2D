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
    
    func clear(_ rect:CGRect)
    func fillRect(_ rect:CGRect, withColor color:W2DColor4f)
    
    func image(named name:String) -> W2DImage?
    
    func render() -> UIImage?
    func render(_ dirtyRects: [CGRect]?) -> UIImage?
    
    func saveState()
    func restoreState()
    
    func applyTransform(_ transform:CGAffineTransform)
    func applyClipping(_ rect:CGRect)
}

public func createW2DContext(width:UInt, height:UInt) -> W2DContext
{
    return W2DContextImpl(width: width, height: height)
}
