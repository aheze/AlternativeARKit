//
//  ARFunctions.swift
//  AlternativeARKit
//
//  Created by Zheng on 4/21/20.
//  Copyright © 2020 Zheng. All rights reserved.
//

import UIKit

/// Add this:
import CoreMotion

extension ViewController {
    func updateHighlightOrientations(attitude: CMAttitude) {
        /// initialAttitude is an optional that points to the reference frame that the device started at
        /// we set this when the device lays out it's subviews on the first launch
        if let initAttitude = initialAttitude {
            
            /// We can now translate the current attitude to the reference frame
            attitude.multiply(byInverseOf: initAttitude)
            
            /// Roll is the movement of the phone left and right, Pitch is forwards and backwards
            let rollValue = attitude.roll.radiansToDegrees
            let pitchValue = attitude.pitch.radiansToDegrees
            
            /// This is a magic number, but for simplicity, we won't do any advanced trigonometry -- also, 10 works pretty well
            let conversion = Double(10)
            
            /// Here, we figure out how much the values changed by comparing against the previous values (motionX and motionY)
            let differenceInX = (rollValue - motionX) * conversion
            let differenceInY = (pitchValue - motionY) * conversion
            
            /// Now we adjust every highlight's potision
            for highlight in previousHighlightComponents {
                highlight.frame.origin.x += CGFloat(differenceInX)
                highlight.frame.origin.y += CGFloat(differenceInY)
            }
            
            /// finally, we put the new attitude values into motionX and motionY so we can compare against them in 0.03 seconds (the next time this function is called)
            motionX = rollValue
            motionY = pitchValue
        }
    }
    
    func placeHighlights(atTheseLocations rectangles: [CGRect]) {
        
//        if let currentMotion = motionManager.deviceMotion {
//            motionX = Double(0)
//            motionY = Double(0)
//            initialAttitude = currentMotion.attitude
//        }
        
        /// ↓ We're going to do more than just simple fade transitions, so remove or comment out the following ↓
        
        // -----------------------------------------------------------------
        /// First, we'll remove all the existing highlights in the drawingView
//        for highlight in drawingView.subviews {
//
//            /// Fading it out
//            UIView.animate(withDuration: 0.3, animations: {
//                highlight.alpha = 0
//            }) { _ in
//
//                /// Then removing it once it's finished fading
//                highlight.removeFromSuperview()
//            }
//        }
        // -----------------------------------------------------------------
        
        /// this will be the updated views that will be currently shown to the user
        var currentViews = [UIView]()
        
        /// this is the maximum distance that we'll consider "near"
        /// if any old highlight is less than this, we'll animate this to the new position
        let maximumNearDistance = CGFloat(8)
        
        /// We're going to be efficient and instead of using the Distance Formula, we're going to use a modified version of it
        /// the modified Distance Formula is the exact same, except we're not square rooting at the end
        /// this saves a lot of processing power, as we'll just compare the non-square-rooted result with maximumNearDistanceSquared
        let maximumNearDistanceSquared = pow(maximumNearDistance, 2)
        
        /// we're going to loop through the rectangles, adding a highlight "in real life" every time
        /// except now, if a previous highlight is less than 8 points away from one that we're about to add, we'll reuse it and animate it to the new position
        for rectangle in rectangles {
            
            /// We're going to add a variable called lowestDist.
            /// Later, we'll check if this is under 64.
            var lowestDist = CGFloat(10000)
            
            /// This is a dictionary mapping distances to UIViews.
            var distToView = [CGFloat: UIView]()
            
            /// previousHighlightComponents are the highlights that are currently on the screen (those that we're going to update)
            for oldView in previousHighlightComponents {
                
                /// we're going to loop over previousHighlightComponents to check if any view is NEAR the the current rectangle that we're going to place
                let currentCompPoint = CGPoint(x: rectangle.origin.x, y: rectangle.origin.y)
                let oldCompPoint = CGPoint(x: oldView.frame.origin.x, y: oldView.frame.origin.y)
                
                /// because normal Distance Formula(includes square rooting) is time consuming, relativeDistance doesn't square it at the end
                /// this is perfectly fine for out case because we're only comparing distances and we don't actually need an accurate distance.
                let distanceBetweenPoints = relativeDistance(currentCompPoint, oldCompPoint)
                
                /// If the distance is lower than any previous distances, we'll make this the lowestDist
                if distanceBetweenPoints <= lowestDist {
                    lowestDist = distanceBetweenPoints
                    
                    /// we're going to map the previous highlight to the lowest dist
                    distToView[lowestDist] = oldView
                }
            }
            
            /// maximumNearDistanceSquared is a magic number, but it works pretty fine in our case (square root of 64 is 8)
            /// so if there is a previous view that is 8 points away, we'll reuse it and slide it into the new position
            if lowestDist <= maximumNearDistanceSquared {
                
                guard let oldView = distToView[lowestDist] else {
                    return
                }
                
                /// these are the views that will be currently (this Vision pass) shown to the user
                currentViews.append(oldView)
                UIView.animate(withDuration: 0.5, animations: {
                    
                    /// reuse and slide the oldView over
                    oldView.frame = rectangle
                })
                
            } else {
                /// There's no previous highlight that's near it, so we'll just fade it in
                
                let highlight = UIView(frame: CGRect(x: rectangle.origin.x, y: rectangle.origin.y, width: rectangle.width, height: rectangle.height))
                
                /// alpha is 0 right now because we're going to fade it in
                highlight.alpha = 0

                /// we're going to draw a rounded rectangle
                let newLayer = CAShapeLayer()
                let layerRect = CGRect(x: 0, y: 0, width: rectangle.width, height: rectangle.height)
                newLayer.bounds = layerRect
                newLayer.path = UIBezierPath(roundedRect: layerRect, cornerRadius: rectangle.height / 3.5).cgPath
                newLayer.lineWidth = 3

                /// set the position of the rounded rectangle (by default it would appear centered in the upper left corner, we don't want that)
                let x = newLayer.bounds.size.width / 2
                let y = newLayer.bounds.size.height / 2
                newLayer.position = CGPoint(x: x, y: y)

                /// Color of the highlights
                newLayer.fillColor =  #colorLiteral(red: 0.6502560775, green: 0.9603669892, blue: 1, alpha: 0.3)
                newLayer.strokeColor =  #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)

                /// Add the rounded rectangle to the highlight (a UIView)
                highlight.layer.addSublayer(newLayer)

                /// we'll add the highlight to the drawingView now
                drawingView.addSubview(highlight)
                
                /// ↓ ADD THIS ↓ (these are the views that will be currently (this Vision pass) shown to the user)
                currentViews.append(highlight)

                /// and finally, we'll fade it in!
                UIView.animate(withDuration: 0.3, animations: {
                    highlight.alpha = 1
                })
            }

        }
        
        /// Now, we'll fade out the old highlights, EXCEPT those that we reused and animated to a new position
        for oldView in previousHighlightComponents {
            
            /// currentViews is the array of highlights that will be currently shown to the user, including the reused old highlights
            /// so if the currentViews doesn't contain oldView, we know that we don't need it anymore and we'll fade it out
            if !currentViews.contains(oldView) {
                UIView.animate(withDuration: 0.3, animations: {
                    oldView.alpha = 0
                }, completion: { _ in
                    
                    /// remove it from drawingView now
                    oldView.removeFromSuperview()
                })
            }
            
        }
        
        /// Once we're done doing all the UI updates, we're going to make previousHighlightComponents the currentViews
        /// Because currentViews will no longer be current in the next Vision pass
        /// In the next Vision pass, we'll be comparing positions against previousHighlightComponents again!
        previousHighlightComponents = currentViews
    }
    
    /// This is the Distance Formula, except we're not going to square the result
    /// Not squaring the result saves a lot of processing power
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
