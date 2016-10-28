//
//  W2DImage.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/18/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

public protocol W2DImage
{
    var size : CGSize { get }
    
    func draw(_ pos:CGPoint)
    func draw(_ pos:CGPoint, alpha:CGFloat)
    
    func draw(_ rect:CGRect)
    func draw(_ rect:CGRect, alpha:CGFloat)
}
