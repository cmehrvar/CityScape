//
//  HandlePostController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-01.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Player
import AVFoundation
import AWSS3
import AWSCore
import AWSCognito
import Firebase
import FirebaseDatabase
import FirebaseAuth

class HandlePostController: UIViewController, PlayerDelegate, UITextFieldDelegate {
    
    weak var rootController: MainRootController?
    
    
    //Global Variables
    var isImage = true
    var image: UIImage!
    var videoURL: NSURL!
    var exportedVideoURL: NSURL!
    var scale: CGFloat?
    let player = Player()
    
    
    //Outlets
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var shareOutlet: UIButton!
    @IBOutlet weak var uploadingViewOutlet: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //Player Delegates
    func playerReady(player: Player) {
        
        print("player ready")
        
    }
    func playerPlaybackStateDidChange(player: Player) {
        
        print("playback state did change")
        
    }
    func playerBufferingStateDidChange(player: Player) {
        
        print("buffer state did change")
        
    }
    func playerPlaybackWillStartFromBeginning(player: Player) {
        
        print("playback will start from beginning")
        
    }
    func playerPlaybackDidEnd(player: Player) {
        
        print("playback did end")
        
    }
    
    func playerCurrentTimeDidChange(player: Player) {
        
        //print("current time did change")
        
    }

    //Actions
    @IBAction func backButton(sender: AnyObject) {

        if isImage {
            
            let editor = AdobeUXImageEditorViewController(image: image)
            editor.delegate = rootController?.actionsController
            
            rootController?.actionsController?.presentViewController(editor, animated: false, completion: {
                
                self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: true, completion: { (bool) in
                    
                    print("handle post toggled")
                    
                })
            })
            
        } else {
            
            self.rootController?.cameraTransitionOutlet.alpha = 1
            self.rootController?.actionsController?.presentFusumaCamera()
            
            self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: true, completion: { (bool) in
                
                print("handle post toggled")
                
            })
        }
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        
        shareOutlet.enabled = false
        
        if isImage {
            
            uploadPost(image, videoURL: nil, isImage: isImage)
            
        } else {
            
            uploadPost(image, videoURL: exportedVideoURL, isImage: isImage)
            
        }
    }
    
    
    func handleCall(){
        
        handleContent()
        
        if !isImage {
            
            shareOutlet.enabled = false
            convertVideoToLowQualityWithInputURL(videoURL, handler: { (exportSession, outputURL) in
                
                if exportSession.status == .Completed {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.shareOutlet.enabled = true
                        self.exportedVideoURL = outputURL
                        
                    })
                    
                    
                    print("good convert")
                    
                } else {
                    
                    print("bad convert")
                    
                }
                
            })
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewDidAppear(true)

    }
    
    //Functions
    func handleContent() {

        if isImage {
            
            if let actualImage = image {
                imageOutlet.image = actualImage
            } else {
                imageOutlet.image = nil
            }

        } else {

            player.delegate = self
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.addChildViewController(self.player)
                self.videoOutlet.addSubview(self.player.view)
                self.player.view.frame = self.videoOutlet.bounds
                self.player.didMoveToParentViewController(self)
                self.player.setUrl(self.videoURL)
                self.player.fillMode = AVLayerVideoGravityResizeAspectFill
                self.player.playbackLoops = true
                self.player.playFromBeginning()
                
                
            })
        }
    }

    func uploadPost(image: UIImage!, videoURL: NSURL!, isImage: Bool) {
        
        var captionString = ""
        self.view.endEditing(true)
        
        if let text = caption.text {
            captionString = text
        }

        UIView.animateWithDuration(0.3) {
            self.uploadingViewOutlet.alpha = 1
        }
        
        self.imageUploadRequest(image) { (imageUrl, imageUploadRequest) in
            
            let imageTransferManager = AWSS3TransferManager.defaultS3TransferManager()

            imageTransferManager.upload(imageUploadRequest).continueWithBlock { (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    print("successful image upload")
                    
                    if !isImage {
                        
                        self.videoUploadRequest(videoURL, completion: { (FIRVideoURL, videoUploadRequest) in
                            
                            let videoTransferManager = AWSS3TransferManager.defaultS3TransferManager()
                            
                            videoTransferManager.upload(videoUploadRequest).continueWithBlock({ (task) -> AnyObject? in
                                
                                print("save thumbnail & video to firebase")
   
                                if let userData = self.rootController?.selfData, selfUID = FIRAuth.auth()?.currentUser?.uid {
                                    
                                    let currentDate = NSDate().timeIntervalSince1970
                                    
                                    if let firstName = userData["firstName"] as? String, lastName = userData["lastName"] as? String, city = userData["city"] as? String {
                                        
                                        let ref = FIRDatabase.database().reference()
                                        
                                        let postChildKey = ref.child("posts").child(city).childByAutoId().key
                                        
                                        let postData: [NSObject:AnyObject] = ["views":0, "userUID":selfUID, "firstName":firstName, "lastName":lastName, "city":city, "timeStamp":currentDate, "imageURL":imageUrl, "caption":captionString, "isImage":isImage, "like" : 0, "dislike" : 0, "postChildKey":postChildKey, "videoURL" : FIRVideoURL]
                                        
                                        
                                        if let score = userData["userScore"] as? Int {
                                            
                                            ref.child("users").child(selfUID).child("userScore").setValue(score+5)
                                            ref.child("userScores").child(selfUID).setValue(score+5)
                                            
                                        }
                                        
                                        ref.child("posts").child(city).child(postChildKey).updateChildValues(postData)
                                        ref.child("users").child(selfUID).child("posts").child(postChildKey).updateChildValues(postData)
                                        ref.child("allPosts").child(postChildKey).updateChildValues(postData)

                                        dispatch_async(dispatch_get_main_queue(), {
                                            
                                            self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: false, completion: { (bool) in
                                                
                                                self.uploadingViewOutlet.alpha = 0
                                                self.shareOutlet.enabled = true
                                                print("handle closed")
                                                
                                            })

                                            self.rootController?.toggleVibes({ (bool) in
                                                
                                                print("vibes toggled")
                                                
                                            })
                                        })
                                    }
                                }

                                return nil
                            })
                        })

                    } else {
                        
                        print("save image only to firebase")
                        
                        if let userData = self.rootController?.selfData, selfUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            let currentDate = NSDate().timeIntervalSince1970
                            
                            if let firstName = userData["firstName"] as? String, lastName = userData["lastName"] as? String, city = userData["city"] as? String, longitude = userData["longitude"] as? CLLocationDegrees, latitude = userData["latitude"] as? CLLocationDegrees, state = userData["state"] as? String {
                                
                                let ref = FIRDatabase.database().reference()
                                
                                let postChildKey = ref.child("posts").child(city).childByAutoId().key
                                
                                let postData: [NSObject:AnyObject] = ["views":0, "userUID":selfUID, "firstName":firstName, "lastName":lastName, "city": city, "timeStamp":currentDate, "imageURL":imageUrl, "caption":captionString, "isImage":isImage, "like" : 0, "dislike" : 0, "postChildKey":postChildKey, "videoURL" : "none"]
                                
                                
                                if let score = userData["userScore"] as? Int {
                                    
                                    ref.child("users").child(selfUID).child("userScore").setValue(score+5)
                                    ref.child("userScores").child(selfUID).setValue(score+5)
                                    
                                }
                                
                                ref.child("posts").child(city).child(postChildKey).updateChildValues(postData)
                                ref.child("users").child(selfUID).child("posts").child(postChildKey).updateChildValues(postData)
                                ref.child("allPosts").child(postChildKey).updateChildValues(postData)

                                ref.child("cityLocations").child(city).updateChildValues(["mostRecentPost" : postData, "latitude" : latitude, "longitude" : longitude, "city" : city, "state" : state])
                                
                                print("successfuly set city")

                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: false, completion: { (bool) in
                                        
                                        self.uploadingViewOutlet.alpha = 0
                                        self.shareOutlet.enabled = true
                                        print("handle closed")
                                        
                                    })
                                    
                                    self.rootController?.toggleVibes({ (bool) in
                                        
                                        self.rootController?.vibesFeedController?.currentCity = city
                                        self.rootController?.vibesFeedController?.observeCurrentCityPosts()

                                        print("vibes toggled")
                                        
                                    })
                                })
                            }
                        }
                    }
 
                } else {
                    print("error uploading: \(task.error)")
                    
                    let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
                return nil
            }
        }
    }
    
    
    
    
    func videoUploadRequest(videoURL: NSURL?, completion: (url: String, uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = videoURL
            uploadRequest.key = fileName
            uploadRequest.bucket = "cityscapebucket"
            
            let amazonVideoURL = "https://s3.amazonaws.com/cityscapebucket/" + fileName
            
            completion(url: amazonVideoURL, uploadRequest: uploadRequest)
            
        }
    }
    
    func imageUploadRequest(image: UIImage, completion: (url: String, uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        //SEGMENTATION BUG, IF FAULT 11 - COMMENT OUT AND REWRITE
        dispatch_async(dispatch_get_main_queue()) {
            imageData?.writeToFile(filePath, atomically: true)
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = fileURL
            uploadRequest.key = fileName
            uploadRequest.bucket = "cityscapebucket"
            
            var imageUrl = ""
            
            if let key = uploadRequest.key {
                imageUrl = "https://s3.amazonaws.com/cityscapebucket/" + key
                
            }
            
            completion(url: imageUrl, uploadRequest: uploadRequest)
        }
    }
    
    
    //Functions
    func convertVideoToLowQualityWithInputURL(inputURL: NSURL, handler: (AVAssetExportSession, NSURL) -> Void) {
        
        let tempURL = inputURL
        
        let newAsset: AVURLAsset = AVURLAsset(URL: tempURL)
        
        if let exportSession: AVAssetExportSession = AVAssetExportSession(asset: newAsset, presetName: AVAssetExportPresetMediumQuality) {
 
            let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
            let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
            
            exportSession.outputURL = fileURL
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                
                handler(exportSession, fileURL)
                
                print("Export Session Done")
                
            })
        }
    }
    func addUploadStuff(){
        
        let error = NSErrorPointer()
        
        do{
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    func addDismissKeyboard() {
        
        let dismissKeyboardGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardGesture)
        
    }
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUploadStuff()
        addDismissKeyboard()
        caption.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
