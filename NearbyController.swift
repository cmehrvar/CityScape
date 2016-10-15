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
    var nearbyUsers = [String]()
    var addedCells = [String:Bool]()
    var dismissedCells = [String:Bool]()
    
    var users = [NSObject : AnyObject]()
    
    var globLocation: CLLocation!

    var timer = NSTimer()
    var s = 0
    
    var transitioning = false
    var currentCityLoaded = false
    
    //Outlets 
    @IBOutlet weak var globCollectionView: UICollectionView!
    @IBOutlet weak var noNearbyOutlet: UIImageView!

    //Collection View Delegates
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (self.view.bounds.width/2)
        let height = width*1.223
        
        let size = CGSize(width: width, height: height)
        
        return size
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if nearbyUsers.count == 0 {
            
            self.noNearbyOutlet.alpha = 1
            
        } else {
            
            self.noNearbyOutlet.alpha = 0
            
        }
        
        return nearbyUsers.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if indexPath.row % 2 == 0 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("leftMatchCollectionCell", forIndexPath: indexPath) as! NearbyMatchCollectionCell
            
            cell.nearbyController = self
            cell.index = indexPath.row
            
            cell.uid = nearbyUsers[indexPath.row]
            
            cell.loadUser(nearbyUsers[indexPath.row])
            
            return cell

        } else {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("rightMatchCollectionCell", forIndexPath: indexPath) as! NearbyMatchCollectionCell
            
            cell.nearbyController = self
            cell.index = indexPath.row
            
            cell.uid = nearbyUsers[indexPath.row]
            
            cell.loadUser(nearbyUsers[indexPath.row])
            
            return cell

        }
    }
    
    //Location Manager Delegates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last {
            
            globLocation = lastLocation
            
            if currentCityLoaded == false {
  
                currentCityLoaded = true
                updateLocationToFirebase()
                
            }
        }
    }
    
    
    //Functions
    func updateLocationToFirebase(){
        
        guard let scopeLocation = globLocation else {return}
        
        let ref = FIRDatabase.database().reference().child("userLocations")
        
        let geoFire = GeoFire(firebaseRef: ref)
        let geoCoder = CLGeocoder()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            
            queryNearby(scopeLocation)
            
            let userRef = FIRDatabase.database().reference().child("users").child(uid)
            
            userRef.updateChildValues(["latitude" : scopeLocation.coordinate.latitude, "longitude" : scopeLocation.coordinate.longitude])
            
            geoCoder.reverseGeocodeLocation(scopeLocation) { (placemark, error) in
                
                if error == nil {
                    
                    if let place = placemark?[0] {
                        
                        if let city = place.locality  {
                            
                            userRef.updateChildValues(["city" : city])
                            
                            if self.rootController?.bottomNavController?.vibesOutlet.text == nil || self.rootController?.bottomNavController?.vibesOutlet.text == "" {
                                
                                self.rootController?.vibesFeedController?.currentCity = city
                                self.rootController?.vibesFeedController?.observeCurrentCityPosts()
                                
                            }
                            
                            
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
            
            geoFire.setLocation(CLLocation(latitude: scopeLocation.coordinate.latitude, longitude: scopeLocation.coordinate.longitude), forKey: uid, withCompletionBlock: { (error) in
                
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
   
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {

                    if key != selfUID {
                        
                        if let myReported = self.rootController?.selfData["reportedUsers"] as? [String : Bool] {

                            if myReported[key] == nil {
                                
                                var add = true
                                
                                if self.dismissedCells[key] != nil {
                                    
                                    add = false
                                    
                                } else if self.addedCells[key] != nil {
                                    
                                    add = false
                                    
                                }
                                
                                if add {
                                    
                                    self.addedCells[key] = true
                                    
                                    let userRef = FIRDatabase.database().reference().child("users").child(key)
                                    
                                    userRef.child("gender").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                        
                                        var isInterested = false
                                        
                                        if let interestedIn = self.rootController?.selfData["interestedIn"] as? [String], userGender = snapshot.value as? String {
                                            
                                            for interest in interestedIn {
                                                
                                                if interest == userGender {
                                                    
                                                    isInterested = true
                                                    
                                                }
                                            }
                                            
                                            if isInterested {
                                                
                                                self.nearbyUsers.append(key)
                                                self.globCollectionView.reloadData()
                                                
                                            }
                                        }
                                    })
                                }
                            }
                            
                        } else {
                            
                            var add = true
                            
                            if self.dismissedCells[key] != nil {
                                
                                add = false
                                
                            } else if self.addedCells[key] != nil {
                                
                                add = false
                                
                            }
                            
                            if add {
                                
                                self.addedCells[key] = true
                                
                                let userRef = FIRDatabase.database().reference().child("users").child(key)
                                
                                userRef.child("gender").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                    
                                    var isInterested = false
                                    
                                    if let interestedIn = self.rootController?.selfData["interestedIn"] as? [String], userGender = snapshot.value as? String {
                                        
                                        for interest in interestedIn {
                                            
                                            if interest == userGender {
                                                
                                                isInterested = true
                                                
                                            }
                                        }
                                        
                                        if isInterested {
                                            
                                            self.nearbyUsers.append(key)
                                            self.globCollectionView.reloadData()
                                            
                                        }
                                    }
                                })
                            }

                        }
                    }
                }
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

        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            print("enabled")
            
            updateLocation()
    
            self.timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(updateLocationToFirebase), userInfo: nil, repeats: true)
        }
    }
    
    
    func requestWhenInUseAuthorization(){
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.Denied {
            
            let title: String = (status == CLAuthorizationStatus.Denied) ? "Location services are off" : "Background location is not enabled"
            let message: String = "To use nearby features you must turn on 'When In Use' in the Location Services Settings"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alert) in
                
                
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
                
                rootController?.hideAllNav({ (bool) in
                    
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
