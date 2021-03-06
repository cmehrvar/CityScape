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

class CityController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var globCollectionView: UICollectionView!
    
    weak var searchController: SearchController?
    var globCities = [[AnyHashable: Any]]()
    var dataSourceForSearchResult = [[AnyHashable: Any]]()
    
    
    //Functions
    func observeCities(){
        
        globCities.removeAll()
        dataSourceForSearchResult.removeAll()
        
        let ref = FIRDatabase.database().reference().child("cityLocations")
        ref.keepSynced(true)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let actualValue = snapshot.value as? [AnyHashable: Any] {
                
                var cities = [[AnyHashable: Any]]()
                
                for (_, value) in actualValue {
                    
                    if let city = value as? [AnyHashable: Any] {
                        
                        cities.append(city)
                        
                    }
                }
                
                let sortedArray = cities.sorted(by: { (a: [AnyHashable: Any], b: [AnyHashable: Any]) -> Bool in
                    
                    if let latitudeA = a["latitude"] as? CLLocationDegrees, let latitudeB = b["latitude"] as? CLLocationDegrees, let longitudeA = a["longitude"] as? CLLocationDegrees, let longitudeB = b["longitude"] as? CLLocationDegrees, let myLatitude = self.searchController?.rootController?.selfData["latitude"] as? CLLocationDegrees, let myLongitude = self.searchController?.rootController?.selfData["longitude"] as? CLLocationDegrees {
                        
                        let center = CLLocation(latitude: myLatitude, longitude: myLongitude)
                        
                        let locA = CLLocation(latitude: latitudeA, longitude: longitudeA)
                        let locB = CLLocation(latitude: latitudeB, longitude: longitudeB)
                        
                        if center.distance(from: locA) > center.distance(from: locB) {
                            
                            return false
                            
                        } else {
                            
                            return true
                            
                        }
                        
                    } else {
                        return false
                    }
                })
                
                if sortedArray.count == 0 {
                    
                    self.globCities = cities
                    
                } else {
                    
                    self.globCities = sortedArray
                    
                }
                
                self.globCollectionView.reloadData()
                
            }
        })
    }
    
    
    //CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let vc = searchController {
            
            if vc.searchBarActive {
                
                return dataSourceForSearchResult.count
                
            } else {
                
                return globCities.count
                
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cityCell", for: indexPath) as! CityCollectionCell
        
        cell.cityController = self
        
        if let vc = searchController {
            
            if vc.searchBarActive {
                
                cell.updateUI(dataSourceForSearchResult[(indexPath as NSIndexPath).row])
                
            } else {
                cell.updateUI(globCities[(indexPath as NSIndexPath).row])
            }
        }
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! HeaderCollectionCell
            
            cell.cityController = self
            cell.exploreOutlet.adjustsFontSizeToFitWidth = true
            
            reusableView = cell
            
        } else if kind == UICollectionElementKindSectionFooter {
            
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerCell", for: indexPath) as! FooterCollectionCell
            
            reusableView = cell
            
        }
        
        
        return reusableView
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.bounds.width
        return CGSize(width: width, height: 100)
        
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
        return CGSize(width: width/2, height: width/2)
        
    }
    
    
    //ScrollView Delegates
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if let navShown = searchController?.rootController?.navIsShown {

            if velocity.y > 0 {
                
                if globCities.count > 6 {
                    
                    if  navShown {
                        
                        searchController?.rootController?.hideAllNav({ (bool) in
                            
                            print("all nav hided", terminator: "")
                            
                        })
                    }
                }
                
            } else if velocity.y < 0 {
                
                
                if !navShown {
                    
                    searchController?.rootController?.showNav(0.3, completion: { (bool) in
                        
                        print("nav shown", terminator: "")
                        
                    })
                }
            }
        }
    }
    
    func swipeToUser(){
        
        searchController?.toggleColour(2)
        
    }
    
    func dismissKeyboard(){
        
        self.view.endEditing(true)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToUser))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.delegate = self
        self.globCollectionView.addGestureRecognizer(leftSwipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        self.globCollectionView.addGestureRecognizer(tapGesture)
        
        
        
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
