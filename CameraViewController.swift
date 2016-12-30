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
import AWSCore
import AWSS3
import Firebase
import FirebaseDatabase
import FirebaseAuth
import NYAlertViewController
import AVFoundation

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVAudioSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    var asset: AVAsset?
    var item: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    weak var rootController: MainRootController?
    
    var postUid = ""
    
    var alertController = NYAlertViewController()
    
    var chatType = ""
    var cameraType = ""
    
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
    
    var flashState = 2
    
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var back2ButtonOutlet: UIButton!
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var tapToTakeOutlet: UILabel!
    
    @IBOutlet weak var cameraButtonOutlet: UIButton!
    @IBOutlet weak var videoButtonOutlet: UIButton!
    @IBOutlet weak var flipCameraButtonOutlet: UIButton!
    @IBOutlet weak var flashButtonOutlet: UIButton!
    
    @IBOutlet weak var videoTimeViewOutlet: UIView!
    @IBOutlet weak var videoTimeLabelOutlet: UILabel!
    @IBOutlet weak var redIndicatorOutlet: UIView!
    
    @IBOutlet weak var captureButtonOutlet: UIButton!
    
    @IBOutlet weak var uploadingOutlet: UIView!

    @IBAction func closeCamera(_ sender: Any) {

        rootController?.toggleCamera(type: "", chatType: "", completion: { (bool) in
            
            print("camera closed")
            
        })
    }
    @IBAction func closeCamera2(_ sender: Any) {
        
        rootController?.toggleCamera(type: "", chatType: "", completion: { (bool) in
            
            print("camera closed")
            
        })
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        
        frontCameraShown = !frontCameraShown
        previewLayer?.removeFromSuperlayer()
        initializeCamera()
        
    }
    
    
    
    @IBAction func toggleFlash(_ sender: Any) {
        
        if flashState == 0 {
            
            flashState = 1
            flashButtonOutlet.setImage(UIImage(named: "onFlash"), for: .normal)
            
        } else if flashState == 1 && captureImage {
            
            flashState = 2
            flashButtonOutlet.setImage(UIImage(named: "autoFlash"), for: .normal)
            
        } else {
            
            flashState = 0
            flashButtonOutlet.setImage(UIImage(named: "noFlash"), for: .normal)
            
        }
    }
    
    @IBAction func gallery(_ sender: Any) {
        
        captureImage = true
        
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
        
    }
    
    @IBAction func video(_ sender: Any) {
        
        captureImage = false
        videoButtonOutlet.setTitleColor(UIColor.init(netHex: 0x077AFF), for: .normal)
        cameraButtonOutlet.setTitleColor(UIColor.white, for: .normal)
        
        videoTimeViewOutlet.alpha = 1
        
        
        if flashState == 2 {
            
            flashState = 1
            flashButtonOutlet.setImage(UIImage(named: "onFlash"), for: .normal)
            
        }
    }
    
    /*
    //ADOBE DELEGATES
    func photoEditor(_ editor: AdobeUXImageEditorViewController, finishedWith image: UIImage?) {
        
        self.dismiss(animated: true, completion: {
            
            DispatchQueue.main.async {
                
                self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                    
                    print("handle post toggled")
                    
                })
                
            }
        })
    }
    
    
    func photoEditorCanceled(_ editor: AdobeUXImageEditorViewController) {
        
        self.dismiss(animated: true, completion: {
            
            print("dismissed")
            
        })
        
        
    }
*/
    func displayEditor(gallery: Bool, inImage: UIImage?, inVideo: URL?){

        var scopeVideo: URL?
        
        alertController = NYAlertViewController()
        alertController.backgroundTapDismissalGestureEnabled = false
        
        if let myCity = self.rootController?.selfData["city"] as? String {
        
        alertController.title = "Post from \(myCity)?"
        alertController.titleColor = UIColor.black
        alertController.message = nil
        
        alertController.buttonColor = UIColor.red
        alertController.buttonTitleColor = UIColor.white
        
        alertController.cancelButtonColor = UIColor.lightGray
        alertController.cancelButtonTitleColor = UIColor.white

        }
        
        if let image = inImage {
            
            var scopeImage = image
            
            if !gallery {
                
                let imageWidth = image.size.width
                
                let smallerRect = CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth)
                
                guard let contextImage = image.cgImage else {return}

                if let newCGImage = contextImage.cropping(to: smallerRect) {
                    
                    scopeImage = UIImage(cgImage: newCGImage, scale: image.scale, orientation: image.imageOrientation)
                    
                }
            }
            
            DispatchQueue.main.async(execute: {
                
                let imageView = UIImageView(image: scopeImage)
                imageView.clipsToBounds = true
                imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0))
                
                imageView.contentMode = .scaleAspectFill
                
                self.alertController.alertViewContentView = imageView
                
            })

            var scopeTextField = UITextField()
            
            alertController.addTextField(configurationHandler: { (textField) in
                
                textField?.placeholder = "Enter a caption..."
                textField?.delegate = self
                textField?.autocorrectionType = .no
                
                if let field = textField {
                    
                    scopeTextField = field
                    
                }
                
            })
            
            alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            alertController.addAction(NYAlertAction(title: "Post", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: {
                    
                    var caption = ""
                    
                    if let scopeCaption = scopeTextField.text {
                        
                        caption = scopeCaption
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.uploadPost(scopeImage, videoURL: nil, caption: caption, isImage: true)
                        
                    }
                })
            }))

        } else if let video = inVideo {

            scopeVideo = video
            
            let asset = AVURLAsset(url: video, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            
            var cgImage: CGImage?
            
            do {
                
                try cgImage = imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                
            } catch let error {
                
                print(error)
                
            }

            var scopeTextField = UITextField()
            
            alertController.addTextField(configurationHandler: { (textField) in
                
                textField?.placeholder = "Enter a caption..."
                textField?.delegate = self
                textField?.autocorrectionType = .no
                
                if let field = textField {
                    
                    scopeTextField = field
                    
                }
                
            })
            
            alertController.addAction(NYAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                self.clearPlayers()
                
                self.dismiss(animated: true, completion: {
                    
                    self.isRecording = false
                    
                    self.videoTimeLabelOutlet.text = "10s"
                    
                    self.backButtonOutlet.alpha = 1
                    self.back2ButtonOutlet.isEnabled = true
                    
                    if let myCity = self.rootController?.selfData["city"] as? String {
                        
                        self.tapToTakeOutlet.text = "Show off YOUR \(myCity)!"
                        
                    }
                    
                    
                    self.flipCameraButtonOutlet.alpha = 1
                    
                    
                    self.captureButtonOutlet.setImage(UIImage.init(named: "cameraIcon"), for: .normal)
                    
                    
                                        })
                
            }))
            
            alertController.addAction(NYAlertAction(title: "Post", style: .default, handler: { (action) in
                
                self.clearPlayers()
                
                self.dismiss(animated: true, completion: {
                    
                    var caption = ""
                    
                    if let scopeCaption = scopeTextField.text {
                        
                        caption = scopeCaption
                        
                    }
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        self.uploadingOutlet.alpha = 1
                        self.view.layoutIfNeeded()
                        
                    })
                    
                    DispatchQueue.main.async {
                        
                        self.convertVideoToLowQualityWithInputURL(video, handler: { (session, url) in
                            
                            DispatchQueue.main.async {
                                
                                if let scopeImage  = cgImage {
                                    
                                    let image = UIImage(cgImage: scopeImage, scale: 1, orientation: UIImageOrientation.up)
                                    
                                    self.uploadPost(image, videoURL: url, caption: caption, isImage: false)
                                    
                                }
                            }
                        })
                    }
                })
            }))
        }
        
        self.present(alertController, animated: true, completion: {
            
            if let video = scopeVideo  {
                
                DispatchQueue.main.async(execute: {
                    
                    self.asset = AVAsset(url: video)
                    
                    if let asset = self.asset {
                        
                        self.item = AVPlayerItem(asset: asset)
                        
                        if let item = self.item {
                            
                            self.player = AVPlayer(playerItem: item)
                            
                        }
                        
                        if let player = self.player {
                            
                            player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                            
                            self.playerLayer = AVPlayerLayer(player: player)
                            
                            if let layer = self.playerLayer {
                                
                                let alertWidth = self.alertController.view.bounds.width
                                
                                let view = UIView(frame: CGRect(x: 0, y: 0, width: alertWidth, height: alertWidth))
       
                                view.clipsToBounds = true
                                view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
   
                                let viewWidth = self.view.bounds.width
                                let viewHeight = self.view.bounds.height
                                let scale = viewHeight/viewWidth
                                
                                let videoView = UIView(frame: CGRect(x: 0, y: 0, width: alertWidth, height: alertWidth*scale))
                                
                                view.addSubview(videoView)

                                videoView.addConstraint(NSLayoutConstraint(item: videoView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: videoView, attribute: NSLayoutAttribute.width, multiplier: scale, constant: 0))
                                
                                view.addConstraint(NSLayoutConstraint(item: videoView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
                                
                                view.addConstraint(NSLayoutConstraint(item: videoView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))

                                view.addConstraint(NSLayoutConstraint(item: videoView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))


                                videoView.layer.addSublayer(layer)
                                layer.frame = videoView.bounds
                                layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                                
                                self.alertController.alertViewContentView = view
                                
                                player.play()
                            }
                        }
                    }
                    
                    print("video downloaded!")
                    
                })

                
            }
            
            print("alertController presented")
            
        })
        
    }


    func videoUploadRequest(_ videoURL: URL?, completion: @escaping (_ url: String, _ uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".mov"
        
        DispatchQueue.main.async {
        
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = videoURL
            uploadRequest?.key = fileName
            uploadRequest?.bucket = "cityscapebucket"
            
            let amazonVideoURL = "https://s3.amazonaws.com/cityscapebucket/" + fileName
            
            completion(amazonVideoURL, uploadRequest!)
            
        }
    }
  
    
    
    func imageUploadRequest(_ image: UIImage, completion: @escaping (_ url: String, _ uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".jpeg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload").appendingPathComponent(fileName)
        let filePath = fileURL.path
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        //SEGMENTATION BUG, IF FAULT 11 - COMMENT OUT AND REWRITE
        DispatchQueue.main.async {
            try? imageData?.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = fileURL
            uploadRequest?.key = fileName
            uploadRequest?.bucket = "cityscapebucket"
            
            var imageUrl = ""
            
            if let key = uploadRequest?.key {
                imageUrl = "https://s3.amazonaws.com/cityscapebucket/" + key
                
            }
            
            completion(imageUrl, uploadRequest!)
        }
    }

    func setToFirebase(_ imageUrl: String?, caption: String?, FIRVideoURL: String?){
        
        if let userData = self.rootController?.selfData, let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let currentDate = Date().timeIntervalSince1970
            
            if let firstName = userData["firstName"] as? String, let lastName = userData["lastName"] as? String, let city = userData["city"] as? String, let longitude = userData["longitude"] as? CLLocationDegrees, let latitude = userData["latitude"] as? CLLocationDegrees, let state = userData["state"] as? String {
                
                let ref = FIRDatabase.database().reference()
                
                let postChildKey = ref.child("posts").child(city).childByAutoId().key
                
                var postData: [AnyHashable: Any] = ["userUID":selfUID, "firstName":firstName, "lastName":lastName, "city":city, "timeStamp":currentDate, "isImage":captureImage, "postChildKey":postChildKey]
                
                if let url = imageUrl {
                    
                    postData["imageURL"] = url
                    
                }
                
                if let url = FIRVideoURL {
                    
                    postData["videoURL"] = url
                    
                }
                
                if let cap = caption {
                    
                    postData["caption"] = cap
                    
                }
                
                if let score = userData["userScore"] as? Int {
                    
                    ref.child("users").child(selfUID).child("userScore").setValue(score+5)
                    ref.child("userScores").child(selfUID).setValue(score+5)
                    
                }
                
                ref.child("posts").child(city).child(postChildKey).updateChildValues(postData)
                ref.child("allPosts").child(postChildKey).updateChildValues(postData)
                ref.child("users").child(selfUID).child("posts").child(postChildKey).updateChildValues(postData)
                
                ref.child("cityLocations").child(city).updateChildValues(["mostRecentPost" : postData, "latitude" : latitude, "longitude" : longitude, "city" : city, "state" : state])
    
                rootController?.vibesFeedController?.globCollectionView.contentOffset = CGPoint.zero
                
                self.clearPlayers()
                
                DispatchQueue.main.async(execute: {
                    
                    self.rootController?.toggleCamera(type: "", chatType: "", completion: { (bool) in
                        self.uploadingOutlet.alpha = 0
                        print("camera closed")
                        
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

    
    func clearPlayers(){
        
        if let layer = playerLayer {
            
            layer.removeFromSuperlayer()
            
        }
        
        if let playerPlayer = player {
            
            playerPlayer.pause()
            playerPlayer.removeObserver(self, forKeyPath: "rate")
            
        }
        
        playerLayer = nil
        player = nil
        item = nil
        asset = nil
        
        
    }
    
    func uploadPost(_ image: UIImage!, videoURL: URL!, caption: String, isImage: Bool) {
        
        self.view.endEditing(true)

        //HANDLE CAPTION
        UIView.animate(withDuration: 0.3, animations: {
            self.uploadingOutlet.alpha = 1
        })
        
        self.imageUploadRequest(image) { (imageUrl, imageUploadRequest) in
            
            let imageTransferManager = AWSS3TransferManager.default()
            
            imageTransferManager?.upload(imageUploadRequest).continue({ (task) -> Any? in
                
                if task.error == nil {
                    
                    print("successful image upload")
                    
                    if !isImage {
                        
                        self.videoUploadRequest(videoURL, completion: { (FIRVideoURL, videoUploadRequest) in
                            
                            let videoTransferManager = AWSS3TransferManager.default()
                            
                            videoTransferManager?.upload(videoUploadRequest).continue({ (task) -> AnyObject? in
                                
                                print("save thumbnail & video to firebase")
                                
                                self.setToFirebase(imageUrl, caption: caption, FIRVideoURL: FIRVideoURL)
                                
                                return nil
                            })
                        })
                        
                    } else {
                        
                        print("save image only to firebase")
                        
                        self.setToFirebase(imageUrl, caption: caption, FIRVideoURL: nil)
                        
                    }
                    
                } else {
                    print("error uploading: \(task.error)")
                    
                    let alertController = UIAlertController(title: "Sorry", message: "Error uploading, please try again", preferredStyle:  UIAlertControllerStyle.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                        
                        self.uploadingOutlet.alpha = 0
                        
                        self.isRecording = false
                        
                        self.backButtonOutlet.alpha = 1
                        self.back2ButtonOutlet.isEnabled = true
                        
                        if let myCity = self.rootController?.selfData["city"] as? String {
                            
                            self.tapToTakeOutlet.text = "Show off YOUR \(myCity)!"
                            
                        }
                        
                        
                        self.flipCameraButtonOutlet.alpha = 1
                        
                        
                        self.captureButtonOutlet.setImage(UIImage.init(named: "cameraIcon"), for: .normal)
                        
                    }))
                    

                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                
                return nil
                
            })
        }

        
                
        
    }


    
    func handleImage(image: UIImage) {
        
        UIApplication.shared.isStatusBarHidden = false
        
        let scopeChatType = chatType
        
        var scopeCurrentKey = ""
        var scopePassedRef = ""
        let scopeType = cameraType
        
        if chatType == "chat" {
            
            if let key = self.rootController?.chatController?.currentKey {
                
                scopeCurrentKey = key
                
            }
            
            if let ref = self.rootController?.chatController?.passedRef {
                
                scopePassedRef = ref
                
            }

            self.rootController?.chatController?.uploadMedia(true, image: image, videoURL: nil) { (date, fileName, messageData) in
                
                let request = self.uploadRequest(image)
                
                let transferManager = AWSS3TransferManager.default()
                
                transferManager?.upload(request).continue({ (task) -> AnyObject? in
                    
                    if task.error == nil {
                        
                        if let key = request.key, let myUid = FIRAuth.auth()?.currentUser?.uid, let selfData = self.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                            
                            let myName = myFirstName + " " + myLastName
                            
                            let ref = FIRDatabase.database().reference()
                            
                            var notificationItem = [AnyHashable: Any]()
                            notificationItem["text"] = "Sent Photo!"
                            
                            let timeStamp = date.timeIntervalSince1970
                            
                            var messageItem: [AnyHashable: Any] = [
                                
                                "key" : fileName,
                                "senderId" : myUid,
                                "timeStamp" : timeStamp,
                                "text" : "Sent a photo!",
                                "senderDisplayName" : myName,
                                "isImage" : true,
                                "isMedia" : true,
                                "media" : "https://s3.amazonaws.com/cityscapebucket/" + key
                                
                            ]
                            
                            if scopeType == "matches" || scopeType == "squad" {
                                
                                messageItem["userUID"] = scopeCurrentKey
                                
                            } else if scopeType == "groupChats" {
                                
                                messageItem["chatKey"] = scopeCurrentKey
                                notificationItem["chatKey"] = scopeCurrentKey
                                
                            } else if scopeType == "posts" {
                                
                                notificationItem["type"] = "postComment"
                                notificationItem["postChildKey"] = scopeCurrentKey
                                
                                if let city = self.rootController?.topChatController?.postCity {
                                    
                                    notificationItem["city"] = city
                                    
                                }
                                
                                if let postUrl = self.rootController?.topChatController?.postURL {
                                    
                                    notificationItem["image"] = postUrl
                                    
                                }
                                
                                if let userUid = self.rootController?.topChatController?.uid {
                                    
                                    
                                    
                                    self.postUid = userUid
                                    
                                }
                                
                                messageItem["postChildKey"] = scopeCurrentKey
                                
                            }
                            
                            if let firstName = self.rootController?.selfData["firstName"] as? String, let lastName = self.rootController?.selfData["lastName"] as? String {
                                
                                if scopeType != "groupChats" {
                                    
                                    notificationItem["firstName"] = firstName
                                    notificationItem["lastName"] = lastName
                                    
                                }
                                
                                messageItem["firstName"] = firstName
                                messageItem["lastName"] = lastName
                                
                            }
                            
                            
                            notificationItem["read"] = false
                            notificationItem["timeStamp"] = timeStamp
                            notificationItem["type"] = scopeType
                            
                            if scopeType == "matches" || scopeType == "squad" {
                                
                                ref.child("users").child(scopeCurrentKey).child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                    
                                    if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                        
                                        appDelegate.pushMessage(uid: scopeCurrentKey, token: token, message: "\(myName): Sent a photo!")
                                        
                                    }
                                })
                                
                                ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                ref.child(scopePassedRef).child("lastActivity").setValue(timeStamp)
                                
                                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                                    
                                    notificationItem["uid"] = selfUID
                                    
                                    ref.child("users").child(scopeCurrentKey).child("\(scopeType)").child(selfUID).child("lastActivity").setValue(timeStamp)
                                    ref.child("users").child(scopeCurrentKey).child("\(scopeType)").child(selfUID).child("messages").childByAutoId().setValue(messageItem)
                                    ref.child("users").child(scopeCurrentKey).child("\(scopeType)").child(selfUID).child("read").setValue(false)
                                    
                                    ref.child("users").child(scopeCurrentKey).child("notifications").child(selfUID).child("\(scopeType)").setValue(notificationItem)
                                    
                                }
                            } else if scopeType == "groupChats" {
                                
                                
                                
                                if let scopeTitle = self.rootController?.topChatController?.chatTitleOutlet.text {
                                    
                                    notificationItem["title"] = scopeTitle
                                    
                                }
                                
                                if let groupPhoto = self.rootController?.topChatController?.groupPicture {
                                    
                                    notificationItem["groupPhoto"] = groupPhoto
                                    
                                }
    
                                ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                ref.child(scopePassedRef).child("timeStamp").setValue(timeStamp)
                                
                                if let members = self.rootController?.topChatController?.members {
                                    
                                    for member in members {
                                        FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(scopeCurrentKey).child("timeStamp").setValue(timeStamp)
                                        FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(scopeCurrentKey).child("read").setValue(false)
                                        
                                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                                            
                                            if member != selfUID {
                                                
                                                
                                                ref.child("users").child(member).child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                                    
                                                    if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let groupChatName = self.rootController?.topChatController?.chatTitleOutlet.text {
                                                        
                                                        appDelegate.pushMessage(uid: member, token: token, message: "\(myName) to \(groupChatName): Sent a photo!")
                                                        
                                                    }
                                                })
                                                
                                                
                                                FIRDatabase.database().reference().child("users").child(member).child("notifications").child("groupChats").child(scopeCurrentKey).setValue(notificationItem)
                                                
                                            }
                                        }
                                    }
                                }
                            } else if scopeType == "posts" {
                                
                                ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                
                                if let myUid = FIRAuth.auth()?.currentUser?.uid {
                                    
                                    if myUid != self.postUid {
                                        
                                        notificationItem["senderUid"] = myUid
                                        
                                        ref.child("users").child(self.postUid).child("notifications").child(myUid).child("postComment").setValue(notificationItem)
                                        
                                    }
                                    
                                }
                            }
                            
                            
                            if scopeChatType == "chat" {

                                self.rootController?.chatController?.endedTyping()
                                self.rootController?.chatController?.finishSendingMessage()
                                
                            } else if scopeChatType == "snapchat" {
                                
                                
                                
                            }
                            
                        }
                        
                    } else {
                        
                        print("failed upload")
                        //Upload Failed
                    }
                    
                    return nil
                })
                
            }
            
            print("fusuma dismissed with image")

            
            
        } else if chatType == "snapchat" {
            
            if let key = self.rootController?.snapchatController?.snapchatChatController?.currentPostKey {
                
                scopeCurrentKey = key
                
                
            }
            
            if let ref = self.rootController?.snapchatController?.snapchatChatController?.passedRef {
                
                scopePassedRef = ref
                
            }
            
            
            self.rootController?.snapchatController?.snapchatChatController?.uploadMedia(true, image: image, videoURL: nil) { (date, fileName, messageData) in
                
                let request = self.uploadRequest(image)
                
                let transferManager = AWSS3TransferManager.default()
                
                transferManager?.upload(request).continue({ (task) -> AnyObject? in
                    
                    if task.error == nil {
                        
                        if let key = request.key, let myUid = FIRAuth.auth()?.currentUser?.uid, let selfData = self.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                            
                            let myName = myFirstName + " " + myLastName
                            
                            let ref = FIRDatabase.database().reference()
                            
                            var notificationItem = [AnyHashable: Any]()
                            notificationItem["text"] = "Sent Photo!"
                            
                            let timeStamp = date.timeIntervalSince1970
                            
                            var messageItem: [AnyHashable: Any] = [
                                
                                "key" : fileName,
                                "senderId" : myUid,
                                "timeStamp" : timeStamp,
                                "text" : "Sent a photo!",
                                "senderDisplayName" : myName,
                                "isImage" : true,
                                "isMedia" : true,
                                "media" : "https://s3.amazonaws.com/cityscapebucket/" + key
                                
                            ]
                            
                            
                            if let firstName = self.rootController?.selfData["firstName"] as? String, let lastName = self.rootController?.selfData["lastName"] as? String {
                                
                                if scopeType != "groupChats" {
                                    
                                    notificationItem["firstName"] = firstName
                                    notificationItem["lastName"] = lastName
                                    
                                }
                                
                                messageItem["firstName"] = firstName
                                messageItem["lastName"] = lastName
                                
                            }
                            
                            notificationItem["type"] = "postComment"
                            notificationItem["postChildKey"] = scopeCurrentKey
                            
                            if let city = self.rootController?.topChatController?.postCity {
                                
                                notificationItem["city"] = city
                                
                            }
                            
                            if let postUrl = self.rootController?.topChatController?.postURL {
                                
                                notificationItem["image"] = postUrl
                                
                            }
                            
                            if let userUid = self.rootController?.topChatController?.uid {
                                
                                self.postUid = userUid
                                
                            }
                            
                            messageItem["postChildKey"] = scopeCurrentKey
 
                            notificationItem["read"] = false
                            notificationItem["timeStamp"] = timeStamp
                            notificationItem["type"] = scopeType
                            
                            ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                            
                            if let myUid = FIRAuth.auth()?.currentUser?.uid {
                                
                                if myUid != self.postUid {
                                    
                                    notificationItem["senderUid"] = myUid
                                    
                                    ref.child("users").child(self.postUid).child("notifications").child(myUid).child("postComment").setValue(notificationItem)
                                    
                                }
                            }

                            self.rootController?.snapchatController?.snapchatChatController?.endedTyping()
                            self.rootController?.snapchatController?.snapchatChatController?.finishSendingMessage()

                            
                        }
                        
                    } else {
                        
                        print("failed upload")
                        //Upload Failed
                    }
                    
                    return nil
                })
                
            }
            
            print("fusuma dismissed with image")
            
            
            
        }

        
        //Call Upload Function
        
        
        
        
        
        
        
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

                    if self.cameraType == "feed" {
                        
                        DispatchQueue.main.async {
                            
                            self.displayEditor(gallery: false, inImage: image, inVideo: nil)
                            
                        }
                        
                        
                        
                        /*
                        self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                            
                            print("handle post toggled")
                            
                        })
                        */
                        
                    } else {
                        
                        self.rootController?.toggleCamera(type: self.cameraType, chatType: self.chatType, completion: { (bool) in
                            
                            DispatchQueue.main.async {
                                
                                self.handleImage(image: image)
                                
                            }
                            
                        })
                        
                    }
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
                    
                    if self.cameraType == "feed" {
                        
                        DispatchQueue.main.async {
                            
                            self.displayEditor(gallery: false, inImage: image, inVideo: nil)
                            
                        }
                        
                        /*
                        self.rootController?.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                            
                            print("handle post toggled")
                            
                        })
                        */
                        
                    } else {

                        self.rootController?.toggleCamera(type: self.cameraType, chatType: self.chatType, completion: { (bool) in
                            
                            DispatchQueue.main.async {
                                
                                self.handleImage(image: image)
                                
                            }
                        })
                    }
                }
            }
            
        } else {
            
            isRecording = true
            
            backButtonOutlet.alpha = 0
            back2ButtonOutlet.isEnabled = false
            
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
            
            if self.cameraType == "feed" {
                
                DispatchQueue.main.async {
                    
                    self.displayEditor(gallery: true, inImage: image, inVideo: nil)
                    
                }

                
            } else {

                self.rootController?.toggleCamera(type: self.cameraType, chatType: self.chatType, completion: { (bool) in
                    
                    self.handleImage(image: image)
                    
                })
                
            }
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
            
            actualPreviewLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.cameraView.bounds.height)
            actualPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            /*
            let instances = 2
            let replicatorLayer = CAReplicatorLayer()
            replicatorLayer.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.width)
            replicatorLayer.instanceCount = instances
            replicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, self.view.bounds.size.width, 0)
            
            replicatorLayer.addSublayer(actualPreviewLayer)
            */
            
            self.cameraView.layer.addSublayer(actualPreviewLayer)
            
        }
    }
    
    func handleVideo(url: URL) {
        
        UIApplication.shared.isStatusBarHidden = false
        
        var scopePassedRef = ""
        var scopeCurrentKey = ""
        let scopeType = self.cameraType
        let scopeChatType = self.chatType

        
        if chatType == "chat" {
            
            if let ref = self.rootController?.chatController?.passedRef {
                
                scopePassedRef = ref
                
            }
            
            if let key = self.rootController?.chatController?.currentKey {
                
                scopeCurrentKey = key
                
            }

        } else if chatType == "snapchat" {
            
            if let ref = self.rootController?.snapchatController?.snapchatChatController?.passedRef {
                
                scopePassedRef = ref
                
            }
            
            if let key = self.rootController?.snapchatController?.snapchatChatController?.currentPostKey {
                
                scopeCurrentKey = key
                
            }
        }
        
        
        self.rootController?.toggleCamera(type: "", chatType: "", completion: { (bool) in
            
            DispatchQueue.main.async {
                
                if scopeChatType == "chat" {
                    
                    self.rootController?.chatController?.uploadMedia(false, image: nil, videoURL: url) { (date, fileName, messageData) in
                        
                        self.convertVideoToLowQualityWithInputURL(url, handler: { (exportSession, outputURL) in
                            
                            if exportSession.status == .completed {
                                
                                let request = AWSS3TransferManagerUploadRequest()
                                request?.body = outputURL
                                request?.key = fileName
                                request?.bucket = "cityscapebucket"
                                
                                let transferManager = AWSS3TransferManager.default()
                                
                                transferManager?.upload(request).continue({ (task) -> AnyObject? in
                                    
                                    if task.error == nil {
                                        
                                        if let key = request?.key, let myUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                                            
                                            let myName = myFirstName + " " + myLastName
                                            
                                            let ref = FIRDatabase.database().reference()
                                            
                                            var notificationItem = [AnyHashable: Any]()
                                            notificationItem["text"] = "Sent Video!"
                                            
                                            let timeStamp = date.timeIntervalSince1970
                                            
                                            var messageItem: [AnyHashable: Any] = [
                                                
                                                "key" : fileName,
                                                "senderId" : myUID,
                                                "timeStamp" : timeStamp,
                                                "text" : "Sent a video!",
                                                "senderDisplayName" : myName,
                                                "isImage" : false,
                                                "isMedia" : true,
                                                "media" : "https://s3.amazonaws.com/cityscapebucket/" + key
                                                
                                            ]
                                            
                                            if scopeType == "matches" || scopeType == "squad" {
                                                
                                                messageItem["userUID"] = scopeCurrentKey
                                                
                                            } else if scopeType == "groupChats" {
                                                
                                                messageItem["chatKey"] = scopeCurrentKey
                                                notificationItem["chatKey"] = scopeCurrentKey
                                                
                                            } else if scopeType == "posts" {
                                                
                                                notificationItem["type"] = "postComment"
                                                notificationItem["postChildKey"] = scopeCurrentKey
                                                
                                                
                                                if let city = self.rootController?.topChatController?.postCity {
                                                    
                                                    notificationItem["city"] = city
                                                    
                                                }
                                                
                                                
                                                if let postUrl = self.rootController?.topChatController?.postURL {
                                                    
                                                    notificationItem["image"] = postUrl
                                                    
                                                }
                                                
                                                if let userUid = self.rootController?.topChatController?.uid {
                                                    
                                                    self.postUid = userUid
                                                    
                                                }
                                                
                                                messageItem["postChildKey"] = scopeCurrentKey
                                                
                                            }
                                            
                                            if let firstName = self.rootController?.selfData["firstName"] as? String, let lastName = self.rootController?.selfData["lastName"] as? String {
                                                
                                                if scopeType != "groupChats" {
                                                    
                                                    notificationItem["firstName"] = firstName
                                                    notificationItem["lastName"] = lastName
                                                    
                                                }
                                                
                                                messageItem["firstName"] = firstName
                                                messageItem["lastName"] = lastName
                                                
                                            }
                                            
                                            
                                            notificationItem["read"] = false
                                            notificationItem["timeStamp"] = timeStamp
                                            notificationItem["type"] = scopeType
                                            
                                            if scopeType == "matches" || scopeType == "squad" {
                                                
                                                ref.child("users").child(scopeCurrentKey).child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                                    
                                                    if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                                        
                                                        appDelegate.pushMessage(uid: scopeCurrentKey, token: token, message: "\(myName): Sent a video!")
                                                        
                                                    }
                                                })
                                                
                                                
                                                ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                                ref.child(scopePassedRef).child("lastActivity").setValue(timeStamp)
                                                
                                                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                                                    
                                                    notificationItem["uid"] = selfUID
                                                    
                                                    ref.child("users").child(scopeCurrentKey).child("\(scopeType)").child(selfUID).child("lastActivity").setValue(timeStamp)
                                                    ref.child("users").child(scopeCurrentKey).child("\(scopeType)").child(selfUID).child("messages").childByAutoId().setValue(messageItem)
                                                    ref.child("users").child(scopeCurrentKey).child("\(scopeType)").child(selfUID).child("read").setValue(false)
                                                    
                                                    ref.child("users").child(scopeCurrentKey).child("notifications").child(selfUID).child("\(scopeType)").setValue(notificationItem)
                                                    
                                                }
                                            } else if scopeType == "groupChats" {
                                                
                                                //notificationItem["title"] =
                                                
                                                if let scopeTitle = self.rootController?.topChatController?.chatTitleOutlet.text {
                                                    
                                                    notificationItem["title"] = scopeTitle
                                                    
                                                }
                                                
                                                if let groupPhoto = self.rootController?.topChatController?.groupPicture {
                                                    
                                                    notificationItem["groupPhoto"] = groupPhoto
                                                    
                                                }
                                                
                                                
                                                ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                                ref.child(scopePassedRef).child("timeStamp").setValue(timeStamp)
                                                
                                                if let members = self.rootController?.topChatController?.members {
                                                    
                                                    for member in members {
                                                        
                                                        FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(scopeCurrentKey).child("timeStamp").setValue(timeStamp)
                                                        FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(scopeCurrentKey).child("read").setValue(false)
                                                        
                                                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                                                            
                                                            if member != selfUID {
                                                                
                                                                ref.child("users").child(member).child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                                                    
                                                                    if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                                                        
                                                                        appDelegate.pushMessage(uid: member, token: token, message: "\(myName) to \(self.rootController?.topChatController?.chatTitleOutlet.text): Sent a video!")
                                                                        
                                                                    }
                                                                })
                                                                
                                                                
                                                                FIRDatabase.database().reference().child("users").child(member).child("notifications").child("groupChats").child(scopeCurrentKey).setValue(notificationItem)
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            } else if scopeType == "posts" {
                                                
                                                ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                                
                                                if let myUid = FIRAuth.auth()?.currentUser?.uid {
                                                    
                                                    if myUid != self.postUid {
                                                        
                                                        notificationItem["senderUid"] = myUid
                                                        
                                                        ref.child("users").child(self.postUid).child("notifications").child(myUid).child("postComment").setValue(notificationItem)
                                                        
                                                    }
                                                    
                                                }
                                            }
       
                                            
                                            if scopeChatType == "chat" {
 
                                                self.rootController?.chatController?.endedTyping()
                                                self.rootController?.chatController?.finishSendingMessage()
                                                
                                            } else if scopeChatType == "snapchat" {

                                                self.rootController?.snapchatController?.snapchatChatController?.endedTyping()
                                                self.rootController?.snapchatController?.snapchatChatController?.finishSendingMessage()

                                            }
                                        }
                                    }
                                    
                                    return nil
                                    
                                })
                                
                                print("good convert")
                                
                            } else {
                                
                                print("bad convert")
                                
                            }
                        })
                    }
                    
                } else if scopeChatType == "snapchat" {
                    
                    self.rootController?.snapchatController?.snapchatChatController?.uploadMedia(false, image: nil, videoURL: url) { (date, fileName, messageData) in
                        
                        self.convertVideoToLowQualityWithInputURL(url, handler: { (exportSession, outputURL) in
                            
                            if exportSession.status == .completed {
                                
                                let request = AWSS3TransferManagerUploadRequest()
                                request?.body = outputURL
                                request?.key = fileName
                                request?.bucket = "cityscapebucket"
                                
                                let transferManager = AWSS3TransferManager.default()
                                
                                transferManager?.upload(request).continue({ (task) -> AnyObject? in
                                    
                                    if task.error == nil {
                                        
                                        if let key = request?.key, let selfData = self.rootController?.selfData, let myUID = FIRAuth.auth()?.currentUser?.uid, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                                            
                                            let myName = myFirstName + " " + myLastName
                                            
                                            let ref = FIRDatabase.database().reference()
                                            
                                            var notificationItem = [AnyHashable: Any]()
                                            notificationItem["text"] = "Sent Video!"
                                            
                                            let timeStamp = date.timeIntervalSince1970
                                            
                                            var messageItem: [AnyHashable: Any] = [
                                                
                                                "key" : fileName,
                                                "senderId" : myUID,
                                                "timeStamp" : timeStamp,
                                                "text" : "Sent a video!",
                                                "senderDisplayName" : myName,
                                                "isImage" : false,
                                                "isMedia" : true,
                                                "media" : "https://s3.amazonaws.com/cityscapebucket/" + key
                                                
                                            ]
                                            
                                            notificationItem["type"] = "postComment"
                                            notificationItem["postChildKey"] = scopeCurrentKey
                                            
                                            
                                            if let city = self.rootController?.topChatController?.postCity {
                                                
                                                notificationItem["city"] = city
                                                
                                            }
                                            
                                            
                                            if let postUrl = self.rootController?.topChatController?.postURL {
                                                
                                                notificationItem["image"] = postUrl
                                                
                                            }
                                            
                                            if let userUid = self.rootController?.topChatController?.uid {
                                                
                                                self.postUid = userUid
                                                
                                            }
                                            
                                            messageItem["postChildKey"] = scopeCurrentKey

                                            
                                            if let firstName = self.rootController?.selfData["firstName"] as? String, let lastName = self.rootController?.selfData["lastName"] as? String {
                                                
                                                if scopeType != "groupChats" {
                                                    
                                                    notificationItem["firstName"] = firstName
                                                    notificationItem["lastName"] = lastName
                                                    
                                                }
                                                
                                                messageItem["firstName"] = firstName
                                                messageItem["lastName"] = lastName
                                                
                                            }
                                            
                                            
                                            notificationItem["read"] = false
                                            notificationItem["timeStamp"] = timeStamp
                                            notificationItem["type"] = scopeType
                                            
                                            ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                            
                                            if let myUid = FIRAuth.auth()?.currentUser?.uid {
                                                
                                                if myUid != self.postUid {
                                                    
                                                    notificationItem["senderUid"] = myUid
                                                    
                                                    ref.child("users").child(self.postUid).child("notifications").child(myUid).child("postComment").setValue(notificationItem)
                                                    
                                                }
                                                
                                            }

                                            if scopeChatType == "chat" {
                                                
                                                self.rootController?.chatController?.endedTyping()
                                                self.rootController?.chatController?.finishSendingMessage()
                                                
                                            } else if scopeChatType == "snapchat" {
                                                
                                                self.rootController?.snapchatController?.snapchatChatController?.endedTyping()
                                                self.rootController?.snapchatController?.snapchatChatController?.finishSendingMessage()
                                                
                                            }

                                            
                                        }
                                    }
                                    
                                    return nil
                                    
                                })
                                
                                print("good convert")
                                
                            } else {
                                
                                print("bad convert")
                                
                            }
                        })
                    }
                }
            }
        })
    }
    
    //Convert Video
    func convertVideoToLowQualityWithInputURL(_ inputURL: URL, handler: @escaping (AVAssetExportSession, URL) -> Void) {
        
        let tempURL = inputURL
        
        let newAsset: AVURLAsset = AVURLAsset(url: tempURL)
        
        if let exportSession: AVAssetExportSession = AVAssetExportSession(asset: newAsset, presetName: AVAssetExportPresetMediumQuality) {
            
            
            let fileName = ProcessInfo.processInfo.globallyUniqueString + ".mov"
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload").appendingPathComponent(fileName)
            
            exportSession.outputURL = fileURL
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.exportAsynchronously(completionHandler: { () -> Void in
                
                handler(exportSession, fileURL)
                
                print("Export Session Done")
                
            })
        }
    }

    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print("done recording")

        self.backButtonOutlet.alpha = 1
        self.back2ButtonOutlet.isEnabled = true
        
        timer.invalidate()
        ms = 0
        s = 0
        
        if self.cameraType == "feed" {
            
            self.displayEditor(gallery: false, inImage: nil, inVideo: outputFileURL)

        } else {
            
            DispatchQueue.main.async {
                
                self.handleVideo(url: outputFileURL)
                
            }
        }
    }
    
    func uploadRequest(_ image: UIImage) -> AWSS3TransferManagerUploadRequest {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".jpeg"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload").appendingPathComponent(fileName)
        let filePath = fileURL.path
        
        let imageData = UIImageJPEGRepresentation(image, 0.25)
        try? imageData?.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = fileURL
        uploadRequest?.key = fileName
        uploadRequest?.bucket = "cityscapebucket"
        
        return uploadRequest!
        
    }

    
    override func viewDidLayoutSubviews() {
        
        guard let actualPreviewLayer = previewLayer else {
            print("Unable to cast create a preview layer from the session")
            return
        }
        
        actualPreviewLayer.frame = cameraView.bounds
        actualPreviewLayer.position = CGPoint(x: cameraView.bounds.midX, y: cameraView.bounds.midY)
        
    }
    
    func keyboardShown(){
        
        //self.dismissKeyboardOutlet.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.alertController.view.center.y -= 120
            self.alertController.view.layoutIfNeeded()
            
        })
    }
    
    
    func keyboardHid(){
        
        //self.dismissKeyboardOutlet.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.alertController.view.center.y += 120
            self.alertController.view.layoutIfNeeded()
            
        })
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "\n" {
            
            textField.resignFirstResponder()
            return false
            
        }
        
        guard let text = textField.text else {return false}
        return text.characters.count + (string.characters.count - range.length) <= 30
        
    }
    
    func addUploadStuff(){
        
        let error = NSErrorPointer.init(nilLiteral: ())
        
        do{
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "rate" {
            
            if let player = object as? AVPlayer, let item = player.currentItem {
                
                if CMTimeGetSeconds(player.currentTime()) == CMTimeGetSeconds(item.duration) {
                    
                    player.seek(to: kCMTimeZero)
                    player.play()
                    
                } else if player.rate == 0 {
                    
                    player.play()
                    
                }
            }
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHid), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tapToTakeOutlet.adjustsFontSizeToFitWidth = true
        redIndicatorOutlet.layer.cornerRadius = 7
        
        addUploadStuff()
        
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
