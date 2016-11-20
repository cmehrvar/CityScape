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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MainRootController: UIViewController {
    
    var selfData = [AnyHashable: Any]()
    
    var locationFromFirebase = false
    
    var homeIsVisible = true

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
    var chatRevealed = false
    var composedRevealed = false
    var addToChatRevealed = false
    var leaderboardIsRevealed = false
    var contactUsRevealed = false
    var settingsIsRevealed = false
    var addFromFacebookIsRevealed = false
    var cameraRevealed = false
    
    var vibesLoadedFromSelf = false
    
    var currentTab = 0
    
    var timer = Timer()

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
    
    @IBOutlet weak var bottomChatConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapWidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapYOutlet: NSLayoutConstraint!
    @IBOutlet weak var snapXOutlet: NSLayoutConstraint!
    @IBOutlet weak var notificationWidthConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var notificationTrailingConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var squadBottomConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var requestsBottomConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var squadTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var requestsTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var topChatConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var composeContainerTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var composeContainerBottomConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var topChatHeightConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var addToChatBottomConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var addToChatTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var leaderboardTopOutlet: NSLayoutConstraint!
    @IBOutlet weak var leaderboardBottomOutlet: NSLayoutConstraint!
    @IBOutlet weak var contactTopOutlet: NSLayoutConstraint!
    @IBOutlet weak var contactBottomOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var settingsTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var settingsBottomConstOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var facebookTopConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var facebookBottomConstOutlet: NSLayoutConstraint!

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
    @IBOutlet weak var notificationContainer: UIView!
    @IBOutlet weak var topChatContainerOutlet: UIView!
    @IBOutlet weak var composeContainerOutlet: UIView!
    @IBOutlet weak var requestContainerOutlet: UIView!
    @IBOutlet weak var squadContainerOutlet: UIView!
    @IBOutlet weak var addToChatContainerOutlet: UIView!
    @IBOutlet weak var leaderboardContainerOutlet: UIView!
    @IBOutlet weak var contactUsContainer: UIView!
    @IBOutlet weak var composeChatOutlet: UIButton!
    @IBOutlet weak var settingsContainer: UIView!
    @IBOutlet weak var addFromFacebookContainer: UIView!
    @IBOutlet weak var cameraButtonIcon: UIButton!
    @IBOutlet weak var actionsContainer: UIView!
    @IBOutlet weak var cameraContainer: UIView!
    

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
    weak var requestsController: RequestsController?
    weak var squadCountController: SquadCountController?
    weak var topChatController: TopChatController?
    weak var composeChatController: ComposeChatController?
    weak var addToChatController: AddToChatController?
    weak var leaderBoardController: LeaderboardController?
    weak var contactController: ContactUsController?
    weak var settingsController: SettingsViewController?
    weak var facebookController: AddFromFacebookController?
    weak var cameraController: CameraViewController?

    @IBAction func composeMessage(_ sender: AnyObject) {
        
        toggleHome { (bool) in
            
            self.composeChat(true, completion: { (bool) in
                
                print("compose revealed")
                
            })
        }
    }
    
    @IBAction func callCamera(_ sender: AnyObject) {
        
        showNav(0.3, completion: { (bool) in
            
            self.clearVibesPlayers()
            
            print("camera")
            
            self.toggleCamera(completion: { (bool) in
                
                print("camera presented")
                
            })            
        })
    }
    
    
    /*
    func presentFusumaCamera(){
        
        UIApplication.shared.isStatusBarHidden = true
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.hasVideo = true
        fusuma.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        present(fusuma, animated: true) {
            
            self.cameraTransitionOutlet.alpha = 1
            
            self.view.layoutIfNeeded()
            
        }
    }
    
    //Adobe Delegates
    
    
    func photoEditor(_ editor: AdobeUXImageEditorViewController, finishedWith image: UIImage?) {

        editor.dismiss(animated: false) {
            
            UIApplication.shared.isStatusBarHidden = false
            
            self.toggleHandlePost(image, videoURL: nil, isImage: true, completion: { (bool) in
                
                self.cameraTransitionOutlet.alpha = 0
                print("handle post toggled")
                
            })
            
        }
        
        print("photo editor chosen")
        
    }
    func photoEditorCanceled(_ editor: AdobeUXImageEditorViewController) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        editor.view.window?.layer.add((transition), forKey: nil)
        
        editor.dismiss(animated: false) {
            
            self.cameraTransitionOutlet.alpha = 1
            
            self.presentFusumaCamera()
        }
        print("photo editor cancelled")
        
    }
    
    //Fusuma Delegates
    
    
    func fusumaImageSelected(_ image: UIImage) {
        
        print("image selected")
        
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("fusuma dismissed with image")
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window?.layer.add((transition), forKey: nil)
        
        
        let editorController = AdobeUXImageEditorViewController(image: image)
        editorController.delegate = self
        
        self.present(editorController, animated: false, completion: nil)
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {

        UIApplication.shared.isStatusBarHidden = false
        
        let asset = AVURLAsset(url: fileURL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
        do {
            
            let cgImage =  try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            
            self.toggleHandlePost(uiImage, videoURL: fileURL, isImage: false, completion: { (bool) in
                print("video handled")
                self.cameraTransitionOutlet.alpha = 0
            })
            
            
        } catch let error {
            print(error)
        }
        
        print("fusuma video completed")
        
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
        let alertController = UIAlertController(title: "Sorry", message: "Camera not authorized", preferredStyle:  UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        print("camera unauthorized")
        
    }
    
    func fusumaClosed() {
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.cameraTransitionOutlet.alpha = 0
        
    }
    */
    func alpha0actionBar(){
        
        /*
        UIView.animate(withDuration: 0.3) { 
            
            self.actionsContainer.alpha = 0
            self.cameraButtonIcon.alpha = 0
            self.view.layoutIfNeeded()
            
        }
        */
    }
    
    
    func alpha1actionBar(){
        
        /*
        UIView.animate(withDuration: 0.3) {
            
            self.actionsContainer.alpha = 1
            self.cameraButtonIcon.alpha = 1
            self.view.layoutIfNeeded()
            
        }
 */
        
    }

    //Toggle Functions
    func toggleCamera(completion: @escaping (Bool) -> ()){
        
        var cameraAlpha: CGFloat = 0
        UIApplication.shared.isStatusBarHidden = false
        
        cameraController?.cameraButtonOutlet.setTitleColor(UIColor.init(netHex: 0x077AFF), for: .normal)
        cameraController?.videoButtonOutlet.setTitleColor(UIColor.white, for: .normal)
        
        cameraController?.captureImage = true
        cameraController?.isRecording = false
        cameraController?.videoTimeViewOutlet.alpha = 0
        cameraController?.tapToTakeOutlet.text = "Tap to take a photo!"
        cameraController?.flipCameraButtonOutlet.alpha = 1
        cameraController?.videoTimeLabelOutlet.text = "10s"
        
        cameraController?.captureButtonOutlet.setImage(UIImage(named: "cameraIcon"), for: .normal)
        
        if !cameraRevealed {
            
            cameraAlpha = 1

            //UIApplication.shared.isStatusBarHidden = true
            
        } else {
            
            //UIApplication.shared.isStatusBarHidden = false

        }

        cameraRevealed = !cameraRevealed
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.cameraContainer.alpha = cameraAlpha
        
            self.view.layoutIfNeeded()
            
        }) { (bool) in
            
            self.cameraController?.initializeCamera()
            completion(bool)
            
        }
    }

    func toggleAddFromFacebook(completion: @escaping (Bool) -> ()) {
        
        var offset: CGFloat = 0
        
        if addFromFacebookIsRevealed {
            
            offset = self.view.bounds.height
            
        } else {

            facebookController?.loadFacebookFriends()

        }
        
        addFromFacebookIsRevealed = !addFromFacebookIsRevealed
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.facebookTopConstOutlet.constant = offset
            self.facebookBottomConstOutlet.constant = -offset
            
            self.view.layoutIfNeeded()
            
            }) { (bool) in
                
                completion(bool)
                
        }
    }
    
    
    func toggleSettings(_ completion: @escaping (Bool) -> ()) {
        
        var offset: CGFloat = 0
        
        if settingsIsRevealed {
            
            offset = self.view.bounds.height
            
        }
        
        settingsIsRevealed = !settingsIsRevealed
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.settingsTopConstOutlet.constant = offset
            self.settingsBottomConstOutlet.constant = -offset
            
            self.view.layoutIfNeeded()
            
            }, completion: { (bool) in
                
                completion(bool)
                
        }) 
    }
    
    
    
    func toggleContactUs(_ completion: @escaping (Bool) -> ()) {
        
        var offset: CGFloat = 0
        
        if contactUsRevealed {
            
            offset = self.view.bounds.height
            
        }
        
        contactUsRevealed = !contactUsRevealed
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.contactTopOutlet.constant = offset
            self.contactBottomOutlet.constant = -offset
            
            self.view.layoutIfNeeded()
            
            }, completion: { (bool) in
                
                completion(bool)
                
        }) 
    }
    
    
    func toggleLeaderboard(_ completion: @escaping (Bool) -> ()) {
        
        var offset: CGFloat = 0
        
        if leaderboardIsRevealed {
            
            offset = self.view.bounds.height
            leaderBoardController?.leaders.removeAll()
            leaderBoardController?.globTableviewOutlet.reloadData()
            
        } else {
            
            leaderBoardController?.loadLeaderboard()
            
        }
        
        leaderboardIsRevealed = !leaderboardIsRevealed
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.leaderboardTopOutlet.constant = offset
            self.leaderboardBottomOutlet.constant = -offset
            
            self.view.layoutIfNeeded()
            
            }, completion: { (bool) in
                
                completion(bool)
                
        }) 
    }
    
    
    func toggleHome(_ completion: @escaping (Bool) -> ()) {

        homeIsVisible = true
        
        let screenHeight = self.view.bounds.height
        
        self.squadCountController?.view.endEditing(true)
        self.searchController?.view.endEditing(true)
        self.chatController?.view.endEditing(true)
        self.menuController?.view.endEditing(true)
        self.snapchatController?.view.endEditing(true)
        
        self.vibesFeedController?.navHidden = false

        var searchAlpha: CGFloat = 0
        var scopeSearchRevealed = false
        
        if searchRevealed && profileRevealed {
            
            self.composeChatOutlet.alpha = 0
            searchAlpha = 1
            scopeSearchRevealed = true
            
        } else {
            
            self.composeChatOutlet.alpha = 1
            
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.topNavConstOutlet.constant = 0
            self.bottomNavConstOutlet.constant = 0
            
            self.topChatConstOutlet.constant = -screenHeight
            self.bottomChatConstOutlet.constant = screenHeight
            
            if !self.chatRevealed {
                
                self.requestsTopConstOutlet.constant = -screenHeight
                self.requestsBottomConstOutlet.constant = screenHeight
                
                self.squadTopConstOutlet.constant = -screenHeight
                self.squadBottomConstOutlet.constant = screenHeight
                
            } else {
                
                if self.requestsRevealed {
                    
                    self.requestsTopConstOutlet.constant = 0
                    self.requestsBottomConstOutlet.constant = 0
                    
                    self.squadTopConstOutlet.constant = -screenHeight
                    self.squadBottomConstOutlet.constant = screenHeight

                    
                } else if self.squadCountRevealed {
                    
                    self.requestsTopConstOutlet.constant = -screenHeight
                    self.requestsBottomConstOutlet.constant = screenHeight
                    
                    self.squadTopConstOutlet.constant = 0
                    self.squadBottomConstOutlet.constant = 0
                    
                }
            }

            
            if self.squadCountRevealed || self.requestsRevealed || (self.chatRevealed && self.profileRevealed) {
                
                self.profileContainer.alpha = 1
                self.topProfileConstOutlet.constant = 0
                self.bottomProfileConstOutlet.constant = 0
                
            } else {
                
                self.profileContainer.alpha = 0
                self.topProfileConstOutlet.constant = -screenHeight
                self.bottomProfileConstOutlet.constant = screenHeight
                
            }
            
            self.searchContainerOutlet.alpha = searchAlpha
            
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            self.chatController?.messages.removeAll()
            self.chatController?.messageData.removeAll()
            self.chatController?.addedMessages.removeAll()
            
            self.chatController?.finishReceivingMessage()
            
            self.searchController?.view.endEditing(true)
            
            self.searchRevealed = scopeSearchRevealed
            
            if self.squadCountRevealed || self.requestsRevealed || (self.chatRevealed && self.profileRevealed) {
                
                if !self.chatRevealed {
                    
                    UIApplication.shared.isStatusBarHidden = true
                    self.profileRevealed = true
                    
                } else {
                    
                    if self.profileRevealed {
                        
                        UIApplication.shared.isStatusBarHidden = true
                        
                    } else {
                        
                        UIApplication.shared.isStatusBarHidden = false
                        
                    }
                }
                
            } else {
                
                UIApplication.shared.isStatusBarHidden = false
                
                self.profileRevealed = false
                self.clearProfilePlayers()
                self.profileController?.currentUID = ""
                self.profileController?.userData.removeAll()
                self.profileController?.globCollectionCell.reloadData()
            }
            
            if !self.chatRevealed {
                
                self.squadCountRevealed = false
                self.requestsRevealed = false
                
            } else {
                
                if self.requestsRevealed {
                    
                    self.squadCountRevealed = false
                    self.requestsRevealed = true
                    
                } else if self.squadCountRevealed {
                    
                    self.squadCountRevealed = true
                    self.requestsRevealed = false
                    
                }
            }
            
            if self.profileRevealed {

                if let profileUID = self.profileController?.userData["uid"] as? String {
                    
                    self.profileController?.retrieveUserData(profileUID)
                    
                }
            }

            self.chatRevealed = false
            
            if self.currentTab != 1 {
                
                if let location = self.nearbyController?.globLocation {
                    
                    self.nearbyController?.queryNearby(location)
                    
                }
            }
 
            completion(complete)
            
        }) 
    }

    
    func toggleNearby(_ completion: @escaping (Bool) -> ()) {
        
        if let location = self.nearbyController?.globLocation {
            
            self.nearbyController?.queryNearby(location)
            
        }
        
        DispatchQueue.main.async {
            
            let bool = self.toggleTabs(1)
            completion(bool)
            
        }
    }
    
    
    
    
    func toggleVibes(_ completion: @escaping (Bool) -> ()){
        
        DispatchQueue.main.async {
            
            let bool = self.toggleTabs(2)
            completion(bool)
            
        }
    }
    
    
    
    
    func toggleMessages(_ completion: @escaping (Bool) -> ()){
        
        DispatchQueue.main.async {
            
            let bool = self.toggleTabs(3)
            completion(bool)
            
        }
    }
    
    
    
    
    func toggleMenu(_ completion: @escaping (Bool) -> ()) {
        
        homeIsVisible = false
        
        self.squadCountController?.view.endEditing(true)
        self.searchController?.view.endEditing(true)
        self.chatController?.view.endEditing(true)
        self.menuController?.view.endEditing(true)
        self.snapchatController?.view.endEditing(true)
        
        let mainDrawerWidthConstant: CGFloat = (self.view.bounds.width) * 0.8
        
        var menuOffset: CGFloat = 0
        
        var closeMenuAlpha: CGFloat = 0
        
        if !menuIsRevealed {
            
            closeMenuAlpha = 1
            
        } else {
            
            menuOffset = -mainDrawerWidthConstant
            
        }
        
        menuIsRevealed = !menuIsRevealed
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.closeMenuContainer.alpha = closeMenuAlpha
            self.leadingMenu.constant = menuOffset
            
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            completion(complete)
            
        }) 
    }
    
    
    
    func toggleNotifications(_ completion: @escaping (Bool) -> ()){
        
        homeIsVisible = false
        
        self.squadCountController?.view.endEditing(true)
        self.searchController?.view.endEditing(true)
        self.chatController?.view.endEditing(true)
        self.menuController?.view.endEditing(true)
        self.snapchatController?.view.endEditing(true)

        let mainDrawerWidthConstant: CGFloat = (self.view.bounds.width) * 0.8
        
        var notificationOffset: CGFloat = 0
        
        var closeMenuAlpha: CGFloat = 0
        
        if !notificationRevealed {
            closeMenuAlpha = 1
            
        } else {
            
            notificationOffset = -mainDrawerWidthConstant
            
        }
        
        notificationController?.globTableViewOutlet.reloadData()
        notificationController?.globTableViewOutlet.setContentOffset(CGPoint.zero, animated: true)
        
        notificationRevealed = !notificationRevealed
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.closeMenuContainer.alpha = closeMenuAlpha
            self.notificationTrailingConstOutlet.constant = notificationOffset
            
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            completion(complete)
            
        }) 
    }
    
    
    
    
    func toggleProfile(_ uid: String, selfProfile: Bool, completion: @escaping (Bool) -> ()){
        
        homeIsVisible = false
        
        UIApplication.shared.isStatusBarHidden = true
        
        clearVibesPlayers()
        
        self.squadCountController?.view.endEditing(true)
        self.searchController?.view.endEditing(true)
        self.chatController?.view.endEditing(true)
        self.menuController?.view.endEditing(true)
        self.snapchatController?.view.endEditing(true)
        
        profileRevealed = true

        profileController?.userData.removeAll()
        
        profileController?.globCollectionCell.reloadData()
        profileController?.userPosts.removeAll()
        
        profileController?.globCollectionCell.setContentOffset(CGPoint.zero, animated: false)
        
        profileController?.currentPicture = 1
        profileController?.currentUID = uid
        profileController?.selfProfile = selfProfile

        profileController?.retrieveUserData(uid)
        
        let screenHeight = self.view.bounds.height
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.profileContainer.alpha = 1
            
            self.requestsTopConstOutlet.constant = -screenHeight
            self.requestsBottomConstOutlet.constant = screenHeight
            
            self.squadTopConstOutlet.constant = -screenHeight
            self.squadBottomConstOutlet.constant = screenHeight
            
            self.topNavConstOutlet.constant = 0
            self.bottomProfileConstOutlet.constant = 0
            self.topProfileConstOutlet.constant = 0

            
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            completion(complete)
            
            self.requestsRevealed = false
            self.squadCountRevealed = false
        }) 
    }
    
    
    
    func openSquadCount(_ userData: [AnyHashable: Any], completion: @escaping (Bool) -> ()){

        UIApplication.shared.isStatusBarHidden = false
        
        homeIsVisible = false
        
        if let squad = userData["squad"] as? [AnyHashable: Any] {
            
            var sortedSquad = [[AnyHashable: Any]]()
            
            for (_, value) in squad {
                
                if let valueToAdd = value as? [AnyHashable: Any] {
                    
                    sortedSquad.append(valueToAdd)
                    
                }
            }
            
            sortedSquad.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                
                if a["lastName"] as? String > b["lastName"] as? String {
                    
                    return true
                    
                } else {
                    
                    return false
                    
                }
            })
            
            self.squadCountController?.squad = sortedSquad as [[NSObject : AnyObject]]
            self.squadCountController?.globTableViewOutlet.reloadData()
            
        } else {
            
            self.squadCountController?.squad.removeAll()
            self.squadCountController?.globTableViewOutlet.reloadData()
            
        }

        if let userUID = userData["uid"] as? String, let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            squadCountController?.uid = userUID
            
            squadCountRevealed = true
            
            if userUID == selfUID {
                
                squadCountController?.nameOutlet.text = "My Squad"
                squadCountController?.selfSquad = true
                
            } else {
                
                if let firstName = userData["firstName"] as? String, let lastName = userData["lastName"] as? String {
                    
                    let name = firstName + " " + lastName
                    squadCountController?.nameOutlet.text = name + "'s Squad"
                    squadCountController?.selfSquad = false
                }
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.squadTopConstOutlet.constant = 0
                self.squadBottomConstOutlet.constant = 0
                
                self.view.layoutIfNeeded()
                
            }, completion: { (bool) in
                
                completion(bool)
                
            }) 
        }
    }

    
    func openRequests(_ completion: @escaping (Bool) -> ()){
        
        UIApplication.shared.isStatusBarHidden = false
        
        homeIsVisible = false
        
        requestsRevealed = true
        
        requestsController?.globTableViewOutlet.reloadData()

        UIView.animate(withDuration: 0.3, animations: {
            
            self.requestsTopConstOutlet.constant = 0
            self.requestsBottomConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }, completion: { (bool) in
            
            completion(bool)
            
        }) 
    }
    

    func revealMatch(_ uid: String!, completion: @escaping (Bool) -> ()) {
        
        self.chatController?.view.endEditing(true)
        
        if !matchIsRevealed {
            
            matchIsRevealed = true
            
            if uid != nil {
                
                let ref = FIRDatabase.database().reference()
                ref.keepSynced(true)
                
                ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? [AnyHashable: Any] {
                        
                        self.matchController?.uid = uid
                        
                        if let firstName = value["firstName"] as? String, let lastName = value["lastName"] as? String {
                            
                            self.matchController?.firstName = firstName
                            self.matchController?.lastName = lastName
                            
                            self.matchController?.likesYouOutlet.text = "\(firstName) \(lastName) Likes You"
                            
                        }
                        
                        if let myProfile = self.selfData["profilePicture"] as? String, let url = URL(string: myProfile) {
                            
                            self.matchController?.myProfileOutlet.sd_setImage(with: url, placeholderImage: nil)
                            
                        }
                        
                        
                        if let yourProfile = value["profilePicture"] as? String, let url = URL(string: yourProfile) {
                            
                            self.matchController?.profileString = yourProfile
                            
                            self.matchController?.yourProfileOutlet.sd_setImage(with: url, placeholderImage: nil)
                            
                        }
                        
                        if let myRank = self.selfData["cityRank"] as? Int {
                            
                            self.matchController?.myRankOutlet.text = String(myRank)
                            
                        }
                        
                        if let yourRank = value["cityRank"] as? Int {
                            
                            self.matchController?.yourRankOutlet.text = String(yourRank)
                            
                        }
                        
                        
                        if let myLatitude = self.selfData["latitude"] as? CLLocationDegrees, let myLongitude = self.selfData["longitude"] as? CLLocationDegrees, let yourLatitude = value["latitude"] as? CLLocationDegrees, let yourLongitude = value["longitude"] as? CLLocationDegrees {
                            
                            let myLocation = CLLocation(latitude: myLatitude, longitude: myLongitude)
                            let yourLocation = CLLocation(latitude: yourLatitude, longitude: yourLongitude)
                            
                            let distance = myLocation.distance(from: yourLocation)
                            
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
        
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.itsAMatchContainerOutlet.alpha = 1
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            completion(complete)
            
        }) 
    }
    
    func closeMatch(_ uid: String, profile: String, firstName: String, lastName: String, keepPlaying: Bool, completion: (Bool) -> ()){

        if let myUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference()
            let activityTime = Date().timeIntervalSince1970
            
            let yourMatchData: [AnyHashable: Any] = ["uid" : uid, "lastActivity" : activityTime, "firstName" : firstName, "lastName" : lastName]
            
            if let myFirstName = selfData["firstName"] as? String, let myLastName = selfData["lastName"] as? String {
                
                let myMatchData: [AnyHashable : Any] = ["uid" : myUID, "lastActivity" : activityTime, "firstName" : myFirstName, "lastName" : myLastName]
                ref.child("users").child(uid).child("matches").child(myUID).updateChildValues(myMatchData)
            }

            ref.child("users").child(myUID).child("matches").child(uid).updateChildValues(yourMatchData)
            ref.child("users").child(myUID).child("matchesDisplayed").updateChildValues([uid : true])
            
            var notificationItem = [AnyHashable: Any]()

            notificationItem["firstName"] = firstName
            notificationItem["lastName"] = lastName
            notificationItem["type"] = "likesYou"
            notificationItem["timeStamp"] = activityTime
            notificationItem["read"] = false
            notificationItem["uid"] = uid

            ref.child("users").child(myUID).child("notifications").child(uid).child("likesYou").setValue(notificationItem)
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.itsAMatchContainerOutlet.alpha = 0
                self.view.layoutIfNeeded()
                
                }, completion: { (bool) in

                    if keepPlaying {
                        
                        print("back to last screen")
                        self.matchIsRevealed = false
                        
                    } else {
                        
                        self.toggleMessages({ (bool) in

                            self.toggleChat("matches", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profile, completion: { (bool) in
                                
                                print("chat toggled")
                                
                                self.matchIsRevealed = false
                                
                            })
                            
                        })
                    }
            })
        }
    }
    
    func toggleChat(_ type: String, key: String?, city: String?, firstName: String?, lastName: String?, profile: String?, completion: @escaping (Bool) -> ()) {

        homeIsVisible = false
        
        clearVibesPlayers()
        
        UIApplication.shared.isStatusBarHidden = false
        
        chatRevealed = true
        
        var refToPass = ""
        
        
        if type == "posts" {
            
            topChatController?.settingIconOutlet.image = nil
            topChatController?.settingsButtonOutlet.isEnabled = false
            
        } else {
            
            topChatController?.settingIconOutlet.image = UIImage(named: "settingsIcon")
            topChatController?.settingsButtonOutlet.isEnabled = true
            
        }

        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if type == "matches" {
                
                if let uid = key {
                    
                    chatController?.currentKey = uid
                    topChatController?.uid = uid
                    
                    refToPass = "/users/\(selfUID)/matches/\(uid)"
                    
                }

                topChatController?.iconOutlet.image = UIImage(named: "chatHeartIcon")
                
                topChatController?.type = "matches"
                
                topChatHeightConstOutlet.constant = 85
                topChatController?.singleTitleViewOutlet.alpha = 1
                topChatController?.groupTopViewOutlet.alpha = 0
                topChatController?.postTopViewOutlet.alpha = 0
                
            } else if type == "squad" {
                
                if let uid = key {
                    
                    chatController?.currentKey = uid
                    topChatController?.uid = uid
                    refToPass = "/users/\(selfUID)/squad/\(uid)"
                    
                }

                topChatController?.iconOutlet.image = UIImage(named: "sendSquad")
                
                topChatController?.type = "squad"
                
                topChatHeightConstOutlet.constant = 85
                topChatController?.singleTitleViewOutlet.alpha = 1
                topChatController?.groupTopViewOutlet.alpha = 0
                topChatController?.postTopViewOutlet.alpha = 0
                
            } else if type == "groupChats" {
                
                if let chatKey = key {
                    
                    chatController?.currentKey = chatKey
                    topChatController?.chatKey = chatKey
                    refToPass = "/groupChats/\(chatKey)"
                    
                }
                
                topChatController?.loadGroup()
                topChatController?.globCollectionViewOutlet.setContentOffset(CGPoint.zero, animated: true)
                
                topChatHeightConstOutlet.constant = 184
                topChatController?.singleTitleViewOutlet.alpha = 0
                topChatController?.groupTopViewOutlet.alpha = 1
                topChatController?.postTopViewOutlet.alpha = 0
                
            } else if type == "posts" {
                
                if let scopeCity = city, let scopePostKey = key {
                    
                    chatController?.currentKey = scopePostKey
                    topChatController?.postkey = scopePostKey
                    topChatController?.postCity = scopeCity
                    
                    refToPass = "/posts/\(scopeCity)/\(scopePostKey)"
                    
                    topChatController?.loadPost()
                    
                    topChatHeightConstOutlet.constant = 123
                    topChatController?.singleTitleViewOutlet.alpha = 0
                    topChatController?.groupTopViewOutlet.alpha = 0
                    topChatController?.postTopViewOutlet.alpha = 1
                    
                }
            }
        }
        
        chatController?.passedRef = refToPass
        chatController?.typeOfChat = type
        
        if let firstName = firstName, let lastName = lastName {
            
            topChatController?.nameOutlet.text = firstName + " " + lastName
            
            topChatController?.firstName = firstName
            topChatController?.lastName = lastName
            
        }
        
        if let profileString = profile, let url = URL(string: profileString) {
            
            topChatController?.profilePicOutlet.sd_setImage(with: url, placeholderImage: nil)
            
        }
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            self.chatController?.senderId = uid
        }
        
        if let firstName = selfData["firstName"] as? String, let lastName = selfData["lastName"] as? String {
            
            self.chatController?.senderDisplayName = "\(firstName) \(lastName)"
            
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.topNavConstOutlet.constant = 0
            self.topChatConstOutlet.constant = 0
            self.bottomChatConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            self.chatController?.newObserveMessages()
            
            self.vibesFeedController?.globCollectionView.reloadData()
            
            completion(complete)
            
        }) 
    }
    
    func toggleHandlePost(_ image: UIImage?, videoURL: URL?, isImage: Bool, completion: (Bool) -> ()) {

        print("handlePostIsRevealed: \(handlePostIsRevealed)")
        
        if !handlePostIsRevealed {

            if let myCity = selfData["city"] as? String {
                
                handlePostController?.postToCurrentCityOutlet.text = "Post to \(myCity) feed?"
                
            }
            
            handlePostController?.postToFacebookSelected = false
            handlePostController?.facebookButtonViewOutlet.backgroundColor = UIColor.lightGray
            handlePostController?.postToFacebookLabelOutlet.text = "NO"
            
            handlePostController?.loadTableView()
            handlePostController?.setPostToYes()
            
            handlePostController?.uploadingViewOutlet.alpha = 0
            
            self.handlePostContainer.alpha = 1
            
            handlePostController?.isImage = isImage
            
            if !isImage {
                
                handlePostController?.videoOutlet.alpha = 1
                
            }
    
            handlePostController?.image = image
            
            handlePostController?.videoURL = videoURL
            
            handlePostController?.handleCall()
            completion(true)
            
        } else {
            
            print("handle close")
            
            homeIsVisible = true
            handlePostController?.image = nil
            handlePostController?.videoOutlet.alpha = 0
            
            self.handlePostContainer.alpha = 0
            
                        
        }
        
        handlePostIsRevealed = !handlePostIsRevealed
        
    }
    
    func toggleSnapchat(_ givenPosts: [[AnyHashable: Any]]?, startingi: Int?, completion: @escaping (Bool) -> ()){
        
        snapchatRevealed = true
        
        vibesFeedController?.videoWithSound = ""
        
        //GET RID OF SNAPS
        snapchatController?.posts.removeAll()
        snapchatController?.addedPosts.removeAll()
        
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
        
        if let start = startingi {
            
            if start == 0 {
                
                snapchatController?.currentIndex = 0
                
            } else {
                
                snapchatController?.currentIndex = start - 1
                
            }

        } else {
            
            snapchatController?.currentIndex = 0
            
        }

        snapchatController?.snapchatChatController?.currentPostKey = ""

        if let snapController = snapchatController, let chatController = snapController.snapchatChatController {
            
            NotificationCenter.default.addObserver(chatController, selector: #selector(chatController.hideKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
            NotificationCenter.default.addObserver(chatController, selector: #selector(chatController.showKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
        }

        if let given = givenPosts, let givenIndex = startingi {
            
            self.snapchatController?.posts = given as [[NSObject : AnyObject]]
            
            self.snapchatController?.loadPrimary("left", i: givenIndex - 1, completion: { (complete) in
                
                print("start content loaded")
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isStatusBarHidden = true
                    
                    UIView.animate(withDuration: 0.3, animations: {
  
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
                }
            })
            
            
        } else {
            
            self.snapchatController?.observePosts(100, completion: { (bool) in
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isStatusBarHidden = true
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        
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
                }
            })
        }
    }

    func toggleAddToChat(_ members: [String]?, chatKey: String?, completion: ((Bool) -> ())){
        
        homeIsVisible = false
        
        var topConstOutlet: CGFloat = 0
        var bottomConstOutlet: CGFloat = 0
        
        if addToChatRevealed {
            
            topConstOutlet = self.view.bounds.height
            bottomConstOutlet = -self.view.bounds.height
            
            addToChatController?.squad.removeAll()
            addToChatController?.selectedSquad.removeAll()
            addToChatController?.userSelected.removeAll()
            addToChatController?.dataSoruceForSearchResult.removeAll()
            addToChatController?.members.removeAll()
            addToChatController?.chatKey = ""
            
            addToChatController?.globTableViewOutlet.reloadData()
            addToChatController?.globCollectionViewOutlet.reloadData()

        } else {
            
            if let memberValue = members, let key = chatKey {
                
                addToChatController?.members = memberValue
                addToChatController?.chatKey = key
                
            }
        }
        
        addToChatRevealed = !addToChatRevealed
        
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.addToChatTopConstOutlet.constant = topConstOutlet
            self.addToChatBottomConstOutlet.constant = bottomConstOutlet
            
            self.view.layoutIfNeeded()

        }) 
    }

    
    func toggleSearch(_ completion: @escaping (Bool) -> ()){
        
        homeIsVisible = false
        
        clearVibesPlayers()
        
        searchController?.userController?.observeUsers()
        searchController?.cityController?.observeCities()
        
        searchController?.searchBarOutlet.text = nil
        searchController?.searchBarActive = false
        searchController?.userController?.globCollectionView.reloadData()
        searchController?.cityController?.globCollectionView.reloadData()
        
        self.showNav(0.3) { (bool) in
            
            print("nav shown")
            
            self.searchController?.toggleColour(1)
            
            let screenHeight = self.view.bounds.height
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.topProfileConstOutlet.constant = -screenHeight
                self.bottomProfileConstOutlet.constant = screenHeight
                
                self.squadTopConstOutlet.constant = -screenHeight
                self.squadBottomConstOutlet.constant = screenHeight
                
                self.requestsTopConstOutlet.constant = -screenHeight
                self.requestsBottomConstOutlet.constant = screenHeight
                
                self.searchContainerOutlet.alpha = 1
                self.composeChatOutlet.alpha = 0
                self.view.layoutIfNeeded()
                
            }, completion: { (bool) in
                
                self.searchRevealed = true
                
                self.profileRevealed = false
                self.squadCountRevealed = false
                self.requestsRevealed = false
                completion(bool)
                
            }) 
        }
    }
    
    
    
    func composeChat(_ open: Bool, completion: @escaping (Bool) -> ()) {

        homeIsVisible = false
        
        self.composedRevealed = open
        
        var topConst: CGFloat = 0
        var bottomConst: CGFloat = 0

        if !open {
            
            let screenHeight = self.view.bounds.height
            
            topConst = screenHeight
            bottomConst = -screenHeight

        }

        composeChatController?.globTableViewOutlet.setContentOffset(CGPoint.zero, animated: false)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.composeContainerTopConstOutlet.constant = topConst
            self.composeContainerBottomConstOutlet.constant = bottomConst
            
            self.view.layoutIfNeeded()

            }, completion: { (bool) in
                
                self.composeChatController?.selectedSquad.removeAll()
                self.composeChatController?.userSelected.removeAll()
                self.composeChatController?.getTalkinOutlet.isEnabled = false
                
                self.composeChatController?.globCollectionViewOutlet.reloadData()
                self.composeChatController?.globTableViewOutlet.reloadData()

                completion(bool)
                
        }) 
    }

    
    func hideAllNav(_ completion: @escaping (Bool) -> ()) {
        
        UIApplication.shared.isStatusBarHidden = true
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.topNavConstOutlet.constant = -100
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            completion(complete)
            
        }) 
    }
    
    func hideTopNav(_ completion: @escaping (Bool) -> ()){
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.bottomNavConstOutlet.constant = -40
            
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            completion(complete)
            
        }) 
    }
    
    func showNav(_ animatingTime: TimeInterval, completion: @escaping (Bool) -> ()){
        
        if !self.profileRevealed {
            
            UIApplication.shared.isStatusBarHidden = false
            
        } else {
            
            UIApplication.shared.isStatusBarHidden = true
            
        }
 
        UIView.animate(withDuration: animatingTime, animations: {
            
            self.topNavConstOutlet.constant = 0
            self.bottomNavConstOutlet.constant = 0
            
            self.view.layoutIfNeeded()
            
        }, completion: { (complete) in
            
            
            self.vibesFeedController?.transitioning = false
            self.vibesFeedController?.navHidden = false
            
            completion(complete)
            
        }) 
    }
    
    
    
    
    //Other Functions
    func toggleTabs(_ tab: Int) -> Bool {
        
        homeIsVisible = true
        
        clearVibesPlayers()
        
        if tab == 2 {
            
            vibesFeedController?.globCollectionView.reloadData()
            
        }

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
            self.messagesController?.globTableView.setContentOffset(CGPoint.zero, animated: true)
            
        }
        
        return true
        
    }
    
    func slideWithDirection(_ leading: CGFloat, trailing: CGFloat){
        
        UIView.animate(withDuration: 0.6, animations: {
            
            self.vibesLeading.constant = leading
            self.vibesTrailing.constant = trailing
            
            self.searchContainerOutlet.alpha = 0
            
            self.view.layoutIfNeeded()
            
        }, completion: { (bool) in
            
            print("slid")
            
        }) 
    }
    
    func loadSelfData(_ completion: @escaping ([AnyHashable: Any]) -> ()){
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            
            ref.observe(.value, with: { (snapshot) in

                if let value = snapshot.value as? [AnyHashable: Any]{
                    
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        
                        appDelegate.selfData = value as [NSObject : AnyObject]
                        
                    }
                    
                    self.selfData = value
                    
                    if let currentSnapID = self.snapchatController?.currentUID {
                        
                        self.snapchatController?.checkSquad(currentSnapID, selfUID: selfUID)
                        
                    }

                    self.messagesController?.sortMessages(value)

                    if self.profileController?.currentUID == selfUID {
                        
                        self.profileController?.userData.removeAll()
                        self.profileController?.userPosts.removeAll()
                        
                        self.profileController?.userData = value as [NSObject : AnyObject]
                        
                        self.profileController?.retrieveUserData(selfUID)
                        
                    }
                    
                    if let keyboardShown = self.menuController?.keyboardShown {
                        
                        if !keyboardShown {
                            
                            if let currentStatus = value["currentStatus"] as? String {
                                
                                self.menuController?.currentStatusTextViewOutlet.text = currentStatus
                                self.menuController?.charactersOutlet.text = "\(currentStatus.characters.count)/30 Characters"
                                
                            }
                        } 
                    }
    
                    
                    if let city = value["city"] as? String {
                        
                        let replacedCity = city.replacingOccurrences(of: ".", with: "")
                        self.vibesFeedController?.currentCity = replacedCity
                        
                    }
                    
                    if !self.matchIsRevealed {
                        self.checkForMatches()
                    }
                    
                    
                    
                    if let matches = value["matches"] as? [AnyHashable: Any] {
                        
                        self.messagesController?.loadMatches(matches)
                        self.messagesController?.noMatchesOutlet.alpha = 0
                        
                    } else {
                        
                        self.messagesController?.noMatchesOutlet.alpha = 1
                        self.messagesController?.globMatches.removeAll()
                        self.messagesController?.globCollectionViewOutlet.reloadData()
                        
                    }
                    
                    self.menuController?.setMenu()

                    //NOTIFICATIONS - selfLoadData
                    if let notifications = value["notifications"] as? [AnyHashable: Any] {

                        var sortedNotifications = [[AnyHashable: Any]]()
                        
                        var index = 0
                        
                        for (_, value) in notifications {
                            
                            if let userValue = value as? [AnyHashable: Any] {
                                
                                for (_, value) in userValue {
                                    
                                    if let valueToAdd = value as? [AnyHashable: Any] {
                                        
                                        sortedNotifications.append(valueToAdd)
                                        
                                        if let read = valueToAdd["read"] as? Bool {
                                            
                                            if !read {
                                                
                                                index += 1
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
        
                        sortedNotifications.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                            
                            if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                
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

                        self.notificationController?.globNotifications = sortedNotifications as [[NSObject : AnyObject]]
                        
                    } else {
                        
                        self.topNavController?.numberOfNotificationsViewOutlet.alpha = 0
                        self.notificationController?.globNotifications.removeAll()
                        

                    }

                    //Requests
                    if let requests = value["squadRequests"] as? [AnyHashable: Any] {
                        
                        var sortedRequests = [[AnyHashable: Any]]()
                        
                        for (_, value) in requests {
                            
                            if let valueToAdd = value as? [AnyHashable: Any] {
                                
                                if valueToAdd["status"] as? Int == 0 {
                                    
                                    sortedRequests.append(valueToAdd)
                                    
                                }
                            }
                        }
                        
                        sortedRequests.sort(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                            
                            if a["timeStamp"] as? TimeInterval > b["timeStamp"] as? TimeInterval {
                                
                                return true
                                
                            } else {
                                
                                return false
                                
                            }
                        })
                        
                        self.requestsController?.numberOfRequestsOutlet.text = "Requests: \(sortedRequests.count)"
                        self.requestsController?.requests = sortedRequests as [[NSObject : AnyObject]]
                        
                    } else {
                        
                        self.requestsController?.numberOfRequestsOutlet.text = "Requests: 0"
                        self.requestsController?.requests.removeAll()

                    }

                    if self.vibesLoadedFromSelf == false {
                        
                        self.vibesLoadedFromSelf = true

                        if value["interestedIn"] != nil {

                            self.nearbyController?.requestWhenInUseAuthorization()
                            self.nearbyController?.updateLocation()

                        } else {
                            
                            self.askInterestedIn()
                            
                        }
                        
                        self.vibesFeedController?.observeCurrentCityPosts()
                        self.updateOnline()
                        
                    }
                    
                    if let interestedIn = value["interestedIn"] as? [String] {
                        
                        if interestedIn.count > 1 {
                            
                            self.settingsController?.toggleInterestedInColor(3)
                            
                        } else {
                            
                            for gender in interestedIn {

                                if gender == "male" {
                                    
                                    self.settingsController?.toggleInterestedInColor(1)

                                    
                                } else if gender == "female" {
                                    
                                    self.settingsController?.toggleInterestedInColor(2)

                                    
                                }
                            }
                        }
                    }
                    
                    if let gender = value["gender"] as? String {
                        
                        if gender == "male" {
                            
                            self.settingsController?.toggleGenderColour(1)
                            
                        } else if gender == "female" {
                            
                            self.settingsController?.toggleGenderColour(2)
                            
                        }
                    }
                    

                    if let squad = value["squad"] as? [AnyHashable: Any] {
                        
                        self.composeChatController?.loadTableView(squad)
                        
                    }
                    
                    if self.searchController?.cityController?.globCities.count == 0 {
                        
                        self.searchController?.cityController?.observeCities()
                        
                    }

                    self.profileController?.globCollectionCell.reloadData()
                    self.squadCountController?.globTableViewOutlet.reloadData()
                    self.facebookController?.globTableViewOutlet.reloadData()
                    
                    
                    completion(value)
                    
                }
            })
        }
    }
    
    func checkForMatches(){

        var uidToShow: String?

        if let displayed = selfData["matchesDisplayed"] as? [String : Bool] {

            for (key, value) in displayed {
                
                if value == false {
                    
                    uidToShow = key
                    
                }
            }
            
            if let uid = uidToShow {
                
                let userPushRef = FIRDatabase.database().reference().child("users").child(uid).child("pushToken")
                userPushRef.keepSynced(true)
                
                userPushRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        
                        if let myFirstName = self.selfData["firstName"] as? String, let myLastName = self.selfData["lastName"] as? String {
                            
                            appDelegate.pushMessage(uid: uid, token: token, message: "You've matched with \(myFirstName) \(myLastName)!")
                            
                        }
                    }
                })

                
                self.revealMatch(uidToShow, completion: { (bool) in
                    
                    print("match shown")
                    
                })
            }
        }
        
        if uidToShow == nil {
            
            if let mySentMatches = selfData["sentMatches"] as? [String : Bool] {
                
                for (key, value) in mySentMatches {
                    
                    if !value {
                        
                        if let myUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            let ref = FIRDatabase.database().reference().child("users").child(key).child("sentMatches").child(myUID)
                            ref.keepSynced(true)
                            
                            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                if snapshot.exists() {
                                    
                                    let userPushRef = FIRDatabase.database().reference().child("users").child(key).child("pushToken")
                                    userPushRef.keepSynced(true)
                                    
                                    userPushRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        if let token = snapshot.value as? String, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                            
                                            if let myFirstName = self.selfData["firstName"] as? String, let myLastName = self.selfData["lastName"] as? String {
                                                
                                                appDelegate.pushMessage(uid: key, token: token, message: "You've matched with \(myFirstName) \(myLastName)!")
                                                
                                            }
                                        }
                                    })
                                    
                                    let usersLocRef = FIRDatabase.database().reference().child("users")
                                    usersLocRef.keepSynced(true)
                                    
                                    usersLocRef.child(key).child("matchesDisplayed").child(myUID).observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        if !snapshot.exists() {
                                            
                                            usersLocRef.child(key).child("matchesDisplayed").updateChildValues([myUID : false])
                                        }
                                        
                                    })
     
                                    usersLocRef.child(myUID).child("matchesDisplayed").child(key).setValue(false)
                                    
                                    
                                    usersLocRef.child(myUID).child("sentMatches").updateChildValues([key : true])
                                    
                                }
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
        
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateActive), userInfo: nil, repeats: true)
        
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
            
            let date = Date().timeIntervalSince1970
            
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.updateChildValues(["lastActive" : date])
            
        }
    }
    
    func askInterestedIn(){
        
        let alertController = UIAlertController(title: "Gender Preference", message: "This information is needed to match with good looking people around you!", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Men", style: .default, handler: { (alert) in
            
            print("men selected")
            
            let ref = FIRDatabase.database().reference()
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                ref.child("users").child(uid).updateChildValues(["interestedIn" : ["male"]])
                self.selfData["interestedIn"] = ["male"]

                self.nearbyController?.requestWhenInUseAuthorization()
                self.nearbyController?.updateLocation()
                
                self.vibesFeedController?.observeCurrentCityPosts()
                
                
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Women", style: .default, handler: { (alert) in
            
            print("women selected")
            
            let ref = FIRDatabase.database().reference()
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                ref.child("users").child(uid).updateChildValues(["interestedIn" : ["female"]])
                self.selfData["interestedIn"] = ["female"]
    
                self.nearbyController?.requestWhenInUseAuthorization()
                self.nearbyController?.updateLocation()
                
                self.vibesFeedController?.observeCurrentCityPosts()
                
            }
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Men & Women", style: .default, handler: { (alert) in
            
            print("men and women selected")
            
            let ref = FIRDatabase.database().reference()
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                ref.child("users").child(uid).updateChildValues(["interestedIn" : ["male", "female"]])
                self.selfData["interestedIn"] = ["male", "female"]

                self.nearbyController?.requestWhenInUseAuthorization()
                self.nearbyController?.updateLocation()
                
                self.vibesFeedController?.observeCurrentCityPosts()
                
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    func clearProfilePlayers(){
        
        if let profile = profileController {
            
            for i in 0..<20 {
                
                profile.videoKeys[i] = nil
                
                if profile.videoPlayersObserved[i] {
                    
                    profile.videoPlayers[i]?.removeObserver(profile, forKeyPath: "rate")
                    
                }
                
                profile.videoPlayersObserved[i] = false
                
                if let player = profile.videoPlayers[i] {
                    
                    player.pause()
                    
                    if profile.videoPlayersObserved[i] {
                        
                        player.removeObserver(profile, forKeyPath: "rate")
                        
                    }
                }
                
                if let layer = profile.videoLayers[i] {
                    
                    layer.removeFromSuperlayer()
                    
                }
                
                profile.videoPlayers[i] = nil
                profile.videoLayers[i] = nil
                profile.videoAssets.removeAll()

                
            }
        }
    }
    
    
    func clearVibesPlayers(){
        
        if let vibes = vibesFeedController {
            
            vibes.videoWithSound = ""
            
            if let profile = profileController {
                
                for i in 0..<8 {
                    
                    vibes.videoKeys[i] = nil
                    
                    if vibes.videoPlayersObserved[i] {
                        
                        vibes.videoPlayers[i]?.removeObserver(vibes, forKeyPath: "rate")
                        
                    }
                    
                    vibes.videoPlayersObserved[i] = false
                    
                    if let player = vibes.videoPlayers[i] {
                        
                        player.pause()
                        
                        if vibes.videoPlayersObserved[i] {
                            
                            player.removeObserver(profile, forKeyPath: "rate")
                            
                        }
                    }
                    
                    if let layer = vibes.videoLayers[i] {
                        
                        layer.removeFromSuperlayer()
                        
                    }
                    
                    vibes.videoPlayers[i] = nil
                    vibes.videoLayers[i] = nil
                    vibes.videoAssets.removeAll()

                }
            }
        }
    }
    
    
    
    func setStage() {
        
        DispatchQueue.main.async {
            
            let screenHeight = self.view.bounds.height
            let screenWidth = self.view.bounds.width
            
            self.snapchatController?.topContentToHeaderOutlet.constant = -50
            self.snapchatController?.contentHeightConstOutlet.constant = screenHeight
            self.snapchatController?.commentStuffOutlet.alpha = 0

            self.snapchatController?.alphaHeaderOutlet.alpha = 0.4
            self.snapchatController?.alphaHeaderOutlet.backgroundColor = UIColor.lightGray
            
            self.snapWidthConstOutlet.constant = screenWidth
            self.snapHeightConstOutlet.constant = screenHeight
            
            self.topProfileConstOutlet.constant = -screenHeight
            self.bottomProfileConstOutlet.constant = screenHeight
            
            self.squadTopConstOutlet.constant = -screenHeight
            self.squadBottomConstOutlet.constant = screenHeight
            
            self.requestsTopConstOutlet.constant = -screenHeight
            self.requestsBottomConstOutlet.constant = screenHeight
            
            self.topChatConstOutlet.constant = -screenHeight
            self.bottomChatConstOutlet.constant = screenHeight
            
            self.addToChatTopConstOutlet.constant = screenHeight
            self.addToChatBottomConstOutlet.constant = -screenHeight
            
            self.composeContainerTopConstOutlet.constant = screenHeight
            self.composeContainerBottomConstOutlet.constant = -screenHeight
            
            self.leaderboardTopOutlet.constant = screenHeight
            self.leaderboardBottomOutlet.constant = -screenHeight
            
            self.contactTopOutlet.constant = screenHeight
            self.contactBottomOutlet.constant = -screenHeight
            
            self.settingsTopConstOutlet.constant = screenHeight
            self.settingsBottomConstOutlet.constant = -screenHeight
            
            self.facebookTopConstOutlet.constant = screenHeight
            self.facebookBottomConstOutlet.constant = -screenHeight
            

            self.menuWidthConstOutlet.constant = screenWidth * 0.8
            self.leadingMenu.constant = -(screenWidth * 0.8)
            
            self.notificationWidthConstOutlet.constant = screenWidth * 0.8
            self.notificationTrailingConstOutlet.constant = -(screenWidth * 0.8)
            
            self.vibesLeading.constant = screenWidth
            self.vibesTrailing.constant = -screenWidth

            self.bottomNavController?.toggleColour(1)
            
            self.topChatContainerOutlet.alpha = 1
            self.chatContainerOutlet.alpha = 1
            self.profileContainer.alpha = 1
            self.menuContainerOutlet.alpha = 1
            self.notificationContainer.alpha = 1
            self.squadContainerOutlet.alpha = 1
            self.requestContainerOutlet.alpha = 1
            self.addToChatContainerOutlet.alpha = 1
            self.composeContainerOutlet.alpha = 1
            self.leaderboardContainerOutlet.alpha = 1
            self.contactUsContainer.alpha = 1
            self.settingsContainer.alpha = 1
            self.addFromFacebookContainer.alpha = 1
            
            self.snapchatContainerOutlet.alpha = 0
            self.searchContainerOutlet.alpha = 0
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate.mainRootController = self
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "vibesFeedSegue" {
            
            let vibes = segue.destination as? NewVibesController
            vibesFeedController = vibes
            vibesFeedController?.rootController = self
            
        } else if segue.identifier == "menuSegue" {
            
            let menu = segue.destination as? MenuController
            menuController = menu
            menuController?.rootController = self
            
        } else if segue.identifier == "nearbySegue" {
            
            let nearby = segue.destination as? NearbyController
            nearbyController = nearby
            nearbyController?.rootController = self
            
        } else if segue.identifier == "messagesSegue" {
            
            let messages = segue.destination as? MessagesController
            messagesController = messages
            messagesController?.rootController = self
            
        } else if segue.identifier == "topNavSegue" {
            
            let topNav = segue.destination as? TopNavBarController
            topNavController = topNav
            topNavController?.rootController = self
            
        } else if segue.identifier == "bottomNavSegue" {
            
            let bottomNav = segue.destination as? BottomNavController
            bottomNavController = bottomNav
            bottomNavController?.rootController = self
            
        } else if segue.identifier == "closeSegue" {
            
            let close = segue.destination as? CloseMenuController
            closeController = close
            closeController?.rootController = self
            
        } else if segue.identifier == "profileSegue" {
            
            let profile = segue.destination as? ProfileController
            profileController = profile
            profileController?.rootController = self
            
        } else if segue.identifier == "matchSegue" {
            
            let match = segue.destination as? ItsAMatchController
            matchController = match
            matchController?.rootController = self
            
        } else if segue.identifier == "chatSegue" {
            
            let chat = segue.destination as? CommentController
            chatController = chat
            chatController?.rootController = self
            
        } else if segue.identifier == "actionsSegue" {
            
            let actions = segue.destination as? ActionsViewController
            actionsController = actions
            actionsController?.rootController = self
            
        } else if segue.identifier == "handlePostSegue" {
            
            let handlePost = segue.destination as? HandlePostController
            handlePostController = handlePost
            handlePostController?.rootController = self

        } else if segue.identifier == "snapchatSegue" {
            
            let snapchat = segue.destination as? SnapchatViewController
            snapchatController = snapchat
            snapchatController?.rootController = self
            
        } else if segue.identifier == "searchSegue" {
            
            let search = segue.destination as? SearchController
            searchController = search
            searchController?.rootController = self
            
        } else if segue.identifier == "notificationSegue" {
            
            let notification = segue.destination as? NotificationController
            notificationController = notification
            notificationController?.rootController = self
            
        } else if segue.identifier == "requestsSegue" {
            
            let request = segue.destination as? RequestsController
            requestsController = request
            requestsController?.rootController = self
            
        } else if segue.identifier == "squadCountSegue" {
            
            let squadCount = segue.destination as? SquadCountController
            squadCountController = squadCount
            squadCountController?.rootController = self
            
        } else if segue.identifier == "topChatSegue" {
            
            let topChat = segue.destination as? TopChatController
            topChatController = topChat
            topChatController?.rootController = self
            
        } else if segue.identifier == "composeChatSegue" {
            
            let composeChat = segue.destination as? ComposeChatController
            composeChatController = composeChat
            composeChatController?.rootController = self

        } else if segue.identifier == "addToChatSegue" {
            
            let addToChat = segue.destination as? AddToChatController
            addToChatController = addToChat
            addToChatController?.rootController = self
            
        } else if segue.identifier == "leaderSegue" {
            
            let leader = segue.destination as? LeaderboardController
            leaderBoardController = leader
            leaderBoardController?.rootController = self
            
        } else if segue.identifier == "contactSegue" {
            
            let contact = segue.destination as? ContactUsController
            contactController = contact
            contactController?.rootController = self
            
        } else if segue.identifier == "settingsSegue" {
            
            let settings = segue.destination as? SettingsViewController
            settingsController = settings
            settingsController?.rootController = self
            
        } else if segue.identifier == "addFromFacebookSegue" {
            
            let facebook = segue.destination as? AddFromFacebookController
            facebookController = facebook
            facebookController?.mainRootController = self
            
            
        } else if segue.identifier == "cameraSegue" {
            
            let camera = segue.destination as? CameraViewController
            cameraController = camera
            cameraController?.rootController = self
            
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
