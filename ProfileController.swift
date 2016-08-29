//
//  ProfileController.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-15.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ProfileController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //Variables
    weak var rootController: MainRootController?
    var userData = [NSObject:AnyObject]()
    var currentUID = ""
    
    //Outlets
    @IBOutlet weak var globCollectionCell: UICollectionView!
    
    //Functions
    func retrieveUserData(uid: String, selfProfile: Bool){

            let ref = FIRDatabase.database().reference().child("users").child(uid)
            
            ref.observeEventType(.Value, withBlock: { (snapshot) in
                
                if let value = snapshot.value as? [NSObject : AnyObject] {
                    
                    if self.currentUID == value["uid"] as? String {
                        
                        self.userData = value
                        self.globCollectionCell.reloadData()
                        
                    } else {
                        ref.removeAllObservers()
                    } 
                }
            })
        
    }
    
    
    //CollectionViewDelegates
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileInfoCell", forIndexPath: indexPath) as! ProfileInfoCollectionCell
            
            cell.nameOutlet.adjustsFontSizeToFitWidth = true
            cell.cityOutlet.adjustsFontSizeToFitWidth = true
            cell.occupationOutlet.adjustsFontSizeToFitWidth = true
            
            cell.profileController = self
            
            cell.loadData(userData)
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        
        if indexPath.row == 0 {
            return CGSize(width: width, height: 435)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
