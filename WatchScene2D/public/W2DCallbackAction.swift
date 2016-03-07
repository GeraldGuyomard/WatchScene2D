//
//  W2DCallbackAction.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 3/6/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import Foundation

public class W2DCallbackAction : W2DFiniteDurationAction
{
    private var fCallback : (W2DNode?) -> Void
    
    public init(callback:(W2DNode?) -> Void)
    {
        fCallback = callback;
        super.init(duration: 0)
    }
    
    public override func execute(dT: NSTimeInterval, director: W2DDirector!)
    {
        assert(fIsRunning)
        
        fCallback(self.target)
        
        onDone(true)
    }
}