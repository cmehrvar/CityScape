//
//  UserController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-09-14.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var searchController: SearchController?
    var globUsers = [[AnyHashable: Any]]()
    var globUserIndexes = [String : Int]()
    var dataSourceForSearchResult = [[AnyHashable: Any]]()
    
    @IBOutlet weak var globCollectionView: UICollectionView!
    
    //Functions
    func observeUsers(){
        
        self.globUsers.removeAll()
        self.globUserIndexes.removeAll()
        
        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("userUIDs")
            ref.keepSynced(true)
            
            var index = 0
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? [String : Bool] {
                    
                    for (uid, _) in value {
                        
                        if selfUID != uid {
                            
                            if let myReported = self.searchController?.rootController?.selfData["reportedUsers"] as? [String : Bool] {
                                
                                if myReported[uid] == nil {
                                    
                                    let scopeIndex = index
                                    self.globUserIndexes[uid] = index
                                    
                                    self.globUsers.insert([AnyHashable: Any](), at: scopeIndex)
                                    
                                    let userRef = FIRDatabase.database().reference().child("users").child(uid)
                                    
                                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        
                                        if let value = snapshot.value as? [AnyHashable: Any] {
                                            
                                            self.globUsers[scopeIndex] = value
                                            self.globCollectionView.reloadData()
                                            
                                        }
                                    })
                                    
                                    index += 1
                                    
                                }
                            } else {
                                
                                let scopeIndex = index
                                self.globUserIndexes[uid] = index
                                
                                self.globUsers.insert([AnyHashable: Any](), at: scopeIndex)
                                
                                let userRef = FIRDatabase.database().reference().child("users").child(uid)
                                userRef.keepSynced(true)
                                
                                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                    
                                    if let value = snapshot.value as? [AnyHashable: Any] {
                                        
                                        self.globUsers[scopeIndex] = value
                                        self.globCollectionView.reloadData()
                                        
                                    }
                                })
                                
                                index += 1
                                
                            }
                        }
                    }
                }
            })
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let vc = searchController {
            
            if vc.searchBarActive {
                
                return dataSourceForSearchResult.count
                
            } else {
                
                return globUsers.count
                
            }
        }
        
        return 0
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UserCollectionCell
        
        cell.userController = self
        
        if let vc = searchController {
            
            if vc.searchBarActive {
                
                cell.updateUI(dataSourceForSearchResult[(indexPath as NSIndexPath).row])
                
            } else {
                cell.updateUI(globUsers[(indexPath as NSIndexPath).row])
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! HeaderCollectionCell
            
            cell.userController = self
            cell.exploreOutlet.adjustsFontSizeToFitWidth = true
            
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
        
        if velocity.y > 0 {
            
            if globUsers.count > 6 {
                
                searchController?.rootController?.hideAllNav({ (bool) in
                    
                    print("all nav hided", terminator: "")
                    
                })
            }
            
        } else if velocity.y < 0 {
            
            searchController?.rootController?.showNav(0.3, completion: { (bool) in
                
                print("nav shown", terminator: "")
                
            })
        }
    }
    
    
    func swipeToCities(){
        
        searchController?.toggleColour(1)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToCities))
        rightSwipeGesture.direction = .right
        rightSwipeGesture.delegate = self
        self.globCollectionView.addGestureRecognizer(rightSwipeGesture)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
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
