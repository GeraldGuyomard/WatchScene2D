//
//  W2DDirector.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/17/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

public protocol W2DDirector
{
    var context : W2DContext { get }
    var currentScene : W2DScene? { get set }
    var dT : NSTimeInterval { get }
    
    func setupDigitalCrownInput(picker picker:WKInterfacePicker, sensitivity:UInt)
    func setDigitalCrownValue(value:Float) // 0..1
    func processDigitalCrownInput(input:NSInteger, handler:(Float) -> Void)
    
    func start()
    func stop()
    
    func addBehavior(behavior:W2DBehavior)
    func removeBehavior(behavior:W2DBehavior)
    
}

public func createW2DDirector(target:WKInterfaceImage, context:W2DContext) -> W2DDirector
{
    return W2DDirectorImpl(target: target, context: context)
}