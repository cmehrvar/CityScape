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
//import Player

class CommentController: JSQMessagesViewController, FusumaDelegate, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootController?
    
    var maxContentOffset = CGFloat()
    
    //JSQData
    //var videoPlayers = [String : Player]()
    var passedRef = ""
    var typeOfChat = ""
    var currentKey = ""
    
    var messages = [JSQMessageData]()
    var messageData = [[NSObject : AnyObject]]()
    var addedMessages = [String : Bool]()
    
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    
    var exportedVideoURL = NSURL()
    
    var keyboardShown = false
    var chatEnlarged = false
    
    var contentOffset: CGFloat = 0
    var scrollingUp = true
    
    
    //Did press send button
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        print("send pressed")
        
        let ref = FIRDatabase.database().reference()
        
        var notificationItem = [NSObject : AnyObject]()
        notificationItem["text"] = text
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".txt")
        let timeStamp = date.timeIntervalSince1970
        
        var messageItem: [NSObject : AnyObject] = [
            
            "key" : fileName,
            "senderId" : senderId,
            "timeStamp" : timeStamp,
            "text" : text,
            "senderDisplayName" : senderDisplayName,
            "isImage" : false,
            "isMedia" : false,
            "media" : "none"
            
        ]
        
        if typeOfChat == "matches" || typeOfChat == "squad" {
            
            messageItem["userUID"] = currentKey
            
        } else if typeOfChat == "groupChats" {
            
            messageItem["chatKey"] = currentKey
            notificationItem["chatKey"] = currentKey
            
        } else if typeOfChat == "posts" {
            
            messageItem["postChildKey"] = currentKey
            
        }
        
        if let firstName = self.rootController?.selfData["firstName"] as? String, lastName = self.rootController?.selfData["lastName"] as? String {
            
            if typeOfChat != "groupChats" {
                
                notificationItem["firstName"] = firstName
                notificationItem["lastName"] = lastName
                
            }
            
            messageItem["firstName"] = firstName
            messageItem["lastName"] = lastName
            
        }
        
        
        notificationItem["read"] = false
        notificationItem["timeStamp"] = timeStamp
        notificationItem["type"] = typeOfChat
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self.messages.append(message)
        self.messageData.append(messageItem)
        self.addedMessages[fileName] = true
        
        if typeOfChat == "matches" || typeOfChat == "squad" {
            
            ref.child(passedRef).child("messages").childByAutoId().setValue(messageItem)
            ref.child(passedRef).child("lastActivity").setValue(timeStamp)
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                notificationItem["uid"] = selfUID
                
                ref.child("users").child(currentKey).child("\(typeOfChat)").child(selfUID).child("lastActivity").setValue(timeStamp)
                ref.child("users").child(currentKey).child("\(typeOfChat)").child(selfUID).child("messages").childByAutoId().setValue(messageItem)
                ref.child("users").child(currentKey).child("\(typeOfChat)").child(selfUID).child("read").setValue(false)
                
                ref.child("users").child(currentKey).child("notifications").child(selfUID).child("\(typeOfChat)").setValue(notificationItem)
                
            }
        } else if typeOfChat == "groupChats" {
            
            //notificationItem["title"] =
            
            if let scopeTitle = rootController?.topChatController?.chatTitleOutlet.text {
                
                notificationItem["title"] = scopeTitle
                
            }
            
            if let groupPhoto = rootController?.topChatController?.groupPicture {
                
                notificationItem["groupPhoto"] = groupPhoto
                
            }
            
            
            ref.child(passedRef).child("messages").childByAutoId().setValue(messageItem)
            ref.child(passedRef).child("timeStamp").setValue(timeStamp)
            
            if let members = rootController?.topChatController?.members {
                
                for member in members {
                    
                    FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(currentKey).child("timeStamp").setValue(timeStamp)
                    FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(currentKey).child("read").setValue(false)
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if member != selfUID {
                            
                            FIRDatabase.database().reference().child("users").child(member).child("notifications").child("groupChats").child(currentKey).setValue(notificationItem)
                            
                        }
                    }
                }
            }
        } else if typeOfChat == "posts" {
            
            ref.child(passedRef).child("messages").childByAutoId().setValue(messageItem)
            
        }
        
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
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        let scopeCurrentKey = currentKey
        let scopePassedRef = self.passedRef
        let scopeType = typeOfChat
        
        //Call Upload Function
        uploadMedia(true, image: image, videoURL: nil) { (date, fileName, messageData) in
            
            let request = self.uploadRequest(image)
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            transferManager.upload(request).continueWithBlock({ (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    if let key = request.key {
                        
                        let ref = FIRDatabase.database().reference()
                        
                        var notificationItem = [NSObject : AnyObject]()
                        notificationItem["text"] = "Sent Photo!"
                        
                        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
                        let timeStamp = date.timeIntervalSince1970
                        
                        var messageItem: [NSObject : AnyObject] = [
                            
                            "key" : fileName,
                            "senderId" : self.senderId,
                            "timeStamp" : timeStamp,
                            "text" : "Sent a photo!",
                            "senderDisplayName" : self.senderDisplayName,
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
                            
                            messageItem["postChildKey"] = scopeCurrentKey
                            
                        }
                        
                        if let firstName = self.rootController?.selfData["firstName"] as? String, lastName = self.rootController?.selfData["lastName"] as? String {
                            
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
                        
                        let photoItem = JSQPhotoMediaItem(image: image)
                        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: date, media: photoItem)
                        
                        self.messages.append(message)
                        self.messageData.append(messageItem)
                        self.addedMessages[fileName] = true
                        
                        if scopeType == "matches" || scopeType == "squad" {
                            
                            ref.child(self.passedRef).child("lastActivity").setValue(timeStamp)
                            
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
                                            FIRDatabase.database().reference().child("users").child(member).child("notifications").child("groupChats").child(scopeCurrentKey).setValue(notificationItem)
                                            
                                        }
                                    }
                                }
                            }
                        } else if scopeType == "posts" {
                            
                            ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                            
                        }
                        
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        self.endedTyping()
                        self.finishSendingMessage()
                        
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
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        let scopePassedRef = self.passedRef
        let scopeCurrentKey = currentKey
        let scopeType = typeOfChat
        
        uploadMedia(false, image: nil, videoURL: fileURL) { (date, fileName, messageData) in
            
            self.convertVideoToLowQualityWithInputURL(fileURL, handler: { (exportSession, outputURL) in
                
                if exportSession.status == .Completed {
                    
                    let request = AWSS3TransferManagerUploadRequest()
                    request.body = outputURL
                    request.key = fileName
                    request.bucket = "cityscapebucket"
                    
                    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                    
                    
                    
                    transferManager.upload(request).continueWithBlock({ (task) -> AnyObject? in
                        
                        if task.error == nil {
                            
                            if let key = request.key {
                                
                                let ref = FIRDatabase.database().reference()
                                
                                var notificationItem = [NSObject : AnyObject]()
                                notificationItem["text"] = "Sent Video!"
                                
                                let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
                                let timeStamp = date.timeIntervalSince1970
                                
                                var messageItem: [NSObject : AnyObject] = [
                                    
                                    "key" : fileName,
                                    "senderId" : self.senderId,
                                    "timeStamp" : timeStamp,
                                    "text" : "Sent a video!",
                                    "senderDisplayName" : self.senderDisplayName,
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
                                    
                                    messageItem["postChildKey"] = scopeCurrentKey
                                    
                                }
                                
                                if let firstName = self.rootController?.selfData["firstName"] as? String, lastName = self.rootController?.selfData["lastName"] as? String {
                                    
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
                                
                                let videoItem = JSQVideoMediaItem(fileURL: outputURL, isReadyToPlay: true)
                                let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: date, media: videoItem)
                                
                                self.messages.append(message)
                                self.messageData.append(messageItem)
                                self.addedMessages[fileName] = true
                                
                                if scopeType == "matches" || scopeType == "squad" {
                                    
                                    ref.child(scopeType).child("lastActivity").setValue(timeStamp)
                                    
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
                                                    FIRDatabase.database().reference().child("users").child(member).child("notifications").child("groupChats").child(scopeCurrentKey).setValue(notificationItem)
                                                    
                                                }
                                            }
                                        }
                                    }
                                } else if scopeType == "posts" {
                                    
                                    ref.child(scopePassedRef).child("messages").childByAutoId().setValue(messageItem)
                                    
                                }
                                
                                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                                self.endedTyping()
                                self.finishSendingMessage()
                                
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
    
    func presentFusumaCamera(){
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(fusuma, animated: true, completion: {
            
            print("camera presented")
            
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
        
        return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "Kate"), diameter: 48)
        
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if !messages.isEmpty {
            
            let message = messages[indexPath.item]
            
            if message.isMediaMessage() {
                
                if let anyCell = cell as? JSQMessagesCollectionViewCell {
                    
                    for view in anyCell.mediaView.subviews {
                        
                        view.removeFromSuperview()
                        
                    }
                }
            }
            
        }
    }
    
    
    //Cell for item at index path
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        cell.cellBottomLabel.textColor = UIColor.blackColor()
        
        if let id = message.senderId() {
            
            let ref = FIRDatabase.database().reference().child("users").child(id)
            
            ref.child("profilePicture").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let profileString = snapshot.value as? String, url = NSURL(string: profileString) {
                    
                    SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .ContinueInBackground, progress: { (currentSize, expectedSize) in
                        
                        
                        
                        }, completed: { (image, error, cache, bool, url) in
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                
                                let imageView = UIImageView(image: image)
                                imageView.contentMode = .ScaleAspectFill
                                imageView.frame = cell.avatarContainerView.bounds
                                imageView.layer.cornerRadius = cell.avatarContainerView.bounds.width/2
                                imageView.clipsToBounds = true
                                
                                cell.avatarImageView.addSubview(imageView)
                                
                            })
                    })
                }
            })
        }
        
        
        let isMedia = message.isMediaMessage()
        
        if !isMedia {
            
            if let id = message.senderId() {
                
                if id == senderId {
                    
                    cell.textView.textColor = UIColor.blackColor()
                    
                } else {
                    
                    cell.textView.textColor = UIColor.whiteColor()
                }
            }
        } else {
            
            if let key = messageData[indexPath.item]["key"] as? String {
                
                if let media = message.media!() as? JSQVideoMediaItem {
                    
/*
                    if let /*player = videoPlayers[key], view = player.view */{
                        
                     /*
                     
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.addChildViewController(player)
                            player.didMoveToParentViewController(self)
                            player.muted = true
                            player.playFromCurrentTime()
                            cell.mediaView.addSubview(view)
                            
                        })
                        */
                        
                    } else { */
                        
                        if let url = media.fileURL {
                            
                            
                            /*
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                let player = Player()
                                player.delegate = self
                                
                                if let videoPlayerView = player.view {
                                    
                                    self.addChildViewController(player)
                                    player.view.frame = cell.mediaView.bounds
                                    player.didMoveToParentViewController(self)
                                    player.setUrl(url)
                                    player.fillMode = AVLayerVideoGravityResizeAspectFill
                                    player.playbackLoops = true
                                    player.muted = true
                                    player.playFromCurrentTime()
                                    cell.mediaView.addSubview(videoPlayerView)
                                    self.videoPlayers[key] = player
                                }
                                
                            })
 
 */
                    
                        
                    }
                    
                } else if let _ = message.media!() as? JSQPhotoMediaItem, urlString = messageData[indexPath.item]["media"] as? String, url = NSURL(string: urlString) {
                    
                    SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .ContinueInBackground, progress: { (currentSize, expectedSize) in
                        
                        
                        
                        }, completed: { (image, error, cache, bool, url) in
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                let imageView = UIImageView(image: image)
                                imageView.contentMode = .ScaleAspectFill
                                
                                imageView.frame = cell.mediaView.bounds
                                imageView.clipsToBounds = true
                                cell.mediaView.addSubview(imageView)
                                
                            })
                    })
                    
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
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleRedColor())
        
    }
    
    //Observe Messages
    func newObserveMessages(){
        
        let ref = FIRDatabase.database().reference().child(passedRef)
        
        print(passedRef)
        
        self.messages.removeAll()
        self.messageData.removeAll()
        self.addedMessages.removeAll()
        
        self.finishReceivingMessage()
        
        ref.child("messages").queryLimitedToLast(50).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject : AnyObject] {
                
                print(value)
                
                if self.typeOfChat == "matches" || self.typeOfChat == "squad" {
                    
                    if let userUid = value["userUID"] as? String, senderUid = value["senderId"] as? String {
                        
                        if self.currentKey == userUid || self.currentKey == senderUid {
                            
                            if let id = value["senderId"] as? String, text = value["text"] as? String, name = value["senderDisplayName"] as? String, media = value["media"] as? String, isImage = value["isImage"] as? Bool, isMedia = value["isMedia"] as? Bool, key = value["key"] as? String, timeStamp = value["timeStamp"] as? NSTimeInterval {
                                
                                let date = NSDate(timeIntervalSince1970: timeStamp)
                                let sentMessage = self.addedMessages[key]
                                
                                if sentMessage == nil {
                                    
                                    self.addMessage(id, text: text, name: name, isMedia: isMedia, media: media, isImage: isImage, date: date, key: key, data: value)
                                    
                                    
                                }
                            }
                            
                        } else {
                            
                            ref.removeAllObservers()
                            
                        }
                    }
                } else if self.typeOfChat == "groupChats" {
                    
                    if let chatKey = value["chatKey"] as? String {
                        
                        if self.currentKey == chatKey {
                            
                            if let id = value["senderId"] as? String, text = value["text"] as? String, name = value["senderDisplayName"] as? String, media = value["media"] as? String, isImage = value["isImage"] as? Bool, isMedia = value["isMedia"] as? Bool, key = value["key"] as? String, timeStamp = value["timeStamp"] as? NSTimeInterval {
                                
                                let date = NSDate(timeIntervalSince1970: timeStamp)
                                let sentMessage = self.addedMessages[key]
                                
                                if sentMessage == nil {
                                    
                                    self.addMessage(id, text: text, name: name, isMedia: isMedia, media: media, isImage: isImage, date: date, key: key, data: value)
                                    
                                }
                            }
                            
                        } else {
                            
                            ref.removeAllObservers()
                            
                        }
                    }
                } else if self.typeOfChat == "posts" {
                    
                    if let postKey = value["postChildKey"] as? String {
                        
                        if self.currentKey == postKey {
                            
                            if let id = value["senderId"] as? String, text = value["text"] as? String, name = value["senderDisplayName"] as? String, media = value["media"] as? String, isImage = value["isImage"] as? Bool, isMedia = value["isMedia"] as? Bool, key = value["key"] as? String, timeStamp = value["timeStamp"] as? NSTimeInterval {
                                
                                let date = NSDate(timeIntervalSince1970: timeStamp)
                                let sentMessage = self.addedMessages[key]
                                
                                if sentMessage == nil {
                                    
                                    self.addMessage(id, text: text, name: name, isMedia: isMedia, media: media, isImage: isImage, date: date, key: key, data: value)
                                    
                                    
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    //Add Message
    func addMessage(id: String, text: String, name: String, isMedia: Bool, media: String, isImage: Bool, date: NSDate, key: String, data: [NSObject : AnyObject]) {
        
        print(text)
        
        if addedMessages[key] == false || addedMessages[key] == nil {
            
            addedMessages[key] = true
            
            if isMedia {
                
                if isImage {
                    
                    let photoItem = JSQPhotoMediaItem()
                    
                    if let selfID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if id == selfID {
                            
                            photoItem.appliesMediaViewMaskAsOutgoing = true
                            
                        } else {
                            
                            photoItem.appliesMediaViewMaskAsOutgoing = false
                            
                        }
                    }
                    
                    let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: photoItem)
                    
                    if let mediaView = message.media.mediaView() {
                        
                        mediaView.contentMode = .ScaleAspectFill
                        
                    }
                    
                    
                    self.messageData.append(data)
                    self.messages.append(message)
                    
                } else {
                    
                    //Download Video, then we need to figure out how to play???
                    if let url = NSURL(string: media) {
                        
                        let videoMedia = JSQVideoMediaItem(fileURL: url, isReadyToPlay: false)
                        
                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            if selfUID == id {
                                
                                videoMedia.appliesMediaViewMaskAsOutgoing = true
                                
                            } else {
                                
                                videoMedia.appliesMediaViewMaskAsOutgoing = false
                                
                            }
                        }
                        
                        print("content offset: \(self.collectionView.contentOffset.y)")
                        print("max content offset: \(self.maxContentOffset)")
                        print("scrolling up: \(self.scrollingUp)")
                        
                        let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: videoMedia)
                        
                        if let mediaView = message.media.mediaView() {
                            
                            mediaView.contentMode = .ScaleAspectFill
                            
                        }
                        
                        self.messageData.append(data)
                        self.messages.append(message)
                        
                    }
                }
                
            } else {
                
                print("content offset: \(self.collectionView.contentOffset.y)")
                print("max content offset: \(self.maxContentOffset)")
                print("scrolling up: \(self.scrollingUp)")
                
                let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text)
                
                self.messageData.append(data)
                self.messages.append(message)
                
            }
            
            if self.collectionView.contentOffset.y == 0 {
                
                self.finishReceivingMessage()
                
                
            } else if ((self.maxContentOffset - self.collectionView.contentOffset.y) <= 300) {
                
                self.finishReceivingMessage()
                
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
            if let mediaView = message.mediaView() {
                
                mediaView.contentMode = .ScaleAspectFill
                
            }
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        } else {
            
            fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
            let message = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        }
        
        let timeInterval = date.timeIntervalSince1970
        
        var messageItem: [NSObject : AnyObject] = ["key" : fileName, "senderId" : senderId, "timeStamp" : timeInterval, "senderDisplayName" : senderDisplayName, "isImage" : isImage, "isMedia" : true]
        
        if typeOfChat == "matches" {
            
            messageItem["userUID"] = currentKey
            
        } else if typeOfChat == "posts" {
            
            messageItem["postChildKey"] = currentKey
            
        } else if typeOfChat == "groupChats" {
            
            messageItem["chatKey"] = currentKey
            
        }
        
        
        self.messageData.append(messageItem)
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
    
    /*
     func observeTyping(){
     
     let refString = passedRef
     
     let ref = FIRDatabase.database().reference().child(refString).child("isTyping")
     
     if let selfUID = FIRAuth.auth()?.currentUser?.uid {
     
     ref.observeEventType(.Value, withBlock:  { (snapshot) in
     
     if let typing = snapshot.value as? [String : Bool] {
     
     let postUIDREF = FIRDatabase.database().reference().child(refString).child("postChildKey")
     
     postUIDREF.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
     
     var isTyping = false
     
     if let postKey = snapshot.value as? String {
     
     if postKey == self.currentPostKey {
     
     for (key, value) in typing {
     
     if key != selfUID {
     
     if value == true {
     
     isTyping = true
     
     }
     }
     }
     
     self.showTypingIndicator = isTyping
     
     } else {
     
     ref.removeAllObservers()
     
     }
     }
     })
     }
     })
     }
     }
     */
    //Add Upload Stuff
    func addUploadStuff(){
        
        let error = NSErrorPointer.init(nilLiteral: ())
        
        do{
            
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
            
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    func dismissKeyboard(){
        
        self.view.endEditing(true)
        
    }
    
    
    //ScrollView Stuff
    var originalHeight: CGFloat?
    
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        print(velocity.y)
        
        if velocity.y > 1 && messages.count > 5 {
            
            if let const = rootController?.topChatHeightConstOutlet.constant {
                
                if const != 0 {
                    
                    originalHeight = const
                    
                }
            }
            
            UIApplication.sharedApplication().statusBarHidden = true
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.rootController?.topChatContainerOutlet.alpha = 0
                self.rootController?.topChatHeightConstOutlet.constant = 0
                self.rootController?.view.layoutIfNeeded()
                
            })
            
        } else if velocity.y < -1 {
            
            if let scopeHeight = originalHeight {
                
                UIApplication.sharedApplication().statusBarHidden = false
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.rootController?.topChatContainerOutlet.alpha = 1
                    self.rootController?.topChatHeightConstOutlet.constant = scopeHeight
                    self.rootController?.view.layoutIfNeeded()
                    
                })
            }
        }
        
        if velocity.y > 0 && (maxContentOffset - scrollView.contentOffset.y) <= 300 {
            
            self.finishReceivingMessage()
            
        }
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > maxContentOffset {
            
            maxContentOffset = scrollView.contentOffset.y
            
        }
        
        if scrollView.contentOffset.y > contentOffset {
            
            scrollingUp = true
            
        } else if scrollView.contentOffset.y < contentOffset {
            
            scrollingUp = false
            
        }
        
        print("scrolling up: \(scrollingUp)")
        
    }
    
    
    func addGestureRecognizers(){
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        self.collectionView.addGestureRecognizer(tapGesture)
        
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