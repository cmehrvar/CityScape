//
//  AppDelegate.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-06-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import AWSCognito
import AVFoundation
import NWPusher
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let releaseMode = "atlasDistribution"
    
    var pusher: NWPusher?
    
    func connectPusher(completion: (Bool) -> ()){
        
        if let url = Bundle.main.url(forResource: releaseMode, withExtension: ".p12") {
            
            let data = try? Data(contentsOf: url)
            
            do {
                
                try pusher = NWPusher.connect(withPKCS12Data: data, password: "cousinhadI@1", environment: NWEnvironment.auto)
                
            } catch let error {
                
                print(error)
                
            }
            
            completion(true)
        }
    }
    
    func pushMessage(uid: String, token: String, message: String) {
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        ref.keepSynced(true)
        ref.child("badgeNumber").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                
                if let badgeNumber = snapshot.value as? Int {
                    
                    let payload: String = "{\"aps\":{\"alert\":\"\(message)\",\"badge\":\(badgeNumber + 1),\"sound\":\"default\"}}"
                    
                    ref.child("badgeNumber").setValue(badgeNumber + 1)
                    
                    DispatchQueue.main.async {
                        
                        if let scopePusher = self.pusher {
                            
                            do {
                                
                                try scopePusher.pushPayload(payload, token: token, identifier: UInt(arc4random()))
                                
                            } catch let error {
                                
                                print(error)
                                
                                self.connectPusher(completion: { (bool) in
                                    
                                    self.pushMessage(uid: uid, token: token, message: message)
                                    
                                })
                            }
                        }
                    }
                }
                
            } else {
                
                let payload = "{\"aps\":{\"alert\":\"\(message)\", \"badge\":\(1), \"sound\":\"default\"}}"
                
                ref.child("badgeNumber").setValue(1)
                
                DispatchQueue.main.async {
                    
                    if let scopePusher = self.pusher {

                        do {
                            
                            try scopePusher.pushPayload(payload, token: token, identifier: UInt(arc4random()))
                            
                        } catch let error {
                            
                            print(error)
                            
                            self.connectPusher(completion: { (bool) in
                                
                                self.pushMessage(uid: uid, token: token, message: message)
                                
                            })

                        }
                    }
                }
            }
        })
    }
    
    var window: UIWindow?
    var selfData = [AnyHashable: Any]()

    //ViewControllers
    weak var mainRootController: MainRootController?
    weak var vibeController: NewVibesController?
    weak var nearbyController: NearbyController?
    
    //Constants
    let CLIENT_ID = "a7708df10b6543febd5b42bb9bd18189"
    let CLIENT_SECRET = "a26fee79-6884-47c3-82e1-c7f8e82a2b23"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.usEast1,
                                                                identityPoolId:"us-east-1:6594b46d-9999-456e-9af7-bace2751204a")
        let configuration = AWSServiceConfiguration(region:.usEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        //AWSNetworkingConfiguration().timeoutIntervalForRequest = 0
        
        //AWSNetworkingConfiguration().timeoutIntervalForResource = 15
        
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch let error {
            print(error)
        }
        
        FIRDatabase.database().persistenceEnabled = true
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        connectPusher { (bool) in
            
            print("connected")
            
        }
        
        
        application.statusBarStyle = .lightContent
        
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        nearbyController?.invalidateTimer()
        nearbyController?.currentCityLoaded = false
        mainRootController?.updateOffline()
        mainRootController?.clearVibesPlayers()
        mainRootController?.clearProfilePlayers()
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("badgeNumber").setValue(0)
            application.applicationIconBadgeNumber = 0
            
        }
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("foreground")
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        FBSDKAppEvents.activateApp()
        
        nearbyController?.requestWhenInUseAuthorization()
        
        mainRootController?.updateOnline()
        
        if vibeController?.currentCity != nil {
            vibeController?.observeCurrentCityPosts()
        }
        
        if selfData["interestedIn"] != nil {
            
            nearbyController?.requestWhenInUseAuthorization()
            nearbyController?.updateLocation()
            
            guard let scopeController = nearbyController else {return}
            
            self.nearbyController?.timer = Timer.scheduledTimer(timeInterval: 30, target: scopeController, selector: #selector(self.nearbyController?.updateLocationToFirebase), userInfo: nil, repeats: true)
            
        }
        
        print("active")
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        application.registerForRemoteNotifications()
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: Data) {
        
        let deviceTokenString = token.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("pushToken").setValue(deviceTokenString)
            
            
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print(error)
        
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        
        print("Received push notification: \(userInfo), identifier: \(identifier)")
        completionHandler()
        
    }
}

