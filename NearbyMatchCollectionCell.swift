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
    @IBAction func matchRequest(sender: AnyObject) {
        
        print("match request sent")
        
        if yourAMatch {
            
            print("toggle messaged")
            
            nearbyController?.rootController?.toggleChat("matches", key: uid, city: nil, firstName: firstName, lastName: lastName, profile: profilePic, completion: { (bool) in
                
                print("chat toggled")
                
            })
            
        } else {
            
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
    }
    
    
    @IBAction func goToProfile(sender: AnyObject) {
        
        nearbyController?.rootController?.toggleProfile(uid, selfProfile: false, completion: { (bool) in
            
            print("profile toggled")
            
        })
        
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        
        if let last = nearbyController?.nearbyUsers.last {
            
            nearbyController?.dismissedCells[uid] = true
            
            nearbyController?.nearbyUsers[index] = last
            nearbyController?.nearbyUsers.removeLast()
            nearbyController?.globCollectionView.reloadData()
            
        }
        
        print("cell dismissed")
    }
    
    
    //Functions
    func loadUser(uid: String){
        
        if let selfData = nearbyController?.rootController?.selfData, selfUID = FIRAuth.auth()?.currentUser?.uid {
            
            if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {

                if self.uid == uid {
                    
                    if let online = userData["online"] as? Bool {
                        
                        if online {
                            self.onlineOutlet.backgroundColor = UIColor.greenColor()
                        } else {
                            self.onlineOutlet.backgroundColor = UIColor.redColor()
                        }
                        
                    }
                    
                    
                    if let matchStatus = userData["matchStatus"] as? String {
                        
                        if matchStatus == "sentMatch" {
                            
                            self.matchButtonOutlet.enabled = false
                            self.buttonImageOutlet.image = UIImage(named: "sentMatch")
                            
                        }
                    }
                    
                    if let displayName = userData["displayName"] as? String {
                        
                        self.nameOutlet.text = displayName
                        
                    }
                    
                    if let profile = userData["profile"] as? String, url = NSURL(string: profile) {
                        
                        if profileImage.sd_imageURL() != url {
                            profileImage.sd_setImageWithURL(url, placeholderImage: nil)
                        }
                        
                        self.profilePic = profile
                        
                    }
                    
                    if let status = userData["status"] as? String {
                        
                        occupationOutlet.text = status
                        
                    } else {
                        
                        occupationOutlet.text = ""
                        
                    }
                }
            }

            let ref = FIRDatabase.database().reference().child("users").child(uid)

            if let myMatches = selfData["matches"] as? [NSObject : AnyObject] {
                
                if myMatches[uid] != nil {
                    
                    yourAMatch = true
                    
                } else {
                    
                    yourAMatch = false
                    
                }
                
            } else {
                
                yourAMatch = false
                
            }
            
            if yourAMatch {
                
                // YOUR A MATCH!!!

                matchButtonOutlet.enabled = true
                buttonImageOutlet.image = UIImage(named: "enabledMessage")
                
            } else {
                
                ref.child("sentMatches").observeEventType(.Value, withBlock: { (snapshot) in
                    
                    var scopeYouSentMe = false
                    var scopeISentYou = false
                    
                    if self.uid == uid {
                        
                        if let yourSentMatches = snapshot.value as? [String : Bool] {
                            
                            if yourSentMatches[selfUID] != nil {
                                
                                //You sent me
                                
                                self.youSentMe = true
                                scopeYouSentMe = true
                                
                            } else {
                                
                                //You did not send me
                                self.youSentMe = false
                                scopeYouSentMe = false
                                
                            }
                            
                        }
                        else {
                            
                            self.youSentMe = false
                            scopeYouSentMe = false
                            
                        }
                        
                        if scopeYouSentMe {
                            
                            //YOU SENT ME!!!
                            
                            if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                                
                                var data = userData
                                data.updateValue("youSentMe", forKey: "matchStatus")
                                self.nearbyController?.users[uid] = data
                                
                            } else {
                                
                                self.nearbyController?.users.updateValue(["matchStatus" : "youSentMe"], forKey: uid)
                                
                            }

                            self.matchButtonOutlet.enabled = true
                            self.buttonImageOutlet.image = UIImage(named: "sendMatch")
                            

                        } else {
                            
                            if let mySentMatches = selfData["sentMatches"] as? [String : Bool] {
                                
                                if mySentMatches[uid] != nil {
                                    
                                    //I've sent you!!
                                    self.iSentYou = true
                                    scopeISentYou = true
                                    
                                } else {
                                    
                                    self.iSentYou = false
                                    scopeISentYou = false
                                    //I haven't sent you!!!
                                    
                                }
                                
                            } else {
                                
                                self.iSentYou = false
                                scopeISentYou = false
                                //I have not sent anyone
                                
                            }
                            
                            if scopeISentYou {
    
                                
                                if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                                    
                                    var data = userData
                                    data.updateValue("sentMatch", forKey: "matchStatus")
                                    self.nearbyController?.users[uid] = data
                                    
                                } else {
                                    
                                    self.nearbyController?.users.updateValue(["matchStatus" : "sentMatch"], forKey: uid)
                                    
                                }
                                
                                //I SENT YOU!!!
                                self.matchButtonOutlet.enabled = false
                                self.buttonImageOutlet.image = UIImage(named: "sentMatch")
                                
                            } else {
                                
                                
                                //NEITHER OF US HAVE SENT :(
                                self.matchButtonOutlet.enabled = true
                                self.buttonImageOutlet.image = UIImage(named: "sendMatch")

                                
                                
                                if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                                    
                                    var data = userData
                                    data.updateValue("sendMatch", forKey: "matchStatus")
                                    self.nearbyController?.users[uid] = data
                                    
                                } else {
                                    
                                    self.nearbyController?.users.updateValue(["matchStatus" : "sendMatch"], forKey: uid)
                                    
                                }
                            }
                        }
                    }
                })
            }
            
            ref.child("firstName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let name = snapshot.value as? String {
                        
                        self.firstName = name
                        
                        ref.child("age").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            
                            if let age = snapshot.value as? NSTimeInterval {
                                
                                let date = NSDate(timeIntervalSince1970: age)
                                let displayName = name + ", " + timeAgoSince(date, showAccronym: false)
                                
                                
                                if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                                    
                                    var data = userData
                                    data.updateValue(displayName, forKey: "displayName")
                                    self.nearbyController?.users[uid] = data
                                    
                                } else {
                                    
                                    self.nearbyController?.users.updateValue(["displayName" : displayName], forKey: uid)
                                    
                                }
                                
                                
                                self.nameOutlet.text = displayName
                                self.nameOutlet.lineBreakMode = .ByWordWrapping
                                
                            }
                        })
                    }
                    
                }
                
                
            })
            
            
            ref.child("lastName").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let lastName = snapshot.value as? String {
                        
                        self.lastName = lastName
                        
                        if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                            
                            var data = userData
                            data.updateValue(lastName, forKey: "lastName")
                            self.nearbyController?.users[uid] = data
                            
                        } else {
                            
                            self.nearbyController?.users.updateValue(["lastName" : lastName], forKey: uid)
                            
                        }
                    }

                    
                }
                
                            })
            
            
            
            ref.child("currentStatus").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let status = snapshot.value as? String {
                        
                        self.occupationOutlet.text = status
                        
                        if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                            
                            var data = userData
                            data.updateValue(status, forKey: "status")
                            self.nearbyController?.users[uid] = data
                            
                        } else {
                            
                            self.nearbyController?.users.updateValue(["status" : status], forKey: uid)
                            
                        }
 
                    } else {
                        
                        self.occupationOutlet.text = ""
                        
                    }
                }
            })
            
            ref.child("profilePicture").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let profile = snapshot.value as? String, url = NSURL(string: profile) {
                        
                        self.profilePic = profile
                        
                        if self.profileImage.sd_imageURL() != url {
                            self.profileImage.sd_setImageWithURL(url, placeholderImage: nil)
                        }

                        if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                            
                            var data = userData
                            data.updateValue(profile, forKey: "profile")
                            self.nearbyController?.users[uid] = data
                            
                        } else {
                            
                            self.nearbyController?.users.updateValue(["profile" : profile], forKey: uid)
                            
                        }
                    }
                }
            })
            
            
            ref.child("online").observeEventType(.Value, withBlock: { (snapshot) in
                
                if self.uid == uid {
                    
                    if let online = snapshot.value as? Bool {
                        
                        if online {
                            self.onlineOutlet.backgroundColor = UIColor.greenColor()
                        } else {
                            self.onlineOutlet.backgroundColor = UIColor.redColor()
                        }

                        if let userData = self.nearbyController?.users[uid] as? [NSObject : AnyObject] {
                            
                            var data = userData
                            data.updateValue(online, forKey: "online")
                            self.nearbyController?.users[uid] = data
                            
                        } else {
                            
                            self.nearbyController?.users.updateValue(["online" : online], forKey: uid)
                            
                        }
                    }
                }
            })
        }
    }
    
    
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
}
