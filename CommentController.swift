//
//  CommentController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-04.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage
import Fusuma
import AWSS3
import AWSCore
import AWSCognito

class CommentController: JSQMessagesViewController, FusumaDelegate {
    
    weak var rootController: ChatRootController?
    
    //JSQData
    var passedRef = ""
    var messages = [JSQMessageData]()
    var avatars = [String : JSQMessagesAvatarImage]()
    var avatarDataSource = [JSQMessageAvatarImageDataSource]()
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var exportedVideoURL = NSURL()
    
    
    
    //Fusuma Delegates
    func fusumaImageSelected(image: UIImage) {
        
        print("image selected")
        
    }
    
    
    func fusumaDismissedWithImage(image: UIImage) {
        
        let date = NSDate()
        
        let message = JSQPhotoMediaItem(image: image)
        let messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
        self.messages.append(messageData)
        
        uploadPost(image, videoURL: nil, isImage: true)
        
        print("fusuma dismissed with image")
        
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        print("fusuma video completed")
        
        convertVideoToLowQualityWithInputURL(fileURL, handler: { (exportSession, outputURL) in
            
            let date = NSDate()
            
            if exportSession.status == .Completed {
                
                let message = JSQVideoMediaItem(fileURL: fileURL, isReadyToPlay: true)
                let messageData = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: date, media: message)
                self.messages.append(messageData)
                
                self.uploadPost(nil, videoURL: fileURL, isImage: false)
                
                print("good convert")
                
            } else {
                
                print("bad convert")
                
            }
            
        })
        
        
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
        let alertController = UIAlertController(title: "Sorry", message: "Camera not authorized", preferredStyle:  UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        print("camera unauthorized")
        
    }
    
    
    func beganTyping(){
        
        let ref = FIRDatabase.database().reference()
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            ref.child(passedRef).child("isTyping").child(selfUID).setValue(true)
            
        }
    }
    
    func endedTyping(){
        
        let ref = FIRDatabase.database().reference()
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            ref.child(passedRef).child("isTyping").child(selfUID).setValue(false)
            
        }
    }
    
    private func setUpBubbles() {
        
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
    }
    
    
    override func textViewDidChange(textView: UITextView) {
        
        super.textViewDidChange(textView)
        
        if textView.text != "" {
            
            beganTyping()
            
        } else {
            
            endedTyping()
            
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if let id = message.senderId() {
            
            if id == senderId {
                return outgoingBubbleImageView
            } else {
                return incomingBubbleImageView
            }
        }
        
        return nil
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        
        if let id = message.senderId(){
            
            return avatars[id]
            
        }
        
        return nil
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        cell.cellBottomLabel.textColor = UIColor.blackColor()
        
        let isMedia = message.isMediaMessage()
        
        if !isMedia {
            
            if let id = message.senderId() {
                
                if id == senderId {
                    
                    cell.textView.textColor = UIColor.whiteColor()
                    
                } else {
                    
                    cell.textView.textColor = UIColor.blackColor()
                }
            }
        }
        
        return cell
        
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let ref = FIRDatabase.database().reference()
        let scopePassedRef = passedRef
        
        ref.child("users").child(senderId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject:AnyObject] {
                
                let timeStamp = NSDate().timeIntervalSince1970
                
                if let profile = value["profilePicture"] as? String, first = value["firstName"] as? String, last = value["lastName"] as? String {
                    
                    let messageItem = [
                        "text" : text,
                        "senderId":senderId,
                        "profilePicture" : profile,
                        "timeStamp" : timeStamp,
                        "firstName" : first,
                        "lastName" : last,
                        "senderDisplayName" : first + " " + last,
                        "isMedia" : false,
                        "isImage" : false,
                        "media" : "none"
                        
                    ]
                    
                    ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                    ref.child("users").child(senderId).child("posts").child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                    
                }
            }
        })
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        endedTyping()
        
        finishSendingMessage()
        
        
    }
    
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        presentFusumaCamera()
        
        
    }
    
    
    func presentFusumaCamera(){
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(fusuma, animated: true) {
            
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        if let messageId = message.senderId() {
            
            if let selfId = FIRAuth.auth()?.currentUser?.uid {
                
                if messageId != selfId {
                    
                    let indexPath = indexPath.item
                    var previousIsSame = false
                    
                    if indexPath > 0 {
                        
                        let previousMessage = messages[indexPath - 1]
                        
                        if let previousId = previousMessage.senderId() {
                            
                            if messageId == previousId {
                                
                                previousIsSame = true
                                
                            }
                        }
                    }
                    
                    if !previousIsSame {
                        
                        if let name = message.senderDisplayName() {
                            return NSAttributedString(string: name)
                            
                        }
                    }
                }
            }
        }
        
        return nil
        
    }
    
    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item]
        
        if let messageId = message.senderId() {
            
            if let selfId = FIRAuth.auth()?.currentUser?.uid {
                
                if messageId != selfId {
                    
                    let indexPath = indexPath.item
                    var previousIsSame = false
                    
                    if indexPath > 0 {
                        
                        let previousMessage = messages[indexPath - 1]
                        
                        if let previousId = previousMessage.senderId() {
                            
                            if messageId == previousId {
                                
                                previousIsSame = true
                                
                            }
                        }
                    }
                    
                    if !previousIsSame {
                        return 15
                        
                    }
                }
            }
        }
        
        return 0
        
    }
    
    func observeMessages() {
        
        let refString = "/" + passedRef
        
        let ref = FIRDatabase.database().reference().child(refString).child("messages")
        
        ref.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            
            if let actualValue = snapshot.value as? [NSObject : AnyObject] {
                
                if let id = actualValue["senderId"] as? String, text = actualValue["text"] as? String, name = actualValue["senderDisplayName"] as? String, profile = actualValue["profilePicture"] as? String, media = actualValue["media"] as? String, isImage = actualValue["isImage"] as? Bool, isMedia = actualValue["isMedia"] as? Bool {
                    
                    self.addMessage(id, text: text, name: name, profileURL: profile, isMedia: isMedia, media: media, isImage: isImage)
                    
                    
                }
            }
            
            self.finishReceivingMessage()
        })
    }
    
    
    func addMessage(id: String, text: String, name: String, profileURL: String, isMedia: Bool, media: String, isImage: Bool) {
        
        let date = NSDate()
        
        if isMedia {
            
            if isImage {

                if let url = NSURL(string: media){
                    
                    SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .ContinueInBackground, progress: nil, completed: { (image, error, cache, bool, url) in
                        
                        let message = JSQPhotoMediaItem(image: image)
                        let messageData = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: message)
                        self.messages.append(messageData)
                        self.finishReceivingMessage()
                        
                    })
                }
            } else {
                
                if let url = NSURL(string: media) {
                    
                    let message = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
                    let messageData = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: message)
                    self.messages.append(messageData)
                    
                }
            }
        } else {
            
            let message = JSQMessage(senderId: id, displayName: name, text: text)
            messages.append(message)
            
        }
        
        
        if avatars[id] == nil {
            
            if let url = NSURL(string: profileURL) {
                
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions.ContinueInBackground, progress: nil, completed: { (image, error, cache, bool, url) in
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if id == selfUID {
                            
                            let userImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 36)
                            self.avatars[id] = userImage
                            
                            
                        } else {
                            
                            let userImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 48)
                            self.avatars[id] = userImage
                        }
                    }
                })
            }
        }
    }
    
    func uploadPost(image: UIImage!, videoURL: NSURL!, isImage: Bool) {
        
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
                
                let ref = FIRDatabase.database().reference()
                let scopePassedRef = self.passedRef
                
                ref.child("users").child(self.senderId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let value = snapshot.value as? [NSObject:AnyObject] {
                        
                        let timeStamp = NSDate().timeIntervalSince1970
                        
                        if let profile = value["profilePicture"] as? String, first = value["firstName"] as? String, last = value["lastName"] as? String {
                            
                            if let key = request.key {
                                
                                let messageItem = [
                                    "text" : "none",
                                    "senderId": self.senderId,
                                    "profilePicture" : profile,
                                    "timeStamp" : timeStamp,
                                    "firstName" : first,
                                    "lastName" : last,
                                    "senderDisplayName" : first + " " + last,
                                    "isMedia" : true,
                                    "isImage" : isImage,
                                    
                                    "media" : "https://s3.amazonaws.com/cityscapebucket/" + key
                                    
                                ]
                                
                                ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                ref.child("users").child(self.senderId).child("posts").child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                
                            }
                            
                        }
                    }
                })
                
                
                
            } else {
                
                print("error uploading: \(task.error)")
                
                let alertController = UIAlertController(title: "Whoops", message: "Error Uploading", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) in
                    
                    
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            
            
            return nil
        })
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        endedTyping()
        finishSendingMessage()
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
    
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUploadStuff()
        setUpBubbles()
        
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
