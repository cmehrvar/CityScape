//
//  HandlePostController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-07-01.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation
import AWSS3
import AWSCore
import AWSCognito
import Firebase
import FirebaseDatabase
import FirebaseAuth

class HandlePostController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    weak var rootController: MainRootController?
    
    var userSelected = [String : Int]()
    
    var squad = [[NSObject : AnyObject]]()
    var selectedSquad = [[NSObject : AnyObject]]()
    var dataSourceForSearchResult = [[NSObject : AnyObject]]()
    
    var searchBarActive = false
    
    var shouldUpload = false
    
    //Global Variables
    var postToFeedSelected = true
    var isImage = true
    var image: UIImage!
    var videoURL: NSURL!
    var exportedVideoURL: NSURL!
    var scale: CGFloat?
    
    var asset: AVAsset?
    var item: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    
    //Outlets
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var videoOutlet: UIView!
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareOutlet: UIButton!
    @IBOutlet weak var uploadingViewOutlet: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var charactersLeftOutlet: UILabel!
    @IBOutlet weak var postToFeedLabelOutlet: UILabel!
    @IBOutlet weak var postToFeedViewOutlet: UIView!
    @IBOutlet weak var dismissKeyboardView: UIView!
    
    @IBOutlet weak var globTableViewOutlet: UITableView!
    
    @IBOutlet weak var contentHeightOutlet: NSLayoutConstraint!
    
    func keyboardShown(){
        
        dismissKeyboardView.alpha = 1
        
    }
    
    
    func keyboardHid(){
        
        dismissKeyboardView.alpha = 0
        
    }
    
    
    func setPostToYes(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardShown), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHid), name: UIKeyboardWillHideNotification, object: nil)
        
        shareOutlet.enabled = true
        postToFeedLabelOutlet.text = "YES"
        postToFeedLabelOutlet.textColor = UIColor.whiteColor()
        postToFeedViewOutlet.backgroundColor = UIColor.redColor()
        postToFeedSelected = true
        
    }
    
    
    func togglePostToFeed(){
        
        if postToFeedSelected {
            
            postToFeedLabelOutlet.text = "NO"
            postToFeedLabelOutlet.textColor = UIColor.blackColor()
            postToFeedViewOutlet.backgroundColor = UIColor.lightGrayColor()
            
            if selectedSquad.count == 0 {
                
                shareOutlet.enabled = false
                
            } else {
                
                shareOutlet.enabled = true
                
            }
            
        } else {
            
            shareOutlet.enabled = true
            postToFeedLabelOutlet.text = "YES"
            postToFeedLabelOutlet.textColor = UIColor.whiteColor()
            postToFeedViewOutlet.backgroundColor = UIColor.redColor()
            
        }
        
        
        
        
        postToFeedSelected = !postToFeedSelected
        
    }
    
    //Functions
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            
            self.searchBarActive = true
            
            self.filterContentForSearchText(searchText)
            
            globTableViewOutlet.reloadData()
            
        } else {
            
            self.searchBarActive = false
            
            globTableViewOutlet.reloadData()
            
        }
    }
    
    func filterContentForSearchText(searchText: String){
        
        dataSourceForSearchResult = squad.filter({ (user: [NSObject : AnyObject]) -> Bool in
            
            if let firstName = user["firstName"] as? String, lastName = user["lastName"] as? String {
                
                let name = firstName + " " + lastName
                
                return name.containsString(searchText)
                
            } else {
                
                return false
            }
        })
    }
    
    func loadTableView(){
        
        var scopeSquad = [[NSObject : AnyObject]]()
        
        if let selfData = rootController?.selfData, mySquad = selfData["squad"] as? [NSObject : AnyObject] {
            
            for (_, value) in mySquad {
                
                if let valueToAdd = value as? [NSObject : AnyObject] {
                    
                    scopeSquad.append(valueToAdd)
                    
                }
            }
        }
        
        scopeSquad.sortInPlace { (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
            
            if a["lastName"] as? String > b["lastName"] as? String {
                
                return false
                
            } else {
                
                return true
                
            }
        }
        
        self.squad = scopeSquad
        self.globTableViewOutlet.reloadData()
        
    }
    
    
    
    
    //TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            return dataSourceForSearchResult.count
            
        } else {
            
            return squad.count
            
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("sendPostSquadCell", forIndexPath: indexPath) as! SendPostSquadCell
        
        cell.handleController = self
        
        if searchBarActive {
            
            cell.loadData(dataSourceForSearchResult[indexPath.row])
            
        } else {
            
            cell.loadData(squad[indexPath.row])
            
        }
        
        return cell
    }
    
    
    
    
    //Actions
    @IBAction func postToFeed(sender: AnyObject) {
        
        togglePostToFeed()
        
        
    }
    
    
    @IBAction func backButton(sender: AnyObject) {
        
        shouldUpload = false
        uploadingViewOutlet.alpha = 0
        
        clearPlayers()
        
        if isImage {
            
            let editor = AdobeUXImageEditorViewController(image: image)
            editor.delegate = rootController?.actionsController
            
            rootController?.actionsController?.presentViewController(editor, animated: false, completion: {
                
                self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: true, completion: { (bool) in
                    
                    print("handle post toggled")
                    
                })
            })
            
        } else {
            
            self.rootController?.cameraTransitionOutlet.alpha = 1
            self.rootController?.actionsController?.presentFusumaCamera()
            
            self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: true, completion: { (bool) in
                
                print("handle post toggled")
                
            })
        }
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        
        
        
        shareOutlet.enabled = false
        
        if isImage {
            
            uploadPost(image, videoURL: nil, isImage: isImage)
            
        } else {
            
            uploadPost(image, videoURL: exportedVideoURL, isImage: isImage)
            
        }
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "rate" {
            
            if let player = object as? AVPlayer, item = player.currentItem {
                
                if CMTimeGetSeconds(player.currentTime()) == CMTimeGetSeconds(item.duration) {
                    
                    player.seekToTime(kCMTimeZero)
                    player.play()
                    
                } else if player.rate == 0 {
                    
                    player.play()
                    
                }
            }
        }
    }
    
    //Functions
    func handleCall(){
        
        handleContent()
        
        if !isImage {
            
            shareOutlet.enabled = false
            convertVideoToLowQualityWithInputURL(videoURL, handler: { (exportSession, outputURL) in
                
                if exportSession.status == .Completed {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.shareOutlet.enabled = true
                        self.exportedVideoURL = outputURL
                        
                    })
                    
                    
                    print("good convert")
                    
                } else {
                    
                    print("bad convert")
                    
                }
                
            })
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewDidAppear(true)
        
    }
    
    //Functions
    func handleContent() {
        
        if isImage {
            
            if let actualImage = image {
                imageOutlet.image = actualImage
            } else {
                imageOutlet.image = nil
            }
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.asset = AVAsset(URL: self.videoURL)
                
                if let asset = self.asset {
                    
                    self.item = AVPlayerItem(asset: asset)
                    
                    if let item = self.item {
                        
                        self.player = AVPlayer(playerItem: item)
                        
                    }
                    
                    if let player = self.player {
                        
                        player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                        
                        self.playerLayer = AVPlayerLayer(player: player)
                        
                        if let layer = self.playerLayer {
                            
                            layer.frame = self.videoOutlet.bounds
                            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            
                            self.videoOutlet.layer.addSublayer(layer)
                            self.videoOutlet.alpha = 1
                            
                            player.play()
                        }
                    }
                }
                
                print("video downloaded!")
                
            })
        }
    }
    
    
    func setToFirebase(imageUrl: String?, caption: String?, FIRVideoURL: String?){

        self.clearPlayers()
        
        if let userData = self.rootController?.selfData, selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let currentDate = NSDate().timeIntervalSince1970
            
            if let firstName = userData["firstName"] as? String, lastName = userData["lastName"] as? String, city = userData["city"] as? String, longitude = userData["longitude"] as? CLLocationDegrees, latitude = userData["latitude"] as? CLLocationDegrees, state = userData["state"] as? String {
                
                if shouldUpload {
                    
                    let ref = FIRDatabase.database().reference()
                    
                    let postChildKey = ref.child("posts").child(city).childByAutoId().key
                    
                    var postData: [NSObject:AnyObject] = ["userUID":selfUID, "firstName":firstName, "lastName":lastName, "city":city, "timeStamp":currentDate, "isImage":isImage, "postChildKey":postChildKey]
                    
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
                    
                    if postToFeedSelected {
                        
                        ref.child("posts").child(city).child(postChildKey).updateChildValues(postData)
                        ref.child("allPosts").child(postChildKey).updateChildValues(postData)
                        ref.child("users").child(selfUID).child("posts").child(postChildKey).updateChildValues(postData)
                        
                        ref.child("cityLocations").child(city).updateChildValues(["mostRecentPost" : postData, "latitude" : latitude, "longitude" : longitude, "city" : city, "state" : state])
                        
                    }
                    
                    if selectedSquad.count > 0 {
                        
                        for member in selectedSquad {
                            
                            if let uid = member["uid"] as? String {
                                
                                var messageItem: [NSObject : AnyObject] = [
                                    
                                    "senderId" : selfUID,
                                    "timeStamp" : currentDate,
                                    "senderDisplayName" : firstName + " " + lastName,
                                    
                                    "isMedia" : true,
                                    
                                    "userUID" : uid
                                    
                                ]
                                
                                var notificationItem = [NSObject : AnyObject]()
                                
                                if let url = FIRVideoURL {
                                    
                                    notificationItem["text"] = "Sent Video!"
                                    
                                    let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
                                    
                                    messageItem["media"] = url
                                    messageItem["key"] = fileName
                                    messageItem["text"] = "Sent a video!"
                                    messageItem["isImage"] = false
                                    
                                } else if let url = imageUrl {
                                    
                                    notificationItem["text"] = "Sent Photo!"
                                    
                                    let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
                                    
                                    messageItem["media"] = url
                                    messageItem["key"] = fileName
                                    messageItem["text"] = "Sent a photo!"
                                    messageItem["isImage"] = true
                                    
                                }
                                
                                if let firstName = self.rootController?.selfData["firstName"] as? String, lastName = self.rootController?.selfData["lastName"] as? String {
                                    
                                    notificationItem["firstName"] = firstName
                                    notificationItem["lastName"] = lastName
                                    
                                    messageItem["firstName"] = firstName
                                    messageItem["lastName"] = lastName
                                    
                                }
                                
                                notificationItem["read"] = false
                                notificationItem["timeStamp"] = currentDate
                                notificationItem["type"] = "squad"
                                notificationItem["uid"]  = selfUID
                                
                                let ref = FIRDatabase.database().reference()
                                
                                ref.child("users").child(selfUID).child("squad").child(uid).child("messages").childByAutoId().setValue(messageItem)
                                ref.child("users").child(selfUID).child("squad").child(uid).child("read").setValue(false)
                                ref.child("users").child(selfUID).child("squad").child(uid).child("lastActivity").setValue(currentDate)
                                
                                ref.child("users").child(uid).child("squad").child(selfUID).child("lastActivity").setValue(currentDate)
                                ref.child("users").child(uid).child("squad").child(selfUID).child("messages").childByAutoId().setValue(messageItem)
                                ref.child("users").child(uid).child("squad").child(selfUID).child("read").setValue(false)
                                
                                ref.child("users").child(uid).child("notifications").child(selfUID).child("squad").setValue(notificationItem)
                                
                            }
                        }
                    }
                }
                
                rootController?.vibesFeedController?.globCollectionView.contentOffset = CGPointZero
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: false, completion: { (bool) in
                        
                        self.uploadingViewOutlet.alpha = 0
                        self.shareOutlet.enabled = true
                        print("handle closed")
                        
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
    
    
    func uploadPost(image: UIImage!, videoURL: NSURL!, isImage: Bool) {
        
        var captionString = ""
        self.view.endEditing(true)
        shouldUpload = true
        
        //HANDLE CAPTION
        if let text = captionTextView.text {
            captionString = text
        }
        
        
        UIView.animateWithDuration(0.3) {
            self.uploadingViewOutlet.alpha = 1
        }
        
        self.imageUploadRequest(image) { (imageUrl, imageUploadRequest) in
            
            let imageTransferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            imageTransferManager.upload(imageUploadRequest).continueWithBlock { (task) -> AnyObject? in
                
                if task.error == nil {
                    
                    print("successful image upload")
                    
                    if self.shouldUpload {
                        
                        if !isImage {
                            
                            self.videoUploadRequest(videoURL, completion: { (FIRVideoURL, videoUploadRequest) in
                                
                                let videoTransferManager = AWSS3TransferManager.defaultS3TransferManager()
                                
                                videoTransferManager.upload(videoUploadRequest).continueWithBlock({ (task) -> AnyObject? in
                                    
                                    print("save thumbnail & video to firebase")
                                    
                                    self.setToFirebase(imageUrl, caption: captionString, FIRVideoURL: FIRVideoURL)
                                    
                                    return nil
                                })
                            })
                            
                        } else {
                            
                            print("save image only to firebase")
                            
                            self.setToFirebase(imageUrl, caption: captionString, FIRVideoURL: nil)
                            
                        }
                        
                    } else {
                        print("error uploading: \(task.error)")
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                    
                    
                }
                
                
                return nil
            }
        }
    }
    
    
    
    
    func videoUploadRequest(videoURL: NSURL?, completion: (url: String, uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = videoURL
            uploadRequest.key = fileName
            uploadRequest.bucket = "cityscapebucket"
            
            let amazonVideoURL = "https://s3.amazonaws.com/cityscapebucket/" + fileName
            
            completion(url: amazonVideoURL, uploadRequest: uploadRequest)
            
        }
    }
    
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
    
    
    //Functions
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
    func addDismissKeyboard() {
        
        let dismissKeyboardGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardView.addGestureRecognizer(dismissKeyboardGesture)
        
    }
    
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    
    func clearPlayers(){
        
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        userSelected.removeAll()
        selectedSquad.removeAll()
        squad.removeAll()
        dataSourceForSearchResult.removeAll()
        
        self.globTableViewOutlet.reloadData()
        
        captionTextView.text = nil
        charactersLeftOutlet.text = "0/30 Characters"
        
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
    
    //TextView Delegates
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y > 1 {
            
            print("up")
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.contentHeightOutlet.constant = 0
                self.view.layoutIfNeeded()
                
            })
            
            
        } else if velocity.y < -1 {
            
            print("down")
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.contentHeightOutlet.constant = 132
                self.view.layoutIfNeeded()
                
            })
            
        }
    }
    
    
    func textViewDidChange(textView: UITextView) {
        
        let textCount = textView.text.characters.count
        charactersLeftOutlet.text = "\(textCount)/30 Characters"
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            return false
            
        }
        
        return textView.text.characters.count + (text.characters.count - range.length) <= 30
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postToFeedViewOutlet.layer.cornerRadius = 5
        captionTextView.layer.cornerRadius = 10
        captionTextView.text = nil
        charactersLeftOutlet.text = "0/30 Characters"
        
        shareOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        shareOutlet.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        
        addUploadStuff()
        addDismissKeyboard()
        
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
