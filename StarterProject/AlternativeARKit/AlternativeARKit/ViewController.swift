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

    //MARK: - Camera
    
    /// I've set the camera up already. This is just some Camera-related stuff.
    @IBOutlet weak var cameraView: CameraView!
    var cameraDevice: AVCaptureDevice?
    let avSession = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    
    //MARK: - User Interface
    
    /// This is displayed to the user.
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurLabel: UILabel!
    
    /// This is the text that we will be looking for. Feel free to change this to whatever you want!
    let textToFind = "ARKit"
    
    //MARK: - Vision and Text Recognition
    
    /// We can't have multiple Vision requests at the same time so we have this variable that keeps track if there is a request going on or not
    var busyPerformingVisionRequest = false
    
    /// We'll use this for converting the Vision coordinates (they are written like a percentage, for example 0.0123123032984% of the view's width)
    /// We must multiply what Vision returns by the device's size
    var aspectRatioWidthOverHeight: CGFloat = 0
    var deviceSize = CGSize()
    
    /// We'll add rectangles/highlights as subviews to drawingView later
    @IBOutlet weak var drawingView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceSize = view.frame.size
        
        blurView.layer.cornerRadius = 6
        blurView.clipsToBounds = true
        blurLabel.text = "Looking for this word: \"\(textToFind)\""
        
        /// Asks for permission to use the camera
        if isAuthorized() {
            configureCamera()
        }
        
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: Camera Delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if busyPerformingVisionRequest == false {
            findUsingVision(in: pixelBuffer)
        }
    }
}

