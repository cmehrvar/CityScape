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
    var globUsers = [[NSObject : AnyObject]]()
    var dataSourceForSearchResult = [[NSObject : AnyObject]]()

    @IBOutlet weak var globCollectionView: UICollectionView!

    //Functions
    func observeUsers(){

        if let selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            let ref = FIRDatabase.database().reference().child("userUIDs")
            
            var index = 0
            
            ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
                
                if selfUID != snapshot.key {
                    
                    let scopeIndex = index
                    
                    self.globUsers.insert([NSObject : AnyObject](), atIndex: scopeIndex)
                    
                    let userRef = FIRDatabase.database().reference().child("users").child(snapshot.key)
                    
                    userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        if let value = snapshot.value as? [NSObject : AnyObject] {
                            
                            self.globUsers[scopeIndex] = value
                            self.globCollectionView.reloadData()
                            
                        }
                    })
                    
                    index += 1

                }
            })
        }
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let vc = searchController {

            if vc.searchBarActive {
                
                return dataSourceForSearchResult.count
                
            } else {
                
                return globUsers.count
                
            }
        }
        
        
        return 0
        
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCell", forIndexPath: indexPath) as! UserCollectionCell
        
        cell.userController = self
        
        if let vc = searchController {
            
            if vc.searchBarActive {
                
                cell.updateUI(dataSourceForSearchResult[indexPath.row])
                
            } else {
                cell.updateUI(globUsers[indexPath.row])
            }
        }
        
        return cell
 
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell", forIndexPath: indexPath) as! HeaderCollectionCell
            
            cell.userController = self
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
            
            if globUsers.count > 6 {
                
                searchController?.rootController?.hideAllNav({ (bool) in
                    
                    print("all nav hided")
                    
                })
            }

        } else if velocity.y < 0 {
            
            searchController?.rootController?.showNav(0.3, completion: { (bool) in
                
                print("nav shown")
                
            })
        }
    }

    
    func swipeToCities(){
        
        searchController?.toggleColour(1)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToCities))
        rightSwipeGesture.direction = .Right
        rightSwipeGesture.delegate = self
        self.globCollectionView.addGestureRecognizer(rightSwipeGesture)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
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
