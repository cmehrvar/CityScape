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
    var searchRevealed = false
    var notificationRevealed = false
    var squadCountRevealed = false
    var requestsRevealed = false
    
    var vibesLoadedFromSelf = false
    
    var currentTab = 0
    
    var timer = NSTimer()
    
    //OUTLETS
    
    //constraints
    @IBOutlet weak var topNavCenter: NSLayoutConstraint!
    @IBOutlet weak var vibesTrailing: NSLayoutConstraint!
    @IBOutlet weak var vibesLeading: NSLayoutConstraint!
    @IBOutlet weak var leadingMenu: NSLayoutConstraint!
    
    @IBOutlet weak var topNavConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var bottomNavConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var menuWidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var topProfileConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var bottomProfileConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var topChatConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var bottomChatConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapWidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapYOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapXOutlet: NSLayoutConstraint!
    @IBOutlet weak var handlePostX: NSLayoutConstraint!
    @IBOutlet weak var notificationWidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var notificationTrailingConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var squadBottomConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var requestsBottomConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var squadTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var requestsTopConstOutlet: NSLayoutConstraint!
    
    
    
    //views
    @IBOutlet weak var closeMenuContainer: UIView!
    @IBOutlet weak var handlePostContainer: UIView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var menuContainerOutlet: UIView!
    @IBOutlet weak var itsAMatchContainerOutlet: UIView!
    @IBOutlet weak var snapchatContainerOutlet: UIView!
    @IBOutlet weak var chatContainerOutlet: UIView!
    @IBOutlet weak var cameraTransitionOutlet: UIView!
    @IBOutlet weak var searchContainerOutlet: UIView!
    @IBOutlet weak var dismissKeyboardContainerOutlet: UIView!
    @IBOutlet weak var notificationContainer: UIView!
    
    
    //View Controllers
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
    weak var searchController: SearchController?
    weak var notificationController: NotificationController?
    weak var dismissController: DismissKeyboardController?
    weak var requestsController: RequestsController?
    weak var squadCountController: SquadCountController?
    
    
    //Toggle Functions
    func dismissKeyboard(completion: Bool -> ()){
        
        self.dismissKeyboardContainerOutlet.alpha = 0
        self.menuController?.view.endEditing(true)
        self.handlePostController?.view.endEditing(true)
        
        completion(true)
    }
    
    func toggleHome(completion: Bool -> ()) {
        
        let screenHeight = self.view.bounds.height
        
        self.chatController?.view.endEditing(true)
        
        self.vibesFeedController?.navHidden = false
        
        if !self.profileRevealed {
            
            if self.currentTab == 1 {
                self.nearbyController?.globCollectionView.setContentOffset(CGPointZero, animated: true)
            } else if self.currentTab == 2 {
                self.vibesFeedController?.globCollectionView.setContentOffset(CGPointZero, animated: true)
            }
        }
        
        if let controller = chatController {
            
            NSNotificationCenter.defaultCenter().removeObserver(controller, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(controller, name: UIKeyboardWillHideNotification, object: nil)
            
        }
        
        var searchAlpha: CGFloat = 0
        var scopeSearchRevealed = false
        
        
        if searchRevealed && profileRevealed {
            
            searchAlpha = 1
            scopeSearchRevealed = true
            
        }
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.topNavConstOutlet.constant = 0
            self.bottomNavConstOutlet.constant = 0
            
            self.topChatConstOutlet.constant = -(screenHeight * 0.8)
            self.bottomChatConstOutlet.constant = screenHeight
            
            self.requestsTopConstOutlet.constant = -screenHeight
            self.requestsBottomConstOutlet.constant = screenHeight
            
            self.squadTopConstOutlet.constant = -screenHeight
            self.squadBottomConstOutlet.constant = screenHeight
            
            if self.squadCountRevealed || self.requestsRevealed {
                
                self.topProfileConstOutlet.constant = 0
                self.bottomProfileConstOutlet.constant = 0
                
            } else {
                
                self.topProfileConstOutlet.constant = -(screenHeight * 0.9)
                self.bottomProfileConstOutlet.constant = screenHeight
                
            }
            
            self.bottomNavController?.topChatBoxView.alpha = 0
            
            self.searchContainerOutlet.alpha = searchAlpha
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            self.chatController?.messages.removeAll()
            self.chatController?.messageKeys.removeAll()
            self.chatController?.messageData.removeAll()
            self.chatController?.addedMessages.removeAll()
            self.chatController?.messageIndex = 0
            
            self.chatController?.finishReceivingMessage()
            
            self.searchController?.view.endEditing(true)
            
            self.searchRevealed = scopeSearchRevealed
            
            if (self.squadCountRevealed || self.requestsRevealed){
                
                self.profileRevealed = true
                
            } else {
                
                self.profileRevealed = false
                self.profileController?.currentUID = ""
                self.profileController?.userData.removeAll()
                self.profileController?.globCollectionCell.reloadData()
            }
            
            self.squadCountRevealed = false
            self.requestsRevealed = false
            
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
        
        if !menuIsRevealed {
            
            closeMenuAlpha = 1
            
        } else {
            
            menuOffset = -mainDrawerWidthConstant
            
        }
        
        menuIsRevealed = !menuIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.closeMenuContainer.alpha = closeMenuAlpha
            self.leadingMenu.constant = menuOffset
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    
    
    func toggleNotifications(completion: Bool -> ()){
        
        let mainDrawerWidthConstant: CGFloat = (self.view.bounds.width) * 0.8
        
        var notificationOffset: CGFloat = 0
        
        var closeMenuAlpha: CGFloat = 0
        
        if !notificationRevealed {
            closeMenuAlpha = 1
            
        } else {
            
            notificationOffset = -mainDrawerWidthConstant
            
        }
        
        notificationController?.globTableViewOutlet.reloadData()
        
        notificationRevealed = !notificationRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.closeMenuContainer.alpha = closeMenuAlpha
            self.notificationTrailingConstOutlet.constant = notificationOffset
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    
    
    
    func toggleProfile(uid: String, selfProfile: Bool, completion: Bool -> ()){
        
        profileRevealed = true
        
        profileController?.globCollectionCell.setContentOffset(CGPointZero, animated: false)
        
        profileController?.currentPicture = 1
        profileController?.currentUID = uid
        profileController?.selfProfile = selfProfile
        profileController?.userData.removeAll()
        profileController?.userPosts.removeAll()
        profileController?.videoPlayers.removeAll()
        
        profileController?.globCollectionCell.reloadData()
        
        profileController?.retrieveUserData(uid)
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.topNavConstOutlet.constant = 0
            
            self.bottomProfileConstOutlet.constant = 0
            self.topProfileConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
        }
    }
    
    
    
    func openSquadCount(userData: [NSObject : AnyObject], completion: Bool -> ()){

        if let squad = userData["squad"] as? [NSObject : AnyObject] {
            
            var sortedSquad = [[NSObject : AnyObject]]()
            
            for (_, value) in squad {
                
                if let valueToAdd = value as? [NSObject : AnyObject] {
                    
                    sortedSquad.append(valueToAdd)
                    
                }
            }
            
            sortedSquad.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                
                if a["lastName"] as? String > b["lastName"] as? String {
                    
                    return true
                    
                } else {
                    
                    return false
                    
                }
            })
            
            self.squadCountController?.squad = sortedSquad
            self.squadCountController?.globTableViewOutlet.reloadData()
            
        } else {
            
            self.squadCountController?.squad.removeAll()
            self.squadCountController?.globTableViewOutlet.reloadData()
            
        }

        if let userUID = userData["uid"] as? String, selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            squadCountRevealed = true
            
            if userUID == selfUID {
                
                squadCountController?.nameOutlet.text = "My Squad"
                squadCountController?.selfSquad = true
                
            } else {
                
                if let firstName = userData["firstName"] as? String, lastName = userData["lastName"] as? String {
                    
                    let name = firstName + " " + lastName
                    squadCountController?.nameOutlet.text = name + "'s Squad"
                    squadCountController?.selfSquad = false
                }
            }
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.squadTopConstOutlet.constant = 0
                self.squadBottomConstOutlet.constant = 0
                
                self.view.layoutIfNeeded()
                
            }) { (bool) in
                
                completion(bool)
                
            }
        }
    }
    
    
    
    
    func openRequests(completion: Bool -> ()){
        
        requestsRevealed = true
        
        requestsController?.globTableViewOutlet.reloadData()

        UIView.animateWithDuration(0.3, animations: {
            
            self.requestsTopConstOutlet.constant = 0
            self.requestsBottomConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }) { (bool) in
            
            completion(bool)
            
        }
    }
    
    
    
    
    func revealMatch(uid: String!, completion: Bool -> ()) {
        
        self.chatController?.view.endEditing(true)
        
        if !matchIsRevealed {
            
            matchIsRevealed = true
            
            if uid != nil {
                
                let ref = FIRDatabase.database().reference()
                
                ref.child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if let value = snapshot.value as? [NSObject : AnyObject] {
                        
                        self.matchController?.uid = uid
                        
                        if let firstName = value["firstName"] as? String, lastName = value["lastName"] as? String {
                            
                            self.matchController?.firstName = firstName
                            self.matchController?.lastName = lastName
                            
                            self.matchController?.likesYouOutlet.text = "\(firstName) \(lastName) Likes You"
                            
                        }
                        
                        if let myProfile = self.selfData["profilePicture"] as? String, url = NSURL(string: myProfile) {
                            
                            self.matchController?.myProfileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                            
                        }
                        
                        
                        if let yourProfile = value["profilePicture"] as? String, url = NSURL(string: yourProfile) {
                            
                            self.matchController?.profileString = yourProfile
                            
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
        }
        
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.itsAMatchContainerOutlet.alpha = 1
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    func closeMatch(uid: String, profile: String, firstName: String, lastName: String, keepPlaying: Bool, completion: Bool -> ()){
        
        if let myUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference()
            let activityTime = NSDate().timeIntervalSince1970
            
            let matchData: [NSObject : AnyObject] = ["uid" : uid, "lastActivity" : activityTime, "firstName" : firstName, "lastName" : lastName, "profilePicture" : profile, "online" : false]
            
            ref.child("users").child(myUID).child("matches").child(uid).updateChildValues(matchData)
            ref.child("users").child(myUID).child("matchesDisplayed").updateChildValues([uid : true])
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.itsAMatchContainerOutlet.alpha = 0
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    if keepPlaying {
                        
                        print("back to last screen")
                        self.matchIsRevealed = false
                        
                    } else {
                        
                        self.toggleMessages({ (bool) in
                            
                            let refToPass = "/users/\(myUID)/matches/\(uid)"
                            
                            self.messagesController?.rootController?.chatController?.passedRef = refToPass
                            self.messagesController?.rootController?.chatController?.typeOfChat = "match"
                            self.messagesController?.rootController?.chatController?.ownerUID = uid
                            
                            self.messagesController?.rootController?.bottomNavController?.chatNameOutlet.text = firstName + " " + lastName
                            
                            if let url = NSURL(string: profile) {
                                
                                self.messagesController?.rootController?.bottomNavController?.chatProfileOutlet.sd_setImageWithURL(url, placeholderImage: nil)
                                
                            }
                            
                            self.toggleChat({ (bool) in
                                
                                print("chat toggled")
                                self.matchIsRevealed = false
                                self.messagesController?.rootController?.chatController?.newObserveMessages()
                                
                            })
                        })
                    }
            })
        }
    }
    
    func toggleChat(completion: (Bool) -> ()) {
        
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
                self.view.layoutIfNeeded()
                
            }) { (complete) in
                
                self.handlePostContainer.alpha = 0
                self.handlePostX.constant = 0
                
                completion(complete)
                
            }
            
        }
        
        handlePostIsRevealed = !handlePostIsRevealed
        
    }
    
    func toggleSnapchat(givenPosts: [[NSObject : AnyObject]]?, startingi: Int?, completion: Bool -> ()){
        
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
        
        if !snapchatRevealed {
            
            UIApplication.sharedApplication().statusBarHidden = true
            
            if let snapController = snapchatController, chatController = snapController.snapchatChatController {
                
                NSNotificationCenter.defaultCenter().addObserver(chatController, selector: #selector(chatController.hideKeyboard), name: UIKeyboardWillHideNotification, object: nil)
                
                NSNotificationCenter.defaultCenter().addObserver(chatController, selector: #selector(chatController.showKeyboard), name: UIKeyboardWillShowNotification, object: nil)
                
            }
            
            print("handle snaps on reveal")
            
        } else {
            
            //GET RID OF SNAPS
            UIApplication.sharedApplication().statusBarHidden = false
            
            print("handle snaps on close")
            
            if let snapController = snapchatController, chatController = snapController.snapchatChatController {
                
                NSNotificationCenter.defaultCenter().removeObserver(chatController, name: UIKeyboardWillShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().removeObserver(chatController, name: UIKeyboardWillHideNotification, object: nil)
                
            }
            
            
            print("handle closing snaps")
            
        }
        
        snapchatRevealed = !snapchatRevealed
        
        let revealed = snapchatRevealed
        
        if revealed {
            
            if let given = givenPosts, givenIndex = startingi {
                
                self.snapchatController?.posts = given
                
                for i in 0..<given.count {
                    
                    self.snapchatController?.loadContent(i)
                    
                }
                
                self.snapchatController?.loadPrimary("left", i: givenIndex - 1, completion: { (complete) in
                    
                    print("start content loaded")
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.snapchatContainerOutlet.alpha = 1
                        self.view.layoutIfNeeded()
                        
                        }, completion: { (bool) in
                            
                            self.snapchatController?.screenIsCircle = false
                            self.snapchatController?.isPanning = false
                            self.snapchatController?.longPressEnabled = false
                            
                            self.snapchatController?.hideChat()
                            
                            self.snapXOutlet.constant = 0
                            self.snapYOutlet.constant = 0
                            
                            self.snapchatController?.view.layer.cornerRadius = 0
                            
                            self.snapWidthConstOutlet.constant = self.view.bounds.width
                            
                            self.snapWidthConstOutlet.constant = self.view.bounds.width
                            self.snapHeightConstOutlet.constant = self.view.bounds.height
                            
                    })
                })
                
                
            } else {
                
                self.snapchatController?.observePosts(100, completion: { (bool) in
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.snapchatContainerOutlet.alpha = 1
                        self.view.layoutIfNeeded()
                        
                        }, completion: { (bool) in
                            
                            self.snapchatController?.screenIsCircle = false
                            self.snapchatController?.isPanning = false
                            self.snapchatController?.longPressEnabled = false
                            
                            self.snapchatController?.hideChat()
                            
                            self.snapXOutlet.constant = 0
                            self.snapYOutlet.constant = 0
                            
                            self.snapchatController?.view.layer.cornerRadius = 0
                            
                            self.snapWidthConstOutlet.constant = self.view.bounds.width
                            self.snapHeightConstOutlet.constant = self.view.bounds.height
                            
                            
                            completion(bool)
                            
                    })
                })
            }
            
        } else {
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.snapchatContainerOutlet.alpha = 0
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.snapchatController?.screenIsCircle = false
                    self.snapchatController?.isPanning = false
                    self.snapchatController?.longPressEnabled = false
                    
                    self.snapchatController?.hideChat()
                    
                    self.snapXOutlet.constant = 0
                    self.snapYOutlet.constant = 0
                    
                    self.snapchatController?.view.layer.cornerRadius = 0
                    
                    self.snapWidthConstOutlet.constant = self.view.bounds.width
                    self.snapHeightConstOutlet.constant = self.view.bounds.height
                    
                    completion(bool)
                    
            })
        }
    }
    
    func toggleSearch(completion: Bool -> ()){
        
        self.showNav(0.3) { (bool) in
            
            print("nav shown")
            
            self.searchController?.toggleColour(1)
            
            let screenHeight = self.view.bounds.height
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.topProfileConstOutlet.constant = -screenHeight
                self.bottomProfileConstOutlet.constant = screenHeight
                
                self.squadTopConstOutlet.constant = -screenHeight
                self.squadBottomConstOutlet.constant = screenHeight
                
                self.requestsTopConstOutlet.constant = -screenHeight
                self.requestsBottomConstOutlet.constant = screenHeight
                
                self.searchContainerOutlet.alpha = 1
                self.view.layoutIfNeeded()
                
            }) { (bool) in
                
                self.searchRevealed = true
                
                self.profileRevealed = false
                self.squadCountRevealed = false
                self.requestsRevealed = false
                completion(bool)
                
            }
        }
    }
    
    func hideAllNav(completion: (Bool) -> ()) {
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.topNavConstOutlet.constant = -115
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
        
        UIApplication.sharedApplication().statusBarHidden = false
        
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
            
            self.searchContainerOutlet.alpha = 0
            
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
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.selfData = value
                    self.selfData = value
                    
                    
                    if let currentStatus = value["currentStatus"] as? String {
                        
                        self.menuController?.currentStatusTextViewOutlet.text = currentStatus
                        self.menuController?.charactersOutlet.text = "\(currentStatus.characters.count)/30 Characters"
                        
                    }
                    
                    if let city = value["city"] as? String {
                        
                        self.vibesFeedController?.currentCity = city
                        
                    }
                    
                    if !self.matchIsRevealed {
                        self.checkForMatches()
                    }
                    
                    if let latitude = value["latitude"] as? CLLocationDegrees, longitude = value["longitude"] as? CLLocationDegrees {
                        
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        self.nearbyController?.queryNearby(location)
                        
                    }
                    
                    if let matches = value["matches"] as? [NSObject : AnyObject] {
                        
                        self.messagesController?.loadMatches(matches)
                        
                    }
                    
                    self.menuController?.setMenu()

                    //NOTIFICATIONS - selfLoadData
                    if let notifications = value["notifications"] as? [NSObject : AnyObject] {
                        
                        print(notifications)
                        
                        var sortedNotifications = [[NSObject : AnyObject]]()
                        
                        var index = 0
                        
                        for (key, value) in notifications {
                            
                            if let valueToAdd = value as? [NSObject : AnyObject] {
                                
                                sortedNotifications.append(valueToAdd)
                                
                                if let read = valueToAdd["read"] as? Bool {
                                    
                                    if !read {
                                        
                                        index += 1
                                        
                                    }
                                }
                            }
                        }
        
                        sortedNotifications.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                            
                            if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
                                
                                return true
                                
                            } else {
                                
                                return false
                                
                            }
                        })
 
                        if index == 0 {
                            
                            self.topNavController?.numberOfNotificationsViewOutlet.alpha = 0
                            
                        } else {
                            
                            self.topNavController?.numberOfNotificationsViewOutlet.alpha = 1
                            self.topNavController?.numberOfNotificationsOutlet.text = "\(index)"
                            
                        }

                        self.notificationController?.globNotifications = sortedNotifications
                        
                    } else {
                        
                        self.topNavController?.numberOfNotificationsViewOutlet.alpha = 0
                        self.notificationController?.globNotifications.removeAll()
                        

                    }

                    //Requests
                    if let requests = value["squadRequests"] as? [NSObject : AnyObject] {
                        
                        var sortedRequests = [[NSObject : AnyObject]]()
                        
                        for (_, value) in requests {
                            
                            if let valueToAdd = value as? [NSObject : AnyObject] {
                                
                                if valueToAdd["status"] as? Int == 0 {
                                    
                                    sortedRequests.append(valueToAdd)
                                    
                                }
                            }
                        }
                        
                        sortedRequests.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                            
                            if a["timeStamp"] as? NSTimeInterval > b["timeStamp"] as? NSTimeInterval {
                                
                                return true
                                
                            } else {
                                
                                return false
                                
                            }
                        })
                        
                        self.requestsController?.numberOfRequestsOutlet.text = "Requests: \(sortedRequests.count)"
                        self.requestsController?.requests = sortedRequests
                        
                    } else {
                        
                        self.requestsController?.numberOfRequestsOutlet.text = "Requests: 0"
                        self.requestsController?.requests.removeAll()

                    }

                    if self.vibesLoadedFromSelf == false {
                        
                        self.vibesLoadedFromSelf = true
                        
                        self.searchController?.userController?.observeUsers()
                        self.searchController?.cityController?.observeCities()
                        
                        if value["interestedIn"] != nil {
                            
                            self.nearbyController?.requestWhenInUseAuthorization()
                            self.nearbyController?.updateLocation()
                            self.nearbyController?.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self.nearbyController!, selector: #selector(self.nearbyController?.updateLocationToFirebase), userInfo: nil, repeats: true)
                            
                        } else {
                            
                            self.askInterestedIn()
                            
                        }
                        
                        self.vibesFeedController?.observeCurrentCityPosts()
                        self.updateOnline()
                        
                    }
                    
                    self.nearbyController?.globCollectionView.reloadData()
                    self.profileController?.globCollectionCell.reloadData()
                    
                    completion(value)
                    
                }
            })
        }
    }
    
    func checkForMatches(){
        
        if let displayed = selfData["matchesDisplayed"] as? [String : Bool] {
            
            var uidToShow: String?
            
            for (key, value) in displayed {
                
                if value == false {
                    
                    uidToShow = key
                    
                }
            }
            
            if uidToShow != nil {
                
                self.revealMatch(uidToShow, completion: { (bool) in
                    
                    print("match shown")
                    
                })
            }
        }
    }
    
    func updateOnline(){
        
        print("online")
        
        updateActive()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(updateActive), userInfo: nil, repeats: true)
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            let userLocRef = FIRDatabase.database().reference().child("userLocations")
            userLocRef.child(uid).updateChildValues(["online" : true])
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            ref.updateChildValues(["online" : true])
            
            
        }
    }
    
    func updateOffline(){
        
        print("offline")
        
        self.timer.invalidate()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            let userLocRef = FIRDatabase.database().reference().child("userLocations")
            userLocRef.child(uid).updateChildValues(["online" : false])
            
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
                self.nearbyController?.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(self.nearbyController?.updateLocationToFirebase), userInfo: nil, repeats: true)
                
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
                self.nearbyController?.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(self.nearbyController?.updateLocationToFirebase), userInfo: nil, repeats: true)
                
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
                self.nearbyController?.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(self.nearbyController?.updateLocationToFirebase), userInfo: nil, repeats: true)
                
            }
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func setStage() {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let screenHeight = self.view.bounds.height
            let screenWidth = self.view.bounds.width
            
            self.snapchatController?.topContentToHeaderOutlet.constant = -50
            self.snapchatController?.contentHeightConstOutlet.constant = screenHeight
            self.snapchatController?.commentStuffOutlet.alpha = 0
            
            
            self.snapchatController?.alphaHeaderOutlet.alpha = 0.4
            self.snapchatController?.alphaHeaderOutlet.backgroundColor = UIColor.lightGrayColor()
            
            self.snapWidthConstOutlet.constant = screenWidth
            self.snapHeightConstOutlet.constant = screenHeight
            
            self.topProfileConstOutlet.constant = -screenHeight
            self.bottomProfileConstOutlet.constant = screenHeight
            
            self.squadTopConstOutlet.constant = -screenHeight
            self.squadBottomConstOutlet.constant = screenHeight
            
            self.requestsTopConstOutlet.constant = -screenHeight
            self.requestsBottomConstOutlet.constant = screenHeight
            
            self.topChatConstOutlet.constant = -(screenHeight - 100)
            self.bottomChatConstOutlet.constant = screenHeight
            
            self.menuWidthConstOutlet.constant = screenWidth * 0.8
            self.leadingMenu.constant = -(screenWidth * 0.8)
            
            self.notificationWidthConstOutlet.constant = screenWidth * 0.8
            self.notificationTrailingConstOutlet.constant = -(screenWidth * 0.8)
            
            self.vibesLeading.constant = screenWidth
            self.vibesTrailing.constant = -screenWidth
            
            self.bottomNavController?.toggleColour(1)
            
            self.chatContainerOutlet.alpha = 1
            self.profileContainer.alpha = 1
            self.menuContainerOutlet.alpha = 1
            self.notificationContainer.alpha = 1
            self.snapchatContainerOutlet.alpha = 0
            self.searchContainerOutlet.alpha = 0
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
        } else if segue.identifier == "searchSegue" {
            
            let search = segue.destinationViewController as? SearchController
            searchController = search
            searchController?.rootController = self
            
        } else if segue.identifier == "dismissSegue" {
            
            let dismiss = segue.destinationViewController as? DismissKeyboardController
            dismissController = dismiss
            dismissController?.rootController = self
            
        } else if segue.identifier == "notificationSegue" {
            
            let notification = segue.destinationViewController as? NotificationController
            notificationController = notification
            notificationController?.rootController = self
            
        } else if segue.identifier == "requestsSegue" {
            
            let request = segue.destinationViewController as? RequestsController
            requestsController = request
            requestsController?.rootController = self
            
        } else if segue.identifier == "squadCountSegue" {
            
            let squadCount = segue.destinationViewController as? SquadCountController
            squadCountController = squadCount
            squadCountController?.rootController = self
            
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
