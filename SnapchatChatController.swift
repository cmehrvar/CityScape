//
//  VibesChatController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-04.
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

class SnapchatChatController: JSQMessagesViewController, FusumaDelegate, PlayerDelegate, UIGestureRecognizerDelegate {
    
    weak var snapchatController: SnapchatViewController?
    
    //JSQData
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
    
    var typeOfChat = "snapchat"
    
    var keyboardShown = false
    var chatEnlarged = false
    
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
        
        print("send pressed")
        
        let ref = FIRDatabase.database().reference()
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".txt")
        let date = NSDate()
        let timeStamp = date.timeIntervalSince1970
        
        print(senderId)
        print(senderDisplayName)
        
        var messageItem: [String : AnyObject] = [
            
            "key" : fileName,
            "text" : text,
            "senderId" : senderId,
            "timeStamp" : timeStamp,
            "senderDisplayName" : senderDisplayName,
            "isMedia" : false,
            "isImage" : false,
            "media" : "none",
            
            ]
        
        if let firstName = self.snapchatController?.rootController?.selfData["firstName"] as? String, lastName = self.snapchatController?.rootController?.selfData["lastName"] as? String {
            
            messageItem["firstName"] = firstName
            messageItem["lastName"] = lastName
            
        }
        
        ref.child(passedRef).child("messages").childByAutoId().setValue(messageItem)
        
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
        
        let scopePassedRef = self.passedRef
        
        //Call Upload Function
        uploadMedia(true, image: image, videoURL: nil) { (date, fileName, messageData) in
            
            let request = self.uploadRequest(image)
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            transferManager.upload(request).continueWithBlock({ (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    print("succesful upload!")
                    
                    let ref = FIRDatabase.database().reference()

                    if let key = request.key {
                        
                        let timeStamp = NSDate().timeIntervalSince1970
                        
                        let messageItem = [
                            "key" : fileName,
                            "text" : "sent a photo!",
                            "senderId": self.senderId,
                            "timeStamp" : timeStamp,
                            "senderDisplayName" : self.senderDisplayName,
                            "isMedia" : true,
                            "isImage" : true,
                            "media" : "https://s3.amazonaws.com/cityscapebucket/" + key,
                            
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
        
        let scopePassedRef = self.passedRef
        
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
                        
                        
                        if let key = request.key {
                            
                            let timeStamp = NSDate().timeIntervalSince1970
                            
                            let messageItem = [
                                "key" : fileName,
                                "text" : "sent a video!",
                                "senderId": self.senderId,
                                "timeStamp" : timeStamp,
                                "senderDisplayName" : self.senderDisplayName,
                                "isMedia" : true,
                                "isImage" : false,
                                "media" : "https://s3.amazonaws.com/cityscapebucket/" + key,
                                
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
    func newObserveMessages(){
        
        let ref = FIRDatabase.database().reference().child(passedRef)
        
        var index = 0
        
        ref.child("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject : AnyObject] {
                
                if let id = value["senderId"] as? String, text = value["text"] as? String, name = value["senderDisplayName"] as? String, media = value["media"] as? String, isImage = value["isImage"] as? Bool, isMedia = value["isMedia"] as? Bool, key = value["key"] as? String, timeStamp = value["timeStamp"] as? NSTimeInterval {
                    
                    let date = NSDate(timeIntervalSince1970: timeStamp)
                    let sentMessage = self.addedMessages[key]
                    
                    if sentMessage == nil {
                        self.addMessage(id, text: text, name: name, isMedia: isMedia, media: media, isImage: isImage, date: date, key: key, i: index)
                    }
                }
                
                index += 1
                
            }
        })
    }
    
    
    //Add Message
    func addMessage(id: String, text: String, name: String, isMedia: Bool, media: String, isImage: Bool, date: NSDate, key: String, i: Int) {
        
        print(text)

        if addedMessages[key] == false || addedMessages[key] == nil {
            
            addedMessages[key] = true
            
            if isMedia {
                
                if isImage {
                    
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
                                
                                self.messages.insert(messageData, atIndex: i)
                                
                                self.finishReceivingMessage()
                                
                            }
                        })
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
                        
                        self.messages.insert(messageData, atIndex: i)
                        
                        self.finishReceivingMessage()
                    }
                    
                }
                
            } else {
                
                let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text)
                
                self.messageKeys.append(key)
                self.messages.append(message)
                
                self.finishReceivingMessage()
                
            }

            if avatars[id] == nil {
                
                let ref = FIRDatabase.database().reference().child("users").child(id).child("profilePicture")
                
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                        
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
                })
            }
        }
    }
    
    //Upload Media
    func uploadMedia(isImage: Bool, image: UIImage?, videoURL: NSURL?, handler: (date: NSDate, fileName: String, messageData: JSQMessageData) -> Void){
        
        let date = NSDate()
        var fileName = ""
        var messageData: JSQMessage!
        
        if isImage {
            
            fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
            let message = JSQPhotoMediaItem(image: image)
            message.mediaView().contentMode = UIViewContentMode.ScaleAspectFill
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        } else {
            
            fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
            let message = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        }
        
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
    
    func dismissKeyboard(){
        
        if keyboardShown {
            self.view.endEditing(true)
        }
    }
    
    
    func hideKeyboard(notification: NSNotification){
        
        print("hide keyboard")
        
        if let rootWidth = self.snapchatController?.rootController?.view.bounds.width {
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.snapchatController?.contentHeightConstOutlet.constant = rootWidth
                
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.keyboardShown = false
            })
            
        }
        
    }
    
    
    
    func showKeyboard(notification: NSNotification){
        
        print("show keyboard")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(), rootWidth = self.snapchatController?.rootController?.view.bounds.width {
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.snapchatController?.contentHeightConstOutlet.constant = rootWidth - keyboardSize.height
                
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.keyboardShown = true
            })
            
        }
        
    }
    
    
    
    //PAN HANDLER
    func panHandler(sender: UIPanGestureRecognizer){
        
        let translation = sender.translationInView(self.view)
        
        switch sender.state {
            
        case .Ended:
            
            print("end y: \(translation.y)")
            
            if translation.y < -125 {

                enlargeChat()

            } else if translation.y > 125 {
                
                shrinkChat()
                
            } else {
                
                print("not long enough gesture")
                
            }
            
        default:
            break
            
        }
    }
    
    
    func shrinkChat(){
        
        if chatEnlarged {
            
            self.chatEnlarged = false
            
            print("shrink chat")
            
            guard let rootWidth = self.snapchatController?.rootController?.view.bounds.width else {return}
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.snapchatController?.contentHeightConstOutlet.constant = rootWidth
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in

                    
            })
        }
    }
    
    
    func enlargeChat(){
        
        if !chatEnlarged {
            
            self.chatEnlarged = true
            
            print("enlarge chat")
            
            UIView.animateWithDuration(0.3, animations: {

                self.snapchatController?.contentHeightConstOutlet.constant = 150
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    
                    
            })
        }
    }
    
    
    func addGestureRecognizers(){
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        self.collectionView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        panGesture.delegate = self
        self.collectionView.addGestureRecognizer(panGesture)
        
        
    }
    
    
    
    override func viewDidLoad() {
        
        self.senderId = "none"
        self.senderDisplayName = "none"
        
        super.viewDidLoad()
        
        self.collectionView.collectionViewLayout.springinessEnabled = false
        self.keyboardController.textView.autocorrectionType = .No
        
        addGestureRecognizers()
        
        
        addUploadStuff()
        setUpBubbles()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
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
