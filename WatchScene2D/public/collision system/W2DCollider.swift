//
//  W2DCollider.swift
//  WatchPong
//
//  Created by Gérald Guyomard on 1/17/16.
//  Copyright © 2016 Gérald Guyomard. All rights reserved.
//

import WatchKit
import Foundation

public class W2DCollider : W2DComponent
{
    public var isActive = true
    
    static public func collideInScene(scene:W2DScene!, movingNode:W2DNode!, direction:CGPoint, instantaneousSpeed:CGFloat) -> [W2DCollision]
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
            movingNodePosition = CGPointMake(box.origin.x + movingNodeRadius, box.origin.y + movingNodeRadius)
            self.direction = direction
            self.instantaneousSpeed = instantaneousSpeed
            moveVector = direction.mul(instantaneousSpeed)
            nextMovingNodePosition = movingNodePosition.add(moveVector)
            
            var movedBox = box
            movedBox.origin = movedBox.origin.add(moveVector)
            
            movingBox = CGRectUnion(box, movedBox)
            
            assert(direction.norm().isNear(1))
        }
    }
    
    static private func _collideRecursive(node:W2DNode!, considerThisNode:Bool, input:CollisionInput, inout collisions:[W2DCollision])
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
    
    public var bounceSpeedFactor : CGFloat = 1.0
    
    public var collisionCallback : ((collision:W2DCollision) -> W2DCollision?)?

    public func collide(input:CollisionInput) -> W2DCollision?
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
        let vertices = W2DCollider.boundingVertices(myNode)
        
        let vCount = vertices.count - 1
        var collision : W2DCollision? = nil
        
        for index in 0..<vCount
        {
             if let c = collisionWithEdge(  myNode,
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

        
        if let c = collision
        {
            if let cb = self.collisionCallback
            {
                collision = cb(collision: c)
            }
        }
        
        if collision == nil
        {
            print("missed collision")
        }
        
        return collision
    }

    static private func boundingVertices(node:W2DNode) -> [CGPoint]
    {
        if node.rotation == 0
        {
            let box = node.globalBoundingBox
            
            let A = box.origin
            let B = CGPointMake(box.origin.x, box.origin.y + box.size.height)
            let C = CGPointMake(box.origin.x + box.size.width, box.origin.y + box.size.height)
            let D = CGPointMake(box.origin.x + box.size.width, box.origin.y)
            
            return [A, B, C, D, A]
        }
        else
        {
            let t = node.globalTransform
            let size = node.size
            
            let A = CGPointApplyAffineTransform(CGPointMake(0, 0), t)
            let B = CGPointApplyAffineTransform(CGPointMake(0, size.height), t)
            let C = CGPointApplyAffineTransform(CGPointMake(size.width, size.height), t)
            let D = CGPointApplyAffineTransform(CGPointMake(size.width, 0), t)
            
            return [A, B, C, D, A]
        }
    }
    
    private func collisionWithEdge(myNode:W2DNode, input:CollisionInput, vertex1:CGPoint, vertex2:CGPoint, edgeIndex:UInt) ->W2DCollision?
    {
        let AB = vertex2.sub(vertex1)
        let AO = input.movingNodePosition.sub(vertex1)
        var edgeNormal = CGPointMake(-AB.y, AB.x)
        
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
        
        // symetry of direction
        let m00 = (v.y * v.y) - (v.x * v.x)
        let m10 = -2 * v.x * v.y
        let m01 = m10
        let m11 = -m00
        
        let symX = (m00 * input.direction.x) + (m01 * input.direction.y)
        let symY = (m10 * input.direction.x) + (m11 * input.direction.y)
        
        // this is already normalized in theory but re normalize because of floating point inaccuracies
        let newDirection = CGPointMake(-symX, -symY).normalizedVector()
        
        let hitPoint = vertex1.add(v.mul(AH))
        let distanceToEdge = sqrt(squareOHLength)
        
        edgeNormal = edgeNormal.mul(invLength)
        assert(edgeNormal.norm().isNear(1))
        
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
