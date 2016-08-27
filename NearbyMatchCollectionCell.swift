//
//  NearbyMatchCollectionCell.swift
//  CityScape
//
//  Created by Cina Mehrvar on 2016-08-07.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import THLabel
import Firebase
import FirebaseDatabase
import FirebaseAuth

class NearbyMatchCollectionCell: UICollectionViewCell {
    
    //Variables
    weak var nearbyController: NearbyController?
    var index = 0
    var uid = ""
    
    //Outlets
    @IBOutlet weak var nameOutlet: THLabel!
    @IBOutlet weak var occupationOutlet: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var onlineOutlet: NearbyOnline!
    @IBOutlet weak var matchButtonOutlet: UIButton!
    @IBOutlet weak var squadButtonOutlet: UIButton!
    @IBOutlet weak var indicatorOutlet: UIImageView!
    
    //Actions
    @IBAction func squadRequest(sender: AnyObject) {

        print("squad request sent")
        
    }
    
    
    @IBAction func matchRequest(sender: AnyObject) {
        
        print("match request sent")

        indicatorOutlet.image = UIImage(named: "RedX")
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.indicatorOutlet.alpha = 1
            
            }) { (bool) in
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.indicatorOutlet.alpha = 0
                    
                })
   
        }

        let ref = FIRDatabase.database().reference()

        if let myUid = FIRAuth.auth()?.currentUser?.uid {

            if let myMatchData = nearbyController?.rootController?.selfData["receivedMatches"] as? [String : Bool] {
                
                if myMatchData[uid] != nil {
                    
                    print("you matched with me")
                    
                    ref.child("users").child(uid).child("matches").updateChildValues([myUid : " "])
                    ref.child("users").child(myUid).child("matches").updateChildValues([uid : " "])

                    ref.child("users").child(uid).child("sentMatches").child(myUid).setValue(true)
                    ref.child("users").child(myUid).child("receivedMatches").child(uid).setValue(true)

                } else {
                    
                    print("you didn't match with me")
                    
                    ref.child("users").child(myUid).child("sentMatches").child(uid).setValue(false)
                    ref.child("users").child(uid).child("receivedMatches").child(myUid).setValue(false)
                }
                
                
            } else {
                
                print("no match data")

                ref.child("users").child(myUid).child("sentMatches").child(uid).setValue(false)
                ref.child("users").child(uid).child("receivedMatches").child(myUid).setValue(false)
  
            }
        }
    }
    
    
    @IBAction func goToProfile(sender: AnyObject) {

        nearbyController?.rootController?.toggleProfile(uid, selfProfile: false, completion: { (bool) in
            
            print("profile toggled")
            
        })
    }

    @IBAction func dismiss(sender: AnyObject) {
        
        if let last = nearbyController?.nearbyUsers.last {
            
            nearbyController?.dismissedCells[uid] = true
            
            if let lastUID = last["uid"] as? String {
                nearbyController?.addedCells[lastUID] = index
            }
            
            nearbyController?.addedIndex -= 1
            
            nearbyController?.nearbyUsers[index] = last
            nearbyController?.nearbyUsers.removeLast()
            nearbyController?.globCollectionView.reloadData()
            
        }
        
        print("cell dismissed")
    }
    
    
    //Functions
    func loadUser(data: [NSObject : AnyObject]){
        
        if let firstName = data["firstName"] as? String {
            
            var name = firstName
            var occupation = ""
            
            if let age = data["age"] as? NSTimeInterval {
                
                let date = NSDate(timeIntervalSince1970: age)
                name += ", " + timeAgoSince(date, showAccronym: false)
                
            }
            
            if let actualOccupation = data["occupation"] as? String {
                occupation = actualOccupation
            }
            
            if let profile = data["profilePicture"] as? String, profileURL = NSURL(string: profile) {
                profileImage.sd_setImageWithURL(profileURL, placeholderImage: nil)
            }
            
            if let online = data["online"] as? Bool {
                
                if online {
                    onlineOutlet.backgroundColor = UIColor.greenColor()
                } else {
                    onlineOutlet.backgroundColor = UIColor.redColor()
                }
                
            }
            
            
            nameOutlet.text = name
            nameOutlet.strokeSize = 0.25
            nameOutlet.strokeColor = UIColor.blackColor()
            nameOutlet.lineBreakMode = .ByWordWrapping
            
            occupationOutlet.adjustsFontSizeToFitWidth = true
            occupationOutlet.text = occupation
            
            
            if let sentMatch = nearbyController?.rootController?.selfData["sentMatches"] as? [String : Bool] {
                
                if sentMatch[uid] != nil {
                    
                    matchButtonOutlet.setTitleColor(UIColor.grayColor(), forState: .Disabled)
                    matchButtonOutlet.enabled = false
                    
                }
            }
        }  
    }
    
    
    

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

}
