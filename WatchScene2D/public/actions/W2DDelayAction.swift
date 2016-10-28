//
//  W2DDelayAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 5/13/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

open class W2DDelayAction : W2DSimpleFiniteDurationAction
{
    open override func run(_ dT: TimeInterval, director: W2DDirector!)
    {
        // do nothing, simple wait...
    }
}
