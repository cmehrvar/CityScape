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

    var youSentMe = false
    var iSentYou = false
    
    //Outlets
    @IBOutlet weak var nameOutlet: THLabel!
    @IBOutlet weak var occupationOutlet: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var onlineOutlet: NearbyOnline!
    @IBOutlet weak var matchButtonOutlet: UIButton!
    @IBOutlet weak var heartIndicator: UIImageView!
    @IBOutlet weak var buttonImageOutlet: UIImageView!
    
    
    //Actions
    @IBAction func matchRequest(sender: AnyObject) {
        
        print("match request sent")
        
        let scopeUsentMe = youSentMe
        let scopeUID = uid
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.heartIndicator.alpha = 1
            self.layoutIfNeeded()
            
            }, completion: { (complete) in
                
                UIView.animateWithDuration(0.3, animations: {
                    
                    self.heartIndicator.alpha = 0
                    self.layoutIfNeeded()
                    
                    }, completion: { (complete) in
                        
                        if let myUID = FIRAuth.auth()?.currentUser?.uid {
                            
                            let ref = FIRDatabase.database().reference()
                            ref.child("users").child(myUID).child("sentMatches").child(scopeUID).setValue(false)

                            if scopeUsentMe {
                                
                                ref.child("users").child(myUID).child("matchesDisplayed").child(scopeUID).setValue(false)
                                ref.child("users").child(scopeUID).child("matchesDisplayed").child(myUID).setValue(false)
                                
                                print("create match")
                                
                            }
                        }
                })
        })
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
        
        if let uid = data["uid"] as? String {
            
            self.uid = uid

            var showButton = true
            
            if let yourSentMatches = data["sentMatches"] as? [String : Bool], selfUID = FIRAuth.auth()?.currentUser?.uid {
                
                if yourSentMatches[selfUID] != nil {
                    
                    //You sent me
                    youSentMe = true
                    
                } else {

                    //You did not send me
                    youSentMe = false
                    
                    
                }

            } else {
                
                
                //You have not sent anyone
                youSentMe = false
                
            }

            
            if let selfData = nearbyController?.rootController?.selfData {
                
                if let mySentMatches = selfData["sentMatches"] as? [String : Bool] {
                    
                    if mySentMatches[uid] != nil {
                        
                        //I've sent you!!
                        iSentYou = true
                        showButton = false
                        
                    } else {
                        
                        iSentYou = false
                        //I haven't sent you!!!
                        
                    }

                } else {
                    
                    iSentYou = false
                    //I have not sent anyone
                    
                }

            } else {
                
                //No Self Data!!!
                print("no self data")
                showButton = false
                
            }

            if showButton {
                
                matchButtonOutlet.enabled = true
                buttonImageOutlet.image = UIImage(named: "heart")
                
            } else {
                
                matchButtonOutlet.enabled = false
                buttonImageOutlet.image = nil
                
            }

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

                
                nameOutlet.text = name
                nameOutlet.strokeSize = 0.25
                nameOutlet.strokeColor = UIColor.blackColor()
                nameOutlet.lineBreakMode = .ByWordWrapping
                
                occupationOutlet.adjustsFontSizeToFitWidth = true
                occupationOutlet.text = occupation
                
            }  
        }
        
    }
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
