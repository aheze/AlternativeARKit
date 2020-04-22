//
//  Utilities.swift
//  AlternativeARKit
//
//  Created by Zheng on 4/21/20.
//  Copyright © 2020 Zheng. All rights reserved.
//

import UIKit


extension UIImage {
    convenience init?(pixBuffer: CVPixelBuffer) {
        var ciImage = CIImage(cvPixelBuffer: pixBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size

        let screenSize: CGRect = UIScreen.main.bounds
        let imageRect = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: size.width, height: size.height)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}

