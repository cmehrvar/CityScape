//
//  NearbyController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-06.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import THLabel
import Contacts

class NearbyController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    //Variables
    weak var rootController: MainRootController?
    let locationManager = CLLocationManager()
    var nearbyUsers = [[NSObject : AnyObject]]()
    var addedCells = [String:Int]()
    var dismissedCells = [String:Bool]()
    
    var globLocation: CLLocation!
    
    var addedIndex = 0
    
    var timer = NSTimer()
    var s = 0
    
    var transitioning = false
    var currentCityLoaded = false
    
    //Outlets
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var horizontalSettingsButtonConstOutlet: NSLayoutConstraint!
    @IBOutlet weak var globCollectionView: UICollectionView!
    
    //Actions
    @IBAction func goToLocationServices(sender: AnyObject) {
        
        if let actualSettingsURL = NSURL(string: UIApplicationOpenSettingsURLString){
            
            UIApplication.sharedApplication().openURL(actualSettingsURL)
            
        }
    }
    
    
    //Collection View Delegates
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (self.view.bounds.width/2)
        let height = width*1.223
        
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyUsers.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("nearbyMatchCollectionCell", forIndexPath: indexPath) as! NearbyMatchCollectionCell
        
        cell.nearbyController = self
        cell.index = indexPath.row
        
        cell.loadUser(nearbyUsers[indexPath.row])
        
        return cell
        
    }
    
    //Location Manager Delegates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last {
            
            globLocation = lastLocation
            
            if currentCityLoaded == false {
                
                
                currentCityLoaded = true
                updateLocationToFirebase()
                
            }
            
            
            //updateLocationToFirebase(lastLocation)
            
            
            /*
             self.timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(updateLocationToFirebase), userInfo: nil, repeats: true)
             */
            
        }
        
    }
    
    
    //Functions
    func updateLocationToFirebase(){
        
        let ref = FIRDatabase.database().reference().child("userLocations")
        
        let geoFire = GeoFire(firebaseRef: ref)
        let geoCoder = CLGeocoder()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            queryNearby(globLocation)
            
            let userRef = FIRDatabase.database().reference().child("users").child(uid)
            
            userRef.updateChildValues(["latitude" : globLocation.coordinate.latitude, "longitude" : globLocation.coordinate.longitude])
            
            geoCoder.reverseGeocodeLocation(globLocation) { (placemark, error) in
                
                if error == nil {
                    
                    if let place = placemark?[0] {
                        
                        if let city = place.locality  {
                            
                            userRef.updateChildValues(["city" : city])
                            
                        }
                        
                        if let state = place.administrativeArea {
                            
                            userRef.updateChildValues(["state" : state])
                            
                        }
                        
                        if let country = place.country {
                            
                            userRef.updateChildValues(["country" : country])
                            
                        }
                    }
                    
                } else {
                    print(error)
                }
            }
            
            geoFire.setLocation(CLLocation(latitude: globLocation.coordinate.latitude, longitude: globLocation.coordinate.longitude), forKey: uid, withCompletionBlock: { (error) in
                
                if error == nil {
                    print("succesfully updated location")
                    
                    
                } else {
                    print(error)
                }
            })
        }
    }
    
    
    
    
    func queryNearby(center: CLLocation){
        
        let ref = FIRDatabase.database().reference().child("userLocations")
        let geoFire = GeoFire(firebaseRef: ref)
        
        if let radius = rootController?.selfData["nearbyRadius"] as? Double {
            
            let circleQuery = geoFire.queryAtLocation(center, withRadius: radius)
            
            circleQuery.observeEventType(.KeyEntered) { (key, location) in
                
                let userRef = FIRDatabase.database().reference().child("users").child(key)
                
                userRef.observeEventType(.Value, withBlock: { (snapshot) in
                    
                    if let value = snapshot.value as? [NSObject : AnyObject], selfUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if value["uid"] as? String != selfUID {
                            
                            var isInterested = false
                            var add = true
                            
                            if let uid = value["uid"] as? String {
                                
                                if self.dismissedCells[uid] != nil {
                                    
                                    add = false
                                    
                                } else if let index = self.addedCells[uid] {
                                    
                                    add = false
                                    self.nearbyUsers[index] = value
                                    self.globCollectionView.reloadData()
                                    
                                }
                                
                                if let interestedIn = self.rootController?.selfData["interestedIn"] as? [String], userGender = value["gender"] as? String {
                                    
                                    for interest in interestedIn {
                                        
                                        if interest == userGender {
                                            
                                            isInterested = true
                                            
                                        }
                                    }
                                }
                                
                                if add && isInterested /*&& !haveSentMatch */{
                                    
                                    self.addedCells[uid] = self.addedIndex
                                    self.nearbyUsers.append(value)
                                    self.addedIndex += 1
                                    self.globCollectionView.reloadData()
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    func updateLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
    }
    
    func checkStatus(){
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.NotDetermined {
            print("denied or not determined")
            
            UIView.animateWithDuration(0.3, animations: {
                self.settingsView.alpha = 1
                self.view.layoutIfNeeded()
            })
            
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse{
            print("enabled")
            
            updateLocation()
            
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(updateLocationToFirebase), userInfo: nil, repeats: true)
            
            
            UIView.animateWithDuration(0.3, animations: {
                self.settingsView.alpha = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    func requestWhenInUseAuthorization(){
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.Denied {
            
            let title: String = (status == CLAuthorizationStatus.Denied) ? "Location services are off" : "Background location is not enabled"
            let message: String = "To use nearby features you must turn on 'When In Use' in the Location Services Settings"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alert) in
                
                UIView.animateWithDuration(0.3, animations: {
                    self.settingsView.alpha = 1
                    self.view.layoutIfNeeded()
                })
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (alert) in
                
                if let actualSettingsURL = NSURL(string: UIApplicationOpenSettingsURLString){
                    
                    UIApplication.sharedApplication().openURL(actualSettingsURL)
                    
                }
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if status == CLAuthorizationStatus.NotDetermined {
            
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func settingsConstraint(){
        
        guard let windowHeight = UIApplication.sharedApplication().keyWindow?.bounds.height else {return}
        let selfHeight = self.view.bounds.height
        
        horizontalSettingsButtonConstOutlet.constant = -((windowHeight - selfHeight)/2)
    }
    
    func invalidateTimer(){
        
        timer.invalidate()
        
    }
    
    func showNav(){
        
        rootController?.showNav(0.3, completion: { (bool) in
            
            print("nav shown")
            
        })
    }
    
    func showVibes(){
        
        self.globCollectionView.scrollEnabled = false
        
        rootController?.toggleVibes({ (bool) in
            
            self.globCollectionView.scrollEnabled = true
            print("vibes toggled")
            
        })
    }
    
    
    func addGestureRecognizers(){
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNav))
        downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        downSwipeGestureRecognizer.delegate = self
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showVibes))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        
    }
    
    
    //ScrollViewDelegates
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if velocity.y > 0 {
            
            if !transitioning {
                
                rootController?.hideTopNav({ (bool) in
                    
                    print("top nav hidden")
                    
                })
                
            }
            
        } else {
            print("velocity negative")
        }
        
        
        print("did end dragging")
        print(velocity)
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        settingsConstraint()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizers()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.nearbyController = self
        
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
        
    }
    
}
