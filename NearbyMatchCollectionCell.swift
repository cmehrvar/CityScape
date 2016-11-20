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
import SDWebImage

class NearbyMatchCollectionCell: UICollectionViewCell {
    
    //Variables
    weak var nearbyController: NearbyController?
    var index = 0
    var uid = ""
    var firstName = ""
    var lastName = ""
    var profilePic = ""
    
    var yourAMatch = false
    var youSentMe = false
    var iSentYou = false
    
    //Outlets
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var occupationOutlet: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var onlineOutlet: NearbyOnline!
    @IBOutlet weak var matchButtonOutlet: UIButton!
    @IBOutlet weak var heartIndicator: UIImageView!
    @IBOutlet weak var buttonImageOutlet: UIImageView!
    
    
    //Actions
    @IBAction func matchRequest(_ sender: AnyObject) {
        
        print("match request sent", terminator: "")
        
        if yourAMatch {
            
            print("toggle messaged", terminator: "")
            
            nearbyController?.rootController?.toggleChat("matches", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profilePic, completion: { (bool) in
                
                print("chat toggled", terminator: "")
                
            })
            
        } else {
            
            let scopeUsentMe = youSentMe
            let scopeUID = uid
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.heartIndicator.alpha = 1
                self.layoutIfNeeded()
                
                }, completion: { (complete) in
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        self.heartIndicator.alpha = 0
                        self.layoutIfNeeded()
                        
                        }, completion: { (complete) in
                            
                            if let myUID = FIRAuth.auth()?.currentUser?.uid {
                                
                                let ref = FIRDatabase.database().reference()
                                ref.keepSynced(true)
                                
                                ref.child("users").child(scopeUID).child("sentMatches").child(myUID).setValue(false)
                                
                                if scopeUsentMe {

                                    ref.child("users").child(myUID).child("matchesDisplayed").child(scopeUID).setValue(false)
                                    ref.child("users").child(scopeUID).child("matchesDisplayed").child(myUID).setValue(false)
                                    
                                    
                                    
                                    print("create match")
                                    
                                } else {
                                    
                                    self.matchButtonOutlet.isEnabled = false
                                    self.buttonImageOutlet.image = UIImage(named: "sentMatch")

                                }
                            }
                    })
            })
        }
    }
    
    
    @IBAction func goToProfile(_ sender: AnyObject) {
        
        nearbyController?.rootController?.toggleProfile(uid, selfProfile: false, completion: { (bool) in
            
            print("profile toggled", terminator: "")
            
        })
        
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        
        if let last = nearbyController?.nearbyUsers.last {
            
            nearbyController?.dismissedCells[uid] = true
            
            nearbyController?.nearbyUsers[index] = last
            nearbyController?.nearbyUsers.removeLast()
            nearbyController?.globCollectionView.reloadData()
            
        }
        
        print("cell dismissed", terminator: "")
    }
    
    
    //Functions
    func loadUser(_ uid: String){
        
        self.uid = uid
        
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        
        ref.observe(.value, with: { (snapshot) in
            
            if uid == self.uid {
                
                if let userData = snapshot.value as? [AnyHashable : Any] {
                    
                    if let online = userData["online"] as? Bool {
                        
                        if online {
                            self.onlineOutlet.backgroundColor = UIColor.green
                        } else {
                            self.onlineOutlet.backgroundColor = UIColor.red
                        }
                    }
                    
                    if let displayName = userData["displayName"] as? String {
                        
                        self.nameOutlet.text = displayName
                        
                    }
                    
                    if let age = userData["age"] as? TimeInterval, let firstName = userData["firstName"] as? String, let lastName = userData["lastName"] as? String {
                        
                        let date = Date(timeIntervalSince1970: age)
                        
                        let displayName = firstName + ", " + timeAgoSince(date: date as NSDate, showAccronym: false)
                        
                        self.firstName = firstName
                        self.lastName = lastName
                        
                        self.nameOutlet.text = displayName
                        self.nameOutlet.lineBreakMode = .byWordWrapping
                        
                    }
                    
                    if let profile = userData["profilePicture"] as? String, let url = URL(string: profile) {
                        
                        if self.profileImage.sd_imageURL() != url {
                            self.profileImage.sd_setImage(with: url, placeholderImage: nil)
                        }
                        
                        self.profilePic = profile
                        
                    }
                    
                    if let status = userData["currentStatus"] as? String {
                        
                        self.occupationOutlet.text = status
                        
                    } else {
                        
                        self.occupationOutlet.text = ""
                        
                    }
                    
                    var scopeYourAMatch = false
                    
                    if let yourMatches = userData["matches"] as? [AnyHashable : Any], let myUID = FIRAuth.auth()?.currentUser?.uid {
                        
                        if yourMatches[myUID] != nil {
                            
                            scopeYourAMatch = true
                            
                        } else {
                            
                            scopeYourAMatch = false
                            
                        }
                        
                        
                    } else {
                        
                        scopeYourAMatch = false
                        
                    }
                    
                    self.yourAMatch = scopeYourAMatch
                    
                    if scopeYourAMatch {
                        
                        // YOUR A MATCH!!!
                        
                        self.matchButtonOutlet.isEnabled = true
                        self.buttonImageOutlet.image = UIImage(named: "enabledMessage")
                        
                    } else {
                        
                        var scopeYouSentMe = false
                        var scopeISentYou = false
                        
                        if let yourSentMatches = userData["sentMatches"] as? [String : Bool] {
                            
                            if let myUID = FIRAuth.auth()?.currentUser?.uid {
                                
                                if yourSentMatches[myUID] != nil {
                                    
                                    //You sent me
                                    scopeISentYou = true
                                    
                                }
                            }
                        }
                        
                        
                        if scopeISentYou && !scopeYourAMatch {
                            
                            self.matchButtonOutlet.isEnabled = false
                            self.buttonImageOutlet.image = UIImage(named: "sentMatch")
                            
                        }
                        
                        self.iSentYou = scopeISentYou
                        
                        if let myUid = FIRAuth.auth()?.currentUser?.uid {
                            
                            let mySentMatchesRef = FIRDatabase.database().reference().child("users").child(myUid).child("sentMatches")
                            
                            mySentMatchesRef.observe(.value, with: { (snapshot) in
                                
                                if scopeYourAMatch {
                                    
                                    self.matchButtonOutlet.isEnabled = true
                                    self.buttonImageOutlet.image = UIImage(named: "enabledMessage")
                                    
                                } else if scopeISentYou {
                                    
                                    self.matchButtonOutlet.isEnabled = false
                                    self.buttonImageOutlet.image = UIImage(named: "sentMatch")
                                    
                                } else {
                                    
                                    self.matchButtonOutlet.isEnabled = true
                                    self.buttonImageOutlet.image = UIImage(named: "sendMatch")
                                    
                                }
                                
                                if let mySentMatches = snapshot.value as? [String : Bool] {
                                    
                                    if mySentMatches[uid] != nil {
                                        
                                        scopeYouSentMe = true
                                        
                                    } else {
                                        
                                        scopeYouSentMe = false
                                        
                                    }
                                    
                                } else {
                                    
                                    scopeYouSentMe = false
                                    
                                }
                                
                                self.youSentMe = scopeYouSentMe
                                
                            })
                        }
                    }
                }
            }
        })
    }
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
