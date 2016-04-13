//
//  W2DDirector.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/17/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

public typealias W2DActionManager = W2DBehaviorGroup

public protocol W2DDirector : class
{
    var context : W2DContext { get }
    var currentScene : W2DScene? { get set }
    var frameRate : UInt { get set }
    var dT : NSTimeInterval { get }
    var smartRedrawEnabled : Bool { get set }
    var showDirtyRects : Bool { get set }
    var actionManager : W2DActionManager { get }
    
    func setupDigitalCrownInput(picker picker:WKInterfacePicker, sensitivity:UInt)
    func setDigitalCrownValue(value:Float) // 0..1
    func processDigitalCrownInput(input:NSInteger, handler:(Float) -> Void)
    
    func start()
    func stop()
    
    func addBehavior(behavior:W2DBehavior)
    func removeBehavior(behavior:W2DBehavior)
    
    func setNeedsRedraw(rect : CGRect)
    func setNeedsFullRedraw()
}

public func createW2DDirector(target:WKInterfaceObject, context:W2DContext) -> W2DDirector
{
    return W2DDirectorImpl(target: target, context: context)
}