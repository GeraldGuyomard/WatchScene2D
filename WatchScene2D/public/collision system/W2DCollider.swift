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
        otherMovedBox.origin = otherMovedBox.origin.add(direction.mul(instantaneousSpeed))
        
        let otherMovingBox = CGRectUnion(otherBox, otherMovedBox)
        
        if (!myBox.intersects(otherMovingBox))
        {
            return nil
        }
        
        // edge <-> moving node collision
        var radius = otherBox.size.width / 2.0
        if instantaneousSpeed > radius
        {
            radius = instantaneousSpeed
        }
        
        let pos = CGPointMake(otherBox.origin.x + radius, otherBox.origin.y + radius)
        
        let A = myBox.origin
        let B = CGPointMake(myBox.origin.x, myBox.origin.y + myBox.size.height)
        let C = CGPointMake(myBox.origin.x + myBox.size.width, myBox.origin.y + myBox.size.height)
        let D = CGPointMake(myBox.origin.x + myBox.size.width, myBox.origin.y)
        
        let vertices = [A, B, C, D, A]
        let vCount = vertices.count - 1
        var collision : W2DCollision? = nil
        
        for index in 0..<vCount
        {
             if let c = collisionWithEdge(  myNode,
                                            movingNode: movingNode,
                                            otherNodePosition: pos,
                                            otherNodeRadius: radius,
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

    private func collisionWithEdge(myNode:W2DNode, movingNode:W2DNode, otherNodePosition:CGPoint, otherNodeRadius:CGFloat, vertex1:CGPoint, vertex2:CGPoint, edgeIndex:UInt, direction:CGPoint) ->W2DCollision?
    {
        let AB = vertex2.sub(vertex1)
        let AO = otherNodePosition.sub(vertex1)
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
        
        let AH = AO.dot(v)
        if AH < -otherNodeRadius
        {
            return nil
        }
        
        if AH > edgeLength
        {
            return nil
        }
        
        // perpendicular distance
        let squareOHLength = AO.squareNorm() - (AH * AH)
        if squareOHLength > (otherNodeRadius * otherNodeRadius)
        {
            // too far
            return nil
        }
        
        // symetry of direction
        let m00 = (v.y * v.y) - (v.x * v.x)
        let m10 = -2 * v.x * v.y
        let m01 = m10
        let m11 = -m00
        
        let symX = (m00 * direction.x) + (m01 * direction.y)
        let symY = (m10 * direction.y) + (m11 * direction.y)
        
        let newDirection = CGPointMake(-symX, -symY)
        
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
