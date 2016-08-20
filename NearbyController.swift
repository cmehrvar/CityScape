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

class NearbyController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, CLLocationManagerDelegate {
    
    //Variables
    weak var rootController: MainRootController?
    let locationManager = CLLocationManager()
    var nearbyUsers = [[NSObject : AnyObject]]()
    var addedCells = [String:Int]()
    var dismissedCells = [String:Bool]()
    
    var addedIndex = 0
    
    
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
    
    @IBAction func slideToggle(sender: AnyObject) {
        
        rootController?.toggleVibes({ (bool) in
            print("slide to vibes")
        })
    }
    
    //Collection View Delegates
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (self.view.bounds.width/2) - 24
        let height = width*1.223
        
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbyUsers.count
    }
    
    
    func cellToReturn(value: [NSObject : AnyObject]) -> Int {
        
        let myGender = rootController?.selfData["gender"] as? String
        let yourGender = value["gender"] as? String
        
        let myInterests = rootController?.selfData["interestedIn"] as! [String]
        let yourInterests = value["interestedIn"] as! [String]
        
        var imInterestedInYou = false
        var youreInterestedInMe = false
        
        for interest in myInterests {
            
            if interest == yourGender {
                imInterestedInYou = true
            }
        }
        
        for interest in yourInterests {
            
            if interest == myGender {
                youreInterestedInMe = true
            }
        }
        
        if imInterestedInYou && youreInterestedInMe {
            return 2
        } else {
            return 1
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let defaultCell = UICollectionViewCell()
        
        if cellToReturn(nearbyUsers[indexPath.row]) == 1 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("nearbySquadCollectionCell", forIndexPath: indexPath) as! NearbySquadCollectionCell
            cell.loadUser(nearbyUsers[indexPath.row])
            cell.nearbyController = self
            cell.index = indexPath.row
            
            if let uid = nearbyUsers[indexPath.row]["uid"] as? String {
                cell.uid = uid
            }
            
            return cell
            
        } else if cellToReturn(nearbyUsers[indexPath.row]) == 2 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("nearbyMatchCollectionCell", forIndexPath: indexPath) as! NearbyMatchCollectionCell
            cell.loadUser(nearbyUsers[indexPath.row])
            cell.nearbyController = self
            cell.index = indexPath.row
            
            if let uid = nearbyUsers[indexPath.row]["uid"] as? String {
                cell.uid = uid
            }
            
            return cell
            
        }
        
        return defaultCell
    }
    
    //Location Manager Delegates
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let ref = FIRDatabase.database().reference().child("userLocations")
        
        let geoFire = GeoFire(firebaseRef: ref)
        let geoCoder = CLGeocoder()
        
        if let lastLocation = locations.last, uid = FIRAuth.auth()?.currentUser?.uid {
            
            /*
            queryNearby(lastLocation)
            
            
            let userRef = FIRDatabase.database().reference().child("users").child(uid)
            
            userRef.updateChildValues(["latitude" : lastLocation.coordinate.latitude, "longitude" : lastLocation.coordinate.longitude])
            
            geoCoder.reverseGeocodeLocation(lastLocation) { (placemark, error) in
                
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
            
            geoFire.setLocation(CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude), forKey: uid, withCompletionBlock: { (error) in
                
                if error == nil {
                    print("succesfully updated location")
                } else {
                    print(error)
                }
            })
 */
        }
    }
    
    
    //Functions
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
                            
                            var add = true
                            
                            if let uid = value["uid"] as? String {
                                
                                if self.dismissedCells[uid] != nil {
                                    
                                    add = false
                                    
                                } else if let index = self.addedCells[uid] {
                                    
                                    add = false
                                    self.nearbyUsers[index] = value
                                    self.globCollectionView.reloadData()
                                    
                                }
                                
                                if add {
                                    
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
            
            circleQuery.observeEventType(.KeyExited) { (key, location) in
                
                for i in 0..<self.nearbyUsers.count {
                    
                    if key == self.nearbyUsers[i]["uid"] as? String {
                        
                        if let last = self.nearbyUsers.last {
                            self.nearbyUsers[i] = last
                            self.nearbyUsers.removeLast()
                            self.globCollectionView.reloadData()
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
    
    func checkStatus(sender: AnyObject?){
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.NotDetermined {
            print("denied or not determined")
            
            UIView.animateWithDuration(0.3, animations: {
                self.settingsView.alpha = 1
                self.view.layoutIfNeeded()
            })
            
        } else if status == CLAuthorizationStatus.AuthorizedWhenInUse{
            print("enabled")
            
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
    
    
    override func viewDidAppear(animated: Bool) {
        requestWhenInUseAuthorization()
        settingsConstraint()
        updateLocation()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkStatus), name: UIApplicationDidBecomeActiveNotification, object: UIApplication.sharedApplication())
        
        // Do any additional setup after loading the view.
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
