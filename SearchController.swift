//
//  SearchController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-12.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class SearchController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootController?
    
    var globCities = [[NSObject : AnyObject]]()
    var globUsers = [[NSObject : AnyObject]]()
    
    var dataSourceForSearchResult = [[NSObject : AnyObject]]()
    
    var searchIsCity = false
    
    var firstLoad = false
    var searchBarActive:Bool = false
    
    
    @IBOutlet weak var dismissViewOutlet: UIView!
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var globCollectionView: UICollectionView!
    
    
    @IBOutlet weak var cityViewOutlet: NavButtonView!
    @IBOutlet weak var cityButtonOutlet: UIButton!
    
    
    @IBOutlet weak var userViewOutlet: NavButtonView!
    @IBOutlet weak var userButtonOutlet: UIButton!
    
    
    
    //Actions
    @IBAction func cityAction(sender: AnyObject) {
        
        toggleColour(1)
        
    }
    
    
    @IBAction func userAction(sender: AnyObject) {
        
        toggleColour(2)
        
    }
    
    
    
    //Functions
    func toggleColour(button: Int) {
        
        if button == 1 {
            
            cityViewOutlet.backgroundColor = UIColor.whiteColor()
            cityButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            userViewOutlet.backgroundColor = UIColor.clearColor()
            userButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            self.searchIsCity = true
            self.observeCities()
            
            
        } else if button == 2 {
            
            userViewOutlet.backgroundColor = UIColor.whiteColor()
            userButtonOutlet.setTitleColor(UIColor(netHex: 0xDF412E), forState: .Normal)
            
            
            cityViewOutlet.backgroundColor = UIColor.clearColor()
            cityButtonOutlet.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            
            self.searchIsCity = false
            self.observeUsers()
            
        }
    }
    
    
    
    func observeUsers(){
        
        if let selfData = rootController?.selfData {
            
            if let latitude = selfData["latitude"] as? CLLocationDegrees, longitude = selfData["longitude"] as? CLLocationDegrees {
                
                let center = CLLocation(latitude: latitude, longitude: longitude)
                
                let ref = FIRDatabase.database().reference().child("userLocations")
                let geoFire = GeoFire(firebaseRef: ref)
                
                let query = geoFire.queryAtLocation(center, withRadius: 22)
                
                var index = 0
                var users = [[NSObject : AnyObject]]()
                
                query.observeEventType(.KeyEntered, withBlock: { (key, location) in

                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                        
                        if key != uid {
                            
                            let userRef = FIRDatabase.database().reference().child("users").child(key)
                            
                            let scopeIndex = index
                            
                            users.append([NSObject : AnyObject]())
                            index += 1
                            
                            userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                                
                                if let value = snapshot.value as? [NSObject : AnyObject] {
                                    
                                    users[scopeIndex] = value
                                    self.globUsers = users
                                    self.globCollectionView.reloadData()
                                    
                                }
                            })
                        }
                    }
                })
            }
        }
    }
    
    
    
    func observeCities(){
        
        if let selfData = rootController?.selfData {
            
            if let latitude = selfData["latitude"] as? CLLocationDegrees, longitude = selfData["longitude"] as? CLLocationDegrees {
                
                let center = CLLocation(latitude: latitude, longitude: longitude)
                
                let ref = FIRDatabase.database().reference().child("cityLocations")
                
                ref.observeEventType(.Value, withBlock: { (snapshot) in
                    
                    if let actualValue = snapshot.value as? [NSObject : AnyObject] {
                        
                        var cities = [[NSObject : AnyObject]]()
                        
                        for (_, value) in actualValue {
                            
                            if let city = value as? [NSObject : AnyObject] {
                                
                                cities.append(city)
                                
                            }
                        }
                        
                        let sortedArray = cities.sort({ (a: [NSObject : AnyObject], b: [NSObject : AnyObject]) -> Bool in
                            
                            if let latitudeA = a["latitude"] as? CLLocationDegrees, latitudeB = b["latitude"] as? CLLocationDegrees, longitudeA = a["longitude"] as? CLLocationDegrees, longitudeB = b["longitude"] as? CLLocationDegrees {
                                
                                let locA = CLLocation(latitude: latitudeA, longitude: longitudeA)
                                let locB = CLLocation(latitude: latitudeB, longitude: longitudeB)
                                
                                if center.distanceFromLocation(locA) > center.distanceFromLocation(locB) {
                                    
                                    return false
                                    
                                } else {
                                    
                                    return true
                                    
                                }
                                
                            } else {
                                return false
                            }
                        })
                        
                        self.globCities = sortedArray
                        self.globCollectionView.reloadData()
                        
                    }
                })
            }
        }
    }
    
    
    func filterContentForSearchText(searchText: String){
        
        if searchIsCity {
            
            self.dataSourceForSearchResult = globCities.filter({ (city: [NSObject : AnyObject]) -> Bool in
                
                if let key = city["city"] as? String {
                    
                    return key.containsString(searchText)
                    
                } else {
                    
                    return false
                }
            })
            
            
        } else {
            
            self.dataSourceForSearchResult = globUsers.filter({ (user: [NSObject : AnyObject]) -> Bool in
                
                if let firstName = user["firstName"] as? String, lastName =  user["lastName"] as? String {
                    
                    let name = firstName + " " + lastName
                    return name.containsString(searchText)
                    
                } else {
                    
                    return false
                }
            })
        }
    }
    
    
    //Search Bar Delegates
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count > 0 {
            
            self.searchBarActive = true
            self.filterContentForSearchText(searchText)
            self.globCollectionView.reloadData()
            
        } else {
            
            self.searchBarActive = false
            self.globCollectionView.reloadData()
            
        }
        
        print("search bar active: \(searchBarActive)")
        
    }
    
    
    
    //CollectionView Delegates
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.bounds.width
        return CGSize(width: width, height: 100)
        
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", forIndexPath: indexPath) as! HeaderCollectionCell
            
            cell.searchController = self
            cell.exploreOutlet.adjustsFontSizeToFitWidth = true
            
            reusableView = cell
            
        }
        
        return reusableView
        
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if searchBarActive {
            
            return dataSourceForSearchResult.count
            
        } else {
            
            if searchIsCity {
                
                return globCities.count
                
            } else {
                
                return globUsers.count
                
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cityCell", forIndexPath: indexPath) as! CityCollectionCell
        
        if searchBarActive {
            
            cell.searchController = self
            cell.updateUI(dataSourceForSearchResult[indexPath.row])
            
        } else {
            
            cell.searchController = self
            
            if searchIsCity {
                
                cell.squadRequestButtonOutlet.alpha = 0
                cell.updateUI(globCities[indexPath.row])
                
            } else {
                
                cell.squadRequestButtonOutlet.alpha = 1
                cell.updateUI(globUsers[indexPath.row])
                
            }
        }
        
        return cell
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
        return CGSize(width: width/2, height: width/2)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }
    
    func tapHandler(){
        
        self.view.endEditing(true)
        
    }
    
    func keyboardDidShow(){
        
        dismissViewOutlet.alpha = 1
        
        
    }
    
    
    func keyboardHid(){
        
        dismissViewOutlet.alpha = 0
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardHid), name: UIKeyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tapGesture.delegate = self
        self.dismissViewOutlet.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
