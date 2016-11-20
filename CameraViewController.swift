//
//  CameraViewController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-11-16.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVAudioSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var rootController: MainRootController?
    
    let frontOut = AVCaptureStillImageOutput()
    let backOut = AVCaptureStillImageOutput()
    
    let micDeviceInput: AVCaptureDeviceInput = AVCaptureDeviceInput()
    
    let frontVideoOut = AVCaptureMovieFileOutput()
    let backVideoOut = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var blurredPreviewLayer: AVCaptureVideoPreviewLayer?

    var frontCameraShown = false
    var isRecording = false
    
    var captureImage = true
    
    var ms = 0
    var s = 0
    
    var startTime = TimeInterval()
    var timer = Timer()

    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var tapToTakeOutlet: UILabel!
    
    @IBOutlet weak var cameraButtonOutlet: UIButton!
    @IBOutlet weak var videoButtonOutlet: UIButton!
    @IBOutlet weak var flipCameraButtonOutlet: UIButton!
    
    @IBOutlet weak var videoTimeViewOutlet: UIView!
    @IBOutlet weak var videoTimeLabelOutlet: UILabel!
    @IBOutlet weak var redIndicatorOutlet: UIView!
    
    @IBOutlet weak var captureButtonOutlet: UIButton!
    
    @IBAction func closeCamera(_ sender: Any) {
        
        rootController?.toggleCamera(completion: { (bool) in
            
                print("camera closed")
            
        })
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        
        frontCameraShown = !frontCameraShown
        previewLayer?.removeFromSuperlayer()
        initializeCamera()
        
    }
    
    @IBAction func gallery(_ sender: Any) {
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        cameraProfile.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(cameraProfile, animated: true, completion: nil)
        
    }
    
    @IBAction func camera(_ sender: Any) {
        
        captureImage = true
        cameraButtonOutlet.setTitleColor(UIColor.init(netHex: 0x077AFF), for: .normal)
        videoButtonOutlet.setTitleColor(UIColor.white, for: .normal)
        
        videoTimeViewOutlet.alpha = 0
        
        tapToTakeOutlet.text = "Tap to take a photo!"
        
        
    }
    
    @IBAction func video(_ sender: Any) {
        
        captureImage = false
        videoButtonOutlet.setTitleColor(UIColor.init(netHex: 0x077AFF), for: .normal)
        cameraButtonOutlet.setTitleColor(UIColor.white, for: .normal)
        
        videoTimeViewOutlet.alpha = 1
        
        tapToTakeOutlet.text = "Tap to begin recording!"
        
    }
    
    @IBAction func capture(_ sender: Any) {
        
        if isRecording {
            
            if !frontCameraShown {
                
                backVideoOut.stopRecording()
                
            } else {
                
                frontVideoOut.stopRecording()
                
            }
            
            timer.invalidate()
            ms = 0
            s = 0
            
            
        } else if captureImage {
            
            if !frontCameraShown {
                
                guard let videoConnection = backOut.connection(withMediaType: AVMediaTypeVideo) else {
                    print("Error creating video connection")
                    return
                }
                
                
                backOut.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer, error) -> Void in
                    
                    guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer), let image = UIImage(data: imageData) else {
                        return
                    }

                    self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                        
                        print("handle post toggled")
                        
                    })
                    

                }
            } else {
                
                guard let videoConnection = frontOut.connection(withMediaType: AVMediaTypeVideo) else {
                    print("Error creating video connection")
                    return
                }
                
                frontOut.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer, error) -> Void in
                    
                    guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer), let image = UIImage(data: imageData) else {
                        return
                    }
                    
                    self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                        
                        print("handle post toggled")
                        
                    })
                }
            }
            
        } else {
            
            isRecording = true

            self.tapToTakeOutlet.text = "Recording..."
            self.flipCameraButtonOutlet.alpha = 0
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(update), userInfo: nil, repeats: true)

            self.captureButtonOutlet.setImage(UIImage.init(named: "stopRecording"), for: .normal)
            
            if !frontCameraShown {
                
                backVideoOut.maxRecordedDuration = CMTime(seconds: 10, preferredTimescale: 1)

                let fileName = ProcessInfo.init().globallyUniqueString.appending(".mov")
                let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload")?.appendingPathComponent(fileName)
                
                backVideoOut.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)

            } else {
                
                frontVideoOut.maxRecordedDuration = CMTime(seconds: 10, preferredTimescale: 1)

                let fileName = ProcessInfo.init().globallyUniqueString.appending(".mov")
                let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload")?.appendingPathComponent(fileName)
                frontVideoOut.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)

            }
        }
    }



    func update() {
        
        
        
        switch ms {
            
        case 0:
            s = 10
            
        case 100:
            s = 9
            
        case 200:
            s = 8
            
        case 300:
            s = 7
            
        case 400:
            s = 6
            
        case 500:
            s = 5
            
        case 600:
            s = 4
            
        case 700:
            s = 3
            
        case 800:
            s = 2
            
        case 900:
            s = 1
            
        case 1000:
            s = 0
            
        default:
            break
            
            
        }
        
        ms += 1
        videoTimeLabelOutlet.text = "\(s)s"
        
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.dismiss(animated: true) {
            
            self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                
                print("handle post shown")
                
            })
        }
    }


    
    
    func initializeCamera(){

        DispatchQueue.main.async {
            
            if let layer = self.previewLayer {
                
                layer.removeFromSuperlayer()
                
            }

            let captureSession = AVCaptureSession()
            
            self.cameraView.clipsToBounds = true
            
            guard let devices = AVCaptureDevice.devices() else {return}
            
            let audioDevices = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            
            var actualDevice: AVCaptureDevice?
            
            for unsafeDevice in devices {
                
                if let device = unsafeDevice as? AVCaptureDevice {
                    
                    if !self.frontCameraShown {
                        
                        if device.position == .back {
                            
                            actualDevice = device
                            
                        }
                        
                    } else {
                        
                        if device.position == .front {
                            
                            actualDevice = device
                            
                        }
                    }
                }
            }
            
            guard let cameraCaptureDevice = actualDevice else {
                print("Unable to cast the first device as a capture device")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: cameraCaptureDevice)
                captureSession.addInput(input)
            } catch let error {
                print("Error was caught when trying to transform the device into a session input: \(error)")
            }
            
            
            guard let audioCaptureDevice = audioDevices else {
                print("Unable to cast the first device as a capture device")
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: audioCaptureDevice)
                captureSession.addInput(input)
            } catch let error {
                print("Error was caught when trying to transform the device into a session input: \(error)")
            }
            
            
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            captureSession.startRunning()
            
            if !self.frontCameraShown {
                
                self.backOut.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                
                if captureSession.canAddOutput(self.backOut) {
                    captureSession.addOutput(self.backOut)
                }
                
                if captureSession.canAddOutput(self.backVideoOut) {
                    captureSession.addOutput(self.backVideoOut)
                }
                
            } else {
                
                self.frontOut.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                
                if captureSession.canAddOutput(self.frontOut) {
                    captureSession.addOutput(self.frontOut)
                }
                
                if captureSession.canAddOutput(self.frontVideoOut) {
                    captureSession.addOutput(self.frontVideoOut)
                }
            }
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            guard let actualPreviewLayer = self.previewLayer else {
                print("Unable to cast create a preview layer from the session")
                return
            }
            
            actualPreviewLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.width)
            actualPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            let instances = 2
            let replicatorLayer = CAReplicatorLayer()
            replicatorLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.width)
            replicatorLayer.instanceCount = instances
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, self.view.bounds.size.width, 0)
            
            replicatorLayer.addSublayer(actualPreviewLayer)
            self.cameraView.layer.addSublayer(replicatorLayer)
            
        }    
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("done recording")
        
        timer.invalidate()
        ms = 0
        s = 0
        
        if let url = outputFileURL {
            
            rootController?.toggleHandlePost(nil, videoURL: outputFileURL, isImage: false, completion: { (bool) in
                
                print("handle post toggled")
                
            })
        }
    }
    
    
    override func viewDidLayoutSubviews() {

         guard let actualPreviewLayer = previewLayer else {
         print("Unable to cast create a preview layer from the session")
         return
         }
         
         actualPreviewLayer.frame = cameraView.bounds
         actualPreviewLayer.position = CGPoint(x: cameraView.bounds.midX, y: cameraView.bounds.midY)
 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redIndicatorOutlet.layer.cornerRadius = 7

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
