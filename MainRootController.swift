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

class MainRootController: UIViewController {
    
    var selfData = [NSObject : AnyObject]()
    
    var locationFromFirebase = false
    
    var menuIsRevealed = false
    var nearbyIsRevealed = false
    var vibesIsRevealed = false
    var messagesIsRevealed = false

    var currentTab = 0
    
    var timer = NSTimer()
    var s = 0
    
    //Outlets
    @IBOutlet weak var topNavCenter: NSLayoutConstraint!
    @IBOutlet weak var bottomNavCenter: NSLayoutConstraint!
    @IBOutlet weak var vibesTrailing: NSLayoutConstraint!
    @IBOutlet weak var vibesLeading: NSLayoutConstraint!
    @IBOutlet weak var closeMenuContainer: UIView!
    @IBOutlet weak var profileBottom: NSLayoutConstraint!
    @IBOutlet weak var profileTop: NSLayoutConstraint!
    @IBOutlet weak var closeMenuTop: NSLayoutConstraint!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var leadingMenu: NSLayoutConstraint!

    weak var topNavController: TopNavBarController?
    weak var bottomNavController: BottomNavController?
    weak var vibesFeedController: VibesFeedController?
    weak var nearbyController: NearbyController?
    weak var messagesController: MessagesController?
    weak var menuController: MenuController?
    weak var closeController: CloseMenuController?
    weak var profileController: ProfileController?
    
    //Toggle Functions
    func toggleHome(completion: Bool -> ()) {
        
        let screenHeight = self.view.bounds.height - 65
        closeMenuTop.constant = 0

        UIView.animateWithDuration(0.3, animations: {
            
            self.profileTop.constant = -screenHeight
            self.profileBottom.constant = screenHeight

            self.view.layoutIfNeeded()
            
            }) { (complete) in

                self.profileController?.userData = ["profilePicture" : "", "firstName" : "", "lastName" : "", "city" : "", "state" : "", "country" : "", "cityRank" : 0, "squad" : [""], "occupation" : "", "lastActive" : NSDate().timeIntervalSince1970]
                self.profileController?.globCollectionCell.reloadData()
                
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
        
        let mainDrawerWidthConstant: CGFloat = 280
        
        var menuOffset: CGFloat = 0
        
        /*
        var topNavOffset: CGFloat = 0
        var bottomNavOffset: CGFloat = self.bottomNavCenter.constant
        var mainOffsetLeading: CGFloat = self.vibesLeading.constant
        var mainOffsetTrailing: CGFloat = self.vibesTrailing.constant
        */
 
        var closeMenuAlpha: CGFloat = 0
        var buttonsEnabled = true
        
        if !menuIsRevealed {
            closeMenuAlpha = 1
            
            buttonsEnabled = false
            
            //mainOffsetLeading += mainDrawerWidthConstant
            //mainOffsetTrailing += mainDrawerWidthConstant
            
            //topNavOffset = mainDrawerWidthConstant
            
            //bottomNavOffset += mainDrawerWidthConstant
            
        } else {
            
            menuOffset = -mainDrawerWidthConstant
            
            //mainOffsetLeading -= mainDrawerWidthConstant
            //mainOffsetTrailing -= mainDrawerWidthConstant
            
            //bottomNavOffset -= mainDrawerWidthConstant

        }
        
        menuIsRevealed = !menuIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.closeMenuContainer.alpha = closeMenuAlpha
            self.leadingMenu.constant = menuOffset
            
            self.bottomNavController?.nearbyButtonOutlet.enabled = buttonsEnabled
            self.bottomNavController?.vibesButtonOutlet.enabled = buttonsEnabled
            self.bottomNavController?.messagesButtonOutlet.enabled = buttonsEnabled

            //self.topNavCenter.constant = topNavOffset
            //self.bottomNavCenter.constant = bottomNavOffset
            //self.vibesLeading.constant = mainOffsetLeading
            //self.vibesTrailing.constant = mainOffsetTrailing
            
            self.view.layoutIfNeeded()
            
        }) { (complete) in
            
            completion(complete)
            
        }
    }
    
    
    func toggleProfile(uid: String, selfProfile: Bool, completion: Bool -> ()){
        
        self.closeMenuTop.constant = -65
        
        profileController?.currentUID = uid
        profileController?.retrieveUserData(uid, selfProfile: selfProfile)

        UIView.animateWithDuration(0.3, animations: {
            
            self.profileTop.constant = 0
            self.profileBottom.constant = 0
            
            self.view.layoutIfNeeded()
            
            }) { (complete) in
                completion(complete)
        }
    }
    

    //Other Functions
    func toggleTabs(tab: Int) -> Bool {
        
        let vibesConst = self.view.bounds.width
        
        if tab == 1 {
            
            UIView.animateWithDuration(0.6, animations: {
                
                self.vibesLeading.constant = vibesConst
                self.vibesTrailing.constant = vibesConst
                
                self.view.layoutIfNeeded()
                
            })
            
            currentTab = 1
            self.bottomNavController?.toggleColour(1)
            
        } else if tab == 2 {
            
            UIView.animateWithDuration(0.6, animations: {
                self.vibesLeading.constant = 0
                self.vibesTrailing.constant = 0
                
                self.view.layoutIfNeeded()
                
            })
            
            
            currentTab = 2
            self.bottomNavController?.toggleColour(2)
            
        } else if tab == 3 {
            
            UIView.animateWithDuration(0.6, animations: {
                self.vibesLeading.constant = -vibesConst
                self.vibesTrailing.constant = -vibesConst
                
                self.view.layoutIfNeeded()
                
            })
            
            currentTab = 3
            self.bottomNavController?.toggleColour(3)
            
        }
        
        return true
        
    }

    func loadSelfData(completion: Bool -> ()){
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("users").child(selfUID)
            
            ref.observeEventType(.Value, withBlock: { (snapshot) in
                
                if let value = snapshot.value as? [NSObject:AnyObject]{
                    
                    self.selfData = value

                    self.menuController?.setMenu()

                    if !self.locationFromFirebase {
                        
                        self.locationFromFirebase = true
                        
                        if let latitude = value["latitude"] as? CLLocationDegrees, longitude = value["longitude"] as? CLLocationDegrees {
                            
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            self.nearbyController?.queryNearby(location)
                        }                        
                    }

                    completion(true)
                }
            })
        }
    }
    
    
    func setStage(){
        
        let screenHeight = self.view.bounds.height - 65

        profileTop.constant = -screenHeight
        profileBottom.constant = screenHeight
        
        profileContainer.alpha = 1
        
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

    
    
    override func viewDidAppear(animated: Bool) {
        
        
        setStage()
        updateOnline()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateOnline), name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateOffline), name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.leadingMenu.constant = -280
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
            
            let vibes = segue.destinationViewController as? VibesFeedController
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
            
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
