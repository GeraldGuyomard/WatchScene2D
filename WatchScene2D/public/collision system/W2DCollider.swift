//
//  W2DCollider.swift
//  WatchPong
//
//  Created by Gérald Guyomard on 1/17/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

open class W2DCollider : W2DComponent
{
    open var isActive = true
    
    static open func collideInScene(_ scene:W2DScene!, movingNode:W2DNode!, direction:CGPoint, instantaneousSpeed:CGFloat) -> [W2DCollision]
    {
        var collisions = [W2DCollision]()
        let input = CollisionInput(movingNode: movingNode, direction: direction, instantaneousSpeed: instantaneousSpeed)
        
        _collideRecursive(scene, considerThisNode: false, input:input, collisions:&collisions)
        
        return collisions
    }
    
    public struct CollisionInput
    {
        public var movingNode : W2DNode
        public var movingNodeRadius : CGFloat
        public var movingNodeRadius2 : CGFloat
        public var movingNodePosition : CGPoint
        public var nextMovingNodePosition : CGPoint
        public var direction : CGPoint
        public var instantaneousSpeed : CGFloat
        public var moveVector : CGPoint
        public var movingBox : CGRect
        
        init(movingNode:W2DNode!, direction:CGPoint, instantaneousSpeed:CGFloat)
        {
            self.movingNode = movingNode
            
            let box = movingNode.globalBoundingBox
            movingNodeRadius = box.size.width / 2
            movingNodeRadius2 = movingNodeRadius * movingNodeRadius
            movingNodePosition = CGPoint(x: box.origin.x + movingNodeRadius, y: box.origin.y + movingNodeRadius)
            self.direction = direction
            self.instantaneousSpeed = instantaneousSpeed
            moveVector = direction.mul(instantaneousSpeed)
            nextMovingNodePosition = movingNodePosition.add(moveVector)
            
            var movedBox = box
            movedBox.origin = movedBox.origin.add(moveVector)
            
            movingBox = box.union(movedBox)
            
            assert(direction.norm().isNear(1))
        }
    }
    
    static fileprivate func _collideRecursive(_ node:W2DNode!, considerThisNode:Bool, input:CollisionInput, collisions:inout [W2DCollision])
    {
        if considerThisNode
        {
            let collider : W2DCollider? = node.component()
            if let c = collider
            {
                if let collision = c.collide(input)
                {
                    collisions.append(collision)
                }
            }
        }
        
        if let children = node.children
        {
            for child in children
            {
                _collideRecursive(child, considerThisNode: true, input:input, collisions:&collisions)
            }
        }
    }
    
    open var bounceSpeedFactor : CGFloat = 1.0
    
    open var collisionCallback : ((_ collision:inout W2DCollision) -> W2DCollision?)?

    open func collide(_ input:CollisionInput) -> W2DCollision?
    {
        if !self.isActive
        {
            return nil
        }
        
        let m : W2DNode? = component()
        guard let myNode = m
            else
        {
            return nil
        }
        
        // first easy rejections with AABBs
        let myBox = myNode.globalBoundingBox
        
        if (!myBox.intersects(input.movingBox))
        {
            return nil
        }
        
        // edge <-> moving node collision
        var vertices = myNode.globalBoundingVertices
        vertices.append(vertices.first!)
        
        let vCount = vertices.count - 1
        var collision : W2DCollision? = nil
        
        for index in 0..<vCount
        {
             if let c = collisionWithEdge2(  myNode,
                                            input:input,
                                            vertex1: vertices[index],
                                            vertex2: vertices[index + 1],
                                            edgeIndex: UInt(index))
            {
                if c.closerThan(collision)
                {
                    collision = c
                }
            }
        }

        
        if collision != nil
        {
            if let cb = self.collisionCallback
            {
                collision = cb(&collision!)
            }
        }
        
        /*if collision == nil
        {
            print("missed collision")
        }*/
        
        return collision
    }

    fileprivate func collisionWithEdge(_ myNode:W2DNode, input:CollisionInput, vertex1:CGPoint, vertex2:CGPoint, edgeIndex:UInt) ->W2DCollision?
    {
        let AB = vertex2.sub(vertex1)
        let AO = input.movingNodePosition.sub(vertex1)
        var edgeNormal = CGPoint(x: -AB.y, y: AB.x)
        
        if AO.dot(edgeNormal) <= 0
        {
            return nil
        }
        
        if input.direction.dot(edgeNormal) >= 0
        {
            return nil
        }
        
        let edgeLength = AB.norm()
        let invLength = 1.0 / edgeLength
        let v = AB.mul(invLength)
        assert(v.norm().isNear(1))
        
        let AH = AO.dot(v)
        
        if AH < -input.movingNodeRadius
        {
            return nil
        }
        
        if AH > (edgeLength + input.movingNodeRadius)
        {
            return nil
        }
        
        // perpendicular distance
        let squareOHLength = AO.squareNorm() - (AH * AH)
        if (squareOHLength > input.movingNodeRadius2)
        {
            return nil
        }
        
        edgeNormal = edgeNormal.mul(invLength)
        assert(edgeNormal.norm().isNear(1))
        
        // symetry of direction
        let sym = CGPoint.symmetry(edgeNormal, point: input.direction)
        // this is already normalized in theory but re normalize because of floating point inaccuracies
        let newDirection = CGPoint(x: -sym.x, y: -sym.y).normalizedVector()
        
        let hitPoint = vertex1.add(v.mul(AH))
        let distanceToEdge = sqrt(squareOHLength)
        
        return W2DCollision(   hitNode:myNode,
                            hitPoint:hitPoint,
            
                            movingNode:input.movingNode,
            
                            bounceDirection:newDirection,
                            bounceSpeedFactor:bounceSpeedFactor,
            
                            edgeIndex: edgeIndex,
                            distanceToEdge:distanceToEdge,
                            edgeNormal:edgeNormal)
    }
    
    fileprivate func collisionWithEdge2(_ myNode:W2DNode, input:CollisionInput, vertex1:CGPoint, vertex2:CGPoint, edgeIndex:UInt) ->W2DCollision?
    {
        let AO = input.movingNodePosition.sub(vertex1)
        
        let u = vertex2.sub(vertex1)
        var edgeNormal = CGPoint(x: -u.y, y: u.x)
        
        if AO.dot(edgeNormal) <= 0
        {
            return nil
        }
        
        if input.direction.dot(edgeNormal) >= 0
        {
            return nil
        }
        
        // Ray Intersection BEGIN
        let v = input.moveVector
        let det = (v.y * u.x) - (v.x * u.y)
        if det.isNear(0)
        {
            return nil
        }
        
        let start = input.movingNodePosition.add(input.direction.mul(input.movingNodeRadius))
        
        let dX = vertex1.x - start.x
        let dY = vertex1.y - start.y
        
        var rayHit = false
        let a = (-u.y * dX  + u.x * dY) / det
        if (a >= 0) && (a <= 1)
        {
            let b = (-v.y * dX + v.x * dY) / det
            rayHit = (b >= 0) && (b <= 1)
        }
        
        // Ray Intersection END
        
        // find the closest position to edge
        
        let edgeLength = u.norm()
        let invLength = 1.0 / edgeLength
        let uUnit = u.mul(invLength)
        assert(uUnit.norm().isNear(1))
        
        let AH = AO.dot(uUnit)
        
        // perpendicular distance
        let squareOHLength = AO.squareNorm() - (AH * AH)
        if !rayHit && squareOHLength > input.movingNodeRadius2
        {
            return nil
        }
        
        edgeNormal = edgeNormal.mul(invLength)
        assert(edgeNormal.norm().isNear(1))
        
        // symetry of direction
        let sym = CGPoint.symmetry(edgeNormal, point: input.direction)
        // this is already normalized in theory but re normalize because of floating point inaccuracies
        let newDirection = CGPoint(x: -sym.x, y: -sym.y).normalizedVector()
        
        let hitPoint = vertex1.add(uUnit.mul(AH))
        let distanceToEdge = sqrt(squareOHLength)
        
        return W2DCollision(   hitNode:myNode,
            hitPoint:hitPoint,
            
            movingNode:input.movingNode,
            
            bounceDirection:newDirection,
            bounceSpeedFactor:bounceSpeedFactor,
            
            edgeIndex: edgeIndex,
            distanceToEdge:distanceToEdge,
            edgeNormal:edgeNormal)

     }
}
