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
    init(size:CGSize)
    
    func render()
}

public func createW2DContext(size:CGSize) -> W2DContext
{
    return W2DContextImpl(size:size)
}
