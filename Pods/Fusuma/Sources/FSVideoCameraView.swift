//
//  FSVideoCameraView.swift
//  Fusuma
//
//  Created by Brendan Kirchner on 3/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol FSVideoCameraViewDelegate: class {
    func videoFinished(withFileURL fileURL: NSURL)
}

final class FSVideoCameraView: UIView {

    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var timeIndicatorOutlet: UIView!
    @IBOutlet weak var timerLabelOutlet: UILabel!
    
    weak var delegate: FSVideoCameraViewDelegate? = nil
    
    let micDeviceInput: AVCaptureDeviceInput = AVCaptureDeviceInput()
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var videoOutput: AVCaptureMovieFileOutput?
    var focusView: UIView?
    
    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    var videoStartImage: UIImage?
    var videoStopImage: UIImage?
    
    var ms = 0
    var s = 0
    
    var startTime = NSTimeInterval()
    var timer:NSTimer = NSTimer()

    
    private var isRecording = false
    
    static func instance() -> FSVideoCameraView {
        
        return UINib(nibName: "FSVideoCameraView", bundle: NSBundle(forClass: self.classForCoder())).instantiateWithOwner(self, options: nil)[0] as! FSVideoCameraView
    }
    
    func initialize() {
        
        if session != nil {
            
            return
        }
        
        self.backgroundColor = fusumaBackgroundColor
        
        self.hidden = false
        
        // AVCapture
        session = AVCaptureSession()
        
        for device in AVCaptureDevice.devices() {
            
            if let device = device as? AVCaptureDevice where device.position == AVCaptureDevicePosition.Back {
                
                self.device = device
            }
        }
        
        let audioDevices = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        do {
            
            if let session = session {
                
                videoInput = try AVCaptureDeviceInput(device: device)
                session.addInput(videoInput)
                
                guard let audioCaptureDevice = audioDevices else {
                    print("Unable to cast the first device as a capture device")
                    return
                }
                
                do {
                    let input = try AVCaptureDeviceInput(device: audioCaptureDevice)
                    session.addInput(input)
                } catch let error {
                    print("Error was caught when trying to transform the device into a session input: \(error)")
                }
                
                videoOutput = AVCaptureMovieFileOutput()
                let totalSeconds = 15.0 //Total Seconds of capture time
                let timeScale: Int32 = 30 //FPS
                
                let maxDuration = CMTimeMakeWithSeconds(totalSeconds, timeScale)
                
                videoOutput?.maxRecordedDuration = maxDuration
                videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024 //SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
                
                if session.canAddOutput(videoOutput) {
                    session.addOutput(videoOutput)
                }
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer.frame = self.previewViewContainer.bounds
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                self.previewViewContainer.layer.addSublayer(videoLayer)
                
                session.startRunning()
                
            }
            
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action: #selector(FSVideoCameraView.focus(_:)))
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
            
        } catch {
            
        }
        
        
        let bundle = NSBundle(forClass: self.classForCoder)
        
        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "ic_flash_on", inBundle: bundle, compatibleWithTraitCollection: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "ic_flash_off", inBundle: bundle, compatibleWithTraitCollection: nil)
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "ic_loop", inBundle: bundle, compatibleWithTraitCollection: nil)
        videoStartImage = fusumaVideoStartImage != nil ? fusumaVideoStartImage : UIImage(named: "video_button", inBundle: bundle, compatibleWithTraitCollection: nil)
        videoStopImage = fusumaVideoStopImage != nil ? fusumaVideoStopImage : UIImage(named: "video_button_rec", inBundle: bundle, compatibleWithTraitCollection: nil)
        
        
        if(fusumaTintIcons) {
            flashButton.tintColor = fusumaBaseTintColor
            flipButton.tintColor  = fusumaBaseTintColor
            shotButton.tintColor  = fusumaBaseTintColor
            
            flashButton.setImage(flashOffImage?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            flipButton.setImage(flipImage?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            shotButton.setImage(videoStartImage?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        } else {
            flashButton.setImage(flashOffImage, forState: .Normal)
            flipButton.setImage(flipImage, forState: .Normal)
            shotButton.setImage(videoStartImage, forState: .Normal)
        }
        
        flashConfiguration()
        
        self.startCamera()
        
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func startCamera() {
        
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.Authorized {
            
            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.Denied || status == AVAuthorizationStatus.Restricted {
            
            session?.stopRunning()
        }
    }
    
    func stopCamera() {
        if self.isRecording {
            self.toggleRecording()
        }
        session?.stopRunning()
    }
    
    @IBAction func shotButtonPressed(sender: UIButton) {
        
        self.toggleRecording()
    }
    
    private func toggleRecording() {
        
        guard let videoOutput = videoOutput else {
            return
        }
        
        self.isRecording = !self.isRecording
        
        let shotImage: UIImage?
        if self.isRecording {
            shotImage = videoStopImage
        } else {
            shotImage = videoStartImage
        }
        self.shotButton.setImage(shotImage, forState: .Normal)
        
        if self.isRecording {
            
            self.timerLabelOutlet.alpha = 1
            self.timerLabelOutlet.text = "15s"
            self.timeIndicatorOutlet.layer.cornerRadius = 10
            self.timeIndicatorOutlet.alpha = 1

            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

            let outputPath = "\(NSTemporaryDirectory())output.mov"
            let outputURL = NSURL.fileURLWithPath(outputPath)
            
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(outputPath) {
                do {
                    try fileManager.removeItemAtPath(outputPath)
                } catch {
                    print("error removing item at path: \(outputPath)")
                    self.isRecording = false
                    return
                }
            }
            self.flipButton.enabled = false
            self.flashButton.enabled = false
            videoOutput.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
        } else {
            
            self.timerLabelOutlet.alpha = 0
            self.timeIndicatorOutlet.alpha = 0
            
            timer.invalidate()
            ms = 0
            s = 0
            timerLabelOutlet.text = ""
            
            videoOutput.stopRecording()
            self.flipButton.enabled = true
            self.flashButton.enabled = true
        }
        return
    }
    
    @IBAction func flipButtonPressed(sender: UIButton) {
        
        session?.stopRunning()
        
        do {
            
            session?.beginConfiguration()
            
            if let session = session {
                
                for input in session.inputs {
                    
                    session.removeInput(input as! AVCaptureInput)
                }
                
                let position = (videoInput?.device.position == AVCaptureDevicePosition.Front) ? AVCaptureDevicePosition.Back : AVCaptureDevicePosition.Front
                
                for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
                    
                    if let device = device as? AVCaptureDevice where device.position == position {
                        
                        videoInput = try AVCaptureDeviceInput(device: device)
                        session.addInput(videoInput)
                        
                    }
                }
                
            }
            
            session?.commitConfiguration()
            
            
        } catch {
            
        }
        
        session?.startRunning()
    }
    
    @IBAction func flashButtonPressed(sender: UIButton) {
        
        do {
            
            if let device = device {
                
                try device.lockForConfiguration()
                
                let mode = device.flashMode
                
                if mode == AVCaptureFlashMode.Off {
                    
                    device.flashMode = AVCaptureFlashMode.On
                    flashButton.setImage(flashOnImage, forState: .Normal)
                    
                } else if mode == AVCaptureFlashMode.On {
                    
                    device.flashMode = AVCaptureFlashMode.Off
                    flashButton.setImage(flashOffImage, forState: .Normal)
                }
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            flashButton.setImage(flashOffImage, forState: .Normal)
            return
        }
        
    }

}

extension FSVideoCameraView: AVCaptureFileOutputRecordingDelegate {
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("started recording to: \(fileURL)")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("finished recording to: \(outputFileURL)")
        self.delegate?.videoFinished(withFileURL: outputFileURL)
    }
    
}

extension FSVideoCameraView {
    
    func focus(recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.locationInView(self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            
            try device.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) == true {
            
            device.focusMode = AVCaptureFocusMode.AutoFocus
            device.focusPointOfInterest = newPoint
        }
        
        if device.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) == true {
            
            device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
            device.exposurePointOfInterest = newPoint
        }
        
        device.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clearColor()
        self.focusView?.layer.borderColor = UIColor.whiteColor().CGColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
        self.addSubview(self.focusView!)
        
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 3.0, options: UIViewAnimationOptions.CurveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransformMakeScale(0.7, 0.7)
            }, completion: {(finished) in
                self.focusView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.focusView!.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
        
        do {
            
            if let device = device {
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureFlashMode.Off
                flashButton.setImage(flashOffImage, forState: .Normal)
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }
    
    
    func update() {
        
        ms++
        
        switch ms {
            
        case 0:
            s = 15
            
        case 100:
            s = 14
            
        case 200:
            s = 13
            
        case 300:
            s = 12
            
        case 400:
            s = 11
            
        case 500:
            s = 10
            
        case 600:
            s = 9
            
        case 700:
            s = 8
            
        case 800:
            s = 7
            
        case 900:
            s = 6
            
        case 1000:
            s = 5
            
        case 1100:
            s = 4
            
        case 1200:
            s = 3
            
        case 1300:
            s = 2
            
        case 1400:
            s = 1
            
        case 1500:
            s = 0
            
        default:
            break
            
            
        }
        
        timerLabelOutlet.text = "\(s)"
        
    }
}
