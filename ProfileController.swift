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
    var pictures = 1
    
    var image1Scale: CGFloat = 0
    var image2Scale: CGFloat = 0
    var image3Scale: CGFloat = 0
    
    var tempImage1: UIImage?
    var tempImage2: UIImage?
    var tempImage3: UIImage?
    
    var tempImage1Scale: CGFloat = 0
    var tempImage2Scale: CGFloat = 0
    var tempImage3Scale: CGFloat = 0
    
    
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
            cell.addUploadStuff()
            
            if let profilePicture = userData["profilePicture"] as? String, url = NSURL(string: profilePicture) {
                cell.profilePicOutlet.sd_setImageWithURL(url, placeholderImage: nil)
            }
            
            if selfProfile {
                
                print("self profile")
                
                
                cell.editButton1.alpha = 1
                cell.editButton2.alpha = 2
                
                
                
                pictures = 2
                
                if tempImage1 != nil {
                    
                    cell.profilePicOutlet.alpha = 1
                    cell.profilePicOutlet.image = tempImage1
                    
                } else {
                    
                    print("no temp image 1")
                }
                
                if tempImage2 != nil {
                    
                    cell.profilePic2Outlet.alpha = 1
                    cell.profilePic2Outlet.image = tempImage2
                    //pictures = 3
                    
                } else {
                    print("no temp image 2")
                    
                    if let profilePicture2 = userData["profilePicture2"] as? String, url = NSURL(string: profilePicture2) {
                        
                        cell.profilePic2Outlet.alpha = 2
                        cell.profilePic2Outlet.sd_setImageWithURL(url, placeholderImage: nil)
                        
                        //pictures = 3
      
                    }
                }
                
                if tempImage3 != nil {
                    
                }
                
                
            } else {
                
                cell.editButton1.alpha = 0
                cell.editButton2.alpha = 0
                
                
                if let profilePicture2 = userData["profilePicture2"] as? String, url = NSURL(string: profilePicture2) {
                    
                    cell.profilePic2Outlet.alpha = 1
                    cell.profilePic2Outlet.sd_setImageWithURL(url, placeholderImage: nil)
                    
                    pictures = 2
                    
                    
                } else {
                    print("no profile 2")
                    
                    cell.profilePic2Outlet.alpha = 0
                    
                }
                
                cell.profilePicCenterConstOutlet.constant = 0
            }
            
            
            if currentPicture == 1 {
                cell.profilePicCenterConstOutlet.constant = 0
            } else if currentPicture == 2 {
                cell.profilePicCenterConstOutlet.constant = -(screenWidth)
            } else if currentPicture == 3 {
                cell.profilePicCenterConstOutlet.constant = -(screenWidth * 2)
            }
            
            cell.addSwipeGesture()
            
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
  
        }else {
            return UICollectionViewCell()
        }
    }
    
    func heightCalculator() -> CGFloat {
        
        let width = self.view.bounds.width
        var height: CGFloat = 0
        
        if currentPicture == 1 {
            
            if selfProfile {
                if tempImage1 == nil {
                    height = width*image1Scale
                } else {
                    height = width*tempImage1Scale
                }
            } else {
                height = width*image1Scale
            }
            
        } else if currentPicture == 2 {
            
            if selfProfile {
                if tempImage2 == nil {
                    
                    if pictures == 2 {
                        height = width*image1Scale
                    } else {
                        height = width*image2Scale
                    }
                    
                } else {
                    height = width*tempImage2Scale
                }
            } else {
                height = width*image2Scale
            }
            
        } else if currentPicture == 3 {
            
            if selfProfile {
                
                if tempImage3 == nil {
                    height = width*image3Scale
                } else {
                    height = width*tempImage3Scale
                }
            } else {
                height = width*image3Scale
            }
        }

        if height < (self.view.bounds.height - 100) {
            return height
        } else {
            return (self.view.bounds.height - 100)
        }
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
