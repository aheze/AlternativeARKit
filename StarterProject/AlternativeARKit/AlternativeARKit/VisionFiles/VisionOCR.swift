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
        
        busyPerformingVisionRequest = true
       
        DispatchQueue.global(qos: .userInitiated).async {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let width = ciImage.extent.width
            let height = ciImage.extent.height
            
            self.aspectRatioWidthOverHeight = height / width /// opposite, because the pixelbuffer is given to us sideways
            
            let request = VNRecognizeTextRequest { request, error in
                /// this function will be called when the Vision request finishes
                self.handleFastDetectedText(request: request, error: error)
            }
            
            
            let lowercased = self.textToFind.lowercased()
            let uppercased = self.textToFind.uppercased()
            
            /// Custom words are the words that get recognized more often than normal words. This is very important for getting optimal Vision results.
            request.customWords = [self.textToFind, lowercased, uppercased]
            
            /// .fast is REALLY fast. It's great for processing live video, like that we're doing.
            request.recognitionLevel = .fast
            request.recognitionLanguages = ["en_GB"]
            
            ///It needs to be .right because the pixelbuffer is given to us sideways
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
            
            do {
                try imageRequestHandler.perform([request])
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    func handleFastDetectedText(request: VNRequest?, error: Error?) {
        /// We make sure that the results is not nil and there is at least one
        guard let results = request?.results, results.count > 0 else {
            busyPerformingVisionRequest = false
            return
        }
        
        for result in results {
            
            
            if let observation = result as? VNRecognizedTextObservation {
                
                /// topCandidates(1) returns us what Vision thinks are the most accurate results.
                /// It's a scale from 1 to 10, 1 is most accurate, 10 is least accurate and returns 10 different groups of words.
                for returnedObject in observation.topCandidates(1) {
                    
                    /// this is the text that Visino detects
                    let originalFoundText = returnedObject.string
                    
                    var x = observation.boundingBox.origin.x
                    var y = 1 - observation.boundingBox.origin.y
                    var height = observation.boundingBox.height
                    var width = observation.boundingBox.width
                    
                    /// We're not going have Vision be case-sensitive
                    let lowerCaseComponentText = originalFoundText.lowercased()
                    
                    /// we're going to do some converting
                    let convertedOriginalWidthOfBigImage = aspectRatioWidthOverHeight * deviceSize.height
                    let offsetWidth = convertedOriginalWidthOfBigImage - deviceSize.width
                    
                    /// The pixelbuffer that we got Vision to process is bigger then the device's screen, so we need to adjust it
                    let offHalf = offsetWidth / 2
                    
                    width *= convertedOriginalWidthOfBigImage
                    height *= deviceSize.height
                    x *= convertedOriginalWidthOfBigImage
                    x -= offHalf
                    y *= deviceSize.height
                    y -= height
                    
                    /// we're going to get the width of each character so we can correctly determine the x-position of matched text
                    let individualCharacterWidth = width / CGFloat(originalFoundText.count)
                    
                    /// this is the width of the word that we're looking for (in this case, "ARKit", or whatever textToFind is)
                    let newWidth = individualCharacterWidth * CGFloat(textToFind.count)
                    
                    /// Again, not case-sensitive
                    if lowerCaseComponentText.contains(textToFind.lowercased()) {
                        
                        /// We take into account that each sentence could have multiple matches.
                        /// indiciesOf is an extension that gives up the indicies of text that we want to find
                        /// For example,
                        // lowerCaseComponentText = "ARKit is cool, ARKit is ok"
                        /// indiciesOf will return [0, 15]
                        let indicies = lowerCaseComponentText.indicesOf(string: textToFind.lowercased())
                        for index in indicies {
                            
                            /// We're going to adjust the x-position of the rectangle that we're going to place based on its index
                            let addedWidth = individualCharacterWidth * CGFloat(index)
                            let newX = x + addedWidth
                            
                            ///Add some buffer space
                            let finalX = newX - 6
                            let finalY = y - 3
                            let finalWidth = newWidth + 12
                            let finalHeight = height + 6
                            
                            print("\"\(originalFoundText)\" | Position: x: \(finalX), y: \(finalY), width: \(finalWidth), height: \(finalHeight)")
                            
                            /// Todo: Step 2... place the rectangle "in real life"
                            
                        }
                    }
                }
            }
        }
        busyPerformingVisionRequest = false
    }
}
