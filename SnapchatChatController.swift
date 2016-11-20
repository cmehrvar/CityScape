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
import AWSS3
import AWSCore
import AWSCognito
//import Player

class SnapchatChatController: JSQMessagesViewController, UIGestureRecognizerDelegate {
    
    weak var snapchatController: SnapchatViewController?
    
    var maxContentOffset = CGFloat()
    
    //JSQData
    //var videoPlayers = [String : Player]()
    var passedRef = ""
    var typeOfChat = "snapchat"
    var currentPostKey = ""
    
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
    
    
    
    
    
    //Did press send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        print("send pressed")
        
        let ref = FIRDatabase.database().reference()
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".txt"
        let timeStamp = date.timeIntervalSince1970
        
        print(senderId)
        print(senderDisplayName)
        
        var messageItem: [AnyHashable: Any] = [
            
            "key" : fileName,
            "text" : text,
            "senderId" : senderId,
            "timeStamp" : timeStamp,
            "senderDisplayName" : senderDisplayName,
            "isMedia" : false,
            "isImage" : false,
            "media" : "none",
            "postChildKey" : currentPostKey
            
        ]
        
        if let firstName = self.snapchatController?.rootController?.selfData["firstName"] as? String, let lastName = self.snapchatController?.rootController?.selfData["lastName"] as? String {
            
            messageItem["firstName"] = firstName
            messageItem["lastName"] = lastName
            
        }
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        self.messages.append(message!)
        self.messageData.append(messageItem)
        self.addedMessages[fileName] = true
        
        ref.child(passedRef).child("messages").childByAutoId().setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        endedTyping()
        finishSendingMessage()
        
        self.finishReceivingMessage()
        
        
    }
    
    
    
    
    
    //Did press accessory button
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        //presentFusumaCamera()
        
        
    }
    
    
    //Fusuma Delegates
    func fusumaImageSelected(_ image: UIImage) {
        
        print("image selected")
        
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        let postKey = currentPostKey
        let scopePassedRef = self.passedRef
        
        //Call Upload Function
        uploadMedia(true, image: image, videoURL: nil) { (date, fileName, messageData) in
            
            let request = self.uploadRequest(image)
            
            let transferManager = AWSS3TransferManager.default()
            
            transferManager?.upload(request).continue({ (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    print("succesful upload!")
                    
                    let ref = FIRDatabase.database().reference()
                    
                    if let key = request.key {
                        
                        let timeStamp = Date().timeIntervalSince1970
                        
                        let messageItem = [
                            
                            "key" : fileName,
                            "text" : "sent a photo!",
                            "senderId": self.senderId,
                            "timeStamp" : timeStamp,
                            "senderDisplayName" : self.senderDisplayName,
                            "isMedia" : true,
                            "isImage" : true,
                            "media" : "https://s3.amazonaws.com/cityscapebucket/" + key,
                            "postChildKey" : postKey
                            
                        ] as [String : Any]
                        
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
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        let scopePassedRef = self.passedRef
        let postKey = currentPostKey
        
        uploadMedia(false, image: nil, videoURL: fileURL) { (date, fileName, messageData) in
            
            self.convertVideoToLowQualityWithInputURL(fileURL, handler: { (exportSession, outputURL) in
                
                if exportSession.status == .completed {
                    
                    //Call Upload Function
                    let request = AWSS3TransferManagerUploadRequest()
                    request?.body = outputURL
                    request?.key = fileName
                    request?.bucket = "cityscapebucket"
                    
                    let transferManager = AWSS3TransferManager.default()
                    
                    transferManager?.upload(request).continue({ (task) -> AnyObject? in
                        
                        let ref = FIRDatabase.database().reference()
                        
                        if let key = request?.key {
                            
                            let timeStamp = Date().timeIntervalSince1970
                            
                            let messageItem = [
                                "key" : fileName,
                                "text" : "sent a video!",
                                "senderId": self.senderId,
                                "timeStamp" : timeStamp,
                                "senderDisplayName" : self.senderDisplayName,
                                "isMedia" : true,
                                "isImage" : false,
                                "media" : "https://s3.amazonaws.com/cityscapebucket/" + key,
                                "postChildKey" : postKey
                                
                            ] as [String : Any]
                            
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
    
    /*
    func presentFusumaCamera(){
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        self.snapchatController?.present(fusuma, animated: true, completion: {
            
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
                                imageView.frame = cell.avatarContainerView.bounds
                                imageView.contentMode = .scaleAspectFill
                                
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
                
            } else if message.media!() is JSQPhotoMediaItem {
                
                if let imageString = messageData[(indexPath as NSIndexPath).item]["media"] as? String, let imageURL = URL(string: imageString) {
                    
                    SDWebImageManager.shared().downloadImage(with: imageURL, options: .continueInBackground, progress: { (currentSize, expectedSize) in
                        
                        }, completed: { (image, error, cache, bool, url) in
                            
                            DispatchQueue.main.async(execute: {
                                
                                let imageView = UIImageView(image: image)
                                imageView.frame = cell.mediaView.bounds
                                imageView.contentMode = .scaleAspectFill
                                imageView.clipsToBounds = true
                                cell.mediaView.addSubview(imageView)
                                
                            })
                            
                    })
                }
            }
            
        }
        
        return cell
        
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
        
        self.messages.removeAll()
        self.messageData.removeAll()
        self.addedMessages.removeAll()
        
        self.finishReceivingMessage()
        
        ref.child("messages").queryLimited(toLast: 50).observe(.childAdded, with: { (snapshot) in
            
            if let value = snapshot.value as? [AnyHashable: Any] {
                
                if let postKey = value["postChildKey"] as? String {
                    
                    if self.currentPostKey == postKey {
                        
                        if let id = value["senderId"] as? String, let text = value["text"] as? String, let name = value["senderDisplayName"] as? String, let media = value["media"] as? String, let isImage = value["isImage"] as? Bool, let isMedia = value["isMedia"] as? Bool, let key = value["key"] as? String, let timeStamp = value["timeStamp"] as? TimeInterval {
                            
                            let date = Date(timeIntervalSince1970: timeStamp)
                            let sentMessage = self.addedMessages[key]
                            
                            if sentMessage == nil {
                                
                                self.addMessage(id, text: text, name: name, isMedia: isMedia, media: media, isImage: isImage, date: date, key: key, data: value)
                                
                                if isImage {
                                    
                                    if let url = URL(string: media) {
                                        
                                        SDWebImageManager.shared().downloadImage(with: url, options: .continueInBackground, progress: { (currentSize, expectedSize) in
                                            
                                            
                                            
                                            }, completed: { (image, error, cache, bool, url) in
                                                
                                                self.collectionView.reloadData()
                                                
                                        })
                                    }
                                }
                            }
                        }
                        
                    } else {
                        
                        ref.removeAllObservers()
                        
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
                    
                    let nilPhotoItem = JSQPhotoMediaItem(image: nil)
                    
                    if let selfID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if id == selfID {
                            
                            nilPhotoItem?.appliesMediaViewMaskAsOutgoing = true
                            
                        } else {
                            
                            nilPhotoItem?.appliesMediaViewMaskAsOutgoing = false
                            
                        }
                        
                    }
                    
                    let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, media: nilPhotoItem)
                    
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
            message?.mediaView().contentMode = UIViewContentMode.scaleAspectFill
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        } else {
            
            fileName = ProcessInfo.processInfo.globallyUniqueString + ".mov"
            let message = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
            messageData = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, media: message)
            
        }
        
        let timeInterval = date.timeIntervalSince1970
        
        let messageItem: [AnyHashable: Any] = ["key" : fileName, "senderId" : senderId, "timeStamp" : timeInterval, "senderDisplayName" : senderDisplayName, "isImage" : isImage, "isMedia" : true, "postChildKey" : currentPostKey]
        
        
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
        
        if keyboardShown {
            self.view.endEditing(true)
        }
    }
    
    
    func hideKeyboard(_ notification: Notification){
        
        print("hide keyboard")
        
        if let rootWidth = self.snapchatController?.rootController?.view.bounds.width {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.snapchatController?.contentHeightConstOutlet.constant = rootWidth
                
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.keyboardShown = false
            })
            
        }
        
    }
    
    
    func showKeyboard(_ notification: Notification){
        
        print("show keyboard")
        
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let rootWidth = self.snapchatController?.rootController?.view.bounds.width {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.snapchatController?.contentHeightConstOutlet.constant = rootWidth - keyboardSize.height
                
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.keyboardShown = true
            })
            
        }
        
    }
    
    
    func shrinkChat(){
        
        if chatEnlarged {
            
            self.chatEnlarged = false
            
            print("shrink chat")
            
            guard let rootWidth = self.snapchatController?.rootController?.view.bounds.width else {return}
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.snapchatController?.contentHeightConstOutlet.constant = rootWidth
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.snapchatController?.isPanning = false
                    self.snapchatController?.longPressEnabled = false
                    
                    if let playerLayer = self.snapchatController?.layer {
                        
                        if let bounds = self.snapchatController?.videoOutlet.bounds {
                            
                            playerLayer.frame = bounds
                            
                        }
                    }
                    
            })
        }
    }
    
    
    func enlargeChat(){
        
        if !chatEnlarged {
            
            self.chatEnlarged = true
            
            print("enlarge chat")
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.snapchatController?.contentHeightConstOutlet.constant = 150
                self.snapchatController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    if let playerLayer = self.snapchatController?.layer {
                        
                        if let bounds = self.snapchatController?.videoOutlet.bounds {
                            
                            playerLayer.frame = bounds
                            
                        }
                    }
                    
            })
        }
    }
    
    
    
    
    //ScrollView Stuff
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        print(velocity.y)
        
        
        if velocity.y > 0 && (maxContentOffset - scrollView.contentOffset.y) <= 300 {
            
            self.finishReceivingMessage()
            
        }
        
        
        
        if velocity.y < -1.5 {
            
            shrinkChat()
            
        } else if velocity.y > 1 {
            
            enlargeChat()
            
        } else {
            
            print("not long enough gesture")
            
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
