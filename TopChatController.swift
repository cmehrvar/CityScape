//
//  TopChatController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-24.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import NYAlertViewController
import SDWebImage
import Fusuma
import AWSS3
import AVFoundation

class TopChatController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, FusumaDelegate {
    
    var asset: AVAsset?
    var item: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    weak var rootController: MainRootController?
    var type = ""
    
    @IBOutlet weak var settingIconOutlet: UIImageView!
    @IBOutlet weak var settingsButtonOutlet: UIButton!
    
    
    //SingleChat
    @IBOutlet weak var profilePicOutlet: TopChatProfileView!
    @IBOutlet weak var iconOutlet: UIImageView!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var singleTitleViewOutlet: UIView!
    
    //GroupChat
    @IBOutlet weak var globCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var squadMembersTitleOutlet: UILabel!
    @IBOutlet weak var groupTopViewOutlet: UIView!
    @IBOutlet weak var chatTitleOutlet: UILabel!
    @IBOutlet weak var groupPhotoOutlet: TopChatProfileView!
    
    //Posts
    @IBOutlet weak var postProfileOutlet: TopChatProfileView!
    @IBOutlet weak var postNameOutlet: UILabel!
    @IBOutlet weak var postCityOutlet: UILabel!
    @IBOutlet weak var postCaptionOutlet: UILabel!
    @IBOutlet weak var postImageOutlet: UIImageView!
    @IBOutlet weak var postVideoOutlet: UIView!
    @IBOutlet weak var postTopViewOutlet: UIView!
    
    //Player Delegates
    
    //POSTS!!!!
    var postkey = ""
    var postCity = ""
    
    
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
    
    var postURL = ""

    func loadPost(){
        
        self.postVideoOutlet.alpha = 0
        self.type = "posts"
        let scopeKey = postkey
        let scopeCity = postCity
        
        postCaptionOutlet.adjustsFontSizeToFitWidth = true
        postCaptionOutlet.baselineAdjustment = .alignCenters
        postNameOutlet.adjustsFontSizeToFitWidth = true
        postNameOutlet.baselineAdjustment = .alignCenters

        let ref = FIRDatabase.database().reference().child("posts").child(scopeCity).child(scopeKey)
        
        ref.child("imageURL").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if self.postkey == scopeKey {
                
                if let imageString = snapshot.value as? String, let url = URL(string: imageString) {
                    
                    self.postURL = imageString
                    self.postImageOutlet.sd_setImage(with: url, placeholderImage: nil)
                    
                }
            }
        })
        
        ref.child("firstName").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let firstName = snapshot.value as? String {
                
                ref.child("lastName").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let lastName = snapshot.value as? String {
                        
                        self.firstName = firstName
                        self.lastName = lastName
                        
                        let name = firstName + " " + lastName
                        self.postNameOutlet.text = name
                        
                    }
                })
            }
        })
        
        ref.child("userUID").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let uid = snapshot.value as? String {
                
                self.uid = uid
                
                let userRef = FIRDatabase.database().reference().child("users").child(uid)
                
                userRef.child("profilePicture").observe(.value, with: { (snapshot) in
                    
                    if self.postkey == scopeKey {
                        
                        if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                            
                            self.postProfileOutlet.sd_setImage(with: url, placeholderImage: nil)
                            
                        }
                        
                    } else {
                        
                        userRef.removeAllObservers()
                        
                    }
                })
            }
        })
        
        ref.child("caption").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if self.postkey == scopeKey {
                
                if let caption = snapshot.value as? String {
                    
                    self.postCaptionOutlet.text = caption
                    
                }
            }
        })
        
        
        ref.child("state").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if self.postkey == scopeKey {
                
                if let state = snapshot.value as? String {
                    
                    self.postCityOutlet.text = scopeCity + ", " + state
                    
                }
            }
        })
        
        
        ref.child("isImage").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let isImage = snapshot.value as? Bool {
                
                if self.postkey == scopeKey {
                    
                    if !isImage {
                        
                        ref.child("videoURL").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let urlString = snapshot.value as? String, let url = URL(string: urlString) {
                                
                                DispatchQueue.main.async(execute: {

                                    self.asset = AVAsset(url: url)
                                    
                                    if let asset = self.asset {
                                        
                                        self.item = AVPlayerItem(asset: asset)
 
                                        if let item = self.item {
                                            
                                            self.player = AVPlayer(playerItem: item)
                                            
                                        }
                                        
                                        if let player = self.player {
                                            
                                            player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                                            
                                            self.playerLayer = AVPlayerLayer(player: player)
                                            
                                            if let layer = self.playerLayer {
                                                
                                                layer.frame = self.postVideoOutlet.bounds
                                                layer.videoGravity = AVLayerVideoGravityResizeAspectFill

                                                self.postVideoOutlet.layer.addSublayer(layer)
                                                self.postVideoOutlet.alpha = 1
                                                
                                                player.play()
                                            }
                                        }
                                    }
   
                                    print("video downloaded!")
                                    
                                })
                            }
                        })
                    }
                }
            }
        })
    }
    
    
    //GROUP CHAT!!!!!!
    var globAlertController: NYAlertViewController?
    var groupPicture: String?
    var chatKey = ""
    var collectionViewMembers = [String]()
    var members = [String]()
    
    func loadGroup(){
        
        self.type = "groupChats"
        
        let scopeKey = chatKey
        
        let ref = FIRDatabase.database().reference().child("groupChats").child(scopeKey)
        
        ref.child("title").observe(.value, with: { (snapshot) in
            
            if scopeKey == self.chatKey {
                
                if let value = snapshot.value as? String {
                    
                    self.chatTitleOutlet.text = value
                    
                }
                
            } else {
                
                ref.removeAllObservers()
                
            }
        })
        
        
        ref.child("members").observe(.value, with: { (snapshot) in
            
            var scopeMembers = [String]()
            var collectionScopeMembers = [String]()
            
            if scopeKey == self.chatKey {
                
                if let valueMembers = snapshot.value as? [AnyHashable: Any] {
                    
                    for (valueUID, _) in valueMembers {
                        
                        if let userUid = valueUID as? String {
                            
                            scopeMembers.append(userUid)
                            
                        }
                    }
                    
                    self.members = scopeMembers
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        for member in scopeMembers {
                            
                            if selfUID != member {
                                
                                collectionScopeMembers.append(member)
                                
                            }
                        }
                    }
                    
                    self.collectionViewMembers = collectionScopeMembers
                    
                    self.globCollectionViewOutlet.reloadData()
                    
                }
                
            } else {
                
                ref.removeAllObservers()
                
            }
        })
        
        
        ref.child("groupPhoto").observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                if self.chatKey == scopeKey {
                    
                    if let photoString = snapshot.value as? String, let url = URL(string: photoString){
                        
                        self.groupPicture = photoString
                        self.groupPhotoOutlet.sd_setImage(with: url, placeholderImage: nil)
                        
                    }
                }
                
            } else {
                
                if self.chatKey == scopeKey {
                    
                    self.groupPhotoOutlet.image = UIImage(named: "icon")
                    
                }
            }
        })
    }
    
    
    func presentFusuma(){
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = false
        
        self.present(fusuma, animated: true) {
            
            print("fusumaPresented")
            
        }
        
    }
    
    
    
    
    //Fusuma Delegates
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        let scopeMembers = members
        let scopeKey = chatKey
        
        print("fusuma dismissed with image")
        presentAlertController(image)
        
        DispatchQueue.main.async(execute: {
            
            let imageView = UIImageView(image: image)
            imageView.clipsToBounds = true
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 0.75, constant: 0))
            
            imageView.contentMode = .scaleAspectFill
            
            if let alertController = self.globAlertController {
                
                alertController.alertViewContentView = imageView
                
            }
        })
        
        
        
        self.imageUploadRequest(image) { (url, uploadRequest) in
            
            let transferManager = AWSS3TransferManager.default()
            
            transferManager?.upload(uploadRequest).continue({ (task) -> Any? in
                
                if task.error == nil {
                    
                    print("successful image upload")
                    
                    FIRDatabase.database().reference().child("groupChats").child(scopeKey).child("groupPhoto").setValue(url)
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        FIRDatabase.database().reference().child("users").child(selfUID).child("groupChats").child(scopeKey).child("groupPhoto").setValue(url)
                        
                    }
                    
                    for member in scopeMembers {
                        
                        FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(scopeKey).child("groupPhoto").setValue(url)
                        
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
        
        UIApplication.shared.isStatusBarHidden = false
        rootController?.cameraTransitionOutlet.alpha = 0
        
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
    
    
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "squadMemberChatCell", for: indexPath) as! TopGroupChatCollectionCell
        
        cell.topChatController = self
        
        cell.loadData(collectionViewMembers[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionViewMembers.count
        
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
    
    var uid = ""
    var firstName = ""
    var lastName = ""
    
    func presentAlertController(_ image: UIImage?){
        
        let scopeUID = uid
        let scopeType = type
        
        let scopeMembers = members
        let scopeChatKey = chatKey
        
        //GROUP CHATS!
        if type == "groupChats" {
            
            let alertController = NYAlertViewController()
            
            var scopeTextField = UITextField()
            alertController.title = chatTitleOutlet.text
            alertController.message = nil
            alertController.backgroundTapDismissalGestureEnabled = true
            
            
            if let imageToAdd = image {
                
                DispatchQueue.main.async(execute: {
                    
                    let imageView = UIImageView(image: imageToAdd)
                    imageView.clipsToBounds = true
                    imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 0.75, constant: 0))
                    
                    imageView.contentMode = .scaleAspectFill
                    
                    alertController.alertViewContentView = imageView
                    
                })
                
                
            } else if let photo = self.groupPhotoOutlet.image {
                
                let scopePicture = groupPicture
                
                DispatchQueue.main.async(execute: {
                    
                    let imageView = UIImageView(image: photo)
                    imageView.clipsToBounds = true
                    imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 0.75, constant: 0))
                    
                    if scopePicture == nil {
                        
                        imageView.contentMode = .scaleAspectFit
                        
                    } else {
                        
                        imageView.contentMode = .scaleAspectFill
                    }
                    
                    alertController.alertViewContentView = imageView
                    
                })
            }
            
            alertController.addTextField(configurationHandler: { (textField) in
                
                textField?.text = self.chatTitleOutlet.text
                textField?.textAlignment = .center
                textField?.autocorrectionType = .no
                textField?.delegate = self
                scopeTextField = textField!
                
            })
            
            alertController.addAction(NYAlertAction(title: "Edit Chat Title", style: .default, handler: { (action) in
                
                if let text = scopeTextField.text {
                    
                    if text != "" {
                        
                        let chatRef = FIRDatabase.database().reference().child("groupChats").child(scopeChatKey)
                        chatRef.child("title").setValue(text)
                        
                        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            FIRDatabase.database().reference().child("users").child(selfUID).child("groupChats").child(scopeChatKey).child("title").setValue(text)
                        }
                        
                        for member in scopeMembers {
                            
                            FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(scopeChatKey).child("title").setValue(text)
                            
                        }
                        
                        alertController.title = text
                        alertController.view.endEditing(true)
                        
                    }
                }
            }))
            
            alertController.addAction(NYAlertAction(title: "Edit Group Photo", style: .default, handler: { (action) in
                
                //Edit Chat Photo
                self.dismiss(animated: true, completion: {
                    self.presentFusuma()
                })
                
            }))
            
            
            alertController.addAction(NYAlertAction(title: "Add Members", style: .default, handler: { (action) in
                
                //Add Members!
                
                self.rootController?.addToChatController?.loadUsers()
                
                self.dismiss(animated: true, completion: {
                    
                    self.rootController?.toggleAddToChat(scopeMembers, chatKey: scopeChatKey, completion: { (bool) in
                        
                        print("Add to chat toggled")
                        
                    })
                })
            }))
            
            
            alertController.addAction(NYAlertAction(title: "Leave Chat", style: .destructive, handler: { (action) in
                
                //Leave Chat
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    FIRDatabase.database().reference().child("groupChats").child(scopeChatKey).child("members").child(selfUID).removeValue()
                    
                    for member in scopeMembers {
                        
                        FIRDatabase.database().reference().child("users").child(member).child("groupChats").child(scopeChatKey).child("members").child(selfUID).removeValue()
                        
                    }
                    
                    FIRDatabase.database().reference().child("users").child(selfUID).child("groupChats").child(scopeChatKey).removeValue()
                    
                    self.dismiss(animated: true, completion: {
                        
                        self.rootController?.toggleHome({ (bool) in
                            
                            print("left chat")
                            
                        })
                    })
                }
            }))
            
            
            alertController.addAction(NYAlertAction(title: "Close", style: .cancel, handler: { (action) in
                
                print("cancel hit")
                
                self.dismiss(animated: true, completion: {
                    
                    print("Controller Dismissed")
                    
                })
            }))
            
            globAlertController = alertController
            
            self.present(alertController, animated: true, completion: {
                
                print("presented")
                
            })
            
            
        } else if type == "posts" {
            
            let alertController = UIAlertController(title: nil, message: "Report \(firstName) \(lastName) for inappropriate behavior?", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Report \(firstName)", style: .destructive, handler: { (action) in
                
                print("report")
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("cancel")
                
            }))
            
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = self.view.bounds
            popover?.permittedArrowDirections = UIPopoverArrowDirection.any

            self.present(alertController, animated: true, completion: {
                
                print("controller presented")
                
            })
            
            
        }else {
            
            //MATCH OR SQUAD
            
            let alertController = UIAlertController(title: "\(firstName + " " + lastName)", message: nil, preferredStyle: .actionSheet)
            
            if type == "matches" {
                
                title = "Delete Match"
                
            } else if type == "squad" {
                
                title = "Delete from squad"
                
            }
            
            alertController.addAction(UIAlertAction(title: title, style: .destructive, handler: { (action) in
                
                self.rootController?.toggleHome({ (bool) in
                    
                    if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                        let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                        
                        if scopeType == "matches" {
                            
                            myRef.child("notifications").child(scopeUID).child("matches").removeValue()
                            myRef.child("notifications").child(scopeUID).child("likesYou").removeValue()
                            myRef.child("matches").child(scopeUID).removeValue()
                            myRef.child("sentMatches").child(scopeUID).removeValue()
                            myRef.child("matchesDisplayed").child(scopeUID).removeValue()
                            
                            yourRef.child("notifications").child(selfUID).child("matches").removeValue()
                            yourRef.child("notifications").child(selfUID).child("likesYou").removeValue()
                            yourRef.child("matches").child(selfUID).removeValue()
                            yourRef.child("sentMatches").child(selfUID).removeValue()
                            yourRef.child("matchesDisplayed").child(selfUID).removeValue()
                            
                            
                        } else if scopeType == "squad" {
                            
                            let myRef = FIRDatabase.database().reference().child("users").child(selfUID)
                            
                            myRef.child("notifications").child(scopeUID).child("squad").removeValue()
                            myRef.child("notifications").child(scopeUID).child("squadRequest").removeValue()
                            myRef.child("squad").child(scopeUID).removeValue()
                            myRef.child("squadRequests").child(scopeUID).removeValue()
                            
                            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUID)
                            
                            yourRef.child("notifications").child(selfUID).child("squad").removeValue()
                            yourRef.child("notifications").child(selfUID).child("squadRequest").removeValue()
                            yourRef.child("squad").child(selfUID).removeValue()
                            yourRef.child("squadRequests").child(selfUID).removeValue()
                            
                        }
                    }
                })
            }))
            
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = self.view.bounds
            popover?.permittedArrowDirections = UIPopoverArrowDirection.any
            
            self.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
        }
    }
    
    
    
    //Actions
    @IBAction func cancel(_ sender: AnyObject) {

        rootController?.chatController?.clearPlayers()
        
        if let layer = playerLayer {
            
            layer.removeFromSuperlayer()
            playerLayer = nil
            
        }

        if let player = player {
            
            player.removeObserver(self, forKeyPath: "rate")
            self.player = nil
            
        }

        item = nil
        asset = nil

        let scopeType = type
        let scopeUid = uid
        let scopeKey = chatKey
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let selfRef = FIRDatabase.database().reference().child("users").child(selfUID)
            
            if scopeType == "posts" {
                
                print("posts")
                
            } else if scopeType == "groupChats" {
                
                selfRef.child("notifications").child("groupChats").child(scopeKey).child("read").setValue(true)
                selfRef.child(scopeType).child(scopeKey).child("read").setValue(true)
                
            } else {
                
                selfRef.child(scopeType).child(scopeUid).child("read").setValue(true)
                selfRef.child("notifications").child(scopeUid).child(scopeType).child("read").setValue(true)
                
            }
        }
        
        rootController?.toggleHome({ (bool) in
            
            print("home toggled")
            
        })
    }
    
    @IBAction func settings(_ sender: AnyObject) {
        
        presentAlertController(nil)
        
    }
    
    @IBAction func toProfile(_ sender: AnyObject) {
        
        let scopeUID = uid
        var selfProfile = false
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if selfUID == scopeUID {
                
                selfProfile = true
                
            }
        }
        
        self.rootController?.toggleHome({ (bool) in
            
            self.rootController?.toggleProfile(scopeUID, selfProfile: selfProfile, completion: { (bool) in
                
                print("profile toggled")
                
            })
        })
    }
    
    
    func keyboardDidShow(){
        
        if let alertController = globAlertController {
            
            alertController.view.center.y -= 150
            
        }
        
    }
    
    func closeKeyboard(){
        
        self.view.endEditing(true)
        
    }
    
    func keyboardDidHide(){
        
        if let alertController = globAlertController {
            
            alertController.view.center.y += 150
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        nameOutlet.baselineAdjustment = .alignCenters
        
        addUploadStuff()
        
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
