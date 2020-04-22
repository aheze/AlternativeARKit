//
//  VisionOCR.swift
//  AlternativeARKit
//
//  Created by Zheng on 4/21/20.
//  Copyright © 2020 Zheng. All rights reserved.
//

import UIKit
import Vision

extension ViewController {
    func findUsingVision(in pixelBuffer: CVPixelBuffer) {
            //print("find")
        busyPerformingVisionRequest = true
       
        DispatchQueue.global(qos: .background).async {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let width = ciImage.extent.width
            let height = ciImage.extent.height
            self.aspectRatioWidthOverHeight = height / width ///opposite, because the pixelbuffer is sideways
            
            let request = VNRecognizeTextRequest { request, error in
                self.handleFastDetectedText(request: request, error: error)
            }
            
            let lowercased = self.textToFind.lowercased()
            let uppercased = self.textToFind.uppercased()
            
            request.customWords = [self.textToFind, lowercased, uppercased]
            
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["en_GB"]
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
            ///It needs to be .right because the image is given to us sideways
            do {
                try imageRequestHandler.perform([request])
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    func handleFastDetectedText(request: VNRequest?, error: Error?) {
        guard let results = request?.results, results.count > 0 else {
            busyPerformingVisionRequest = false
            return
        }
        var rectangles = [CGRect]()
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for returnedObject in observation.topCandidates(1) {
                    
                    let originalFoundText = returnedObject.string
                    
                    var x = observation.boundingBox.origin.x
                    var y = 1 - observation.boundingBox.origin.y
                    var height = observation.boundingBox.height
                    var width = observation.boundingBox.width
                    
                    let lowerCaseComponentText = originalFoundText.lowercased()
                    
                    let convertedOriginalWidthOfBigImage = aspectRatioWidthOverHeight * deviceSize.height
                    let offsetWidth = convertedOriginalWidthOfBigImage - deviceSize.width
                    let offHalf = offsetWidth / 2
                    
                    width *= convertedOriginalWidthOfBigImage
                    height *= deviceSize.height
                    x *= convertedOriginalWidthOfBigImage
                    x -= offHalf
                    y *= deviceSize.height
                    y -= height
                    
                    let rect = CGRect(x: x, y: y, width: width, height: height)
                    drawFastHighlight(component: rect)
                    let individualCharacterWidth = width / CGFloat(originalFoundText.count)
                    let newWidth = individualCharacterWidth * CGFloat(textToFind.count)
                    
                    if lowerCaseComponentText.contains(textToFind.lowercased()) {
                        let indicies = lowerCaseComponentText.indicesOf(string: textToFind.lowercased())
                        for index in indicies {
                            let addedWidth = individualCharacterWidth * CGFloat(index)
                            let newX = x + addedWidth
                            
                            let finalX = newX - 6
                            let finalY = y - 3
                            let finalWidth = newWidth + 12
                            let finalHeight = height + 6
                            
//                            print("\(originalFoundText) | Position: x: \(finalX), y: \(y), width: \(width), height: \(height)")
                            let rect = CGRect(x: finalX, y: finalY, width: finalWidth, height: finalHeight)
                            rectangles.append(rect)
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.placeHighlights(rects: rectangles)
        }
        busyPerformingVisionRequest = false
    }
    func drawFastHighlight(component: CGRect) {
        DispatchQueue.main.async {
            let newW = component.width
            let newH = component.height
            
            let buffer = CGFloat(3)
            let doubBuffer = CGFloat(6)
            let newX = component.origin.x
            let newY = component.origin.y
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: newX - buffer, y: newY, width: newW + doubBuffer, height: newH)
            layer.cornerRadius = newH / 3.5
            self.animateFastChange(layer: layer)
        }
    }
    func animateFastChange(layer: CAShapeLayer) {
         view.layer.insertSublayer(layer, above: cameraView.layer)
         layer.masksToBounds = true
         let gradient = CAGradientLayer()
         gradient.frame = layer.bounds
         gradient.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0.7220415609, green: 0.7220415609, blue: 0.7220415609, alpha: 0.3010059932).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor]
         gradient.startPoint = CGPoint(x: -1, y: 0.5)
         gradient.endPoint = CGPoint(x: 0, y: 0.5)
         layer.addSublayer(gradient)
         
         let startPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
         startPointAnim.fromValue = CGPoint(x: -1, y: 0.5)
         startPointAnim.toValue = CGPoint(x:1, y: 0.5)

         let endPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
         endPointAnim.fromValue = CGPoint(x: 0, y: 0.5)
         endPointAnim.toValue = CGPoint(x:2, y: 0.5)

         let animGroup = CAAnimationGroup()
         animGroup.animations = [startPointAnim, endPointAnim]
         animGroup.duration = 0.6
         animGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
         animGroup.repeatCount = 0
         gradient.add(animGroup, forKey: "animateGrad")
    
         DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
             layer.removeFromSuperlayer()
         })
     }
}
