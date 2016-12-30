//
//  ProfileController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import AWSS3
import AVFoundation
import SDWebImage
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class ProfileController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    //Variables
    weak var rootController: MainRootController?
    var userData = [AnyHashable: Any]()
    var userPosts = [[AnyHashable: Any]]()
    
    var globFirstMessages = [[AnyHashable : Any]]()
    var globSecondMessages = [[AnyHashable : Any]]()
    var globThirdMessages = [[AnyHashable : Any]]()
    
    var videoAssets = [String : AVAsset]()
    var videoPlayers = [AVPlayer?]()
    var videoPlayersObserved = [Bool]()
    var videoLayers = [AVPlayerLayer?]()
    var videoKeys = [String?]()
    
    var gridView = true
    
    var selfProfile = false
    
    var editedImage = ""
    
    var currentPicture = 1
    
    var tempImage1: UIImage?
    var tempImage2: UIImage?
    var tempImage3: UIImage?
    var tempImage4: UIImage?
    var tempImage5: UIImage?
    
    var currentUID = ""
    var profile1 = ""
    
    var videoWithSound = ""
    
    //Outlets
    @IBOutlet weak var globCollectionCell: UICollectionView!
    
    
    //Actions
    @IBAction func close(_ sender: AnyObject) {

        rootController?.toggleHome({ (bool) in
            
            self.rootController?.clearProfilePlayers()
            
            print("home toggled")
            
        })
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
    
    
    
    //Image Uploads
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
    
    /*
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("fusuma dismissed with image")
        
        let scopeEditedImage = editedImage
        
        self.imageUploadRequest(image) { (url, uploadRequest) in
            
            let transferManager = AWSS3TransferManager.default()
            
            transferManager?.upload(uploadRequest).continue({ (task) -> Any? in
                
                if task.error == nil {
                    
                    print("successful image upload")
                    let ref = FIRDatabase.database().reference()
                    
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        
                        ref.child("users").child(uid).updateChildValues([scopeEditedImage: url])
                    }
                    
                } else {
                    print("error uploading: \(task.error)")
                    
                    let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                return nil
                
            })
        }
    }
    
    func fusumaImageSelected(_ image: UIImage) {
        
        print("image selected")
        
    }
    
    
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
        let alertController = UIAlertController(title: "Sorry", message: "Camera not authorized", preferredStyle:  UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        print("camera unauthorized")
        
    }
    
    func fusumaClosed() {
        
        rootController?.cameraTransitionOutlet.alpha = 0
        
    }
    
    
    func presentFusuma(_ editedImage: String){
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false
        
        self.editedImage = editedImage
        
        self.present(fusuma, animated: true) {
            
            print("fusumaPresented")
            
        }
    }
    */
    func addUploadStuff(){
        
        let error = NSErrorPointer.init(nilLiteral: ())
        
        do{
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error?.pointee = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    //Functions
    func retrieveUserData(_ uid: String){
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if uid == selfUID {
                
                if let selfData = self.rootController?.selfData {
                    
                    self.userData = selfData
                    
                    var scopePosts = [[AnyHashable: Any]]()
                    var scopeFirstMessages = [[AnyHashable : Any]]()
                    var scopeSecondMessages = [[AnyHashable : Any]]()
                    var scopeThirdMessages = [[AnyHashable : Any]]()
                    
                    if let posts = selfData["posts"] as? [AnyHashable: Any] {
                        
                        for post in posts {
                            
                            if let data = post.1 as? [AnyHashable: Any] {
                                
                                scopePosts.append(data)
                                
                            }
                        }
                    }
                    
                    scopePosts.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                        
                        if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                            return true
                        } else {
                            return false
                        }
                    })
                    
                    for _ in scopePosts {
                        
                        scopeFirstMessages.append([AnyHashable : Any]())
                        scopeSecondMessages.append([AnyHashable : Any]())
                        scopeThirdMessages.append([AnyHashable : Any]())
                        
                    }
                    
                    self.globFirstMessages = scopeFirstMessages
                    self.globSecondMessages = scopeSecondMessages
                    self.globThirdMessages = scopeThirdMessages
                    
                    self.userPosts = scopePosts
                    
                    self.globCollectionCell.reloadData()

                    for i in 0..<scopePosts.count {
                        
                        let post = scopePosts[i]
                        
                        print(post)
                        scopeFirstMessages.append([AnyHashable : Any]())
                        scopeSecondMessages.append([AnyHashable : Any]())
                        scopeThirdMessages.append([AnyHashable : Any]())
   
                        if let city = post["city"] as? String, let postChildKey = post["postChildKey"] as? String {
                            
                            let ref = FIRDatabase.database().reference().child("posts").child(city).child(postChildKey).child("messages")
                            ref.keepSynced(true)
                            ref.observeSingleEvent(of: .value, with: { (snapshot) in

                                if let allMessages = snapshot.value as? [AnyHashable : Any] {
                                    
                                    var sortedMessages = allMessages.sorted(by: { (a: (key: AnyHashable, value: Any), b: (key: AnyHashable, value: Any)) -> Bool in
                                        
                                        if let a = a.value as? [AnyHashable : Any], let b = b.value as? [AnyHashable : Any] {
                                            
                                            if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                                
                                                return true
                                                
                                            }
                                        }
                                        
                                        return false

                                    })
                                    
                                    if sortedMessages.count == 1 {
                                        
                                        if let firstMessage = sortedMessages[0].value as? [AnyHashable : Any] {
                                            
                                            scopeThirdMessages[i] = firstMessage
                                            
                                        }
                                        
                                    }
                                    
                                    if sortedMessages.count == 2 {
                                        
                                        if let firstMessage = sortedMessages[0].value as? [AnyHashable : Any] {
                                            
                                            scopeThirdMessages[i] = firstMessage
                                            
                                        }
                                        
                                        
                                        if let secondMessage = sortedMessages[1].value as? [AnyHashable : Any] {
                                            
                                            scopeSecondMessages[i] = secondMessage
                                            
                                        }
                                    }
                                    
                                    if sortedMessages.count > 2 {
                                        
                                        if let firstMessage = sortedMessages[0].value as? [AnyHashable : Any] {
                                            
                                            scopeThirdMessages[i] = firstMessage
                                            
                                        }
                                        
                                        
                                        if let secondMessage = sortedMessages[1].value as? [AnyHashable : Any] {
                                            
                                            scopeSecondMessages[i] = secondMessage
                                            
                                        }
                                        
                                        
                                        if let thirdMessage = sortedMessages[2].value as? [AnyHashable : Any] {
                                            
                                            scopeFirstMessages[i] = thirdMessage
                                            
                                        }
                                    }
                                    
                                    self.globFirstMessages = scopeFirstMessages
                                    self.globSecondMessages = scopeSecondMessages
                                    self.globThirdMessages = scopeThirdMessages
                                    
                                    self.globCollectionCell.reloadData()
                                    self.globFirstMessages = scopeFirstMessages
                                    self.globSecondMessages = scopeSecondMessages
                                    self.globThirdMessages = scopeThirdMessages
                                    
                                    self.globCollectionCell.reloadData()
                                }
                            })
                        }
                        
                    }
  
                    self.userPosts = scopePosts

                    self.globCollectionCell.reloadData()
                    
                }
                
            } else {
                
                let ref = FIRDatabase.database().reference().child("users").child(uid)
                
                
                ref.observe(.value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? [AnyHashable: Any] {
                        
                        if self.currentUID == value["uid"] as? String {
                            
                            self.userData = value
                            
                            var scopePosts = [[AnyHashable: Any]]()
                            
                            var scopeFirstMessages = [[AnyHashable : Any]]()
                            var scopeSecondMessages = [[AnyHashable : Any]]()
                            var scopeThirdMessages = [[AnyHashable : Any]]()
                            
                            if let posts = value["posts"] as? [AnyHashable: Any] {
                                
                                for post in posts {
                                    
                                    if let data = post.1 as? [AnyHashable: Any] {
                                        
                                        scopePosts.append(data)
                                        
                                    }
                                }
                            }
                            
                            scopePosts.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                                
                                if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                    return true
                                } else {
                                    return false
                                }
                                
                                
                            })
                            
                            for _ in scopePosts {
                                
                                scopeFirstMessages.append([AnyHashable : Any]())
                                scopeSecondMessages.append([AnyHashable : Any]())
                                scopeThirdMessages.append([AnyHashable : Any]())
                                
                            }
                            
                            self.globFirstMessages = scopeFirstMessages
                            self.globSecondMessages = scopeSecondMessages
                            self.globThirdMessages = scopeThirdMessages
                            
                            self.userPosts = scopePosts
                            
                            self.globCollectionCell.reloadData()
                            
                            for i in 0..<scopePosts.count {
 
                                let post = scopePosts[i]
 
                                if let city = post["city"] as? String, let postChildKey = post["postChildKey"] as? String {
                                    
                                    let ref = FIRDatabase.database().reference().child("posts").child(city).child(postChildKey).child("messages")
                                    ref.keepSynced(true)
                                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        if let allMessages = snapshot.value as? [AnyHashable : Any] {
                                            
                                            var sortedMessages = allMessages.sorted(by: { (a: (key: AnyHashable, value: Any), b: (key: AnyHashable, value: Any)) -> Bool in
                                                
                                                if let a = a.value as? [AnyHashable : Any], let b = b.value as? [AnyHashable : Any] {
                                                    
                                                    if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                                        
                                                        return true
                                                        
                                                    }
                                                }
                                                
                                                return false
                                                
                                            })
                                            
                                            if sortedMessages.count == 1 {
                                                
                                                if let firstMessage = sortedMessages[0].value as? [AnyHashable : Any] {
                                                    
                                                    scopeThirdMessages[i] = firstMessage
                                                    
                                                }
                                                
                                            }
                                            
                                            if sortedMessages.count == 2 {
                                                
                                                if let firstMessage = sortedMessages[0].value as? [AnyHashable : Any] {
                                                    
                                                    scopeThirdMessages[i] = firstMessage
                                                    
                                                }

                                                
                                                if let secondMessage = sortedMessages[1].value as? [AnyHashable : Any] {
                                                    
                                                    scopeSecondMessages[i] = secondMessage
                                                    
                                                }
                                            }
                                            
                                            if sortedMessages.count > 2 {
                                                
                                                if let firstMessage = sortedMessages[0].value as? [AnyHashable : Any] {
                                                    
                                                    scopeThirdMessages[i] = firstMessage
                                                    
                                                }
                                                
                                                
                                                if let secondMessage = sortedMessages[1].value as? [AnyHashable : Any] {
                                                    
                                                    scopeSecondMessages[i] = secondMessage
                                                    
                                                }

                                                
                                                if let thirdMessage = sortedMessages[2].value as? [AnyHashable : Any] {
                                                    
                                                    scopeFirstMessages[i] = thirdMessage
                                                    
                                                }
                                            }
     
                                            self.globFirstMessages = scopeFirstMessages
                                            self.globSecondMessages = scopeSecondMessages
                                            self.globThirdMessages = scopeThirdMessages
                                            
                                            self.globCollectionCell.reloadData()
                                        }
                                    })
                                }
                            }

                            
                            
                        } else {
                            ref.removeAllObservers()
                        }
                    }
                })
            }
        }
    }

    func setPlayerTitle(_ postKey: String, cell: UICollectionViewCell) {
        
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
        
        if let userCell = cell as? UserVideoPostCell {
            
            userCell.player = playerForCell
            
        } else if let videoCell = cell as? VideoVibeCollectionCell {
            
            videoCell.player = playerForCell
            
        }
    }
    
    
    //CollectionViewDelegates
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let videoCell = cell as? UserVideoPostCell {
            
            let index = videoCell.index
            let postKey = videoCell.postChildKey
            let playerNumber = videoCell.player
            
            if let player = videoPlayers[playerNumber] {
                
                if !videoPlayersObserved[playerNumber] {
                    
                    player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                    videoPlayersObserved[playerNumber] = true
                    
                }
                
                DispatchQueue.main.async(execute: {
                    
                    self.videoLayers[playerNumber] = AVPlayerLayer(player: player)
                    self.videoLayers[playerNumber]?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.videoLayers[playerNumber]?.frame = videoCell.bounds
                    
                    if let layer = self.videoLayers[playerNumber] {
                        
                        videoCell.videoOutlet.layer.addSublayer(layer)
                        
                    }
                    
                    player.isMuted = true
                    player.play()
                    
                    
                })
                
            } else {
                
                var asset: AVAsset?
                
                if let loadedAsset = videoAssets[postKey] {
                    
                    asset = loadedAsset
                    
                } else if let urlString = userPosts[index]["videoURL"] as? String, let url = URL(string: urlString) {
                    
                    asset = AVAsset(url: url)
                    
                }
                
                if let actualAsset = asset {
                    
                    DispatchQueue.main.async(execute: {
                        
                        let playerItem = AVPlayerItem(asset: actualAsset)
                        self.videoKeys[playerNumber] = postKey
                        self.videoPlayers[playerNumber] = AVPlayer(playerItem: playerItem)
                        self.videoPlayers[playerNumber]?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        self.videoPlayersObserved[playerNumber] = true
                        
                        self.videoLayers[playerNumber] = AVPlayerLayer(player: self.videoPlayers[playerNumber])
                        self.videoLayers[playerNumber]?.videoGravity = AVLayerVideoGravityResizeAspectFill
                        self.videoLayers[playerNumber]?.frame = videoCell.bounds
                        
                        if let layer = self.videoLayers[playerNumber] {
                            
                            videoCell.videoOutlet.layer.addSublayer(layer)
                            
                        }
                        
                        self.videoPlayers[playerNumber]?.isMuted = true
                        self.videoPlayers[playerNumber]?.play()
                        
                    })
                }
            }
            
        }
        
        var shouldAdd = false
        
        var key = ""
        var playerNumber = 0
        
        if let postVideo = cell as? VideoVibeCollectionCell {
            
            postVideo.createIndicator()
            shouldAdd = true
            key = postVideo.postKey
            playerNumber = postVideo.player
            
        }
        
        if let inVideo = cell as? InMediaCollectionCell {
            
            if !inVideo.isImage {
                
                shouldAdd = true
                key = inVideo.key
                playerNumber = inVideo.player
                
            }
            
        }
        
        if let outVideo = cell as? OutMediaCollectionCell {
            
            if !outVideo.isImage {
                
                shouldAdd = true
                key = outVideo.key
                playerNumber = outVideo.player
                
            }
        }
        
        if shouldAdd {
            
            if let player = videoPlayers[playerNumber] {
                
                if !videoPlayersObserved[playerNumber] {
                    
                    player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                    videoPlayersObserved[playerNumber] = true
                    
                }
                
                DispatchQueue.main.async(execute: {

                    self.videoLayers[playerNumber] = AVPlayerLayer(player: player)
                    
                    if let layer = self.videoLayers[playerNumber] {
                        
                        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                        
                        if let postVideo = cell as? VideoVibeCollectionCell {
                            
                            layer.frame = postVideo.bounds
                            
                            postVideo.videoOutlet.layer.addSublayer(layer)
                            
                            if postVideo.postKey == self.videoWithSound {
                                
                                postVideo.soundImageOutlet.image = UIImage(named: "unmute")
                                postVideo.soundLabelOutlet.text = "Tap to mute"
                                player.isMuted = false
                                
                            } else {
                                
                                postVideo.soundImageOutlet.image = UIImage(named: "mute")
                                postVideo.soundLabelOutlet.text = "Tap for sound"
                                player.isMuted = true
                                
                            }
                            
                        } else if let inVideo = cell as? InMediaCollectionCell {
                            
                            if !inVideo.isImage {
                                
                                layer.frame = inVideo.bounds
                                inVideo.videoOutlet.layer.addSublayer(layer)
                                player.isMuted = true
                                
                            }
                            
                        } else if let outVideo = cell as? OutMediaCollectionCell {
                            
                            if !outVideo.isImage {
                                
                                layer.frame = outVideo.bounds
                                player.isMuted = true
                                outVideo.videoOutlet.layer.addSublayer(layer)
                                
                            }
                        }
                        
                        player.play()
                        
                    }
                })
            } else {
                
                var asset: AVAsset?
                
                if let loadedAsset = videoAssets[key] {
                    
                    asset = loadedAsset
                    
                } else {
                    
                    if cell is VideoVibeCollectionCell {
                        
                        if let urlString = userPosts[(indexPath as NSIndexPath).section - 1]["videoURL"] as? String, let url = URL(string: urlString) {
                            
                            asset = AVAsset(url: url)
                            
                        }
                        
                    } else if cell is InMediaCollectionCell || cell is OutMediaCollectionCell {
                        
                        if (indexPath as NSIndexPath).row == 4 {
                            
                            if let urlString = globFirstMessages[(indexPath as NSIndexPath).section - 1]["media"] as? String, let url = URL(string: urlString) {
                                
                                asset = AVAsset(url: url)
                                
                            }
                            
                        } else if (indexPath as NSIndexPath).row == 5 {
                            
                            if let urlString = globSecondMessages[(indexPath as NSIndexPath).section - 1]["media"] as? String, let url = URL(string: urlString) {
                                
                                asset = AVAsset(url: url)
                                
                            }
                            
                            
                        } else if (indexPath as NSIndexPath).row == 6 {
                            
                            if let urlString = globThirdMessages[(indexPath as NSIndexPath).section - 1]["media"] as? String, let url = URL(string: urlString) {
                                
                                asset = AVAsset(url: url)
                                
                            }
                        }
                    }
                }
                
                if let actualAsset = asset {
                    
                    DispatchQueue.main.async(execute: {
                        
                        let playerItem = AVPlayerItem(asset: actualAsset)
                        self.videoKeys[playerNumber] = key
                        self.videoPlayers[playerNumber] = AVPlayer(playerItem: playerItem)
                        
                        if let player = self.videoPlayers[playerNumber] {
                            
                            player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                            self.videoPlayersObserved[playerNumber] = true
                            
                            self.videoLayers[playerNumber] = AVPlayerLayer(player: self.videoPlayers[playerNumber])
                            
                            if let layer = self.videoLayers[playerNumber] {
                                
                                layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                                
                                if let postVideo = cell as? VideoVibeCollectionCell {
                                    
                                    self.videoLayers[playerNumber]?.frame = postVideo.bounds
                                    
                                    if postVideo.postKey == self.videoWithSound {
                                        
                                        postVideo.soundImageOutlet.image = UIImage(named: "unmute")
                                        postVideo.soundLabelOutlet.text = "Tap to mute"
                                        player.isMuted = false
                                        
                                    } else {
                                        
                                        postVideo.soundImageOutlet.image = UIImage(named: "mute")
                                        postVideo.soundLabelOutlet.text = "Tap for sound"
                                        player.isMuted = true
                                        
                                    }
                                    
                                    postVideo.videoOutlet.layer.addSublayer(layer)
                                    
                                } else if let inVideo = cell as? InMediaCollectionCell {
                                    
                                    if !inVideo.isImage {
                                        
                                        layer.frame = inVideo.bounds
                                        inVideo.videoOutlet.layer.addSublayer(layer)
                                        player.isMuted = true
                                        
                                    }
                                    
                                } else if let outVideo = cell as? OutMediaCollectionCell {
                                    
                                    if !outVideo.isImage {
                                        
                                        layer.frame = outVideo.bounds
                                        outVideo.videoOutlet.layer.addSublayer(layer)
                                        player.isMuted = true
                                        
                                    }
                                }
                                
                                player.play()
                                
                            }
                        }
                    })
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if !userPosts.isEmpty {
            
            if let videoCell = cell as? UserVideoPostCell {
                
                var isVisible = false
                
                for visibleCell in collectionView.visibleCells {
                    
                    if let visibleVideo = visibleCell as? UserVideoPostCell {
                        
                        let index = visibleVideo.index
                        
                        if visibleVideo.postChildKey == self.userPosts[index]["postChildKey"] as? String {
                            
                            isVisible = true
                            
                        }
                    }
                }
                
                let playerNumber = videoCell.player
                
                if let player = videoPlayers[playerNumber] {
                    
                    if videoPlayersObserved[playerNumber] {
                        
                        player.removeObserver(self, forKeyPath: "rate")
                        videoPlayersObserved[playerNumber] = false
                        
                    }
                }
                
                if !isVisible {
                    
                    videoLayers[playerNumber]?.removeFromSuperlayer()
                    videoLayers[playerNumber] = nil
                    videoKeys[playerNumber] = nil
                    videoPlayers[playerNumber]?.pause()
                    videoPlayers[playerNumber] = nil
                    
                    if let subLayers = videoCell.videoOutlet.layer.sublayers {
                        
                        for layer in subLayers {
                            
                            layer.removeFromSuperlayer()
                            
                        }
                    }
                }
            }
 
            var shouldRemove = false
            
            var isVisible = false
            
            for visibleCell in collectionView.visibleCells {
                
                if let visibleVideo = visibleCell as? VideoVibeCollectionCell {
                    
                    let index = visibleVideo.index
                    
                    if visibleVideo.postKey == self.userPosts[index]["postChildKey"] as? String {
                        
                        isVisible = true
                        
                    }
                    
                } else {
                    
                    if let visibleVideo = visibleCell as? InMediaCollectionCell {
                        
                        if !visibleVideo.isImage {
                            
                            if (indexPath as NSIndexPath).row == 4 {
                                
                                if visibleVideo.key == self.globFirstMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                                
                            } else if (indexPath as NSIndexPath).row == 5 {
                                
                                if visibleVideo.key == self.globSecondMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if (indexPath as NSIndexPath).row == 6 {
                                
                                if visibleVideo.key == self.globThirdMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                            }
                        }
                        
                    } else if let visibleVideo = visibleCell as? OutMediaCollectionCell {
                        
                        if !visibleVideo.isImage {
                            
                            if (indexPath as NSIndexPath).row == 4 {
                                
                                if visibleVideo.key == self.globFirstMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if (indexPath as NSIndexPath).row == 5 {
                                
                                if visibleVideo.key == self.globSecondMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                                
                            } else if (indexPath as NSIndexPath).row == 6 {
                                
                                if visibleVideo.key == self.globThirdMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                    
                                    isVisible = true
                                    
                                }
                            }
                        }
                    }
                }
            }
            
            var playerNumber = 0
            
            if let videoCell = cell as? VideoVibeCollectionCell {
                
                shouldRemove = true
                playerNumber = videoCell.player
                
            } else if let inCell = cell as? InMediaCollectionCell {
                
                if !inCell.isImage {
                    
                    shouldRemove = true
                    playerNumber = inCell.player
                    
                }
                
            } else if let outCell = cell as? OutMediaCollectionCell {
                
                if !outCell.isImage {
                    
                    shouldRemove = true
                    playerNumber = outCell.player
                    
                }
            }
            
            if let player = videoPlayers[playerNumber] {
                
                if videoPlayersObserved[playerNumber] && shouldRemove {
                    
                    player.removeObserver(self, forKeyPath: "rate")
                    videoPlayersObserved[playerNumber] = false
                    
                }
            }
            
            if !isVisible && shouldRemove {
                
                if let videoCell = cell as? VideoVibeCollectionCell {
                    
                    for view in videoCell.videoThumbnailOutlet.subviews  {
                        
                        view.removeFromSuperview()
                        
                    }
                    
                    if let subLayers = videoCell.videoOutlet.layer.sublayers {
                        
                        for layer in subLayers {
                            
                            layer.removeFromSuperlayer()
                            
                        }
                    }
                    
                } else if let videoCell = cell as? InMediaCollectionCell {
                    
                    if !videoCell.isImage  {
                        
                        if let subLayers = videoCell.videoOutlet.layer.sublayers {
                            
                            for layer in subLayers {
                                
                                layer.removeFromSuperlayer()
                                
                            }
                        }
                    }
                    
                } else if let videoCell = cell as? OutMediaCollectionCell {
                    
                    if !videoCell.isImage  {
                        
                        if let subLayers = videoCell.videoOutlet.layer.sublayers {
                            
                            for layer in subLayers {
                                
                                layer.removeFromSuperlayer()
                                
                            }
                        }
                    }
                }
                
                videoLayers[playerNumber]?.removeFromSuperlayer()
                videoLayers[playerNumber] = nil
                videoKeys[playerNumber] = nil
                videoPlayers[playerNumber]?.pause()
                videoPlayers[playerNumber] = nil
                
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            if (indexPath as NSIndexPath).row == 0 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! StatusCell
                cell.profileController = self
                cell.loadCell(userData)
                return cell
                
            } else if (indexPath as NSIndexPath).row == 1 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilePicCell", for: indexPath) as! ProfilePicCollectionCell
                
                let screenWidth = self.view.bounds.width
                cell.profileController = self
                cell.currentPicture = currentPicture
                cell.loadImages(userData, screenWidth: screenWidth)
                return cell
                
            }  else if (indexPath as NSIndexPath).row == 2 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nameCell", for: indexPath) as! ProfileInfoCollectionCell
                
                if selfProfile {
                    
                    cell.squadButtonOutlet.alpha = 0
                    cell.messageButtonOutlet.alpha = 0
                    
                } else {
                    
                    cell.squadButtonOutlet.alpha = 1
                    cell.messageButtonOutlet.alpha = 1
                    
                }
                
                cell.profileController = self
                cell.loadData(userData)
                
                cell.nameOutlet.adjustsFontSizeToFitWidth = true
                cell.cityOutlet.adjustsFontSizeToFitWidth = true
                
                return cell
                
            } else if (indexPath as NSIndexPath).row == 3 {
                
                if selfProfile {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selfRankSquadCell", for: indexPath)
                        as! SelfSquadRankCell
                    
                    cell.profileController = self
                    cell.loadData(userData)
                    return cell
                    
                } else {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notSelfRankSquadCell", for: indexPath) as! NotSelfSquadRankCell
                    
                    cell.profileController = self
                    cell.loadData(userData)
                    
                    return cell
                    
                }
                
            } else if !selfProfile && (indexPath as NSIndexPath).row == 4  {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activeDistanceCell", for: indexPath) as! ActiveDistanceCell
                cell.profileController = self
                cell.loadData(userData)
                return cell
                
            } else if (selfProfile && (indexPath as NSIndexPath).row == 4) || (!selfProfile && (indexPath as NSIndexPath).row == 5) {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "viewModeCell", for: indexPath) as! ViewModeCell
                
                cell.profileController = self
                cell.setViewMode()
                
                return cell
                
            }
            
        } else {
            
            if gridView {
                
                let index = (indexPath as NSIndexPath).row
                
                if let isImage = userPosts[index]["isImage"] as? Bool{
                    
                    if isImage {
                        
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userImagePostCell", for: indexPath) as! UserImagePostCell
                        
                        cell.profileController = self
                        
                        cell.posts = userPosts as [[NSObject : AnyObject]]
                        cell.index = index
                        cell.loadCell(userPosts[index])
                        
                        return cell
                        
                    } else {
                        
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userVideoPostCell", for: indexPath) as! UserVideoPostCell
                        
                        cell.profileController = self
                        
                        if let key = userPosts[index]["postChildKey"] as? String {
                            
                            setPlayerTitle(key, cell: cell)
                            
                        }
                        
                        cell.loadCell(userPosts[index])
                        
                        cell.posts = userPosts as [[NSObject : AnyObject]]
                        cell.index = index
                        
                        cell.imageOutlet.layer.cornerRadius = 10
                        cell.imageOutlet.clipsToBounds = true
                        cell.videoOutlet.layer.cornerRadius = 10
                        cell.videoOutlet.clipsToBounds = true
                        
                        if let imageUrlString = userPosts[index]["imageURL"] as? String, let imageUrl = URL(string: imageUrlString) {
                            
                            cell.imageOutlet.sd_setImage(with: imageUrl, completed: { (image, error, cache, url) in
                                
                                print("done loading video thumbnail")
                                
                            })
                            
                            
                            return cell
                            
                        }
                    }
                }
                
            } else {
 
                if (indexPath as NSIndexPath).row == 0 {
                    
                    if let isImage = userPosts[(indexPath as NSIndexPath).section - 1]["isImage"] as? Bool {
                        
                        if isImage {
                            
                            if let urlString = userPosts[(indexPath as NSIndexPath).section - 1]["imageURL"] as? String, let url = URL(string: urlString){
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageVibeCollectionCell
                                cell.createIndicator()
                                cell.loadImage(url)
                                cell.addPinchRecognizer()
                                return cell
                            }
                            
                        } else {
                            
                            if let  imageUrlString = userPosts[(indexPath as NSIndexPath).section - 1]["imageURL"] as? String, let imageUrl = URL(string: imageUrlString), let key = userPosts[(indexPath as NSIndexPath).section - 1]["postChildKey"] as? String {
                                
                                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoVibeCollectionCell
                                
                                cell.soundOutlet.layer.cornerRadius = 5
                                cell.postKey = key
                                cell.index = indexPath.section - 1
                                
                                setPlayerTitle(key, cell: cell)
                                
                                cell.profileController = self
                                cell.vibesController = nil
                                
                                cell.videoThumbnailOutlet.sd_setImage(with: imageUrl, completed: { (image, error, cache, url) in
                                    
                                    print("done loading video thumbnail")
                                    
                                })
                                
                                return cell
                                
                            }
                        }
                    }
                    
                    
                } else if (indexPath as NSIndexPath).row == 1 {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "buttonsCell", for: indexPath) as! LikeButtonsCollectionCell
                    
                    cell.profileController = self
                    cell.vibesController = nil
                    cell.loadData(userPosts[(indexPath as NSIndexPath).section - 1])
                    
                    return cell
                    
                } else if (indexPath as NSIndexPath).row == 2 {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "captionCell", for: indexPath) as! CaptionCell
                    cell.loadData(userPosts[(indexPath as NSIndexPath).section - 1])
                    return cell
                    
                } else if (indexPath as NSIndexPath).row == 3 {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeAgoCell", for: indexPath) as! TimeAgoCollectionCell
                    cell.loadData(userPosts[(indexPath as NSIndexPath).section - 1])
                    return cell
                    
                } else if (indexPath as NSIndexPath).row == 4 {
                    
                    //if incoming -> inCell, else outCell
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if let senderId = globFirstMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                            
                            var selfMessage = false
                            
                            if senderId == selfUID {
                                
                                selfMessage = true
                                
                            }
                            
                            if let isMedia = globFirstMessages[(indexPath as NSIndexPath).section - 1]["isMedia"] as? Bool {
                                
                                if !isMedia {
                                    
                                    if !selfMessage {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
                                        
                                        if let secondId = globSecondMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                                            
                                            if secondId == senderId {
                                                
                                                cell.loadData(false, data: globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            } else {
                                                
                                                cell.loadData(true, data: globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            }
                                            
                                        } else {
                                            
                                            cell.loadData(true, data: globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                            
                                        }
                                        
                                        return cell
                                        
                                        
                                    } else {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMessageCell", for: indexPath) as! OutgoingCollectionCell
                                        
                                        cell.loadData(globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                        return cell
                                        
                                    }
                                    
                                } else {
                                    
                                    if !selfMessage {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMediaCell", for: indexPath) as! InMediaCollectionCell
                                        
                                        
                                        if let secondId = globSecondMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                                            
                                            if secondId == senderId {
                                                
                                                cell.loadCell(false, message: globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            } else {
                                                
                                                cell.loadCell(true, message: globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            }
                                            
                                        } else {
                                            
                                            cell.loadCell(true, message: globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                            
                                        }
                                        
                                        if let key = globFirstMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    } else {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMediaCell", for: indexPath) as! OutMediaCollectionCell
                                        
                                        cell.loadCell(globFirstMessages[(indexPath as NSIndexPath).section - 1])
                                        
                                        if let key = globFirstMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                } else if (indexPath as NSIndexPath).row == 5 {
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if let senderId = globSecondMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                            
                            var selfMessage = false
                            
                            if senderId == selfUID {
                                
                                selfMessage = true
                                
                            }
                            
                            if let isMedia = globSecondMessages[(indexPath as NSIndexPath).section - 1]["isMedia"] as? Bool {
                                
                                if !isMedia {
                                    
                                    if !selfMessage {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
                                        
                                        if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                                            
                                            if thirdId == senderId {
                                                
                                                cell.loadData(false, data: globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            } else {
                                                
                                                cell.loadData(true, data: globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            }
                                        } else {
                                            
                                            cell.loadData(true, data: globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                            
                                        }
                                        
                                        if let key = globSecondMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    } else {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMessageCell", for: indexPath) as! OutgoingCollectionCell
                                        
                                        cell.loadData(globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                        
                                        if let key = globSecondMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    }
                                    
                                } else {
                                    
                                    if !selfMessage {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMediaCell", for: indexPath) as! InMediaCollectionCell
                                        
                                        if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                                            
                                            if thirdId == senderId {
                                                
                                                cell.loadCell(false, message: globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            } else {
                                                
                                                cell.loadCell(true, message: globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                                
                                            }
                                            
                                        } else {
                                            
                                            cell.loadCell(true, message: globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                            
                                        }
                                        
                                        if let key = globSecondMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    } else {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMediaCell", for: indexPath) as! OutMediaCollectionCell
                                        
                                        cell.loadCell(globSecondMessages[(indexPath as NSIndexPath).section - 1])
                                        
                                        if let key = globSecondMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                } else if (indexPath as NSIndexPath).row == 6 {
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if let senderId = globThirdMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                            
                            var selfMessage = false
                            
                            if senderId == selfUID {
                                
                                selfMessage = true
                                
                            }
                            
                            if let isMedia = globThirdMessages[(indexPath as NSIndexPath).section - 1]["isMedia"] as? Bool {
                                
                                if !isMedia {
                                    
                                    if !selfMessage {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
                                        cell.loadData(true, data: globThirdMessages[(indexPath as NSIndexPath).section - 1])
                                        return cell
                                        
                                    } else {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMessageCell", for: indexPath) as! OutgoingCollectionCell
                                        cell.loadData(globThirdMessages[(indexPath as NSIndexPath).section - 1])
                                        return cell
                                        
                                    }
                                    
                                } else {
                                    
                                    if !selfMessage {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMediaCell", for: indexPath) as! InMediaCollectionCell
                                        
                                        cell.loadCell(true, message: globThirdMessages[(indexPath as NSIndexPath).section - 1])
                                        
                                        if let key = globThirdMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    } else {
                                        
                                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outMediaCell", for: indexPath) as! OutMediaCollectionCell
                                        
                                        cell.loadCell(globThirdMessages[(indexPath as NSIndexPath).section - 1])
                                        
                                        if let key = globThirdMessages[(indexPath as NSIndexPath).section - 1]["key"] as? String {
                                            
                                            setPlayerTitle(key, cell: cell)
                                            
                                        }
                                        
                                        return cell
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                } else if (indexPath as NSIndexPath).row == 7 {
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goToChatCell", for: indexPath) as! GoToChatCell
                    cell.profileController = self
                    cell.vibesController = nil
                    cell.index = indexPath.section - 1
                    cell.loadData(userPosts[(indexPath as NSIndexPath).section - 1])
                    
                    return cell
                    
                }
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inMessageCell", for: indexPath) as! IncomingCollectionCell
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            
            if selfProfile && userPosts.count == 0 {
                
                return 4
                
            } else if (!selfProfile && userPosts.count == 0) || (selfProfile && userPosts.count > 0) {
                
                return 5
                
            } else {
                
                return 6
                
            }
            
        } else {
            
            if gridView {
                
                return userPosts.count
                
            } else {
                
                return 8
                
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if gridView {
            
            return 2
            
        } else {
            
            return (userPosts.count + 1)
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
        if indexPath.section == 0 {
            
            if (indexPath as NSIndexPath).row == 0 {
                
                if let status = userData["currentStatus"] as? String {
                    
                    if status != "" {
                        
                        return CGSize(width: width, height: 44)
                        
                    }
                }
                
                return CGSize(width: width, height: 0)
                
            } else if (indexPath as NSIndexPath).row == 1 {
                
                return CGSize(width: width, height: width)
                
                
            } else if (indexPath as NSIndexPath).row == 2 {
                
                if self.selfProfile {
                    
                    return CGSize(width: width, height: 90)
                    
                } else {
                    
                    if let occupation = userData["occupation"] as? String {
                        
                        if occupation != "" {
                            
                            return CGSize(width: width, height: 90)
                            
                        }
                        
                    }
                    
                    return CGSize(width: width, height: 67)
                    
                }
                
            } else if (indexPath as NSIndexPath).row == 3  {
                
                return CGSize(width: width, height: 60)
                
            } else if (indexPath as NSIndexPath).row == 4 && !selfProfile {
                
                return CGSize(width: width, height: 45)
                
            } else  {
                
                return CGSize(width: width, height: 50)
                
            }
            
        } else {
            
            if gridView {
                
                let thirdWidth = width * 0.33
                return CGSize(width: thirdWidth, height: thirdWidth)
                
            } else {
                
                if (indexPath as NSIndexPath).row == 0 {
                    
                    return CGSize(width: width, height: width)
                    
                } else if (indexPath as NSIndexPath).row == 1 {
                    
                    return CGSize(width: width, height: 55)
                    
                } else if (indexPath as NSIndexPath).row == 2 {
                    
                    if userPosts[(indexPath as NSIndexPath).section - 1]["caption"] as? String != "" {
                        
                        return CGSize(width: width, height: 33)
                        
                    } else {
                        
                        return CGSize(width: width, height: 0)
                        
                    }
                    
                } else if (indexPath as NSIndexPath).row == 3 {
                    
                    return CGSize(width: width, height: 25)
                    
                } else if (indexPath as NSIndexPath).row == 4 {
                    
                    if let senderId = globFirstMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        var selfMessage = false
                        
                        if senderId == selfUID {
                            
                            selfMessage = true
                            
                        }
                        
                        if let isMedia = globFirstMessages[(indexPath as NSIndexPath).section - 1]["isMedia"] as? Bool {
                            
                            if !isMedia {
                                
                                if !selfMessage {
                                    
                                    if let secondId = globSecondMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                                        
                                        if secondId == senderId {
                                            
                                            return CGSize(width: width, height: 38)
                                            
                                        } else {
                                            
                                            return CGSize(width: width, height: 52)
                                            
                                        }
                                        
                                    } else {
                                        
                                        return CGSize(width: width, height: 52)
                                        
                                    }
                                    
                                    
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 38)
                                    
                                }
                                
                            } else {
                                
                                if !selfMessage {
                                    
                                    if let secondId = globSecondMessages[(indexPath as NSIndexPath).section - 1]["senderID"] as? String {
                                        
                                        if secondId == senderId {
                                            
                                            return CGSize(width: width, height: 108)
                                            
                                        } else {
                                            
                                            return CGSize(width: width, height: 120)
                                            
                                        }
                                        
                                    } else {
                                        
                                        return CGSize(width: width, height: 120)
                                        
                                    }
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 108)
                                    
                                    
                                }
                            }
                        }
                        
                    } else {
                        
                        return CGSize(width: width, height: 0)
                        
                    }
                    
                } else if (indexPath as NSIndexPath).row == 5 {
                    
                    if let senderId = globSecondMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        var selfMessage = false
                        
                        if senderId == selfUID {
                            
                            selfMessage = true
                            
                        }
                        
                        if let isMedia = globSecondMessages[(indexPath as NSIndexPath).section - 1]["isMedia"] as? Bool {
                            
                            if !isMedia {
                                
                                if !selfMessage {
                                    
                                    if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                                        
                                        if thirdId == senderId {
                                            return CGSize(width: width, height: 38)
                                            
                                        } else {
                                            
                                            return CGSize(width: width, height: 52)
                                            
                                        }
                                    } else {
                                        
                                        return CGSize(width: width, height: 52)
                                        
                                    }
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 38)
                                    
                                }
                                
                            } else {
                                
                                if !selfMessage {
                                    
                                    if let thirdId = globThirdMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String {
                                        
                                        if thirdId == senderId {
                                            return CGSize(width: width, height: 108)
                                            
                                        } else {
                                            
                                            return CGSize(width: width, height: 120)
                                            
                                        }
                                        
                                    } else {
                                        
                                        return CGSize(width: width, height: 120)
                                        
                                    }
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 108)
                                    
                                }
                            }
                        }
                    } else {
                        
                        return CGSize(width: width, height: 0)
                        
                    }
                    
                } else if (indexPath as NSIndexPath).row == 6 {
                    
                    if let senderId = globThirdMessages[(indexPath as NSIndexPath).section - 1]["senderId"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        var selfMessage = false
                        
                        if senderId == selfUID {
                            
                            selfMessage = true
                            
                        }
                        
                        if let isMedia = globThirdMessages[(indexPath as NSIndexPath).section - 1]["isMedia"] as? Bool {
                            
                            if !isMedia {
                                
                                if !selfMessage {
                                    
                                    return CGSize(width: width, height: 52)
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 38)
                                    
                                }
                                
                            } else {
                                
                                if !selfMessage {
                                    
                                    return CGSize(width: width, height: 120)
                                    
                                } else {
                                    
                                    return CGSize(width: width, height: 108)
                                    
                                }
                            }
                        }
                    } else {
                        
                        return CGSize(width: width, height: 0)
                        
                    }
                    
                } else if (indexPath as NSIndexPath).row == 7 {
                    
                    if (indexPath as NSIndexPath).section == userPosts.count {
                        
                        return CGSize(width: width, height: 80)
                        
                    } else {
                        
                        return CGSize(width: width, height: 36)
                        
                    }
                }
                
                return CGSize.zero
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUploadStuff()
        
        for _ in 0..<20 {
            
            videoPlayersObserved.append(false)
            videoLayers.append(nil)
            videoPlayers.append(nil)
            videoKeys.append(nil)
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SDWebImageManager.shared().imageCache.clearMemory()
        
        
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
