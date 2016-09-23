//
//  CityController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-14.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class CityController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var globCollectionView: UICollectionView!
    
    weak var searchController: SearchController?
    var globCities = [[NSObject : AnyObject]]()
    var dataSourceForSearchResult = [[NSObject : AnyObject]]()

    
    //Functions
    func observeCities(){
        
        if let selfData = searchController?.rootController?.selfData {
            
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

    
    
    
    
    
    
    //CollectionView Delegates
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let vc = searchController {

                if vc.searchBarActive {
                    
                    return dataSourceForSearchResult.count
                    
                } else {
                    
                    return globCities.count
                    
                }
            }

        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cityCell", forIndexPath: indexPath) as! CityCollectionCell
        
        cell.cityController = self
        
        if let vc = searchController {
            
            if vc.searchBarActive {
                
                cell.updateUI(dataSourceForSearchResult[indexPath.row])

            } else {
                cell.updateUI(globCities[indexPath.row])
            }
        }

        return cell
        
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", forIndexPath: indexPath) as! HeaderCollectionCell
            
            cell.cityController = self
            cell.exploreOutlet.adjustsFontSizeToFitWidth = true
            
            reusableView = cell
            
        }
        
        return reusableView
        
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.bounds.width
        return CGSize(width: width, height: 100)
        
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
        return CGSize(width: width/2, height: width/2)
        
    }


    //ScrollView Delegates
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        
        if velocity.y > 0 {
            
            searchController?.rootController?.hideAllNav({ (bool) in
                
                print("all nav hided")
                
            })
            
        } else if velocity.y < 0 {
            
            searchController?.rootController?.showNav(0.3, completion: { (bool) in
                
                print("nav shown")
                
            })
        }
    }
    
    func swipeToUser(){
        
        searchController?.toggleColour(2)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToUser))
        leftSwipeGesture.direction = .Left
        leftSwipeGesture.delegate = self
        self.globCollectionView.addGestureRecognizer(leftSwipeGesture)
        
        
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
