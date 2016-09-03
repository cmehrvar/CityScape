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
    var firstName = ""
    var lastName = ""
    var profilePic = ""
    
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

        let ref = FIRDatabase.database().reference()
        
        print(uid)

        if let myUid = FIRAuth.auth()?.currentUser?.uid {

            if let myMatchData = nearbyController?.rootController?.selfData["receivedMatches"] as? [String : Bool] {
                
                if myMatchData[uid] != nil {
                    
                    print("you matched with me")
                    
                    let timeInterval = NSDate().timeIntervalSince1970
                    
                    ref.child("users").child(uid).child("matches").child(myUid).updateChildValues(["lastActivity" : timeInterval, "uid" : myUid])
                    
                    if let myFirstName = self.nearbyController?.rootController?.selfData["firstName"] as? String, myLastName = self.nearbyController?.rootController?.selfData["lastName"] as? String {
                        
                        ref.child("users").child(uid).child("matches").child(myUid).updateChildValues(["firstName" : myFirstName, "lastName" : myLastName])
                        
                    }

                    
                    ref.child("users").child(myUid).child("matches").child(uid).updateChildValues(["lastActivity" : timeInterval, "uid" : uid, "firstName" : firstName, "lastName" : lastName])


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
        
        nearbyController?.rootController?.toggleProfile(uid, selfProfile: false, profilePic: profilePic, completion: { (bool) in
            
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
                self.profilePic = profile
                profileImage.sd_setImageWithURL(profileURL, placeholderImage: nil)
            }
            
            if let online = data["online"] as? Bool {
                
                if online {
                    onlineOutlet.backgroundColor = UIColor.greenColor()
                } else {
                    onlineOutlet.backgroundColor = UIColor.redColor()
                }
            }

            if let sentData = nearbyController?.rootController?.selfData["sentMatches"] as? [String : Bool] {
                
                if sentData[uid] == nil {
                    
                    matchButtonOutlet.enabled = true
                   
                    
                } else {
                    
                    matchButtonOutlet.setTitleColor(UIColor.grayColor(), forState: .Disabled)
                    matchButtonOutlet.enabled = false

                }
                
            } else {
                
                matchButtonOutlet.enabled = true

            }


            nameOutlet.text = name
            nameOutlet.strokeSize = 0.25
            nameOutlet.strokeColor = UIColor.blackColor()
            nameOutlet.lineBreakMode = .ByWordWrapping
            
            occupationOutlet.adjustsFontSizeToFitWidth = true
            occupationOutlet.text = occupation

        }  
    }
    
    
    

    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

}
