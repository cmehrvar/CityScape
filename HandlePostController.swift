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
import FBSDKShareKit

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


class HandlePostController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FBSDKSharingDelegate {
    
    weak var rootController: MainRootController?

    var squad = [[AnyHashable: Any]]()
    var selectedSquad = [AnyHashable: Any]()
    var dataSourceForSearchResult = [[AnyHashable: Any]]()
    
    var searchBarActive = false
    
    
    var shouldUpload = false
    
    //Global Variables
    var postToFacebookSelected = false
    var postToFeedSelected = true
    var isImage = true
    var image: UIImage!
    var videoURL: URL!
    var exportedVideoURL: URL!
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
    
    @IBOutlet weak var postToCurrentCityOutlet: UILabel!
    
    @IBOutlet weak var postToFacebookLabelOutlet: UILabel!
    
    @IBOutlet weak var globTableViewOutlet: UITableView!
    
    @IBOutlet weak var contentHeightOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var facebookButtonViewOutlet: UIView!

    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
        print("canceled")
        
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        
        print(error)
        
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        
        if postToFeedSelected || selectedSquad.count > 0 {
            
            if self.isImage {
                
                self.uploadPost(self.image, videoURL: nil, isImage: self.isImage)
                
            } else {
                
                self.uploadPost(self.image, videoURL: self.exportedVideoURL, isImage: self.isImage)
                
            }
            
        } else {
            
            DispatchQueue.main.async(execute: {
                
                self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: false, completion: { (bool) in
                    
                    self.uploadingViewOutlet.alpha = 0
                    self.shareOutlet.isEnabled = true
                    print("handle closed")
                    
                })
                
                self.rootController?.toggleVibes({ (bool) in
 
                    self.clearPlayers()
                    self.rootController?.vibesFeedController?.observeCurrentCityPosts()

                    print("vibes toggled")
                    
                })
            })
        }
    }

    func keyboardShown(){
        
        dismissKeyboardView.alpha = 1
        
    }
    
    
    func keyboardHid(){
        
        dismissKeyboardView.alpha = 0
        
    }
    
    
    @IBAction func setFacebookToYes(_ sender: AnyObject) {
        
        if postToFacebookSelected {
            
            postToFacebookLabelOutlet.text = "NO"
            facebookButtonViewOutlet.backgroundColor = UIColor.lightGray
            
            if selectedSquad.count == 0 && !postToFeedSelected {
                
                shareOutlet.isEnabled = false
                
            } else {
                
                shareOutlet.isEnabled = true
                
            }
            
        } else {
            
            shareOutlet.isEnabled = true
            postToFacebookLabelOutlet.text = "YES"
            facebookButtonViewOutlet.backgroundColor = UIColor(netHex: 0x3b5998)
            
        }
        
        postToFacebookSelected = !postToFacebookSelected
        
    }
    
    
    func setPostToYes(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHid), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        shareOutlet.isEnabled = true
        postToFeedLabelOutlet.text = "YES"
        postToFeedLabelOutlet.textColor = UIColor.white
        postToFeedViewOutlet.backgroundColor = UIColor.red
        postToFeedSelected = true
        
    }
    
    
    func togglePostToFeed(){
        
        if postToFeedSelected {
            
            postToFeedLabelOutlet.text = "NO"
            postToFeedLabelOutlet.textColor = UIColor.black
            postToFeedViewOutlet.backgroundColor = UIColor.lightGray
            
            if selectedSquad.count == 0 && !postToFacebookSelected {
                
                shareOutlet.isEnabled = false
                
            } else {
                
                shareOutlet.isEnabled = true
                
            }
            
        } else {
            
            shareOutlet.isEnabled = true
            postToFeedLabelOutlet.text = "YES"
            postToFeedLabelOutlet.textColor = UIColor.white
            postToFeedViewOutlet.backgroundColor = UIColor.red
            
        }
        
        
        
        
        postToFeedSelected = !postToFeedSelected
        
    }
    
    //Functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            
            self.searchBarActive = true
            
            self.filterContentForSearchText(searchText)
            
            globTableViewOutlet.reloadData()
            
        } else {
            
            self.searchBarActive = false
            
            globTableViewOutlet.reloadData()
            
        }
    }
    
    func filterContentForSearchText(_ searchText: String){
        
        dataSourceForSearchResult = squad.filter({ (user: [AnyHashable: Any]) -> Bool in
            
            if let firstName = user["firstName"] as? String, let lastName = user["lastName"] as? String {
                
                let name = firstName + " " + lastName
                
                return name.contains(searchText)
                
            } else {
                
                return false
            }
        })
    }
    
    func loadTableView(){
        
        var scopeSquad = [[AnyHashable: Any]]()
        
        if let selfData = rootController?.selfData, let mySquad = selfData["squad"] as? [AnyHashable: Any] {
            
            for (_, value) in mySquad {
                
                if let valueToAdd = value as? [AnyHashable: Any] {
                    
                    scopeSquad.append(valueToAdd)
                    
                }
            }
        }
        
        scopeSquad.sort { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
            
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            return dataSourceForSearchResult.count
            
        } else {
            
            return squad.count
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sendPostSquadCell", for: indexPath) as! SendPostSquadCell
        
        cell.handleController = self
        
        if searchBarActive {
            
            cell.loadData(dataSourceForSearchResult[(indexPath as NSIndexPath).row])
            
        } else {
            
            cell.loadData(squad[(indexPath as NSIndexPath).row])
            
        }
        
        return cell
    }
    
    
    
    
    //Actions
    @IBAction func postToFeed(_ sender: AnyObject) {
        
        togglePostToFeed()
        
        
    }
    
    
    @IBAction func backButton(_ sender: AnyObject) {
        
        shouldUpload = false
        uploadingViewOutlet.alpha = 0
        
        clearPlayers()
        
        if isImage {
            
            let editor = AdobeUXImageEditorViewController(image: image)
            editor.delegate = rootController?.actionsController
            
            rootController?.actionsController?.present(editor, animated: false, completion: {
                
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
    
    @IBAction func shareAction(_ sender: AnyObject) {
        
        self.shareOutlet.isEnabled = false
        
        if postToFacebookSelected {
            
            if isImage {

                if let selfImage = self.image, let photo = FBSDKSharePhoto(image: selfImage, userGenerated: true) {
                    
                    let content = FBSDKSharePhotoContent()
                    content.photos = [photo]
                    FBSDKShareDialog.show(from: self, with: content, delegate: self)
      
                }
  
            } else {
                
                if let url = self.exportedVideoURL, let video = FBSDKShareVideo(videoURL: url) {
                    
                    let content = FBSDKShareVideoContent()
                    content.video = video
                    FBSDKShareDialog.show(from: self, with: content, delegate: self)
                    
                }
            }

        } else {
            
            if self.isImage {
                
                self.uploadPost(self.image, videoURL: nil, isImage: self.isImage)
                
            } else {
                
                self.uploadPost(self.image, videoURL: self.exportedVideoURL, isImage: self.isImage)
                
            }
        }
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
    
    //Functions
    func handleCall(){
        
        handleContent()
        
        if !isImage {
            
            shareOutlet.isEnabled = false
            convertVideoToLowQualityWithInputURL(videoURL, handler: { (exportSession, outputURL) in
                
                if exportSession.status == .completed {
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.shareOutlet.isEnabled = true
                        self.exportedVideoURL = outputURL
                        
                    })
                    
                    
                    print("good convert")
                    
                } else {
                    
                    print("bad convert")
                    
                }
                
            })
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
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
            
            DispatchQueue.main.async(execute: {
                
                self.asset = AVAsset(url: self.videoURL)
                
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
    
    
    func setToFirebase(_ imageUrl: String?, caption: String?, FIRVideoURL: String?, scopeSelectedSquad: [AnyHashable: Any]){

        if let userData = self.rootController?.selfData, let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let currentDate = Date().timeIntervalSince1970
            
            if let firstName = userData["firstName"] as? String, let lastName = userData["lastName"] as? String, let city = userData["city"] as? String, let longitude = userData["longitude"] as? CLLocationDegrees, let latitude = userData["latitude"] as? CLLocationDegrees, let state = userData["state"] as? String {
                
                if shouldUpload {
                    
                    let ref = FIRDatabase.database().reference()
                    
                    let postChildKey = ref.child("posts").child(city).childByAutoId().key
                    
                    var postData: [AnyHashable: Any] = ["userUID":selfUID, "firstName":firstName, "lastName":lastName, "city":city, "timeStamp":currentDate, "isImage":isImage, "postChildKey":postChildKey]
                    
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
                    
                    if scopeSelectedSquad.count > 0 {
                        
                        for (_, value) in scopeSelectedSquad {
                            
                            if let member = value as? [AnyHashable: Any] {
                                
                                if let uid = member["uid"] as? String {
                                    ref.child("users").child(uid).child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                            
                                            if FIRVideoURL != nil {
                                                
                                                appDelegate.pushMessage(uid: uid, token: token, message: "\(firstName) \(lastName): Sent a video!")
                                                
                                            } else if imageUrl != nil {
                                                
                                                appDelegate.pushMessage(uid: uid, token: token, message: "\(firstName) \(lastName): Sent a photo!")
                                                
                                                
                                            }
                                        }
                                    })
                                    
                                    var messageItem: [AnyHashable: Any] = [
                                        
                                        "senderId" : selfUID,
                                        "timeStamp" : currentDate,
                                        "senderDisplayName" : firstName + " " + lastName,
                                        
                                        "isMedia" : true,
                                        
                                        "userUID" : uid
                                        
                                    ]
                                    
                                    var notificationItem = [AnyHashable: Any]()
                                    
                                    if let url = FIRVideoURL {
                                        
                                        notificationItem["text"] = "Sent Video!"
                                        
                                        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".mov"
                                        
                                        messageItem["media"] = url
                                        messageItem["key"] = fileName
                                        messageItem["text"] = "Sent a video!"
                                        messageItem["isImage"] = false
                                        
                                    } else if let url = imageUrl {
                                        
                                        notificationItem["text"] = "Sent Photo!"
                                        
                                        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".jpeg"
                                        
                                        messageItem["media"] = url
                                        messageItem["key"] = fileName
                                        messageItem["text"] = "Sent a photo!"
                                        messageItem["isImage"] = true
                                        
                                    }
                                    
                                    if let firstName = self.rootController?.selfData["firstName"] as? String, let lastName = self.rootController?.selfData["lastName"] as? String {
                                        
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
                }
                
                rootController?.vibesFeedController?.globCollectionView.contentOffset = CGPoint.zero
                
                DispatchQueue.main.async(execute: {
                    
                    self.rootController?.toggleHandlePost(nil, videoURL: nil, isImage: false, completion: { (bool) in
                        
                        self.uploadingViewOutlet.alpha = 0
                        self.shareOutlet.isEnabled = true
                        print("handle closed")
                        
                    })
                    
                    self.rootController?.toggleVibes({ (bool) in
    
                        self.rootController?.vibesFeedController?.currentCity = city
                        self.rootController?.vibesFeedController?.observeCurrentCityPosts()
                        self.clearPlayers()
                        
                        print("vibes toggled")
                        
                    })
                })
            }
        }
    }
    
    
    func uploadPost(_ image: UIImage!, videoURL: URL!, isImage: Bool) {
        
        let scopeSelectedSquad = selectedSquad
        
        var captionString = ""
        self.view.endEditing(true)
        shouldUpload = true
        
        //HANDLE CAPTION
        if let text = captionTextView.text {
            captionString = text
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
            self.uploadingViewOutlet.alpha = 1
        }) 
        
        self.imageUploadRequest(image) { (imageUrl, imageUploadRequest) in
            
            let imageTransferManager = AWSS3TransferManager.default()
            
            imageTransferManager?.upload(imageUploadRequest).continue({ (task) -> Any? in
                
                if task.error == nil {
                    
                    print("successful image upload")
                    
                    if self.shouldUpload {
                        
                        if !isImage {
                            
                            self.videoUploadRequest(videoURL, completion: { (FIRVideoURL, videoUploadRequest) in
                                
                                let videoTransferManager = AWSS3TransferManager.default()
                                
                                videoTransferManager?.upload(videoUploadRequest).continue({ (task) -> AnyObject? in
                                    
                                    print("save thumbnail & video to firebase")
                                    
                                    self.setToFirebase(imageUrl, caption: captionString, FIRVideoURL: FIRVideoURL, scopeSelectedSquad: scopeSelectedSquad)


                                    return nil
                                })
                            })
                            
                        } else {
                            
                            print("save image only to firebase")
                            
                            self.setToFirebase(imageUrl, caption: captionString, FIRVideoURL: nil, scopeSelectedSquad: scopeSelectedSquad)

                        }
                        
                    } else {
                        print("error uploading: \(task.error)")
                        
                        let alertController = UIAlertController(title: "Sorry", message: "Error uploading profile picture, please try again later", preferredStyle:  UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                }
                
                return nil
                
            })
        }
    }
    
    
    
    
    func videoUploadRequest(_ videoURL: URL?, completion: @escaping (_ url: String, _ uploadRequest: AWSS3TransferManagerUploadRequest) -> ()) {
        
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".mov"
        
        DispatchQueue.main.async {
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.body = videoURL
            uploadRequest?.key = fileName
            uploadRequest?.bucket = "cityscapebucket"
            
            let amazonVideoURL = "https://s3.amazonaws.com/cityscapebucket/" + fileName
            
            completion(amazonVideoURL, uploadRequest!)
            
        }
    }
    
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
    
    
    //Functions
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
    func addUploadStuff(){
        
        let error = NSErrorPointer.init(nilLiteral: ())
        
        do{
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error?.pointee = error1
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)

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
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y > 1 {
            
            print("up")
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.contentHeightOutlet.constant = 0
                self.view.layoutIfNeeded()
                
            })
            
            
        } else if velocity.y < -1 {
            
            print("down")
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.contentHeightOutlet.constant = 132
                self.view.layoutIfNeeded()
                
            })
            
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        let textCount = textView.text.characters.count
        charactersLeftOutlet.text = "\(textCount)/30 Characters"
        
    }
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            textView.resignFirstResponder()
            return false
            
        }
        
        return textView.text.characters.count + (text.characters.count - range.length) <= 30
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postToCurrentCityOutlet.adjustsFontSizeToFitWidth = true
        
        facebookButtonViewOutlet.layer.cornerRadius = 5
        postToFeedViewOutlet.layer.cornerRadius = 5
        captionTextView.layer.cornerRadius = 10
        captionTextView.text = nil
        charactersLeftOutlet.text = "0/30 Characters"
        
        shareOutlet.setTitleColor(UIColor.white, for: UIControlState())
        shareOutlet.setTitleColor(UIColor.lightGray, for: .disabled)
        
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
