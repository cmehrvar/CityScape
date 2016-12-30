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
import AWSS3
import AWSCore
import AWSCognito

class CommentController: JSQMessagesViewController, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootController?
    
    var maxContentOffset = CGFloat()

    var passedRef = ""
    var typeOfChat = ""
    var currentKey = ""
    
    var videoAssets = [String : AVAsset]()
    var videoPlayers = [AVPlayer?]()
    var videoPlayersObserved = [Bool]()
    var videoLayers = [AVPlayerLayer?]()
    var videoKeys = [String?]()
    var videoPlayerIndexes = [String : Int]()
    
    var messages = [JSQMessageData]()
    var messageData = [[AnyHashable: Any]]()
    var addedMessages = [String : Bool]()
    
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    
    var exportedVideoURL: NSURL?
    
    var keyboardShown = false
    var chatEnlarged = false
    
    var contentOffset: CGFloat = 0
    var scrollingUp = true
    
    
    
    func clearPlayers(){
        
        for i in 0..<20 {
            
            videoKeys[i] = nil
            
            if videoPlayersObserved[i] {
                
                videoPlayers[i]?.removeObserver(self, forKeyPath: "rate")
                
            }
            
            videoPlayersObserved[i] = false
            
            if let player = videoPlayers[i] {
                
                player.pause()
                
                if videoPlayersObserved[i] {
                    
                    player.removeObserver(self, forKeyPath: "rate")
                    
                }
            }
            
            if let layer = videoLayers[i] {
                
                layer.removeFromSuperlayer()
                
            }
            
            videoPlayers[i] = nil
            videoLayers[i] = nil
            videoAssets.removeAll()
            
            
        }
    }
    
    
    var postUid = ""
    
    //Did press send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        print("send pressed")
        
        let ref = FIRDatabase.database().reference()
        
        var notificationItem = [AnyHashable: Any]()
        notificationItem["text"] = text
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".txt"
        let timeStamp = date.timeIntervalSince1970
        
        var messageItem: [AnyHashable: Any] = [
            
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
            
            notificationItem["type"] = "postComment"
            notificationItem["postChildKey"] = currentKey
            
            if let city = rootController?.topChatController?.postCity {
                
                notificationItem["city"] = city
                
            }
            
            if let postUrl = rootController?.topChatController?.postURL {
                
                notificationItem["image"] = postUrl
                
            }
            
            if let userUid = rootController?.topChatController?.uid {
                
                self.postUid = userUid
                
            }

            messageItem["postChildKey"] = currentKey
            
            
        }
        
        if let firstName = self.rootController?.selfData["firstName"] as? String, let lastName = self.rootController?.selfData["lastName"] as? String {
            
            if typeOfChat != "groupChats" {
                
                notificationItem["firstName"] = firstName
                notificationItem["lastName"] = lastName
                
            }
            
            messageItem["firstName"] = firstName
            messageItem["lastName"] = lastName
            
        }
        
        
        notificationItem["read"] = false
        notificationItem["timeStamp"] = timeStamp
        
        if typeOfChat != "posts" {
            
            notificationItem["type"] = typeOfChat
            
        }
        
        
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self.messages.append(message!)
        self.messageData.append(messageItem)
        self.addedMessages[fileName] = true
        
        if typeOfChat == "matches" || typeOfChat == "squad" {
            
            let scopeUID = currentKey
            
            ref.child("users").child(currentKey).child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let myName = self.senderDisplayName, let messageText = text {

                    appDelegate.pushMessage(uid: scopeUID, token: token, message: "\(myName): \(messageText)")
                    
                }
            })

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
                            
                            ref.child("users").child(member).child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let myName = self.senderDisplayName, let groupChatName = self.rootController?.topChatController?.chatTitleOutlet.text, let messageText = text {
                                    
                                    appDelegate.pushMessage(uid: member, token: token, message: "\(myName) to \(groupChatName): \(messageText)")
                                    
                                }
                            })

                            FIRDatabase.database().reference().child("users").child(member).child("notifications").child("groupChats").child(currentKey).setValue(notificationItem)
                            
                        }
                    }
                }
            }
        } else if typeOfChat == "posts" {
            
            ref.child(passedRef).child("messages").childByAutoId().setValue(messageItem)
            
            if let myUid = FIRAuth.auth()?.currentUser?.uid {
                
                if myUid != self.postUid {
                    
                    notificationItem["senderUid"] = myUid
                    
                    ref.child("users").child(postUid).child("notifications").child(myUid).child("postComment").setValue(notificationItem)
                    
                }
            }
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        endedTyping()
        finishSendingMessage()
        
    }
    
    //Did press accessory button
    override func didPressAccessoryButton(_ sender: UIButton!) {

        self.rootController?.toggleCamera(type: typeOfChat, chatType: "chat", completion: { (bool) in
            
            print("camera presented")
            
        })
    }
    
    /*
    //Fusuma Delegates
    func fusumaImageSelected(_ image: UIImage) {
        
        print("image selected")
        
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        UIApplication.shared.isStatusBarHidden = false
        
        let scopeCurrentKey = currentKey
        let scopePassedRef = self.passedRef
        let scopeType = typeOfChat
        
        //Call Upload Function
        uploadMedia(true, image: image, videoURL: nil) { (date, fileName, messageData) in
            
            let request = self.uploadRequest(image)
            
            let transferManager = AWSS3TransferManager.default()
            
            transferManager?.upload(request).continue({ (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    if let key = request.key {
                        
                        let ref = FIRDatabase.database().reference()
                        
                        var notificationItem = [AnyHashable: Any]()
                        notificationItem["text"] = "Sent Photo!"

                        let timeStamp = date.timeIntervalSince1970
                        
                        var messageItem: [AnyHashable: Any] = [
                            
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
                            
                            messageItem["postChildKey"] = self.currentKey
                            
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
                                
                                if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let myName = self.senderDisplayName {
                                    
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
                                                
                                                if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let myName = self.senderDisplayName, let groupChatName = self.rootController?.topChatController?.chatTitleOutlet.text {
                                                    
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
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        UIApplication.shared.isStatusBarHidden = false
        
        let scopePassedRef = self.passedRef
        let scopeCurrentKey = currentKey
        let scopeType = typeOfChat
        
        uploadMedia(false, image: nil, videoURL: fileURL) { (date, fileName, messageData) in
            
            self.convertVideoToLowQualityWithInputURL(fileURL, handler: { (exportSession, outputURL) in
                
                if exportSession.status == .completed {
                    
                    let request = AWSS3TransferManagerUploadRequest()
                    request?.body = outputURL
                    request?.key = fileName
                    request?.bucket = "cityscapebucket"
                    
                    let transferManager = AWSS3TransferManager.default()

                    transferManager?.upload(request).continue({ (task) -> AnyObject? in
                        
                        if task.error == nil {
                            
                            if let key = request?.key {
                                
                                let ref = FIRDatabase.database().reference()
                                
                                var notificationItem = [AnyHashable: Any]()
                                notificationItem["text"] = "Sent Video!"

                                let timeStamp = date.timeIntervalSince1970
                                
                                var messageItem: [AnyHashable: Any] = [
                                    
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
                                    
                                    notificationItem["type"] = "postComment"
                                    notificationItem["postChildKey"] = self.currentKey
                                    
                                    
                                    if let city = self.rootController?.topChatController?.postCity {
                                        
                                        notificationItem["city"] = city
                                        
                                    }
                                    
                                    
                                    if let postUrl = self.rootController?.topChatController?.postURL {
                                        
                                        notificationItem["image"] = postUrl
                                        
                                    }
                                    
                                    if let userUid = self.rootController?.topChatController?.uid {
                                        
                                        self.postUid = userUid
                                        
                                    }
                                    
                                    messageItem["postChildKey"] = self.currentKey
                                    
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
                                        
                                        if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let myName = self.senderDisplayName {
                                            
                                            appDelegate.pushMessage(uid: scopeCurrentKey, token: token, message: "\(self.senderDisplayName): Sent a video!")
                                            
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
                                                            
                                                            appDelegate.pushMessage(uid: member, token: token, message: "\(self.senderDisplayName) to \(self.rootController?.topChatController?.chatTitleOutlet.text): Sent a video!")
                                                            
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
    
    /*
    func presentFusumaCamera(){
        
        UIApplication.shared.isStatusBarHidden = true
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        self.present(fusuma, animated: true, completion: {
            
            print("camera presented")
            
        })
    }
    
    func fusumaCameraRollUnauthorized() {
        
        let alertController = UIAlertController(title: "Sorry", message: "Camera not authorized", preferredStyle:  UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        print("camera unauthorized")
        
    }
    
 */
 */
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
    override func textViewDidChange(_ textView: UITextView) {
        
        super.textViewDidChange(textView)
        
        if textView.text != "" {
            
            beganTyping()
            
        } else {
            
            endedTyping()
            
        }
    }
    
    //Message Data
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }
    
    //Items in section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    //Message bubble Image
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
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
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(), diameter: 48)
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let mediaCell = cell as? JSQMessagesCollectionViewCell {
            
            let message = messages[(indexPath as NSIndexPath).item]
            
            if message.isMediaMessage() {
                
                if message.media!() is JSQVideoMediaItem {
                    
                    if let key = messageData[(indexPath as NSIndexPath).item]["key"] as? String, let playerIndex = videoPlayerIndexes[key]  {
                        
                        if let player = videoPlayers[playerIndex] {

                            if !videoPlayersObserved[playerIndex] {
                                
                                player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                                videoPlayersObserved[playerIndex] = true
                                
                            }

                            DispatchQueue.main.async(execute: {
                                
                                self.videoLayers[playerIndex] = AVPlayerLayer(player: player)
                                self.videoLayers[playerIndex]?.videoGravity = AVLayerVideoGravityResizeAspectFill
                                self.videoLayers[playerIndex]?.frame = mediaCell.mediaView.bounds
                                
                                if let layer = self.videoLayers[playerIndex] {
                                    
                                    mediaCell.mediaView.layer.addSublayer(layer)
                                    
                                }
                                
                                player.isMuted = true
                                player.play()
                                
                            })
 
                        } else {
                            
                            var asset: AVAsset?
                            
                            if let loadedAsset = videoAssets[key] {
                                
                                asset = loadedAsset
                                
                            } else if let media = message.media!() as? JSQVideoMediaItem, let url = media.fileURL {
                                
                                asset = AVAsset(url: url)
                                
                            }
                            
                            if let actualAsset = asset {
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    let playerItem = AVPlayerItem(asset: actualAsset)
                                    self.videoKeys[playerIndex] = key
                                    self.videoPlayers[playerIndex] = AVPlayer(playerItem: playerItem)
                                    self.videoPlayers[playerIndex]?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                                    self.videoPlayersObserved[playerIndex] = true
                                    
                                    self.videoLayers[playerIndex] = AVPlayerLayer(player: self.videoPlayers[playerIndex])
                                    self.videoLayers[playerIndex]?.videoGravity = AVLayerVideoGravityResizeAspectFill
                                    self.videoLayers[playerIndex]?.frame = mediaCell.mediaView.bounds
                                    
                                    if let layer = self.videoLayers[playerIndex] {
                                        
                                        mediaCell.mediaView.layer.addSublayer(layer)
                                        
                                    }
                                    
                                    self.videoPlayers[playerIndex]?.isMuted = true
                                    self.videoPlayers[playerIndex]?.play()
                                
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if !messages.isEmpty && !messageData.isEmpty {
            
            if let mediaCell = cell as? JSQMessagesCollectionViewCell {
                
                let message = messages[(indexPath as NSIndexPath).item]
                
                if message.media!() is JSQVideoMediaItem {
                    
                    if let key = messageData[(indexPath as NSIndexPath).item]["key"] as? String {
                        
                        if let playerNumber = videoPlayerIndexes[key] {
                            
                            if let player = videoPlayers[playerNumber] {
                                
                                if videoPlayersObserved[playerNumber] {
                                    
                                    player.removeObserver(self, forKeyPath: "rate")
                                    videoPlayersObserved[playerNumber] = false
                                    
                                }
                            }
                            
                            
                            videoLayers[playerNumber]?.removeFromSuperlayer()
                            videoLayers[playerNumber] = nil
                            videoKeys[playerNumber] = nil
                            videoPlayerIndexes.removeValue(forKey: key)
                            videoPlayers[playerNumber]?.pause()
                            videoPlayers[playerNumber] = nil
                            
                            if let subLayers = mediaCell.mediaView.layer.sublayers {
                                
                                for layer in subLayers {
                                    
                                    if layer is AVPlayerLayer {
                                        
                                        layer.removeFromSuperlayer()
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    func setPlayerTitle(_ postKey: String) {
        
        var playerForCell = 0
        
        for i in 0..<20 {
            
            if videoKeys[i] == nil {
                
                playerForCell = i
                
            }
        }
        
        for i in 0..<20 {
            
            if videoKeys[i] == postKey {
                
                playerForCell = i
                
            }
        }
        
        videoKeys[playerForCell] = postKey
        videoPlayerIndexes[postKey] = playerForCell
        
    }
    
    
    
    //Cell for item at index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell

        let message = messages[(indexPath as NSIndexPath).item]
        
        cell.cellBottomLabel.textColor = UIColor.black
        
        if let id = message.senderId() {
            
            let ref = FIRDatabase.database().reference().child("users").child(id)
            
            ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                    
                    SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: { (currentSize, expectedSize) in
                        
                        
                        
                        }, completed: { (image, error, cache, bool, url) in
                            
                            DispatchQueue.main.async(execute: {
                                
                                
                                let imageView = UIImageView(image: image)
                                imageView.contentMode = .scaleAspectFill
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
                    
                    cell.textView.textColor = UIColor.black
                    
                } else {
                    
                    cell.textView.textColor = UIColor.white
                }
            }
        } else {
            
            if message.media!() is JSQVideoMediaItem {
                
                if let key = messageData[(indexPath as NSIndexPath).item]["key"] as? String {

                    setPlayerTitle(key)

                }
                
            } else if let _ = message.media!() as? JSQPhotoMediaItem, let urlString = messageData[(indexPath as NSIndexPath).item]["media"] as? String, let url = URL(string: urlString) {
                    
                    SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: { (currentSize, expectedSize) in
                        
                        
                        
                        }, completed: { (image, error, cache, bool, url) in
                            
                            DispatchQueue.main.async(execute: {
                                
                                let imageView = UIImageView(image: image)
                                imageView.contentMode = .scaleAspectFill
                                
                                imageView.frame = cell.mediaView.bounds
                                imageView.clipsToBounds = true
                                cell.mediaView.addSubview(imageView)
                                
                            })
                    })

            }
        }
        
        return cell
        
    }
    
    
    
    
    
    
    //Top Cell Label Text
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = messages[indexPath.item]
        
        if let date = message.date() {
            
            if indexPath.item == 0 {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                dateFormatter.timeStyle = DateFormatter.Style.short
                let dateObj = dateFormatter.string(from: date)
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
                        
                        let dateFormatter = DateFormatter()
                        
                        let daysAgo = date.daysFrom(previousDate)
                        
                        if daysAgo > 0 {
                            
                            dateFormatter.dateStyle = DateFormatter.Style.medium
                            dateFormatter.timeStyle = DateFormatter.Style.short
                            
                        } else {
                            
                            dateFormatter.dateStyle = DateFormatter.Style.none
                            dateFormatter.timeStyle = DateFormatter.Style.short
                            
                        }
                        
                        let dateObj = dateFormatter.string(from: date)
                        return NSAttributedString(string: dateObj)
                        
                    }
                }
            }
        }
        
        return nil
    }
    
    //Height for Cell Top Label Text
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
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
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
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
    fileprivate func setUpBubbles() {
        
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
        
    }
    
    //Observe Messages
    func newObserveMessages(){
        
        let ref = FIRDatabase.database().reference().child(passedRef)
        
        print(passedRef)
        
        self.messages.removeAll()
        self.messageData.removeAll()
        self.addedMessages.removeAll()
        
        self.finishReceivingMessage()
        
        ref.child("messages").queryLimited(toLast: 50).observe(.childAdded, with: { (snapshot) in
            
            if let value = snapshot.value as? [AnyHashable: Any] {
                
                print(value)
                
                if self.typeOfChat == "matches" || self.typeOfChat == "squad" {
                    
                    if let userUid = value["userUID"] as? String, let senderUid = value["senderId"] as? String {
                        
                        if self.currentKey == userUid || self.currentKey == senderUid {
                            
                            if let id = value["senderId"] as? String, let text = value["text"] as? String, let name = value["senderDisplayName"] as? String, let media = value["media"] as? String, let isImage = value["isImage"] as? Bool, let isMedia = value["isMedia"] as? Bool, let key = value["key"] as? String, let timeStamp = value["timeStamp"] as? TimeInterval {
                                
                                let date = Date(timeIntervalSince1970: timeStamp)
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
                            
                            if let id = value["senderId"] as? String, let text = value["text"] as? String, let name = value["senderDisplayName"] as? String, let media = value["media"] as? String, let isImage = value["isImage"] as? Bool, let isMedia = value["isMedia"] as? Bool, let key = value["key"] as? String, let timeStamp = value["timeStamp"] as? TimeInterval {
                                
                                let date = Date(timeIntervalSince1970: timeStamp)
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
                            
                            if let id = value["senderId"] as? String, let text = value["text"] as? String, let name = value["senderDisplayName"] as? String, let media = value["media"] as? String, let isImage = value["isImage"] as? Bool, let isMedia = value["isMedia"] as? Bool, let key = value["key"] as? String, let timeStamp = value["timeStamp"] as? TimeInterval {
                                
                                let date = Date(timeIntervalSince1970: timeStamp)
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
    func addMessage(_ id: String, text: String, name: String, isMedia: Bool, media: String, isImage: Bool, date: Date, key: String, data: [AnyHashable: Any]) {
        
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
                    
                    if let mediaView = message?.media.mediaView() {
                        
                        mediaView.contentMode = .scaleAspectFill
                        
                    }
                    
                    
                    self.messageData.append(data)
                    self.messages.append(message!)
                    
                } else {
                    
                    //Download Video, then we need to figure out how to play???
                    if let url = URL(string: media) {
                        
                        let videoMedia = JSQVideoMediaItem(fileURL: url, isReadyToPlay: false)
                        
                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            if selfUID == id {
                                
                                videoMedia?.appliesMediaViewMaskAsOutgoing = true
                                
                            } else {
                                
                                videoMedia?.appliesMediaViewMaskAsOutgoing = false
                                
                            }
                        }
                        
                        print("content offset: \(self.collectionView.contentOffset.y)")
                        print("max content offset: \(self.maxContentOffset)")
                        print("scrolling up: \(self.scrollingUp)")
                        
                        let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: videoMedia)
                        
                        if let mediaView = message?.media.mediaView() {
                            
                            mediaView.contentMode = .scaleAspectFill
                            
                        }
                        
                        self.messageData.append(data)
                        self.messages.append(message!)
                        
                    }
                }
                
            } else {
                
                print("content offset: \(self.collectionView.contentOffset.y)")
                print("max content offset: \(self.maxContentOffset)")
                print("scrolling up: \(self.scrollingUp)")
                
                let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text)
                
                self.messageData.append(data)
                self.messages.append(message!)
                
            }
            
            if self.collectionView.contentOffset.y == 0 {
                
                self.finishReceivingMessage()
                
                
            } else if ((self.maxContentOffset - self.collectionView.contentOffset.y) <= 300) {
                
                self.finishReceivingMessage()
                
            }
        }
    }
    
    //Upload Media
    func uploadMedia(_ isImage: Bool, image: UIImage?, videoURL: URL?, handler: (_ date: Date, _ fileName: String, _ messageData: JSQMessageData) -> Void){
        
        let date = Date()
        var fileName = ""
        var messageData: JSQMessage!
        
        if isImage {
            
            fileName = ProcessInfo.processInfo.globallyUniqueString + ".jpeg"
            let message = JSQPhotoMediaItem(image: image)
            if let mediaView = message?.mediaView() {
                
                mediaView.contentMode = .scaleAspectFill
                
            }
            
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        } else {
            
            fileName = ProcessInfo.processInfo.globallyUniqueString + ".mov"
            let message = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        }
        
        let timeInterval = date.timeIntervalSince1970
        
        var messageItem: [AnyHashable: Any] = ["key" : fileName, "senderId" : senderId, "timeStamp" : timeInterval, "senderDisplayName" : senderDisplayName, "isImage" : isImage, "isMedia" : true]
        
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
        
        handler(date, fileName, messageData)
        
    }
    
    
    //Upload Request
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
            
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
            
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    func dismissKeyboard(){
        
        self.view.endEditing(true)
        
    }
    
    
    //ScrollView Stuff
    var originalHeight: CGFloat?
    
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        print(velocity.y)
        
        if velocity.y > 1 && messages.count > 5 {
            
            if let const = rootController?.topChatHeightConstOutlet.constant {
                
                if const != 0 {
                    
                    originalHeight = const
                    
                }
            }
            
            UIApplication.shared.isStatusBarHidden = true
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.rootController?.topChatContainerOutlet.alpha = 0
                self.rootController?.topChatHeightConstOutlet.constant = 0
                self.rootController?.view.layoutIfNeeded()
                
            })
            
        } else if velocity.y < -1 {
            
            if let scopeHeight = originalHeight {
                
                UIApplication.shared.isStatusBarHidden = false
                
                UIView.animate(withDuration: 0.3, animations: {
                    
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
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
        
        self.senderId = "none"
        self.senderDisplayName = "none"
        
        super.viewDidLoad()
        
        self.collectionView.collectionViewLayout.springinessEnabled = false
        self.keyboardController.textView.autocorrectionType = .no
        
        addGestureRecognizers()
        
        addUploadStuff()
        setUpBubbles()
        
        for _ in 0..<20 {
            
            videoPlayersObserved.append(false)
            videoLayers.append(nil)
            videoPlayers.append(nil)
            videoKeys.append(nil)
            
        }

        
        // Do any additional setup after loading the view.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
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
