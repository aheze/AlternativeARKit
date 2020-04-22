//
//  ViewController.swift
//  AlternativeARKit
//
//  Created by Zheng on 4/21/20.
//  Copyright © 2020 Zheng. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    //MARK: Camera
    @IBOutlet weak var cameraView: CameraView!
    var cameraDevice: AVCaptureDevice?
    let avSession = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurLabel: UILabel!
    let textToFind = "ARKit"
    
    //MARK: Vision and Text Recognition
    var busyPerformingVisionRequest = false
    var aspectRatioWidthOverHeight: CGFloat = 0
    var deviceSize = CGSize()
    
    @IBOutlet weak var drawingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceSize = view.frame.size
        blurView.layer.cornerRadius = 6
        blurView.clipsToBounds = true
        blurLabel.text = "Looking for this word: \"\(textToFind)\""
        
        if isAuthorized() {
            configureCamera()
        }
        
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Camera Delegate and Setup
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if busyPerformingVisionRequest == false {
            findUsingVision(in: pixelBuffer)
        }
    }
}

