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
import Player

class CommentController: JSQMessagesViewController, FusumaDelegate, PlayerDelegate {
    
    weak var rootController: ChatRootController?
    
    //JSQData
    var messageIndex = 0

    var messageData = [[String : AnyObject]]()
    
    var videoPlayers = [String : Player]()
    
    var passedRef = ""
    var messages = [JSQMessageData]()
    var messageKeys = [String]()
    var avatars = [String : JSQMessagesAvatarImage]()
    var avatarDataSource = [JSQMessageAvatarImageDataSource]()
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var exportedVideoURL = NSURL()
    var addedMessages = [String : Bool]()
    var profileUrl = ""
    var firstName = ""
    var lastName = ""
    var postUID = ""
    
    //Player Delegates
    func playerReady(player: Player){
        
    }
    func playerPlaybackStateDidChange(player: Player){
        
    }
    func playerBufferingStateDidChange(player: Player){
        
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player){
        
    }
    func playerPlaybackDidEnd(player: Player){
        
        player.playFromBeginning()
        
    }
    
    func playerCurrentTimeDidChange(player: Player) {
        print("current time did change")
    }
    
    
    
    //Did press send button
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let ref = FIRDatabase.database().reference()
        let scopePassedRef = passedRef
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".txt")
        
        let timeStamp = NSDate().timeIntervalSince1970
        let dateFromTimeStamp = NSDate(timeIntervalSince1970: timeStamp)
        
        let offlineItem: [String : AnyObject] = [
        
            "key" : fileName,
            "text" : text,
            "senderId":senderId,
            "profilePicture" : profileUrl,
            "date" : date,
            "senderDisplayName" : firstName + " " + lastName,
            "isMedia" : false,
            "isImage" : false,
            "media" : "none"

        ]
        
        
        let messageItem: [String : AnyObject] = [
            "key" : fileName,
            "text" : text,
            "senderId":senderId,
            "profilePicture" : profileUrl,
            "timeStamp" : timeStamp,
            "firstName" : firstName,
            "lastName" : lastName,
            "senderDisplayName" : firstName + " " + lastName,
            "isMedia" : false,
            "isImage" : false,
            "media" : "none"
            
        ]
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        messages.append(message)
        messageKeys.append(fileName)
        
        messageData.append(offlineItem)

        addedMessages[fileName] = true
        
        addMessage(senderId, text: text, name: senderDisplayName, profileURL: profileUrl, isMedia: false, media: "none", isImage: false, date: dateFromTimeStamp, key: fileName, i: nil, offlineImage: nil)
        
        ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
        ref.child("users").child(postUID).child("posts").child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        endedTyping()
        
        finishSendingMessage()
        
        
    }
    
    
    //Did press accessory button
    override func didPressAccessoryButton(sender: UIButton!) {
        
        presentFusumaCamera()
        
        
    }


    //Fusuma Delegates
    func fusumaImageSelected(image: UIImage) {
        
        print("image selected")
        
    }
 
    func fusumaDismissedWithImage(image: UIImage) {
        
        //Call Upload Function
        
        uploadMedia(true, image: image, videoURL: nil) { (date, fileName, messageData) in
            
            let request = self.uploadRequest(image)
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            transferManager.upload(request).continueWithBlock({ (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    print("succesful upload!")
                    
                    let ref = FIRDatabase.database().reference()
                    let scopePassedRef = self.passedRef
                    
                    if let key = request.key {
                        
                        let timeStamp = NSDate().timeIntervalSince1970

                        let messageItem = [
                            "key" : fileName,
                            "text" : "sent a photo!",
                            "senderId": self.senderId,
                            "profilePicture" : self.profileUrl,
                            "timeStamp" : timeStamp,
                            "firstName" : self.firstName,
                            "lastName" : self.lastName,
                            "senderDisplayName" : self.firstName + " " + self.lastName,
                            "isMedia" : true,
                            "isImage" : true,
                            "media" : "https://s3.amazonaws.com/cityscapebucket/" + key
                            
                        ]
                        
                        ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                        ref.child("users").child(self.senderId).child("posts").child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                        
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

    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        uploadMedia(false, image: nil, videoURL: fileURL) { (date, fileName, messageData) in
            
            self.convertVideoToLowQualityWithInputURL(fileURL, handler: { (exportSession, outputURL) in
                
                if exportSession.status == .Completed {
                    
                    //Call Upload Function
                    let request = AWSS3TransferManagerUploadRequest()
                    request.body = outputURL
                    request.key = fileName
                    request.bucket = "cityscapebucket"
                    
                    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                    
                    transferManager.upload(request).continueWithBlock({ (task) -> AnyObject? in
                        
                        let ref = FIRDatabase.database().reference()
                        let scopePassedRef = self.passedRef
                        
                        if let key = request.key {
                            
                            let timeStamp = NSDate().timeIntervalSince1970
                            
                            let messageItem = [
                                "key" : fileName,
                                "text" : "sent a video!",
                                "senderId": self.senderId,
                                "profilePicture" : self.profileUrl,
                                "timeStamp" : timeStamp,
                                "firstName" : self.firstName,
                                "lastName" : self.lastName,
                                "senderDisplayName" : self.firstName + " " + self.lastName,
                                "isMedia" : true,
                                "isImage" : false,
                                "media" : "https://s3.amazonaws.com/cityscapebucket/" + key
                                
                            ]
                            
                            ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                            ref.child("users").child(self.senderId).child("posts").child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                            
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
 
    func presentFusumaCamera(){
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(fusuma, animated: true) {
            
        }
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
    
    
    //**************           Override Functions             **************//
    
    //Text Did Change
    override func textViewDidChange(textView: UITextView) {
        
        super.textViewDidChange(textView)
        
        if textView.text != "" {
            
            beganTyping()
            
        } else {
            
            endedTyping()
            
        }
    }
    
    //Message Data
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }
    
    //Items in section
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    //Message bubble Image
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
    
    
    //Avatar
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        
        if let id = message.senderId(){
            
            return avatars[id]
            
        }
        
        return nil
    }
    
    //Cell for item at index path
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
        } else {
            
            if let media = message.media!() as? JSQVideoMediaItem {
                
                let key = messageKeys[indexPath.item]
                
                if videoPlayers[key] == nil {
                    
                    if let url = media.fileURL {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.videoPlayers[key] = Player()
                            self.videoPlayers[key]?.delegate = self
                            
                            if let player = self.videoPlayers[key] {
                                
                                if let videoPlayerView = player.view {
                                    
                                    self.addChildViewController(player)
                                    player.view.frame = cell.mediaView.bounds
                                    player.didMoveToParentViewController(self)
                                    player.setUrl(url)
                                    player.fillMode = AVLayerVideoGravityResizeAspectFill
                                    player.playbackLoops = true
                                    player.playFromBeginning()
                                    cell.mediaView.addSubview(videoPlayerView)
                                    
                                    self.messageData[indexPath.item]["player"] = player
                                    
                                }
                            }
                        })
                    }
                } else {
                    
                    if let player = self.videoPlayers[key] {
                        
                        if let videoPlayerView = player.view {
                            
                            self.addChildViewController(player)
                            cell.mediaView.addSubview(videoPlayerView)
                            player.playFromBeginning()
                            
                        }
                    }
                }
            }             
         }
        
        return cell
        
    }
    
    //Top Cell Label Text
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        if let date = message.date() {
            
            if indexPath.item == 0 {
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                let dateObj = dateFormatter.stringFromDate(date)
                return NSAttributedString(string: dateObj)
                
            } else {
                
                let previousIndex = indexPath.item - 1
                
                let previousMessage = messages[previousIndex]
                
                if let previousDate = previousMessage.date() {
                    
                    let minutesAgo = date.minutesFrom(previousDate)
                    
                    let text = message.text!()
                    
                    if text != nil {
                        print(text)
                    }
                    
                    print(minutesAgo)
                    
                    if minutesAgo >= 10 {
                        
                        let dateFormatter = NSDateFormatter()
                        
                        let daysAgo = date.daysFrom(previousDate)
                        
                        if daysAgo > 0 {
                            
                            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                            
                        } else {
                            
                            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
                            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                            
                        }
                        
                        let dateObj = dateFormatter.stringFromDate(date)
                        return NSAttributedString(string: dateObj)
                        
                    }
                }
            }
        }
        
        return nil
    }
    
    //Height for Cell Top Label Text
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item]
        
        if indexPath.item == 0 {
            return 15
        } else if let date = message.date() {
            
            let previousIndex = indexPath.item - 1
            
            let previousMessage = messages[previousIndex]
            
            if let previousDate = previousMessage.date() {
                
                let minutesAgo = date.minutesFrom(previousDate)
                
                if minutesAgo >= 10 {
                    return 15
                }
            }
        }
        
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        let message = messages[indexPath.item]
        
        if let messageId = message.senderId() {
            
            if let selfId = FIRAuth.auth()?.currentUser?.uid {
                
                if messageId != selfId {
                    
                    let indexPath = indexPath.item
                    var nextIsSame = false
                    
                    if indexPath < messages.count - 1 {
                        
                        let nextMessage = messages[indexPath + 1]
                        
                        if let nextId = nextMessage.senderId() {
                            
                            if messageId == nextId {
                                
                                nextIsSame = true
                                
                            }
                        }
                    }
                    
                    if !nextIsSame {
                        
                        return 15
                    }
                }
            }
        }
        
        return 0
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        if let messageId = message.senderId() {
            
            if let selfId = FIRAuth.auth()?.currentUser?.uid {
                
                if messageId != selfId {
                    
                    let indexPath = indexPath.item
                    var nextIsSame = false
                    
                    if indexPath < messages.count - 1 {
                        
                        let nextMessage = messages[indexPath + 1]
                        
                        if let nextId = nextMessage.senderId() {
                            
                            if messageId == nextId {
                                
                                nextIsSame = true
                                
                            }
                        }
                    }
                    
                    if !nextIsSame {
                        
                        if let name = message.senderDisplayName() {
                            return NSAttributedString(string: name)
                            
                        }
                    }
                }
            }
        }
        
        return nil
        
    }
    
    
    
    //**************           Functions             **************//
    
    
    
    //Set up bubbles
    private func setUpBubbles() {
        
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
    }
    
    //Observe Messages
    
    func observeMessages() {
        
        let refString = "/" + passedRef
        
        let ref = FIRDatabase.database().reference().child(refString).child("messages")

        ref.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            
            if let actualValue = snapshot.value as? [NSObject : AnyObject] {
                
                if let id = actualValue["senderId"] as? String, text = actualValue["text"] as? String, name = actualValue["senderDisplayName"] as? String, profile = actualValue["profilePicture"] as? String, media = actualValue["media"] as? String, isImage = actualValue["isImage"] as? Bool, isMedia = actualValue["isMedia"] as? Bool, key = actualValue["key"] as? String, timeStamp = actualValue["timeStamp"] as? NSTimeInterval {
                    
                    let date = NSDate(timeIntervalSince1970: timeStamp)
                    
                    let sentMessage = self.addedMessages[key]
                    
                    if sentMessage == nil {
                        
                        // PUT PLACEHOLDERS AND SUCH HERE!!!!
                        
                        self.addMessage(id, text: text, name: name, profileURL: profile, isMedia: isMedia, media: media, isImage: isImage, date: date, key: key, i: nil, offlineImage: nil)
                    }
                }
            }
            
            self.finishReceivingMessage()
        })
    }
    
    
    //Add Message
    func addMessage(id: String, text: String, name: String, profileURL: String, isMedia: Bool, media: String, isImage: Bool, date: NSDate, key: String, i: Int?, offlineImage: UIImage?) {
        
        if addedMessages[key] == false || addedMessages[key] == nil {
            
            let scopeIndex = self.messageIndex

            let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text)
            self.messageKeys.append(key)
            self.messages.append(message)
            
            self.finishReceivingMessage()

            messageData.append(["senderId" : id, "text" : text, "senderDisplayName" : name, "profilePicture" : profileURL, "isMedia" : isMedia, "media" : media, "isImage" : isImage, "date" : date, "key" : key])
            
            
            if let index = i {
                
                if offlineImage != nil {
                    messageData[index]["offlineImage"] = offlineImage
                }

            }
            
            if let player = videoPlayers[key], index = i {

                messageData[index]["player"] = player
                
            }
            
            addedMessages[key] = true
            
            if isMedia {
                
                if isImage {
                    
                    if offlineImage != nil {
                        
                        let message = JSQPhotoMediaItem(image: offlineImage)
                        
                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            if selfUID == id {
                                
                                message.appliesMediaViewMaskAsOutgoing = true
                                
                            } else {
                                
                                message.appliesMediaViewMaskAsOutgoing = false
                                
                            }
                        }
                        
                        let messageData = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: message)
                        
                        self.messages[scopeIndex] = messageData

                    } else {
                        
                        if let url = NSURL(string: media){
                            
                            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .ContinueInBackground, progress: nil, completed: { (image, error, cache, bool, url) in
                                
                                if error == nil {
                                    
                                    let message = JSQPhotoMediaItem(image: image)
                                    
                                    
                                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                                        
                                        if selfUID == id {
                                            
                                            message.appliesMediaViewMaskAsOutgoing = true
                                            
                                        } else {
                                            
                                            message.appliesMediaViewMaskAsOutgoing = false
                                            
                                        }
                                    }
                                    
                                    let messageData = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: message)
                                    
                                    self.messages[scopeIndex] = messageData
                                    
                                }
                                
                                
                                
                            })
                        }

                        
                    }
                    
                    
                } else {
                    
                    
                        //Download Video, then we need to figure out how to play???
                        if let url = NSURL(string: media) {
                            
                            let message = JSQVideoMediaItem(fileURL: url, isReadyToPlay: false)
                            
                            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                                
                                if selfUID == id {
                                    
                                    message.appliesMediaViewMaskAsOutgoing = true
                                    
                                } else {
                                    
                                    message.appliesMediaViewMaskAsOutgoing = false
                                    
                                }
                            }

                            let messageData = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: message)
                            
                            self.messages[scopeIndex] = messageData
                        }
                    
                    
                    
                    
                    
                    

                }
                
                self.finishReceivingMessage()
                
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
                            
                            self.finishReceivingMessage()
                        }
                    })
                }
            }
            
            messageIndex += 1
            
        }

    }
    
    //Upload Media
    func uploadMedia(isImage: Bool, image: UIImage?, videoURL: NSURL?, handler: (date: NSDate, fileName: String, messageData: JSQMessageData) -> Void){
        
        let date = NSDate()
        var fileName = ""
        var messageData: JSQMessage!
        
        var offlineMessage = [String : AnyObject]()
        
        if isImage {
            
            fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
            let message = JSQPhotoMediaItem(image: image)
            message.mediaView().contentMode = UIViewContentMode.ScaleAspectFill
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
            offlineMessage["offlineImage"] = image
            offlineMessage["text"] = "sent a photo!"
            offlineMessage["isImage"] = true
            
        } else {
            
            fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
            let message = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)

            offlineMessage["text"] = "sent a video!"
            offlineMessage["isImage"] = false
        }
        
        offlineMessage["date"] = date
        offlineMessage["senderId"] = senderId
        offlineMessage["isMedia"] = true
        offlineMessage["key"] = fileName
        offlineMessage["senderDisplayName"] = senderDisplayName
        offlineMessage["profilePicture"] = profileUrl
        offlineMessage["media"] = "none"
        
        self.messageData.append(offlineMessage)
        self.messageKeys.append(fileName)
        self.messages.append(messageData)
        
        

        self.addedMessages[fileName] = true
        
        finishReceivingMessage()
        
        handler(date: date, fileName: fileName, messageData: messageData)
        
    }

    
    //Upload Request
    func uploadRequest(image: UIImage) -> AWSS3TransferManagerUploadRequest {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.25)
        imageData?.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "cityscapebucket"
        
        return uploadRequest
        
    }
    
    //Convert Video
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
    
    func observeTyping(){
        
        let refString = "/" + passedRef
        
        let ref = FIRDatabase.database().reference().child(refString).child("isTyping")
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            ref.observeEventType(.Value, withBlock:  { (snapshot) in
                
                var showType = false
                
                if let data = snapshot.value as? [String : Bool] {
                    
                    for (key, value) in data {
                        
                        if key != selfUID {
                            
                            if value == true {
                                showType = true
                            }
                        }
                    }
                    
                    self.showTypingIndicator = showType
                    
                    
                }
            })
        }
    }
    
    //Add Upload Stuff
    func addUploadStuff(){
        
        let error = NSErrorPointer()
        
        do{

            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
            
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    
    //View did appear
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.collectionViewLayout.springinessEnabled = false
        
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
