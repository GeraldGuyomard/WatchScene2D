//
//  W2DBehavior.swift
//  WatchScene2D
//
//  Created by Gérald Guyomard on 10/18/15.
//  Copyright © 2015 Gérald Guyomard. All rights reserved.
//

import Foundation

public protocol W2DBehavior : class
{
    func execute(_ dT:TimeInterval, director:W2DDirector!)
}
