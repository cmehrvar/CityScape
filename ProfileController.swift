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
import Player
import AWSS3
import AVFoundation
import SDWebImage

class ProfileController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FusumaDelegate, PlayerDelegate {
    
    //Variables
    weak var rootController: MainRootController?
    var userData = [NSObject:AnyObject]()
    var userPosts = [[NSObject : AnyObject]]()
    var videoPlayers = [String : Player]()
    
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
        
        
        
    }
    
    func playerCurrentTimeDidChange(player: Player) {
        
    }
    
    
    
    //Image Uploads
    func imageUploadRequest(image: UIImage, completion: (url: String, uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        
        //SEGMENTATION BUG, IF FAULT 11 - COMMENT OUT AND REWRITE
        dispatch_async(dispatch_get_main_queue()) {
            imageData?.writeToFile(filePath, atomically: true)
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = fileURL
            uploadRequest.key = fileName
            uploadRequest.bucket = "cityscapebucket"
            
            var imageUrl = ""
            
            if let key = uploadRequest.key {
                imageUrl = "https://s3.amazonaws.com/cityscapebucket/" + key
                
            }
            
            completion(url: imageUrl, uploadRequest: uploadRequest)
        }
    }
    
    
    func fusumaDismissedWithImage(image: UIImage) {
        
        print("fusuma dismissed with image")
        
        let scopeEditedImage = editedImage
        
        self.imageUploadRequest(image) { (url, uploadRequest) in
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    print("successful image upload")
                    let ref = FIRDatabase.database().reference()
                    
                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        
                        ref.child("users").child(uid).updateChildValues([scopeEditedImage: url])
                    }
                    
                } else {
                    print("error uploading: \(task.error)")
                    
                    let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
                return nil
            }
        }
    }
    
    
    
    
    func fusumaImageSelected(image: UIImage) {
        
        print("image selected")
        
    }
    
    
    
    func fusumaVideoCompleted(withFileURL fileURL: NSURL) {
        
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
        let alertController = UIAlertController(title: "Sorry", message: "Camera not authorized", preferredStyle:  UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        print("camera unauthorized")
        
    }
    func fusumaClosed() {
        
        UIApplication.sharedApplication().statusBarHidden = false
        rootController?.cameraTransitionOutlet.alpha = 0
        
    }
    
    
    func presentFusuma(editedImage: String){
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false
        
        self.editedImage = editedImage
        
        self.presentViewController(fusuma, animated: true) {
            
            print("fusumaPresented")
            
        }
        
    }
    
    func addUploadStuff(){
        
        let error = NSErrorPointer.init(nilLiteral: ())
        
        do{
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    
    
    
    //Functions
    func retrieveUserData(uid: String){
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if uid == selfUID {
                
                if let selfData = self.rootController?.selfData {
                    
                    self.userData = selfData
                    
                    var scopePosts = [[NSObject:AnyObject]]()
                    
                    if let posts = selfData["posts"] as? [NSObject : AnyObject] {
                        
                        for post in posts {
                            
                            if let data = post.1 as? [NSObject : AnyObject] {
                                
                                scopePosts.append(data)
                                
                            }
                        }
                    }
                    
                    scopePosts.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                        
                        if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
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
                
                ref.observeEventType(.Value, withBlock: { (snapshot) in
                    
                    if let value = snapshot.value as? [NSObject : AnyObject] {
                        
                        if self.currentUID == value["uid"] as? String {
                            
                            self.userData = value
                            
                            var scopePosts = [[NSObject:AnyObject]]()
                            
                            if let posts = value["posts"] as? [NSObject : AnyObject] {
                                
                                for post in posts {
                                    
                                    if let data = post.1 as? [NSObject : AnyObject] {
                                        
                                        scopePosts.append(data)
                                        
                                    }
                                }
                                
                            }
                            
                            scopePosts.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                                
                                if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
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
    
    //CollectionViewDelegates
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userVideoPostCell", forIndexPath: indexPath) as? UserVideoPostCell {

            cell.videoOutlet.alpha = 0

            if let player = videoPlayers[cell.postChildKey] {
                
                player.stop()

            }
        }
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selfProfile {
            return userPosts.count + 4
        } else {
            return userPosts.count + 5
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("statusCell", forIndexPath: indexPath) as! StatusCell
            cell.loadCell(userData)
            return cell
            
        } else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profilePicCell", forIndexPath: indexPath) as! ProfilePicCollectionCell
            
            let screenWidth = self.view.bounds.width
            cell.profileController = self
            cell.currentPicture = currentPicture
            cell.loadImages(userData, screenWidth: screenWidth)
            return cell
            
        }  else if indexPath.row == 2 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("nameCell", forIndexPath: indexPath) as! ProfileInfoCollectionCell
            
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
            
        } else if indexPath.row == 3 {
            
            if selfProfile {
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("selfRankSquadCell", forIndexPath: indexPath)
                    as! SelfSquadRankCell
                
                cell.profileController = self
                cell.loadData(userData)
                return cell
                
            } else {
                
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("notSelfRankSquadCell", forIndexPath: indexPath) as! NotSelfSquadRankCell
                
                cell.profileController = self
                cell.loadData(userData)
                
                return cell
                
            }
            
        } else if !selfProfile && indexPath.row == 4 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("activeDistanceCell", forIndexPath: indexPath) as! ActiveDistanceCell
            cell.profileController = self
            cell.loadData(userData)
            return cell
            
        } else {
            
            var index = indexPath.row
            
            if selfProfile {
                
                index -= 4
                
            } else {
                
                index -= 5
                
            }
            
            if let isImage = userPosts[index]["isImage"] as? Bool{
                
                if isImage {
                    
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userImagePostCell", forIndexPath: indexPath) as! UserImagePostCell
                    
                    cell.profileController = self
                    
                    print("User post count : \(userPosts.count)")
                    print("Index: \(index)")
                    cell.posts = userPosts
                    cell.index = index
                    cell.loadCell(userPosts[index])
                    
                    return cell
                    
                } else {
                    
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userVideoPostCell", forIndexPath: indexPath) as! UserVideoPostCell
                    
                    cell.profileController = self
                    
                    cell.loadCell(userPosts[index])
                    
                    cell.posts = userPosts
                    cell.index = index
                    
                    cell.imageOutlet.layer.cornerRadius = 10
                    cell.imageOutlet.clipsToBounds = true
                    cell.videoOutlet.layer.cornerRadius = 10
                    cell.videoOutlet.clipsToBounds = true
                    
                    
                    if let videoURLString = userPosts[index]["videoURL"] as? String, url = NSURL(string: videoURLString), imageUrlString = userPosts[index]["imageURL"] as? String, imageUrl = NSURL(string: imageUrlString) {
                        
                        cell.imageOutlet.sd_setImageWithURL(imageUrl, completed: { (image, error, cache, url) in
                            
                            print("done loading video thumbnail")
                            
                        })

                        if let key = userPosts[index]["postChildKey"] as? String {
                            
                            if let player = videoPlayers[key] {
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    if let videoPlayerView = player.view {
                                        
                                        self.addChildViewController(player)
                                        player.didMoveToParentViewController(self)
                                        player.playFromCurrentTime()
                                        videoPlayerView.removeFromSuperview()
                                        cell.videoOutlet.addSubview(videoPlayerView)
                                        cell.videoOutlet.alpha = 1
                                        
                                    }
                                })
                                
                            } else {
                                
                                cell.createIndicator()
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    let scopePlayer = Player()
                                    scopePlayer.delegate = self
                                    
                                    self.addChildViewController(scopePlayer)
                                    scopePlayer.view.frame = cell.videoOutlet.bounds
                                    scopePlayer.didMoveToParentViewController(self)
                                    scopePlayer.setUrl(url)
                                    scopePlayer.fillMode = AVLayerVideoGravityResizeAspectFill
                                    scopePlayer.playbackLoops = true
                                    scopePlayer.playFromCurrentTime()
                                    
                                    if let videoPlayerView = scopePlayer.view {
                                        
                                        cell.videoOutlet.addSubview(videoPlayerView)
                                        cell.videoOutlet.alpha = 1
                                    }
                                    
                                    self.videoPlayers[key] = scopePlayer
                                    
                                })
                            }
                        }
                        
                        return cell
 
                    }
                }
            }
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userImagePostCell", forIndexPath: indexPath) as! UserImagePostCell
        return cell
        
    }
    
        
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            let width = self.view.bounds.width
            
            if indexPath.row == 0 {
                
                if let status = userData["currentStatus"] as? String {
                    
                    if status != "" {
                        
                        return CGSize(width: width, height: 30)
                        
                    }
                }
                
                return CGSize(width: width, height: 0)
                
            } else if indexPath.row == 1 {
                
                return CGSize(width: width, height: width)
                
                
            } else if indexPath.row == 2 {
                
                if let occupation = userData["occupation"] as? String {
                    
                    if occupation != "" {
                        
                        return CGSize(width: width, height: 85)
                        
                    }
                }
                
                return CGSize(width: width, height: 67)
                
            } else if indexPath.row == 3  {
                
                return CGSize(width: width, height: 50)
                
            } else if indexPath.row == 4 && !selfProfile {
                
                return CGSize(width: width, height: 34)
                
            } else {
                
                let thirdWidth = width * 0.33
                return CGSize(width: thirdWidth, height: thirdWidth)
                
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            addUploadStuff()
            // Do any additional setup after loading the view.
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            
            self.videoPlayers.removeAll()
            
            SDWebImageManager.sharedManager().imageCache.clearMemory()
            
            
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
