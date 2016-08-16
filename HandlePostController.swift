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

class HandlePostController: UIViewController, AdobeUXImageEditorViewControllerDelegate, PlayerDelegate, UITextFieldDelegate {
    
    //Global Variables
    var isImage = true
    var image: UIImage!
    var videoURL: NSURL!
    var exportedVideoURL: NSURL!
    
    
    //Outlets
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var shareOutlet: UIBarButtonItem!
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
    
    
    //Adobe Delegates
    func photoEditorCanceled(editor: AdobeUXImageEditorViewController) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        editor.view.window?.layer.addAnimation((transition), forKey: nil)
        
        
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
        editor.presentViewController(vc, animated: false) {
            //vc.vibesFeedController?.getFirebaseData()
            //vc.vibesFeedController?.transitionToFusumaOutlet.alpha = 1
            //vc.vibesFeedController?.presentFusumaCamera()
        }
        
        
    }
    func photoEditor(editor: AdobeUXImageEditorViewController, finishedWithImage image: UIImage?) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        editor.view.window?.layer.addAnimation((transition), forKey: nil)
        
        isImage = true
        
        editor.dismissViewControllerAnimated(false, completion: nil)
        
        
        
        print("handle post editor clicked done")
        
    }
    
    
    //Actions
    @IBAction func backButton(sender: AnyObject) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window?.layer.addAnimation((transition), forKey: nil)
        
        if isImage {
            
            let editor = AdobeUXImageEditorViewController(image: image)
            editor.delegate = self
            self.presentViewController(editor, animated: false, completion: nil)
            
        } else {
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
            self.presentViewController(vc, animated: false) {
                //vc.vibesController?.getFirebaseData()
                //vc.vibesController?.transitionToFusumaOutlet.alpha = 1
                //vc.vibesController?.presentFusumaCamera()
            }
        }
    }
    @IBAction func shareAction(sender: AnyObject) {
        
        shareOutlet.enabled = false
        
        if isImage {
            
            uploadPost(image, videoURL: nil, isImage: isImage)
            
        } else {
            
            uploadPost(nil, videoURL: exportedVideoURL, isImage: isImage)
            
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
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
    
    //Functions
    func handleContent() {
        
        if isImage {
            
            imageOutlet.image = image
            
        } else {
            
            let player = Player()
            player.delegate = self
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.addChildViewController(player)
                self.videoOutlet.addSubview(player.view)
                player.view.frame = self.videoOutlet.bounds
                player.didMoveToParentViewController(self)
                player.setUrl(self.videoURL)
                player.fillMode = AVLayerVideoGravityResizeAspectFill
                player.playbackLoops = true
                player.playFromBeginning()
                
                
            })
        }
    }
    
    
    
    func uploadPost(image: UIImage!, videoURL: NSURL!, isImage: Bool) {
        
        
        
        UIView.animateWithDuration(0.3) {
            self.uploadingViewOutlet.alpha = 1
        }
        
        
        var request = AWSS3TransferManagerUploadRequest()
        
        if isImage {
            
            request = uploadRequest(image)
            
        } else {
            
            let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
            
            request.body = videoURL
            request.key = fileName
            request.bucket = "cityscapebucket"
            
        }
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(request).continueWithBlock({ (task) -> AnyObject? in
            
            if task.error == nil {
                
                print("successful upload!")
                
                //DO SOMETHING WITH FIREBASE
                
                let currentUser = FIRAuth.auth()?.currentUser
                let ref = FIRDatabase.database().reference()
                
                if let userUID = currentUser?.uid {
                    
                    ref.child("users").child(userUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        var contentURL = String()
                        var captionVar = String()
                        
                        if let key = request.key, actualCaption = self.caption.text {
                            
                            captionVar = "\"" + actualCaption + "\""
                            contentURL = "https://s3.amazonaws.com/cityscapebucket/" + key
                            
                        }

                        let userData = snapshot.value as! [NSObject:AnyObject]
                        let currentDate = NSDate().timeIntervalSince1970
                        
                        let firstName: AnyObject! = userData["firstName"]
                        let lastName: AnyObject! = userData["lastName"]
                        let city: AnyObject! = userData["city"]
                        let profile: AnyObject! = userData["profilePicture"]
                        
                        
                        let postChildKey = ref.child("posts").childByAutoId().key
                        
                        let postData: [NSObject:AnyObject] = ["views":0, "userUID":userUID, "firstName":firstName, "lastName":lastName, "city":city, "timeStamp":currentDate, "profilePicture":profile, "contentURL":contentURL, "caption":captionVar, "isImage":isImage, "like" : 0, "dislike" : 0, "postChildKey":postChildKey]
                        
                        
                        
                        ref.child("userScores").child(userUID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let score = snapshot.value as? Int {
                                
                                ref.child("users").child(userUID).child("totalScore").setValue(score+5)
                                ref.child("userScores").child(userUID).setValue(score+5)
                                
                            }
                        })
                        
                        
                        ref.child("posts").child(postChildKey).updateChildValues(postData)
                        ref.child("users").child(userUID).child("posts").child(postChildKey).updateChildValues(postData)
                        ref.child("postUIDs").child(postChildKey).setValue(currentDate)
                                                
                        
                        
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainRootController") as! MainRootController
                        
                        self.presentViewController(vc, animated: true, completion: {
                            
                            //vc.vibesController?.getFirebaseData()
                            
                        })
                    })
                }

            } else {
                
                print("error uploading: \(task.error)")
                
                let alertController = UIAlertController(title: "Whoops", message: "Error Uploading", preferredStyle: UIAlertControllerStyle.Alert)

                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.uploadingViewOutlet.alpha = 0
                    })
                    
                }))

                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.shareOutlet.enabled = true
            })
            
            return nil
        })
    }
    
    
    func uploadRequest(image: UIImage) -> AWSS3TransferManagerUploadRequest {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        imageData?.writeToFile(filePath, atomically: true)
        
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "cityscapebucket"
        
        return uploadRequest
        
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
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismissKeyboard)
        
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
