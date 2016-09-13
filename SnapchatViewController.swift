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
import Player
import AVFoundation

class SnapchatViewController: UIViewController, UIGestureRecognizerDelegate, PlayerDelegate {
    
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
    
    @IBOutlet weak var primaryImageLeadingConstant: NSLayoutConstraint!
    @IBOutlet weak var primaryImageTrailingOutlet: NSLayoutConstraint!
    
    
    @IBOutlet weak var videoOutlet: UIView!
    
    var mostRecentTimeInterval: NSTimeInterval?
    
    var longPressEnabled = false
    var isPanning = false
    var chatIsRevealed = false
    var screenIsCircle = false
    
    var nextEnabled = true
    
    var firstImageLoaded = false
    
    var posts = [[NSObject : AnyObject]]()
    var addedPosts = [String : Bool]()
    
    var videoPlayers = [String : Player]()
    
    var currentPostKey = ""
    
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
    
    
    
    
    //Actions
    @IBAction func closeOrSquad(sender: AnyObject) {
        
        
    }
    
    
    //Functions
    func loadContent(index: Int){
        
        let post = posts[index]
        
        if let imageString = post["imageURL"] as? String, imageURL = NSURL(string: imageString){
            
            if let isImage = post["isImage"] as? Bool {
                
                if isImage {
                    
                    print("isImage")
                    
                } else if let postKey = post["postChildKey"] as? String {

                    if self.videoPlayers[postKey] == nil {
                        
                        if let videoString = post["videoURL"] as? String, videoURL = NSURL(string: videoString), key = post["postChildKey"] as? String {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                let player = Player()
                                player.delegate = self
                                self.addChildViewController(player)
                                player.view.frame = self.videoOutlet.bounds
                                player.didMoveToParentViewController(self)
                                player.setUrl(videoURL)
                                player.fillMode = AVLayerVideoGravityResizeAspectFill
                                player.playbackLoops = true
                                
                                self.videoPlayers[key] = player
                                
                                print("video downloaded!")
 
                            })
                        }
                    }
                }
                
                SDWebImageManager.sharedManager().downloadImageWithURL(imageURL, options: .ContinueInBackground, progress: { (currentSize, expectedSize) in
                    
                    }, completed: { (image, error, cache, bool, url) in
                        
                })
            }
        }
    }
    
    
    func observePosts(lastNumber: UInt, completion: Bool -> ()){
        
        let ref = FIRDatabase.database().reference()
        
        ref.child("allPosts").queryLimitedToLast(lastNumber).observeEventType(.Value, withBlock: { (snapshot) in
            
            if let value = snapshot.value as? [NSObject : AnyObject]{
                
                var scopePosts = [[NSObject : AnyObject]]()
                
                for (_, someValue) in value {
                    
                    if let valueToAdd = someValue as? [NSObject : AnyObject] {
                        
                        if self.mostRecentTimeInterval == nil {
                            scopePosts.append(valueToAdd)
                        } else {
                            
                            if let postTimeStamp = valueToAdd["timeStamp"] as? NSTimeInterval {
                                
                                if postTimeStamp <= self.mostRecentTimeInterval {
                                    scopePosts.append(valueToAdd)
                                }
                            }
                        }
                    }
                }
                
                print("unordered:")
                print(scopePosts)
                
                scopePosts.sortInPlace({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                    
                    if a["timeStamp"] as? NSTimeInterval >= b["timeStamp"] as? NSTimeInterval {
                        
                        return true
                        
                    } else {
                        
                        return false
                        
                    }
                    
                })
                
                self.posts = scopePosts
                
                if self.mostRecentTimeInterval == nil {
                    
                    if let timeInterval = self.posts[0]["timeStamp"] as? NSTimeInterval {
                        
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

                
                
                for i in 0..<self.posts.count {
                    
                    self.loadContent(i)
                    
                }
                
            }
        })
    }
    
    
    func revealChat(){
        
        nameOutlet.textColor = UIColor.blackColor()
        cityRankOutlet.textColor = UIColor.blackColor()
        
        if let rootWidth = self.rootController?.view.bounds.width {
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.topContentToHeaderOutlet.constant = 0
                self.contentHeightConstOutlet.constant = rootWidth
                self.commentStuffOutlet.alpha = 1
                
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.isPanning = false
                    self.longPressEnabled = false
                    
                    self.chatIsRevealed = true
                    self.snapchatChatController?.finishReceivingMessage()
   
            })
        }
    }
    
    func hideChat(){
        
        nameOutlet.textColor = UIColor.whiteColor()
        cityRankOutlet.textColor = UIColor.whiteColor()
        
        if let rootHeight = self.rootController?.view.bounds.height {
            
            UIView.animateWithDuration(0.3, animations: {
                
                self.topContentToHeaderOutlet.constant = -50
                self.contentHeightConstOutlet.constant = rootHeight
                self.commentStuffOutlet.alpha = 0
                
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in
                    
                    self.chatIsRevealed = false
                    self.snapchatChatController?.chatEnlarged = false
                    self.isPanning = false
                    self.longPressEnabled = false

                    
            })
        }
    }
    
    
    
    
    
    func screenToCircle(animatingTime: NSTimeInterval){
        
        if let rootWidth = self.rootController?.view.bounds.width {
            
            self.view.clipsToBounds = true
            self.screenIsCircle = true
            
            UIView.animateWithDuration(animatingTime, animations: {
                
                self.rootController?.snapWidthConstOutlet.constant = (rootWidth-100)
                self.rootController?.snapHeightConstOutlet.constant = (rootWidth-100)
                
                self.view.layer.cornerRadius = (rootWidth-100)/2
                
                self.rootController?.view.layoutIfNeeded()
                self.view.layoutIfNeeded()
                
            })
        }
    }
    
    func screenToNormal(animatingTime: NSTimeInterval){
        
        self.screenIsCircle = false
        
        if let rootHeight = self.rootController?.view.bounds.height, rootWidth = self.rootController?.view.bounds.width {
            
            UIView.animateWithDuration(0.3, animations: {
                
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
    
    func closeWithDirection(x: CGFloat, y: CGFloat, animationTime: NSTimeInterval){
        
        UIView.animateWithDuration(animationTime, animations: {
            
            self.rootController?.snapXOutlet.constant = x
            self.rootController?.snapYOutlet.constant = y
            
            self.rootController?.view.layoutIfNeeded()
            
            }, completion: { (bool) in
                
                self.rootController?.toggleSnapchat({ (bool) in
                    
                    self.isPanning = false
                    self.longPressEnabled = false
                    print("snapchat toggled")
                    
                })
                
        })
        
    }
    
    
    
    //PAN HANDLER
    func panGestureHandler(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        
        guard let rootHeight = self.rootController?.view.bounds.height, rootWidth = self.rootController?.view.bounds.width else {return}
        
        var initialTranslationX: CGFloat = 0
        var initialTransaltionY: CGFloat = 0
        
        switch sender.state {
            
        case.Began:
            
            initialTranslationX = translation.x
            initialTransaltionY = translation.y
            
            isPanning = true
            
            print("initial x: \(initialTranslationX)")
            print("initial y: \(initialTransaltionY)")
            
            
        case .Changed:
            
            if longPressEnabled {
                
                rootController?.snapXOutlet.constant = translation.x
                rootController?.snapYOutlet.constant = translation.y
                
            }
            
        case .Ended:
            
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
                    
                    if screenIsCircle {
                        
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
                    
                    if screenIsCircle {
                        
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
    
    
    func longPressHandler(sender: UILongPressGestureRecognizer){
        
        switch sender.state {
            
        case .Began:
            print("long press began")
            
            screenToCircle(0.3)
            longPressEnabled = true
            
        case .Ended:
            print("long press ended")
            
            if !isPanning {
                
                screenToNormal(0.3)
                
            }
            
        default:
            break
            
        }
    }
    
    
    var currentIndex = 0
    
    func loadSecondaryContent(direction: String, i: Int, completion: Bool -> ()){
        
        if i == posts.count - 1 {
            
            print("end")
            
            if let rootHeight = self.rootController?.view.bounds.height {
                
                self.screenToCircle(0.15)
                self.closeWithDirection(0, y: rootHeight, animationTime: 0.75)
                
            }
            
        } else {
            
            var post = [NSObject : AnyObject]()
            
            
            if let key = post[i] as? String, player = videoPlayers[key] {
                
                player.view.removeFromSuperview()

            }

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
            
            if let imageString = post["imageURL"] as? String, imageURL = NSURL(string: imageString) {
                
                secondaryImageOutlet.sd_setImageWithURL(imageURL, completed: { (image, error, cache, url) in
                    
                    print("image completed")
                    
                })
            }
            
            
            self.slideContent(direction, completion: { (bool) in
                
                completion(bool)
                
            })
            
            
            
        }
    }
    
    
    func slideContent(direction: String, completion: Bool -> ()){
        
        guard let rootWidth = self.rootController?.view.bounds.width else {return}
        
        if direction == "left" {
            
            UIView.animateWithDuration(0.3, animations: {
                
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
            
            UIView.animateWithDuration(0.3, animations: {
                
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
        
        if let chatEnlarged = snapchatChatController?.chatEnlarged {

            if chatEnlarged {
                
                snapchatChatController?.shrinkChat()
   
            } else if nextEnabled && !longPressEnabled {
                
                let scopeIndex = currentIndex
                
                nextEnabled = false
                
                loadSecondaryContent("left", i: scopeIndex, completion: { (bool) in
                    
                    self.loadPrimary("left", i: scopeIndex, completion: { (Bool) in
                        
                    })
                })
            }
        }
    }
    
    
    func loadPrimary(direction: String, i: Int, completion: Bool -> ()){
        
        var post = [NSObject : AnyObject]()
        
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

        if let profileString = post["profilePicture"] as? String, profileURL = NSURL(string: profileString) {
            
            profilePicOutlet.sd_setImageWithURL(profileURL, placeholderImage: nil)
            
        }
        
        if let imageString = post["imageURL"] as? String, imageURL = NSURL(string: imageString) {
            
            imageOutlet.sd_setImageWithURL(imageURL, placeholderImage: nil)
            
        }
        
        if let key = post["postChildKey"] as? String, player = videoPlayers[key] {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.videoOutlet.alpha = 1
                self.videoOutlet.addSubview(player.view)
                player.playFromCurrentTime()
                
            })

        } else {
            
            if let isImage = post["isImage"] as? Bool {
                
                if !isImage {
                    
                    print("load video")
                    
                    if let videoString = post["videoURL"] as? String, videoURL = NSURL(string: videoString), key = post["postChildKey"] as? String {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let player = Player()
                            player.delegate = self
                            self.addChildViewController(player)
                            player.view.frame = self.videoOutlet.bounds
                            player.didMoveToParentViewController(self)
                            player.setUrl(videoURL)
                            player.fillMode = AVLayerVideoGravityResizeAspectFill
                            player.playbackLoops = true
                            
                            self.videoPlayers[key] = player
                            
                            self.videoOutlet.alpha = 1
                            self.videoOutlet.addSubview(player.view)
                            player.playFromCurrentTime()
                            
                            print("video downloaded!")
                            
                        })
                    }
                    
                } else {
                    
                    print("is image!")
    
                }
            }
        }
        
        
        if let caption = post["caption"] as? String {
            
            captionOutlet.text = caption
            
        }
        
        if let rank = post["cityRank"] as? Int {
            
            cityRankOutlet.text = "#" + String(rank)
            
        }
        
        if let firstName = post["firstName"] as? String, lastName = post["lastName"] as? String {
            
            nameOutlet.text = firstName + " " + lastName
            
        }
        
        
        if let postKey = post["postChildKey"] as? String, city = post["city"] as? String {
            
            let ref = "posts/\(city)/\(postKey)"
            currentPostKey = postKey
            snapchatChatController?.currentPostKey = postKey
            snapchatChatController?.passedRef = ref
            
        }
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            snapchatChatController?.senderId = uid
            
        }
        
        if let firstName = self.rootController?.selfData["firstName"] as? String, lastName = self.rootController?.selfData["lastName"] as? String {
            
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
        self.snapchatChatController?.observeTyping()
        self.snapchatChatController?.newObserveMessages()
        
        self.isPanning = false
        self.longPressEnabled = false
        
        completion(true)
        
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
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "snapChatSegue" {
            
            let chatController = segue.destinationViewController as? SnapchatChatController
            snapchatChatController = chatController
            snapchatChatController?.snapchatController = self
            
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
