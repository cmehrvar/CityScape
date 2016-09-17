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
    
    var selfProfile = false
    
    var currentPicture = 1
    
    var tempImage1: UIImage?
    var tempImage2: UIImage?
    var tempImage3: UIImage?
    var tempImage4: UIImage?
    var tempImage5: UIImage?

    var currentUID = ""

    //Outlets
    @IBOutlet weak var globCollectionCell: UICollectionView!
    

    
    //Functions
    func retrieveUserData(uid: String){
        
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
        return 2
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("profilePicCell", forIndexPath: indexPath) as! ProfilePicCollectionCell
            
            let screenWidth = self.view.bounds.width
            cell.profileController = self
            cell.currentPicture = currentPicture
            cell.loadImages(userData, screenWidth: screenWidth)
            return cell
            

        } else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath) as! ProfileInfoCollectionCell

            if selfProfile {
                
                cell.squadButtonOutlet.alpha = 0
                cell.messageButtonOutlet.alpha = 0
                
            } else {
                
                cell.squadButtonOutlet.alpha = 1
                cell.messageButtonOutlet.alpha = 1
                
            }
            
            cell.profileController = self
            cell.selfProfile = selfProfile
            cell.loadData(userData)
            
            cell.nameOutlet.adjustsFontSizeToFitWidth = true
            cell.cityOutlet.adjustsFontSizeToFitWidth = true
            cell.occupationOutlet.adjustsFontSizeToFitWidth = true
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        
        if indexPath.row == 0 {
            
            return CGSize(width: width, height: height * 0.65)
            
        } else if indexPath.row == 1 {
            return CGSize(width: width, height: height * 0.35)
        } else {
            return CGSizeZero
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
