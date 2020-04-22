//
//  ARFunctions.swift
//  AlternativeARKit
//
//  Created by Zheng on 4/21/20.
//  Copyright © 2020 Zheng. All rights reserved.
//

import UIKit

extension ViewController {
    
    
    func placeHighlights(rects: [CGRect]) {
     
        for highlight in drawingView.subviews {
            UIView.animate(withDuration: 0.2, animations: {
                highlight.alpha = 0
            }) { _ in
                highlight.removeFromSuperview()
            }
        }
        
        for rectangle in rects {
            
            
           
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: 0, y: 0, width: rectangle.width, height: rectangle.height)
            layer.cornerRadius = rectangle.height / 3.5
            
            let newLayer = CAShapeLayer()
            newLayer.bounds = layer.frame
            newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: rectangle.height / 3.5).cgPath
            newLayer.lineWidth = 3
            newLayer.lineCap = .round
            
    
            let x = newLayer.bounds.size.width / 2
            let y = newLayer.bounds.size.height / 2
            newLayer.position = CGPoint(x: x, y: y)
            
            
            newLayer.fillColor = #colorLiteral(red: 0.6502560775, green: 0.9603669892, blue: 1, alpha: 0.3)
            newLayer.strokeColor = #colorLiteral(red: 0, green: 0.6823529412, blue: 0.937254902, alpha: 1)
            layer.addSublayer(newLayer)
            

            let highlight = UIView(frame: CGRect(x: rectangle.origin.x, y: rectangle.origin.y, width: rectangle.width, height: rectangle.height))
            highlight.alpha = 0
            
            highlight.layer.addSublayer(layer)
            drawingView.addSubview(highlight)
            
            
            UIView.animate(withDuration: 0.2, animations: {
                highlight.alpha = 1
            })
            
            
            
        }
        
    }
    
}
