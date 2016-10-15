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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var pusher: NWPusher?

    func pushMessage(uid: String, token: String, message: String) {
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)

        ref.child("badgeNumber").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists() {
                
                if let badgeNumber = snapshot.value as? Int {
                    
                    
                    
                    let payload: String = "{\"aps\":{\"alert\":\"\(message)\",\"badge\":\(badgeNumber + 1),\"sound\":\"default\"}}"
                    
                    ref.child("badgeNumber").setValue(badgeNumber + 1)
                    
                    if let scopePusher = self.pusher {
                        
                        do {

                            try scopePusher.pushPayload(payload, token: token, identifier: UInt(rand()))
                            
                        } catch let error {
                            
                            print(error)
                            
                        }
                    }
                }
                
            } else {
                
                let payload = "{\"aps\":{\"alert\":\"\(message)\", \"badge\":\(1), \"sound\":\"default\"}}"
                
                ref.child("badgeNumber").setValue(1)
                
                if let scopePusher = self.pusher {
                    
                    do {
                        
                        try scopePusher.pushPayload(payload, token: token, identifier: UInt(rand()))
                        
                    } catch let error {
                        
                        print(error)
                        
                    }
                }
            }
        })
    }

    var window: UIWindow?
    var selfData = [NSObject : AnyObject]()
    
    //ViewControllers
    weak var mainRootController: MainRootController?
    weak var vibeController: NewVibesController?
    weak var nearbyController: NearbyController?

    //Constants
    let CLIENT_ID = "a7708df10b6543febd5b42bb9bd18189"
    let CLIENT_SECRET = "a26fee79-6884-47c3-82e1-c7f8e82a2b23"


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:"us-east-1:6594b46d-9999-456e-9af7-bace2751204a")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        AWSNetworkingConfiguration().timeoutIntervalForRequest = 0
        
        AWSNetworkingConfiguration().timeoutIntervalForResource = 15
        
        AdobeUXAuthManager.sharedManager().setAuthenticationParametersWithClientID(CLIENT_ID, withClientSecret: CLIENT_SECRET)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch let error {
            print(error)
        }
        
        FIRDatabase.database().persistenceEnabled = true
        
        if application.respondsToSelector(#selector(application.registerUserNotificationSettings)) {
            
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        }
        
        if let url = NSBundle.mainBundle().URLForResource("AtlasProduction", withExtension: ".p12") {
            
            let data = NSData(contentsOfURL: url)
            
            do {
                
                try pusher = NWPusher.connectWithPKCS12Data(data, password: "cousinhadI@1", environment: NWEnvironment.Auto)
                
            } catch let error {
                
                print(error)
                
            }
            
            if pusher != nil {
                
                print("good pusher")
                
            } else {
                
                print("bad pusher")
                
            }
        }

        application.statusBarStyle = .LightContent
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
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

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("foreground")
                
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
        nearbyController?.checkStatus()

        mainRootController?.updateOnline()

        if vibeController?.currentCity != nil {
            vibeController?.observeCurrentCityPosts()
        }

        if selfData["interestedIn"] != nil {
            
            nearbyController?.requestWhenInUseAuthorization()
            nearbyController?.updateLocation()
            
            guard let scopeController = nearbyController else {return}
            
            self.nearbyController?.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: scopeController, selector: #selector(self.nearbyController?.updateLocationToFirebase), userInfo: nil, repeats: true)
            
        }
        
        print("active")
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        application.registerForRemoteNotifications()
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken token: NSData) {
        
        var pushToken = token.description
        pushToken = pushToken.stringByReplacingOccurrencesOfString("<", withString: "")
        pushToken = pushToken.stringByReplacingOccurrencesOfString(">", withString: "")
        pushToken = pushToken.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            FIRDatabase.database().reference().child("users").child(selfUID).child("pushToken").setValue(pushToken)
            
            
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {

        print(error)
        
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        print("Received push notification: \(userInfo), identifier: \(identifier)")
        completionHandler()
        
    }
}

