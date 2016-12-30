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

    var globLocation: CLLocation!

    var timer = Timer()
    var s = 0
    
    var transitioning = false
    var currentCityLoaded = false
    
    //Outlets 
    @IBOutlet weak var globCollectionView: UICollectionView!
    @IBOutlet weak var noNearbyOutlet: UIImageView!

    //Collection View Delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.bounds.width)/2
        let height = width*1.223
        
        let size = CGSize(width: width, height: width + 34)
        
        return size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return nearbyUsers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if (indexPath as NSIndexPath).row % 2 == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "leftMatchCollectionCell", for: indexPath) as! NearbyMatchCollectionCell
            
            cell.nearbyController = self
            cell.index = (indexPath as NSIndexPath).row
            
            cell.uid = nearbyUsers[(indexPath as NSIndexPath).row]
            
            cell.loadUser(nearbyUsers[(indexPath as NSIndexPath).row])
            
            return cell

        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rightMatchCollectionCell", for: indexPath) as! NearbyMatchCollectionCell
            
            cell.nearbyController = self
            cell.index = (indexPath as NSIndexPath).row
            
            cell.uid = nearbyUsers[(indexPath as NSIndexPath).row]
            
            cell.loadUser(nearbyUsers[(indexPath as NSIndexPath).row])
            
            return cell

        }
    }
    
    var nearbyQueried = false
    
    //Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last {

            globLocation = lastLocation
            
            if !nearbyQueried {
                
                nearbyQueried = true
                queryNearby(lastLocation)
                
            }
  
            if currentCityLoaded == false {
  
                currentCityLoaded = true
                updateLocationToFirebase()

            }
        }
    }

    //Functions
    func updateLocationToFirebase(){
        
        guard let scopeLocation = globLocation else {return}

        let geoCoder = CLGeocoder()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {

            let userRef = FIRDatabase.database().reference().child("users").child(uid)
            
            userRef.updateChildValues(["latitude" : scopeLocation.coordinate.latitude, "longitude" : scopeLocation.coordinate.longitude])
            
            geoCoder.reverseGeocodeLocation(scopeLocation) { (placemark, error) in
                
                if error == nil {
                    
                    if let place = placemark?[0] {
                        
                        if let city = place.locality  {
                            
                            let replacedCity = city.replacingOccurrences(of: ".", with: "")
   
                            userRef.updateChildValues(["city" : replacedCity])

                            if self.rootController?.bottomNavController?.torontoOutlet.text == nil || self.rootController?.bottomNavController?.torontoOutlet.text == "" {

                                self.rootController?.vibesFeedController?.currentCity = replacedCity
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
            
            
            if let selfUID = FIRAuth.auth()?.currentUser?.uid, let selfData = self.rootController?.selfData, let myGender = selfData["gender"] as? String, let myInterests = selfData["interestedIn"] as? [String] {
                
                FIRDatabase.database().reference().child("userLocations").child(selfUID).updateChildValues(["gender" : myGender, "interests" : myInterests, "l" : [scopeLocation.coordinate.latitude, scopeLocation.coordinate.longitude]])
                
            }
        }
    }
    
    
    
    
    func queryNearby(_ center: CLLocation){
        
        let ref = FIRDatabase.database().reference().child("userLocations")
        ref.keepSynced(true)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let value = snapshot.value as? [AnyHashable : Any] {
                
                var locations = [[AnyHashable : Any]]()
                
                for (key, locationValue) in value {

                    if let locationUID = key as? String, let dictLocationValue = locationValue as? [AnyHashable : Any], let yourGender = dictLocationValue["gender"] as? String, let location = dictLocationValue["l"] as? [CLLocationDegrees], let yourInterests = dictLocationValue["interests"] as? [String] {
                        
                        let latitude = location[0]
                        let longitude = location[1]
                        
                        if let myUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            if locationUID != myUID {
                                
                                if let myReported = self.rootController?.selfData["reportedUsers"] as? [String : Bool] {
                                    
                                    if myReported[locationUID] == nil {
                                        
                                        var add = true
                                        
                                        if self.dismissedCells[locationUID] != nil {
                                            
                                            add = false
                                            
                                        }
                                        
                                        if add {
                                            
                                            var iWantYou = false
                                            var youWantMe = false
                                            
                                            if let myInterests = self.rootController?.selfData["interestedIn"] as? [String], let myGender = self.rootController?.selfData["gender"] as? String {
                                                
                                                for myInterest in myInterests {
                                                    
                                                    if myInterest == yourGender {
                                                        
                                                        iWantYou = true
                                                        
                                                    }
                                                }
                                                
                                                for yourInterest in yourInterests {
                                                    
                                                    if yourInterest == myGender {
                                                        
                                                        youWantMe = true
                                                        
                                                    }
                                                }
                                                
                                                if iWantYou && youWantMe {
                                                    
                                                    let point = CLLocation(latitude: latitude, longitude: longitude)
                                                    let locationData: [AnyHashable : Any] = ["uid" : locationUID, "point" : point]
                                                    locations.append(locationData)
                                                    
                                                }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    
                                    var add = true
                                    
                                    if self.dismissedCells[locationUID] != nil {
                                        
                                        add = false
                                        
                                    }
                                    
                                    if add {
                                        
                                        var iWantYou = false
                                        var youWantMe = false
                                        
                                        if let myInterests = self.rootController?.selfData["interestedIn"] as? [String], let myGender = self.rootController?.selfData["gender"] as? String {
                                            
                                            for myInterest in myInterests {
                                                
                                                if myInterest == yourGender {
                                                    
                                                    iWantYou = true
                                                    
                                                }
                                            }
                                            
                                            for yourInterest in yourInterests {
                                                
                                                if yourInterest == myGender {
                                                    
                                                    youWantMe = true
                                                    
                                                }
                                            }
                                            
                                            if iWantYou && youWantMe {
                                                
                                                let point = CLLocation(latitude: latitude, longitude: longitude)
                                                let locationData: [AnyHashable : Any] = ["uid" : locationUID, "point" : point]
                                                locations.append(locationData)
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                locations.sort(by: { (a: [AnyHashable : Any], b: [AnyHashable : Any]) -> Bool in
                    
                    if let aPoint = a["point"] as? CLLocation, let bPoint = b["point"] as? CLLocation {
                        
                        if aPoint.distance(from: center) > bPoint.distance(from: center) {
                            
                            return false
                            
                        } else {
                            
                            return true
                            
                        }
                    }
                    
                    return false
                    
                })
                
                var scopeNearbyUsers = [String]()
                
                for locationValue in locations {
                    
                    if let uid = locationValue["uid"] as? String {
                        
                        scopeNearbyUsers.append(uid)
                        
                    }
                }
                
                self.nearbyUsers = scopeNearbyUsers
                self.globCollectionView.reloadData()
                
                if self.nearbyUsers.count == 0 {
                    
                    self.noNearbyOutlet.alpha = 1
                    
                } else {
                    
                    self.noNearbyOutlet.alpha = 0
                    
                }
            }
        })
    }
    
    func updateLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
    }
    
    
    func requestWhenInUseAuthorization(){
        
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.denied {
            
            let title: String = (status == CLAuthorizationStatus.denied) ? "Location services are off" : "Background location is not enabled"
            let message: String = "To use nearby features you must turn on 'When In Use' in the Location Services Settings"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
                
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) in
                
                if let actualSettingsURL = URL(string: UIApplicationOpenSettingsURLString){
                    
                    UIApplication.shared.openURL(actualSettingsURL)
                    
                }
            }))
            
            self.present(alertController, animated: true, completion: nil)
            
        } else if status == CLAuthorizationStatus.notDetermined {
            
            self.locationManager.requestWhenInUseAuthorization()
            
        } else if status == CLAuthorizationStatus.authorizedWhenInUse {
            
            updateLocation()
            self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(updateLocationToFirebase), userInfo: nil, repeats: true)
            
        }
    }
    
    
    func invalidateTimer(){
        
        timer.invalidate()
        
    }
    
    func showNav(){
        
        if let navShown = rootController?.navIsShown {
            
            if !navShown {
                
                rootController?.showNav(0.3, completion: { (bool) in
                    
                    print("nav shown")
                    
                })
            }
        }
    }
    
    func showVibes(){
        
        self.globCollectionView.isScrollEnabled = false
        
        rootController?.toggleVibes({ (bool) in
            
            self.globCollectionView.isScrollEnabled = true
            print("vibes toggled")
            
        })
    }
    
    
    func addGestureRecognizers(){
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showNav))
        downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        downSwipeGestureRecognizer.delegate = self
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(showVibes))
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        leftSwipeGestureRecognizer.delegate = self
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(downSwipeGestureRecognizer)
        
    }
    
    
    //ScrollViewDelegates
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if let navShown = self.rootController?.navIsShown {
            
            if navShown {
                
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
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.nearbyUsers.count == 0 {
            
            self.noNearbyOutlet.alpha = 1
            
        } else {
            
            self.noNearbyOutlet.alpha = 0
            
        }
        
        addGestureRecognizers()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.nearbyController = self
        
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
        
    }
    
}
