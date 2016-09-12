//
//  MainRootController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-30.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import SDWebImage

class MainRootController: UIViewController {
    
    var selfData = [NSObject : AnyObject]()
    
    var locationFromFirebase = false
    
    var menuIsRevealed = false
    var nearbyIsRevealed = false
    var vibesIsRevealed = false
    var messagesIsRevealed = false
    var matchIsRevealed = false
    var handlePostIsRevealed = false
    var profileRevealed = false
    var snapchatRevealed = false
    
    var vibesLoadedFromSelf = false
    
    var currentTab = 0
    
    var timer = NSTimer()
    
    //Outlets
    @IBOutlet weak var topNavCenter: NSLayoutConstraint!
    @IBOutlet weak var vibesTrailing: NSLayoutConstraint!
    @IBOutlet weak var vibesLeading: NSLayoutConstraint!
    @IBOutlet weak var closeMenuContainer: UIView!
    @IBOutlet weak var handlePostContainer: UIView!
    
    @IBOutlet weak var closeMenuTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var leadingMenu: NSLayoutConstraint!
    @IBOutlet weak var menuContainerOutlet: UIView!
    @IBOutlet weak var itsAMatchContainerOutlet: UIView!
    @IBOutlet weak var snapchatContainerOutlet: UIView!
    
    @IBOutlet weak var chatContainerOutlet: UIView!
    @IBOutlet weak var topNavConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var bottomNavConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var menuWidthConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var topProfileConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var bottomProfileConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var topChatConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var bottomChatConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var cameraTransitionOutlet: UIView!
    
    @IBOutlet weak var handlePostX: NSLayoutConstraint!
    
    
    @IBOutlet weak var snapWidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapYOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapXOutlet: NSLayoutConstraint!
    
    
    
    
    
    weak var actionsController: ActionsViewController?
    weak var topNavController: TopNavBarController?
    weak var bottomNavController: BottomNavController?
    weak var vibesFeedController: NewVibesController?
    weak var nearbyController: NearbyController?
    weak var messagesController: MessagesController?
    weak var menuController: MenuController?
    weak var closeController: CloseMenuController?
    weak var profileController: ProfileController?
    weak var matchController: ItsAMatchController?
    weak var chatController: CommentController?
    weak var handlePostController: HandlePostController?
    weak var snapchatController: SnapchatViewController?
    
    
    //Toggle Functions
    func toggleHome(completion: Bool -> ()) {
        
        let screenHeight = self.view.bounds.height
        
        self.closeMenuTopConstOutlet.constant = 0
        
        self.chatController?.view.endEditing(true)
        
        self.vibesFeedController?.navHidden = false
        
        if self.currentTab == 1 && !self.profileRevealed {
            self.nearbyController?.globCollectionView.setContentOffset(CGPointZero, animated: true)
        } else if self.currentTab == 2 && !self.profileRevealed {
            self.vibesFeedController?.globCollectionView.setContentOffset(CGPointZero, animated: true)
        }
        
        
        if let controller = chatController {
            
            NSNotificationCenter.defaultCenter().removeObserver(controller, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(controller, name: UIKeyboardWillHideNotification, object: nil)
            
        }
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.topNavConstOutlet.constant = 0
            
            self.bottomNavConstOutlet.constant = 0
            
            self.topChatConstOutlet.constant = -(screenHeight * 0.8)
            self.bottomChatConstOutlet.constant = screenHeight
            
            self.topProfileConstOutlet.constant = -(screenHeight * 0.9)
            self.bottomProfileConstOutlet.constant = screenHeight
            
            self.bottomNavController?.topChatBoxView.alpha = 0
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            self.chatController?.messages.removeAll()
            self.chatController?.messageKeys.removeAll()
            self.chatController?.messageData.removeAll()
            self.chatController?.addedMessages.removeAll()
            self.chatController?.messageIndex = 0
            
            self.chatController?.finishReceivingMessage()
            
            self.profileController?.currentUID = ""
            self.profileController?.currentPicture = 1
            self.profileController?.pictures = 1
            self.profileController?.userData.removeAll()
            
            self.profileRevealed = false
            
            completion(complete)
            
        }
    }
    
    
    func toggleNearby(completion: (Bool) -> ()) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let bool = self.toggleTabs(1)
            completion(bool)
            
        }
    }
    
    func toggleVibes(completion: (Bool) -> ()){
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let bool = self.toggleTabs(2)
            completion(bool)
            
        }
    }
    
    func toggleMessages(completion: (Bool) -> ()){
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let bool = self.toggleTabs(3)
            completion(bool)
            
        }
    }
    
    func toggleMenu(completion: (Bool) -> ()) {
        
        let mainDrawerWidthConstant: CGFloat = (self.view.bounds.width) * 0.8
        
        var menuOffset: CGFloat = 0
        
        var closeMenuAlpha: CGFloat = 0
        var buttonsEnabled = true
        
        if !menuIsRevealed {
            closeMenuAlpha = 1
            
            buttonsEnabled = false
            
        } else {
            
            menuOffset = -mainDrawerWidthConstant
            
        }
        
        menuIsRevealed = !menuIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.closeMenuContainer.alpha = closeMenuAlpha
            self.leadingMenu.constant = menuOffset
            
            self.bottomNavController?.nearbyButtonOutlet.enabled = buttonsEnabled
            self.bottomNavController?.vibesButtonOutlet.enabled = buttonsEnabled
            self.bottomNavController?.messagesButtonOutlet.enabled = buttonsEnabled
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    
    func toggleProfile(uid: String, selfProfile: Bool, profilePic: String, completion: Bool -> ()){
        
        print(profilePic)
        
        profileRevealed = true
        
        if let url = NSURL(string: profilePic) {
            
            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .ContinueInBackground, progress: { (receivedSize, expectedSize) in
                
                print("received size: \(receivedSize)")
                print("expected size: \(expectedSize)")
                
                }, completed: { (image, error, cache, bool, url) in
                    
                    if error == nil {
                        
                        let calculatedScale = image.size.height / image.size.width
                        print("calculated scale: \(calculatedScale)")
                        
                        self.profileController?.image1Scale = calculatedScale
                        self.profileController?.globCollectionCell.reloadData()
                        
                        
                    }
                    
            })
        }
        
        self.closeMenuTopConstOutlet.constant = -(self.view.bounds.height - 50)
        
        profileController?.currentUID = uid
        profileController?.retrieveUserData(uid)
        profileController?.selfProfile = selfProfile
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.topNavConstOutlet.constant = 0
            
            self.bottomProfileConstOutlet.constant = 0
            self.topProfileConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            self.messagesController?.globCollectionViewOutlet.reloadData()
            
            completion(complete)
        }
    }
    
    func toggleMatch(uid: String!, completion: Bool -> ()) {
        
        var matchAlpha: CGFloat = 1
        
        if uid != nil {
            
            let ref = FIRDatabase.database().reference()
            
            ref.child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if let value = snapshot.value as? [NSObject : AnyObject] {
                    
                    
                    if let firstName = value["firstName"] as? String, lastName = value["lastName"] as? String {
                        
                        self.matchController?.likesYouOutlet.text = "\(firstName) \(lastName) Likes You"
                        
                    }
                    
                    if let myProfile = self.selfData["profilePicture"] as? String, url = NSURL(string: myProfile) {
                        
                        self.matchController?.myProfileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                    }
                    
                    
                    if let yourProfile = value["profilePicture"] as? String, url = NSURL(string: yourProfile) {
                        
                        self.matchController?.yourProfileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                    }
                    
                    if let myRank = self.selfData["cityRank"] as? Int {
                        
                        self.matchController?.myRankOutlet.text = String(myRank)
                        
                    }
                    
                    if let yourRank = value["cityRank"] as? Int {
                        
                        self.matchController?.yourRankOutlet.text = String(yourRank)
                        
                    }
                    
                    
                    if let myLatitude = self.selfData["latitude"] as? CLLocationDegrees, myLongitude = self.selfData["longitude"] as? CLLocationDegrees, yourLatitude = value["latitude"] as? CLLocationDegrees, yourLongitude = value["longitude"] as? CLLocationDegrees {
                        
                        let myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                        let yourLocation = CLLocation(latitude: yourLatitude, longitude: yourLongitude)
                        
                        let distance = myLocation.distanceFromLocation(yourLocation)
                        
                        if distance > 9999 {
                            
                            let kilometers: Int = Int(distance) / 1000
                            self.matchController?.distanceOutlet.text = String(kilometers) + " kilometers away"
                            
                        } else if distance > 99 {
                            
                            let kilometers: Double = Double(distance) / 1000
                            let rounded = round(kilometers*10) / 10
                            self.matchController?.distanceOutlet.text = String(rounded) + " kilometers away"
                            
                        } else {
                            
                            self.matchController?.distanceOutlet.text = String(Int(round(distance))) + " meters away"
                            
                        }
                    }
                }
            })
        }
        
        if matchIsRevealed {
            matchAlpha = 0
            
        }
        
        matchIsRevealed = !matchIsRevealed
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.itsAMatchContainerOutlet.alpha = matchAlpha
            
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    func toggleChat(completion: (Bool) -> ()) {
        
        self.chatController?.senderId = selfData["uid"] as? String
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.chatController?.senderId = uid
        }
        
        if let firstName = selfData["firstName"] as? String, lastName = selfData["lastName"] as? String {
            
            self.chatController?.senderDisplayName = "\(firstName) \(lastName)"
            
        }
        
        if let controller = chatController {
            
            NSNotificationCenter.defaultCenter().addObserver(controller, selector: #selector(controller.keyboardDidShow), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(controller, selector: #selector(controller.keyboardHid), name: UIKeyboardWillHideNotification, object: nil)
            
            
            
        }
        
        
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.bottomNavController?.topChatBoxView.alpha = 1
            
            self.topNavConstOutlet.constant = 0
            self.topChatConstOutlet.constant = 0
            self.bottomChatConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    
    
    func toggleHandlePost(image: UIImage?, videoURL: NSURL?, isImage: Bool, completion: Bool -> ()) {
        
        let rootHeight = self.view.bounds.height
        
        print("handlePostIsRevealed: \(handlePostIsRevealed)")
        
        if !handlePostIsRevealed {
            
            self.handlePostX.constant = 0
            self.handlePostContainer.alpha = 1
            
            handlePostController?.isImage = isImage
            
            handlePostController?.image = image
            
            handlePostController?.videoURL = videoURL
            
            handlePostController?.handleCall()
            completion(true)
            
        } else {
            
            print("handle close")
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.handlePostX.constant = rootHeight
                
            }) { (complete) in
                
                self.handlePostContainer.alpha = 0
                self.handlePostX.constant = 0
                
                completion(complete)
                
            }
            
        }
        
        handlePostIsRevealed = !handlePostIsRevealed
        
    }
    
    
    
    func toggleSnapchat(completion: Bool -> ()){
        
        var snapAlpha: CGFloat = 0
        
        if !snapchatRevealed {
            
            snapAlpha = 1
            
            UIApplication.sharedApplication().statusBarHidden = true
            
            if let snapController = snapchatController, chatController = snapController.snapchatChatController {
                
                NSNotificationCenter.defaultCenter().addObserver(chatController, selector: #selector(chatController.hideKeyboard), name: UIKeyboardWillHideNotification, object: nil)
                
                NSNotificationCenter.defaultCenter().addObserver(chatController, selector: #selector(chatController.showKeyboard), name: UIKeyboardWillShowNotification, object: nil)
                
            }
            
            //GET RID OF SNAPS
            snapchatController?.posts.removeAll()
            
            snapchatController?.videoOutlet.alpha = 0
            snapchatController?.imageOutlet.image = nil
            snapchatController?.profilePicOutlet.image = nil
            snapchatController?.nameOutlet.text = ""
            snapchatController?.cityRankOutlet.text = "#"
            
            snapchatController?.secondaryImageOutlet.image = nil
            
            //HANDLE SNAPS
            snapchatController?.nextEnabled = true
            snapchatController?.mostRecentTimeInterval = nil
            snapchatController?.firstImageLoaded = false
            snapchatController?.currentIndex = 0
            snapchatController?.snapchatChatController?.currentPostKey = ""
            
            
            print("handle snaps on reveal")
            
        } else {
            
            //GET RID OF SNAPS
            
            print("handle snaps on close")
            
            snapchatController?.posts.removeAll()
            
            snapchatController?.imageOutlet.image = nil
            snapchatController?.profilePicOutlet.image = nil
            snapchatController?.nameOutlet.text = ""
            snapchatController?.cityRankOutlet.text = "#"
            
            snapchatController?.secondaryImageOutlet.image = nil
            
            if let snapController = snapchatController, chatController = snapController.snapchatChatController {
                
                NSNotificationCenter.defaultCenter().removeObserver(chatController, name: UIKeyboardWillShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().removeObserver(chatController, name: UIKeyboardWillHideNotification, object: nil)
                
            }
            
            self.showNav(0.3, completion: { (bool) in
                
                print("nav shown")
                
            })
            
            
            print("handle closing snaps")
            
        }
        
        snapchatRevealed = !snapchatRevealed
        
        let revealed = snapchatRevealed
        
        self.snapchatController?.screenIsCircle = false
        self.snapchatController?.isPanning = false
        self.snapchatController?.longPressEnabled = false
        
        self.snapchatController?.hideChat()
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.snapchatContainerOutlet.alpha = snapAlpha
            
        }) { (bool) in
            
            self.snapXOutlet.constant = 0
            self.snapYOutlet.constant = 0
            
            self.snapchatController?.view.layer.cornerRadius = 0
            
            self.snapWidthConstOutlet.constant = self.view.bounds.width
            self.snapHeightConstOutlet.constant = self.view.bounds.height
            
            
            if revealed {
                
                self.snapchatController?.observePosts(100, completion: { (bool) in
                    
                    self.snapchatController?.loadPrimary("left", i: -1, completion: { (complete) in
                        
                        print("start content loaded")
                        
                        completion(complete)
                    })
                    
                })
            }
        }
    }
    
    
    
    
    
    func hideAllNav(completion: (Bool) -> ()) {
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.topNavConstOutlet.constant = -100
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    func hideTopNav(completion: (Bool) -> ()){
        
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.bottomNavConstOutlet.constant = -50
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    
    func showNav(animatingTime: NSTimeInterval, completion: (Bool) -> ()){

        UIView.animateWithDuration(animatingTime, animations: {
            
            self.topNavConstOutlet.constant = 0
            self.bottomNavConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            
            self.vibesFeedController?.transitioning = false
            self.vibesFeedController?.navHidden = false
            
            completion(complete)
            
        }
    }
    
    
    //Other Functions
    func toggleTabs(tab: Int) -> Bool {
        
        let vibesConst = self.view.bounds.width
        
        self.showNav(0.6, completion: { (bool) in
            
            print("nav shown")
            
        })
        
        if tab == 1 {
            
            slideWithDirection(vibesConst, trailing: vibesConst)
            
            currentTab = 1
            self.bottomNavController?.toggleColour(1)
            
        } else if tab == 2 {
            
            slideWithDirection(0, trailing: 0)
            
            currentTab = 2
            self.bottomNavController?.toggleColour(2)
            
        } else if tab == 3 {
            
            slideWithDirection(-vibesConst, trailing: -vibesConst)
            
            currentTab = 3
            self.bottomNavController?.toggleColour(3)
            
        }
        
        return true
        
    }
    
    
    func slideWithDirection(leading: CGFloat, trailing: CGFloat){
        
        UIView.animateWithDuration(0.6, animations: {
            
            self.vibesLeading.constant = leading
            self.vibesTrailing.constant = trailing
            
            self.view.layoutIfNeeded()
            
        }) { (bool) in
            
            print("slid")
            
        }
    }
    
    
    
    
    
    func loadSelfData(completion: [NSObject : AnyObject] -> ()){
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            
            ref.observeEventType(.Value, withBlock: { (snapshot) in
                
                if let value = snapshot.value as? [NSObject:AnyObject]{
                    
                    self.selfData = value
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.selfData = value
                    
                    
                    if let city = value["city"] as? String {
                        
                        self.vibesFeedController?.currentCity = city
                        
                        if self.vibesLoadedFromSelf == false {
                            
                            self.vibesLoadedFromSelf = true
                            self.vibesFeedController?.observeCurrentCityPosts()
                            
                        }
                    }
                    
                    
                    self.checkForMatches()
                    
                    if let latitude = value["latitude"] as? CLLocationDegrees, longitude = value["longitude"] as? CLLocationDegrees {
                        
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        self.nearbyController?.queryNearby(location)
                        
                    }
                    
                    if let matches = value["matches"] as? [NSObject : AnyObject] {
                        self.messagesController?.loadMatches(matches)
                    }
                    
                    self.menuController?.setMenu()
                    
                    completion(value)
                }
            })
        }
    }
    
    
    
    func checkForMatches(){
        
        if let sentMatches = selfData["sentMatches"] as? [String : Bool] {
            
            for (key, value) in sentMatches {
                
                if value == true {
                    
                    if let matchDisplayed = selfData["matchDisplayed"] as? [String : Bool] {
                        
                        if matchDisplayed[key] != true {
                            
                            let ref = FIRDatabase.database().reference()
                            
                            if let uid = FIRAuth.auth()?.currentUser?.uid {
                                
                                ref.child("users").child(uid).child("matchDisplayed").updateChildValues([key : true])
                                
                                self.toggleMatch(key, completion: { (bool) in
                                    
                                    print("match toggled")
                                    
                                })
                                
                            }
                        }
                        
                    } else {
                        
                        let ref = FIRDatabase.database().reference()
                        
                        if let uid = FIRAuth.auth()?.currentUser?.uid {
                            
                            ref.child("users").child(uid).child("matchDisplayed").updateChildValues([key : true])
                            
                            self.toggleMatch(key, completion: { (bool) in
                                
                                print("match toggled")
                                
                            })
                        }
                    }
                }
            }
        }
        
        
        if let receivedMatches = selfData["receivedMatches"] as? [String : Bool] {
            
            for (key, value) in receivedMatches {
                
                if value == true {
                    
                    if let matchDisplayed = selfData["matchDisplayed"] as? [String : Bool] {
                        
                        if matchDisplayed[key] != true {
                            
                            let ref = FIRDatabase.database().reference()
                            
                            if let uid = FIRAuth.auth()?.currentUser?.uid {
                                
                                ref.child("users").child(uid).child("matchDisplayed").updateChildValues([key : true])
                                
                                self.toggleMatch(key, completion: { (bool) in
                                    
                                    print("match toggled")
                                    
                                })
                                
                            }
                        }
                        
                    } else {
                        
                        let ref = FIRDatabase.database().reference()
                        
                        if let uid = FIRAuth.auth()?.currentUser?.uid {
                            
                            ref.child("users").child(uid).child("matchDisplayed").updateChildValues([key : true])
                            
                            self.toggleMatch(key, completion: { (bool) in
                                
                                print("match toggled")
                                
                            })
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    func updateOnline(){
        
        print("online")
        
        updateActive()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(updateActive), userInfo: nil, repeats: true)
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            ref.updateChildValues(["online" : true])
            
        }
    }
    
    func updateOffline(){
        
        print("offline")
        
        self.timer.invalidate()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            ref.updateChildValues(["online" : false])
            
        }
    }
    
    func updateActive() {
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            let date = NSDate().timeIntervalSince1970
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.updateChildValues(["lastActive" : date])
            
        }
    }
    
    
    func askInterestedIn(){
        
        let alertController = UIAlertController(title: "Gender Preference", message: "This information is needed to match with good looking people around you!", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Men", style: .Default, handler: { (alert) in
            
            print("men selected")
            
            let ref = FIRDatabase.database().reference()
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                ref.child("users").child(uid).updateChildValues(["interestedIn" : ["male"]])
                self.selfData["interestedIn"] = ["male"]
                
                self.nearbyController?.requestWhenInUseAuthorization()
                self.nearbyController?.updateLocation()
                
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Women", style: .Default, handler: { (alert) in
            
            print("women selected")
            
            let ref = FIRDatabase.database().reference()
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                ref.child("users").child(uid).updateChildValues(["interestedIn" : ["female"]])
                self.selfData["interestedIn"] = ["female"]
                
                self.nearbyController?.requestWhenInUseAuthorization()
                self.nearbyController?.updateLocation()
                
            }
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Men & Women", style: .Default, handler: { (alert) in
            
            print("men and women selected")
            
            let ref = FIRDatabase.database().reference()
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                ref.child("users").child(uid).updateChildValues(["interestedIn" : ["male", "female"]])
                self.selfData["interestedIn"] = ["male", "female"]
                
                self.nearbyController?.requestWhenInUseAuthorization()
                self.nearbyController?.updateLocation()
                
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func setStage() {
        
        let screenHeight = self.view.bounds.height
        let screenWidth = self.view.bounds.width
        
        self.snapchatController?.topContentToHeaderOutlet.constant = -50
        self.snapchatController?.contentHeightConstOutlet.constant = screenHeight
        self.snapchatController?.commentStuffOutlet.alpha = 0
        
        
        self.snapchatController?.alphaHeaderOutlet.alpha = 0.4
        self.snapchatController?.alphaHeaderOutlet.backgroundColor = UIColor.lightGrayColor()
        
        self.snapWidthConstOutlet.constant = screenWidth
        self.snapHeightConstOutlet.constant = screenHeight
        
        self.topProfileConstOutlet.constant = -(screenHeight - 50)
        self.bottomProfileConstOutlet.constant = screenHeight
        
        self.topChatConstOutlet.constant = -(screenHeight - 100)
        self.bottomChatConstOutlet.constant = screenHeight
        
        self.menuWidthConstOutlet.constant = screenWidth * 0.8
        self.leadingMenu.constant = -(screenWidth * 0.8)
        
        self.vibesLeading.constant = screenWidth
        self.vibesTrailing.constant = -screenWidth
        
        self.bottomNavController?.toggleColour(1)
        
        chatContainerOutlet.alpha = 1
        profileContainer.alpha = 1
        menuContainerOutlet.alpha = 1
        snapchatContainerOutlet.alpha = 0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        setStage()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updateOnline()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.mainRootController = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "vibesFeedSegue" {
            
            let vibes = segue.destinationViewController as? NewVibesController
            vibesFeedController = vibes
            vibesFeedController?.rootController = self
            
        } else if segue.identifier == "menuSegue" {
            
            let menu = segue.destinationViewController as? MenuController
            menuController = menu
            menuController?.rootController = self
            
        } else if segue.identifier == "nearbySegue" {
            
            let nearby = segue.destinationViewController as? NearbyController
            nearbyController = nearby
            nearbyController?.rootController = self
            
        } else if segue.identifier == "messagesSegue" {
            
            let messages = segue.destinationViewController as? MessagesController
            messagesController = messages
            messagesController?.rootController = self
            
        } else if segue.identifier == "topNavSegue" {
            
            let topNav = segue.destinationViewController as? TopNavBarController
            topNavController = topNav
            topNavController?.rootController = self
            
        } else if segue.identifier == "bottomNavSegue" {
            
            let bottomNav = segue.destinationViewController as? BottomNavController
            bottomNavController = bottomNav
            bottomNavController?.rootController = self
            
        } else if segue.identifier == "closeSegue" {
            
            let close = segue.destinationViewController as? CloseMenuController
            closeController = close
            closeController?.rootController = self
            
        } else if segue.identifier == "profileSegue" {
            
            let profile = segue.destinationViewController as? ProfileController
            profileController = profile
            profileController?.rootController = self
            
        } else if segue.identifier == "matchSegue" {
            
            let match = segue.destinationViewController as? ItsAMatchController
            matchController = match
            matchController?.rootController = self
            
        } else if segue.identifier == "chatSegue" {
            
            let chat = segue.destinationViewController as? CommentController
            chatController = chat
            chatController?.rootController = self
            
        } else if segue.identifier == "actionsSegue" {
            
            let actions = segue.destinationViewController as? ActionsViewController
            actionsController = actions
            actionsController?.rootController = self
            
        } else if segue.identifier == "handlePostSegue" {
            
            let handlePost = segue.destinationViewController as? HandlePostController
            handlePostController = handlePost
            handlePostController?.rootController = self
            
            
        } else if segue.identifier == "snapchatSegue" {
            
            let snapchat = segue.destinationViewController as? SnapchatViewController
            snapchatController = snapchat
            snapchatController?.rootController = self
            
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
