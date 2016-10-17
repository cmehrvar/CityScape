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
    
    var users = [AnyHashable: Any]()
    
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
        
        let width = (self.view.bounds.width/2)
        let height = width*1.223
        
        let size = CGSize(width: width, height: height)
        
        return size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if nearbyUsers.count == 0 {
            
            self.noNearbyOutlet.alpha = 1
            
        } else {
            
            self.noNearbyOutlet.alpha = 0
            
        }
        
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
    
    //Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
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

                            if self.rootController?.bottomNavController?.torontoOutlet.text == nil || self.rootController?.bottomNavController?.torontoOutlet.text == "" {

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
            
            geoFire?.setLocation(CLLocation(latitude: scopeLocation.coordinate.latitude, longitude: scopeLocation.coordinate.longitude), forKey: uid, withCompletionBlock: { (error) in
                
                if error == nil {
                    print("succesfully updated location")
                    
                    
                } else {
                    print(error)
                }
            })
        }
    }
    
    
    
    
    func queryNearby(_ center: CLLocation){
        
        let ref = FIRDatabase.database().reference().child("userLocations")
        let geoFire = GeoFire(firebaseRef: ref)
        
        if let radius = rootController?.selfData["nearbyRadius"] as? Double {
            
            let circleQuery = geoFire?.query(at: center, withRadius: radius)
            
            circleQuery?.observe(.keyEntered) { (scopeKey, location) in
   
                if let selfUID = FIRAuth.auth()?.currentUser?.uid {

                    if scopeKey != selfUID {
                        
                        if let key = scopeKey {
                            
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
                                        
                                        userRef.child("gender").observeSingleEvent(of: .value, with: { (snapshot) in
                                            
                                            var isInterested = false
                                            
                                            if let interestedIn = self.rootController?.selfData["interestedIn"] as? [String], let userGender = snapshot.value as? String {
                                                
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
                                    
                                    userRef.child("gender").observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        var isInterested = false
                                        
                                        if let interestedIn = self.rootController?.selfData["interestedIn"] as? [String], let userGender = snapshot.value as? String {
                                            
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
    }
    
    func updateLocation(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
    }
    
    func checkStatus(){
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.notDetermined {
            print("denied or not determined")

        } else if status == CLAuthorizationStatus.authorizedWhenInUse {
            print("enabled")
            
            updateLocation()
    
            self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateLocationToFirebase), userInfo: nil, repeats: true)
        }
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
