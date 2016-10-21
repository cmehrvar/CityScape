//
//  SnapchatViewController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SDWebImage
import AVFoundation
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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class SnapchatViewController: UIViewController, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootController?
    weak var snapchatChatController: SnapchatChatController?
    
    @IBOutlet weak var alphaHeaderOutlet: UIView!
    @IBOutlet weak var topContentToHeaderOutlet: NSLayoutConstraint!
    @IBOutlet weak var contentHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var commentStuffOutlet: UIView!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var secondaryImageOutlet: UIImageView!
    @IBOutlet weak var captionOutlet: UILabel!
    @IBOutlet weak var profilePicOutlet: VibeHeaderProfilePic!
    @IBOutlet weak var cityRankOutlet: UILabel!
    @IBOutlet weak var closeOrSquadButton: UIButton!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var contentViewOutlet: UIView!
    @IBOutlet weak var squadIndicatorImage: UIImageView!
    
    @IBOutlet weak var primaryImageLeadingConstant: NSLayoutConstraint!
    @IBOutlet weak var primaryImageTrailingOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var videoOutlet: UIView!
    
    var mostRecentTimeInterval: TimeInterval?
    
    var singlePost = false
    
    var longPressEnabled = false
    var isPanning = false
    var chatIsRevealed = false
    var screenIsCircle = false
    
    var nextEnabled = true
    
    var firstImageLoaded = false
    
    var currentIndex = 0
    
    var posts = [[AnyHashable: Any]]()
    var addedPosts = [String : Bool]()

    var asset: AVAsset?
    var item: AVPlayerItem?
    var player: AVPlayer?
    var layer: AVPlayerLayer?

    var currentPostKey = ""
    var currentSquadInstance = ""
    var currentUID = ""
    
    var firstName = ""
    var lastName = ""
    var profilePic = ""

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

    //Actions
    @IBAction func toProfile(_ sender: AnyObject) {
        
        let screenHeight = self.view.bounds.height
        let scopeUID = currentUID

        self.closeWithDirection(0, y: screenHeight, animationTime: 0.3)

        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            var selfProfile = false
            
            if scopeUID == selfUID {
                
                selfProfile = true
                
            }
            
            self.rootController?.toggleHome({ (bool) in
                
                self.rootController?.toggleProfile(scopeUID, selfProfile: selfProfile, completion: { (bool) in
                    
                    print("profileToggled")
                    
                })
            })
        }
    }
    
    
    @IBAction func closeOrSquad(_ sender: AnyObject) {
        
        let scopeUserUID = currentUID
        let scopeFirstName = firstName
        let scopeLastName = lastName
        let scopeProfile = profilePic
        
        if currentSquadInstance == "inSquad" {
            
            //Delete Squad?
            print("toggle messages")
            
            let screenHeight = self.view.bounds.height
            
            closeWithDirection(0, y: screenHeight, animationTime: 0.3)
            
            self.rootController?.toggleChat("squad", key: scopeUserUID, city: nil, firstName: scopeFirstName, lastName: scopeLastName, profile: scopeProfile, completion: { (bool) in
                
                print("chat toggled")
                
            })
            
        } else if currentSquadInstance == "sentSquad" {
            
            //Cancel send?
            print("cancel send?")
            
            let alertController = UIAlertController(title: "Unsend squad request to \(firstName + " " + lastName)", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Unsend Request", style: .destructive, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    DispatchQueue.main.async(execute: {
                        
                        let ref = FIRDatabase.database().reference().child("users").child(scopeUserUID)
                        
                        ref.child("squadRequests").child(selfUID).removeValue()
                        ref.child("notifications").child(selfUID).child("squadRequest").removeValue()
                        
                        self.checkSquad(scopeUserUID, selfUID: selfUID)
                        
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
            
            
        } else if currentSquadInstance == "confirmSquad" {
            
            //Confrim or Deny
            print("confirm or deny")
            
            let alertController = UIAlertController(title: "Confirm \(firstName + " " + lastName) to your squad?", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Add to Squad", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.rootController?.selfData, let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)

                        DispatchQueue.main.async(execute: {
                            
                            ref.child("notifications").child(scopeUserUID).child("squadRequest").updateChildValues(["status" : "approved"])
                            ref.child("squadRequests").child(scopeUserUID).removeValue()
                            
                            ref.child("squad").child(scopeUserUID).setValue(["firstName" : scopeFirstName, "lastName" : scopeLastName, "uid" : scopeUserUID])
                            
                            let yourRef = FIRDatabase.database().reference().child("users").child(scopeUserUID)
                            
                            
                            
                            yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                    
                                    appDelegate.pushMessage(scopeUserUID, token: token, message: "\(myFirstName) is now in your squad!")
                                    
                                    
                                }
                            })

                            
                            let timeInterval = Date().timeIntervalSince1970

                            yourRef.child("notifications").child(selfUID).child("squadRequest").setValue(["firstName" : myFirstName, "lastName" : myLastName, "type" : "addedYou", "timeStamp" : timeInterval, "uid" : selfUID, "read" : false])
                            
                            yourRef.child("squad").child(selfUID).setValue(["firstName" : myFirstName, "lastName" : myLastName, "uid" : selfUID])
                            
                            
                            self.checkSquad(self.currentUID, selfUID: selfUID)
                            
                        })
                    
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Reject \(firstName)", style: .destructive, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {
                    
                    let ref =  FIRDatabase.database().reference().child("users").child(selfUID)
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("notifications").child(scopeUserUID).child("squadRequest").removeValue()
                        ref.child("squadRequests").child(scopeUserUID).removeValue()
                        
                        
                        self.checkSquad(self.currentUID, selfUID: selfUID)
                        
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
                
            })
            
            
        } else {
            
            //Send a request
            print("send a request")
            
            let alertController = UIAlertController(title: "Add \(firstName + " " + lastName) to your squad!", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Send Request", style: .default, handler: { (action) in
                
                if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.rootController?.selfData, let firstName = selfData["firstName"] as? String, let lastName = selfData["lastName"] as? String {
                    
                    let yourRef = FIRDatabase.database().reference().child("users").child(scopeUserUID)
                    
                    yourRef.child("pushToken").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            
                            appDelegate.pushMessage(scopeUserUID, token: token, message: "\(firstName) has sent you a squad request")
        
                        }
                    })

                    let timeInterval = Date().timeIntervalSince1970
                    
                    //0 -> Hasn't responded yet, 1 -> Approved, 2 -> Denied
                    let ref = FIRDatabase.database().reference().child("users").child(scopeUserUID)

                    let squadItem = ["uid" : selfUID, "read" : false, "status": 0, "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName] as [String : Any]
                    
                    let notificationItem = ["uid" : selfUID, "read" : false, "status" : "awaitingAction", "type" : "squadRequest", "timeStamp" : timeInterval, "firstName" : firstName, "lastName" : lastName] as [String : Any]
                    
                    
                    DispatchQueue.main.async(execute: {
                        
                        ref.child("squadRequests").child(selfUID).setValue(squadItem)
                        ref.child("notifications").child(selfUID).child("squadRequest").setValue(notificationItem)
                        
                        self.checkSquad(self.currentUID, selfUID: selfUID)
                        
                    })
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
                print("canceled")
                
            }))
            
            self.present(alertController, animated: true, completion: {
                
                print("alert controller presented")
                
            })
        }
    }
    
    
    //Functions
    func observePosts(_ lastNumber: UInt, completion: @escaping (Bool) -> ()){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("allPosts").queryLimited(toLast: lastNumber).observe(.value, with: { (snapshot) in
            
            if let value = snapshot.value as? [AnyHashable: Any]{
                
                var scopePosts = [[AnyHashable: Any]]()
                
                for (_, someValue) in value {
                    
                    if let valueToAdd = someValue as? [AnyHashable: Any] {
                        
                        if self.mostRecentTimeInterval == nil {
                            scopePosts.append(valueToAdd)
                        } else {
                            
                            if let postTimeStamp = valueToAdd["timeStamp"] as? TimeInterval {
                                
                                if postTimeStamp <= self.mostRecentTimeInterval {
                                    scopePosts.append(valueToAdd)
                                }
                            }
                        }
                    }
                }
                
                print("unordered:")
                print(scopePosts)
                
                scopePosts.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                    
                    if a["timeStamp"] as? TimeInterval >= b["timeStamp"] as? TimeInterval {
                        
                        return true
                        
                    } else {
                        
                        return false
                        
                    }
                })
                
                self.posts = scopePosts
                
                if self.mostRecentTimeInterval == nil {
                    
                    if let timeInterval = self.posts[0]["timeStamp"] as? TimeInterval {
                        
                        self.mostRecentTimeInterval = timeInterval
                        
                    }
                }
                
                if !self.firstImageLoaded {
                    
                    self.firstImageLoaded = true
                    
                    self.loadPrimary("left", i: -1, completion: { (bool) in
                        
                        completion(bool)
                        
                        print("primary loaded")
                        
                    })
                }
            }
        })
    }
    
    
    func revealChat(){
        
        nameOutlet.textColor = UIColor.black
        cityRankOutlet.textColor = UIColor.black
        
        if let rootWidth = self.rootController?.view.bounds.width {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.topContentToHeaderOutlet.constant = 0
                self.contentHeightConstOutlet.constant = rootWidth
                self.commentStuffOutlet.alpha = 1
                
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.isPanning = false
                    self.longPressEnabled = false
                    
                    self.chatIsRevealed = true
                    self.snapchatChatController?.finishReceivingMessage()
                    
                    if let playerLayer = self.layer {
                        
                        playerLayer.frame = self.videoOutlet.bounds
                        
                        
                    }
                    
            })
        }
    }
    
    func hideChat(){
        
        nameOutlet.textColor = UIColor.white
        cityRankOutlet.textColor = UIColor.white
        
        if let rootHeight = self.rootController?.view.bounds.height {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.topContentToHeaderOutlet.constant = -50
                self.contentHeightConstOutlet.constant = rootHeight
                self.commentStuffOutlet.alpha = 0
                
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.chatIsRevealed = false
                    self.snapchatChatController?.chatEnlarged = false
                    self.isPanning = false
                    self.longPressEnabled = false
                    
                    if let playerLayer = self.layer {
                        
                        playerLayer.frame = self.videoOutlet.bounds
                        
                    }
                    
            })
        }
    }
    
    
    
    
    
    func screenToCircle(_ animatingTime: TimeInterval){
        
        if let rootWidth = self.rootController?.view.bounds.width {
            
            self.view.clipsToBounds = true
            self.screenIsCircle = true
            
            UIView.animate(withDuration: animatingTime, animations: {
                
                self.rootController?.snapWidthConstOutlet.constant = (rootWidth-100)
                self.rootController?.snapHeightConstOutlet.constant = (rootWidth-100)
                
                self.view.layer.cornerRadius = (rootWidth-100)/2
                
                self.rootController?.view.layoutIfNeeded()
                self.view.layoutIfNeeded()
                
            })
        }
    }
    
    func screenToNormal(_ animatingTime: TimeInterval){
        
        self.screenIsCircle = false
        
        if let rootHeight = self.rootController?.view.bounds.height, let rootWidth = self.rootController?.view.bounds.width {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.rootController?.snapXOutlet.constant = 0
                self.rootController?.snapYOutlet.constant = 0
                
                self.rootController?.snapWidthConstOutlet.constant = rootWidth
                self.rootController?.snapHeightConstOutlet.constant = rootHeight
                
                self.view.layer.cornerRadius = 0
                
                self.rootController?.view.layoutIfNeeded()
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.isPanning = false
                    self.longPressEnabled = false
            })
            
            
        }
    }
    
    func closeWithDirection(_ x: CGFloat, y: CGFloat, animationTime: TimeInterval){
        
        singlePost = false
        
        snapchatChatController?.clearPlayers()
        
        if let profileRevealed = rootController?.profileRevealed {
            
            if profileRevealed {
                
                UIApplication.shared.isStatusBarHidden = true
                
            } else {
                
                if let topNavConst = rootController?.topNavConstOutlet.constant {
                    
                    if topNavConst == 0 {
                        
                        UIApplication.shared.isStatusBarHidden = false
                        
                    } else {
                        
                        UIApplication.shared.isStatusBarHidden = true
                    }
                }
            }
        }
        
        if let playerLayer = layer {
            
            playerLayer.removeFromSuperlayer()
            
        }
        
        if let playerPlayer = player {
            
            playerPlayer.removeObserver(self, forKeyPath: "rate")
            playerPlayer.pause()
            
        }
        
        layer = nil
        player = nil
        item = nil
        asset = nil
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: animationTime, animations: {
                
                self.rootController?.snapXOutlet.constant = x
                self.rootController?.snapYOutlet.constant = y
                
                self.rootController?.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.rootController?.snapXOutlet.constant = 0
                    self.rootController?.snapYOutlet.constant = 0
                    
                    if let rootWidth = self.rootController?.view.bounds.width {
                        
                        self.rootController?.snapWidthConstOutlet.constant = rootWidth
                        
                    }
                    
                    if let rootHeight = self.rootController?.view.bounds.height {
                        
                        self.rootController?.snapHeightConstOutlet.constant = rootHeight
                        
                    }
                    
                    self.view.layer.cornerRadius = 0
                    
                    self.rootController?.snapchatContainerOutlet.alpha = 0
                    
                    print("snapchat close")
                    
            
            })
        }
    }
    
    
    
    //PAN HANDLER
    func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        guard let rootHeight = self.rootController?.view.bounds.height, let rootWidth = self.rootController?.view.bounds.width else {return}
        
        var initialTranslationX: CGFloat = 0
        var initialTransaltionY: CGFloat = 0
        
        switch sender.state {
            
        case.began:
            
            initialTranslationX = translation.x
            initialTransaltionY = translation.y
            
            isPanning = true
            
            print("initial x: \(initialTranslationX)")
            print("initial y: \(initialTransaltionY)")
            
            
        case .changed:
            
            if longPressEnabled {
                
                rootController?.snapXOutlet.constant = translation.x
                rootController?.snapYOutlet.constant = translation.y
                
            }
            
        case .ended:
            
            print("end x: \(translation.x)")
            print("end y: \(translation.y)")
            
            let endTranslationX = translation.x
            let endTranslationY = translation.y
            
            let squaredTotal = (endTranslationX * endTranslationX) + (endTranslationY * endTranslationY)
            
            let distance = sqrt(Double(squaredTotal))
            
            var directionIsUp = false
            var directionIsDown = false
            
            var directionIsHorizontal = false
            var directionIsRight = false
            var directionIsLeft = false
            
            if translation.y < -75 {
                
                directionIsUp = true
                directionIsDown = false
                
            } else if -75 <= translation.y && translation.y <= 75 {
                
                directionIsUp = false
                directionIsDown = false
                
            } else if 75 < translation.y {
                
                directionIsUp = false
                directionIsDown = true
                
            }
            
            if translation.x < -75 {
                
                directionIsHorizontal = true
                directionIsLeft = true
                directionIsRight = false
                
            } else if -75 <= translation.x && translation.x <= 75 {
                
                directionIsHorizontal = false
                directionIsLeft = false
                directionIsRight = false
                
            } else if 75 < translation.x {
                
                directionIsHorizontal = true
                directionIsLeft = false
                directionIsRight = true
                
            }
            
            
            
            if distance > 75 {
                
                if directionIsDown && directionIsRight {
                    
                    print("direction is down right")
                    
                    if screenIsCircle {
                        
                        closeWithDirection(rootWidth, y: rootHeight, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE!
                        
                        if chatIsRevealed {
                            
                            if let enlarged = self.snapchatChatController?.chatEnlarged {
                                
                                if enlarged {
                                    
                                    self.snapchatChatController?.shrinkChat()
                                    
                                } else {
                                    
                                    hideChat()
                                    
                                }
                            }
                            
                        } else {
                            
                            screenToCircle(0.15)
                            closeWithDirection(rootWidth, y: rootHeight, animationTime: 0.75)
                            
                        }
                    }
                    
                } else if directionIsDown && !directionIsHorizontal {
                    
                    print("direction is down only")
                    
                    if screenIsCircle {
                        
                        closeWithDirection(0, y: rootHeight, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE!
                        
                        if chatIsRevealed {
                            
                            if let enlarged = self.snapchatChatController?.chatEnlarged {
                                
                                if enlarged {
                                    
                                    self.snapchatChatController?.shrinkChat()
                                    
                                } else {
                                    
                                    hideChat()
                                    
                                }
                            }
                            
                        } else {
                            
                            screenToCircle(0.15)
                            closeWithDirection(0, y: rootHeight, animationTime: 0.75)
                            
                        }
                    }
                    
                } else if directionIsDown && directionIsLeft {
                    
                    print("direction is down left")
                    
                    if screenIsCircle {
                        
                        closeWithDirection(-rootWidth, y: rootHeight, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE!
                        
                        if chatIsRevealed {
                            
                            if let enlarged = self.snapchatChatController?.chatEnlarged {
                                
                                if enlarged {
                                    
                                    self.snapchatChatController?.shrinkChat()
                                    
                                } else {
                                    
                                    hideChat()
                                    
                                }
                            }
                            
                        } else {
                            
                            screenToCircle(0.15)
                            closeWithDirection(-rootWidth, y: rootHeight, animationTime: 0.75)
                            
                        }
                    }
                    
                } else if directionIsLeft && !directionIsUp && !directionIsDown {
                    
                    print("direction is left only")
                    
                    if screenIsCircle || singlePost {
                        
                        closeWithDirection(-rootWidth, y: 0, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE
                        if nextEnabled {
                            
                            let scopeIndex = currentIndex
                            
                            nextEnabled = false
                            
                            loadSecondaryContent("left", i: scopeIndex, completion: { (bool) in
                                
                                self.loadPrimary("left", i: scopeIndex, completion: { (Bool) in
                                    
                                })
                            })
                        }
                    }
                    
                } else if directionIsRight && !directionIsUp && !directionIsDown {
                    
                    print("direction is right only")
                    
                    if screenIsCircle || singlePost {
                        
                        closeWithDirection(rootWidth, y: 0, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE!
                        
                        if nextEnabled {
                            
                            let scopeIndex = currentIndex
                            
                            nextEnabled = false
                            
                            loadSecondaryContent("right", i: scopeIndex, completion: { (bool) in
                                
                                self.loadPrimary("right", i: scopeIndex, completion: { (Bool) in
                                    
                                    
                                    
                                })
                            })
                        }
                    }
                    
                } else if directionIsLeft && directionIsUp {
                    
                    print("direction is up left")
                    
                    if screenIsCircle {
                        
                        closeWithDirection(-rootWidth, y: -rootHeight, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE!
                        
                        if !chatIsRevealed {
                            
                            revealChat()
                            
                        }
                    }
                    
                } else if directionIsUp && !directionIsHorizontal {
                    
                    print("direction is up only")
                    
                    if screenIsCircle {
                        
                        closeWithDirection(0, y: -rootHeight, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE!
                        
                        if !chatIsRevealed {
                            
                            revealChat()
                            
                        }
                    }
                    
                } else if directionIsUp && directionIsRight {
                    
                    print("direction is up right")
                    
                    if screenIsCircle {
                        
                        closeWithDirection(rootWidth, y: -rootHeight, animationTime: 0.45)
                        
                    } else {
                        
                        //SCREEN IS NOT CIRCLE!
                        
                        if !chatIsRevealed {
                            
                            revealChat()
                            
                        }
                    }
                    
                }  else {
                    print("unknown case")
                    
                    screenToNormal(0.3)
                    
                }
                
            } else {
                
                print("dont make changes to screen")
                screenToNormal(0.3)
                
            }
            
        default:
            break
            
        }
    }
    
    
    func longPressHandler(_ sender: UILongPressGestureRecognizer){
        
        switch sender.state {
            
        case .began:
            print("long press began")
            
            screenToCircle(0.3)
            longPressEnabled = true
            
        case .ended:
            print("long press ended")
            
            if !isPanning {
                
                screenToNormal(0.3)
                
            }
            
        default:
            break
            
        }
    }
    
    
    
    
    func loadSecondaryContent(_ direction: String, i: Int, completion: @escaping (Bool) -> ()){
        
        if let playerLayer = layer {
            
            playerLayer.removeFromSuperlayer()
            
        }
        
        if let playerPlayer = player {
            
            playerPlayer.removeObserver(self, forKeyPath: "rate")
            playerPlayer.pause()
            
        }
        
        layer = nil
        player = nil
        item = nil
        asset = nil
        
        print("i: \(i)")
        print("posts.count: \(posts.count)")
        
        if i == posts.count - 1 && direction == "left"{
            
            print("end")
            
            if let rootHeight = self.rootController?.view.bounds.height {
                
                self.screenToCircle(0.15)
                self.closeWithDirection(0, y: rootHeight, animationTime: 0.75)
                
            }
            
        } else {
            
            var post = [AnyHashable: Any]()

            if direction == "left" {
                
                print("direction is left")
                
                post = posts[i + 1]
                
            } else if direction == "right" {
                
                print("direction is right")
                
                if i == 0 {
                    
                    if let rootHeight = self.rootController?.view.bounds.height {
                        
                        self.screenToCircle(0.15)
                        self.closeWithDirection(0, y: rootHeight, animationTime: 0.75)
                        
                        return
                        
                    }
                }
                
                post = posts[i - 1]
                
            }
            
            self.secondaryImageOutlet.alpha = 1
            self.videoOutlet.alpha = 0
            
            if let imageString = post["imageURL"] as? String, let imageURL = URL(string: imageString) {
                
                secondaryImageOutlet.sd_setImage(with: imageURL, completed: { (image, error, cache, url) in
                    
                    print("image completed")
                    
                })
            }
            
            self.slideContent(direction, completion: { (bool) in
                
                completion(bool)
                
            })
        }
    }
    
    
    func slideContent(_ direction: String, completion: @escaping (Bool) -> ()){
        
        guard let rootWidth = self.rootController?.view.bounds.width else {return}
        
        if direction == "left" {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.primaryImageLeadingConstant.constant = -rootWidth
                self.primaryImageTrailingOutlet.constant = rootWidth
                
                self.videoOutlet.layoutIfNeeded()
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.imageOutlet.alpha = 0
                    self.primaryImageTrailingOutlet.constant = 0
                    self.primaryImageLeadingConstant.constant = 0
                    
                    completion(bool)
                    
                    print("left image")
                    
            })
            
            
        } else if direction == "right" {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.primaryImageLeadingConstant.constant = rootWidth
                self.primaryImageTrailingOutlet.constant = -rootWidth
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.imageOutlet.alpha = 0
                    self.primaryImageTrailingOutlet.constant = 0
                    self.primaryImageLeadingConstant.constant = 0
                    
                    completion(bool)
                    
                    print("right image")
                    
            })
        }
        
    }
    
    
    func tapHandler(){

        print(singlePost)
        
        if let chatEnlarged = snapchatChatController?.chatEnlarged {
            
            if chatEnlarged {
                
                snapchatChatController?.shrinkChat()
                
            } else if nextEnabled && !longPressEnabled && !singlePost {
                
                let scopeIndex = currentIndex
                
                nextEnabled = false
                
                loadSecondaryContent("left", i: scopeIndex, completion: { (bool) in
                    
                    self.loadPrimary("left", i: scopeIndex, completion: { (Bool) in
                        
                    })
                })
            } else if singlePost {

                closeWithDirection(0, y: self.view.bounds.height, animationTime: 0.3)
                
            }
        }
    }
    
    
    func checkSquad(_ uid: String, selfUID: String){
        
        //LOAD SQUAD ICON
        
        if uid == selfUID {
            
            squadIndicatorImage.image = nil
            closeOrSquadButton.isEnabled = false
            
        } else if uid != "" || !uid.isEmpty {
            
            closeOrSquadButton.isEnabled = true
            
            if let selfData = self.rootController?.selfData {
                
                var inMySquad = false
                var iSentYou = false
                var youSentMe = false
                
                if let mySquad = selfData["squad"] as? [AnyHashable: Any] {
                    
                    if mySquad[uid] != nil {
                        
                        inMySquad = true
                        
                    }
                }
                
                if inMySquad {
                    
                    self.squadIndicatorImage.image = UIImage(named: "enabledMessage")
                    self.currentSquadInstance = "inSquad"
                    
                } else {
                    
                    if let mySquadRequests = selfData["squadRequests"] as? [AnyHashable: Any] {
                        
                        for (key, _) in mySquadRequests {
                            
                            if let squadUID = key as? String {
                                
                                if uid == squadUID {
                                    
                                    youSentMe = true
                                    
                                }
                            }
                        }
                    }
                    
                    if youSentMe {
                        
                        self.squadIndicatorImage.image = UIImage(named: "confirmSquad")
                        self.currentSquadInstance = "confirmSquad"
                        
                    } else {
                        
                        let ref = FIRDatabase.database().reference().child("users").child(uid)
                        
                        ref.child("squadRequests").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            print(snapshot.value)
                            
                            if snapshot.exists() {
                                
                                if let yourSquadRequests = snapshot.value as? [AnyHashable: Any] {
                                    
                                    for (key, _) in yourSquadRequests {
                                        
                                        if let squadUID = key as? String {
                                            
                                            if selfUID == squadUID {
                                                
                                                iSentYou = true
                                                
                                            }
                                        }
                                    }
                                }
                                
                                if iSentYou {
                                    
                                    if self.currentUID == uid {
                                        
                                        self.squadIndicatorImage.image = UIImage(named: "sentSquad")
                                        self.currentSquadInstance = "sentSquad"
                                        
                                    }
                                    
                                } else {
                                    
                                    if self.currentUID == uid {
                                        
                                        self.squadIndicatorImage.image = UIImage(named: "sendSquad")
                                        self.currentSquadInstance = "sendSquad"
                                        
                                    }
                                }
                                
                            } else {
                                
                                if self.currentUID == uid {
                                    
                                    self.squadIndicatorImage.image = UIImage(named: "sendSquad")
                                    self.currentSquadInstance = "sendSquad"
                                    
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    
    func loadPrimary(_ direction: String, i: Int, completion: (Bool) -> ()){
        
        var post = [AnyHashable: Any]()
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if direction == "left" {
                
                print("primary direction is left")
                
                post = posts[i + 1]
                
                if i >= posts.count - 1 {
                    
                    if let rootHeight = self.rootController?.view.bounds.height {
                        
                        screenToCircle(0.15)
                        closeWithDirection(0, y: rootHeight, animationTime: 0.75)
                        completion(true)
                        
                    }
                }
                
            } else if direction == "right" {
                
                post = posts[i - 1]
                
                print("primary direction is right")
                
            }
            
            if let uid = post["userUID"] as? String {
                
                self.currentUID = uid
                snapchatChatController?.senderId = selfUID
                
                self.checkSquad(uid, selfUID: selfUID)
                
                let ref = FIRDatabase.database().reference().child("users").child(uid)
                
                ref.child("profilePicture").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let profileString = snapshot.value as? String, let url = URL(string: profileString) {
                        
                        self.profilePic = profileString
                        
                        if self.currentUID == uid {
                            
                            self.profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
                            
                        }
                    }
                })
                
                
                ref.child("cityRank").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let rank = snapshot.value as? Int {
                        
                        if self.currentUID == uid {
                            
                            self.cityRankOutlet.text = "#\(rank)"
                            
                        }
                    }
                })
                
                
                if let profileString = post["profilePicture"] as? String, let profileURL = URL(string: profileString) {
                    
                    profilePicOutlet.sd_setImage(with: profileURL, placeholderImage: nil)
                    
                }
                
                if let rank = post["cityRank"] as? Int {
                    
                    cityRankOutlet.text = "#" + String(rank)
                    
                }
                
                
                
                
                
                if let imageString = post["imageURL"] as? String, let imageURL = URL(string: imageString) {
                    
                    imageOutlet.sd_setImage(with: imageURL, placeholderImage: nil)
                    
                }
                
                
                if let isImage = post["isImage"] as? Bool {
                    
                    if !isImage {
                        
                        print("load video")
                        
                        
                            
                            if let urlString = post["videoURL"] as? String, let url = URL(string: urlString) {
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    self.asset = AVAsset(url: url)
                                    
                                    if let asset = self.asset {
                                        
                                        self.item = AVPlayerItem(asset: asset)
                                        
                                        if let item = self.item {
                                            
                                            self.player = AVPlayer(playerItem: item)
                                            
                                        }
                                        
                                        if let player = self.player {
                                            
                                            player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
                                            
                                            self.layer = AVPlayerLayer(player: player)
                                            
                                            if let layer = self.layer {
                                                
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
                }
                
                /*
                
                if let caption = post["caption"] as? String {
                    
                    captionOutlet.text = caption
                    
                }
                */
                if let firstName = post["firstName"] as? String, let lastName = post["lastName"] as? String {
                    
                    self.firstName = firstName
                    self.lastName = lastName
                    
                    nameOutlet.text = firstName + " " + lastName
                    
                }
                
                if let postKey = post["postChildKey"] as? String, let city = post["city"] as? String {
                    
                    let ref = "posts/\(city)/\(postKey)"
                    currentPostKey = postKey
                    snapchatChatController?.currentPostKey = postKey
                    snapchatChatController?.passedRef = ref
                    
                }
                
                if let firstName = self.rootController?.selfData["firstName"] as? String, let lastName = self.rootController?.selfData["lastName"] as? String {
                    
                    self.snapchatChatController?.senderDisplayName = "\(firstName) \(lastName)"
                    
                }
                
                self.imageOutlet.alpha = 1
                self.secondaryImageOutlet.alpha = 0
                
                if i >= 0 {
                    
                    if direction == "left" {
                        
                        currentIndex += 1
                        
                    } else if direction == "right" {
                        
                        currentIndex -= 1
                        
                    }
                }
                
                self.nextEnabled = true
                self.snapchatChatController?.newObserveMessages()
                
                self.isPanning = false
                self.longPressEnabled = false
                
                completion(true)
            }
        }
    }
    
    
    func addGestureRecognizers(){
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
        panGesture.delegate = self
        self.contentViewOutlet.addGestureRecognizer(panGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        longPressGesture.delegate = self
        self.view.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.delegate = self
        self.contentViewOutlet.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOutlet.adjustsFontSizeToFitWidth = true
        captionOutlet.adjustsFontSizeToFitWidth = true
        
        addGestureRecognizers()
        
        // Do any additional setup after loading the view.
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "snapChatSegue" {
            
            let chatController = segue.destination as? SnapchatChatController
            snapchatChatController = chatController
            snapchatChatController?.snapchatController = self
            
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
