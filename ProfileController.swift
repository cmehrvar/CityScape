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
import Fusuma
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


class ProfileController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FusumaDelegate {
    
    //Variables
    weak var rootController: MainRootController?
    var userData = [AnyHashable: Any]()
    var userPosts = [[AnyHashable: Any]]()
    
    var videoAssets = [String : AVAsset]()
    var videoPlayers = [AVPlayer?]()
    var videoPlayersObserved = [Bool]()
    var videoLayers = [AVPlayerLayer?]()
    var videoKeys = [String?]()
    
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
    
    //Outlets
    @IBOutlet weak var globCollectionCell: UICollectionView!
    
    
    //Actions
    @IBAction func close(_ sender: AnyObject) {
        
        rootController?.toggleHome({ (bool) in
            
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
                            
                            self.userPosts = scopePosts
                            
                            self.globCollectionCell.reloadData()
                            
                        } else {
                            ref.removeAllObservers()
                        }
                    }
                })
            }
        }
    }
    
    
    
    func setPlayerTitle(_ postKey: String, cell: UserVideoPostCell) {
        
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
        cell.player = playerForCell
        
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
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if !userPosts.isEmpty {
            
            if let videoCell = cell as? UserVideoPostCell {
                
                var isVisible = false
                
                for visibleCell in collectionView.visibleCells {
                    
                    if let visibleVideo = visibleCell as? UserVideoPostCell {
                        
                        if visibleVideo.postChildKey == self.userPosts[videoCell.index]["postChildKey"] as? String {
                            
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
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath as NSIndexPath).row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "statusCell", for: indexPath) as! StatusCell
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
            
        } else if !selfProfile && (indexPath as NSIndexPath).row == 4 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activeDistanceCell", for: indexPath) as! ActiveDistanceCell
            cell.profileController = self
            cell.loadData(userData)
            return cell
            
        } else {
            
            var index = (indexPath as NSIndexPath).row
            
            if selfProfile {
                
                index -= 4
                
            } else {
                
                index -= 5
                
            }
            
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
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userImagePostCell", for: indexPath) as! UserImagePostCell
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selfProfile {
            return userPosts.count + 4
        } else {
            return userPosts.count + 5
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
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
                
                
                //THIS WILL NEED TO BE CHANGED
                
                
                return CGSize(width: width, height: 67)
                
            }
            
        } else if (indexPath as NSIndexPath).row == 3  {
            
            return CGSize(width: width, height: 60)
            
        } else if (indexPath as NSIndexPath).row == 4 && !selfProfile {
            
            return CGSize(width: width, height: 34)
            
        } else {
            
            let thirdWidth = width * 0.33
            return CGSize(width: thirdWidth, height: thirdWidth)
            
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
