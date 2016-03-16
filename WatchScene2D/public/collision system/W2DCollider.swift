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
        _collideRecursive(scene, considerThisNode: false, movingNode:movingNode, direction:direction, instantaneousSpeed:instantaneousSpeed, collisions:&collisions)
        return collisions
    }
    
    static private func _collideRecursive(node:W2DNode!, considerThisNode:Bool, movingNode:W2DNode!, direction:CGPoint, instantaneousSpeed:CGFloat, inout collisions:[W2DCollision])
    {
        if considerThisNode
        {
            let collider : W2DCollider? = node.component()
            if let c = collider
            {
                if let collision = c.collide(movingNode, direction: direction, instantaneousSpeed:instantaneousSpeed)
                {
                    collisions.append(collision)
                }
            }
        }
        
        if let children = node.children
        {
            for child in children
            {
                _collideRecursive(child, considerThisNode: true, movingNode:movingNode, direction: direction, instantaneousSpeed: instantaneousSpeed, collisions:&collisions)
            }
        }
    }
    
    public var bounceSpeedFactor : CGFloat = 1.0
    
    public var collisionCallback : ((collision:W2DCollision) -> W2DCollision?)?

    public func collide(movingNode:W2DNode!, direction:CGPoint, instantaneousSpeed:CGFloat) -> W2DCollision?
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
        let otherBox = movingNode.globalBoundingBox
        
        var otherMovedBox = otherBox
        let moveVector = direction.mul(instantaneousSpeed)
        otherMovedBox.origin = otherMovedBox.origin.add(moveVector)
        
        let otherMovingBox = CGRectUnion(otherBox, otherMovedBox)
        
        if (!myBox.intersects(otherMovingBox))
        {
            return nil
        }
        
        // edge <-> moving node collision
        var radius = otherBox.size.width / 2.0
        /*if instantaneousSpeed > radius
        {
            radius = instantaneousSpeed
        }*/
        
        let pos = CGPointMake(otherBox.origin.x + radius, otherBox.origin.y + radius)
        let nextPos = pos.add(moveVector)
        
        let vertices = W2DCollider.boundingVertices(myNode)
        
        let vCount = vertices.count - 1
        var collision : W2DCollision? = nil
        
        for index in 0..<vCount
        {
             if let c = collisionWithEdge(  myNode,
                                            movingNode: movingNode,
                                            movingNodePosition: pos,
                                            movingNodeNextPosition: nextPos,
                                            movingNodeRadius: radius,
                                            vertex1: vertices[index],
                                            vertex2: vertices[index + 1],
                                            edgeIndex: UInt(index),
                                            direction:direction)
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
    
    private func collisionWithEdge(myNode:W2DNode, movingNode:W2DNode, movingNodePosition:CGPoint, movingNodeNextPosition:CGPoint, movingNodeRadius:CGFloat, vertex1:CGPoint, vertex2:CGPoint, edgeIndex:UInt, direction:CGPoint) ->W2DCollision?
    {
        assert(direction.norm().isNear(1))
        
        let AB = vertex2.sub(vertex1)
        let AO = movingNodePosition.sub(vertex1)
        var edgeNormal = CGPointMake(-AB.y, AB.x)
        
        if AO.dot(edgeNormal) <= 0
        {
            return nil
        }
        
        if direction.dot(edgeNormal) >= 0
        {
            return nil
        }
        
        let edgeLength = AB.norm()
        let invLength = 1.0 / edgeLength
        let v = AB.mul(invLength)
        assert(v.norm().isNear(1))
        
        let AH = AO.dot(v)
        if AH < -movingNodeRadius
        {
            return nil
        }
        
        if AH > edgeLength
        {
            return nil
        }
        
        // perpendicular distance
        let squareOHLength = AO.squareNorm() - (AH * AH)
        if squareOHLength > (movingNodeRadius * movingNodeRadius)
        {
            // too far but maybe next position will cross this edge...
            let AP = movingNodeNextPosition.sub(vertex1)
            if AP.dot(edgeNormal) < 0
            {
                return nil
            }
            else
            {
                // crossed edge indeed
            }
        }
        
        // symetry of direction
        let m00 = (v.y * v.y) - (v.x * v.x)
        let m10 = -2 * v.x * v.y
        let m01 = m10
        let m11 = -m00
        
        let symX = (m00 * direction.x) + (m01 * direction.y)
        let symY = (m10 * direction.x) + (m11 * direction.y)
        
        // this is already normalized in theory but re normalize because of floating point inaccuracies
        let newDirection = CGPointMake(-symX, -symY).normalizedVector()
        
        let hitPoint = vertex1.add(v.mul(AH))
        let distanceToEdge = sqrt(squareOHLength)
        
        edgeNormal = edgeNormal.mul(invLength)
        
        return W2DCollision(   hitNode:myNode,
                            hitPoint:hitPoint,
            
                            movingNode:movingNode,
            
                            bounceDirection:newDirection,
                            bounceSpeedFactor:bounceSpeedFactor,
            
                            edgeIndex: edgeIndex,
                            distanceToEdge:distanceToEdge,
                            edgeNormal:edgeNormal)
    }
}
